import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key, required this.shape}) : super(key: key);

  final WearShape shape;

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Center(
      child: Container(
        height: screenSize.height - 10,
        width: screenSize.width - 10,
        decoration:
            const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Counted:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: _incrementCounter,
                style: ElevatedButton.styleFrom(
                    primary: Colors.black54,
                    shape: const CircleBorder(),
                    fixedSize:
                        Size(screenSize.width / 4, screenSize.height / 4)),
                child: const Icon(Icons.add))
          ],
        ),
      ),
    );
  }
}
