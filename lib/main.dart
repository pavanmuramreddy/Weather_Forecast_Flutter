import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// --- CONFIGURATION ---
const String API_KEY =
    '1e0ff4f338feea959ffe5c5f4f7c048b'; // <-- IMPORTANT: REPLACE WITH YOUR API KEY
const String DEFAULT_CITY = 'Vellore';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- DATA MODELS ---

class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final List<Forecast> dailyForecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.dailyForecast,
  });

  factory Weather.fromJson(
    Map<String, dynamic> currentData,
    Map<String, dynamic> forecastData,
  ) {
    final daily = (forecastData['list'] as List).map((item) {
      return Forecast.fromJson(item);
    }).toList();

    return Weather(
      cityName: currentData['name'],
      temperature: currentData['main']['temp'].toDouble(),
      description: currentData['weather'][0]['main'],
      icon: currentData['weather'][0]['icon'],
      humidity: currentData['main']['humidity'],
      windSpeed: currentData['wind']['speed'],
      dailyForecast: daily,
    );
  }
}

class Forecast {
  final DateTime date;
  final double temp;
  final String description;
  final String icon;

  Forecast({
    required this.date,
    required this.temp,
    required this.description,
    required this.icon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: json['main']['temp'].toDouble(),
      description: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}

// --- API SERVICE ---

class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> fetchWeather(String city) async {
    final currentUrl = '$_baseUrl/weather?q=$city&appid=$API_KEY&units=metric';
    final forecastUrl =
        '$_baseUrl/forecast?q=$city&appid=$API_KEY&units=metric';

    try {
      final currentResponse = await http.get(Uri.parse(currentUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);
        return Weather.fromJson(currentData, forecastData);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the weather service');
    }
  }
}

// --- UI SCREENS AND WIDGETS ---

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherApiService _weatherApiService = WeatherApiService();
  final TextEditingController _cityController = TextEditingController(
    text: DEFAULT_CITY,
  );
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(DEFAULT_CITY);
  }

  Future<void> _fetchWeatherData(String city) async {
    if (API_KEY == 'YOUR_OPENWEATHERMAP_API_KEY') {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Please replace "YOUR_OPENWEATHERMAP_API_KEY" with your actual API key.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherApiService.fetchWeather(city);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showCitySearchDialog(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_weather == null) {
      return const Center(child: Text('No weather data.'));
    }
    return RefreshIndicator(
      onRefresh: () => _fetchWeatherData(_cityController.text),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurrentWeatherWidget(weather: _weather!),
            const SizedBox(height: 24),
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ForecastListWidget(
              forecast: _get7DayForecast(_weather!.dailyForecast),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter City Name'),
        content: TextField(
          controller: _cityController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g., London"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Search'),
            onPressed: () {
              if (_cityController.text.isNotEmpty) {
                _fetchWeatherData(_cityController.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  List<Forecast> _get7DayForecast(List<Forecast> daily) {
    // This logic groups forecasts by day and takes the forecast closest to midday.
    final Map<int, Forecast> dailyForecasts = {};
    for (var f in daily) {
      final day = f.date.day;
      if (!dailyForecasts.containsKey(day) ||
          (f.date.hour - 12).abs() <
              (dailyForecasts[day]!.date.hour - 12).abs()) {
        dailyForecasts[day] = f;
      }
    }
    return dailyForecasts.values.toList();
  }
}

class CurrentWeatherWidget extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherWidget({Key? key, required this.weather})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                  errorBuilder: (c, e, s) => Icon(Icons.cloud, size: 50),
                ),
                const SizedBox(width: 10),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 48),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              weather.description,
              style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Humidity', '${weather.humidity}%'),
                _buildInfoColumn(
                  'Wind',
                  '${weather.windSpeed.toStringAsFixed(1)} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ForecastListWidget extends StatelessWidget {
  final List<Forecast> forecast;

  const ForecastListWidget({Key? key, required this.forecast})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length > 7 ? 7 : forecast.length,
        itemBuilder: (context, index) {
          final dayForecast = forecast[index];
          return ForecastCard(forecast: dayForecast);
        },
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final Forecast forecast;

  const ForecastCard({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              DateFormat('E, MMM d').format(forecast.date),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/${forecast.icon}.png',
              errorBuilder: (c, e, s) => Icon(Icons.cloud, size: 30),
            ),
            Text('${forecast.temp.toStringAsFixed(1)}°C'),
          ],
        ),
      ),
    );
  }
}
