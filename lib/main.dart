import 'package:flutter/material.dart';
import 'package:ruta_este/screens/panel_conductor_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === 1. IMPORTACIONES DE FIREBASE ===
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/reportar_screen.dart';
import 'screens/horarios_screen.dart';
import 'screens/comunidad_screen.dart';

void main() async {
  // Asegura que los widgets nativos estén listos antes de llamar a Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // === 2. ENCENDEMOS LA CONEXIÓN CON LA NUBE ===
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("🔥 Firebase conectado exitosamente 🔥");
  } catch (e) {
    debugPrint("Error conectando Firebase: $e");
  }

  // =======================================================
  // MODO PRUEBAS: Borramos la memoria cada vez que se abre
  // =======================================================
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // <-- ESTA ES LA LÍNEA MÁGICA QUE BORRA TU SESIÓN ANTERIOR

  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(BusCheckApp(isLoggedIn: isLoggedIn));
}

class BusCheckApp extends StatelessWidget {
  final bool isLoggedIn;

  const BusCheckApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruta Este',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primaryColor: const Color(0xFFFB923C),
        useMaterial3: true,
      ),
      home: _pantallaInicial(),
    );
  }

  // Función que decide a dónde llevarte según tu rol
  Widget _pantallaInicial() {
    if (!isLoggedIn) return const LoginScreen();

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final rol = snapshot.data!.getString('rol') ?? 'pasajero';
        if (rol == 'conductor') {
          return const PanelConductorScreen();
        } else {
          return const MainNavigationScreen();
        }
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Ruta ', style: TextStyle(color: Colors.black)),
                  TextSpan(text: 'Este', style: TextStyle(color: Color(0xFFFB923C))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 10),
                  const SizedBox(width: 4),
                  Text('EN VIVO', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const <Widget>[
          MapaScreen(),
          ReportarScreen(),
          HorariosScreen(),
          ComunidadScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFB923C),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'MAPA', activeIcon: Icon(Icons.map)),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'REPORTAR', activeIcon: Icon(Icons.chat_bubble)),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'HORARIOS', activeIcon: Icon(Icons.access_time_filled)),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'COMUNIDAD', activeIcon: Icon(Icons.people)),
        ],
      ),
    );
  }
}