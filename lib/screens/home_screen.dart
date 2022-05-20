import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:indra/config.dart';
import 'package:http/http.dart' as http;
import 'package:indra/models/weather_response.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomePage(title: 'Home');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<WeatherResponse> response;
  late Future<Position> currentPosition;
  Future<WeatherResponse> fetchWeather() async {
    final pos = await _determinePosition();
    final response = await http.get(Uri.parse(
        "${EnvironmentConfig.apiUrl}/weather?lat=${pos.latitude.toInt()}&lon=${pos.longitude.toInt()}&appid=${EnvironmentConfig.apiKey}"));

    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch weather information');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    response = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("bg_sunny.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              child: FutureBuilder<WeatherResponse>(
                future: response,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${snapshot.data!.main}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${(snapshot.data!.temp! - 273.15).round()}°",
                          style: const TextStyle(
                            fontSize: 86,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                }),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            ClipPath(
              clipper: WaveClipperTwo(flip: true, reverse: true),
              child: Container(
                height: 350,
                color: Colors.white,
                child: const Center(child: Text("WaveClipperTwo(flip: true)")),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Add new location',
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.deepPurple,
          size: 30,
        ),
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.cubicTo(size.width / 4, 3 * size.height / 4, 3 * size.width / 4,
        size.height / 4, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
