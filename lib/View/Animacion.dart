import 'package:flutter/material.dart';
import 'package:invernadero/Pantalla_Noconectadas/pantallas/camas.dart';

class Animacion extends StatefulWidget {
  const Animacion({Key? key}) : super(key: key);

  @override
  _AnimacionState createState() => _AnimacionState();
}

class _AnimacionState extends State<Animacion> {
  Future<void> _esperarYRedirigir() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PrincipalPagina(), 
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _esperarYRedirigir(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo2.png',
              width: 400.0,
              height: 400.0,
            ),
            SizedBox(height: 16.0),
            Text(
              "Bienvenido",
              style: TextStyle(
                fontSize: 60.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
