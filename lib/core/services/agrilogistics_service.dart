import '../models/transporter_model.dart';
import '../models/vehicle_model.dart';
import '../models/route_model.dart';
import '../models/transport_request_model.dart';
import '../models/trip_model.dart';
import '../models/crop_plot_model.dart';

/// AgriLogistics Service
/// Module 4: Transporter directory, vehicle capacity, route transparency,
/// multi-step booking flow management
class AgriLogisticsService {
  AgriLogisticsService._();

  // ============================================================================
  // MOCK TRANSPORTERS - 8+ transporters with ratings and standard routes
  // ============================================================================

  static final List<Transporter> _mockTransporters = [
    // Top-rated transporters
    Transporter(
      id: 'trans-001',
      name: 'Mohammed Ali',
      phoneNumber: '+251911111111',
      businessName: 'Jimma Express Transport',
      baseLocation: 'Jimma Town',
      isVerified: true,
      rating: 4.8,
      totalTrips: 156,
      completedTrips: 152,
      standardRoutes: ['Jimma-Nekemte', 'Jimma-Agaro', 'Jimma-Addis Ababa'],
      registeredAt: DateTime(2022, 6, 10),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-12345',
    ),
    Transporter(
      id: 'trans-002',
      name: 'Almaz Tesfaye',
      phoneNumber: '+251922222222',
      businessName: 'Oromia Cargo Services',
      baseLocation: 'Jimma Town',
      isVerified: true,
      rating: 4.6,
      totalTrips: 203,
      completedTrips: 196,
      standardRoutes: ['Jimma-Nekemte', 'Jimma-Agaro', 'Nekemte-Agaro'],
      registeredAt: DateTime(2022, 3, 15),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-23456',
    ),
    
    // Medium-rated transporters
    Transporter(
      id: 'trans-003',
      name: 'Bekele Worku',
      phoneNumber: '+251933333333',
      businessName: 'Bekele Transport & Logistics',
      baseLocation: 'Nekemte',
      isVerified: true,
      rating: 4.3,
      totalTrips: 89,
      completedTrips: 84,
      standardRoutes: ['Nekemte-Jimma', 'Nekemte-Agaro'],
      registeredAt: DateTime(2023, 1, 20),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 12)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-34567',
    ),
    Transporter(
      id: 'trans-004',
      name: 'Fatuma Hussein',
      phoneNumber: '+251944444444',
      businessName: 'Highland Freight',
      baseLocation: 'Agaro',
      isVerified: true,
      rating: 4.5,
      totalTrips: 124,
      completedTrips: 119,
      standardRoutes: ['Agaro-Jimma', 'Agaro-Nekemte'],
      registeredAt: DateTime(2022, 9, 5),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 1)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-45678',
    ),
    
    // New/emerging transporters
    Transporter(
      id: 'trans-005',
      name: 'Dawit Kebede',
      phoneNumber: '+251955555555',
      businessName: 'Swift Cargo Solutions',
      baseLocation: 'Jimma Town',
      isVerified: true,
      rating: 4.2,
      totalTrips: 47,
      completedTrips: 45,
      standardRoutes: ['Jimma-Nekemte', 'Jimma-Agaro'],
      registeredAt: DateTime(2024, 2, 10),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 8)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-56789',
    ),
    Transporter(
      id: 'trans-006',
      name: 'Sara Mulugeta',
      phoneNumber: '+251966666666',
      businessName: 'Agaro Transport Co.',
      baseLocation: 'Agaro',
      isVerified: false,
      rating: 3.9,
      totalTrips: 32,
      completedTrips: 30,
      standardRoutes: ['Agaro-Jimma'],
      registeredAt: DateTime(2024, 4, 15),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 2)),
      isAvailable: true,
    ),
    Transporter(
      id: 'trans-007',
      name: 'Yohannes Tadesse',
      phoneNumber: '+251977777777',
      businessName: 'Nekemte Logistics',
      baseLocation: 'Nekemte',
      isVerified: true,
      rating: 4.4,
      totalTrips: 76,
      completedTrips: 73,
      standardRoutes: ['Nekemte-Jimma', 'Nekemte-Agaro'],
      registeredAt: DateTime(2023, 6, 1),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 18)),
      isAvailable: false, // Currently unavailable
      licenseNumber: 'ETH-TL-67890',
    ),
    Transporter(
      id: 'trans-008',
      name: 'Tigist Abebe',
      phoneNumber: '+251988888888',
      businessName: 'Reliable Transport Services',
      baseLocation: 'Jimma Town',
      isVerified: true,
      rating: 4.7,
      totalTrips: 138,
      completedTrips: 134,
      standardRoutes: ['Jimma-Nekemte', 'Jimma-Agaro', 'Jimma-Addis Ababa'],
      registeredAt: DateTime(2022, 11, 20),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 3)),
      isAvailable: true,
      licenseNumber: 'ETH-TL-78901',
    ),
  ];

  // ============================================================================
  // MOCK VEHICLES - 12+ vehicles with different types and capacities
  // ============================================================================

  static final List<Vehicle> _mockVehicles = [
    // Transporter 001's vehicles
    Vehicle(
      id: 'vehicle-001',
      transporterId: 'trans-001',
      vehicleType: VehicleType.truck,
      plateNumber: 'ET-3-12345',
      capacityQuintals: 150,
      model: 'Isuzu FVR',
      yearManufactured: 2019,
      isActive: true,
      condition: VehicleCondition.excellent,
      registeredAt: DateTime(2022, 6, 10),
      lastMaintenanceDate: DateTime(2024, 8, 15),
    ),
    Vehicle(
      id: 'vehicle-002',
      transporterId: 'trans-001',
      vehicleType: VehicleType.pickup,
      plateNumber: 'ET-3-23456',
      capacityQuintals: 25,
      model: 'Toyota Hilux',
      yearManufactured: 2020,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2022, 8, 20),
      lastMaintenanceDate: DateTime(2024, 9, 1),
    ),
    
    // Transporter 002's vehicles
    Vehicle(
      id: 'vehicle-003',
      transporterId: 'trans-002',
      vehicleType: VehicleType.truck,
      plateNumber: 'ET-3-34567',
      capacityQuintals: 180,
      model: 'Hino 700 Series',
      yearManufactured: 2018,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2022, 3, 15),
      lastMaintenanceDate: DateTime(2024, 7, 10),
    ),
    Vehicle(
      id: 'vehicle-004',
      transporterId: 'trans-002',
      vehicleType: VehicleType.miniTruck,
      plateNumber: 'ET-3-45678',
      capacityQuintals: 50,
      model: 'Isuzu NQR',
      yearManufactured: 2021,
      isActive: true,
      condition: VehicleCondition.excellent,
      registeredAt: DateTime(2023, 1, 5),
      lastMaintenanceDate: DateTime(2024, 9, 20),
    ),
    
    // Transporter 003's vehicles
    Vehicle(
      id: 'vehicle-005',
      transporterId: 'trans-003',
      vehicleType: VehicleType.lorry,
      plateNumber: 'ET-5-56789',
      capacityQuintals: 85,
      model: 'Mercedes-Benz Actros',
      yearManufactured: 2017,
      isActive: true,
      condition: VehicleCondition.fair,
      registeredAt: DateTime(2023, 1, 20),
      lastMaintenanceDate: DateTime(2024, 5, 15),
    ),
    
    // Transporter 004's vehicles
    Vehicle(
      id: 'vehicle-006',
      transporterId: 'trans-004',
      vehicleType: VehicleType.miniTruck,
      plateNumber: 'ET-4-67890',
      capacityQuintals: 45,
      model: 'Isuzu ELF',
      yearManufactured: 2020,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2022, 9, 5),
      lastMaintenanceDate: DateTime(2024, 8, 25),
    ),
    Vehicle(
      id: 'vehicle-007',
      transporterId: 'trans-004',
      vehicleType: VehicleType.pickup,
      plateNumber: 'ET-4-78901',
      capacityQuintals: 20,
      model: 'Nissan Navara',
      yearManufactured: 2019,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2023, 2, 10),
      lastMaintenanceDate: DateTime(2024, 9, 5),
    ),
    
    // Transporter 005's vehicles
    Vehicle(
      id: 'vehicle-008',
      transporterId: 'trans-005',
      vehicleType: VehicleType.truck,
      plateNumber: 'ET-3-89012',
      capacityQuintals: 120,
      model: 'Volvo FH',
      yearManufactured: 2022,
      isActive: true,
      condition: VehicleCondition.excellent,
      registeredAt: DateTime(2024, 2, 10),
      lastMaintenanceDate: DateTime(2024, 9, 15),
    ),
    
    // Transporter 006's vehicles
    Vehicle(
      id: 'vehicle-009',
      transporterId: 'trans-006',
      vehicleType: VehicleType.pickup,
      plateNumber: 'ET-4-90123',
      capacityQuintals: 18,
      model: 'Toyota Hilux',
      yearManufactured: 2016,
      isActive: true,
      condition: VehicleCondition.fair,
      registeredAt: DateTime(2024, 4, 15),
      lastMaintenanceDate: DateTime(2024, 6, 20),
    ),
    
    // Transporter 007's vehicles
    Vehicle(
      id: 'vehicle-010',
      transporterId: 'trans-007',
      vehicleType: VehicleType.lorry,
      plateNumber: 'ET-5-01234',
      capacityQuintals: 95,
      model: 'Scania R Series',
      yearManufactured: 2019,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2023, 6, 1),
      lastMaintenanceDate: DateTime(2024, 8, 10),
    ),
    
    // Transporter 008's vehicles
    Vehicle(
      id: 'vehicle-011',
      transporterId: 'trans-008',
      vehicleType: VehicleType.truck,
      plateNumber: 'ET-3-12346',
      capacityQuintals: 160,
      model: 'Isuzu Giga',
      yearManufactured: 2020,
      isActive: true,
      condition: VehicleCondition.excellent,
      registeredAt: DateTime(2022, 11, 20),
      lastMaintenanceDate: DateTime(2024, 9, 10),
    ),
    Vehicle(
      id: 'vehicle-012',
      transporterId: 'trans-008',
      vehicleType: VehicleType.miniTruck,
      plateNumber: 'ET-3-23457',
      capacityQuintals: 55,
      model: 'Mitsubishi Canter',
      yearManufactured: 2021,
      isActive: true,
      condition: VehicleCondition.good,
      registeredAt: DateTime(2023, 3, 15),
      lastMaintenanceDate: DateTime(2024, 9, 18),
    ),
  ];

  // ============================================================================
  // MOCK ROUTES - Standard routes with checkpoint fee transparency
  // ============================================================================

  static final List<Route> _mockRoutes = [
    // Jimma-Nekemte route
    Route(
      id: 'route-001',
      origin: 'Jimma Town',
      destination: 'Nekemte',
      distanceKm: 150,
      baseCostPerKm: 10.0,
      costPerTonKm: 5.0,
      checkpoints: [
        Checkpoint(
          name: 'Jimma Checkpoint',
          distanceFromOriginKm: 5,
          fee: 150,
          type: CheckpointType.inspection,
          description: 'Agricultural produce inspection',
        ),
        Checkpoint(
          name: 'Bedele Weighbridge',
          distanceFromOriginKm: 85,
          fee: 200,
          type: CheckpointType.weighbridge,
          description: 'Vehicle weight verification',
        ),
        Checkpoint(
          name: 'Nekemte Entry',
          distanceFromOriginKm: 148,
          fee: 100,
          type: CheckpointType.inspection,
          description: 'Entry point inspection',
        ),
      ],
      estimatedDurationHours: 4.5,
      condition: RouteCondition.good,
      lastUpdated: DateTime(2024, 9, 1),
    ),
    
    // Jimma-Agaro route
    Route(
      id: 'route-002',
      origin: 'Jimma Town',
      destination: 'Agaro',
      distanceKm: 55,
      baseCostPerKm: 10.0,
      costPerTonKm: 5.0,
      checkpoints: [
        Checkpoint(
          name: 'Jimma Checkpoint',
          distanceFromOriginKm: 5,
          fee: 150,
          type: CheckpointType.inspection,
          description: 'Agricultural produce inspection',
        ),
        Checkpoint(
          name: 'Agaro Entry',
          distanceFromOriginKm: 53,
          fee: 100,
          type: CheckpointType.inspection,
          description: 'Market entry inspection',
        ),
      ],
      estimatedDurationHours: 1.5,
      condition: RouteCondition.excellent,
      lastUpdated: DateTime(2024, 9, 15),
    ),
    
    // Nekemte-Jimma route (reverse)
    Route(
      id: 'route-003',
      origin: 'Nekemte',
      destination: 'Jimma Town',
      distanceKm: 150,
      baseCostPerKm: 10.0,
      costPerTonKm: 5.0,
      checkpoints: [
        Checkpoint(
          name: 'Nekemte Exit',
          distanceFromOriginKm: 2,
          fee: 100,
          type: CheckpointType.inspection,
        ),
        Checkpoint(
          name: 'Bedele Weighbridge',
          distanceFromOriginKm: 65,
          fee: 200,
          type: CheckpointType.weighbridge,
        ),
        Checkpoint(
          name: 'Jimma Entry',
          distanceFromOriginKm: 145,
          fee: 150,
          type: CheckpointType.inspection,
        ),
      ],
      estimatedDurationHours: 4.5,
      condition: RouteCondition.good,
      lastUpdated: DateTime(2024, 9, 1),
    ),
    
    // Agaro-Jimma route (reverse)
    Route(
      id: 'route-004',
      origin: 'Agaro',
      destination: 'Jimma Town',
      distanceKm: 55,
      baseCostPerKm: 10.0,
      costPerTonKm: 5.0,
      checkpoints: [
        Checkpoint(
          name: 'Agaro Exit',
          distanceFromOriginKm: 2,
          fee: 100,
          type: CheckpointType.inspection,
        ),
        Checkpoint(
          name: 'Jimma Entry',
          distanceFromOriginKm: 50,
          fee: 150,
          type: CheckpointType.inspection,
        ),
      ],
      estimatedDurationHours: 1.5,
      condition: RouteCondition.excellent,
      lastUpdated: DateTime(2024, 9, 15),
    ),
    
    // Nekemte-Agaro route
    Route(
      id: 'route-005',
      origin: 'Nekemte',
      destination: 'Agaro',
      distanceKm: 95,
      baseCostPerKm: 10.0,
      costPerTonKm: 5.0,
      checkpoints: [
        Checkpoint(
          name: 'Nekemte Exit',
          distanceFromOriginKm: 2,
          fee: 100,
          type: CheckpointType.inspection,
        ),
        Checkpoint(
          name: 'Agaro Entry',
          distanceFromOriginKm: 93,
          fee: 100,
          type: CheckpointType.inspection,
        ),
      ],
      estimatedDurationHours: 2.5,
      condition: RouteCondition.fair,
      lastUpdated: DateTime(2024, 8, 20),
    ),
  ];

  // Mock trip storage
  static final List<Trip> _mockTrips = [];

  // ============================================================================
  // PUBLIC API - Transporter Directory
  // ============================================================================

  /// Get all transporters
  static List<Transporter> getAllTransporters() {
    return List.from(_mockTransporters);
  }

  /// Get available transporters only
  static List<Transporter> getAvailableTransporters() {
    return _mockTransporters.where((t) => t.isAvailable).toList();
  }

  /// Get verified transporters
  static List<Transporter> getVerifiedTransporters() {
    return _mockTransporters.where((t) => t.isVerified).toList();
  }

  /// Get transporter by ID
  static Transporter? getTransporterById(String transporterId) {
    try {
      return _mockTransporters.firstWhere((t) => t.id == transporterId);
    } catch (e) {
      return null;
    }
  }

  /// Get vehicles for a transporter
  static List<Vehicle> getVehiclesByTransporter(String transporterId) {
    return _mockVehicles.where((v) => v.transporterId == transporterId).toList();
  }

  /// Get vehicle by ID
  static Vehicle? getVehicleById(String vehicleId) {
    try {
      return _mockVehicles.firstWhere((v) => v.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // PUBLIC API - Route Management
  // ============================================================================

  /// Get all routes
  static List<Route> getAllRoutes() {
    return List.from(_mockRoutes);
  }

  /// Find route between two locations
  static Route? findRoute(String origin, String destination) {
    try {
      return _mockRoutes.firstWhere(
        (r) =>
            r.origin.toLowerCase() == origin.toLowerCase() &&
            r.destination.toLowerCase() == destination.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get route by ID
  static Route? getRouteById(String routeId) {
    try {
      return _mockRoutes.firstWhere((r) => r.id == routeId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // FILTERING LOGIC
  // ============================================================================

  /// Filter transporters by location
  static List<Transporter> filterTransportersByLocation(String location) {
    return _mockTransporters
        .where((t) =>
            t.baseLocation.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }

  /// Filter transporters by route
  static List<Transporter> filterTransportersByRoute(String origin, String destination) {
    final routeQuery = '$origin-$destination';
    return _mockTransporters.where((t) {
      return t.operatesOnRoute(routeQuery);
    }).toList();
  }

  /// Filter transporters by minimum rating
  static List<Transporter> filterTransportersByRating(double minRating) {
    return _mockTransporters.where((t) => t.rating >= minRating).toList();
  }

  /// Filter vehicles by type
  static List<Vehicle> filterVehiclesByType(VehicleType type) {
    return _mockVehicles.where((v) => v.vehicleType == type).toList();
  }

  /// Filter vehicles by minimum capacity
  static List<Vehicle> filterVehiclesByCapacity(double minQuintals) {
    return _mockVehicles
        .where((v) => v.capacityQuintals >= minQuintals && v.isActive)
        .toList();
  }

  /// Find suitable transporters for a request
  static List<Transporter> findSuitableTransporters({
    required String origin,
    required String destination,
    required double quantityKg,
    double? minRating,
    bool? verifiedOnly,
  }) {
    var transporters = _mockTransporters.where((t) => t.isAvailable).toList();

    // Filter by route
    final routeQuery = '$origin-$destination';
    transporters = transporters.where((t) => t.operatesOnRoute(routeQuery)).toList();

    // Filter by rating
    if (minRating != null) {
      transporters = transporters.where((t) => t.rating >= minRating).toList();
    }

    // Filter by verification
    if (verifiedOnly == true) {
      transporters = transporters.where((t) => t.isVerified).toList();
    }

    // Check if they have vehicles with sufficient capacity
    final requiredQuintals = quantityKg / 100.0;
    transporters = transporters.where((t) {
      final vehicles = getVehiclesByTransporter(t.id);
      return vehicles.any((v) => v.capacityQuintals >= requiredQuintals && v.isActive);
    }).toList();

    // Sort by rating (highest first)
    transporters.sort((a, b) => b.rating.compareTo(a.rating));

    return transporters;
  }

  // ============================================================================
  // BOOKING FLOW MANAGEMENT
  // ============================================================================

  /// Create a transport request
  static TransportRequest createTransportRequest({
    required String farmerId,
    required CropType cropType,
    required double quantityKg,
    required String pickupLocation,
    required String deliveryLocation,
    required DateTime requestedPickupDate,
    String? specialInstructions,
    bool requiresRefrigeration = false,
  }) {
    final request = TransportRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: farmerId,
      cropType: cropType,
      quantityKg: quantityKg,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      requestedPickupDate: requestedPickupDate,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      specialInstructions: specialInstructions,
      requiresRefrigeration: requiresRefrigeration,
    );
    return request;
  }

  /// Match request with transporter (simulate booking)
  static Trip? matchTransportRequest({
    required TransportRequest request,
    required String transporterId,
    required String vehicleId,
  }) {
    final transporter = getTransporterById(transporterId);
    final vehicle = getVehicleById(vehicleId);
    
    if (transporter == null || vehicle == null) return null;
    if (!transporter.isAvailable || !vehicle.isActive) return null;

    // Find route
    final route = findRoute(request.pickupLocation, request.deliveryLocation);
    if (route == null) return null;

    // Calculate cost
    final totalCost = route.calculateTotalCost(request.quantityTons);

    // Create trip
    final trip = Trip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      transportRequestId: request.id,
      farmerId: request.farmerId,
      transporterId: transporterId,
      vehicleId: vehicleId,
      routeId: route.id,
      cropType: request.cropType,
      quantityKg: request.quantityKg,
      pickupLocation: request.pickupLocation,
      deliveryLocation: request.deliveryLocation,
      totalCost: totalCost,
      status: TripStatus.matched,
      createdAt: DateTime.now(),
      scheduledPickupTime: request.requestedPickupDate,
      estimatedArrivalTime: route.getEstimatedArrival(request.requestedPickupDate),
      statusUpdates: [
        TripStatusUpdate(
          status: TripStatus.matched,
          timestamp: DateTime.now(),
          note: 'Trip matched with ${transporter.businessName}',
          location: request.pickupLocation,
        ),
      ],
    );

    _mockTrips.add(trip);
    return trip;
  }

  /// Update trip status (simulate state transitions)
  static Trip? updateTripStatus(String tripId, TripStatus newStatus) {
    try {
      final tripIndex = _mockTrips.indexWhere((t) => t.id == tripId);
      if (tripIndex == -1) return null;

      final trip = _mockTrips[tripIndex];
      final now = DateTime.now();

      Trip updatedTrip;
      switch (newStatus) {
        case TripStatus.pickedUp:
          updatedTrip = trip.copyWith(
            status: TripStatus.pickedUp,
            actualPickupTime: now,
            statusUpdates: [
              ...?trip.statusUpdates,
              TripStatusUpdate(
                status: TripStatus.pickedUp,
                timestamp: now,
                note: 'Cargo picked up',
                location: trip.pickupLocation,
              ),
            ],
          );
          break;
        case TripStatus.inTransit:
          updatedTrip = trip.copyWith(
            status: TripStatus.inTransit,
            statusUpdates: [
              ...?trip.statusUpdates,
              TripStatusUpdate(
                status: TripStatus.inTransit,
                timestamp: now,
                note: 'In transit to destination',
              ),
            ],
          );
          break;
        case TripStatus.delivered:
          updatedTrip = trip.copyWith(
            status: TripStatus.delivered,
            actualDeliveryTime: now,
            statusUpdates: [
              ...?trip.statusUpdates,
              TripStatusUpdate(
                status: TripStatus.delivered,
                timestamp: now,
                note: 'Cargo delivered successfully',
                location: trip.deliveryLocation,
              ),
            ],
          );
          break;
        case TripStatus.cancelled:
          updatedTrip = trip.copyWith(
            status: TripStatus.cancelled,
            statusUpdates: [
              ...?trip.statusUpdates,
              TripStatusUpdate(
                status: TripStatus.cancelled,
                timestamp: now,
                note: 'Trip cancelled',
              ),
            ],
          );
          break;
        default:
          return trip;
      }

      _mockTrips[tripIndex] = updatedTrip;
      return updatedTrip;
    } catch (e) {
      return null;
    }
  }

  /// Get all trips
  static List<Trip> getAllTrips() {
    return List.from(_mockTrips)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get trips by farmer ID
  static List<Trip> getTripsByFarmer(String farmerId) {
    return _mockTrips.where((t) => t.farmerId == farmerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get active trips (not delivered or cancelled)
  static List<Trip> getActiveTrips() {
    return _mockTrips.where((t) => t.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get logistics statistics
  static Map<String, dynamic> getLogisticsStats() {
    final allVehicles = _mockVehicles;
    final availableTransporters = getAvailableTransporters();
    final activeTrips = getActiveTrips();

    return {
      'totalTransporters': _mockTransporters.length,
      'availableTransporters': availableTransporters.length,
      'verifiedTransporters': getVerifiedTransporters().length,
      'totalVehicles': allVehicles.length,
      'activeVehicles': allVehicles.where((v) => v.isActive).length,
      'totalRoutes': _mockRoutes.length,
      'totalTrips': _mockTrips.length,
      'activeTrips': activeTrips.length,
      'completedTrips': _mockTrips.where((t) => t.isCompleted).length,
      'averageTransporterRating':
          _mockTransporters.fold(0.0, (sum, t) => sum + t.rating) /
              _mockTransporters.length,
      'totalCapacityQuintals':
          allVehicles.fold(0.0, (sum, v) => sum + v.capacityQuintals),
    };
  }
}
