# Design to Dev : Building An App from Start to Finish




## Before you begin



This guide is meant to be the companion guide to the Flutter Forward 2022 Talk "Building the Basil theme".

When building with Flutter it can be tempting to do theming at the widget level but this can lead to difficult refactoring as the design changes. We will instead use Material 3 as the core design system and build customizations on top of it. Additionally, this codelab will be a resource for architectural practices. By the end, you should have a better understanding of how to translate a design file to production code.

The final source code will be linked below.

### Prerequisites

* Ability to create and run a basic Flutter application.
* Knowledge of Dart / Flutter programming basics

### What you'll build

* A highly themed and well structured recipe application using best practices from Material 3.

### What you'll need

*  [Flutter SDK](https://docs.flutter.dev/get-started/install)
*  [Android SDK](https://developer.android.com/studio) or  [Flutter Desktop integration](https://docs.flutter.dev/development/platform-integration/desktop#additional-windows-requirements)
*  [Figma](https://figma.com)

By the end of this codelab you will have a responsive app that looks like this.

<img src="img/61239955004e4359.png" alt="61239955004e4359.png"  width="2048.00" />


## Creating the project



To get started we need to use the Flutter CLI to generate our project and open it up in  [VSCode](https://code.visualstudio.com/).

```
$ mkdir pesto_example
$ cd pesto_example
$ flutter create .
$ code .
```

This will create the project and open the folder up in VSCode (If this did not happen for you simply open the folder in your preferred IDE).

At this point we should have the default counter example and we will be starting fresh so feel free to delete the file or empty the contents.


## Understanding the application structure



In this application, we will be using a number of libraries and a defined application structure. The libraries will be introduced as needed. The application we will build separates its concerns into layers: Data, Domain (business logic), and Presentation.

Let's start by creating the directory structure we will need later. 

```sh
mkdir lib/domain
mkdir lib/data
mkdir lib/presentation
```

We also need to add the images to the project. Update the ``pubspec.yaml`` to include the images located at `assets/images/`:

```yaml
name: pesto_example
description: A new Flutter project.

publish_to: "none"

version: 1.0.0+1

environment:
  sdk: '>=3.0.0-85.0.dev <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.21

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/2.0x/
    - assets/images/3.0x/

```


## Scaffolding the application



If we run the application right now, we'll see the template Counter app. Let's fix that. First, we want to move the main logic for running the application out of main.dart and use our layered structure. 

 Create a file at `lib/presentation/app.dart` and add the following text.

```dart
import 'package:flutter/material.dart';

class Pesto extends StatefulWidget {
  const Pesto({super.key});

  @override
  State<Pesto> createState() => _PestoState();
}

class _PestoState extends State<Pesto> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pesto',
        home: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Text('Pesto Default')));
  }
}
```

Replace the lib/main.dart app with the following.

```dart
import 'package:flutter/material.dart';
import 'presentation/app.dart';

void main() {
  runApp(const Pesto());
}
```


## Adding Recipe and Recipes screens



Following our application structure, we have a domain model class that holds all the data needed to create a recipe, a number of which are optional. Create a file at lib/domain/model/recipe.dart and add the following content:

```dart
import 'package:flutter/material.dart';

/// Base class for all recipes
class Recipe {
  const Recipe({
    required this.imagePath,
    required this.title,
    required this.description,
    this.warnings = const [],
    this.ingredients = const [],
  });

  /// Path to the image asset
  final String imagePath;

  /// Title of the recipe
  final String title;

  /// Description of the recipe
  final String description;

  /// All warnings for this recipe
  final List<RecipeWarning> warnings;

  /// All ingredients for this recipe
  final List<RecipeIngredient> ingredients;

  String get id => title.toLowerCase().replaceAll(' ', '-');
}

/// Recipe warning
class RecipeWarning {
  const RecipeWarning(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Recipe step
class RecipeIngredient {
  const RecipeIngredient(this.label, this.amount);
  final String label;
  final String amount;
}
```

### Creating an initial RecipesScreen page

Our RecipesScreen has some basic structure to show a list of recipes using ListTiles. For now, we have a sample list of recipes that we will replace later with retrieval from the repository.

lib/presentation/screens/RecipesScreen.dart

```dart
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// Will remove later
import 'package:pesto_example/domain/model/recipe.dart';


class RecipesScreen extends StatelessWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  // will remove this later
  final recipes = const [
    Recipe(
      imagePath: 'assets/images/Spinach.png',
      title: 'Spinach Filo Puffs',
      description:
          'Hearty, organic filo puffs that taste just a little better than homemade.',
    ),
    Recipe(
      imagePath: 'assets/images/Beef.png',
      title: 'Beef Pot Pies',
      description:
          'Hearty, organic beef pot pies that taste just a little better than homemade.',
    ),
    Recipe(
      imagePath: 'assets/images/Basil.png',
      title: 'Basil Pesto',
      description:
          'Hearty, organic basil pesto that taste just a little better than homemade.',
    ),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            leading: Image.asset(recipe.imagePath),
            title: Text(recipe.title),
            subtitle: Text(recipe.description),
            // onTap: () => context.push('/recipes/${recipe.id}'),
          );
        },
      ),
    );
  }
}
```

### Creating screens for individual recipes

Now that we have a general RecipesScreen, let's add one to display individual recipes. When a recipe is selected, it will pass through an id to identify the recipe to display. To make that a bit more simple, we can use a package called ‘collection.'

The collection package can search a list of items given an expression. 

```sh
$ flutter pub add collection
```

For now, we have included a couple recipes and our widget will simply show the recipe id.

```dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pesto_example/domain/model/recipe.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  // Will remove later
  final recipes = const [
    Recipe(
      imagePath: 'images/Spinach.png',
      title: 'Spinach Filo Puffs',
      description:
          'Hearty, organic filo puffs that taste just a little better than homemade.',
    ),
    Recipe(
      imagePath: 'images/Beef.png',
      title: 'Beef Pot Pies',
      description:
          'Hearty, organic beef pot pies that taste just a little better than homemade.',
    ),
    Recipe(
      imagePath: 'images/Basil.png',
      title: 'Basil Pesto',
      description:
          'Hearty, organic basil pesto that taste just a little better than homemade.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final recipe = recipes.firstWhereOrNull((recipe) => recipe.id == id);
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe'),
        ),
        body: const Center(
          child: Text('Recipe not found'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe: $id'),
      ),
      body: const Placeholder(),
    );
  }
}
```

Run the app and have the initial screen but we can't yet see an individual recipe yet.

<img src="img/433cbc2331a9c4c8.png" alt="433cbc2331a9c4c8.png"  width="797.00" />


## Moving between screens



To facilitate moving between locations in the app, we'll be using go_router. go_router provides many more features that the ones we'll be using so check out its page on pub.dev ( [https://pub.dev/packages/go_router](https://pub.dev/packages/go_router)) for a detailed list or Package of the week video for a quick primer. 

<video id="b6Z885Z46cU"></video>

Add go_router  to the project by running the following command:

```
$ flutter pub add go_router
```

To route between targets in your app, you need to set up routes. In our application, we'll be differentiating between routes using their paths. Though unused here, you can also optionally name routes. We have three routes, two for the home screen and one for the recipe screen. The second option is technically redundant but is useful if we decided to expand the app later.

Add the following to lib/presentation/router.dart

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:pesto_example/presentation/screens/recipe.dart';
import 'package:pesto_example/presentation/screens/recipes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, state) => const RecipesScreen(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (_, state) => const RecipesScreen(),
      ),
      GoRoute(
          path: '/recipe/:id',
          builder: (_, state) => RecipeScreen(id: state.params['id']!))
    ],
  );
}
```

In lib/presentation/app.dart, replace the current _PestoState with the following that will use the routes we have set up.

```dart
class _PestoState extends State<Pesto> {
  late final router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pesto',
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}

```

In lib/presentation/screens/recipes.dart, make sure the onTap line is uncommented and that you've added an import for go_router.

```dart
import 'package:go_router/go_router.dart';
...

...

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            leading: Image.asset(recipe.imagePath),
            title: Text(recipe.title),
            subtitle: Text(recipe.description),
            onTap: () => context.push('/recipe/${recipe.id}'),
          );
        },
      ),
    );
  }
