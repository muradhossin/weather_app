import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/utils/weather_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool tempUnitStatus = false;
  bool is24Hours = false;
  @override
  void initState() {
    getBool(prefUnit).then((value) {
      setState(() {
        tempUnitStatus = value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SwitchListTile(
            value: tempUnitStatus,
            onChanged: (value) async{
              setState(() {
                tempUnitStatus = value;
              });
              await setBool(prefUnit, value);
              context.read<WeatherProvider>().setTempUint(value);
            },
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text("Default is Celsius"),
          ),
          SwitchListTile(
            value: is24Hours,
            onChanged: (value) async{
              setState(() {
                is24Hours = value;
              });
              await setBool(prefTimeFormat, value);
              context.read<WeatherProvider>().setTimeFormat(value);

            },
            title: const Text('Show Time in 24 hour format'),
            subtitle: const Text("Default is 12 hour format"),
          ),
        ],
      ),
    );
  }
}
