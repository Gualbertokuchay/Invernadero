import 'package:flutter/material.dart';
import 'package:invernadero/Pantalla_Noconectadas/pantalla_card.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 245, 241, 241),
              Color.fromARGB(255, 245, 241, 241),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Spacer(),
                    Row(
                    ),
                  ],
                ),
                formato_card(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
