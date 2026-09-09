// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PairingNotifier)
final pairingProvider = PairingNotifierProvider._();

final class PairingNotifierProvider
    extends $NotifierProvider<PairingNotifier, PairingState> {
  PairingNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pairingProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pairingNotifierHash();

  @$internal
  @override
  PairingNotifier create() => PairingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingState>(value),
    );
  }
}

String _$pairingNotifierHash() => r'75ad812682f80fd9f54f6fa0d2454e1762a76d67';

abstract class _$PairingNotifier extends $Notifier<PairingState> {
  PairingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PairingState, PairingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PairingState, PairingState>,
        PairingState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
