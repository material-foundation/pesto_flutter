import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/notes.dart';
import 'screens/profile.dart';
import 'screens/recipe.dart';
import 'screens/recipes.dart';
import 'screens/root.dart';
import 'screens/settings.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          int index = 1;
          final location = state.location;
          if (location.startsWith('/notes')) {
            index = 0;
          } else if (location.startsWith('/profile')) {
            index = 2;
          } else if (location.startsWith('/settings')) {
            index = 3;
          }
          return RootLayout(
            destinations: const [
              Destination(
                label: 'Notes',
                selectedIcon: Icons.note,
                unselectedIcon: Icons.note_outlined,
              ),
              Destination(
                label: 'Recipes',
                selectedIcon: Icons.store,
                unselectedIcon: Icons.store_outlined,
              ),
              Destination(
                label: 'Account',
                selectedIcon: Icons.account_circle,
                unselectedIcon: Icons.account_circle_outlined,
              ),
              Destination(
                label: 'Settings',
                selectedIcon: Icons.settings,
                unselectedIcon: Icons.settings_outlined,
              ),
            ],
            navigationIndex: index,
            onDestination: (index) {
              switch (index) {
                case 0:
                  context.go('/notes');
                  break;
                case 1:
                  context.go('/');
                  break;
                case 2:
                  context.go('/profile');
                  break;
                case 3:
                  context.go('/settings');
                  break;
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => const RecipesScreen(),
            routes: [
              GoRoute(
                path: 'recipe/:id',
                builder: (_, state) => RecipeScreen(id: state.params['id']!),
              ),
              GoRoute(
                path: 'notes',
                builder: (_, state) => const NotesScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (_, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (_, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
