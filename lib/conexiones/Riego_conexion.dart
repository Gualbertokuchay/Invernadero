import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class API {
  static const List<String> hostConnect = [
    "http://alumnostics.utpproyectos.com.mx/serveinver/ApiDispInt.php?id=1",
    //"http://192.168.3.64/Conexion/conexion.php"
  ];
}

class SistemaRiego extends StatefulWidget {
  const SistemaRiego({Key? key}) : super(key: key);

  @override
  State<SistemaRiego> createState() => _ConexionSQLState();
}

class _ConexionSQLState extends State<SistemaRiego> {
  late MqttServerClient client;
  bool isConnected = false;
  List<Map<String, dynamic>> _data = [];
  List<bool> _isBombaOnList = [];

  @override
  void initState() {
    super.initState();
    client = MqttServerClient('broker.emqx.io', 'mqttx_eb5cefaf');
    client.port = 1883;
    client.logging(on: true);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.pongCallback = _pong;
    // No se utiliza seguridad TLS
    client.secure = false;

    final connMessage = MqttConnectMessage()
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    // Agregar el identificador de cliente
    client.clientIdentifier = 'myClientId';

    // Conectar automáticamente al iniciar la pantalla
    connect();

    fetchDataFromAPI();
  }

  void _onConnected() {
    setState(() {
      isConnected = true;
    });
    print('Connected to MQTT broker');
  }

  void _onDisconnected() {
    setState(() {
      isConnected = false;
    });
    print('Disconnected from MQTT broker');
  }

  void _pong() {
    print('Ping response client callback invoked');
  }

  Future<void> connect() async {
    try {
      await client.connect();
      print('Connected to MQTT broker');
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message: $payload from topic: ${c[0].topic}>');
    });
  }

  void publishMessage(String message) {
    if (isConnected) {
      //invernadero/a
      final topic = 'sistemaderiego';
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message: $message');
    }
  }

  void toggleBomba(int index, bool newValue) {
    _isBombaOnList[index] = newValue;
    String message = newValue
        ? '1'
        : '0'; // Aquí deberías ajustar el mensaje según tus necesidades
    publishMessage(message);
    setState(() {});
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  Future<void> fetchDataFromAPI() async {
    final List<Future<http.Response>> responses =
        API.hostConnect.map((url) => http.get(Uri.parse(url))).toList();

    try {
      final List<http.Response> httpResponses = await Future.wait(responses);

      final List<Map<String, dynamic>> allData = [];

      for (final http.Response response in httpResponses) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is List<dynamic>) {
            allData.addAll(List<Map<String, dynamic>>.from(data));
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            final dataList = data['data'];
            if (dataList is List<dynamic>) {
              allData.addAll(List<Map<String, dynamic>>.from(dataList));
            } else {
              print(
                  'Error de conversion de JSON data. La clave "data" no contiene una lista.');
            }
          } else {
            print(
                'Error de conversion de JSON data. Formato inesperado del JSON.');
          }
        } else {
          print('Error in GET request: ${response.statusCode}');
        }
      }

      setState(() {
        _data = allData;
        _isBombaOnList = List.filled(_data.length, false);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: const Text("Riego"),
        backgroundColor: Colors.white,
        centerTitle: true, // Centrar el título en el AppBar
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _data.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columnas
                  childAspectRatio: 1.0, // Relación de aspecto cuadrada
                ),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Aumentar el espacio entre tarjetas
                    child: Card(
                      // Tarjeta
                      elevation: 15.0, // Elevación de la tarjeta
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16.0), // Bordes redondeados
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Espacio interno de la tarjeta
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centrar el contenido verticalmente
                          children: [
                            Icon(
                              Icons
                                  .water, // Puedes cambiar esto por el ícono que desees
                              size: 150.0, // Tamaño del ícono
                              color: Colors.blue, // Color del ícono
                            ),
                            SizedBox(
                                height:
                                    0.0), // Espacio entre el ícono y el texto
                            _buildCard(index),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final item = _data[index];
    final isBombaOn = _isBombaOnList[index];

    return Column(
      children: [
        Switch(
          value: isBombaOn,
          onChanged: (value) => toggleBomba(index, value),
        ),
        SizedBox(height: 8.0), // Espacio entre el switch y el primer texto
        Text(
          "Modelo: ${item['modelo']}",
          style: TextStyle(
            fontSize: 40.0, // Tamaño de fuente aumentado
            color: Colors.black, // Texto en negro
          ),
        ),
        Text(
          "Descripción: ${item['descripcion']}",
          style: TextStyle(
            fontSize: 25.0, // Tamaño de fuente aumentado
            color: Colors.black, // Texto en negro
          ),
        ),
      ],
    );
  }
}
