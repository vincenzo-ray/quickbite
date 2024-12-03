import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'services/deep_link_service.dart';

// path for the app to handle links
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,

  // handle routes
  routes: [

    // handle no recipe link
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // handle recipe link
    GoRoute(
      path: '/recipe/:id',
      name: 'recipe',
      builder: (context, state) {
        final recipeId = int.parse(state.pathParameters['id']!);
        return RecipeDetailsScreen(
          recipeId: recipeId,
          title: 'Recipe Details', // TODO: get title from backend?
          usedIngredients: const [], // Default to an empty list
          missedIngredients: const [], // Default to an empty list
        );
      },
    ),
  ],

  // error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Navigation error: ${state.error}'),
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await DeepLinkService.initUniLinks(router);
  } catch (e) {
    debugPrint('Deep linking initialization failed: $e'); // handle error
  }
  
  runApp(const QuickBiteApp());
}

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'QuickBite',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}