```

You can now navigate between locations in the app.


## Fleshing out the domain and data layers



Previously, we were using hard coded lists of Recipes to build out the screens. Let's now build out a discrete implementation that pulls the recipes from a repository.

### Adding Riverpod and Recipe Repository

Riverpod will be supplying our state management for Pesto. Instead of using InheritedWidgets as provider does, Riverpod implementations pass to widgets a WidgetRef object that they can use to interact with and query state. Riverpod is one of many possible options you could use.

We need to add  [Riverpod](https://pub.dev/packages/flutter_riverpod) to our dependencies:

```
$ flutter pub add flutter_riverpod
```

The Riverpod  [Provider](https://pub.dev/documentation/riverpod/latest/riverpod/Provider-class.html) class is your main access point to state.They can be accessed from anywhere and default to being safe.

Create and update the file `lib/data/repository/module.dart`  with the following code:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/recipes.dart';
import 'recipes_impl.dart';

final recipesProvider = Provider<RecipesRepository>(
  (ref) => RecipesRepositoryImpl(),
);
```

Don't refresh your app just yet, we need to make the `RecipeRepository` and `RecipeRepositoryImpl` classes.

### Creating RecipeRepository and RecipeRepositoryImpl

RecipeRepository requires a single function for classes that extend it, a function getRecipes that returns a List.

Update the file `lib/domain/repository/recipes.dart`  with the following:

```dart
import '../model/recipe.dart';

/// Repository for recipes
abstract class RecipesRepository {
  /// Get all recipes
  List<Recipe> getRecipes();
}
```

