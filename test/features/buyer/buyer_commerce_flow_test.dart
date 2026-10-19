import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/routes/app_routes.dart';
import 'package:agrolink/models/produce_model.dart';
import 'package:agrolink/models/order_model.dart';
import 'package:agrolink/core/models/farmer_model.dart';
import 'package:agrolink/core/models/cart_item.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/core/providers/produce_provider.dart';
import 'package:agrolink/core/providers/cart_provider.dart';
import 'package:agrolink/core/providers/buyer_provider.dart';
import 'package:agrolink/core/providers/favorites_provider.dart';
import 'package:agrolink/features/buyer/dialogs/contact_farmer_dialog.dart';
import 'package:agrolink/features/buyer/screens/produce_details_screen.dart';
import 'package:agrolink/features/buyer/screens/order_details_screen.dart';
import 'package:agrolink/features/buyer/screens/farmer_profile_view_screen.dart';
import 'package:agrolink/features/buyer/tabs/browse_tab.dart';
import 'package:agrolink/screens/buyer/payment_screen.dart';
import 'package:agrolink/models/user_model.dart';

/// Mock AuthProvider for Buyer Commerce Testing
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _testUser;

  void setTestUser(UserModel user) {
    _testUser = user;
    notifyListeners();
  }

  @override
  UserModel? get user => _testUser;

  @override
  String? get userId => _testUser?.id ?? 'buyer_001';

  @override
  bool get isAuthenticated => _testUser != null;

  @override
  bool get isBuyer => true;

  @override
  bool get isFarmer => false;

  @override
  bool get isTransporter => false;

  @override
  bool get isBureauOfficer => false;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  bool get isInitialized => true;

  @override
  List<String> get availableRoles => ['buyer'];

  @override
  String? get currentRole => 'buyer';

  @override
  bool get hasMultipleRoles => false;

  @override
  String? get userRole => 'buyer';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock ProduceProvider for Buyer Commerce Testing
class MockProduceProvider extends ChangeNotifier implements ProduceProvider {
  List<ProduceModel> _items = [];
  bool _mockLoading = false;
  Map<String, dynamic>? _lastFiltersApplied;

  void setTestProduce(List<ProduceModel> items) {
    _items = items;
    notifyListeners();
  }

  @override
  List<ProduceModel> get allProduce => _items;

  @override
  List<ProduceModel> get filteredProduce => _items;

  @override
  bool get isLoading => _mockLoading;

  @override
  String? get error => null;

  @override
  String get searchQuery => '';

  @override
  Map<String, dynamic>? get activeFilters => _lastFiltersApplied;

  @override
  bool get hasError => false;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  Future<void> loadAllProduce() async {
    notifyListeners();
  }

  @override
  Future<void> loadAvailableProduce() async {
    notifyListeners();
  }

  @override
  void searchProduce(String query) {
    notifyListeners();
  }

  @override
  void filterProduce({
    String? cropType,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? qualityGrade,
    bool? isOrganic,
    String? status,
  }) {
    _lastFiltersApplied = {
      if (cropType != null) 'cropType': cropType,
      if (location != null) 'location': location,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (qualityGrade != null) 'qualityGrade': qualityGrade,
      if (isOrganic != null) 'isOrganic': isOrganic,
      if (status != null) 'status': status,
    };
    notifyListeners();
  }

