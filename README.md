Un sistema de invernadero basado en MQTT y HTTP es una solución tecnológica que permite monitorear y controlar un invernadero de manera remota y eficiente. El sistema utiliza el protocolo MQTT (Message Queuing Telemetry Transport) para la comunicación entre dispositivos y un servidor web con una interfaz de usuario (UI) para que los usuarios puedan interactuar con el sistema de manera intuitiva. Aquí tienes un resumen de sus componentes principales:

1. **Sensores y Actuadores**: El sistema de invernadero está equipado con una variedad de sensores que monitorean condiciones ambientales como temperatura, humedad, nivel de luz, calidad del suelo, etc. También incluye actuadores que pueden controlar elementos como sistemas de riego, ventiladores, persianas, y sistemas de calefacción.

2. **Dispositivos IoT**: Cada sensor y actuador está conectado a un dispositivo IoT (Internet de las Cosas) que puede comunicarse a través del protocolo MQTT. Estos dispositivos recopilan datos del entorno y envían actualizaciones al servidor central.

3. **Broker MQTT**: El servidor central actúa como un broker MQTT que recibe datos de los dispositivos IoT y los almacena en tiempo real. Los datos pueden ser mensajes sobre la temperatura actual, el nivel de humedad, etc. El servidor también gestiona la distribución de comandos a los actuadores.

4. **Servidor Web**: El sistema cuenta con un servidor web que aloja una interfaz de usuario (UI) accesible a través de un navegador. La UI permite a los usuarios monitorear las condiciones del invernadero y tomar decisiones informadas. Puede mostrar gráficos en tiempo real, historiales de datos, alarmas y controles para los actuadores.

5. **Comunicación HTTP**: La interfaz de usuario se comunica con el servidor central a través del protocolo HTTP (Hypertext Transfer Protocol). Los usuarios pueden acceder a la UI desde cualquier dispositivo con acceso a Internet, como computadoras, tabletas o teléfonos móviles.

6. **Base de Datos**: El sistema puede incluir una base de datos para almacenar históricos de datos y registros de acciones tomadas. Esto permite el análisis retrospectivo y la generación de informes.

7. **Lógica de Control**: El servidor central también incorpora una lógica de control que puede tomar decisiones automatizadas basadas en los datos recopilados. Por ejemplo, puede activar sistemas de riego cuando la humedad del suelo cae por debajo de un umbral específico.

En resumen, un sistema de invernadero basado en MQTT y HTTP combina la eficiencia de la comunicación MQTT para la adquisición de datos de sensores y control de actuadores con una interfaz de usuario web amigable para que los usuarios supervisen y gestionen su invernadero de manera remota. Esto facilita la optimización de las condiciones ambientales y el aumento de la productividad en la agricultura o el cultivo de plantas en invernaderos.



![Captura de pantalla (54)](https://github.com/Gualbertokuchay/Invernadero/assets/90735517/c4c5afb5-e5e1-41e7-87ef-bb76c73214b8)

![Captura de pantalla (53)](https://github.com/Gualbertokuchay/Invernadero/assets/90735517/711b1b52-b17b-47f2-b1d3-4e5d4af3b8be)

![Captura de pantalla 2023-09-24 103302](https://github.com/Gualbertokuchay/Invernadero/assets/90735517/d1e454cb-b5d2-4455-83c6-3c6766d35f60)
