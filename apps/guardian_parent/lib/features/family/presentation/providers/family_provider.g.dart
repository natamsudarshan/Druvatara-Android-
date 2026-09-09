// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FamilyNotifier)
final familyProvider = FamilyNotifierProvider._();

final class FamilyNotifierProvider
    extends $NotifierProvider<FamilyNotifier, FamilyState> {
  FamilyNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familyProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familyNotifierHash();

  @$internal
  @override
  FamilyNotifier create() => FamilyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyState>(value),
    );
  }
}

String _$familyNotifierHash() => r'b035f894e4a7fdab8d1f087459f1c7c7ac004bbe';

abstract class _$FamilyNotifier extends $Notifier<FamilyState> {
  FamilyState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FamilyState, FamilyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FamilyState, FamilyState>, FamilyState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
