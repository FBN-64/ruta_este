import 'package:flutter/material.dart';

class HorariosScreen extends StatelessWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rutas e Intervalos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text('Basado en reportes de los últimos 15 min.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),

            TextField(
              decoration: InputDecoration(
                hintText: 'Busca tu ruta o paradero...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 24),

            _buildRouteCard(routeNumber: '5401', routeName: 'Chosica - Lima', frequency: 'Frecuencia: 3-5 min', statusText: 'FLUIDO', statusColor: const Color(0xFF10B981)),
            _buildRouteCard(routeNumber: '4502', routeName: 'Huaycán - Abancay', frequency: 'Frecuencia: 10 min', statusText: 'LENTO', statusColor: const Color(0xFFF97316)),
            _buildRouteCard(routeNumber: '4408', routeName: 'Chaclacayo - Grau', frequency: 'Frecuencia: 8 min', statusText: 'FLUIDO', statusColor: const Color(0xFF10B981)),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('¿Prefieres un Colectivo?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.send, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Hemos detectado alta demanda en Carretera Central. Los colectivos están saliendo cada 2 min desde el Puente Santa Anita.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.4)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard({required String routeNumber, required String routeName, required String frequency, required String statusText, required Color statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(routeNumber, style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(frequency, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}