import 'package:flutter_test/flutter_test.dart';
import 'package:agrolink/core/models/inspection_model.dart';

/// Integration test for complete inspection workflow
/// Tests the entire flow from creation to completion
void main() {
  group('Inspection Workflow Integration', () {
    test('should create inspection with required fields', () {
      final inspection = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: DateTime.now(),
        status: InspectionStatus.scheduled,
      );

      expect(inspection.id, 'test-123');
      expect(inspection.status, InspectionStatus.scheduled);
      expect(inspection.type, InspectionType.routine);
      expect(inspection.isComplete, false);
      expect(inspection.isInProgress, false);
    });

    test('should update inspection status', () {
      final inspection = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: DateTime.now(),
        status: InspectionStatus.scheduled,
      );

      final updated = inspection.copyWith(
        status: InspectionStatus.inProgress,
      );

      expect(updated.status, InspectionStatus.inProgress);
      expect(updated.isInProgress, true);
      expect(updated.id, inspection.id);
    });

    test('should add findings to inspection', () {
      final finding = InspectionFinding(
        id: 'finding-1',
        category: 'Crop Quality',
        description: 'Test finding',
        severity: FindingSeverity.moderate,
        timestamp: DateTime.now(),
      );

      final inspection = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: DateTime.now(),
        status: InspectionStatus.inProgress,
        findings: [finding],
      );

      expect(inspection.findings.length, 1);
      expect(inspection.findings.first.category, 'Crop Quality');
      expect(inspection.findings.first.severity, FindingSeverity.moderate);
    });

    test('should calculate issue count correctly', () {
      final findings = [
        InspectionFinding(
          id: 'f1',
          category: 'Safety',
          description: 'Critical issue',
          severity: FindingSeverity.critical,
          timestamp: DateTime.now(),
        ),
        InspectionFinding(
          id: 'f2',
          category: 'Quality',
          description: 'Major issue',
          severity: FindingSeverity.major,
          timestamp: DateTime.now(),
        ),
        InspectionFinding(
          id: 'f3',
          category: 'Minor',
          description: 'Minor issue',
          severity: FindingSeverity.minor,
          timestamp: DateTime.now(),
        ),
      ];

      final inspection = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: DateTime.now(),
        findings: findings,
      );

      // Issue count includes only critical and major
      expect(inspection.issueCount, 2);
    });

    test('should complete inspection workflow', () {
      final checkIn = DateTime.now();
      final checkOut = checkIn.add(const Duration(hours: 2));

      final inspection = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: checkIn,
        checkOutTime: checkOut,
        status: InspectionStatus.completed,
        signature: 'base64signature',
        findings: [
          InspectionFinding(
            id: 'f1',
            category: 'Test',
            description: 'Test finding',
            severity: FindingSeverity.minor,
            timestamp: DateTime.now(),
          ),
        ],
      );

      expect(inspection.isComplete, true);
      expect(inspection.signature, isNotNull);
      expect(inspection.findings.isNotEmpty, true);
      expect(inspection.duration, isNotNull);
      expect(inspection.duration!.inHours, 2);
    });

    test('should serialize and deserialize inspection', () {
      final original = Inspection(
        id: 'test-123',
        officerId: 'officer-1',
        officerName: 'Test Officer',
        type: InspectionType.routine,
        woredaId: 'woreda-1',
        woredaName: 'Test Woreda',
        checkInTime: DateTime.now(),
        status: InspectionStatus.completed,
      );

      final json = original.toJson();
      final deserialized = Inspection.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.officerId, original.officerId);
      expect(deserialized.type, original.type);
      expect(deserialized.status, original.status);
    });
  });
}
