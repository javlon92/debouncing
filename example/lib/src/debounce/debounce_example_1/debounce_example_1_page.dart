import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debouncing_example/src/src.dart';

class DebounceExample1Page extends StatelessWidget {
  const DebounceExample1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebounceExample1Bloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('DebounceExamplePage'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<DebounceExample1Bloc, DebounceExample1State>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WText(
                    title: 'WithOutResettableEvent:\n',
                    subtitle: state.withoutResettableText,
                  ),
                  const SizedBox(height: 20),
                  WText(
                    title: 'WithResettableEvent:\n',
                    subtitle: state.withResettableText,
                  ),
                  const SizedBox(height: 20),
                  WTextField(
                    labelText: 'TextField for WithOutResettableEvent',
                    isLoading: state.withoutResettableTextStatus.isLoading,
                    onChanged: (text) {
                      context.read<DebounceExample1Bloc>().add(OnChangedWithoutResettable(text: text));
                    },
                  ),
                  const SizedBox(height: 20),
                  WTextField(
                    labelText: 'TextField fot WithResettableEvent',
                    isLoading: state.withResettableTextStatus.isLoading,
                    onChanged: (text) {
                      context.read<DebounceExample1Bloc>().add(OnChangedWithResettable(text: text));
                    },
                  ),
                ],
              );
            },
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class WText extends StatelessWidget {
  final String title;
  final String subtitle;

  const WText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: title,
          style: Theme.of(context).textTheme.headlineSmall,
          children: [
            TextSpan(
              text: subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class WTextField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool isLoading;
  final String labelText;

  const WTextField({
    super.key,
    this.onChanged,
    required this.isLoading,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        suffix: Visibility(
          visible: isLoading,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
