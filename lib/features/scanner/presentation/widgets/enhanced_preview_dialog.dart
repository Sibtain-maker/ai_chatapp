import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/scanner_service.dart';
import '../../data/ai_enhancement_service.dart';
import '../../../auth/providers/auth_provider.dart';

class EnhancedPreviewDialog extends ConsumerStatefulWidget {
  final String originalImagePath;
  final VoidCallback onRetake;
  final VoidCallback onSave;

  const EnhancedPreviewDialog({
    super.key,
    required this.originalImagePath,
    required this.onRetake,
    required this.onSave,
  });

  @override
  ConsumerState<EnhancedPreviewDialog> createState() => _EnhancedPreviewDialogState();
}

class _EnhancedPreviewDialogState extends ConsumerState<EnhancedPreviewDialog> {
  EnhancementResult? _enhancementResult;
  bool _isProcessing = false;
  bool _showOriginal = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processEnhancement();
  }

  Future<void> _processEnhancement() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final scannerService = ref.read(scannerServiceProvider);
      final originalFile = File(widget.originalImagePath);
      
      final result = await scannerService.getEnhancementPreview(
        originalFile: originalFile,
        userId: user.id,
      );

      if (mounted) {
        setState(() {
          _enhancementResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  void _toggleComparison() {
    setState(() {
      _showOriginal = !_showOriginal;
    });
  }

  void _onSave() {
    // Save the enhanced version
    widget.onSave();
    
    // Cleanup temporary files
    if (_enhancementResult != null) {
      ref.read(aiEnhancementServiceProvider)
          .cleanupTempFile(_enhancementResult!.enhancedFile);
    }
  }

  void _onRetake() {
    // Cleanup temporary files
    if (_enhancementResult != null) {
      ref.read(aiEnhancementServiceProvider)
          .cleanupTempFile(_enhancementResult!.enhancedFile);
    }
    widget.onRetake();
  }

  @override
  void dispose() {
    // Cleanup temporary files when dialog is disposed
    if (_enhancementResult != null) {
      ref.read(aiEnhancementServiceProvider)
          .cleanupTempFile(_enhancementResult!.enhancedFile);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with toggle and actions
          AppBar(
            title: Text(_isProcessing 
              ? 'Processing...' 
              : _error != null 
                ? 'Error' 
                : 'AI Enhanced Preview'),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            actions: [
              if (!_isProcessing && _error == null)
                IconButton(
                  onPressed: _toggleComparison,
                  icon: Icon(_showOriginal ? Icons.auto_fix_high : Icons.compare),
                  tooltip: _showOriginal ? 'Show Enhanced' : 'Show Original',
                ),
              TextButton(
                onPressed: (_isProcessing || _error != null) ? null : _onSave,
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          
          // Image display area
          Flexible(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxHeight: 500,
                minHeight: 300,
              ),
              child: _buildImageDisplay(),
            ),
          ),
          
          // Enhancement info and controls
          if (!_isProcessing && _error == null && _enhancementResult != null)
            _buildEnhancementInfo(),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _onRetake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retake'),
                ),
                ElevatedButton(
                  onPressed: (_isProcessing || _error != null) ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isProcessing 
                    ? 'Processing...' 
                    : _error != null 
                      ? 'Error' 
                      : 'Use Enhanced Photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_isProcessing) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 16),
              Text(
                'AI Enhancement in Progress...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This may take up to 3 seconds',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: Colors.red[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Enhancement Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _processEnhancement,
                child: const Text('Retry Enhancement'),
              ),
            ],
          ),
        ),
      );
    }

    if (_enhancementResult == null) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show original or enhanced image
    final imageFile = _showOriginal 
        ? _enhancementResult!.originalFile 
        : _enhancementResult!.enhancedFile;

    return Stack(
      children: [
        Image.file(
          imageFile,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
        // Comparison indicator
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _showOriginal ? Colors.grey[700] : Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _showOriginal ? 'ORIGINAL' : 'AI ENHANCED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancementInfo() {
    if (_enhancementResult == null) return const SizedBox.shrink();

    final metadata = _enhancementResult!.enhancementMetadata;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'AI Enhancement Complete',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard(
                'Processing Time',
                '${_enhancementResult!.processingTimeMs}ms',
                Icons.timer,
              ),
              _buildMetricCard(
                'Quality Score',
                '${metadata.qualityScore.round()}%',
                Icons.trending_up,
              ),
              _buildMetricCard(
                'Algorithm',
                metadata.algorithm.split('_')[1], // Show V1, V2, etc.
                Icons.psychology,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the compare button above to toggle between original and enhanced versions',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}