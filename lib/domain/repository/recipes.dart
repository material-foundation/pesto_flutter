import '../model/recipe.dart';

/// Repository for recipes
abstract class RecipesRepository {
  /// Get all recipes
  List<Recipe> getRecipes();
}
