import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/recipes.dart';
import 'recipes_impl.dart';

final recipesProvider = Provider<RecipesRepository>(
  (ref) => RecipesRepositoryImpl(),
);
