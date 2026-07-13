import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComunidadScreen extends StatefulWidget {
  const ComunidadScreen({super.key});

  @override
  State<ComunidadScreen> createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  String _miCorreo = '';

  @override
  void initState() {
    super.initState();
    _cargarMiCorreo();
  }

  // Leemos de la memoria quiénes somos para resaltar nuestro nombre en el ranking
  Future<void> _cargarMiCorreo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _miCorreo = prefs.getString('correo_usuario') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ranking de Viajeros', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Text('Los estudiantes que más ayudan a la comunidad.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),

          // LISTA EN TIEMPO REAL DESDE FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 👇 AQUÍ ESTÁ EL CAMBIO: Quitamos el .where()
              stream: FirebaseFirestore.instance.collection('usuarios')
                  .orderBy('puntos', descending: true) // Solo dejamos el ordenamiento
                  .snapshots(),
              builder: (context, snapshot) {

                // Agregamos esto para ver si Firebase nos manda algún otro error
                if (snapshot.hasError) {
                  return Center(child: Text('Error de Firebase: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFB923C)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aún no hay viajeros en el ranking.'));
                }

                final usuarios = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final data = usuarios[index].data() as Map<String, dynamic>;

                    final esMiPerfil = data['correo'] == _miCorreo;
                    final puntos = data['puntos'] ?? 0;
                    final alias = data['alias'] ?? 'Usuario';

                    return _buildRankingCard(
                      posicion: index + 1,
                      alias: alias,
                      puntos: puntos,
                      esMiPerfil: esMiPerfil,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard({required int posicion, required String alias, required int puntos, required bool esMiPerfil}) {
    // Colores especiales de medallas para el Top 3
    Color colorMedalla;
    if (posicion == 1) colorMedalla = const Color(0xFFFFD700); // Oro
    else if (posicion == 2) colorMedalla = const Color(0xFFC0C0C0); // Plata
    else if (posicion == 3) colorMedalla = const Color(0xFFCD7F32); // Bronce
    else colorMedalla = Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esMiPerfil ? const Color(0xFFFFF7ED) : Colors.grey[50], // Resalta tu perfil en naranja claro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: esMiPerfil ? const Color(0xFFFB923C) : Colors.grey[200]!, width: esMiPerfil ? 2 : 1),
      ),
      child: Row(
        children: [
          // Número y Medalla
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colorMedalla.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Text('#$posicion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: posicion <= 3 ? colorMedalla : Colors.grey[700])),
          ),
          const SizedBox(width: 16),

          // Nombre y etiqueta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alias, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: esMiPerfil ? const Color(0xFF9A3412) : Colors.black)),
                if (esMiPerfil) const Text('¡Este eres tú!', style: TextStyle(fontSize: 12, color: Color(0xFFFB923C), fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Puntos
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFB923C), size: 20),
              const SizedBox(width: 4),
              Text('$puntos pts', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}