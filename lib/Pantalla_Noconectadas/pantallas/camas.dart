import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invernadero/conexion0/conexion.dart';
import 'dart:convert';


class PrincipalPagina extends StatefulWidget {
  @override
  _PrincipalPaginaState createState() => _PrincipalPaginaState();
}

class _PrincipalPaginaState extends State<PrincipalPagina> {
  double temperature = 25.0;
  int humidity = 0;
  String weatherDescription = '';
  IconData weatherIcon = Icons.error_outline;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
    getTemperatureData();
    getHumidityData();
    getWeatherData();
  }

  Future<void> getTemperatureData() async {
    final apiKey =
        'aa7e24cfaa729ef73daa6b2ecd5a58ba'; // Reemplaza con tu clave de API
    final city = 'Maxcanu'; // Reemplaza con el nombre de la ciudad deseada

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'];
      });
    } else {
      print('Error al obtener datos climáticos: ${response.statusCode}');
    }
  }

  Color getTemperatureIconColor(double temperature) {
    if (temperature <= 10) {
      return Colors.black;
    } else if (temperature <= 20) {
      return Colors.black;
    } else if (temperature <= 30) {
      return Color.fromARGB(255, 255, 230, 0);
    } else {
      return Colors.black;
    }
  }

  Color getHumidityIconColor(int humidity) {
    if (humidity <= 30) {
      return Colors.black;
    } else if (humidity <= 60) {
      return Colors.black;
    } else {
      return Colors.black;
    }
  }

  Color getWeatherIconColor(String weatherDescription) {
    if (weatherDescription == 'Clear') {
      return Colors.black;
    } else if (weatherDescription == 'Clouds') {
      return Colors.black;
    } else if (weatherDescription == 'Rain') {
      return Colors.black;
    } else if (weatherDescription == 'Snow') {
      return Colors.black;
    } else if (weatherDescription == 'Thunderstorm') {
      return Colors.black;
    } else {
      return Colors.black;
    }
  }

  IconData getWeatherIcon(String weatherDescription) {
    switch (weatherDescription) {
      case 'Clear':
        return Icons.wb_sunny; // Icono de sol para clima despejado
      case 'Clouds':
        return Icons.wb_cloudy; // Icono de nube para clima nublado
      case 'Rain':
        return Icons.grain; // Icono de lluvia para clima lluvioso
      case 'Snow':
        return Icons.ac_unit; // Icono de copo de nieve para clima nevado
      case 'Thunderstorm':
        return Icons.flash_on; // Icono de tormenta para clima con tormenta
      default:
        return Icons.error_outline; // Icono de error por defecto para clima desconocido
    }
  }

  Future<void> getWeatherData() async {
    final apiKey =
        '67e02f00103d0d65a2e32ba901f01b66'; // Reemplaza con tu clave de API
    final city = 'Maxcanu'; // Reemplaza con el nombre de la ciudad deseada

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weatherDescription = data['weather'][0]['main'];
        weatherIcon = getWeatherIcon(weatherDescription);
      });
    } else {
      print('Error al obtener datos climáticos: ${response.statusCode}');
    }
  }

  Future<void> getHumidityData() async {
    final apiKey =
        'aef264edb959ea5cc3cc60cd436a8f3a'; // Reemplaza con tu clave de API
    final city = 'Maxcanu'; // Reemplaza con el nombre de la ciudad deseada

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        humidity = data['main']['humidity'];
      });
    } else {
      print('Error al obtener datos climáticos: ${response.statusCode}');
    }
  }

  Future<void> fetchDataFromAPI() async {
    final url = "http://alumnostics.utpproyectos.com.mx/serveinver/ApiCama.php";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        if (data is List<dynamic>) {
          setState(() {
            _data = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map<String, dynamic> && data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List<dynamic>) {
            setState(() {
              _data = List<Map<String, dynamic>>.from(dataList);
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

  Future<void> _handleRefresh() async {
    await fetchDataFromAPI();
    getTemperatureData();
    getHumidityData();
    getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        elevation: 10, // Ajusta la elevación para controlar la sombra
        shadowColor: Colors.white, // Color de sombra negro
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 130),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                    ),
                    SizedBox(height: 30),
                    Image.asset(
                      'assets/img/logo2.png',
                      width: 230,
                      height: 230,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Icon(
                weatherIcon,
                size: 50,
                color: getWeatherIconColor(weatherDescription),
              ),
              SizedBox(height: 5),
              Text(
                '${temperature.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Maxcanu',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                'Clima',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          weatherIcon,
                          size: 44,
                          color: getWeatherIconColor(weatherDescription),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Temperatura',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.opacity,
                          size: 45,
                          color: getHumidityIconColor(humidity),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$humidity%',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Humedad',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 30,
                  ),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (buildercontext) => ConexionApi(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 10,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                item['nombre'].toString().toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              height: 80,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/img/camas.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
