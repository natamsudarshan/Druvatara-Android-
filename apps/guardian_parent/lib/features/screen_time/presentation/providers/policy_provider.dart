import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/policy_repository.dart';

part 'policy_provider.g.dart';

@Riverpod(keepAlive: true)
class PolicyNotifier extends _$PolicyNotifier {
  @override
  PolicyState build() {
    return PolicyState.initial();
  }

  Future<void> createPolicy(String familyId, String childId, CreatePolicyRequest request) async {
    state = PolicyState.loading();
    try {
      final repo = ref.read(policyRepositoryProvider);
      final response = await repo.createPolicy(familyId, childId, request);
      state = PolicyState.loaded(policies: [response.policy, ...state.policies], currentPolicy: response.policy);
    } catch (e) {
      state = PolicyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadLatestPolicy(String familyId, String childId) async {
    state = PolicyState.loading();
    try {
      final repo = ref.read(policyRepositoryProvider);
      final response = await repo.getLatestPolicy(familyId, childId);
      state = PolicyState.loaded(currentPolicy: response.policy, policies: state.policies);
    } catch (e) {
      state = PolicyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadPolicyHistory(String familyId, String childId) async {
    try {
      final repo = ref.read(policyRepositoryProvider);
      final response = await repo.getPolicyHistory(familyId, childId);
      state = state.copyWith(policies: response.policies);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updatePolicy(String familyId, String childId, UpdatePolicyRequest request) async {
    state = PolicyState.loading();
    try {
      final repo = ref.read(policyRepositoryProvider);
      final response = await repo.updatePolicy(familyId, childId, request);
      final updatedPolicies = state.policies.map((p) => p.id == response.policy.id ? response.policy : p).toList();
      state = PolicyState.loaded(policies: updatedPolicies, currentPolicy: response.policy);
    } catch (e) {
      state = PolicyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> rollbackPolicy(String familyId, String childId, int version) async {
    state = PolicyState.loading();
    try {
      final repo = ref.read(policyRepositoryProvider);
      final response = await repo.rollbackPolicy(familyId, childId, version);
      final updatedPolicies = state.policies.map((p) => p.id == response.policy.id ? response.policy : p).toList();
      state = PolicyState.loaded(policies: updatedPolicies, currentPolicy: response.policy);
    } catch (e) {
      state = PolicyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> acknowledgePolicy(String deviceId, int policyVersion, bool success, {String? error}) async {
    final repo = ref.read(policyRepositoryProvider);
    await repo.acknowledgePolicy(deviceId, policyVersion, success, error: error);
  }
}

class PolicyState {
  final List<Policy> policies;
  final Policy? currentPolicy;
  final String? error;
  final bool isLoading;

  const PolicyState._({
    this.policies = const [],
    this.currentPolicy,
    this.error,
    this.isLoading = false,
  });

  factory PolicyState.initial() => const PolicyState._();
  factory PolicyState.loading() => const PolicyState._(isLoading: true);
  factory PolicyState.loaded({List<Policy> policies = const [], Policy? currentPolicy}) =>
      PolicyState._(policies: policies, currentPolicy: currentPolicy);
  factory PolicyState.error(String message) => PolicyState._(error: message);

  PolicyState copyWith({List<Policy>? policies, Policy? currentPolicy, String? error, bool? isLoading}) {
    return PolicyState._(
      policies: policies ?? this.policies,
      currentPolicy: currentPolicy ?? this.currentPolicy,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}