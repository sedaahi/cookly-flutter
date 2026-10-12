import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'my_recipes_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final ValueNotifier<int> favoritesRefreshNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    favoritesRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(refreshListenable: favoritesRefreshNotifier),
      FavoritesScreen(refreshListenable: favoritesRefreshNotifier),
      const MyRecipesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          if (index == selectedIndex) return;

          setState(() {
            selectedIndex = index;
          });

          if (index == 0 || index == 1) {
            favoritesRefreshNotifier.value++;
            debugPrint('Favorites refresh: $index');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'My Recipes',
          ),
        ],
      ),
    );
  }
}
