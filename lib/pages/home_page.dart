import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/utils/constants.dart';
import 'package:weather/utils/helper_functions.dart';
import 'package:weather/utils/textstyles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WeatherProvider weatherProvider;
  bool isCalledOnce = true;

  @override
  void didChangeDependencies() {
    if (isCalledOnce) {
      weatherProvider = Provider.of<WeatherProvider>(context, listen: true);
      _getData();
    }
    isCalledOnce = false;
    super.didChangeDependencies();
  }

  void _getData() {
    _determinePosition().then((position) {
      weatherProvider.setNewPosition(position.latitude, position.longitude);
      weatherProvider.getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          elevation: 0,
          title: const Text('Weather app'),
        ),
        body: weatherProvider.hasDataLoaded
            ? ListView(
                children: [
                  _currentWeatherSection(),
                  _forecastWeatherSection(),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget _currentWeatherSection() {
    final current = weatherProvider.currentWeatherResponse;
    return Column(
      children: [
        Text(
          getFormattedDate(
            current!.dt!,
            pattern: 'EEE dd, yyyy',
          ),
          style: txtDate16,
        ),
        Text(
          '${current.name}, ${current.sys!.country}',
          style: txtAddress20,
        ),
        Text(
          '${current.main!.temp!.round()}$degree${weatherProvider.tempUnitSymbol}',
          style: txtTempBig80,
        ),
        Text(
          'Feels like ${current.main!.feelsLike!.round()}$degree${weatherProvider.tempUnitSymbol}',
          style: txtTempNormal18,
        ),
        Image.network("$iconPrefix${current.weather![0].icon}$iconSuffix"),
        Text(
          current.weather![0].description!,
          style: txtAddress20,
        ),
        Wrap(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Humidity ${current.main!.humidity}%',
                style: txtTempNormal18,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Pressure ${current.main!.pressure}hPa%',
                style: txtTempNormal18,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Visibility ${current.visibility} meter',
                style: txtTempNormal18,
              ),
            ),
          ],
        ),
        Wrap(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Sunrise ${getFormattedDate(current.sys!.sunrise!, pattern: 'hh:mm a')}',
                style: txtAddress20,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Sunset ${getFormattedDate(current.sys!.sunset!, pattern: 'hh:mm a')}',
                style: txtAddress20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _forecastWeatherSection() {
    final itemList = weatherProvider.forecastWeatherResponse!.list!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: itemList
            .map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          getFormattedDate(item.dt!, pattern: 'EEE, HH:mm'),
                          style: txtDate16,
                        ),
                      ),
                      Expanded(
                        child: Image.network(
                          "$iconPrefix${item.weather![0].icon}$iconSuffix",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.main!.tempMax!.round()}/${item.main!.tempMin!.round()}$degree${weatherProvider.tempUnitSymbol}',
                          style: txtDate16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.weather![0].description!,
                          style: txtDate16,
                        ),
                      ),
                    ],
                  ),
            ))
            .toList(),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
