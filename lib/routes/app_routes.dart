import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/farmer/farmer_main.dart';
import '../screens/farmer/add_produce_screen.dart';
import '../screens/farmer/my_produce_screen.dart';
import '../screens/farmer/order_requests_screen.dart';
import '../screens/farmer/logistics_status_screen.dart';
import '../features/farmer/screens/farmer_dashboard_screen.dart';
import '../features/farmer/screens/farmer_profile_screen.dart';
import '../features/farmer/screens/edit_farmer_profile_screen.dart';
import '../features/farmer/screens/add_farm_screen.dart';
import '../features/farmer/screens/create_transport_request_screen.dart';
import '../features/farmer/screens/transport_request_detail_screen.dart';
import '../features/market/screens/market_intelligence_screen.dart';
import '../screens/buyer/buyer_main.dart';
import '../screens/buyer/browse_produce_screen.dart';
import '../screens/buyer/my_orders_screen.dart';
import '../screens/buyer/payment_screen.dart';
import '../features/buyer/screens/buyer_dashboard_screen.dart';
import '../features/buyer/screens/checkout_screen.dart';
import '../features/buyer/screens/produce_details_screen.dart';
import '../features/buyer/screens/order_details_screen.dart';
import '../features/buyer/screens/farmer_profile_view_screen.dart';
import '../models/order_model.dart';
import '../models/produce_model.dart';
import '../screens/transporter/transporter_main.dart';
import '../screens/transporter/available_pickups_screen.dart';
import '../screens/transporter/my_deliveries_screen.dart';
import '../screens/shared/profile_screen.dart';
import '../core/navigation/navigation_shell.dart';
import '../features/bureau/screens/bureau_dashboard_screen.dart';
import '../features/bureau/screens/create_inspection_screen.dart';
import '../features/bureau/screens/inspection_list_screen.dart';
import '../features/bureau/screens/inspection_details_screen.dart';
import '../features/transporter/screens/transporter_dashboard_screen.dart';
import '../features/transporter/screens/available_jobs_screen.dart';
import '../features/transporter/screens/active_deliveries_screen.dart';
import '../features/transporter/screens/delivery_details_screen.dart';
import '../features/transporter/screens/proof_of_delivery_screen.dart';
import '../features/transporter/screens/earnings_screen.dart';
import '../core/models/trip_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String otpVerification = '/otp_verification';
  static const String home = '/home';
  
  static const String farmerDashboard = '/farmer_dashboard';
  static const String farmerDashboardNew = '/farmer_dashboard_new';
  static const String addProduce = '/add_produce';
  static const String myProduce = '/my_produce';
  static const String orderRequests = '/order_requests';
  static const String logisticsStatus = '/logistics_status';

  static const String buyerDashboard = '/buyer_dashboard';
  static const String browseProduce = '/browse_produce';
  static const String myOrders = '/my_orders';
  static const String payment = '/payment';

  static const String transporterDashboard = '/transporter_dashboard';
  static const String availablePickups = '/available_pickups';
  static const String myDeliveries = '/my_deliveries';

  static const String profile = '/profile';
  static const String marketIntelligence = '/market_intelligence';

  // Phase 2: Bureau Oversight & Inspection Routes
  static const String bureauDashboard = '/bureau_dashboard';
  static const String createInspection = '/create_inspection';
  static const String inspectionList = '/inspection_list';
  static const String inspectionDetails = '/inspection_details';

  // Phase 3: Transporter Operations & POD Routes
  static const String transporterDashboardNew = '/transporter_dashboard_new';
  static const String availableJobs = '/available_jobs';
  static const String activeDeliveries = '/active_deliveries';
  static const String deliveryDetails = '/delivery_details';
  static const String proofOfDelivery = '/proof_of_delivery';
  static const String earnings = '/earnings';

  // Phase 4: Buyer Commerce Routes
  static const String buyerDashboardNew = '/buyer_dashboard_new';
  static const String checkout = '/checkout';
  static const String produceDetails = '/produce_details';
  static const String orderDetails = '/order_details';
  static const String farmerProfileView = '/farmer_profile_view';

  static Map<String, WidgetBuilder> get routes => {
        // splash route removed - using home property in MaterialApp instead
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        home: (context) => const NavigationShell(),
        // Note: OTP verification uses arguments, so it's navigated directly
        
        farmerDashboard: (context) => const FarmerMainScreen(),
        farmerDashboardNew: (context) => const FarmerDashboardScreen(),
        addProduce: (context) => const AddProduceScreen(),
        myProduce: (context) => const MyProduceScreen(),
        orderRequests: (context) => const OrderRequestsScreen(),
        logisticsStatus: (context) => const LogisticsStatusScreen(),
        
        buyerDashboard: (context) => const BuyerMainScreen(),
        browseProduce: (context) => const BrowseProduceScreen(),
        myOrders: (context) => const MyOrdersScreen(),
        payment: (context) => const PaymentScreen(),
        
        transporterDashboard: (context) => const TransporterMainScreen(),
        availablePickups: (context) => const AvailablePickupsScreen(),
        myDeliveries: (context) => const MyDeliveriesScreen(),
        profile: (context) => const ProfileScreen(),
        marketIntelligence: (context) => const MarketIntelligenceScreen(),

        // Phase 2: Bureau Oversight & Inspection Routes
        bureauDashboard: (context) => const BureauDashboardScreen(),
        createInspection: (context) => const CreateInspectionScreen(),
        inspectionList: (context) => const InspectionListScreen(),
        inspectionDetails: (context) {
          final inspectionId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return InspectionDetailsScreen(inspectionId: inspectionId);
        },

        // Phase 3: Transporter Operations & POD Routes
        transporterDashboardNew: (context) => const TransporterDashboardScreen(),
        availableJobs: (context) => const AvailableJobsScreen(),
        activeDeliveries: (context) => const ActiveDeliveriesScreen(),
        deliveryDetails: (context) {
          final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
          if (trip == null) {
            return const Scaffold(body: Center(child: Text('Delivery not found')));
          }
          return DeliveryDetailsScreen(delivery: trip);
        },
        proofOfDelivery: (context) {
          final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
          if (trip == null) {
            return const Scaffold(body: Center(child: Text('Delivery not found')));
          }
          return ProofOfDeliveryScreen(delivery: trip);
        },
        earnings: (context) => const EarningsScreen(),
        
        // Phase 4: Buyer Commerce Routes
        buyerDashboardNew: (context) => const BuyerDashboardScreen(),
        checkout: (context) => const CheckoutScreen(),
        produceDetails: (context) {
          final produce = ModalRoute.of(context)?.settings.arguments as ProduceModel?;
          if (produce == null) {
            return const Scaffold(body: Center(child: Text('Produce not found')));
          }
          return ProduceDetailsScreen(produce: produce);
        },
        orderDetails: (context) {
          final order = ModalRoute.of(context)?.settings.arguments as OrderModel?;
          if (order == null) {
            return const Scaffold(body: Center(child: Text('Order not found')));
          }
          return OrderDetailsScreen(order: order);
        },
        farmerProfileView: (context) {
          final farmerId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return FarmerProfileViewScreen(farmerId: farmerId);
        },
        
        // Phase 4: Farmer Workflow Routes
        FarmerRoutes.profile: (context) => const FarmerProfileScreen(),
        FarmerRoutes.editProfile: (context) => const EditFarmerProfileScreen(),
        FarmerRoutes.addFarm: (context) => const AddFarmScreen(),
        FarmerRoutes.createTransportRequest: (context) => const CreateTransportRequestScreen(),
        FarmerRoutes.transportRequestDetail: (context) {
          final requestId = ModalRoute.of(context)?.settings.arguments as String;
          return TransportRequestDetailScreen(requestId: requestId);
        },
      };
}

// Phase 4: Farmer Workflow Routes
class FarmerRoutes {
  static const String profile = '/farmer/profile';
  static const String editProfile = '/farmer/edit_profile';
  static const String addFarm = '/farmer/add_farm';
  static const String createTransportRequest = '/farmer/create_transport_request';
  static const String transportRequestDetail = '/farmer/transport_request_detail';
  static const String marketplace = '/marketplace';
  static const String marketIntelligence = '/market/intelligence';
}