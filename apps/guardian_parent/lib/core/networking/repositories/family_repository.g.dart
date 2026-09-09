// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(familyRepository)
final familyRepositoryProvider = FamilyRepositoryProvider._();

final class FamilyRepositoryProvider extends $FunctionalProvider<
    FamilyRepository,
    FamilyRepository,
    FamilyRepository> with $Provider<FamilyRepository> {
  FamilyRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familyRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familyRepositoryHash();

  @$internal
  @override
  $ProviderElement<FamilyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyRepository create(Ref ref) {
    return familyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyRepository>(value),
    );
  }
}

String _$familyRepositoryHash() => r'20ed5dd1bcc502a9e3e877d956a356754b416aaf';
