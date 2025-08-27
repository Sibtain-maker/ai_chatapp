import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/scanner_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/enhanced_preview_dialog.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _permissionError;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Add timeout to prevent indefinite loading
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Camera initialization timeout'),
      );
      
      if (cameras.isEmpty) {
        setState(() {
          _permissionError = 'No cameras available on this device';
          _isCameraInitialized = false;
          _isInitializing = false;
        });
        return;
      }

      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Camera initialization timeout'),
      );
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _permissionError = null;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _permissionError = 'Camera permission needed. Please allow camera access and try again.';
          _isCameraInitialized = false;
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      
      // Show preview dialog
      if (mounted) {
        _showImagePreview(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        _showImagePreview(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during processing
      builder: (context) => EnhancedPreviewDialog(
        originalImagePath: imagePath,
        onRetake: () => Navigator.of(context).pop(),
        onSave: () {
          Navigator.of(context).pop();
          _saveDocument(imagePath);
        },
      ),
    );
  }

  Future<void> _saveDocument(String imagePath) async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final scannerService = ref.read(scannerServiceProvider);
      final imageFile = File(imagePath);
      
      await scannerService.saveScannedDocument(
        imageFile: imageFile,
        userId: user.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      setState(() {
        _isFlashOn = !_isFlashOn; // Revert on error
      });
    }
  }

  Widget _buildCameraPreview() {
    if (_permissionError != null) {
      return _buildPermissionError();
    }

    if (_isInitializing && (!_isCameraInitialized || _cameraController == null)) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few seconds',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        // Overlay for edge detection visual guide
        CustomPaint(
          painter: EdgeDetectionOverlayPainter(),
          child: Container(),
        ),
        // Camera controls
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              FloatingActionButton(
                heroTag: 'gallery',
                onPressed: _pickFromGallery,
                backgroundColor: Colors.black54,
                child: const Icon(Icons.photo_library, color: Colors.white),
              ),
              // Capture button
              FloatingActionButton.large(
                heroTag: 'capture',
                onPressed: _captureImage,
                backgroundColor: Colors.white,
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
              ),
              // Flash button
              FloatingActionButton(
                heroTag: 'flash',
                onPressed: _toggleFlash,
                backgroundColor: Colors.black54,
                child: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionError() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 24),
              Text(
                _permissionError!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Allow camera permission in Settings or use Gallery to select photos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _permissionError = null;
                  });
                  _initializeCamera();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Try Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Scanner Tips'),
                  content: const Text(
                    'Position the document within the guide lines for best results. '
                    'Ensure good lighting and avoid shadows. '
                    'The scanner will automatically detect edges and correct perspective.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _buildCameraPreview(),
    );
  }
}

// Custom painter for edge detection overlay
class EdgeDetectionOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double margin = 40;
    final rect = Rect.fromLTWH(
      margin,
      margin,
      size.width - margin * 2,
      size.height - margin * 2,
    );

    // Draw corner guides
    const double cornerLength = 30;
    
    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}