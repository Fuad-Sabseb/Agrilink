import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/routes/app_routes.dart';
import 'package:agrolink/core/models/trip_model.dart';
import 'package:agrolink/core/models/transport_request_model.dart';
import 'package:agrolink/core/models/crop_plot_model.dart';
import 'package:agrolink/core/models/proof_of_delivery.dart';
import 'package:agrolink/core/providers/transport_provider.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/core/repositories/transport_repository.dart';
import 'package:agrolink/features/transporter/screens/transporter_dashboard_screen.dart';
import 'package:agrolink/features/transporter/screens/available_jobs_screen.dart';
import 'package:agrolink/features/transporter/screens/active_deliveries_screen.dart';
import 'package:agrolink/features/transporter/screens/delivery_details_screen.dart';
import 'package:agrolink/features/transporter/screens/proof_of_delivery_screen.dart';
import 'package:agrolink/features/transporter/screens/earnings_screen.dart';
import 'package:agrolink/features/transporter/widgets/signature_pad_widget.dart';
import 'package:agrolink/models/user_model.dart';

// Valid 1x1 transparent PNG bytes for mock photo file
const List<int> _kTransparentPngBytes = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

/// Mock AuthProvider for Transporter Testing
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _testUser;

  void setTestUser(UserModel user) {
    _testUser = user;
    notifyListeners();
  }

  @override
  UserModel? get user => _testUser;

  @override
  String? get userId => _testUser?.id ?? 'transporter_001';

  @override
  bool get isAuthenticated => _testUser != null;

  @override
  bool get isTransporter => true;

  @override
  bool get isFarmer => false;

  @override
  bool get isBuyer => false;

  @override
  bool get isBureauOfficer => false;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isInitialized => true;

  @override
  List<String> get availableRoles => ['transporter'];

  @override
  String? get currentRole => 'transporter';

  @override
  bool get hasMultipleRoles => false;

  @override
  String? get userRole => 'transporter';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock TransportProvider for Transporter Testing
class MockTransportProvider extends ChangeNotifier implements TransportProvider {
  List<TransportRequest> _mockRequests = [];
  List<Trip> _mockTrips = [];
  bool _isLoading = false;
  String? _error;
  bool markDeliveredCalled = false;
  String? lastDeliveredTripId;
  bool markPickedUpCalled = false;
  bool markInTransitCalled = false;
  bool acceptJobCalled = false;

  void setMockRequests(List<TransportRequest> requests) {
    _mockRequests = requests;
    notifyListeners();
  }

