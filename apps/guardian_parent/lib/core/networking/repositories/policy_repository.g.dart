// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(policyRepository)
final policyRepositoryProvider = PolicyRepositoryProvider._();

final class PolicyRepositoryProvider extends $FunctionalProvider<
    PolicyRepository,
    PolicyRepository,
    PolicyRepository> with $Provider<PolicyRepository> {
  PolicyRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'policyRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$policyRepositoryHash();

  @$internal
  @override
  $ProviderElement<PolicyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PolicyRepository create(Ref ref) {
    return policyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolicyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolicyRepository>(value),
    );
  }
}

String _$policyRepositoryHash() => r'bb2931ac94a1811c6432b08db24a66b813ac8ce7';