`RecipesRepositoryImpl` returns a static list of recipes when getRecipes is called. Riverpod uses an instance of RecipeRepositoryImpl in its provider when we want to display recipes.

Update the file `lib/data/repository/recipes_impl.dart`  with the following:

```dart
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

```


## Riverpod: Converting from StatelessWidget to ConsumerWidget



If you reloaded the app at the end of the last step, you might have been disappointed that only the sample recipes were displayed. That's because the screens were still StatelessWidgets and had no access to the provider we had setup.

ConsumerWidget extends StatelessWidget but can listen to providers.

There's only a small change required to turn a StatelessWidget into a ConsumerWidget. The signature of the build function takes in a Widget ref in addition to the BuildContext as shown below. Inside that build function, you can use that WidgetRef to access providers you've already set up.

```dart
class Example extends ConsumerWidget {
  const Example({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(helloWorldProvider);
    return Text(value); // Hello world
  }
}
```

In the recipe screen file, we need to: 

* Add imports for riverpod and the repository module, 
* Change the parent class to ConsumerWidget,
* Add WidgetRef to the signature of the build function
* Replace the local variable recipes with a call to ref.watch in the build function

```dart
import '../../data/repository/module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).getRecipes();
  ...
  }
}
```

Similar changes need to be made in the recipes screen file. All necessary changes are at the start of the file.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repository/module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).getRecipes();

    ...
  }
}
```

In your lib/main.dart file, add the ProviderScope and riverpod import so that it matches the following.

```dart
import 'package:flutter/material.dart';
import 'package:pesto_example/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: Pesto()));
}
```

> aside negative
> 
> Troubleshooting: If you see an error message "Bad state: No ProviderScope found" make sure you have passed a provider in your app's root widget. In our case, it is main.dart. Fail to wrap the Pesto widget with a ProviderScope, you will get the error and it will look like the error is in the router file.


## Creating a custom theme



We need to add 2 packages to make the widget work.

```
$ flutter pub add palette_generator
$ flutter pub add material_color_utilities
```

Update the `lib/presentation/theme.dart`  file with the following:

```dart
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class BasilTheme extends ThemeExtension<BasilTheme> {
  const BasilTheme({
    this.primaryColor = const Color(0xFF356859),
    this.tertiaryColor = const Color(0xFFFF5722),
    this.neutralColor = const Color(0xFFFFFBE6),
  });

  final Color primaryColor;
  final Color tertiaryColor;
  final Color neutralColor;

  Scheme _scheme() {
    final base = CorePalette.of(primaryColor.value);
    final primary = base.primary;
    final tertiary = CorePalette.of(tertiaryColor.value).primary;
    final neutral = CorePalette.of(neutralColor.value).neutral;
    return Scheme(
      primary: primary.get(40),
      onPrimary: primary.get(100),
      primaryContainer: primary.get(90),
      onPrimaryContainer: primary.get(10),
      secondary: base.secondary.get(40),
      onSecondary: base.secondary.get(100),
      secondaryContainer: base.secondary.get(90),
      onSecondaryContainer: base.secondary.get(10),
      tertiary: tertiary.get(40),
      onTertiary: tertiary.get(100),
      tertiaryContainer: tertiary.get(90),
      onTertiaryContainer: tertiary.get(10),
      error: base.error.get(40),
      onError: base.error.get(100),
      errorContainer: base.error.get(90),
      onErrorContainer: base.error.get(10),
      background: neutral.get(99),
      onBackground: neutral.get(10),
      surface: neutral.get(99),
      onSurface: neutral.get(10),
      outline: base.neutralVariant.get(50),
      outlineVariant: base.neutralVariant.get(80),
      surfaceVariant: base.neutralVariant.get(90),
      onSurfaceVariant: base.neutralVariant.get(30),
      shadow: neutral.get(0),
      scrim: neutral.get(0),
      inverseSurface: neutral.get(20),
      inverseOnSurface: neutral.get(95),
      inversePrimary: primary.get(80),
    );
  }

  ThemeData _base(final ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      extensions: [this],
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }


  @override
  ThemeExtension<BasilTheme> copyWith({
    Color? primaryColor,
    Color? tertiaryColor,
    Color? neutralColor,
  }) =>
      BasilTheme(
        primaryColor: primaryColor ?? this.primaryColor,
        tertiaryColor: tertiaryColor ?? this.tertiaryColor,
        neutralColor: neutralColor ?? this.neutralColor,
      );

  @override
  BasilTheme lerp(
    covariant ThemeExtension<BasilTheme>? other,
    double t,
  ) {
    if (other is! BasilTheme) return this;
    return BasilTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      tertiaryColor: Color.lerp(tertiaryColor, other.tertiaryColor, t)!,
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t)!,
    );
  }

  ThemeData toThemeData() {
    final colorScheme = _scheme().toColorScheme(Brightness.light);
    return _base(colorScheme).copyWith(brightness: colorScheme.brightness);
  }
}

