import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/location_update.dart';
import '../models/trip_model.dart';

/// Real-time tracking service using WebSocket for live location updates
/// 
/// Architecture:
/// Transporter Device GPS → Location Service → Real-time Channel →
/// Backend → Buyer/Farmer → Live Map
/// 
/// Features:
/// - WebSocket connection management
/// - Automatic reconnection with exponential backoff
/// - Connection state monitoring
/// - Subscription management per trip
/// - Authorization token handling
/// - Ping/pong heartbeat
class RealtimeTrackingService {
  static final RealtimeTrackingService _instance = RealtimeTrackingService._internal();
  factory RealtimeTrackingService() => _instance;
  RealtimeTrackingService._internal();

  // WebSocket configuration
  static const String _wsBaseUrl = 'ws://your-backend-url/ws'; // Replace with actual URL
  static const Duration _reconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  static const Duration _pingInterval = Duration(seconds: 30);
  static const int _maxReconnectAttempts = 5;

  WebSocketChannel? _channel;
  ConnectionState _connectionState = ConnectionState.disconnected;
  String? _authToken;
  
  // Reconnection management
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  DateTime? _lastMessageTime;

  // Subscription management
  final Map<String, StreamController<LocationUpdate>> _tripSubscriptions = {};
  final Map<String, StreamController<TripStatusUpdate>> _statusSubscriptions = {};
  final StreamController<ConnectionState> _connectionStateController = 
      StreamController<ConnectionState>.broadcast();

  // Getters
  ConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == ConnectionState.connected;
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;

  /// Initialize with auth token
  Future<void> initialize(String authToken) async {
    _authToken = authToken;
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_connectionState == ConnectionState.connecting ||
        _connectionState == ConnectionState.connected) {
      return;
    }

    _setConnectionState(ConnectionState.connecting);

    try {
      final uri = Uri.parse('$_wsBaseUrl?token=$_authToken');
      _channel = WebSocketChannel.connect(uri);

      // Wait for connection
      await _channel!.ready;

      _setConnectionState(ConnectionState.connected);
      _reconnectAttempts = 0;

      // Start listening to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnect,
        cancelOnError: false,
      );

