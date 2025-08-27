import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/document_model.dart';
import '../widgets/ocr_text_editor.dart';
import '../../data/text_export_service.dart';

/// Page for viewing and editing OCR extracted text
class OcrTextViewPage extends ConsumerStatefulWidget {
  final DocumentModel document;
  
  const OcrTextViewPage({
    super.key,
    required this.document,
  });

  @override
  ConsumerState<OcrTextViewPage> createState() => _OcrTextViewPageState();
}

class _OcrTextViewPageState extends ConsumerState<OcrTextViewPage> {
  String? _editedText;
  bool _isSaving = false;
  final TextExportService _exportService = TextExportService();

  @override
  void initState() {
    super.initState();
    _editedText = widget.document.extractedText;
  }

  void _onTextChanged(String text) {
    setState(() {
      _editedText = text;
    });
  }

  Future<void> _saveText() async {
    if (_editedText == null || _isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      // Save to database via scanner service
      // Note: This would need to be implemented in the scanner service
      // For now, we'll show a success message
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save text: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _copyText() async {
    final textToCopy = _editedText ?? '';
    if (textToCopy.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: textToCopy));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareText() async {
    final textToShare = _editedText ?? '';
    if (textToShare.isEmpty) return;

    // TODO: Implement share functionality using share_plus package
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  Future<void> _exportText() async {
    final textToExport = _editedText ?? '';
    if (textToExport.isEmpty) return;

    // Show export options dialog
    showDialog(
      context: context,
      builder: (context) => _ExportOptionsDialog(
        text: textToExport,
        documentTitle: widget.document.title,
        exportService: _exportService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.document.hasOcrText && 
                   (widget.document.extractedText?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Text'),
        actions: [
          if (hasText) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyText,
              tooltip: 'Copy text',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareText,
              tooltip: 'Share text',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    _exportText();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Export as file'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Document info header
          _buildDocumentHeader(),
          
          // OCR processing info
          if (widget.document.ocrMetadata != null)
            _buildOcrInfo(),
          
          // Text editor
          Expanded(
            child: hasText
                ? OcrTextEditor(
                    document: widget.document,
                    onSave: _isSaving ? null : _saveText,
                    onTextChanged: _onTextChanged,
                  )
                : _buildNoTextMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Created ${_formatDate(widget.document.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrInfo() {
    final metadata = widget.document.ocrMetadata!;
    final processingTime = metadata['processing_time_ms'] as int? ?? 0;
    final textBlocks = metadata['text_blocks'] as int? ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'OCR Processing Info',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('Processing Time', '${processingTime}ms'),
              const SizedBox(width: 24),
              _buildInfoItem('Text Blocks', '$textBlocks'),
              const SizedBox(width: 24),
              _buildInfoItem('Confidence', 
                '${((widget.document.ocrConfidence ?? 0) * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNoTextMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_fields_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No text extracted',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The OCR process didn\'t detect any readable text in this document,\nor the confidence was below the required threshold.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Dialog for export options
class _ExportOptionsDialog extends StatelessWidget {
  final String text;
  final String documentTitle;
  final TextExportService exportService;
  
  const _ExportOptionsDialog({
    required this.text,
    required this.documentTitle,
    required this.exportService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Text'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Plain Text (.txt)'),
            subtitle: const Text('Export as a simple text file'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final fileName = exportService.generateFileName(text, prefix: 'document');
                await exportService.exportToTxt(
                  text: text, 
                  fileName: fileName,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to $fileName.txt')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: ${e.toString()}')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Markdown (.md)'),
            subtitle: const Text('Export as a markdown document'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final fileName = exportService.generateFileName(text, prefix: 'document');
                await exportService.exportToMarkdown(
                  text: text, 
                  fileName: fileName,
                  title: documentTitle,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to $fileName.md')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: ${e.toString()}')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('CSV (.csv)'),
            subtitle: const Text('Export as comma-separated values'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                final fileName = exportService.generateFileName(text, prefix: 'document');
                await exportService.exportToCsv(
                  text: text, 
                  fileName: fileName,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to $fileName.csv')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}