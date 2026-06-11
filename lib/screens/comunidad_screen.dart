import 'package:flutter/material.dart';

class ComunidadScreen extends StatelessWidget {
  const ComunidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comunidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text('Cuidándonos en la Carretera Central', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(Icons.workspace_premium, color: Color(0xFFF97316), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TU IMPACTO', style: TextStyle(color: Color(0xFFF97316), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Level 4 ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Ruta-Master', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatBox('REPORTES', '128'),
                    const SizedBox(width: 12),
                    _buildStatBox('AHORRO TIEMPO', '14h'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text('Top Colaboradores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),

          _buildTopUserRow(rank: 1, name: 'Carlos M.', points: '2,450 pts', isFirst: true),
          _buildTopUserRow(rank: 2, name: 'Andrea L.', points: '2,120 pts', isFirst: false),
          _buildTopUserRow(rank: 3, name: 'Juan P.', points: '1,980 pts', isFirst: false),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUserRow({required int rank, required String name, required String points, required bool isFirst}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('#$rank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isFirst ? const Color(0xFFF97316) : Colors.grey[400])),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))),
          Text(points, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ],
      ),
    );
  }
}