extension on Scheme {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
        primary: Color(primary),
        onPrimary: Color(onPrimary),
        primaryContainer: Color(primaryContainer),
        onPrimaryContainer: Color(onPrimaryContainer),
        secondary: Color(secondary),
        onSecondary: Color(onSecondary),
        secondaryContainer: Color(secondaryContainer),
        onSecondaryContainer: Color(onSecondaryContainer),
        tertiary: Color(tertiary),
        onTertiary: Color(onTertiary),
        tertiaryContainer: Color(tertiaryContainer),
        onTertiaryContainer: Color(onTertiaryContainer),
        error: Color(error),
        onError: Color(onError),
        errorContainer: Color(errorContainer),
        onErrorContainer: Color(onErrorContainer),
        outline: Color(outline),
        outlineVariant: Color(outlineVariant),
        background: Color(background),
        onBackground: Color(onBackground),
        surface: Color(surface),
        onSurface: Color(onSurface),
        surfaceVariant: Color(surfaceVariant),
        onSurfaceVariant: Color(onSurfaceVariant),
        inverseSurface: Color(inverseSurface),
        onInverseSurface: Color(inverseOnSurface),
        inversePrimary: Color(inversePrimary),
        shadow: Color(shadow),
        scrim: Color(scrim),
        surfaceTint: Color(primary),
        brightness: brightness);
  }
}

```

Here we added the brand colors defined in our design file.

This also defines our theme class as a theme extension to be able to reference it in the widget tree with proper overrides.

`lib/presentation/app.dart`

Update the file with the following:

```dart
import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class Pesto extends StatefulWidget {
  const Pesto({super.key});

  @override
  State<Pesto> createState() => _PestoState();
}

class _PestoState extends State<Pesto> {
  late final router = buildRouter();
  final theme = BasilTheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pesto',
      theme: theme.toThemeData(),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
```


## Custom scheme class in detail



Let's create a method that returns a Scheme that we can use to create a custom color scheme class.

Sometimes a design is derived from a single color and for those instances we can use the color scheme from seed color. CorePalette will take that input color and generate a color scheme.

For Basil we have multiple brand colors that we need to use to create custom tonal groups from.

First define a base palette that all tokens can inherit from if not overridden.

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
  ...
  Scheme _scheme() {
    final base = CorePalette.of(primaryColor.value);
    final primary = base.primary;
    final tertiary = CorePalette.of(tertiaryColor.value).primary;
    final neutral = CorePalette.of(neutralColor.value).neutral;
    return Scheme(...);
  }
}
```

Next create the tertiary tonal group and note that the palette is returning the primary palette to provide the chromatic tonal group the design was intending.

Finally create the neutral palette which will also be used to override tokens.

The Color palette class comes from the material color utilities and is a group of palettes that are derived from a single source color.

Next, we will be adding tokens to the Scheme class.

You may not be familiar with the Scheme class or the concept of design tokens.

The Scheme is a class in material color utilities that has a 1 to 1 relationship with the Color scheme in Flutter. Design tokens are named design decisions that assign a role or responsibility (like onPrimary) to a discrete value. 

In Material 3, each role has a well-defined palette and tone based on the Brightness. For example, the onPrimary color role may have a different value if the UI is light or dark.

Also worth noting is that specifying every color role directly is generally not encouraged. **This implementation is for demo purposes** to help you understand what is going on in ThemeData. Not using care when overriding colors can result in contrast issues or problems with legibility.

<img src="img/61755b2938b613a1.png" alt="61755b2938b613a1.png"  width="1532.00" />

To learn more about the new tokens in material design you can go to  [m3.material.io](https://m3.material.io/).

Next add the overrides for the tokens.

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
  ...
  Scheme _scheme() {
    ...
    return Scheme(
      primary: primary.get(40),
      onPrimary: primary.get(100),
      primaryContainer: primary.get(90),
      onPrimaryContainer: primary.get(10),
      secondary: base.secondary.get(40),
      onSecondary: base.secondary.get(100),
      secondaryContainer: base.secondary.get(90),
      onSecondaryContainer: base.secondary.get(10),
      tertiary: tertiary.get(40),
      onTertiary: tertiary.get(100),
      tertiaryContainer: tertiary.get(90),
      onTertiaryContainer: tertiary.get(10),
      error: base.error.get(40),
      onError: base.error.get(100),
      errorContainer: base.error.get(90),
      onErrorContainer: base.error.get(10),
      background: neutral.get(99),
      onBackground: neutral.get(10),
      surface: neutral.get(99),
      onSurface: neutral.get(10),
      outline: base.neutralVariant.get(50),
      outlineVariant: base.neutralVariant.get(80),
      surfaceVariant: base.neutralVariant.get(90),
      onSurfaceVariant: base.neutralVariant.get(30),
      shadow: neutral.get(0),
      scrim: neutral.get(0),
      inverseSurface: neutral.get(20),
      inverseOnSurface: neutral.get(95),
      inversePrimary: primary.get(80),
        ...
    );
  }
}
```

Note that for a dark theme there needs to be different tones used for the tokens.

For most cases, you will not need to create a custom color scheme, but the final theme file will demonstrate many of the things that the helper functions will give you automatically.

```dart
extension on Scheme {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
        primary: Color(primary),
        onPrimary: Color(onPrimary),
        ...
        brightness: brightness);
  }
}
```

We also can create an extension method on the scheme class to return a color scheme that the theme data class expects with a given brightness.

### Using the color scheme

Now we can add the Color scheme parameter to our base method and pass the color scheme to the theme data class.

When overriding a token such as the scaffold background, sometimes the design will use a brand color instead of a derived token in the scheme.

For this token we are checking if it is a light brightness and using the brand color defined earlier.

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
  ...
  ThemeData _base(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      extensions: [this],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? neutralColor : colorScheme.background,
      ...
    );
  }
  ...
}
```

