import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/constant/api_constant.dart';

import '../models/weather_forecast_model.dart';

class WeatherController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchWeatherData();
  }

  var isLoading = false.obs;
  var temperature = 0.0.obs;
  var weatherCondition = ''.obs;
  var windSpeed = 0.0.obs;
  var forecast = List<WeatherForecast>.empty().obs;
  var temperatureUnit = TemperatureUnit.celsius.obs;

  var cityName = "".obs;

  var exception = "".obs;

  Future<Position> getCurrentPosition() async {
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// Method to update weather data
  updateWeather(double temp, String condition, double wind,
      List<WeatherForecast> forecastData) {
    temperature.value = temp;
    weatherCondition.value = condition;
    windSpeed.value = wind;
    forecast.value = forecastData;
  }

  Set<String> uniqueDates = <String>{};
  List<DateTime> uniqueDatetimes = [];

  /// Method to fetch weather data
  Future<void> fetchWeatherData() async {
    isLoading(true);

    try {
      Position currentPosition = await getCurrentPosition();

      final address = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      cityName(address[0].locality);

      final forecastResponse = await http
          .get(Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
        'lat': "${currentPosition.latitude}",
        "lon": "${currentPosition.longitude}",
        "units": "metric",
        "appid": ApiConstant.apiKey
      }));

      log("forecastResponse ${forecastResponse.request}");

      if (forecastResponse.statusCode == 200) {
        final Map<String, dynamic> forecastData =
            json.decode(forecastResponse.body);
        final List<WeatherForecast> forecastList = [];

        uniqueDates.clear();

        for (var item in forecastData['list']) {
          final DateTime date =
              DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);

          String dateString = "${date.year}-${date.month}-${date.day}";

          if (!uniqueDates.contains(dateString)) {
            uniqueDates.add(dateString);

            final double temperature = item['main']['temp'].runtimeType == int
                ? double.parse('${item['main']['temp']}')
                : item['main']['temp'];
            final String condition = item['weather'][0]['description'];
            final double windSpeed = item['wind']['speed'].runtimeType == int
                ? double.parse("${item['wind']['speed']}")
                : item['wind']['speed'];
            forecastList
                .add(WeatherForecast(temperature, condition, windSpeed, date));
          }
        }

        log("AWAIT ${forecastList.length}");

        await updateWeather(
            forecastList.first.temperature,
            forecastList.first.condition,
            forecastList.first.windSpeed,
            forecastList);
        exception('');
        isLoading(false);
      } else {
        isLoading(false);
        forecast.value = [];
        exception('Failed to load weather data');
        throw Exception('Failed to load weather data');
      }
    } on Exception catch (_) {
      isLoading(false);
      forecast.value = [];
      exception('Failed to load weather data');
      throw Exception('Failed to load weather data');
    }
  }

  DateTime initialDate = DateTime.now();
  DateTime? currentDate; // To keep track of the current date

  /// Method to fetch weather by location data
  Future<void> fetchWeatherByLocation(String location) async {
    try {
      isLoading(true);

      final response = await http.get(Uri.https(
          'api.openweathermap.org',
          '/data/2.5/weather',
          {'q': location, "units": "metric", "appid": ApiConstant.apiKey}));

      if (response.statusCode == 200) {
        final Map<String, dynamic> forecastData = json.decode(response.body);

        final List<WeatherForecast> forecastList = [];

        updateWeather(
            forecastData["main"]["temp"],
            forecastData['weather'][0]['description'],
            forecastData['wind']['speed'],
            forecastList);

        cityName(location.capitalizeFirst);
        exception('');

        isLoading(false);
      } else {
        isLoading(false);
        forecast.value = [];
        exception('Failed to load weather data');
        throw Exception('Failed to load weather data');
      }
    } on Exception catch (_) {
      isLoading(false);
      forecast.value = [];
      exception('Failed to load weather data');
      throw Exception('Failed to load weather data');
    }
  }

  ///convert unit

  void setTemperatureUnit(TemperatureUnit unit) {
    temperatureUnit.value = unit;
    Get.back();
  }

  String getTemperatureUnitLabel() {
    return temperatureUnit.value == TemperatureUnit.celsius ? 'C' : 'F';
  }

  double convertTemperature(double temp) {
    if (temperatureUnit.value == TemperatureUnit.fahrenheit) {
      return ((temp * 9 / 5) + 32).toPrecision(2);
    } else {
      return temp;
    }
  }

  ///Theme

  var isDarkTheme = false.obs;

  void toggleTheme() {
    Get.changeTheme(
      Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
    );

    Get.back();
  }
}
