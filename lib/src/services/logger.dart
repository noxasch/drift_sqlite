import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print(
        '{"provider": "${provider.name ?? provider.runtimeType}", "newValue": "$newValue"}');
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer containers) {
    print('${provider.name ?? provider.runtimeType} has been disposed.');
  }
}