Finally we can compose the complete color scheme and theme data class in out "to theme data" method, while making sure to pass the brightness.

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
  ...
  ThemeData toThemeData() {
    final colorScheme = _scheme().toColorScheme(Brightness.light);
    return _base(colorScheme).copyWith(brightness: colorScheme.brightness);
  }
  ...
}
```


## Updating routing



Instead of showing each screen individually, our design calls for a nested UI that hosts the child routes and an ability to navigate between them.

ShellRoute in go_router provides this functionality.


After adding ShellRoute, we'll have the following possible routes in the app:

* RecipeScreen
* RecipesScreen
* NotesScreen (new)
* ProfileScreen (new)
* SettingsScreen (new)

&lt;Insert new example from the new Liam designs here&gt;

<img src="img/ec6e759e95546404.png" alt="ec6e759e95546404.png"  width="404.00" />

### Create new Route locations

After adding ShellRoute, we'll have a few more routes in the app we need to create:

* RecipeScreen
* RecipesScreen
* NotesScreen (new)
* ProfileScreen (new)
* SettingsScreen (new)

`lib/presentation/screens/settings.dart`

```dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Placeholder(),
    );
  }
}
```

`lib/presentation/screens/profile.dart`

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Placeholder(),
    );
  }
}
```

`lib/presentation/screens/notes.dart`

```dart
import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const Placeholder(),
    );
  }
}
```

`lib/presentation/router.dart`

Now we can update the router with a `ShellRoute`.

```dart
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
```


## Making the UI adaptive



Right now the app is built for one form factor. Instead, we'd like flexibility to allow it to apply the best use of space and UI patterns when it's space constrained on a mobile device or has a lot of horizontal and vertical width as on a tablet.

The `RootLayout` widget `(lib/presentation/screens/root.dart)` gives us this flexibility. Its build function examines the LayoutBuilder constraints to determine maxWidth and if it is 860 pixels wide or more, the tablet form factor is constructed. Otherwise the mobile is used.

```dart
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
```

<img src="img/507eebcd0b17b9a3.png" alt="507eebcd0b17b9a3.png"  width="1996.00" />

<img src="img/725a18e44a861d1a.png" alt="725a18e44a861d1a.png"  width="529.03" />


## Creating custom components



Our design has a number of custom components matching the designer's intent. They are:

* AdaptiveCard(s) that show themed Recipe cards in an grid view,
* SelectChip showing an filter criteria that has been selected,
* FilterList showing all available filters.

Go ahead and create the following files:

* `lib/presentation/widgets/adaptive_cards.dart`
* `lib/presentation/widgets/filter_list.dart`
* `lib/presentation/widgets/selected_chip.dart`
* `lib/presentation/widgets/warning_chip.dart`


## AdaptiveCard



`lib/presentation/widgets/adaptive_cards.dart`

```dart
import 'package:flutter/material.dart';

import '../theme.dart';

class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imagePath});

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.textTheme;
    final colors = theme.colorScheme;
    final basilTheme = theme.extension<BasilTheme>();
    return Column(
      children: [
        Expanded(
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 32),
          child: Text(
            title,
            style: typography.displaySmall!.copyWith(
              color: theme.brightness == Brightness.light
                  ? basilTheme?.tertiaryColor
                  : colors.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          subtitle,
          style: typography.bodyLarge!.copyWith(
            color: colors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AdaptiveCards extends StatelessWidget {
  const AdaptiveCards(
      {super.key, required this.cards, required this.cardWidth});

  final List<Widget> cards;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final itemSize = Size(cardWidth, 192);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = (width / itemSize.width).floor();
        final childAspectRatio = width / (crossAxisCount * itemSize.width);
        return GridView.count(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 32,
          mainAxisSpacing: 32,
          childAspectRatio: childAspectRatio,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
```


## FilterChip and SelectChip



`lib/presentation/widgets/filter_list.dart`

