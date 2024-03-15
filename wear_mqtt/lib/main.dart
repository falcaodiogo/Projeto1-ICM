import 'package:flutter/material.dart';
import 'package:phone_main/widgets/mqtt_view.dart';
import 'package:phone_main/mqtt/state/mqtt_appstate.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: ChangeNotifierProvider<MQTTAppState>(
        create: (_) => MQTTAppState(),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 19, 35, 44),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: const IntrinsicHeight(
                    child: MQTTView(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
