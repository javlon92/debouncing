import 'package:debouncing_example/src/src.dart';
import 'package:flutter/material.dart';

class ThrottleExample2Page extends StatefulWidget {
  const ThrottleExample2Page({super.key});

  @override
  State<ThrottleExample2Page> createState() => _ThrottleExample2PageState();
}

class _ThrottleExample2PageState extends State<ThrottleExample2Page> with ThrottleStateMixin {
  double normalScrollPosition = 0;
  double throttledScrollPosition = 0;
  final ScrollController scrollController = ScrollController();

  @override
  ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 1500), trailing: true);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        if (scrollController.hasClients) {
          normalScrollPosition = scrollController.position.pixels;
        }
      });

      throttle(() {
        setState(() {
          if (scrollController.hasClients) {
            throttledScrollPosition = scrollController.position.pixels;
          }
        });
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    // throttle.dispose(); // ❌ The dispose method is called automatically when the [State] is closed, it's not necessary to close it manually.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height / 2.5;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ThrottleExamplePage'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            WText(
              title: 'Normal Scroll\n',
              subtitle: 'position: $normalScrollPosition',
            ),
            const SizedBox(height: 10),
            WText(
              title: 'Throttle Scroll\n',
              subtitle: 'position: $throttledScrollPosition',
            ),
            const SizedBox(height: 10),
            const WText(
              title: 'Throttle Interval\n',
              subtitle: 'config: leading: true, trailing: true,\ninterval: 1500 milliseconds',
            ),
            SizedBox(height: height)
          ],
        ),
      ),
    );
  }
}
