import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- AGREGADO PARA FIREBASE AUTH
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'panel_conductor_screen.dart'; // <-- AGREGADO PARA LA NUEVA RUTA

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Nuevo para la contraseña

  bool _isConductor = false; // Interruptor para cambiar la vista
  bool _isLoading = false;   // Para mostrar un círculo de carga mientras Firebase piensa

  // ==========================================
  // INGRESO PARA PASAJEROS (Sin contraseña)
  // ==========================================
  void _ingresarPasajero() async {
    final correo = _correoController.text.trim();
    final alias = _aliasController.text.trim();

    if (correo.isEmpty || !correo.contains('@') || alias.isEmpty) {
      _mostrarError('Por favor, ingresa un correo válido y un alias.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Guardamos el perfil en Firebase usando su correo como ID
      await FirebaseFirestore.instance.collection('usuarios').doc(correo).set({
        'correo': correo,
        'alias': alias,
        'rol': 'pasajero',
      }, SetOptions(merge: true)); // 'merge: true' evita que se borre si ya existía

      // 2. Le asignamos 0 puntos iniciales solo si es un usuario nuevo
      final docSnapshot = await FirebaseFirestore.instance.collection('usuarios').doc(correo).get();
      if (!docSnapshot.data()!.containsKey('puntos')) {
        await FirebaseFirestore.instance.collection('usuarios').doc(correo).update({'puntos': 0});
      }

      // 3. Guardamos la sesión en el celular
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('rol', 'pasajero');
      await prefs.setString('correo_usuario', correo); // <-- Recordamos quién es

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
      }
    } catch (e) {
      _mostrarError('Error al conectar con la base de datos.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // INGRESO PARA CONDUCTORES (Con Firebase Auth)
  // ==========================================
  void _ingresarConductor() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || !correo.contains('@') || password.isEmpty) {
      _mostrarError('Por favor, ingresa tu correo y contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Intentamos iniciar sesión en los servidores de Google
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      // Si tiene éxito, guardamos el estado en el celular
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('rol', 'conductor'); // <-- GUARDAMOS EL ROL

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PanelConductorScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores si la contraseña es incorrecta o el usuario no existe
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _mostrarError('Correo o contraseña incorrectos.');
      } else {
        _mostrarError('Error de servidor: ${e.message}');
      }
    } catch (e) {
      _mostrarError('Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BOTÓN PARA CAMBIAR DE ROL EN LA ESQUINA
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isConductor = !_isConductor;
                      // Limpiamos los campos al cambiar de vista
                      _correoController.clear();
                      _aliasController.clear();
                      _passwordController.clear();
                    });
                  },
                  icon: Icon(_isConductor ? Icons.directions_walk : Icons.directions_bus, color: const Color(0xFFFB923C)),
                  label: Text(_isConductor ? 'Soy Pasajero' : 'Soy Conductor', style: const TextStyle(color: Color(0xFFFB923C), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // LOGO TIPO "R.E"
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

              // TÍTULO DINÁMICO
              Center(
                child: Text(
                  _isConductor ? 'Portal de Conductores' : 'Ruta Este',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _isConductor ? 'Inicia sesión para transmitir tu ubicación.' : 'Vincular tu cuenta nos ayuda a\nguardar tus puntos y reportes.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // CAMPO DE TEXTO: CORREO (COMÚN PARA AMBOS)
              const Text('Tu correo electrónico', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFB923C), width: 2)),
                ),
              ),
              const SizedBox(height: 20),

              // CAMPO DE TEXTO DINÁMICO (ALIAS O CONTRASEÑA)
              Text(_isConductor ? 'Tu Contraseña' : '¿Cómo te llamamos?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _isConductor ? _passwordController : _aliasController,
                obscureText: _isConductor, // Oculta el texto si es contraseña
                decoration: InputDecoration(
                  hintText: _isConductor ? '******' : 'Ej. RutaMaster, Viajero22...',
                  prefixIcon: Icon(_isConductor ? Icons.lock_outline : Icons.alternate_email, color: const Color(0xFFFB923C)),
                  filled: true, fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFB923C), width: 2)),
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN PRINCIPAL
              ElevatedButton(
                onPressed: _isLoading ? null : (_isConductor ? _ingresarConductor : _ingresarPasajero),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                    _isConductor ? 'Iniciar Sesión (Conductor)' : 'Vincular y Continuar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}