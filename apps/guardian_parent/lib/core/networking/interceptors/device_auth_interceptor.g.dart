// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_auth_interceptor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceAuthInterceptor)
final deviceAuthInterceptorProvider = DeviceAuthInterceptorProvider._();

final class DeviceAuthInterceptorProvider extends $FunctionalProvider<
    DeviceAuthInterceptor,
    DeviceAuthInterceptor,
    DeviceAuthInterceptor> with $Provider<DeviceAuthInterceptor> {
  DeviceAuthInterceptorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceAuthInterceptorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceAuthInterceptorHash();

  @$internal
  @override
  $ProviderElement<DeviceAuthInterceptor> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceAuthInterceptor create(Ref ref) {
    return deviceAuthInterceptor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceAuthInterceptor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceAuthInterceptor>(value),
    );
  }
}

String _$deviceAuthInterceptorHash() =>
    r'cecd2f07acacdb83b0f9fe4c0ad712f66d4e47c8';
