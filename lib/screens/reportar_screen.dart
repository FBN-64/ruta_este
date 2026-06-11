import 'package:flutter/material.dart';

class ReportarScreen extends StatefulWidget {
  const ReportarScreen({super.key});

  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  int _faseReporte = 0;
  String _reporteSeleccionado = '';

  void _enviarReporte(String titulo) async {
    setState(() {
      _reporteSeleccionado = titulo;
      _faseReporte = 1;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _faseReporte = 2;
      });
    }
  }

  void _reiniciarFlujo() {
    setState(() {
      _faseReporte = 0;
      _reporteSeleccionado = '';
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
            const Text('Loading...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text('Transmitting your report\nto the community', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
            const Text('Report successful!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Ruta Este - Chosica - Lima', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Selected: $_reporteSeleccionado', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              child: const Text('Start Over', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 30),

        _buildReportCard(color: const Color(0xFF10B981), icon: Icons.people_outline, title: 'Asientos libres', subtitle: 'Hay espacio para sentarse'),
        const SizedBox(height: 16),
        _buildReportCard(color: const Color(0xFFF97316), icon: Icons.people_outline, title: 'Pocos sitios', subtitle: 'Gente parada, pero se puede subir'),
        const SizedBox(height: 16),
        _buildReportCard(color: const Color(0xFFEF4444), icon: Icons.warning_amber_rounded, title: 'Totalmente lleno', subtitle: 'No se detiene o no entra nadie más'),
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

  Widget _buildReportCard({required Color color, required IconData icon, required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () => _enviarReporte(title),
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