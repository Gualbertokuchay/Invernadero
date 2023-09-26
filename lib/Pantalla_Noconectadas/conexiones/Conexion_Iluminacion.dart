import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Ap {
  static const List<String> hostConnect = [
    "http://alumnostics.utpproyectos.com.mx/serveinver/ApiDispInt.php?id=1"
  ];
}

class Iluminacion extends StatefulWidget {
  const Iluminacion({Key? key}) : super(key: key);

  @override
  State<Iluminacion> createState() => _ConexionSQLState();
}

class _ConexionSQLState extends State<Iluminacion> {
  late MqttServerClient client;
  bool isConnected = false;
  List<Map<String, dynamic>> _data = [];
  List<bool> _isLuzOnList = [];

  @override
  void initState() {
    super.initState();
    initializeMqtt();
    fetchDataFromAPI();
  }

  void initializeMqtt() {
    client = MqttServerClient('broker.emqx.io', 'mqttx_eb5cefaf');
    client.port = 1883;
    client.logging(on: true);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.pongCallback = _pong;
    client.secure = false;

    final connMessage = MqttConnectMessage()
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    client.clientIdentifier = 'myClientId';

    connectToMqtt();
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

  Future<void> connectToMqtt() async {
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
      const topic = 'iluminacion';
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      print('Published message: $message');
    }
  }

  void toggleLuz(int index, bool newValue) {
    _isLuzOnList[index] = newValue;
    String message = newValue ? '1' : '0';
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
        Ap.hostConnect.map((url) => http.get(Uri.parse(url))).toList();

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
                  'Error de conversión de JSON data. La clave "data" no contiene una lista.');
            }
          } else {
            print(
                'Error de conversión de JSON data. Formato inesperado del JSON.');
          }
        } else {
          print('Error in GET request: ${response.statusCode}');
        }
      }

      setState(() {
        _data = allData;
        _isLuzOnList = List.filled(_data.length, false);
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
      backgroundColor: const Color.fromARGB(255, 247, 251, 247),
      appBar: AppBar(
        title: Text("Panel Iluminación"), // Texto centrado en el AppBar
        centerTitle: true, // Centra el texto en el AppBar
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _data.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0, // Esto hace que las tarjetas sean cuadradas
                ),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final item = _data[index];
    final isLuzOn = _isLuzOnList[index];

    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLuzOn
              ? Icon(
                  Icons.lightbulb,
                  size: 200.0,
                  color: Colors.yellow, // Cambia el color del icono según necesites
                )
              : Icon(
                  Icons.lightbulb_outline,
                  size: 200.0,
                  color: Colors.black, // Cambia el color del icono según necesites
                ),
          SizedBox(height: 10.0),
          Text(
            "ID: ${item['cama_id']}",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5.0),
          Text(
            "${item['cama_nombre']}",
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 10.0),
          Switch(
            value: isLuzOn,
            onChanged: (value) => toggleLuz(index, value),
          ),
        ],
      ),
    );
  }
}