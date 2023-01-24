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