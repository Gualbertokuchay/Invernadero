import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ConexionApi extends StatefulWidget {
  const ConexionApi({Key? key}) : super(key: key);

  @override
  State<ConexionApi> createState() => _ConexionApiState();
}

class _ConexionApiState extends State<ConexionApi> {
  late MqttServerClient client;
  bool isConnected = false;
  List<bool> _isLuzOnList = [];
  List<bool> _isVentilacionOnList = [];
  List<bool> _isRiegoOnList = [];
  double _temperaturaValue = 0.0;
  double _humedadValue = 0.0;

  @override
  void initState() {
    super.initState();
    initializeMqtt();
  }

  void initializeMqtt() {
    client = MqttServerClient('broker.emqx.io', 'mqttx_f39c405a');
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

    _isLuzOnList = List.generate(3, (index) => false);
    _isVentilacionOnList = List.generate(3, (index) => false);
    _isRiegoOnList = List.generate(3, (index) => false);

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
      // Suscribirse a los tópicos de temperatura y humedad
      client.subscribe('sensordetemperatura', MqttQos.atLeastOnce);
      client.subscribe('sensordehumedad', MqttQos.atLeastOnce);
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message: $payload from topic: ${c[0].topic}>');

      // Actualizar los valores de temperatura y humedad cuando se recibe un mensaje
      if (c[0].topic == 'sensordetemperatura') {
        setState(() {
          _temperaturaValue = double.tryParse(payload) ?? 0.0;
        });
      } else if (c[0].topic == 'sensordehumedad') {
        setState(() {
          _humedadValue = double.tryParse(payload) ?? 0.0;
        });
      }
    });
  }

  void publishMessage(String message, String topic, String area) {
    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      print('Mensaje enviado desde el área de $area: $message to topic: $topic');
    }
  }

  void toggleLuz(int index, bool newValue) {
    _isLuzOnList[index] = newValue;
    String message = newValue ? '1' : '0';
    String area = 'iluminacion';
    publishMessage(message, 'iluminacion', area);
    setState(() {});
  }

  void toggleVentilacion(int index, bool newValue) {
    _isVentilacionOnList[index] = newValue;
    String message = newValue ? '2' : '3';
    String area = 'ventilacion1';
    publishMessage(message, 'ventilacion1$index', area);
    setState(() {});
  }

  void toggleRiego(int index, bool newValue) {
    _isRiegoOnList[index] = newValue;
    String message = newValue ? '4' : '5';
    String area = 'Sistema de Riego';
    publishMessage(message, 'sistemaderiego', area);
    setState(() {});
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Paneles de Control",
          style: TextStyle(
            color: Colors.black, // Texto negro
          ),
        ),
        centerTitle: true, // Centrar el título en el medio
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              'Iluminación',
              _isLuzOnList,
              Icons.lightbulb,
              toggleLuz,
            ),
            _buildCard(
              'Ventilación',
              _isVentilacionOnList,
              Icons.ac_unit,
              toggleVentilacion,
            ),
            _buildCard(
              'Sistema de Riego',
              _isRiegoOnList,
              Icons.local_florist,
              toggleRiego,
            ),
            _buildSensorCard('Temperatura', _temperaturaValue),
            _buildSensorCard('Humedad', _humedadValue),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    String category,
    List<dynamic> dataList,
    IconData icon,
    Function toggleFunction,
  ) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.black,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 7.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int index = 0; index < 3; index++)
                  _buildSwitchWidget(
                    index,
                    dataList,
                    toggleFunction,
                    category,
                    icon,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String category, double value) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.black,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 13.0),
            Text(
              '$category: $value',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchWidget(int index, List<dynamic> stateList,
      Function toggleFunction, String category, IconData icon) {
    final isOn = stateList[index];
    return Column(
      children: [
        isOn
            ? Icon(
                icon,
                size: 65.0,
                color: Colors.green,
              )
            : Icon(
                icon,
                size: 65.0,
                color: Colors.black,
              ),
        SizedBox(height: 10.0),
        Text(category),
        Switch(
          value: isOn,
          onChanged: (value) => toggleFunction(index, value),
        ),
      ],
    );
  }
}
