// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pairingRepository)
final pairingRepositoryProvider = PairingRepositoryProvider._();

final class PairingRepositoryProvider extends $FunctionalProvider<
    PairingRepository,
    PairingRepository,
    PairingRepository> with $Provider<PairingRepository> {
  PairingRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pairingRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pairingRepositoryHash();

  @$internal
  @override
  $ProviderElement<PairingRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PairingRepository create(Ref ref) {
    return pairingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingRepository>(value),
    );
  }
}

String _$pairingRepositoryHash() => r'5704414c8ae50de3bb608cc31b102e16dc617750';
