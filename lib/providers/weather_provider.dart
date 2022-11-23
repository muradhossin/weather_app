import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/models/current_weather_response.dart';
import 'package:weather/utils/constants.dart';
import 'package:http/http.dart' as Http;
class WeatherProvider extends ChangeNotifier{
  CurrentWeatherResponse currentWeatherResponse = CurrentWeatherResponse();

  Future<void> getCurrentWeatherDate(Position position) async{
    final urlString = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$WeatherAPI_KEY&units=metric';
    final response = await Http.get(Uri.parse(urlString));
    final map = jsonDecode(response.body);
    if(response.statusCode == 200){
      currentWeatherResponse = CurrentWeatherResponse.fromJson(map);
      print(currentWeatherResponse.main!.temp.toString());
    }
  }
}