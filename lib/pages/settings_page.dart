import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool status = false;
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
            value: status,
            onChanged: (value){
              setState(() {
                status = value;
              });
            },
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text("Default is Celsius"),
          ),
        ],
      ),
    );
  }
}
