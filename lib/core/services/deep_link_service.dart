import '../navigation/navigation_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  // Deep link scheme constant
  static const String scheme = 'agrolink';
  
  // NavigationService dependency
  final NavigationService _navigationService = NavigationService();

  Future<DeepLinkResult> parseDeepLink(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      
      if (uri.scheme != scheme) {
        return DeepLinkResult(
          valid: false,
          error: DeepLinkError.invalidScheme,
        );
      }

      final route = '${uri.host}${uri.path}';
      final params = uri.queryParameters;

      return DeepLinkResult(
        valid: true,
        route: route,
        params: params,
      );
    } catch (e) {
      return DeepLinkResult(
        valid: false,
        error: DeepLinkError.malformedUrl,
      );
    }
  }

  bool validateDeepLink(String deepLink) {
    try {
      final uri = Uri.parse(deepLink);
      return uri.scheme == scheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> navigateToDeepLink(String deepLink) async {
    final result = await parseDeepLink(deepLink);
    
    if (!result.valid) {
      _navigationService.navigateToAndClearStack('/');
      return false;
    }

    try {
      final route = result.route!;
      final params = result.params ?? {};

      if (route.startsWith('order/detail')) {
        final orderId = params['orderId'];
        if (orderId != null) {
          _navigationService.navigateTo('/order/detail', arguments: orderId);
          return true;
        }
      } else if (route.startsWith('transport/track')) {
        final tripId = params['tripId'];
        if (tripId != null) {
          _navigationService.navigateTo('/transport/track', arguments: tripId);
          return true;
        }
      } else if (route.startsWith('produce/detail')) {
        final produceId = params['produceId'];
        if (produceId != null) {
          _navigationService.navigateTo('/produce/detail', arguments: produceId);
          return true;
        }
      } else if (route.startsWith('market/list')) {
        final marketId = params['marketId'];
        _navigationService.navigateTo('/market/list', arguments: marketId);
        return true;
      } else if (route.startsWith('profile/farms')) {
        _navigationService.navigateTo('/profile/farms');
        return true;
      }

      _navigationService.navigateToAndClearStack('/');
      return false;
    } catch (e) {
      _navigationService.navigateToAndClearStack('/');
      return false;
    }
  }

  String buildDeepLink(String route, Map<String, String>? params) {
    final uri = Uri(
      scheme: scheme,
      host: route.split('/').first,
      path: route.contains('/') ? '/${route.split('/').skip(1).join('/')}' : '',
      queryParameters: params,
    );
    return uri.toString();
  }
}

class DeepLinkResult {
  final bool valid;
  final String? route;
  final Map<String, String>? params;
  final DeepLinkError? error;

  DeepLinkResult({
    required this.valid,
    this.route,
    this.params,
    this.error,
  });
}

enum DeepLinkError {
  invalidScheme,
  malformedUrl,
  routeNotFound,
  authenticationRequired,
}
