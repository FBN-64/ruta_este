import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- IMPORTACIÓN PARA LA MEMORIA LOCAL
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();

  void _ingresar() async { // <-- AGREGAMOS ASYNC PARA MANEJAR LA MEMORIA
    final correo = _correoController.text.trim();
    final alias = _aliasController.text.trim();

    // 1. Validamos que el correo no esté vacío y tenga un formato básico
    if (correo.isEmpty || !correo.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un correo válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Validamos que el alias no esté vacío
    if (alias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, elige un alias para continuar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 3. Guardando el inicio de sesión en el dispositivo
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      // Guardamos los datos para cambios futuros
      await prefs.setString('userEmail', correo);
      await prefs.setString('userAlias', alias);
    } catch (e) {
      debugPrint("Error guardando datos locales: $e");
    }

    // Si todo está bien, destruimos esta pantalla y pasamos al mapa
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo en Texto
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, letterSpacing: -2),
                    children: [
                      TextSpan(text: 'R.', style: TextStyle(color: Colors.black)),
                      TextSpan(text: 'E', style: TextStyle(color: Color(0xFFFB923C))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Titulo y subtitulo
              const Center(
                child: Text(
                  'Ruta Este',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Vincular tu cuenta nos ayuda a\nguardar tus puntos y reportes.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Parte del correo
              const Text(
                'Tu correo electrónico',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'ejemplo@gmail.com',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFB923C), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CAMPO DE TEXTO PARA EL ALIAS
              const Text(
                '¿Cómo te llamamos?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _aliasController,
                decoration: InputDecoration(
                  hintText: 'Ej. RutaMaster, Viajero22...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFFFB923C)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFB923C), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN PRINCIPAL
              ElevatedButton(
                onPressed: _ingresar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF1F2937).withValues(alpha: 0.3),
                ),
                child: const Text(
                    'Vincular y Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Al continuar, aceptas nuestros\nTérminos de Servicio y Privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}