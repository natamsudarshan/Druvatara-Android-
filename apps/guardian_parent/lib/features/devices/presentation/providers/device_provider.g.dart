// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeviceNotifier)
final deviceProvider = DeviceNotifierProvider._();

final class DeviceNotifierProvider
    extends $NotifierProvider<DeviceNotifier, DeviceState> {
  DeviceNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceNotifierHash();

  @$internal
  @override
  DeviceNotifier create() => DeviceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceState>(value),
    );
  }
}

String _$deviceNotifierHash() => r'6f91370f7e008fad516373565b6f40746dcc92ca';

abstract class _$DeviceNotifier extends $Notifier<DeviceState> {
  DeviceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DeviceState, DeviceState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DeviceState, DeviceState>, DeviceState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
