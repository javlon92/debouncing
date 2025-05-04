import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:debouncing_example/src/src.dart';

class DebounceExample2Page extends StatelessWidget {
  const DebounceExample2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DebounceExample2Provider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('DebounceExamplePage'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<DebounceExample2Provider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WText(
                    title: 'WithOutResettableEvent:\n',
                    subtitle: provider.state.withoutResettableText,
                  ),
                  const SizedBox(height: 20),
                  WText(
                    title: 'WithResettableEvent:\n',
                    subtitle: provider.state.withResettableText,
                  ),
                  const SizedBox(height: 20),
                  WTextField(
                    labelText: 'TextField for WithOutResettableEvent',
                    isLoading: provider.state.withoutResettableTextStatus.isLoading,
                    onChanged: (text) {
                      provider.onChangedWithoutResettable(text: text);
                    },
                  ),
                  const SizedBox(height: 20),
                  WTextField(
                    labelText: 'TextField fot WithResettableEvent',
                    isLoading: provider.state.withResettableTextStatus.isLoading,
                    onChanged: (text) {
                      provider.onChangedWithResettable(text: text);
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
