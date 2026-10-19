import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/inspection_provider.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/theme/colors.dart';
import '../dialogs/add_finding_dialog.dart';
import '../dialogs/signature_capture_dialog.dart';
import 'inspection_report_viewer_screen.dart';

/// Inspection Details Screen
/// Displays complete inspection information and allows actions
/// Requirements: 3.1-3.11, 5.4, 5.10, 6.1
class InspectionDetailsScreen extends StatefulWidget {
  final String inspectionId;

  const InspectionDetailsScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  State<InspectionDetailsScreen> createState() => _InspectionDetailsScreenState();
}

class _InspectionDetailsScreenState extends State<InspectionDetailsScreen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().selectInspection(widget.inspectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Details'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InspectionProvider>().fetchInspections();
            },
          ),
        ],
      ),
      body: Consumer<InspectionProvider>(
        builder: (context, provider, _) {
          final inspection = provider.selectedInspection;

          if (inspection == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(inspection),
                _buildInspectionInfo(inspection),
                _buildTimeline(inspection),
                if (inspection.findings.isNotEmpty) _buildFindings(inspection),
                if (inspection.photoUrls.isNotEmpty) _buildPhotos(inspection),
                if (inspection.notes != null) _buildNotes(inspection),
                if (inspection.signature != null) _buildSignature(inspection),
                _buildActions(inspection, provider),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Inspection inspection) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _getStatusColor(inspection.status).withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTypeBadge(inspection.type),
              const SizedBox(width: 8),
              _buildStatusBadge(inspection.status),
              if (inspection.issueCount > 0) ...[
                const SizedBox(width: 8),
                _buildIssueBadge(inspection.issueCount),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            inspection.cooperativeName ?? inspection.farmName ?? 'Unknown Target',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            inspection.woredaName,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionInfo(Inspection inspection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Inspection ID', inspection.id),
              const Divider(),
              _buildInfoRow('Officer', inspection.officerName),
              const Divider(),
              _buildInfoRow('Type', inspection.type.displayName),
              const Divider(),
              _buildInfoRow('Status', inspection.status.displayName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Inspection inspection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTimelineItem(
                Icons.login,
                'Check-in',
                _formatDateTime(inspection.checkInTime),
                AppColors.success,
              ),
              if (inspection.checkOutTime != null)
                _buildTimelineItem(
                  Icons.logout,
                  'Check-out',
                  _formatDateTime(inspection.checkOutTime!),
                  AppColors.tertiary,
                ),
              if (inspection.formattedDuration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Duration: ${inspection.formattedDuration}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindings(Inspection inspection) {
    final groupedFindings = <FindingSeverity, List<InspectionFinding>>{};
    for (final finding in inspection.findings) {
      groupedFindings.putIfAbsent(finding.severity, () => []).add(finding);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Findings (${inspection.findings.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (inspection.status == InspectionStatus.inProgress)
                    TextButton.icon(
                      onPressed: () => _handleAddFinding(inspection),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ...FindingSeverity.values.reversed.map((severity) {
                final findings = groupedFindings[severity] ?? [];
                if (findings.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeverityHeader(severity, findings.length),
                    const SizedBox(height: 8),
                    ...findings.map((finding) => _buildFindingCard(finding)),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotos(Inspection inspection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos (${inspection.photoUrls.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (inspection.status == InspectionStatus.inProgress)
                    TextButton.icon(
                      onPressed: () => _handleCapturePhoto(inspection),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Add'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: inspection.photoUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: AppColors.disabled),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotes(Inspection inspection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                inspection.notes!,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignature(Inspection inspection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inspector Signature',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Digital Signature'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Signed by: ${inspection.officerName}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(Inspection inspection, InspectionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (inspection.status == InspectionStatus.scheduled)
            ElevatedButton.icon(
              onPressed: () => _handleStartInspection(inspection, provider),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Start Inspection', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          if (inspection.status == InspectionStatus.inProgress) ...[
            ElevatedButton.icon(
              onPressed: () => _handleAddFinding(inspection),
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text('Add Finding', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _handleCapturePhoto(inspection),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _handleCompleteInspection(inspection, provider),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Complete Inspection', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
          if (inspection.status == InspectionStatus.completed)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectionReportViewerScreen(inspection: inspection),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text('Generate Report', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildTypeBadge(InspectionType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InspectionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIssueBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$count ${count == 1 ? 'Issue' : 'Issues'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityHeader(FindingSeverity severity, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${severity.displayName} ($count)',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFindingCard(InspectionFinding finding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  finding.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _formatDateTime(finding.timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(finding.description),
            if (finding.recommendation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        finding.recommendation!,
                        style: const TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Action handlers
  Future<void> _handleStartInspection(
    Inspection inspection,
    InspectionProvider provider,
  ) async {
    await provider.startInspection(inspection.id);
    
    if (!mounted) return;
    
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection started successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleAddFinding(Inspection inspection) async {
    final finding = await showDialog<InspectionFinding>(
      context: context,
      builder: (context) => const AddFindingDialog(),
    );

    if (finding != null && mounted) {
      final provider = context.read<InspectionProvider>();
      await provider.addFinding(inspection.id, finding);

      if (!mounted) return;

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finding added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleCapturePhoto(Inspection inspection) async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      final provider = context.read<InspectionProvider>();
      await provider.addPhoto(inspection.id, photo.path);

      if (!mounted) return;

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleCompleteInspection(
    Inspection inspection,
    InspectionProvider provider,
  ) async {
    // Validate findings exist
    if (inspection.findings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one finding before completing'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    // Capture signature
    final signature = await showDialog<String>(
      context: context,
      builder: (context) => const SignatureCaptureDialog(),
    );

    if (signature != null && mounted) {
      await provider.completeInspection(inspection.id, signature);

      if (!mounted) return;

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspection completed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  // Helper methods
  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.scheduled:
        return AppColors.tertiary;
      case InspectionStatus.inProgress:
        return AppColors.secondary;
      case InspectionStatus.completed:
        return AppColors.success;
      case InspectionStatus.cancelled:
        return AppColors.disabled;
    }
  }

  Color _getSeverityColor(FindingSeverity severity) {
    switch (severity) {
      case FindingSeverity.critical:
        return AppColors.error;
      case FindingSeverity.major:
        return AppColors.secondary;
      case FindingSeverity.moderate:
        return AppColors.accent;
      case FindingSeverity.minor:
        return AppColors.warning;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
