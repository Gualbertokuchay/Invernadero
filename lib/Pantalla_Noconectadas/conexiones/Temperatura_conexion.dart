import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class API {
  static const String hostConnect =
      "http://alumnostics.utpproyectos.com.mx/serveinver/ApiDispInt.php?id=1";
}

class Sensores extends StatefulWidget {
  const Sensores({Key? key}) : super(key: key);

  @override
  State<Sensores> createState() => _ConexionSQLState();
}

class _ConexionSQLState extends State<Sensores> {
  late MqttServerClient client;
  bool isConnected = false;
  List<Map<String, dynamic>> _data = [];
  List<bool> _isVentiladorOnList = [];
  double _temperatureValue = 0.0;
  double _humidityValue = 0.0;

  @override
  void initState() {
    super.initState();
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

    connect();

    fetchDataFromAPI();
  }

  void _onConnected() {
    setState(() {
      isConnected = true;
    });
    print('Connected to MQTT broker');
    subscribeToTemperatureTopic();
    subscribeToHumidityTopic();
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
      final topic = 'ventilacion1';
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message: $message');
    }
  }

  void toggleVentilador(int index, bool newValue) {
    _isVentiladorOnList[index] = newValue;
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
    final url = API.hostConnect;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic>) {
          setState(() {
            _data = List<Map<String, dynamic>>.from(data);
            _isVentiladorOnList = List.filled(_data.length, false);
          });
        } else if (data is Map<String, dynamic> && data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List<dynamic>) {
            setState(() {
              _data = List<Map<String, dynamic>>.from(dataList);
              _isVentiladorOnList = List.filled(_data.length, false);
            });
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
    } catch (e) {
      print('Error: $e');
    }
  }

  void subscribeToTemperatureTopic() {
    if (isConnected) {
      final temperatureTopic = 'sensor:temperatura';
      client.subscribe(temperatureTopic, MqttQos.atLeastOnce);

      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _temperatureValue = double.parse(payload);
        print('Temperature value received: $_temperatureValue');
        setState(() {});
      });
    }
  }

  void subscribeToHumidityTopic() {
    if (isConnected) {
      final humidityTopic = 'sensor:temperatura';
      client.subscribe(humidityTopic, MqttQos.atLeastOnce);

      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _humidityValue = double.parse(payload);
        print('Humidity value received: $_humidityValue');
        setState(() {});
      });
    }
  }

  Future<void> _handleRefresh() async {
    await fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Panel de Temperatura y Humedad"),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _data.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 tarjetas por fila
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.white, // Fondo blanco
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thermostat,
                            size: 40.0,
                            color: Colors.blue, // Color del ícono de temperatura
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Temperatura: $_temperatureValue °C",
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Switch(
                                value: _isVentiladorOnList[index],
                                onChanged: (bool newValue) {
                                  toggleVentilador(index, newValue);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: _data.length,
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
