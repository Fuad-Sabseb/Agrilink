import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/models/inspection_model.dart';
import 'package:agrolink/core/models/inspection_operation_model.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/core/providers/inspection_provider.dart';
import 'package:agrolink/features/bureau/screens/bureau_dashboard_screen.dart';
import 'package:agrolink/features/bureau/screens/create_inspection_screen.dart';
import 'package:agrolink/features/bureau/screens/inspection_report_viewer_screen.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/routes/app_routes.dart';

/// Mock AuthProvider for Bureau Testing
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _testUser;

  void setTestUser(UserModel user) {
    _testUser = user;
    notifyListeners();
  }

  @override
  UserModel? get user => _testUser;

  @override
  String? get userId => _testUser?.id ?? 'OFF001';

  @override
  bool get isAuthenticated => _testUser != null;

  @override
  bool get isBureauOfficer => _testUser?.role.toLowerCase() == 'bureau_officer';

  @override
  bool get isFarmer => false;

  @override
  bool get isBuyer => false;

  @override
  bool get isTransporter => false;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isInitialized => true;

  @override
  List<String> get availableRoles => ['bureau_officer'];

  @override
  String? get currentRole => 'bureau_officer';

  @override
  bool get hasMultipleRoles => false;

  @override
  String? get userRole => 'bureau_officer';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock InspectionProvider for Bureau Testing
class MockInspectionProvider extends ChangeNotifier implements InspectionProvider {
  List<Inspection> _mockInspections = [];
  Inspection? _mockSelectedInspection;

  void setMockInspections(List<Inspection> list) {
    _mockInspections = list;
    notifyListeners();
  }

  @override
  List<Inspection> get inspections => _mockInspections;

  @override
  Inspection? get selectedInspection => _mockSelectedInspection;

  @override
  Map<String, dynamic>? get statistics => {
        'total': 12,
        'scheduled': 3,
        'inProgress': 2,
        'completed': 7,
        'passRate': 85.0,
      };

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<InspectionOperation> get offlineQueue => [];

  @override
  int get totalInspections => _mockInspections.length;

  @override
  int get scheduledCount =>
      _mockInspections.where((i) => i.status == InspectionStatus.scheduled).length;

  @override
  int get inProgressCount =>
      _mockInspections.where((i) => i.status == InspectionStatus.inProgress).length;

  @override
  int get completedCount =>
      _mockInspections.where((i) => i.status == InspectionStatus.completed).length;

  @override
  int get pendingOperationsCount => 0;

  @override
  Future<void> fetchInspections() async {}

  @override
  Future<void> selectInspection(String id) async {
    _mockSelectedInspection = _mockInspections.firstWhere(
      (i) => i.id == id,
      orElse: () => Inspection(
        id: id,
        officerId: 'OFF001',
        officerName: 'Abebe Kebede',
        type: InspectionType.routine,
        woredaId: 'woreda-001',
        woredaName: 'Jimma Town',
        checkInTime: DateTime.now(),
        status: InspectionStatus.scheduled,
      ),
    );
    notifyListeners();
  }

