// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(childRepository)
final childRepositoryProvider = ChildRepositoryProvider._();

final class ChildRepositoryProvider extends $FunctionalProvider<ChildRepository,
    ChildRepository, ChildRepository> with $Provider<ChildRepository> {
  ChildRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'childRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$childRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChildRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChildRepository create(Ref ref) {
    return childRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChildRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChildRepository>(value),
    );
  }
}

String _$childRepositoryHash() => r'0d1013e5d07801a527fd00520cd794af1b47fc9b';
