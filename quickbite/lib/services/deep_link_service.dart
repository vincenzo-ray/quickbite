import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class DeepLinkService {
  static final _logger = Logger();
  static final _appLinks = AppLinks();

  // handles incoming paths from app link
  static Future<void> initUniLinks(GoRouter router) async {
    try {
      // handle app if it was launched from dead state
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _logger.i('App opened with initial URI: $initialUri');
        _handleDeepLink(initialUri, router);
      }

      // Handle URI when app is running
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _logger.i('Received URI while app running: $uri');
            _handleDeepLink(uri, router);
          }
        },
        onError: (err) {
          _logger.e('URI error: $err');
        },
      );
    } 
    // error with deep link
    on PlatformException catch (e) {
      _logger.e('Failed deep link: ${e.message}');
    } catch (e) {
      _logger.e('Deep link initialization error: $e');
    }
  }

  // Handle deep links
  static void _handleDeepLink(Uri uri, GoRouter router) {
    try {
      _logger.i('Handling deep link: $uri');
      
      // Check if this is a recipe URI
      if (uri.host == 'recipe') {
        final pathSegments = uri.pathSegments;

        if (pathSegments.isNotEmpty) {
          final recipeId = int.tryParse(pathSegments[0]);

          if (recipeId != null) {
            _logger.i('Going to recipe: $recipeId');
            // go to the recipe details screen
            router.push('/recipe/$recipeId');
          } else {
            _logger.w('Invalid recipe ID in deep link: ${pathSegments[0]}');
          }
        }
      } else {
        _logger.w('No path for deep link: $uri');
      }
    } catch (e, stackTrace) {
      _logger.e('Error handling deep link: $e\n$stackTrace');
    }
  }
} 