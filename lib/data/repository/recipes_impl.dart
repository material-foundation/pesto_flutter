import 'package:flutter/material.dart';

import '../../domain/model/recipe.dart';
import '../../domain/repository/recipes.dart';

class RecipesRepositoryImpl extends RecipesRepository {
  @override
  List<Recipe> getRecipes() {
    const warnings = [
      RecipeWarning('Gluten free', Icons.spa),
      RecipeWarning('Egg free', Icons.egg),
    ];
    const ingredients = [
      RecipeIngredient('Basil', '6 tbsp'),
      RecipeIngredient('Gluten-free Spaghetti', '2 cups'),
      RecipeIngredient('Garlic', '1 tbsp'),
      RecipeIngredient('Ricotta', '4 cups'),
      RecipeIngredient('Kale', '3 cups'),
    ];
    return const [
      Recipe(
        imagePath: 'assets/images/Spinach.png',
        title: 'Spinach Filo Puffs',
        description:
            'Hearty, organic filo puffs that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Beef.png',
        title: 'Beef Pot Pies',
        description:
            'Hearty, organic beef pot pies that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Basil.png',
        title: 'Basil Pesto',
        description:
            'Hearty, organic basil pesto that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Spinach.png',
        title: 'Spinach Filo Puffs',
        description:
            'Hearty, organic filo puffs that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Beef.png',
        title: 'Beef Pot Pies',
        description:
            'Hearty, organic beef pot pies that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Basil.png',
        title: 'Basil Pesto',
        description:
            'Hearty, organic basil pesto that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Spinach.png',
        title: 'Spinach Filo Puffs',
        description:
            'Hearty, organic filo puffs that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Beef.png',
        title: 'Beef Pot Pies',
        description:
            'Hearty, organic beef pot pies that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Basil.png',
        title: 'Basil Pesto',
        description:
            'Hearty, organic basil pesto that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Spinach.png',
        title: 'Spinach Filo Puffs',
        description:
            'Hearty, organic filo puffs that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Beef.png',
        title: 'Beef Pot Pies',
        description:
            'Hearty, organic beef pot pies that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Basil.png',
        title: 'Basil Pesto',
        description:
            'Hearty, organic basil pesto that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Spinach.png',
        title: 'Spinach Filo Puffs',
        description:
            'Hearty, organic filo puffs that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Beef.png',
        title: 'Beef Pot Pies',
        description:
            'Hearty, organic beef pot pies that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
      Recipe(
        imagePath: 'assets/images/Basil.png',
        title: 'Basil Pesto',
        description:
            'Hearty, organic basil pesto that taste just a little better than homemade.',
        warnings: warnings,
        ingredients: ingredients,
      ),
    ];
  }
}
