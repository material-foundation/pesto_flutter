import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootLayout extends StatelessWidget {
  const RootLayout({
    Key? key,
    required this.navigationIndex,
    required this.onDestination,
    required this.destinations,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final int navigationIndex;
  final ValueChanged<int> onDestination;
  final List<Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 860;
        if (isTablet) {
          return buildTablet(context);
        } else {
          return buildMobile(context);
        }
      },
    );
  }

  Widget buildTablet(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: buildFab(context, elevated: false),
              ),
              Expanded(
                child: NavigationRail(
                  groupAlignment: 0,
                  destinations: destinations
                      .map((d) => d.toNavigationRailDestination())
                      .toList(),
                  selectedIndex: navigationIndex,
                  labelType: NavigationRailLabelType.selected,
                  onDestinationSelected: onDestination,
                ),
              )
            ],
          ),
          Expanded(child: Scaffold(body: child)),
        ],
      ),
    );
  }

  Widget buildMobile(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Image.asset('assets/images/Logo.png')),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  final selected = index == navigationIndex;
                  return ListTile(
                    title: Text(destination.label),
                    leading: Icon(selected
                        ? destination.selectedIcon
                        : destination.unselectedIcon),
                    selected: selected,
                    onTap: () {
                      onDestination(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: child,
      floatingActionButton: buildFab(context),
    );
  }

  Widget? buildFab(BuildContext context, {bool elevated = true}) {
    final router = GoRouter.of(context);
    if (router.location != '/') return null;
    return FloatingActionButton(
      elevation: elevated ? null : 0,
      child: const Icon(Icons.edit_outlined),
      onPressed: () {},
    );
  }
}

class Destination {
  const Destination(
      {required this.label,
      required this.selectedIcon,
      required this.unselectedIcon});

  final String label;
  final IconData selectedIcon, unselectedIcon;

  NavigationRailDestination toNavigationRailDestination() {
    return NavigationRailDestination(
      icon: Icon(unselectedIcon),
      selectedIcon: Icon(selectedIcon),
      label: Text(label),
    );
  }
}
