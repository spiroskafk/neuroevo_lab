import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/simulation_screen.dart';

class NeuroEvoApp extends StatelessWidget {
  const NeuroEvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroEvo Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF2196F3),
          surface: Color(0xFF16213E),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/simulation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return SimulationScreen(simulationId: args ?? 'self_driving');
        },
      },
    );
  }
}
