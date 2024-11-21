import 'package:flutter/material.dart';
import 'package:zean/game/assets.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recomendacion.dart'; // Asegúrate de importar el modelo

 class Recomendacion {
    final int id;
    final String nombre;
    final String descripcion;
    final int rangomin;
    final int rangomax;
    final String tipo;

    Recomendacion({
      required this.id,
      required this.nombre,
      required this.descripcion,
      required this.rangomin,
      required this.rangomax,
      required this.tipo,
    });

    // Método para convertir el JSON en un objeto Recomendacion
    factory Recomendacion.fromJson(Map<String, dynamic> json) {
      return Recomendacion(
        id: json['rec_id'] as int,
        nombre: json['rec_nombre'] as String,
        descripcion: json['rec_descripcion'] as String,
        rangomin: json['rec_rangomin'] as int,
        rangomax: json['rec_rangomax'] as int,
        tipo: json['rec_tipo'] as String,
      );
    }
  }
  
class RecomendacionPage extends StatelessWidget {
  final int id;

  const RecomendacionPage({Key? key, required this.id}) : super(key: key);

 


Future<List<Recomendacion>> fetchRecomendaciones() async {
  final url = Uri.parse('http://3.92.181.59/salud/api/v1/recomendaciones/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Convierte la respuesta en una lista de objetos Recomendacion
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Recomendacion.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las recomendaciones');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Recomendaciones",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Recomendacion>>(
        future: fetchRecomendaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final recomendaciones = snapshot.data!;
            final recomendacion = recomendaciones.firstWhere(
                (rec) => rec.id == id,
                orElse: () => Recomendacion(
                    id: 0,
                    nombre: 'No encontrado',
                    descripcion: 'No hay descripción disponible',
                    rangomin: 0,
                    rangomax: 0,
                    tipo: 'N/A'));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono y título
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal,
                            child: const Icon(Icons.star, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              recomendacion.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Descripción
                      Text(
                        recomendacion.descripcion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Rango mínimo y máximo
                      Text(
                        "Rango: ${recomendacion.rangomin} - ${recomendacion.rangomax}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tipo
                      Text(
                        "Tipo: ${recomendacion.tipo}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text("No se encontraron datos"));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: RecomendacionPage(id: 1), // Envía un ID de prueba
  ));
}
