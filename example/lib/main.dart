import 'package:flutter/material.dart';
import 'dart:async';
import 'package:debouncing_example/src/src.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
void main() => runZonedGuarded<void>(
      () => runApp(
        const MyApp(),
      ),
      (error, stackTrace) => developer.log(
        'A global error has occurred: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'background',
        level: 900,
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debounce, Throttle, BackOff',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/debounce_example_1_page': (context) => const DebounceExample1Page(),
        '/debounce_example_2_page': (context) => const DebounceExample2Page(),
        '/throttle_example_1_page': (context) => const ThrottleExample1Page(),
        '/throttle_example_2_page': (context) => const ThrottleExample2Page(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MyHomePage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/debounce_example_1_page');
              },
              style: TextButton.styleFrom(backgroundColor: Colors.amber),
              child: Text(
                'Open DebounceExample1Page',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/debounce_example_2_page');
              },
              style: TextButton.styleFrom(backgroundColor: Colors.amber),
              child: Text(
                'Open DebounceExample2Page',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/throttle_example_1_page');
              },
              style: TextButton.styleFrom(backgroundColor: Colors.amber),
              child: Text(
                'Open ThrottleExample1Page',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/throttle_example_2_page');
              },
              style: TextButton.styleFrom(backgroundColor: Colors.amber),
              child: Text(
                'Open ThrottleExample2Page',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