  @override
  void clearFilters() {
    _lastFiltersApplied = null;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock CartProvider for Buyer Commerce Testing
class MockCartProvider extends ChangeNotifier implements CartProvider {
  final List<CartItem> _items = [];

  @override
  List<CartItem> get items => _items;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  int get itemCount => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  double get totalQuantity => 0;

  @override
  double get subtotal => 0;

  @override
  double get deliveryFee => 0;

  @override
  double get tax => 0;

  @override
  double get total => 0;

  @override
  Map<String, List<CartItem>> get itemsByFarmer => {};

  @override
  Set<String> get farmerNames => {};

  @override
  Future<bool> addItem(ProduceModel produce, double quantity) async {
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock BuyerProvider for Buyer Commerce Testing
class MockBuyerProvider extends ChangeNotifier implements BuyerProvider {
  Farmer? _mockFarmer;

  void setMockFarmer(Farmer? farmer) {
    _mockFarmer = farmer;
  }

  @override
  Future<Farmer?> getFarmerProfile(String farmerId) async {
    return _mockFarmer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock FavoritesProvider for Buyer Commerce Testing
class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  final Set<String> _favs = {};

  @override
  bool isFavorite(String produceId) => _favs.contains(produceId);

  @override
  Future<bool> toggleFavorite(String produceId) async {
    if (_favs.contains(produceId)) {
      _favs.remove(produceId);
    } else {
      _favs.add(produceId);
    }
    notifyListeners();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAuthProvider mockAuth;
  late MockProduceProvider mockProduce;
  late MockCartProvider mockCart;
  late MockBuyerProvider mockBuyer;
  late MockFavoritesProvider mockFavorites;

  final testProduce = ProduceModel(
    id: 'prod_teff_01',
    farmerId: 'farmer_abebe_01',
    farmerName: 'Abebe Bikila',
    cropName: 'White Teff',
    cropType: 'cereal',
    quantity: 50.0,
    unit: 'kg',
    pricePerUnit: 120.0,
    description: 'Fresh organic Grade 1 white teff harvest from Adaa.',
    status: 'available',
    location: 'Debre Zeit, Ethiopia',
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 2),
    imageUrls: [],
    qualityGrade: 'Grade 1',
    isOrganic: true,
  );

  final testOrder = OrderModel(
    id: 'order_789',
    produceId: 'prod_teff_01',
    produceName: 'White Teff',
    buyerId: 'buyer_001',
    buyerName: 'Almaz Ayana',
    farmerId: 'farmer_abebe_01',
    farmerName: 'Abebe Bikila',
    quantityOrdered: 20.0,
    unit: 'kg',
    pricePerUnit: 120.0,
    totalPrice: 2400.0,
    status: 'confirmed',
    pickupLocation: 'Debre Zeit, Ethiopia',
    deliveryLocation: 'Bole, Addis Ababa, Ethiopia',
    paymentMethod: 'telebirr',
    paymentStatus: 'pending',
    createdAt: DateTime(2026, 10, 10),
  );

  final testFarmer = Farmer(
    id: 'farmer_abebe_01',
    name: 'Abebe Bikila',
    phoneNumber: '+251911223344',
    woreda: 'Adaa',
    kebele: '01',
    cooperativeName: 'Adaa Agricultural Co-op',
    registeredAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuth = MockAuthProvider();
    mockProduce = MockProduceProvider();
    mockCart = MockCartProvider();
    mockBuyer = MockBuyerProvider();
    mockFavorites = MockFavoritesProvider();

    mockAuth.setTestUser(UserModel(
      id: 'buyer_001',
      fullName: 'Almaz Ayana',
      email: 'almaz@agrolink.et',
      phone: '+251922334455',
      password: 'hashedpassword',
      role: 'buyer',
      location: 'Addis Ababa',
      createdAt: DateTime.now(),
    ));

    mockBuyer.setMockFarmer(testFarmer);
    mockProduce.setTestProduce([testProduce]);
  });

  Widget buildTestApp({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
        ChangeNotifierProvider<ProduceProvider>.value(value: mockProduce),
        ChangeNotifierProvider<CartProvider>.value(value: mockCart),
        ChangeNotifierProvider<BuyerProvider>.value(value: mockBuyer),
        ChangeNotifierProvider<FavoritesProvider>.value(value: mockFavorites),
      ],
      child: MaterialApp(
        home: child,
        routes: AppRoutes.routes,
      ),
    );
  }

  group('Phase 4: AppRoutes Buyer Route Handlers Tests', () {
    testWidgets('AppRoutes.produceDetails route handles null arguments gracefully', (tester) async {
      final routes = AppRoutes.routes;
      final builder = routes[AppRoutes.produceDetails];
      expect(builder, isNotNull);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => builder!(context),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Produce not found'), findsOneWidget);
    });

    testWidgets('AppRoutes.orderDetails route handles null arguments gracefully', (tester) async {
      final routes = AppRoutes.routes;
      final builder = routes[AppRoutes.orderDetails];
      expect(builder, isNotNull);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => builder!(context),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Order not found'), findsOneWidget);
    });

    testWidgets('AppRoutes.farmerProfileView route builder returns FarmerProfileViewScreen', (tester) async {
      final routes = AppRoutes.routes;
      final builder = routes[AppRoutes.farmerProfileView];
      expect(builder, isNotNull);

      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => builder!(context),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FarmerProfileViewScreen), findsOneWidget);
    });
  });

  group('Phase 4: ContactFarmerDialog Widget Tests', () {
    testWidgets('renders farmer information and all contact methods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFarmerDialog(farmer: testFarmer),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and name
      expect(find.text('Contact Farmer'), findsOneWidget);
      expect(find.text('Abebe Bikila'), findsOneWidget);
      expect(find.text('+251911223344'), findsOneWidget);

      // Check contact options
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Send SMS'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Copy Number'), findsOneWidget);
    });

