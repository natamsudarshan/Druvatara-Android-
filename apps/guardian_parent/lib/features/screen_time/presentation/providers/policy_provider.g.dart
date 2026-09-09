// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PolicyNotifier)
final policyProvider = PolicyNotifierProvider._();

final class PolicyNotifierProvider
    extends $NotifierProvider<PolicyNotifier, PolicyState> {
  PolicyNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'policyProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$policyNotifierHash();

  @$internal
  @override
  PolicyNotifier create() => PolicyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PolicyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PolicyState>(value),
    );
  }
}

String _$policyNotifierHash() => r'afc8bf0757b0066eb8c326b3065a1b70b34aab93';

abstract class _$PolicyNotifier extends $Notifier<PolicyState> {
  PolicyState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PolicyState, PolicyState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PolicyState, PolicyState>, PolicyState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