```dart
import 'package:flutter/material.dart';

import 'selected_chip.dart';

class FilterList extends StatelessWidget {
  const FilterList({
    super.key,
    required this.allFilters,
    required this.activeFilters,
  });

  final List<String> allFilters, activeFilters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final filter in allFilters)
            Padding(
              padding: const EdgeInsets.all(4),
              child: activeFilters.contains(filter)
                  ? SelectedChip(
                      label: filter,
                      onTap: () {},
                    )
                  : ChoiceChip(
                      selected: false,
                      label: Text(filter),
                      tooltip: 'Add "$filter" filter',
                      onSelected: (_) {},
                    ),
            )
        ],
      ),
    );
  }
}

```

`lib/presentation/widgets/selected_chip.dart`

```dart
import 'package:flutter/material.dart';

class SelectedChip extends StatelessWidget {
  const SelectedChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return RawChip(
        label: Text(label),
        onPressed: onTap,
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onTap,
        backgroundColor: colors.secondaryContainer,
        deleteIconColor: colors.onSecondaryContainer,
        labelStyle: TextStyle(color: colors.onSecondaryContainer),
        deleteButtonTooltipMessage: 'Remove $label',
        side: BorderSide(color: colors.secondaryContainer));
  }
}

```

```
import 'dart:math';

import 'package:flutter/material.dart';

class WarningChip extends StatelessWidget {
  const WarningChip({
    Key? key,
    required this.iconData,
    required this.label,
    this.tertiaryColor,
  }) : super(key: key);

  final IconData iconData;
  final String label;
  final Color? tertiaryColor;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24;
    const double borderWidth = 3;
    final outlineColor = tertiaryColor ?? Theme.of(context).colorScheme.error;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: outlineColor,
                        width: borderWidth,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(iconSize),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Icon(
                    iconData,
                    color: Theme.of(context).colorScheme.primary,
                    size: iconSize,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: pi / 7,
                      child: Container(
                        height: borderWidth,
                        width: iconSize,
                        color: outlineColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: outlineColor,
                ),
          ),
        ],
      ),
    );
  }
}
```

`lib/presentation/screens/recipe.dart`

```dart
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/module.dart';
import '../../domain/model/recipe.dart';
import '../theme.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).getRecipes();
    final recipe = recipes.firstWhereOrNull((recipe) => recipe.id == id);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe'),
        ),
        body: const Center(
          child: Text('Recipe not found'),
        ),
      );
    }

    return Container(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final basilTheme = theme.extension<BasilTheme>();
          final typography = theme.textTheme;
          final colors = theme.colorScheme;
          final outlineColor = theme.brightness == Brightness.light
              ? basilTheme?.tertiaryColor
              : colors.tertiary;
          return Scaffold(
            appBar: AppBar(
              title: Transform.scale(
                scale: 0.5,
                child: Image.asset('assets/images/Logo.png'),
              ),
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 360,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(recipe.imagePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 32),
                          child: Text(
                            recipe.title,
                            style: typography.displayLarge!.copyWith(
                              color: outlineColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          recipe.description,
                          style: typography.bodyLarge!.copyWith(
                            color: colors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Wrap(
                          children: recipe.warnings
                              .map(
                                  (e) => buildWarning(context, e, outlineColor))
                              .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 32),
                          child: Text(
                            'Ingredients',
                            style: typography.displaySmall!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? basilTheme?.tertiaryColor
                                  : colors.tertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...recipe.ingredients
                            .map((e) => buildStep(context, e))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.restaurant_outlined),
              label: const Text('Start cooking'),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Widget buildStep(BuildContext context, RecipeIngredient ingredients) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: colors.primary,
          ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline),
          const SizedBox(width: 8),
          Text(
            ingredients.label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(
                color: colors.primary,
                strokeWidth: 2,
                gap: 3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ingredients.amount,
          ),
        ],
      ),
    );
  }

  Widget buildWarning(
    BuildContext context,
    RecipeWarning warning,
    Color? tertiaryColor,
  ) {
    const double iconSize = 24;
    const double borderWidth = 3;
    final outlineColor = tertiaryColor ?? Theme.of(context).colorScheme.error;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Icon(
                    warning.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: iconSize,
                  ),
                ),
                // Build strike trough icon overlay
                Positioned(
                  top: -borderWidth,
                  left: -borderWidth,
                  bottom: -borderWidth,
                  right: -borderWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: outlineColor,
                        width: borderWidth,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(iconSize),
                      ),
                    ),
                  ),
                ),
                // Line through
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Center(
                    child: Transform.rotate(
                      angle: pi / 7,
                      child: Container(
                        height: borderWidth,
                        width: iconSize,
                        color: outlineColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            warning.label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: outlineColor,
                ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dashWidth = strokeWidth + gap;
    final dashCount = (size.width / dashWidth).floor();
    for (var i = 0; i <= dashCount; i++) {
      final dx = i * dashWidth;
      canvas.drawLine(Offset(dx, 0), Offset(dx + strokeWidth, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

```


## Updating the RecipeScreen



`lib/presentation/screens/recipe.dart`

