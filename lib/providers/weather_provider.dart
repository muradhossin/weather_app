import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/models/current_weather_response.dart';
import 'package:weather/models/forecast_weather_response.dart';
import 'package:weather/utils/constants.dart';
import 'package:http/http.dart' as Http;
class WeatherProvider extends ChangeNotifier{
  CurrentWeatherResponse? currentWeatherResponse;
  ForecastWeatherResponse? forecastWeatherResponse;

  double latitude = 0.0;
  double longitude = 0.0;
  String tempUnit = metric;
  String tempUnitSymbol = celsius;
  String timeFormat = timePattern24h;


  void setNewPosition(double lat, double lng){
    latitude = lat;
    longitude = lng;
  }

  void setTempUint(bool status){
    tempUnit = status ? imperial : metric;
    tempUnitSymbol = status ? fahrenheit : celsius;
    getData();
  }

  void setTimeFormat(bool status){
    timeFormat = status ? timePattern12h : timePattern24h;
    getData();
  }

  bool get hasDataLoaded => currentWeatherResponse != null && forecastWeatherResponse != null;

  void getData(){
    _getCurrentWeatherDate();
    _getForecastWeatherDate();
  }

  Future<void> _getCurrentWeatherDate() async{
    final urlString = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$tempUnit';
    try{
      final response = await Http.get(Uri.parse(urlString));
      final map = jsonDecode(response.body);
      if(response.statusCode == 200){
        currentWeatherResponse = CurrentWeatherResponse.fromJson(map);
        notifyListeners();
      }else{
        print(map['message']);
      }
    }catch(error){
      print(error.toString());
    }
  }
  Future<void> _getForecastWeatherDate() async{
    final urlString = 'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$tempUnit';
    try{
      final response = await Http.get(Uri.parse(urlString));
      final map = jsonDecode(response.body);
      if(response.statusCode == 200){
        forecastWeatherResponse = ForecastWeatherResponse.fromJson(map);
        notifyListeners();
      }else{
        print(map['message']);
      }
    }catch(error){
      print(error.toString());
    }
  }

  Future<void> convertAddressToLocation(String address) async{
    try{
      final locationList = await locationFromAddress(address);
      if(locationList.isNotEmpty){
        final location = locationList.first;
        latitude = location.latitude;
        longitude = location.longitude;
        getData();
      }else{
        print('No location found from your provided address');
      }
    }catch(error){
      print(error.toString());
    }
  }
}