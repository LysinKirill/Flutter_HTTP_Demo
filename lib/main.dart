import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: OPENWEATHERMAP_API_KEY is not set in the .env file.');
  }

  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String apiKey;
  final String geocodingUrl = 'http://api.openweathermap.org/geo/1.0/direct';
  final String weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String cityName = 'London';
  Map<String, dynamic>? weatherData;
  String errorMessage = '';

  final List<String> cities = [
    'London',
    'Paris',
    'New York',
    'Tokyo',
    'Berlin',
    'Moscow',
    'Sydney',
    'Beijing',
    'Dubai',
    'Mumbai',
  ];

  Future<void> fetchWeather() async {
    try {
      final geocodingResponse = await http.get(
        Uri.parse('$geocodingUrl?q=$cityName&limit=1&appid=$apiKey'),
      );

      if (geocodingResponse.statusCode != 200) {
        setState(() {
          weatherData = null;
          errorMessage = 'Failed to fetch location: ${geocodingResponse.statusCode}';
        });
        return;
      }

      final List<dynamic> geocodingData = jsonDecode(geocodingResponse.body);
      if (geocodingData.isEmpty) {
        setState(() {
          weatherData = null;
          errorMessage = 'Location not found';
        });
        return;
      }

      final double lat = geocodingData[0]['lat'];
      final double lon = geocodingData[0]['lon'];

      final weatherResponse = await http.get(
        Uri.parse('$weatherUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
      );

      if (weatherResponse.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(weatherResponse.body);
          errorMessage = '';
        });
      } else {
        setState(() {
          weatherData = null;
          errorMessage = 'Failed to fetch weather data: ${weatherResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        weatherData = null;
        errorMessage = 'Network error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      setState(() {
        errorMessage = 'API key is not set. Please check the .env file.';
      });
    } else {
      fetchWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: cityName,
                onChanged: (String? newValue) {
                  setState(() {
                    cityName = newValue!;
                  });
                  fetchWeather();
                },
                items: cities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              if (weatherData != null)
                Column(
                  children: [
                    Text(
                      '${weatherData!['name']}, ${weatherData!['sys']['country']}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${weatherData!['main']['temp']}°C',
                      style: TextStyle(fontSize: 48),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${weatherData!['weather'][0]['description']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      'http://openweathermap.org/img/wn/${weatherData!['weather'][0]['icon']}@2x.png',
                    ),
                  ],
                ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}