import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/ecran_chargement.dart';

// UI Design: Point d'entrée de l'application UqarLive avec thème UQAR
void main() {
  runApp(const UqarLiveApp());
}

class UqarLiveApp extends StatelessWidget {
  const UqarLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UqarLive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: CouleursApp.principal,
        scaffoldBackgroundColor: CouleursApp.fond,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CouleursApp.principal,
          primary: CouleursApp.principal,
          secondary: CouleursApp.accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        useMaterial3: true,
      ),
      home: const EcranChargement(),
      debugShowCheckedModeBanner: false,
    );
  }
}
