import 'package:flutter/material.dart';

class HorariosScreen extends StatelessWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 10.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Horarios y Rutas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  Text('Planifica tu viaje por la Carretera Central.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 24),

                  // TARJETA DE HORARIO GENERAL
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937), // Azul muy oscuro casi negro
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Color(0xFFFB923C), size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Horario de Operación', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Lunes a Domingo\n5:00 AM - 11:30 PM', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Paraderos Principales (Hacia Lima)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // LISTA DE PARADEROS (TIMELINE)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildParadero(tiempo: '0 min', titulo: 'Chosica (Parque Echenique)', subtitulo: 'Paradero Inicial', isFirst: true),
                _buildParadero(tiempo: '25 min', titulo: 'Entrada de Huaycán', subtitulo: 'Paradero Intermedio'),
                _buildParadero(tiempo: '45 min', titulo: 'UTP Sede Ate', subtitulo: 'Zona Universitaria / Real Plaza'),
                _buildParadero(tiempo: '60 min', titulo: 'Óvalo Santa Anita', subtitulo: 'Conexión Evitamiento'),
                _buildParadero(tiempo: '90 min', titulo: 'Centro de Lima (Grau)', subtitulo: 'Paradero Final', isLast: true),
              ]),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // WIDGET PERSONALIZADO PARA CREAR LA "LÍNEA DE TIEMPO"
  Widget _buildParadero({required String tiempo, required String titulo, required String subtitulo, bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // 1. DIBUJO DE LA LÍNEA Y EL CÍRCULO
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 3, height: 20,
                  color: isFirst ? Colors.transparent : const Color(0xFFFB923C),
                ),
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFB923C), width: 4),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 3,
                    color: isLast ? Colors.transparent : const Color(0xFFFB923C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 2. CAJA DE TEXTO DEL PARADERO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(subtitulo, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFB923C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(tiempo, style: const TextStyle(color: Color(0xFF9A3412), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}