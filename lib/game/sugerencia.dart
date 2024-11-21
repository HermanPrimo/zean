import 'package:flutter/material.dart';
import 'package:zean/game/encuesta.dart';
import 'package:zean/game/notificaciones.dart';
import 'package:zean/game/perfil.dart';
import 'package:zean/game/recomendacion.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Modelo de Recomendación
class Recomendacion {
  final int id;
  final String imagen;

  Recomendacion({
    required this.id,
    required this.imagen,
  });

  // Método para convertir el JSON en un objeto Recomendacion
  factory Recomendacion.fromJson(Map<String, dynamic> json) {
    return Recomendacion(
      id: json['rec_id'] as int,
      imagen: json['rec_imagen'] ?? 'https://via.placeholder.com/400x250.png?text=No+Image+Available',
    );
  }
}

// Función para obtener datos desde la API
Future<List<Recomendacion>> fetchRecomendaciones() async {
  final url = Uri.parse('http://3.92.181.59/salud/api/v1/recomendaciones/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Decodifica la respuesta para respetar UTF-8
    final String utf8Body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = jsonDecode(utf8Body);
    return jsonList.map((json) => Recomendacion.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las recomendaciones');
  }
}

class SugerenciaPage extends StatelessWidget {
  const SugerenciaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600; // Determina si es tablet o no.

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              CustomHeader(
                title: "SUGERENCIAS",
                onAvatarTap: () {
                  // Navegar a la página de perfil
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerfilPage(),
                    ),
                  );
                },
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificacionesPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: isTablet ? 30 : 20),

              // Sugerencias (Carrusel de imágenes dinámico)
              FutureBuilder<List<Recomendacion>>(
                future: fetchRecomendaciones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final recomendaciones = snapshot.data!;
                    return SizedBox(
                      height: isTablet ? 150 : 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recomendaciones.length,
                        itemBuilder: (context, index) {
                          final recomendacion = recomendaciones[index];
                          return _buildSuggestionImage(
                            recomendacion.imagen,
                            recomendacion.id,
                            context,
                            isTablet,
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: Text("No se encontraron datos"));
                  }
                },
              ),
              SizedBox(height: isTablet ? 30 : 20),

              // Encuestas
              Text(
                "ENCUESTAS",
                style: TextStyle(
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: isTablet ? 20 : 10),

              // Tarjetas de encuestas
              _buildSurveyCard(
                id: 1,
                title: "Experiencia de Vida con Diabetes",
                timeRemaining: "14hrs",
                context: context,
                isTablet: isTablet,
              ),
              _buildSurveyCard(
                id: 2,
                title: "Impacto de la Diabetes en la Vida Diaria",
                timeRemaining: "1d",
                context: context,
                isTablet: isTablet,
              ),
              _buildSurveyCard(
                id: 3,
                title: "Percepción y Educación sobre la Diabetes",
                timeRemaining: "1d 12hrs",
                context: context,
                isTablet: isTablet,
              ),
              _buildSurveyCard(
                id: 4,
                title: "Retos y Soluciones en el Tratamiento de la Diabetes",
                timeRemaining: "2d",
                context: context,
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionImage(
      String imagePath, int id, BuildContext context, bool isTablet) {
    return GestureDetector(
      onTap: () {
        // Navegación a la página de recomendaciones pasando el id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecomendacionPage(id: id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 16.0 : 8.0),
        width: isTablet ? 150 : 100,
        height: isTablet ? 150 : 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyCard({
    required int id,
    required String title,
    required String timeRemaining,
    required BuildContext context,
    required bool isTablet,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Texto del título y tiempo restante
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Termina en: $timeRemaining",
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Botón Responder
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Navegación a la página de encuestas pasando el id
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EncuestaPage(id: id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53746E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 14 : 12,
                ),
              ),
              child: Text(
                "Responder",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SugerenciaPage(),
  ));
}