      // Start ping timer
      _startPingTimer();

    } catch (e) {
      _setConnectionState(ConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _setConnectionState(ConnectionState.disconnected);
  }

  /// Send location update to server
  Future<void> sendLocationUpdate(LocationUpdate update) async {
    if (!isConnected) {
      throw Exception('Not connected to tracking server');
    }

    final message = {
      'type': 'location_update',
      'data': update.toJson(),
    };

    _channel?.sink.add(jsonEncode(message));
  }

  /// Subscribe to location updates for a specific trip
  /// Returns stream of location updates
  /// Only authorized users (trip participants) can subscribe
  Stream<LocationUpdate> subscribeToTripLocation(String tripId, String userId) {
    if (!isConnected) {
      throw Exception('Not connected to tracking server');
    }

    // Request subscription from server
    final message = {
      'type': 'subscribe_location',
      'trip_id': tripId,
      'user_id': userId,
    };

    _channel?.sink.add(jsonEncode(message));

    // Create stream controller for this subscription
    final controller = StreamController<LocationUpdate>.broadcast();
    _tripSubscriptions[tripId] = controller;

    return controller.stream;
  }

  /// Unsubscribe from trip location updates
  Future<void> unsubscribeFromTripLocation(String tripId) async {
    if (!isConnected) return;

    final message = {
      'type': 'unsubscribe_location',
      'trip_id': tripId,
    };

    _channel?.sink.add(jsonEncode(message));

    // Close and remove stream controller
    _tripSubscriptions[tripId]?.close();
    _tripSubscriptions.remove(tripId);
  }

  /// Subscribe to trip status updates
  Stream<TripStatusUpdate> subscribeToTripStatus(String tripId, String userId) {
    if (!isConnected) {
      throw Exception('Not connected to tracking server');
    }

    final message = {
      'type': 'subscribe_status',
      'trip_id': tripId,
      'user_id': userId,
    };

    _channel?.sink.add(jsonEncode(message));

    final controller = StreamController<TripStatusUpdate>.broadcast();
    _statusSubscriptions[tripId] = controller;

    return controller.stream;
  }

  /// Unsubscribe from trip status updates
  Future<void> unsubscribeFromTripStatus(String tripId) async {
    if (!isConnected) return;

    final message = {
      'type': 'unsubscribe_status',
      'trip_id': tripId,
    };

    _channel?.sink.add(jsonEncode(message));

    _statusSubscriptions[tripId]?.close();
    _statusSubscriptions.remove(tripId);
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic data) {
    _lastMessageTime = DateTime.now();

    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String;

      switch (type) {
        case 'location_update':
          _handleLocationUpdate(message['data'] as Map<String, dynamic>);
          break;

        case 'status_update':
          _handleStatusUpdate(message['data'] as Map<String, dynamic>);
          break;

        case 'subscription_confirmed':
          // Subscription successful
          break;

        case 'subscription_denied':
          // Unauthorized - close relevant stream
          final tripId = message['trip_id'] as String?;
          if (tripId != null) {
            _tripSubscriptions[tripId]?.addError(
              Exception('Unauthorized to track this trip'),
            );
            _tripSubscriptions[tripId]?.close();
            _tripSubscriptions.remove(tripId);
          }
          break;

        case 'pong':
          // Heartbeat response
          break;

        case 'error':
          final error = message['error'] as String;
          print('WebSocket error: $error');
          break;

        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error processing WebSocket message: $e');
    }
  }

  /// Handle location update message
  void _handleLocationUpdate(Map<String, dynamic> data) {
    try {
      final update = LocationUpdate.fromJson(data);
      final tripId = update.transportTripId;

      // Emit to relevant subscription
      if (_tripSubscriptions.containsKey(tripId)) {
        _tripSubscriptions[tripId]!.add(update);
      }
    } catch (e) {
      print('Error handling location update: $e');
    }
  }

  /// Handle status update message
  void _handleStatusUpdate(Map<String, dynamic> data) {
    try {
      final update = TripStatusUpdate.fromJson(data);
      final tripId = data['trip_id'] as String;

      // Emit to relevant subscription
      if (_statusSubscriptions.containsKey(tripId)) {
        _statusSubscriptions[tripId]!.add(update);
      }
    } catch (e) {
      print('Error handling status update: $e');
    }
  }

  /// Handle WebSocket error
  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _setConnectionState(ConnectionState.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnect
  void _onDisconnect() {
    _setConnectionState(ConnectionState.disconnected);
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnect attempts reached');
      return;
    }

    final delayMs = _reconnectDelay.inMilliseconds * (1 << _reconnectAttempts);
    final delay = Duration(
      milliseconds: delayMs < _maxReconnectDelay.inMilliseconds 
          ? delayMs 
          : _maxReconnectDelay.inMilliseconds,
    );
    _reconnectTimer = Timer(delay, () {
      print('Reconnecting... (attempt $_reconnectAttempts)');
      connect();
    });
  }

  /// Start ping timer for keepalive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (isConnected) {
        _sendPing();
      }
    });
  }

  /// Send ping message
  void _sendPing() {
    final message = {'type': 'ping'};
    _channel?.sink.add(jsonEncode(message));
  }

  /// Update connection state
  void _setConnectionState(ConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
    }
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    
    for (final controller in _tripSubscriptions.values) {
      controller.close();
    }
    for (final controller in _statusSubscriptions.values) {
      controller.close();
    }
    
    _tripSubscriptions.clear();
    _statusSubscriptions.clear();
    _connectionStateController.close();
    
    _channel?.sink.close();
  }
}

/// Connection state enum
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}
