import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:indra/config.dart';
import 'package:http/http.dart' as http;
import 'package:indra/models/main.dart';
import 'package:indra/models/quote.dart';
import 'package:indra/models/quote_response.dart';
import 'package:indra/models/three_hour_weather_response.dart';
import 'package:indra/models/weather.dart';
import 'package:indra/models/weather_response.dart';
import "package:indra/extensions/string_apis.dart";
import 'package:indra/models/wind.dart';
import 'package:intl/intl.dart';

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
  late Future<WeatherResponse> currentWeather;
  late Future<ThreeHourWeatherResponse> threeHourWeather;
  late Future<Position> currentPosition;
  late Future<QuoteResponse> randomQuote;
  int currentHour = DateTime.now().hour;

  Future<WeatherResponse> fetchCurrentWeather() async {
    final pos = await _determinePosition();
    final response = await http.get(Uri.parse(
        "${EnvironmentConfig.apiUrl}/weather?lat=${pos.latitude.toInt()}&lon=${pos.longitude.toInt()}&appid=${EnvironmentConfig.apiKey}&units=metric"));

    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch weather information');
    }
  }

  Future<ThreeHourWeatherResponse> fetchListWeather() async {
    final pos = await _determinePosition();
    final response = await http.get(Uri.parse(
        "${EnvironmentConfig.apiUrl}/forecast?lat=${pos.latitude.toInt()}&lon=${pos.longitude.toInt()}&appid=${EnvironmentConfig.apiKey}&units=metric"));

    if (response.statusCode == 200) {
      return ThreeHourWeatherResponse.fromJson(jsonDecode(response.body));
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

  Future<QuoteResponse> fetchRandomQuote() async {
    final response =
        await http.get(Uri.parse("https://quotes.rest/qod?language=en"));
    if (response.statusCode == 200) {
      return QuoteResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch weather information');
    }
  }

  String getBackgroundFromCurrentTime() {
    if (currentHour > 6 && currentHour < 16) {
      return "assets/bg_sunny.jpg";
    } else if (currentHour >= 16 && currentHour < 18) {
      return "assets/bg_sunset.jpg";
    } else {
      return "assets/bg_night.jpg";
    }
  }

  Color getTextColor() {
    if (currentHour > 6 && currentHour < 16) {
      return Colors.black;
    } else if (currentHour >= 16 && currentHour < 18) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    currentWeather = fetchCurrentWeather();
    threeHourWeather = fetchListWeather();
    randomQuote = fetchRandomQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(getBackgroundFromCurrentTime()),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              child: FutureBuilder<WeatherResponse>(
                future: currentWeather,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    final Weather weather = snapshot.data!.weather[0];
                    final Wind? wind = snapshot.data?.wind;
                    final Main? main = snapshot.data?.main;
                    final int vis = snapshot.data?.visibility ?? 0;
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            DateFormat("E, MMM dd yyyy").format(DateTime.now()),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: getTextColor(),
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  weather.main,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 40,
                                    color: getTextColor(),
                                  ),
                                ),
                                Text(
                                  "${(snapshot.data!.main.temp).round()}°",
                                  style: TextStyle(
                                    fontSize: 90,
                                    fontWeight: FontWeight.w900,
                                    color: getTextColor(),
                                  ),
                                ),
                                Text(
                                  "Feels like ${main?.feelsLike.round()}°",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: getTextColor(),
                                  ),
                                ),
                                Text(
                                  weather.description.capitalize(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: getTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: FutureBuilder<QuoteResponse>(
                            future: randomQuote,
                            builder: ((context, snapshot) {
                              if (snapshot.hasData) {
                                final Quote? quote = snapshot.data?.quote;
                                return Column(
                                  children: [
                                    Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 70),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Text(
                                          "${quote?.quote}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "~ ${quote?.author}",
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              return Row(
                                children: [
                                  const Text(
                                    "Getting your quote for today...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                  CircularProgressIndicator(
                                    color: Colors.purple.shade700,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                        Container(
                          height: 75,
                          margin: const EdgeInsets.only(top: 70),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Spacer(flex: 1),
                                  Text(
                                    "${main?.humidity}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Humidity ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                ],
                              ),
                              Column(
                                children: [
                                  const Spacer(flex: 1),
                                  Text(
                                    "${vis / 1000} km",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Visibility ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                ],
                              ),
                              Column(
                                children: [
                                  const Spacer(flex: 1),
                                  Text(
                                    "${wind?.speed} m/s",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Wind ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                ],
                              ),
                            ],
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
                height: 250,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(30, 70, 30, 0),
                child: FutureBuilder<ThreeHourWeatherResponse>(
                  future: threeHourWeather,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final ThreeHourWeatherResponse? data = snapshot.data;
                      final List<WeatherResponse> items = data!.list;
                      return Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Text(
                                "Today",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(flex: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    size: 20,
                                    color: Colors.red[600],
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "${data.city.name}, ${data.city.country}",
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black38,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: ((context, index) {
                                var item = items[index];
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        item.dt! * 1000);
                                String formattedDate =
                                    DateFormat('dd/MM').format(date);
                                String formattedTime =
                                    DateFormat('HH:mm a').format(date);

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${(item.main.temp).round()}°",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        item.weather[0].main,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                              itemCount: items.length,
                            ),
                          )
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Container();
                  },
                ),
              ),
            ),
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
