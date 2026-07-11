import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class PanelConductorScreen extends StatefulWidget {
  const PanelConductorScreen({super.key});

  @override
  State<PanelConductorScreen> createState() => _PanelConductorScreenState();
}

class _PanelConductorScreenState extends State<PanelConductorScreen> {
  final MapController _mapController = MapController();
  final loc.Location _locationService = loc.Location();
  LatLng? _currentLocation;

  // Interruptor que controlará si mandamos datos a Firebase o no
  bool _isTransmitting = false;

  @override
  void initState() {
    super.initState();
    _iniciarGPS();
  }

  // Iniciamos el hardware del GPS igual que en la pantalla del pasajero
  Future<void> _iniciarGPS() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    try {
      final locData = await _locationService.getLocation();
      if (mounted && locData.latitude != null && locData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locData.latitude!, locData.longitude!);
        });
        _mapController.move(_currentLocation!, 16.0);
      }
    } catch (e) {
      debugPrint("Error obteniendo ubicación: $e");
    }

    _locationService.onLocationChanged.listen((locData) {
      if (mounted && locData.latitude != null && locData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locData.latitude!, locData.longitude!);
        });
      }
    });
  }

  void _centrarUbicacion() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    }
  }

  void _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  // Función para encender o apagar el GPS hacia la nube
  void _toggleTransmision() {
    setState(() {
      _isTransmitting = !_isTransmitting;
    });

    if (_isTransmitting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transmisión iniciada. Los pasajeros ahora pueden verte.'), backgroundColor: Colors.green),
      );
      // Aquí agregaremos la lógica para subir a Firestore más adelante
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transmisión detenida. Ya no apareces en el mapa.'), backgroundColor: Colors.redAccent),
      );
      // Aquí agregaremos la lógica para borrar el bus de Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // 1. EL MAPA DE FONDO
          // ==========================================
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-11.986812, -76.852423),
              initialZoom: 15.0,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fabian.rutaeste',
              ),

              // El marcador de ubicación del conductor
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 60, height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cambia de color a Verde cuando transmite y Azul cuando no
                          Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: _isTransmitting ? Colors.green.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3),
                                  shape: BoxShape.circle
                              )
                          ),
                          Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                  color: _isTransmitting ? Colors.green : Colors.blue,
                                  shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ==========================================
          // 2. BOTONES SUPERIORES FLOTANTES
          // ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tarjeta indicadora de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_bus, color: _isTransmitting ? Colors.green : Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isTransmitting ? 'EN RUTA' : 'FUERA DE SERVICIO',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _isTransmitting ? Colors.green : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Botón de Cerrar Sesión
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                    child: IconButton(icon: const Icon(Icons.logout, color: Colors.black87), onPressed: _cerrarSesion),
                  ),
                ],
              ),
            ),
          ),

          // Botón para centrar GPS
          Positioned(
            bottom: 180, right: 16,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: IconButton(icon: Icon(Icons.near_me_outlined, color: Colors.grey[700]), onPressed: _centrarUbicacion),
            ),
          ),

          // ==========================================
          // 3. PANEL INFERIOR (CONTROLES DE TRANSMISIÓN)
          // ==========================================
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _isTransmitting ? Colors.green.withValues(alpha: 0.1) : const Color(0xFFFB923C).withValues(alpha: 0.1),
                            shape: BoxShape.circle
                        ),
                        child: Icon(_isTransmitting ? Icons.satellite_alt : Icons.gps_off, color: _isTransmitting ? Colors.green : const Color(0xFFFB923C)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _isTransmitting ? 'Transmitiendo GPS' : 'Ubicación oculta',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            Text(
                                _isTransmitting ? 'Los pasajeros ven tu posición en vivo.' : 'Inicia tu ruta para empezar a compartir.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // BOTÓN GIGANTE
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _toggleTransmision,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTransmitting ? Colors.redAccent : const Color(0xFFFB923C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isTransmitting ? 'DETENER RUTA' : 'INICIAR TRANSMISIÓN',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}