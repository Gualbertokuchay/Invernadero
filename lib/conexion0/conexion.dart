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
  List<bool> _isSensoresTemperaturaOnList = [];
  List<bool> _isHumedadOnList = [];
  List<double> _temperaturaValues = [0.0, 0.0, 0.0];
  List<double> _humedadValues = [0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();
    initializeMqtt();
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

    _isLuzOnList = List.generate(3, (index) => false);
    _isVentilacionOnList = List.generate(3, (index) => false);
    _isRiegoOnList = List.generate(3, (index) => false);
    _isSensoresTemperaturaOnList = List.generate(3, (index) => false);
    _isHumedadOnList = List.generate(3, (index) => false);

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

      // Aquí deberías procesar los mensajes MQTT y actualizar _temperaturaValues y _humedadValues
      // en función de los valores recibidos.
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
    String area = 'Iluminación';
    publishMessage(message, 'iluminacion', area);
    setState(() {});
  }

  void toggleVentilacion(int index, bool newValue) {
    _isVentilacionOnList[index] = newValue;
    String message = newValue ? '1' : '0';
    String area = 'Ventilación';
    publishMessage(message, 'ventilacion1', area);
    setState(() {});
  }

  void toggleRiego(int index, bool newValue) {
    _isRiegoOnList[index] = newValue;
    String message = newValue ? '1' : '0';
    String area = 'Sistema de Riego';
    publishMessage(message, 'sistemaderiego', area);
    setState(() {});
  }

  void toggleSensoresTemperatura(int index, bool newValue) {
    _isSensoresTemperaturaOnList[index] = newValue;
    String message = newValue ? '1' : '0';
    String area = 'Temperatura';
    publishMessage(message, 'sensor:temperatura', area);
    setState(() {});
  }

  void toggleHumedad(int index, bool newValue) {
    _isHumedadOnList[index] = newValue;
    String message = newValue ? '1' : '0';
    String area = 'Humedad';
    publishMessage(message, 'sensor:humedad', area);
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
        title: Text("Panel de Control"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.4,
          ),
          itemCount: 15,
          itemBuilder: (context, index) {
            if (index < 3) {
              return _buildCard(
                  index, _isLuzOnList, toggleLuz, 'Iluminación', Icons.lightbulb);
            } else if (index < 6) {
              return _buildCard(index - 3, _isVentilacionOnList,
                  toggleVentilacion, 'Ventilación', Icons.ac_unit);
            } else if (index < 9) {
              return _buildCard(
                  index - 6, _isRiegoOnList, toggleRiego, 'Sistema de Riego', Icons.local_florist);
            } else if (index < 12) {
              return _buildCard(index - 9, _isSensoresTemperaturaOnList,
                  toggleSensoresTemperatura, 'Temperatura', Icons.thermostat);
            } else {
              return _buildCard(index - 12, _isHumedadOnList,
                  toggleHumedad, 'Humedad', Icons.water_drop);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(int index, List<bool> stateList, Function toggleFunction,
      String category, IconData icon) {
    final isOn = stateList[index];

    return Card(
      elevation: 3.4,
      margin: EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isOn
              ? Icon(
                  icon,
                  size: 78.0,
                  color: Colors.greenAccent,
                )
              : Icon(
                  icon,
                  size: 78.0,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
          SizedBox(height: 10.0),
          Text(category),
          category == 'Temperatura'
              ? Text(
                  'Temperatura: ${_temperaturaValues[index]}°C',
                  style: TextStyle(fontSize: 22),
                )
              : SizedBox(),
          category == 'Humedad'
              ? Text(
                  'Humedad: ${_humedadValues[index]}%',
                  style: TextStyle(fontSize: 22),
                )
              : SizedBox(),
          Switch(
            value: isOn,
            onChanged: (value) => toggleFunction(index, value),
          ),
        ],
      ),
    );
  }
}