```dart
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/module.dart';
import '../../domain/model/recipe.dart';
import '../theme.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).getRecipes();
    final recipe = recipes.firstWhereOrNull((recipe) => recipe.id == id);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe'),
        ),
        body: const Center(
          child: Text('Recipe not found'),
        ),
      );
    }

    return Container(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final basilTheme = theme.extension<BasilTheme>();
          final typography = theme.textTheme;
          final colors = theme.colorScheme;
          final outlineColor = theme.brightness == Brightness.light
              ? basilTheme?.tertiaryColor
              : colors.tertiary;
          return Scaffold(
            appBar: AppBar(
              title: Transform.scale(
                scale: 0.5,
                child: Image.asset('assets/images/Logo.png'),
              ),
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 360,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(recipe.imagePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 32),
                          child: Text(
                            recipe.title,
                            style: typography.displayLarge!.copyWith(
                              color: outlineColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          recipe.description,
                          style: typography.bodyLarge!.copyWith(
                            color: colors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Wrap(
                          children: recipe.warnings
                              .map(
                                  (e) => buildWarning(context, e, outlineColor))
                              .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, top: 32),
                          child: Text(
                            'Ingredients',
                            style: typography.displaySmall!.copyWith(
                              color: theme.brightness == Brightness.light
                                  ? basilTheme?.tertiaryColor
                                  : colors.tertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...recipe.ingredients
                            .map((e) => buildStep(context, e))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.restaurant_outlined),
              label: const Text('Start cooking'),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Widget buildStep(BuildContext context, RecipeIngredient ingredients) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: colors.primary,
          ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline),
          const SizedBox(width: 8),
          Text(
            ingredients.label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(
                color: colors.primary,
                strokeWidth: 2,
                gap: 3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ingredients.amount,
          ),
        ],
      ),
    );
  }

  Widget buildWarning(
    BuildContext context,
    RecipeWarning warning,
    Color? tertiaryColor,
  ) {
    const double iconSize = 24;
    const double borderWidth = 3;
    final outlineColor = tertiaryColor ?? Theme.of(context).colorScheme.error;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Icon(
                    warning.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: iconSize,
                  ),
                ),
                // Build strike trough icon overlay
                Positioned(
                  top: -borderWidth,
                  left: -borderWidth,
                  bottom: -borderWidth,
                  right: -borderWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: outlineColor,
                        width: borderWidth,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(iconSize),
                      ),
                    ),
                  ),
                ),
                // Line through
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Center(
                    child: Transform.rotate(
                      angle: pi / 7,
                      child: Container(
                        height: borderWidth,
                        width: iconSize,
                        color: outlineColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            warning.label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: outlineColor,
                ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dashWidth = strokeWidth + gap;
    final dashCount = (size.width / dashWidth).floor();
    for (var i = 0; i <= dashCount; i++) {
      final dx = i * dashWidth;
      canvas.drawLine(Offset(dx, 0), Offset(dx + strokeWidth, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

```


## Updating the RecipesScreen



```dart
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/Logo.png');
  }
}
```

```
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repository/module.dart';
import '../../domain/model/recipe.dart';
import '../widgets/adaptive_cards.dart';
import '../widgets/filter_list.dart';
import '../widgets/logo.dart';

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
          title: const Logo(),
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
```


## Theming the app



Now that we have all the core widgets in place we can run our app and see what it would look like with the default blue theme data.

&gt;         The goal of not doing any theming yet is to show how much is possible to theme with the `ThemeData` class

### Specifying custom fonts

Based on the design file we need to use 2 different fonts.  [Lekton](https://fonts.google.com/specimen/Lekton) and  [Montserrat](https://fonts.google.com/specimen/Montserrat) from  [Google Fonts](https://fonts.google.com/).

First we need to import the google fonts package in the file where we defined our theme.

```dart
...
import 'package:google_fonts/google_fonts.dart';
...

@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
}
```

Next we can create a new method to return a base theme data class that we will use for other contexts such as light and dark later.

We can import the two fonts defined for us in the design spec and create a merged theme which we pass to the theme data class.

Note that it is possible to override just a single level or groups of styles depending on the design intent.

&gt; This package just require internet access to make sure to give the macos target if running the correct entitlement defined in the package.

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
  ThemeData _base() {
    final primaryTextTheme = GoogleFonts.lektonTextTheme();
    final secondaryTextTheme = GoogleFonts.montserratTextTheme();
    final textTheme = primaryTextTheme.copyWith(
        displaySmall: secondaryTextTheme.displaySmall);
    ...
    return ThemeData(
      ...
      textTheme: textTheme,
      ...
    );
  }
}
```

That's it for typography! Next time we run the app we will see roboto updated to the correct new text styles.

#### Generating color theme

To build the theme based on the colors in the design file we could use the [Material Theme Builder](https://m3.material.io/theme-builder) to export a static theme, but today we will go over how to build the theme with the [material color utilities](https://pub.dev/packages/material_color_utilities) package.

Let's add the material color utilities import above our theme to get access to the HCT color system.

&gt; The flutter SDK already depends on the package but you will still want to add the package to you pubspec dependencies.

```dart
...
import 'package:material_color_utilities/material_color_utilities.dart';

