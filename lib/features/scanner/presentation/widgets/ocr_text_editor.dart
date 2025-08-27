import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/document_model.dart';

/// Widget for editing OCR extracted text with error correction capabilities
class OcrTextEditor extends ConsumerStatefulWidget {
  final DocumentModel document;
  final VoidCallback? onSave;
  final Function(String)? onTextChanged;
  
  const OcrTextEditor({
    super.key,
    required this.document,
    this.onSave,
    this.onTextChanged,
  });

  @override
  ConsumerState<OcrTextEditor> createState() => _OcrTextEditorState();
}

class _OcrTextEditorState extends ConsumerState<OcrTextEditor> {
  late TextEditingController _textController;
  late String _originalText;
  bool _hasChanges = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _originalText = widget.document.extractedText ?? '';
    _textController = TextEditingController(text: _originalText);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = _textController.text;
    final hasChanges = currentText != _originalText;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
    
    widget.onTextChanged?.call(currentText);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _resetText() {
    _textController.text = _originalText;
    setState(() {
      _hasChanges = false;
    });
  }

  void _clearText() {
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return _buildFullScreenEditor();
    }
    
    return _buildCompactEditor();
  }

  Widget _buildCompactEditor() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildTextEditor(maxLines: 8),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFullScreenEditor() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Extracted Text'),
        leading: IconButton(
          icon: const Icon(Icons.fullscreen_exit),
          onPressed: _toggleFullScreen,
        ),
        actions: [
          if (_hasChanges) ...[
            TextButton(
              onPressed: _resetText,
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: widget.onSave,
              child: const Text('Save'),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildConfidenceIndicator(),
            const SizedBox(height: 16),
            Expanded(child: _buildTextEditor()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.text_fields, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          const Text(
            'Extracted Text',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildConfidenceIndicator(),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _toggleFullScreen,
            tooltip: 'Full screen editor',
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidence = widget.document.ocrConfidence ?? 0.0;
    final percentage = (confidence * 100).round();
    
    Color indicatorColor;
    if (confidence >= 0.9) {
      indicatorColor = Colors.green;
    } else if (confidence >= 0.7) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$percentage% confident',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTextEditor({int? maxLines}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _textController,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: widget.document.extractedText?.isEmpty ?? true
              ? 'No text extracted. You can add text manually here...'
              : 'Edit the extracted text to correct any errors...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_textController.text.length} characters',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          if (_hasChanges) ...[
            TextButton(
              onPressed: _resetText,
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: _clearText,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: widget.onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? Colors.orange : Colors.grey[300],
              foregroundColor: _hasChanges ? Colors.white : Colors.grey[600],
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Preview widget showing original vs edited text comparison
class TextComparisonWidget extends StatelessWidget {
  final String originalText;
  final String editedText;
  
  const TextComparisonWidget({
    super.key,
    required this.originalText,
    required this.editedText,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText == editedText) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('No changes made to the extracted text.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.compare_arrows, size: 20),
                SizedBox(width: 8),
                Text(
                  'Text Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Original (OCR):',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    originalText.isEmpty ? '(No original text)' : originalText,
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Edited:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    editedText.isEmpty ? '(No edited text)' : editedText,
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}