  void setMockTrips(List<Trip> trips) {
    _mockTrips = trips;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  List<TransportRequest> get transportRequests => _mockRequests;

  @override
  List<TransportRequest> get filteredRequests => _mockRequests;

  @override
  List<Trip> get trips => _mockTrips;

  @override
  List<Trip> get filteredTrips => _mockTrips;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get hasError => _error != null;

  @override
  bool get isEmpty => _mockRequests.isEmpty && _mockTrips.isEmpty && !_isLoading;

  @override
  List<TransportRequest> get farmerRequests => _mockRequests;

  @override
  Future<void> loadPendingTransportRequests() async {}

  @override
  Future<void> loadActiveTrips() async {}

  @override
  Future<void> loadTripsByTransporter(String transporterId) async {}

  @override
  Future<void> loadAllTransportRequests() async {}

  @override
  Future<void> loadAllTrips() async {}

  @override
  Future<AcceptJobResult> acceptJobWithRaceCheck({
    required String jobId,
    required String transporterId,
    required String vehicleId,
    required DateTime estimatedPickupTime,
  }) async {
    acceptJobCalled = true;
    return AcceptJobResult(
      success: true,
      job: Trip(
        id: 'trip-accepted-1',
        transportRequestId: jobId,
        farmerId: 'farmer_001',
        transporterId: transporterId,
        vehicleId: vehicleId,
        routeId: 'route_001',
        cropType: CropType.coffee,
        quantityKg: 500,
        pickupLocation: 'Jimma Farm',
        deliveryLocation: 'Addis Ababa Central',
        totalCost: 1500,
        createdAt: DateTime.now(),
        status: TripStatus.matched,
      ),
    );
  }

  @override
  Future<bool> markTripPickedUp(String tripId, {String? note}) async {
    markPickedUpCalled = true;
    return true;
  }

  @override
  Future<bool> markTripInTransit(String tripId, {String? note}) async {
    markInTransitCalled = true;
    return true;
  }

  @override
  Future<bool> markTripDelivered(String tripId, {String? note}) async {
    markDeliveredCalled = true;
    lastDeliveredTripId = tripId;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock TransportRepository for Testing
class MockTransportRepository extends TransportRepository {
  File? mockPhotoFile;
  ProofOfDelivery? mockProofResult;
  bool shouldThrowPhotoError = false;
  bool shouldThrowSignatureError = false;
  bool capturePhotoCalled = false;
  bool captureProofOfDeliveryCalled = false;

  @override
  Future<File?> capturePhoto() async {
    capturePhotoCalled = true;
    if (shouldThrowPhotoError) {
      throw Exception('Photo capture error');
    }
    return mockPhotoFile;
  }

  @override
  Future<ProofOfDelivery?> captureProofOfDelivery({
    required String jobId,
    required String recipientName,
    String? notes,
    double? latitude,
    double? longitude,
    required SignatureData signatureData,
    File? photoFile,
  }) async {
    captureProofOfDeliveryCalled = true;
    if (shouldThrowPhotoError) {
      throw Exception('Photo upload error');
    }
    if (shouldThrowSignatureError) {
      throw Exception('Signature error');
    }
    return mockProofResult ??
        ProofOfDelivery(
          id: 'pod-test-success-001',
          jobId: jobId,
          photoUrl: 'https://storage.example.com/pod.jpg',
          signatureUrl: 'https://storage.example.com/sig.png',
          recipientName: recipientName,
          capturedAt: DateTime.now(),
          notes: notes,
        );
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockTransportProvider mockTransportProvider;
  late MockTransportRepository mockTransportRepository;
  late Directory tempDir;
  late File samplePhotoFile;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('transporter_test_');
    samplePhotoFile = File('${tempDir.path}/test_photo.png');
    await samplePhotoFile.writeAsBytes(_kTransparentPngBytes);
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockAuthProvider.setTestUser(
      UserModel(
        id: 'transporter_001',
        fullName: 'Abebe Transporter',
        email: 'abebe@transport.com',
        phone: '+251911223344',
        password: 'hashed_password',
        location: 'Addis Ababa',
        role: 'transporter',
        createdAt: DateTime.now(),
        roleData: {'vehicleId': 'VH-001'},
      ),
    );

    mockTransportProvider = MockTransportProvider();
    mockTransportRepository = MockTransportRepository();
    mockTransportRepository.mockPhotoFile = samplePhotoFile;
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<TransportProvider>.value(value: mockTransportProvider),
      ],
      child: MaterialApp(
        home: child,
        routes: AppRoutes.routes,
      ),
    );
  }

  group('AppRoutes Transporter Route Handler Tests', () {
    test('should define all transporter routes correctly', () {
      expect(AppRoutes.routes.containsKey(AppRoutes.transporterDashboardNew), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.availableJobs), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.activeDeliveries), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.deliveryDetails), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.proofOfDelivery), isTrue);
      expect(AppRoutes.routes.containsKey(AppRoutes.earnings), isTrue);
    });

    testWidgets('deliveryDetails route should handle null arguments gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.deliveryDetails),
              child: const Text('Open Details'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      expect(find.text('Delivery not found'), findsOneWidget);
    });

    testWidgets('proofOfDelivery route should handle null arguments gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.proofOfDelivery),
              child: const Text('Open POD'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open POD'));
      await tester.pumpAndSettle();

      expect(find.text('Delivery not found'), findsOneWidget);
    });
  });

  group('TransporterDashboardScreen Widget Tests', () {
    testWidgets('should render dashboard title, welcome banner, and 0 stats initially', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TransporterDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Transporter Dashboard'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Available Jobs'), findsWidgets);
      expect(find.text('Active Deliveries'), findsWidgets);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Earnings'), findsWidgets);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Browse Jobs'), findsOneWidget);
      expect(find.text('My Deliveries'), findsOneWidget);
    });

    testWidgets('should render active delivery card with short and long trip IDs safely', (tester) async {
      final activeTrip = Trip(
        id: 'TR01', // Short ID (< 8 chars) to test substring safety
        transportRequestId: 'req-001',
        farmerId: 'farmer_001',
        transporterId: 'transporter_001',
        vehicleId: 'VH-001',
        routeId: 'route_001',
        cropType: CropType.coffee,
        quantityKg: 800,
        pickupLocation: 'Jimma Farm A',
        deliveryLocation: 'Bole Terminal',
        totalCost: 2400,
        createdAt: DateTime.now(),
        status: TripStatus.inTransit,
      );

      mockTransportProvider.setMockTrips([activeTrip]);

      await tester.pumpWidget(buildTestableWidget(const TransporterDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Delivery #TR01'), findsOneWidget);
      expect(find.text('Bole Terminal'), findsOneWidget);
    });

    testWidgets('tapping Browse Jobs should navigate to AvailableJobsScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const TransporterDashboardScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Browse Jobs'));
      await tester.tap(find.text('Browse Jobs'));
      await tester.pumpAndSettle();

      expect(find.byType(AvailableJobsScreen), findsOneWidget);
      expect(find.text('Available Jobs'), findsOneWidget);
    });
  });

  group('AvailableJobsScreen Widget Tests', () {
    testWidgets('should render empty state when no jobs are available', (tester) async {
      mockTransportProvider.setMockRequests([]);

      await tester.pumpWidget(buildTestableWidget(const AvailableJobsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Available Jobs'), findsOneWidget);
      expect(find.text('No Jobs Available'), findsOneWidget);
    });

    testWidgets('should render job cards when jobs are available', (tester) async {
      final sampleJob = TransportRequest(
        id: 'req-test-100',
        farmerId: 'farmer_001',
        cropType: CropType.coffee,
        quantityKg: 1000,
        pickupLocation: 'Gomad Depot',
        deliveryLocation: 'Mercato Warehouse',
        requestedPickupDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        requiresRefrigeration: true,
      );

      mockTransportProvider.setMockRequests([sampleJob]);

      await tester.pumpWidget(buildTestableWidget(const AvailableJobsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('COFFEE'), findsOneWidget);
      expect(find.text('Gomad Depot'), findsOneWidget);
      expect(find.text('Mercato Warehouse'), findsOneWidget);
      expect(find.text('Accept Job'), findsOneWidget);
      expect(find.text('Refrigerated'), findsOneWidget);
    });

    testWidgets('should open accept job dialog and handle acceptance flow', (tester) async {
      final sampleJob = TransportRequest(
        id: 'req-test-200',
        farmerId: 'farmer_001',
        cropType: CropType.maize,
        quantityKg: 2000,
        pickupLocation: 'Hawassa Farm',
        deliveryLocation: 'Adama Hub',
        requestedPickupDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      mockTransportProvider.setMockRequests([sampleJob]);

      await tester.pumpWidget(buildTestableWidget(const AvailableJobsScreen()));
      await tester.pumpAndSettle();

      // Tap Accept Job button on the card
      await tester.tap(find.text('Accept Job'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Accept Job'), findsWidgets);
      expect(find.text('Do you want to accept transport job for Maize?'), findsOneWidget);

      // Confirm acceptance
      await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
      await tester.pumpAndSettle();

      expect(mockTransportProvider.acceptJobCalled, isTrue);
      expect(find.text('Job for Maize accepted successfully! 🚛'), findsOneWidget);
    });
  });

  group('ActiveDeliveriesScreen & DeliveryDetailsScreen Tests', () {
    final activeTrip = Trip(
      id: 'trip-active-001',
      transportRequestId: 'req-1',
      farmerId: 'farmer_001',
      transporterId: 'transporter_001',
      vehicleId: 'VH-001',
      routeId: 'route_001',
      cropType: CropType.teff,
      quantityKg: 1500,
      pickupLocation: 'Debre Markos',
      deliveryLocation: 'Addis Ababa Grain Market',
      totalCost: 3500,
      createdAt: DateTime.now(),
      status: TripStatus.inTransit,
      scheduledPickupTime: DateTime.now(),
    );

    final completedTrip = Trip(
      id: 'trip-done-001',
      transportRequestId: 'req-2',
      farmerId: 'farmer_001',
      transporterId: 'transporter_001',
      vehicleId: 'VH-001',
      routeId: 'route_002',
      cropType: CropType.wheat,
      quantityKg: 2000,
      pickupLocation: 'Arsi Asella',
      deliveryLocation: 'Bishoftu Mill',
      totalCost: 4000,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      actualDeliveryTime: DateTime.now().subtract(const Duration(days: 1)),
      status: TripStatus.delivered,
    );

    testWidgets('ActiveDeliveriesScreen should render tabs and switch between Active and Completed', (tester) async {
      mockTransportProvider.setMockTrips([activeTrip, completedTrip]);

      await tester.pumpWidget(buildTestableWidget(const ActiveDeliveriesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('My Deliveries'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Active tab shows active trip
      expect(find.text('Debre Markos'), findsOneWidget);
      expect(find.text('Addis Ababa Grain Market'), findsOneWidget);

      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Arsi Asella'), findsOneWidget);
      expect(find.text('Bishoftu Mill'), findsOneWidget);
    });

    testWidgets('DeliveryDetailsScreen should display trip information and Complete Delivery button for inTransit', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DeliveryDetailsScreen(delivery: activeTrip),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delivery Details'), findsOneWidget);
      expect(find.text('Delivery #trip-act'), findsOneWidget); // 8 chars substring
      expect(find.text('Debre Markos'), findsOneWidget);
      expect(find.text('Addis Ababa Grain Market'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Complete Delivery'), findsOneWidget);
    });

    testWidgets('tapping Complete Delivery on DeliveryDetailsScreen should open ProofOfDeliveryScreen', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DeliveryDetailsScreen(delivery: activeTrip),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.pumpAndSettle();

      expect(find.byType(ProofOfDeliveryScreen), findsOneWidget);
      expect(find.text('Proof of Delivery'), findsOneWidget);
    });
  });

  group('ProofOfDeliveryScreen Validation & Submission Tests', () {
    final delivery = Trip(
      id: 'trip-pod-999',
      transportRequestId: 'req-pod',
      farmerId: 'farmer_001',
      transporterId: 'transporter_001',
      vehicleId: 'VH-001',
      routeId: 'route_001',
      cropType: CropType.coffee,
      quantityKg: 600,
      pickupLocation: 'Kaffa Forest',
      deliveryLocation: 'Bole Terminal Station',
      totalCost: 1800,
      createdAt: DateTime.now(),
      status: TripStatus.inTransit,
    );

    testWidgets('should render destination and all form components', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Proof of Delivery'), findsOneWidget);
      expect(find.text('Complete Delivery'), findsWidgets);
      expect(find.text('Bole Terminal Station'), findsOneWidget);
      expect(find.text('Recipient Name *'), findsOneWidget);
      expect(find.text('Delivery Photo *'), findsOneWidget);
      expect(find.text('Receiver Signature *'), findsOneWidget);
      expect(find.text('Delivery Notes (Optional)'), findsOneWidget);
    });

    testWidgets('should validate recipient name is required', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Attempt to submit without entering recipient name
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.tap(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter recipient name'), findsOneWidget);
      expect(mockTransportRepository.captureProofOfDeliveryCalled, isFalse);
    });

    testWidgets('should validate delivery photo is required after recipient name is entered', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter recipient name
      await tester.enterText(find.byType(TextField).first, 'John Recipient');
      await tester.pumpAndSettle();

      // Submit without capturing photo
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.tap(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.pumpAndSettle();

      expect(find.text('Please capture a delivery photo'), findsOneWidget);
      expect(mockTransportRepository.captureProofOfDeliveryCalled, isFalse);
    });

    testWidgets('tapping photo capture should invoke capturePhoto and display captured image', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on photo capture area
      await tester.tap(find.text('Tap to capture photo'));
      await tester.pumpAndSettle();

      expect(mockTransportRepository.capturePhotoCalled, isTrue);
      expect(find.text('Photo captured successfully'), findsOneWidget);
    });

    testWidgets('should validate receiver signature is required after photo is captured', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter recipient name
      await tester.enterText(find.byType(TextField).first, 'John Recipient');
      // Capture photo
      await tester.tap(find.text('Tap to capture photo'));
      await tester.pumpAndSettle();

      // Dismiss any active SnackBar so button is unobstructed
      ScaffoldMessenger.of(tester.element(find.byType(ProofOfDeliveryScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Attempt to submit without signature
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.tap(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.pumpAndSettle();

      expect(find.text('Please capture receiver signature'), findsOneWidget);
      expect(mockTransportRepository.captureProofOfDeliveryCalled, isFalse);
    });

    testWidgets('should complete delivery successfully when all required fields and evidence are captured', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          ProofOfDeliveryScreen(
            delivery: delivery,
            repository: mockTransportRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Enter recipient name
      await tester.enterText(find.byType(TextField).first, 'Mulugeta Tadesse');
      await tester.pumpAndSettle();

      // 2. Capture photo
      await tester.tap(find.text('Tap to capture photo'));
      await tester.pumpAndSettle();

      // Clear photo SnackBar before signature
      ScaffoldMessenger.of(tester.element(find.byType(ProofOfDeliveryScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // 3. Capture signature via SignaturePadWidget callback
      final signaturePadFinder = find.byType(SignaturePadWidget);
      expect(signaturePadFinder, findsOneWidget);
      final SignaturePadWidget signaturePad = tester.widget(signaturePadFinder);
      signaturePad.onSignatureCaptured(
        SignatureData(
          imageBytes: _kTransparentPngBytes,
          capturedAt: DateTime.now(),
        ),
      );
      await tester.pump();

      expect(find.text('Signature captured successfully'), findsOneWidget);

      // Dismiss SnackBar before tapping Complete Delivery
      ScaffoldMessenger.of(tester.element(find.byType(ProofOfDeliveryScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // 4. Submit Proof of Delivery
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.tap(find.widgetWithText(FilledButton, 'Complete Delivery'));
      await tester.pumpAndSettle();

      // Verify repository and provider calls
      expect(mockTransportRepository.captureProofOfDeliveryCalled, isTrue);
      expect(mockTransportProvider.markDeliveredCalled, isTrue);
      expect(mockTransportProvider.lastDeliveredTripId, equals('trip-pod-999'));

      // Verify success dialog
      expect(find.text('Delivery Completed!'), findsOneWidget);
      expect(find.text('POD ID: pod-test'), findsOneWidget);
    });
  });

  group('EarningsScreen Widget Tests', () {
    testWidgets('should render Earnings screen with zero trips and not crash with NaN chart', (tester) async {
      mockTransportProvider.setMockTrips([]);

      await tester.pumpWidget(buildTestableWidget(const EarningsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Earnings'), findsWidgets);
      expect(find.text('0 ETB'), findsWidgets);
      expect(find.text('Request Payout'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Transaction History'), findsOneWidget);
    });

    testWidgets('should calculate and display earnings from completed trips', (tester) async {
      final completedTrip = Trip(
        id: 'TR-EARN-01',
        transportRequestId: 'req-earn-1',
        farmerId: 'farmer_001',
        transporterId: 'transporter_001',
        vehicleId: 'VH-001',
        routeId: 'route_001',
        cropType: CropType.coffee,
        quantityKg: 1000,
        pickupLocation: 'Farm A',
        deliveryLocation: 'Depot B',
        totalCost: 5000,
        createdAt: DateTime.now(),
        actualDeliveryTime: DateTime.now(),
        status: TripStatus.delivered,
      );

      mockTransportProvider.setMockTrips([completedTrip]);

      await tester.pumpWidget(buildTestableWidget(const EarningsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('5000 ETB'), findsWidgets);
      expect(find.text('+5000 ETB'), findsOneWidget);
      expect(find.text('Delivery #TR-EARN-'), findsOneWidget);
    });
  });
}