@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
}
```


## Creating Widget themes



Next we'll be making a number of changes to the widgets we've created. These are the last changes we'll be making to lib/presentation/theme.dart so feel free to either make these individual changes yourself or grab the final file.

### Tab bar

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
  ThemeData _base(final ColorScheme colorScheme) {
    ...
    return ThemeData(
      ...
      tabBarTheme: TabBarTheme(
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurface,
          indicator: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: colorScheme.primary, width: 2)))),
      ...
    );
  }
}
```

### Floating action button

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
  ThemeData _base(final ColorScheme colorScheme) {
    ...
    return ThemeData(
      ...
     floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer),
      ...
    );
  }
}
```

### Navigation rail

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
  ThemeData _base(final ColorScheme colorScheme) {
    ...
    return ThemeData(
      ...
      navigationRailTheme: NavigationRailThemeData(
          backgroundColor: isLight ? neutralColor : colorScheme.surface,
          selectedIconTheme:
              IconThemeData(color: colorScheme.onSecondaryContainer),
          indicatorColor: colorScheme.secondaryContainer),
      ...
    );
  }
}
```

### App bar and chips

```dart
@immutable
class BasilTheme extends ThemeExtension<BasilTheme> {
    ...
  ThemeData _base(final ColorScheme colorScheme) {
    ...
    return ThemeData(
      ...
      appBarTheme: AppBarTheme(
          backgroundColor: isLight ? neutralColor : colorScheme.surface),
      chipTheme: ChipThemeData(
          backgroundColor: isLight ? neutralColor : colorScheme.surface),
      ...
    );
  }
}
```

You don't have to override theming in every component, sometimes the Material 3 defaults fit the mood your design calls for.


## Theming based on the image



As we discussed before Material 3 gives us the ability to derive themes from a color. Material color utilities also has the ability to create a theme based on the colors in an image. A common example of this is a music app where the play screen is influenced by the artist's album art. 

Album art was created in most cases to theme a UI so there is a set of requirements that are applied by material color utilities to make sure the elements of the UI are legible and have proper contrast.

Applying this to Pesto, when you navigate into the details of a specific recipe, the theme for that screen will be based on the recipe's image.

`lib/presentation/widgets/image_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:palette_generator/palette_generator.dart';

class ImageTheme extends StatelessWidget {
  const ImageTheme({
    super.key,
    required this.path,
    required this.child,
  });
  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: colorSchemeFromImage(theme.colorScheme, path),
      builder: (context, snapshot) {
        final scheme = snapshot.data ?? theme.colorScheme;
        return Theme(
          data: theme.copyWith(colorScheme: scheme),
          child: child,
        );
      },
    );
  }

  Future<List<Color>?> sourceColorsFromImage(String path) async {
    try {
      final pixels = await imageToPixels(path);
      if (pixels == null || pixels.isEmpty) return null;
      final result = await QuantizerCelebi().quantize(pixels, 128);
      final ranked = Score.score(result.colorToCount);
      return ranked.map((e) => Color(e)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<List<int>?> imageToPixels(String path) async {
    try {
      final provider = await PaletteGenerator.fromImageProvider(
        AssetImage(path),
      );
      return provider.colors.map((e) => e.value).toList();
    } catch (e) {
      debugPrint('error converting image to pixels: $e');
      return null;
    }
  }

  Future<ColorScheme> colorSchemeFromImage(
    ColorScheme base,
    String path,
  ) async {
    final colors = await sourceColorsFromImage(path);
    if (colors == null || colors.isEmpty) return base;
    final to = base.primary.value;
    final from = colors[0].value;
    final blended = Color(Blend.harmonize(from, to));
    final scheme = ColorScheme.fromSeed(
      seedColor: blended,
      brightness: base.brightness,
    );
    return scheme;
  }
}
```

Now we can update the recipe class to include the new widget.

`lib/presentation/screens/recipe.dart`

```dart
import 'dart:math';

...
import '../widgets/image_theme.dart';

class RecipeScreen extends ConsumerWidget {
  ...
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ...
    return ImageTheme( // <-- Rename the container to ImageTheme
      path: recipe.imagePath, // <-- Add the path to the image
      ...
     );
  }
  ...
}
```

Now when we run the application the colors will be tinted based on the image selected.

<img src="img/61239955004e4359.png" alt="61239955004e4359.png"  width="2048.00" />

<img src="img/27841b9ec4600808.png" alt="27841b9ec4600808.png"  width="499.31" />


## Conclusion

In this codelab, you learned how to create an adaptive application using Material 3 components and supporting libraries.

### Resources

*  [Figma File](goo.gle/ff22-pesto-figma)
*  [Github Repo](https://github.com/material-foundation/pesto_flutter)
