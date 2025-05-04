import 'package:debouncing_example/src/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThrottleExample1Page extends StatelessWidget {
  const ThrottleExample1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height / 2.5;
    return BlocProvider(
      create: (_) => ThrottleExample1Cubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('ThrottleExamplePage'),
        ),
        body: BlocBuilder<ThrottleExample1Cubit, ThrottleExample1State>(
          builder: (context, state) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                context.read<ThrottleExample1Cubit>().onScroll(scrollPosition: notification.metrics.pixels);
                return false;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  children: [
                    WText(
                      title: 'Normal Scroll\n',
                      subtitle: 'position: ${state.normalScrollPosition}',
                    ),
                    const SizedBox(height: 10),
                    WText(
                      title: 'Throttle Scroll\n',
                      subtitle: 'position: ${state.throttleScrollPosition}',
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
          },
        ),
      ),
    );
  }
}
