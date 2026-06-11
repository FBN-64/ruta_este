import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importamos las pantallas
import 'screens/login_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/reportar_screen.dart';
import 'screens/horarios_screen.dart';
import 'screens/comunidad_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
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
      // Si estamos logueados, vamos directamente al mapa, si no, al Login
      home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
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