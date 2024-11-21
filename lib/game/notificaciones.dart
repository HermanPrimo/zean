import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Enum para el estado de la notificación
enum EstadoNotificacion { leido, noLeido }

// Modelo de Notificación
class Notificacion {
  final int id;
  final String titulo;
  final String descripcion;
  final EstadoNotificacion estado;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
  });

  // Método para convertir el JSON en un objeto Notificación
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['avi_id'] as int,
      titulo: json['avi_nombre'] as String,
      descripcion: json['avi_descripcion'] as String,
      estado: (json['avi_estado'] as String) == 'noLeido'
          ? EstadoNotificacion.noLeido
          : EstadoNotificacion.leido,
    );
  }
}

// Función para obtener datos desde la API
Future<List<Notificacion>> fetchNotificaciones() async {
  final url = Uri.parse('http://3.92.181.59/salud/api/v1/aviso/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Decodifica la respuesta para respetar UTF-8
    final String utf8Body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = jsonDecode(utf8Body);
    return jsonList.map((json) => Notificacion.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las notificaciones');
  }
}

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Encabezado personalizado
          CustomHeader(
            title: "NOTIFICACIONES",
            onAvatarTap: () {
              Navigator.pop(context);
            },
            onNotificationTap: () {
              // Acción adicional si es necesario
            },
          ),
          const SizedBox(height: 16.0),

          // Lista de notificaciones
          Expanded(
            child: FutureBuilder<List<Notificacion>>(
              future: fetchNotificaciones(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  final notificaciones = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: notificaciones.length,
                    itemBuilder: (context, index) {
                      final notificacion = notificaciones[index];

                      // Determinar colores según el estado
                      final backgroundColor = notificacion.estado ==
                              EstadoNotificacion.noLeido
                          ? Colors.red[100]!
                          : Colors.green[100]!;
                      final iconColor = notificacion.estado ==
                              EstadoNotificacion.noLeido
                          ? Colors.red
                          : Colors.green;

                      return _buildNotificationCard(
                        context,
                        title: notificacion.titulo,
                        description: notificacion.descripcion,
                        backgroundColor: backgroundColor,
                        iconColor: iconColor,
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No se encontraron datos"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.black,
                    onPressed: () {
                      // Acción para eliminar notificación
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, size: 20),
                    color: Colors.black,
                    onPressed: () {
                      // Acción para marcar como leída
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget reutilizable para el encabezado
class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;

  const CustomHeader({
    Key? key,
    required this.title,
    required this.onAvatarTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.brown,
                size: 32,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: const Icon(
              Icons.notifications,
              color: Colors.orange,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: NotificacionesPage(),
  ));
}
