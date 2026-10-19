import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../models/inspection_model.dart';

/// PDF Report Generator Service for Inspection Reports
/// Generates professional PDF reports from inspection data
/// Requirements: 8.1-8.15, 20.1-20.10
class PdfReportGeneratorService {
  static const String reportTitle = 'Ethiopian Agricultural Bureau';
  static const String reportSubtitle = 'Inspection Report';

  static final PdfColor _primaryColor = PdfColor.fromInt(0xFF3A7D44);
  static final PdfColor _secondaryColor = PdfColor.fromInt(0xFF8B5A3C);
  static final PdfColor _tertiaryColor = PdfColor.fromInt(0xFF4A90E2);
  static final PdfColor _accentColor = PdfColor.fromInt(0xFFD4AF37);
  static final PdfColor _errorColor = PdfColor.fromInt(0xFFD32F2F);
  static final PdfColor _creamBackground = PdfColor.fromInt(0xFFF5F1E8);

  /// Generate a PDF report from inspection data
  /// Returns the file path of the generated PDF
  Future<String> generateReport(Inspection inspection) async {
    if (inspection.signature == null || inspection.signature!.isEmpty) {
      throw Exception('Inspection must have a signature to generate report');
    }

    final pdf = pw.Document();

    // Add report pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildOfficerInfo(inspection),
          pw.SizedBox(height: 15),
          _buildInspectionDetails(inspection),
          pw.SizedBox(height: 15),
          _buildSummaryStatistics(inspection),
          pw.SizedBox(height: 15),
          _buildFindingsSection(inspection),
          pw.SizedBox(height: 15),
          _buildPhotosSection(inspection),
          pw.SizedBox(height: 15),
          _buildSignatureSection(inspection),
          pw.Spacer(),
          _buildFooter(inspection),
        ],
      ),
    );

    // Save PDF to file
    return await _savePdfToFile(pdf, inspection.id);
  }

  /// Build report header with Ethiopian Agricultural Bureau branding
  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          reportTitle,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          reportSubtitle,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.normal,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: _primaryColor),
      ],
    );
  }

  /// Build officer information section
  pw.Widget _buildOfficerInfo(Inspection inspection) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Inspector Information',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Officer Name', inspection.officerName),
              ),
              pw.Expanded(
                child: _buildInfoRow('Officer ID', inspection.officerId),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _buildInfoRow('Woreda', inspection.woredaName),
        ],
      ),
    );
  }

  /// Build inspection details section
  pw.Widget _buildInspectionDetails(Inspection inspection) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Inspection Details',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow('Inspection ID', inspection.id),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Type', inspection.type.displayName),
              ),
              pw.Expanded(
                child: _buildInfoRow('Status', inspection.status.displayName),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          if (inspection.cooperativeName != null)
            _buildInfoRow('Cooperative', inspection.cooperativeName!),
          if (inspection.farmName != null)
            _buildInfoRow('Farm', inspection.farmName!),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow(
                  'Check-in',
                  _formatDate(inspection.checkInTime),
                ),
              ),
              if (inspection.checkOutTime != null)
                pw.Expanded(
                  child: _buildInfoRow(
                    'Check-out',
                    _formatDate(inspection.checkOutTime!),
                  ),
                ),
            ],
          ),
          if (inspection.formattedDuration != null)
            pw.SizedBox(height: 4),
          if (inspection.formattedDuration != null)
            _buildInfoRow('Duration', inspection.formattedDuration!),
          if (inspection.notes != null && inspection.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Notes:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(inspection.notes!),
          ],
        ],
      ),
    );
  }

  /// Build summary statistics section
  pw.Widget _buildSummaryStatistics(Inspection inspection) {
    final grouped = _groupFindingsBySeverity(inspection.findings);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _creamBackground,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total Findings',
                inspection.findings.length.toString(),
                _tertiaryColor,
              ),
              _buildStatItem(
                'Critical',
                grouped[FindingSeverity.critical]?.length.toString() ?? '0',
                _errorColor,
              ),
              _buildStatItem(
                'Major',
                grouped[FindingSeverity.major]?.length.toString() ?? '0',
                _secondaryColor,
              ),
              _buildStatItem(
                'Moderate',
                grouped[FindingSeverity.moderate]?.length.toString() ?? '0',
                _accentColor,
              ),
              _buildStatItem(
                'Minor',
                grouped[FindingSeverity.minor]?.length.toString() ?? '0',
                _primaryColor,
              ),
            ],
          ),
          if (inspection.farmersInterviewed > 0) ...[
            pw.SizedBox(height: 8),
            pw.Text('Farmers Interviewed: ${inspection.farmersInterviewed}'),
          ],
          if (inspection.estimatedCropVolume != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Estimated Crop Volume: ${inspection.estimatedCropVolume!.toStringAsFixed(2)} kg',
            ),
          ],
        ],
      ),
    );
  }

  /// Build findings section
  pw.Widget _buildFindingsSection(Inspection inspection) {
    if (inspection.findings.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Text(
          'No findings reported during this inspection.',
          style: const pw.TextStyle(color: PdfColors.grey600),
        ),
      );
    }

    final grouped = _groupFindingsBySeverity(inspection.findings);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Findings',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...FindingSeverity.values.reversed.map((severity) {
          final findings = grouped[severity] ?? [];
          if (findings.isEmpty) return pw.SizedBox();

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _getSeverityColor(severity),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  '${severity.displayName} (${findings.length})',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              ...findings.map((finding) => _buildFindingItem(finding)),
              pw.SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Build individual finding item
  pw.Widget _buildFindingItem(InspectionFinding finding) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                finding.category,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                _formatDate(finding.timestamp),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(finding.description),
          if (finding.recommendation != null &&
              finding.recommendation!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Recommendation: ${finding.recommendation}',
              style: pw.TextStyle(
                fontSize: 10,
                color: _tertiaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build photos section
  pw.Widget _buildPhotosSection(Inspection inspection) {
    if (inspection.photoUrls.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Inspection Photos',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '${inspection.photoUrls.length} photo(s) captured during inspection.',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Wrap(
          spacing: 4,
          runSpacing: 4,
          children: inspection.photoUrls
              .take(6)
              .map((url) => pw.Container(
                    width: 80,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Photo',
                        style:
                            const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  /// Build signature section
  pw.Widget _buildSignatureSection(Inspection inspection) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Inspector Signature',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 100,
          width: 200,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Center(
            child: pw.Text(
              'Digital Signature',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Signed by: ${inspection.officerName}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        if (inspection.checkOutTime != null)
          pw.Text(
            'Date: ${_formatDate(inspection.checkOutTime!)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
      ],
    );
  }

  /// Build report footer
  pw.Widget _buildFooter(Inspection inspection) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated: ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Ethiopian Agricultural Bureau - Inspection Report',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper: Build info row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Helper: Build statistic item
  pw.Widget _buildStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// Helper: Group findings by severity
  Map<FindingSeverity, List<InspectionFinding>> _groupFindingsBySeverity(
    List<InspectionFinding> findings,
  ) {
    final Map<FindingSeverity, List<InspectionFinding>> grouped = {};

    for (final finding in findings) {
      if (!grouped.containsKey(finding.severity)) {
        grouped[finding.severity] = [];
      }
      grouped[finding.severity]!.add(finding);
    }

    return grouped;
  }

  /// Helper: Get color for severity level
  PdfColor _getSeverityColor(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.critical:
        return _errorColor;
      case FindingSeverity.major:
        return _secondaryColor;
      case FindingSeverity.moderate:
        return _accentColor;
      case FindingSeverity.minor:
        return _primaryColor;
    }
  }

  /// Helper: Format date for display
  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  /// Helper: Save PDF to file
  Future<String> _savePdfToFile(pw.Document pdf, String inspectionId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'inspection_report_$inspectionId.pdf';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}