  @override
  Future<Inspection?> createInspection(Map<String, dynamic> data) async {
    final typeStr = data['type']?.toString();
    final type = InspectionType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => InspectionType.routine,
    );
    final inspection = Inspection(
      id: 'insp-created-1',
      officerId: 'OFF001',
      officerName: 'Abebe Kebede',
      type: type,
      woredaId: data['woredaId'] as String? ?? 'woreda-001',
      woredaName: data['woredaName'] as String? ?? 'Jimma Town',
      checkInTime: DateTime.now(),
      status: InspectionStatus.scheduled,
    );
    _mockInspections.insert(0, inspection);
    notifyListeners();
    return inspection;
  }

  Future<bool> updateInspectionStatus(String id, InspectionStatus status) async => true;

  @override
  Future<bool> addFinding(String inspectionId, InspectionFinding finding) async => true;

  Future<bool> addFindingWithPhoto({
    required String inspectionId,
    required String category,
    required String description,
    required FindingSeverity severity,
    String? recommendation,
    String? photoPath,
    String? caption,
  }) async => true;

  Future<bool> saveSignature({
    required String inspectionId,
    required String signerName,
    required String signerRole,
    required String signatureData,
  }) async => true;

  @override
  void clearSelectedInspection() {
    _mockSelectedInspection = null;
    notifyListeners();
  }

  void clearError() {
    notifyListeners();
  }

  Future<void> retryFailedOperations() async {}

  List<Inspection> filterInspections({
    InspectionStatus? status,
    InspectionType? type,
    String? woredaId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) => _mockInspections;

  @override
  List<Inspection> sortInspections(List<Inspection> inspections, SortOption sortOption) =>
      inspections;

  @override
  Future<void> addPhoto(
    String inspectionId,
    String photoPath, {
    Function(double)? onProgress,
  }) async {}

  @override
  Future<void> completeInspection(
    String inspectionId,
    String signature,
  ) async {}

  @override
  List<Inspection> filteredInspections({
    InspectionStatus? status,
    InspectionType? type,
    String? woredaId,
    DateTime? startDate,
    DateTime? endDate,
  }) => _mockInspections;

  @override
  List<Inspection> searchInspections(String query) => _mockInspections;

  @override
  Future<void> startInspection(String inspectionId) async {}

  @override
  Future<int> syncOfflineOperations() async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockInspectionProvider mockInspectionProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockInspectionProvider = MockInspectionProvider();

    final officerUser = UserModel(
      id: 'OFF001',
      fullName: 'Abebe Kebede',
      phone: '+251911234567',
      password: '',
      role: 'bureau_officer',
      location: 'Jimma',
      createdAt: DateTime.now(),
      email: 'officer@example.com',
      isVerified: true,
      roleData: {
        'assignedWoredas': ['woreda-001', 'woreda-002', 'woreda-003'],
      },
    );
    mockAuthProvider.setTestUser(officerUser);

    mockInspectionProvider.setMockInspections([
      Inspection(
        id: 'insp-001',
        officerId: 'OFF001',
        officerName: 'Abebe Kebede',
        type: InspectionType.routine,
        woredaId: 'woreda-001',
        woredaName: 'Jimma Town',
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: InspectionStatus.inProgress,
      ),
      Inspection(
        id: 'insp-002',
        officerId: 'OFF001',
        officerName: 'Abebe Kebede',
        type: InspectionType.followUp,
        woredaId: 'woreda-002',
        woredaName: 'Agaro',
        checkInTime: DateTime.now().subtract(const Duration(days: 1)),
        status: InspectionStatus.completed,
      ),
    ]);
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<InspectionProvider>.value(value: mockInspectionProvider),
      ],
      child: MaterialApp(
        routes: AppRoutes.routes,
        home: child,
      ),
    );
  }

  group('Phase 2 AppRoutes Verification', () {
    test('should have all Phase 2 bureau routes registered', () {
      final routes = AppRoutes.routes;
      expect(routes.containsKey(AppRoutes.bureauDashboard), isTrue);
      expect(routes.containsKey(AppRoutes.createInspection), isTrue);
      expect(routes.containsKey(AppRoutes.inspectionList), isTrue);
      expect(routes.containsKey(AppRoutes.inspectionDetails), isTrue);
    });
  });

  group('BureauDashboardScreen Widget Tests', () {
    testWidgets('should render dashboard tabs and overview contents', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const BureauDashboardScreen(officerId: 'OFF001')));
      await tester.pumpAndSettle();

      expect(find.text('Bureau Dashboard'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Inspections'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);

      // Verify officer card loads
      expect(find.text('Abebe Kebede'), findsOneWidget);

      // Verify quick action buttons exist
      expect(find.text('New Inspection'), findsOneWidget);
      expect(find.text('Generate Report'), findsOneWidget);
      expect(find.text('View All Inspections & Filter'), findsOneWidget);
    });

    testWidgets('should switch to Inspections tab and display inspections', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const BureauDashboardScreen(officerId: 'OFF001')));
      await tester.pumpAndSettle();

      // Tap the Inspections tab
      await tester.tap(find.text('Inspections'));
      await tester.pumpAndSettle();

      // Should display inspection items
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('CreateInspectionScreen Target Selection Tests', () {
    testWidgets('should render form fields initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateInspectionScreen()));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Create Inspection')), findsOneWidget);
      expect(find.text('Routine Inspection'), findsOneWidget);
      expect(find.text('Target Type'), findsOneWidget);
      expect(find.text('Cooperative'), findsOneWidget);
      expect(find.text('Farm'), findsOneWidget);
      expect(find.text('Select Cooperative'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Create Inspection'), findsOneWidget);
    });

    testWidgets('should validate form and reject submission without target', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateInspectionScreen()));
      await tester.pumpAndSettle();

      // Scroll to submit button and tap
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(ElevatedButton, 'Create Inspection');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Validation error message should appear
      expect(find.text('Please select a cooperative'), findsOneWidget);
    });

    testWidgets('should open target search bottom sheet and select cooperative', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateInspectionScreen()));
      await tester.pumpAndSettle();

      // Tap on target search icon to open modal bottom sheet
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Modal bottom sheet should be displayed
      expect(find.text('Select Cooperative'), findsWidgets);
      expect(find.text('Search Cooperative or woreda...'), findsOneWidget);
      expect(find.text('Jimma Coffee Growers Cooperative'), findsOneWidget);
      expect(find.text('Oromia Agricultural Cooperative Union'), findsOneWidget);

      // Filter by search query
      await tester.enterText(find.byType(TextField).last, 'Gomma');
      await tester.pumpAndSettle();

      expect(find.text('Gomma Multipurpose Farmers Coop'), findsOneWidget);
      expect(find.text('Jimma Coffee Growers Cooperative'), findsNothing);

      // Tap Gomma cooperative to select
      await tester.tap(find.text('Gomma Multipurpose Farmers Coop'));
      await tester.pumpAndSettle();

      // Bottom sheet should close, and target + woreda should be populated
      expect(find.text('Gomma Multipurpose Farmers Coop'), findsOneWidget);
      expect(find.text('Assigned Woreda'), findsOneWidget);
      expect(find.text('Gomma (woreda-003)'), findsOneWidget);
    });

    testWidgets('should switch target type to Farm and show farm targets', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateInspectionScreen()));
      await tester.pumpAndSettle();

      // Tap Farm radio
      await tester.tap(find.text('Farm'));
      await tester.pumpAndSettle();

      expect(find.text('Select Farm'), findsOneWidget);

      // Tap search icon to open bottom sheet
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Bottom sheet should display Farm options
      expect(find.text('Select Farm'), findsWidgets);
      expect(find.text('Abba Jifar Demonstration Farm'), findsOneWidget);
      expect(find.text('Agaro Specialty Plot'), findsOneWidget);

      // Tap Abba Jifar Demonstration Farm
      await tester.tap(find.text('Abba Jifar Demonstration Farm'));
      await tester.pumpAndSettle();

      expect(find.text('Abba Jifar Demonstration Farm'), findsOneWidget);
      expect(find.text('Jimma Town (woreda-001)'), findsOneWidget);
    });

    testWidgets('should successfully create inspection and return inspection to caller', (tester) async {
      Inspection? createdResult;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<InspectionProvider>.value(value: mockInspectionProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    createdResult = await Navigator.push<Inspection>(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateInspectionScreen()),
                    );
                  },
                  child: const Text('Open Create'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open CreateInspectionScreen
      await tester.tap(find.text('Open Create'));
      await tester.pumpAndSettle();

      // Select cooperative
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jimma Coffee Growers Cooperative'));
      await tester.pumpAndSettle();

      // Scroll to submit button and tap
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(ElevatedButton, 'Create Inspection');
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify returned created inspection and state update
      expect(createdResult, isNotNull);
      expect(createdResult!.woredaName, 'Jimma Town');
      expect(mockInspectionProvider.inspections.length, 3);
    });
  });

  group('InspectionReportViewerScreen Widget Tests', () {
    testWidgets('should render inspection report screen and handle report state', (tester) async {
      final sampleInspection = Inspection(
        id: 'insp-report-test',
        officerId: 'OFF001',
        officerName: 'Abebe Kebede',
        type: InspectionType.routine,
        woredaId: 'woreda-001',
        woredaName: 'Jimma Town',
        checkInTime: DateTime(2026, 10, 15, 10, 0),
        status: InspectionStatus.completed,
      );

      await tester.pumpWidget(buildTestableWidget(
        InspectionReportViewerScreen(inspection: sampleInspection),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Inspection Report'), findsOneWidget);
      // Because inspection has no signature, error state with retry is displayed
      expect(find.text('Error Generating Report'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
