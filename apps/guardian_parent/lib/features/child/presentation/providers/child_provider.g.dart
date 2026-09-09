// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChildNotifier)
final childProvider = ChildNotifierProvider._();

final class ChildNotifierProvider
    extends $NotifierProvider<ChildNotifier, ChildState> {
  ChildNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'childProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$childNotifierHash();

  @$internal
  @override
  ChildNotifier create() => ChildNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChildState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChildState>(value),
    );
  }
}

String _$childNotifierHash() => r'deb9d7f36fe8270ca816ea432315cbf4fa5e4888';

abstract class _$ChildNotifier extends $Notifier<ChildState> {
  ChildState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChildState, ChildState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ChildState, ChildState>, ChildState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
