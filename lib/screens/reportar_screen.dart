import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Para saber quién es el pasajero

class ReportarScreen extends StatefulWidget {
  const ReportarScreen({super.key});

  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  int _faseReporte = 0;
  String _reporteSeleccionado = '';

  String? _busSeleccionadoId;
  String? _busSeleccionadoTitulo;

  void _enviarReporte(String titulo, String capacidad, int colorHex) async {
    if (_busSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un bus de la lista primero.'), backgroundColor: Colors.redAccent)
      );
      return;
    }

    setState(() {
      _reporteSeleccionado = titulo;
      _faseReporte = 1;
    });

    try {
      // 1. Actualizamos el estado del bus en el mapa
      await FirebaseFirestore.instance.collection('buses_activos').doc(_busSeleccionadoId).update({
        'estado': titulo,
        'capacidad': capacidad,
        'color': colorHex,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      });

      // 2. Leemos la memoria del celular para saber quién es el pasajero
      final prefs = await SharedPreferences.getInstance();
      final correoPasajero = prefs.getString('correo_usuario') ?? 'anonimo';

      // 3. Guardamos el historial del reporte
      await FirebaseFirestore.instance.collection('reportes').add({
        'bus_id': _busSeleccionadoId,
        'bus_titulo': _busSeleccionadoTitulo,
        'estado_reportado': titulo,
        'usuario_correo': correoPasajero,
        'fecha_hora': FieldValue.serverTimestamp(),
      });

      // 4. MAGIA DE COMUNIDAD: ¡Le sumamos 10 puntos al pasajero!
      if (correoPasajero != 'anonimo') {
        await FirebaseFirestore.instance.collection('usuarios').doc(correoPasajero).update({
          'puntos': FieldValue.increment(10) // <-- Esto suma +10 en Firebase automáticamente
        });
      }

      if (mounted) {
        setState(() {
          _faseReporte = 2;
        });
      }
    } catch (e) {
      debugPrint("Error al enviar reporte: $e");
      if (mounted) {
        setState(() => _faseReporte = 0);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hubo un error de conexión.'), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  void _reiniciarFlujo() {
    setState(() {
      _faseReporte = 0;
      _reporteSeleccionado = '';
      _busSeleccionadoId = null;
      _busSeleccionadoTitulo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0),
        child: _construirVistaActual(),
      ),
    );
  }

  Widget _construirVistaActual() {
    if (_faseReporte == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFB923C)),
            const SizedBox(height: 30),
            const Text('Enviando...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text('Transmitiendo tu reporte\na la comunidad', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    } else if (_faseReporte == 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 24),
            const Text('¡Reporte exitoso!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Text('+10 Puntos de Viajero', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFB923C))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Detalles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(_busSeleccionadoTitulo ?? 'Bus en ruta', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Estado: $_reporteSeleccionado', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _reiniciarFlujo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Reportar otro bus', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Cómo viene el bus?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Text('Tu reporte ayuda a miles de estudiantes a decidir su viaje.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 24),

        const Text('¿Qué bus estás viendo?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('buses_activos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final buses = snapshot.data!.docs;

              if (buses.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: const Text('No hay buses transmitiendo su GPS ahora mismo.', style: TextStyle(color: Colors.grey)),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Selecciona un bus...'),
                    value: _busSeleccionadoId,
                    items: buses.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(data['titulo'] ?? 'Bus Desconocido'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _busSeleccionadoId = value;
                        final busDoc = buses.firstWhere((b) => b.id == value);
                        _busSeleccionadoTitulo = (busDoc.data() as Map<String, dynamic>)['titulo'];
                      });
                    },
                  ),
                ),
              );
            }
        ),

        const SizedBox(height: 24),

        _buildReportCard(color: const Color(0xFF10B981), icon: Icons.people_outline, title: 'Asientos libres', subtitle: 'Hay espacio para sentarse', colorHex: 0xFF10B981),
        const SizedBox(height: 16),
        _buildReportCard(color: const Color(0xFFF97316), icon: Icons.people_outline, title: 'Pocos sitios', subtitle: 'Gente parada, pero se puede subir', colorHex: 0xFFF97316),
        const SizedBox(height: 16),
        _buildReportCard(color: const Color(0xFFEF4444), icon: Icons.warning_amber_rounded, title: 'Totalmente lleno', subtitle: 'No se detiene o no entra nadie más', colorHex: 0xFFEF4444),
        const Spacer(),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFEDD5))),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle), child: const Icon(Icons.people, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Text('Dato: El 80% de los reportes en esta zona dicen que el bus está lleno.', style: TextStyle(color: Color(0xFF9A3412), fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildReportCard({required Color color, required IconData icon, required String title, required String subtitle, required int colorHex}) {
    return GestureDetector(
      onTap: () => _enviarReporte(title, subtitle, colorHex),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
        ]),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}