import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/services/inspection/pdf_report_generator_service.dart';
import '../../../core/theme/colors.dart';

/// Inspection Report Viewer Screen
/// Displays PDF report with download and share options
/// Requirements: 9.1-9.11, 10.1-10.11
class InspectionReportViewerScreen extends StatefulWidget {
  final Inspection inspection;

  const InspectionReportViewerScreen({
    super.key,
    required this.inspection,
  });

  @override
  State<InspectionReportViewerScreen> createState() =>
      _InspectionReportViewerScreenState();
}

class _InspectionReportViewerScreenState
    extends State<InspectionReportViewerScreen> {
  final _pdfService = PdfReportGeneratorService();
  String? _pdfPath;
  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final path = await _pdfService.generateReport(widget.inspection);
      setState(() {
        _pdfPath = path;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Report'),
        backgroundColor: AppColors.primary,
        actions: [
          if (_pdfPath != null) ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _handleDownload,
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _handleShare,
              tooltip: 'Share',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating report...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_pdfPath == null) {
      return const Center(child: Text('Report not available'));
    }

    return _buildReportPreview();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.disabled),
            const SizedBox(height: 16),
            const Text(
              'Error Generating Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportMetadata(),
          const SizedBox(height: 24),
          _buildPdfPlaceholder(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildReportMetadata() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inspection Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.inspection.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildMetadataRow('Inspection Type', widget.inspection.type.displayName),
          const SizedBox(height: 8),
          _buildMetadataRow('Target', widget.inspection.cooperativeName ?? 
              widget.inspection.farmName ?? 'Unknown'),
          const SizedBox(height: 8),
          _buildMetadataRow('Officer', widget.inspection.officerName),
          const SizedBox(height: 8),
          _buildMetadataRow('Date', _formatDate(widget.inspection.checkInTime)),
          const SizedBox(height: 8),
          _buildMetadataRow('Status', widget.inspection.status.displayName),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfPlaceholder() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 80, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text(
            'PDF Report Generated',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the buttons below to view, download, or share',
            style: TextStyle(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'File: ${_pdfPath!.split('/').last}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _handleDownload,
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text(
            'Download to Device',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _handleShare,
          icon: const Icon(Icons.share),
          label: const Text('Share Report'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            if (_pdfPath == null) return;
            final file = File(_pdfPath!);
            if (await file.exists()) {
              try {
                final uri = Uri.file(_pdfPath!);
                final launched = await launchUrl(uri);
                if (!launched) {
                  await _handleShare();
                }
              } catch (_) {
                await _handleShare();
              }
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report file not found. Please regenerate.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open in Viewer'),
        ),
      ],
    );
  }

  Future<void> _handleDownload() async {
    try {
      // Copy to Downloads folder
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        // Fallback to app documents if Downloads not accessible
        final appDir = await getApplicationDocumentsDirectory();
        final targetPath = '${appDir.path}/${_pdfPath!.split('/').last}';
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to: $targetPath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      final fileName = 'inspection_${widget.inspection.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final targetPath = '${downloadsDir.path}/$fileName';
      
      final sourceFile = File(_pdfPath!);
      await sourceFile.copy(targetPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report downloaded to: $targetPath'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    try {
      final file = File(_pdfPath!);
      if (!await file.exists()) {
        throw Exception('Report file not found');
      }

      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        subject: 'Inspection Report - ${widget.inspection.id}',
        text: 'Inspection report for ${widget.inspection.cooperativeName ?? widget.inspection.farmName}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
