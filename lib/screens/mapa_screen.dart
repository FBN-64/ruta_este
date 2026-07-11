import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- IMPORTACIÓN DE FIREBASE

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final loc.Location _locationService = loc.Location();
  LatLng? _currentLocation;

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

    try {
      final locData = await _locationService.getLocation();
      if (mounted && locData.latitude != null && locData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locData.latitude!, locData.longitude!);
        });
        _mapController.move(_currentLocation!, 16.0);
      }
    } catch (e) {
      debugPrint("Error: $e");
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
    } else {
      _iniciarGPS();
    }
  }

  // ==========================================
  // FUNCIÓN PARA MOSTRAR EL MODAL DEL BUS
  // ==========================================
  void _mostrarDetalleBus(Map<String, dynamic> bus) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                    )
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(bus['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: bus['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                          bus['estado'],
                          style: TextStyle(color: bus['color'], fontWeight: FontWeight.bold, fontSize: 10)
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(bus['ruta'], style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _buildInfoCard('ACTUALIZADO', bus['tiempo'])),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfoCard('CAPACIDAD', bus['capacidad'])),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFFF97316)),
                      const SizedBox(width: 8),
                      Text(
                        'Tiempo estimado: ${bus['tiempo_estimado']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  void _mostrarLeyenda() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                    )
                ),
                const SizedBox(height: 24),
                const Text('Leyenda del Mapa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 16),

                _buildLeyendaItem(color: Colors.blue, icon: Icons.my_location, titulo: 'Tu ubicación', subtitulo: 'Dónde te encuentras ahora'),
                const SizedBox(height: 12),
                _buildLeyendaItem(color: const Color(0xFF10B981), icon: Icons.directions_bus, titulo: 'Asientos libres', subtitulo: 'Hay espacio para sentarse'),
                const SizedBox(height: 12),
                _buildLeyendaItem(color: const Color(0xFFF97316), icon: Icons.directions_bus, titulo: 'Pocos sitios', subtitulo: 'Gente parada, pero se puede subir'),
                const SizedBox(height: 12),
                _buildLeyendaItem(color: const Color(0xFFEF4444), icon: Icons.directions_bus, titulo: 'Totalmente lleno', subtitulo: 'No se detiene o no entra nadie más'),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
    );
  }

  Widget _buildLeyendaItem({required Color color, required IconData icon, required String titulo, required String subtitulo}) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(subtitulo, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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

            // ==========================================
            // MAGIA DE FIREBASE: STREAMBUILDER EN TIEMPO REAL
            // ==========================================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('buses_activos').snapshots(),
              builder: (context, snapshot) {

                // Si aún está cargando la base de datos o hubo un error
                if (!snapshot.hasData) {
                  return const MarkerLayer(markers: []);
                }

                // Transformamos los datos de la nube en Marcadores de mapa
                final marcadoresDeBuses = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final geoPoint = data['posicion'] as GeoPoint?;

                  if (geoPoint == null) return null; // Evitar errores si no hay GPS

                  final posicionDelBus = LatLng(geoPoint.latitude, geoPoint.longitude);
                  final int colorHex = data['color'] ?? 0xFF10B981; // Verde por defecto

                  return Marker(
                    point: posicionDelBus,
                    width: 50, height: 50,
                    child: GestureDetector(
                      onTap: () {
                        // Preparamos los datos para que el modal los muestre
                        final busData = {
                          'titulo': data['titulo'] ?? 'Bus Desconocido',
                          'ruta': data['ruta'] ?? 'Ruta Carretera Central',
                          'estado': data['estado'] ?? 'EN RUTA',
                          'capacidad': data['capacidad'] ?? 'Desconocido',
                          'tiempo_estimado': data['tiempo_estimado'] ?? 'Calculando...',
                          'tiempo': 'En vivo',
                          'color': Color(colorHex),
                        };
                        _mostrarDetalleBus(busData);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(colorHex),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))]
                        ),
                        child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                      ),
                    ),
                  );
                }).whereType<Marker>().toList(); // .whereType filtra cualquier error nulo

                // Agregamos siempre el marcador del pasajero al final para que se vea
                if (_currentLocation != null) {
                  marcadoresDeBuses.add(
                    Marker(
                      point: _currentLocation!,
                      width: 60, height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.3), shape: BoxShape.circle)),
                          Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3))),
                        ],
                      ),
                    ),
                  );
                }

                // Devolvemos la capa con todos los buses + tu ubicación
                return MarkerLayer(markers: marcadoresDeBuses);
              },
            ),
          ],
        ),

        Positioned(
          top: 16, right: 16,
          child: Column(
            children: [
              _buildMapControlButton(
                icon: Icons.near_me_outlined,
                onPressed: _centrarUbicacion,
              ),
              const SizedBox(height: 12),
              _buildMapControlButton(
                icon: Icons.info_outline,
                onPressed: _mostrarLeyenda,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))]),
      child: IconButton(icon: Icon(icon, color: Colors.grey[700]), onPressed: onPressed),
    );
  }
}