    testWidgets('tapping Copy Number copies phone number to clipboard and dismisses', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showContactFarmerDialog(context, farmer: testFarmer);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Contact Farmer'), findsOneWidget);

      // Tap Copy Number
      await tester.tap(find.text('Copy Number'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Contact Farmer'), findsNothing);
      expect(result, isTrue);
    });
  });

  group('Phase 4: ProduceDetailsScreen Widget Tests', () {
    testWidgets('displays produce information in ETB currency and opens contact dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: ProduceDetailsScreen(produce: testProduce),
      ));
      await tester.pumpAndSettle();

      // Title and Location
      expect(find.text('White Teff'), findsOneWidget);
      expect(find.textContaining('Debre Zeit'), findsWidgets);

      // Price formatted in ETB
      expect(find.textContaining('120.00 ETB'), findsOneWidget);

      // Farmer name
      expect(find.text('Abebe Bikila'), findsOneWidget);

      // Contact farmer action button is present as tooltip/icon button
      final contactButton = find.byTooltip('Contact Farmer');
      expect(contactButton, findsOneWidget);

      // Tap Contact Farmer button to open dialog
      await tester.tap(contactButton);
      await tester.pumpAndSettle();

      expect(find.byType(ContactFarmerDialog), findsOneWidget);
      expect(find.text('Abebe Bikila'), findsWidgets);
    });
  });

  group('Phase 4: OrderDetailsScreen Widget Tests', () {
    testWidgets('renders Pay Now button when order is confirmed and unpaid', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: OrderDetailsScreen(order: testOrder),
      ));
      await tester.pumpAndSettle();

      // Order info
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('White Teff'), findsOneWidget);
      expect(find.textContaining('2400.00 ETB'), findsWidgets);

      // Farmer contact button is present in order details
      expect(find.text('Contact Farmer'), findsOneWidget);

      // Pay Now button is visible because status is confirmed and paymentStatus is pending
      expect(find.text('Pay Now'), findsOneWidget);
    });
  });

  group('Phase 4: BrowseTab Produce Filter Bottom Sheet Tests', () {
    testWidgets('opens filter bottom sheet and allows configuring and applying filters', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: const BrowseTab(),
      ));
      await tester.pumpAndSettle();

      // Browse Tab header and filter button
      expect(find.text('Browse Produce'), findsOneWidget);
      final filterButton = find.text('Filter');
      expect(filterButton, findsOneWidget);

      // Tap filter button to open bottom sheet
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Filter bottom sheet components
      expect(find.text('Filter Produce'), findsOneWidget);
      expect(find.text('Crop Type'), findsOneWidget);
      expect(find.text('Max Price per Unit'), findsOneWidget);
      expect(find.text('Quality Grade'), findsOneWidget);
      expect(find.text('Organic Produce Only'), findsOneWidget);

      // Select Teff filter chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Teff'));
      await tester.pumpAndSettle();

      // Select Grade 1 chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Grade 1'));
      await tester.pumpAndSettle();

      // Toggle Organic Certified
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Tap Apply Filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // Bottom sheet dismissed and filter applied to ProduceProvider
      expect(find.text('Filter Produce'), findsNothing);
      expect(mockProduce.activeFilters, isNotNull);
      expect(mockProduce.activeFilters?['cropType'], 'teff');
      expect(mockProduce.activeFilters?['qualityGrade'], 'Grade 1');
      expect(mockProduce.activeFilters?['isOrganic'], isTrue);
    });
  });

  group('Phase 4: PaymentScreen Ethiopian Payment Methods Tests', () {
    testWidgets('renders ETB currency and allows switching Ethiopian payment methods', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: RouteSettings(
                name: AppRoutes.payment,
                arguments: testOrder,
              ),
              builder: (_) => const PaymentScreen(),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Check header and ETB amount
      expect(find.text('Make Payment'), findsOneWidget);
      expect(find.text('ETB 2,400'), findsOneWidget);

      // Check Ethiopian payment methods
      expect(find.text('Telebirr'), findsOneWidget);
      expect(find.text('CBE Birr'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);

      // Initially Telebirr is selected, showing phone input
      expect(find.text('Telebirr Number'), findsOneWidget);

      // Switch to CBE Birr
      await tester.tap(find.text('CBE Birr'));
      await tester.pumpAndSettle();
      expect(find.text('CBE Birr Number'), findsOneWidget);

      // Switch to Bank Transfer
      await tester.tap(find.text('Bank Transfer'));
      await tester.pumpAndSettle();
      expect(find.text('Bank Account Name'), findsOneWidget);
      expect(find.text('Account Number'), findsOneWidget);

      // Confirm Payment button is present
      expect(find.text('Confirm Payment'), findsOneWidget);
    });
  });
}
