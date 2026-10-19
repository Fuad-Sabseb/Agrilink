import 'dart:math';
import '../models/bureau_officer_model.dart';
import '../models/inspection_model.dart';
import '../models/aggregate_report_model.dart';
import '../models/crop_plot_model.dart';

/// Bureau Oversight Service
/// Manages government/cooperative oversight functionality
class BureauOversightService {
  // Singleton pattern
  static final BureauOversightService _instance =
      BureauOversightService._internal();
  factory BureauOversightService() => _instance;
  BureauOversightService._internal();

  // Mock data storage
  final List<BureauOfficer> _officers = [];
  final List<Inspection> _inspections = [];
  final List<AggregateReport> _reports = [];

  /// Initialize mock data
  Future<void> initialize() async {
    if (_officers.isEmpty) {
      _generateMockOfficers();
      _generateMockInspections();
      _generateMockReports();
    }
  }

  // ==================== BUREAU OFFICERS ====================

  /// Get all bureau officers
  Future<List<BureauOfficer>> getOfficers() async {
    await initialize();
    return List.from(_officers);
  }

  /// Get officer by ID
  Future<BureauOfficer?> getOfficerById(String id) async {
    await initialize();
    try {
      return _officers.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get officers by woreda
  Future<List<BureauOfficer>> getOfficersByWoreda(String woredaId) async {
    await initialize();
    return _officers.where((o) => o.coversWoreda(woredaId)).toList();
  }

  // ==================== INSPECTIONS ====================

  /// Get all inspections
  Future<List<Inspection>> getInspections({
    String? officerId,
    String? woredaId,
    InspectionType? type,
    InspectionStatus? status,
  }) async {
    await initialize();
    var results = List<Inspection>.from(_inspections);

    if (officerId != null) {
      results = results.where((i) => i.officerId == officerId).toList();
    }
    if (woredaId != null) {
      results = results.where((i) => i.woredaId == woredaId).toList();
    }
    if (type != null) {
      results = results.where((i) => i.type == type).toList();
    }
    if (status != null) {
      results = results.where((i) => i.status == status).toList();
    }

    // Sort by check-in time descending
    results.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return results;
  }

  /// Get inspection by ID
  Future<Inspection?> getInspectionById(String id) async {
    await initialize();
    try {
      return _inspections.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get inspection history for a cooperative
  Future<List<Inspection>> getCooperativeInspectionHistory(
      String cooperativeId) async {
    await initialize();
    return _inspections
        .where((i) => i.cooperativeId == cooperativeId)
        .toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  /// Create new inspection (check-in)
  Future<Inspection> createInspection({
    required String officerId,
    required String officerName,
    required InspectionType type,
    String? cooperativeId,
    String? cooperativeName,
    String? farmId,
    String? farmName,
    required String woredaId,
    required String woredaName,
    double? latitude,
    double? longitude,
  }) async {
    final inspection = Inspection(
      id: 'INSP${DateTime.now().millisecondsSinceEpoch}',
      officerId: officerId,
      officerName: officerName,
      type: type,
      cooperativeId: cooperativeId,
      cooperativeName: cooperativeName,
      farmId: farmId,
      farmName: farmName,
      woredaId: woredaId,
      woredaName: woredaName,
      checkInTime: DateTime.now(),
      status: InspectionStatus.inProgress,
      latitude: latitude,
      longitude: longitude,
    );

    _inspections.add(inspection);
    return inspection;
  }

  /// Update inspection (add findings, notes, etc.)
  Future<Inspection> updateInspection(
    String inspectionId, {
    String? notes,
    List<InspectionFinding>? findings,
    List<String>? photoUrls,
    String? signature,
    int? farmersInterviewed,
    double? estimatedCropVolume,
  }) async {
    final index = _inspections.indexWhere((i) => i.id == inspectionId);
    if (index == -1) throw Exception('Inspection not found');

    final updated = _inspections[index].copyWith(
      notes: notes,
      findings: findings,
      photoUrls: photoUrls,
      signature: signature,
      farmersInterviewed: farmersInterviewed,
      estimatedCropVolume: estimatedCropVolume,
    );

    _inspections[index] = updated;
    return updated;
  }

  /// Complete inspection (check-out)
  Future<Inspection> completeInspection(
    String inspectionId, {
    String? notes,
    String? signature,
  }) async {
    final index = _inspections.indexWhere((i) => i.id == inspectionId);
    if (index == -1) throw Exception('Inspection not found');

    final updated = _inspections[index].copyWith(
      checkOutTime: DateTime.now(),
      status: InspectionStatus.completed,
      notes: notes,
      signature: signature,
    );

    _inspections[index] = updated;

    // Update officer's completed inspection count
    final officerIndex =
        _officers.indexWhere((o) => o.id == updated.officerId);
    if (officerIndex != -1) {
      _officers[officerIndex] = _officers[officerIndex].copyWith(
        completedInspections: _officers[officerIndex].completedInspections + 1,
        lastInspectionDate: DateTime.now(),
      );
    }

    return updated;
  }

  /// Add finding to inspection
  Future<Inspection> addFinding(
    String inspectionId, {
    required String category,
    required String description,
    required FindingSeverity severity,
    String? recommendation,
  }) async {
    final inspection = await getInspectionById(inspectionId);
    if (inspection == null) throw Exception('Inspection not found');

    final finding = InspectionFinding(
      id: 'FIND${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      description: description,
      severity: severity,
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );

    final updatedFindings = List<InspectionFinding>.from(inspection.findings)
      ..add(finding);

    return await updateInspection(inspectionId, findings: updatedFindings);
  }

  // ==================== AGGREGATE REPORTS ====================

  /// Get all reports
  Future<List<AggregateReport>> getReports({
    String? woredaId,
    ReportPeriod? period,
  }) async {
    await initialize();
    var results = List<AggregateReport>.from(_reports);

    if (woredaId != null) {
      results = results.where((r) => r.woredaId == woredaId).toList();
    }
    if (period != null) {
      results = results.where((r) => r.period == period).toList();
    }

    // Sort by report date descending
    results.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return results;
  }

  /// Get report by ID
  Future<AggregateReport?> getReportById(String id) async {
    await initialize();
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get woreda aggregates (crop volume by woreda)
  Future<Map<String, dynamic>> getWoredaAggregates(String woredaId) async {
    await initialize();

    final woredaReports = await getReports(woredaId: woredaId);
    if (woredaReports.isEmpty) {
      return {
        'woredaId': woredaId,
        'totalFarms': 0,
        'totalHectares': 0.0,
        'totalExpectedHarvest': 0.0,
        'totalActualHarvest': 0.0,
        'cropVolumes': <CropVolumeData>[],
      };
    }

    // Use the most recent report
    final latestReport = woredaReports.first;

    return {
      'woredaId': woredaId,
      'woredaName': latestReport.woredaName,
      'totalFarms': latestReport.totalFarms,
      'totalHectares': latestReport.totalHectares,
      'totalFarmers': latestReport.totalFarmers,
      'activeCooperatives': latestReport.activeCooperatives,
      'totalExpectedHarvest': latestReport.totalExpectedHarvest,
      'totalActualHarvest': latestReport.totalActualHarvest,
      'harvestCompletionRate': latestReport.harvestCompletionRate,
      'averageYieldPerHectare': latestReport.averageYieldPerHectare,
      'cropVolumes': latestReport.cropVolumes,
      'reportDate': latestReport.reportDate,
    };
  }

  /// Get cooperative list for a woreda
  Future<List<Map<String, dynamic>>> getCooperativeList(
      String woredaId) async {
    await initialize();

    // Mock cooperative data
    return [
      {
        'id': 'COOP001',
        'name': 'Jimma Coffee Growers Cooperative',
        'woredaId': woredaId,
        'memberCount': 245,
        'establishedYear': 2015,
        'lastInspection': DateTime.now().subtract(const Duration(days: 30)),
        'status': 'Active',
      },
      {
        'id': 'COOP002',
        'name': 'Oromia Farmers Union',
        'woredaId': woredaId,
        'memberCount': 189,
        'establishedYear': 2012,
        'lastInspection': DateTime.now().subtract(const Duration(days: 45)),
        'status': 'Active',
      },
      {
        'id': 'COOP003',
        'name': 'Agaro Agricultural Cooperative',
        'woredaId': woredaId,
        'memberCount': 156,
        'establishedYear': 2018,
        'lastInspection': DateTime.now().subtract(const Duration(days: 60)),
        'status': 'Active',
      },
    ];
  }

  /// Generate harvest report
  Future<AggregateReport> generateHarvestReport({
    required String woredaId,
    required String woredaName,
    required ReportPeriod period,
    required String officerId,
    required String officerName,
    String? zoneId,
    String? zoneName,
    String? notes,
  }) async {
    // Generate mock crop volume data
    final cropVolumes = [
      CropVolumeData(
        cropType: CropType.coffee,
        hectares: 450.5,
        expectedVolume: 900000, // 900 tons
        actualVolume: 875000, // 875 tons
        farmCount: 120,
        averageGrade: QualityGrade.grade1,
        averagePrice: 85.0,
        harvestStatus: HarvestStatus.inProgress,
        estimatedHarvestDate: DateTime.now().add(const Duration(days: 30)),
      ),
      CropVolumeData(
        cropType: CropType.maize,
        hectares: 320.0,
        expectedVolume: 640000, // 640 tons
        actualVolume: 620000, // 620 tons
        farmCount: 85,
        averageGrade: QualityGrade.standard,
        averagePrice: 12.5,
        harvestStatus: HarvestStatus.completed,
      ),
      CropVolumeData(
        cropType: CropType.teff,
        hectares: 280.0,
        expectedVolume: 420000, // 420 tons
        actualVolume: null, // Not yet harvested
        farmCount: 95,
        averageGrade: QualityGrade.grade2,
        averagePrice: 45.0,
        harvestStatus: HarvestStatus.preHarvest,
        estimatedHarvestDate: DateTime.now().add(const Duration(days: 60)),
      ),
    ];

    final report = AggregateReport(
      id: 'RPT${DateTime.now().millisecondsSinceEpoch}',
      woredaId: woredaId,
      woredaName: woredaName,
      zoneId: zoneId,
      zoneName: zoneName,
      reportDate: DateTime.now(),
      period: period,
      cropVolumes: cropVolumes,
      totalFarms: 300,
      activeCooperatives: 12,
      totalHectares: 1050.5,
      totalFarmers: 1250,
      generatedBy: officerId,
      generatedByName: officerName,
      notes: notes,
    );

    _reports.add(report);
    return report;
  }

  /// Get inspection statistics
  Future<Map<String, dynamic>> getInspectionStatistics({
    String? officerId,
    String? woredaId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await initialize();

    var inspections = List<Inspection>.from(_inspections);

    if (officerId != null) {
      inspections = inspections.where((i) => i.officerId == officerId).toList();
    }
    if (woredaId != null) {
      inspections = inspections.where((i) => i.woredaId == woredaId).toList();
    }
    if (startDate != null) {
      inspections =
          inspections.where((i) => i.checkInTime.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      inspections =
          inspections.where((i) => i.checkInTime.isBefore(endDate)).toList();
    }

    final completed =
        inspections.where((i) => i.status == InspectionStatus.completed).length;
    final inProgress = inspections
        .where((i) => i.status == InspectionStatus.inProgress)
        .length;
    final totalIssues = inspections.fold(0, (sum, i) => sum + i.issueCount);
    final totalFarmersInterviewed =
        inspections.fold(0, (sum, i) => sum + i.farmersInterviewed);

    return {
      'total': inspections.length,
      'completed': completed,
      'inProgress': inProgress,
      'completionRate':
          inspections.isEmpty ? 0.0 : (completed / inspections.length) * 100,
      'totalIssuesFound': totalIssues,
      'totalFarmersInterviewed': totalFarmersInterviewed,
      'byType': {
        'routine': inspections
            .where((i) => i.type == InspectionType.routine)
            .length,
        'followUp': inspections
            .where((i) => i.type == InspectionType.followUp)
            .length,
        'complaint': inspections
            .where((i) => i.type == InspectionType.complaint)
            .length,
        'preHarvest': inspections
            .where((i) => i.type == InspectionType.preHarvest)
            .length,
        'postHarvest': inspections
            .where((i) => i.type == InspectionType.postHarvest)
            .length,
      },
    };
  }

  // ==================== MOCK DATA GENERATION ====================

  void _generateMockOfficers() {
    final now = DateTime.now();

    _officers.addAll([
      BureauOfficer(
        id: 'OFF001',
        fullName: 'Abebe Kebede',
        employeeId: 'JZB-2018-001',
        phoneNumber: '+251911234567',
        email: 'abebe.kebede@moa.gov.et',
        rank: OfficerRank.coordinator,
        bureauName: 'Jimma Zone Agricultural Bureau',
        assignedWoredas: ['jimma', 'agaro', 'goma'],
        joinDate: DateTime(2018, 3, 15),
        specialization: 'Coffee Production',
        completedInspections: 156,
        lastInspectionDate: now.subtract(const Duration(days: 3)),
      ),
      BureauOfficer(
        id: 'OFF002',
        fullName: 'Chaltu Desalegn',
        employeeId: 'JZB-2019-012',
        phoneNumber: '+251922345678',
        email: 'chaltu.desalegn@moa.gov.et',
        rank: OfficerRank.seniorOfficer,
        bureauName: 'Jimma Zone Agricultural Bureau',
        assignedWoredas: ['jimma', 'seka'],
        joinDate: DateTime(2019, 7, 1),
        specialization: 'Grain Production',
        completedInspections: 98,
        lastInspectionDate: now.subtract(const Duration(days: 5)),
      ),
      BureauOfficer(
        id: 'OFF003',
        fullName: 'Dereje Tadesse',
        employeeId: 'JZB-2020-008',
        phoneNumber: '+251933456789',
        email: 'dereje.tadesse@moa.gov.et',
        rank: OfficerRank.fieldOfficer,
        bureauName: 'Jimma Zone Agricultural Bureau',
        assignedWoredas: ['agaro', 'limmu'],
        joinDate: DateTime(2020, 9, 10),
        specialization: 'Cooperative Management',
        completedInspections: 67,
        lastInspectionDate: now.subtract(const Duration(days: 2)),
      ),
      BureauOfficer(
        id: 'OFF004',
        fullName: 'Fikre Hailu',
        employeeId: 'JZB-2017-005',
        phoneNumber: '+251944567890',
        email: 'fikre.hailu@moa.gov.et',
        rank: OfficerRank.supervisor,
        bureauName: 'Jimma Zone Agricultural Bureau',
        assignedWoredas: ['jimma', 'agaro', 'seka', 'goma'],
        joinDate: DateTime(2017, 5, 20),
        specialization: 'Quality Control',
        completedInspections: 203,
        lastInspectionDate: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void _generateMockInspections() {
    final now = DateTime.now();
    final random = Random();

    _inspections.addAll([
      Inspection(
        id: 'INSP001',
        officerId: 'OFF001',
        officerName: 'Abebe Kebede',
        type: InspectionType.routine,
        cooperativeId: 'COOP001',
        cooperativeName: 'Jimma Coffee Growers Cooperative',
        woredaId: 'jimma',
        woredaName: 'Jimma',
        checkInTime: now.subtract(const Duration(days: 3, hours: 2)),
        checkOutTime: now.subtract(const Duration(days: 3)),
        status: InspectionStatus.completed,
        notes:
            'Cooperative storage facilities are well maintained. Quality control procedures are being followed.',
        findings: [
          InspectionFinding(
            id: 'FIND001',
            category: 'Storage',
            description: 'Minor moisture issue in warehouse section B',
            severity: FindingSeverity.minor,
            recommendation:
                'Improve ventilation and monitor humidity levels daily',
            timestamp: now.subtract(const Duration(days: 3, hours: 1)),
          ),
        ],
        latitude: 7.6746 + (random.nextDouble() - 0.5) * 0.1,
        longitude: 36.8341 + (random.nextDouble() - 0.5) * 0.1,
        farmersInterviewed: 15,
        estimatedCropVolume: 45000,
      ),
      Inspection(
        id: 'INSP002',
        officerId: 'OFF002',
        officerName: 'Chaltu Desalegn',
        type: InspectionType.preHarvest,
        cooperativeId: 'COOP002',
        cooperativeName: 'Oromia Farmers Union',
        woredaId: 'jimma',
        woredaName: 'Jimma',
        checkInTime: now.subtract(const Duration(hours: 4)),
        status: InspectionStatus.inProgress,
        notes: 'Pre-harvest assessment in progress. Crop quality looks good.',
        findings: [],
        latitude: 7.6746 + (random.nextDouble() - 0.5) * 0.1,
        longitude: 36.8341 + (random.nextDouble() - 0.5) * 0.1,
        farmersInterviewed: 8,
        estimatedCropVolume: 32000,
      ),
      Inspection(
        id: 'INSP003',
        officerId: 'OFF003',
        officerName: 'Dereje Tadesse',
        type: InspectionType.followUp,
        cooperativeId: 'COOP003',
        cooperativeName: 'Agaro Agricultural Cooperative',
        woredaId: 'agaro',
        woredaName: 'Agaro',
        checkInTime: now.subtract(const Duration(days: 5, hours: 3)),
        checkOutTime: now.subtract(const Duration(days: 5, hours: 1)),
        status: InspectionStatus.completed,
        notes: 'Follow-up inspection. Previous issues have been resolved.',
        findings: [
          InspectionFinding(
            id: 'FIND002',
            category: 'Documentation',
            description: 'Record keeping has improved significantly',
            severity: FindingSeverity.minor,
            recommendation: 'Continue current practices',
            timestamp: now.subtract(const Duration(days: 5, hours: 2)),
          ),
        ],
        latitude: 7.8456 + (random.nextDouble() - 0.5) * 0.1,
        longitude: 36.6234 + (random.nextDouble() - 0.5) * 0.1,
        farmersInterviewed: 12,
        estimatedCropVolume: 28000,
      ),
      Inspection(
        id: 'INSP004',
        officerId: 'OFF004',
        officerName: 'Fikre Hailu',
        type: InspectionType.postHarvest,
        cooperativeId: 'COOP001',
        cooperativeName: 'Jimma Coffee Growers Cooperative',
        woredaId: 'jimma',
        woredaName: 'Jimma',
        checkInTime: now.subtract(const Duration(days: 1, hours: 5)),
        checkOutTime: now.subtract(const Duration(days: 1, hours: 2)),
        status: InspectionStatus.completed,
        notes:
            'Post-harvest quality check completed. Coffee grade meets export standards.',
        findings: [
          InspectionFinding(
            id: 'FIND003',
            category: 'Crop Quality',
            description: 'Excellent coffee quality - Grade 1 standard',
            severity: FindingSeverity.minor,
            recommendation: 'Maintain current processing methods',
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
          ),
        ],
        latitude: 7.6746 + (random.nextDouble() - 0.5) * 0.1,
        longitude: 36.8341 + (random.nextDouble() - 0.5) * 0.1,
        farmersInterviewed: 20,
        estimatedCropVolume: 52000,
      ),
    ]);
  }

  void _generateMockReports() {
    final now = DateTime.now();

    _reports.addAll([
      AggregateReport(
        id: 'RPT001',
        woredaId: 'jimma',
        woredaName: 'Jimma',
        zoneId: 'jimma_zone',
        zoneName: 'Jimma Zone',
        reportDate: now.subtract(const Duration(days: 7)),
        period: ReportPeriod.monthly,
        cropVolumes: [
          CropVolumeData(
            cropType: CropType.coffee,
            hectares: 450.5,
            expectedVolume: 900000,
            actualVolume: 875000,
            farmCount: 120,
            averageGrade: QualityGrade.grade1,
            averagePrice: 85.0,
            harvestStatus: HarvestStatus.inProgress,
            estimatedHarvestDate: now.add(const Duration(days: 30)),
          ),
          CropVolumeData(
            cropType: CropType.maize,
            hectares: 320.0,
            expectedVolume: 640000,
            actualVolume: 620000,
            farmCount: 85,
            averageGrade: QualityGrade.standard,
            averagePrice: 12.5,
            harvestStatus: HarvestStatus.completed,
          ),
          CropVolumeData(
            cropType: CropType.teff,
            hectares: 280.0,
            expectedVolume: 420000,
            actualVolume: null,
            farmCount: 95,
            averageGrade: QualityGrade.grade2,
            averagePrice: 45.0,
            harvestStatus: HarvestStatus.preHarvest,
            estimatedHarvestDate: now.add(const Duration(days: 60)),
          ),
        ],
        totalFarms: 300,
        activeCooperatives: 12,
        totalHectares: 1050.5,
        totalFarmers: 1250,
        generatedBy: 'OFF001',
        generatedByName: 'Abebe Kebede',
        notes: 'Overall production is on track for this season.',
      ),
      AggregateReport(
        id: 'RPT002',
        woredaId: 'agaro',
        woredaName: 'Agaro',
        zoneId: 'jimma_zone',
        zoneName: 'Jimma Zone',
        reportDate: now.subtract(const Duration(days: 10)),
        period: ReportPeriod.monthly,
        cropVolumes: [
          CropVolumeData(
            cropType: CropType.coffee,
            hectares: 380.0,
            expectedVolume: 760000,
            actualVolume: 740000,
            farmCount: 95,
            averageGrade: QualityGrade.premium,
            averagePrice: 92.0,
            harvestStatus: HarvestStatus.inProgress,
            estimatedHarvestDate: now.add(const Duration(days: 25)),
          ),
          CropVolumeData(
            cropType: CropType.wheat,
            hectares: 180.0,
            expectedVolume: 360000,
            actualVolume: 355000,
            farmCount: 52,
            averageGrade: QualityGrade.grade1,
            averagePrice: 18.0,
            harvestStatus: HarvestStatus.completed,
          ),
        ],
        totalFarms: 147,
        activeCooperatives: 8,
        totalHectares: 560.0,
        totalFarmers: 680,
        generatedBy: 'OFF003',
        generatedByName: 'Dereje Tadesse',
        notes: 'Coffee quality in Agaro is exceptionally good this season.',
      ),
    ]);
  }
}
