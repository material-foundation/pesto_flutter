import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repository/module.dart';
import '../../domain/model/recipe.dart';
import '../widgets/adaptive_cards.dart';
import '../widgets/filter_list.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).getRecipes();
    final hasDrawer = Scaffold.of(context).hasDrawer;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/Logo.png'),
          leading: hasDrawer
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                )
              : null,
          toolbarHeight: 100,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Recipes'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildRecipes(context, recipes),
            buildRecipes(context, recipes),
          ],
        ),
      ),
    );
  }

  Widget buildRecipes(BuildContext context, List<Recipe> recipes) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
          child: FilterList(
            allFilters: ['Appetizers', 'Entrees', 'Desserts', 'Cocktails'],
            activeFilters: ['Appetizers', 'Entrees'],
          ),
        ),
        Expanded(
          child: AdaptiveCards(
            cardWidth: 372,
            cards: [
              for (final recipe in recipes)
                InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24),
                  ),
                  onTap: () => context.push('/recipe/${recipe.id}'),
                  child: AdaptiveCard(
                    title: recipe.title,
                    subtitle: recipe.description,
                    imagePath: recipe.imagePath,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
