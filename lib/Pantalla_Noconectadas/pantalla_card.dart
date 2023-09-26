import 'package:flutter/material.dart';
import 'package:invernadero/Pantalla_Noconectadas/conexiones/Riego_conexion.dart';

import 'package:invernadero/Pantalla_Noconectadas/conexiones/Temperatura_conexion.dart';
import 'package:invernadero/Pantalla_Noconectadas/conexiones/conexion_ventiladores.dart';
import 'package:invernadero/Pantalla_Noconectadas/conexiones/Conexion_Iluminacion.dart';

Card formato_card(BuildContext context) {
  return Card(
    elevation: 5, // Añade una sombra al card
    margin: EdgeInsets.all(0.0), // Margen exterior
    color: Color.fromARGB(
        255, 245, 241, 241), // Color de fondo negro para el primer Card
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.eco,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Dispositivos Inteligentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Color de texto blanco
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildDeviceCard(
                    context,
                    Icons.lightbulb,
                    'Focos',
                    Colors.black,
                    Iluminacion(),
                  ),
                  _buildDeviceCard(
                    context,
                    Icons.ac_unit,
                    'Ventiladores',
                    Colors.black,
                    Ventilacion(),
                  ),
                  _buildDeviceCard(
                    context,
                    Icons.water,
                    'Riego',
                    Colors.black,
                    SistemaRiego(),
                  ),
                  _buildDeviceCard(
                    context,
                    Icons.thermostat,
                    'Temperatura',
                    Colors.black,
                    Sensores(),
                  ),
                  _buildDeviceCard(
                    context,
                    Icons.camera,
                    'Camaras',
                    Colors.black,
                    Ventilacion(),
                  ),
                  _buildDeviceCard(
                    context,
                    Icons.window,
                    'Persianas',
                    Colors.black,
                    Ventilacion(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Card _buildDeviceCard(BuildContext context, IconData icon, String label,
    Color iconColor, Widget destination) {
  return Card(
    elevation: 2,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destination,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: iconColor,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
