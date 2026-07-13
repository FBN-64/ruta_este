import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- NUEVO: Para la base de datos
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

  bool _isTransmitting = false;



  @override
  void initState() {
    super.initState();
    _iniciarGPS();
  }

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

    // NUEVO: Configuramos el GPS para que se actualice cada 5 segundos o cada 5 metros
    // Esto evita saturar los servidores de Firebase
    await _locationService.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 5000,
      distanceFilter: 5,
    );

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

    // ESCUCHAMOS EL MOVIMIENTO DEL CONDUCTOR
    _locationService.onLocationChanged.listen((locData) {
      if (mounted && locData.latitude != null && locData.longitude != null) {
        final nuevaPosicion = LatLng(locData.latitude!, locData.longitude!);

        setState(() {
          _currentLocation = nuevaPosicion;
        });

        // MAGIA: Si está transmitiendo, mandamos esta nueva posición a la nube
        if (_isTransmitting) {
          _actualizarUbicacionEnFirestore(nuevaPosicion);
        }
      }
    });
  }

  // ==========================================
  // FUNCIONES DE FIREBASE CORREGIDAS
  // ==========================================

  Future<void> _actualizarUbicacionEnFirestore(LatLng posicion) async {
    // Pedimos el usuario justo en este momento
    final conductorActual = FirebaseAuth.instance.currentUser;

    if (conductorActual == null) {
      debugPrint("⛔ ERROR: Firebase Auth aún no carga al usuario.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('buses_activos').doc(conductorActual.uid).set({
        'id_conductor': conductorActual.uid,
        'titulo': 'Bus ${conductorActual.email?.split('@').first ?? 'Activo'}',
        'ruta': 'Ruta: Carretera Central',
        'estado': 'ASIENTOS LIBRES',
        'capacidad': 'Asientos libres',
        'tiempo_estimado': 'En camino',
        'color': 0xFF10B981,
        'posicion': GeoPoint(posicion.latitude, posicion.longitude),
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ DATO SUBIDO A FIREBASE CORRECTAMENTE");
    } catch (e) {
      debugPrint("⛔ Error subiendo a Firestore: $e");
    }
  }

  Future<void> _eliminarBusDeFirestore() async {
    final conductorActual = FirebaseAuth.instance.currentUser;
    if (conductorActual == null) return;

    try {
      await FirebaseFirestore.instance.collection('buses_activos').doc(conductorActual.uid).delete();
      debugPrint("🗑️ BUS ELIMINADO DE FIREBASE");
    } catch (e) {
      debugPrint("⛔ Error eliminando de Firestore: $e");
    }
  }

  // ==========================================

  void _centrarUbicacion() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    }
  }

  void _cerrarSesion() async {
    // Si estaba transmitiendo, borramos su bus antes de salir
    if (_isTransmitting) {
      await _eliminarBusDeFirestore();
    }

    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  void _toggleTransmision() {
    setState(() {
      _isTransmitting = !_isTransmitting;
    });

    if (_isTransmitting) {
      if (_currentLocation != null) {
        _actualizarUbicacionEnFirestore(_currentLocation!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transmisión iniciada. Los pasajeros ahora pueden verte.'), backgroundColor: Colors.green),
      );
    } else {
      _eliminarBusDeFirestore();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transmisión detenida. Ya no apareces en el mapa.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA DE FONDO
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

              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 60, height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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

          // 2. BOTONES SUPERIORES FLOTANTES
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                    child: IconButton(icon: const Icon(Icons.logout, color: Colors.black87), onPressed: _cerrarSesion),
                  ),
                ],
              ),
            ),
          ),

          // BOTÓN CENTRAR GPS
          Positioned(
            bottom: 180, right: 16,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: IconButton(icon: Icon(Icons.near_me_outlined, color: Colors.grey[700]), onPressed: _centrarUbicacion),
            ),
          ),

          // 3. PANEL INFERIOR (CONTROLES)
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