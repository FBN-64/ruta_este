import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final loc.Location _locationService = loc.Location();
  LatLng? _currentLocation;

  // DATOS SIMULADOS DE LOS BUSES (Mocks)
  final List<Map<String, dynamic>> _busesSimulados = [
    {
      'id': '1',
      'titulo': 'Chosicano A1',
      'ruta': 'Ruta: Chosica - Lima',
      'estado': 'ASIENTOS LIBRES',
      'capacidad': 'Asientos libres',
      'tiempo': 'hace 2 min',
      'tiempo_estimado': '45 min',
      'color': const Color(0xFF10B981), // Color verde
      'posicion': const LatLng(-11.941946, -76.702302),
    },
    {
      'id': '2',
      'titulo': 'La Nueva Estrella',
      'ruta': 'Ruta: Huaycán - Centro',
      'estado': 'POCOS SITIOS',
      'capacidad': 'Gente parada',
      'tiempo': 'hace 5 min',
      'tiempo_estimado': '10 min',
      'color': const Color(0xFFF97316), // Color naranja
      'posicion': const LatLng(-11.998521, -76.837169),
    },
    {
      'id': '3',
      'titulo': 'El Lorito',
      'ruta': 'Ruta: Ate - Callao',
      'estado': 'TOTALMENTE LLENO',
      'capacidad': 'No entra nadie',
      'tiempo': 'hace 1 min',
      'tiempo_estimado': '20 min',
      'color': const Color(0xFFEF4444), // Color Rojo
      'posicion': const LatLng(-11.987678, -76.814503),
    },
  ];

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

  // FUNCIÓN PARA MOSTRAR EL MODAL (BOTTOM SHEET)
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
                // NUEVA TARJETA: TIEMPO ESTIMADO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.1), // Naranja claro
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
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9A3412) // Naranja oscuro
                        ),
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
  // FUNCIÓN PARA MOSTRAR LA LEYENDA DEL MAPA
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

            MarkerLayer(
              markers: [
                ..._busesSimulados.map((bus) => Marker(
                  point: bus['posicion'],
                  width: 50, height: 50,
                  child: GestureDetector(
                    onTap: () => _mostrarDetalleBus(bus),
                    child: Container(
                      decoration: BoxDecoration(
                          color: bus['color'],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))]
                      ),
                      child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                    ),
                  ),
                )),

                if (_currentLocation != null)
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
              ],
            )
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