import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/family_repository.dart';

part 'family_provider.g.dart';

@Riverpod(keepAlive: true)
class FamilyNotifier extends _$FamilyNotifier {
  @override
  FamilyState build() {
    return FamilyState.initial();
  }

  Future<void> createFamily(String name, {String timezone = 'Asia/Kolkata', String language = 'en'}) async {
    state = FamilyState.loading();
    try {
      final repo = ref.read(familyRepositoryProvider);
      final response = await repo.createFamily(CreateFamilyRequest(
        name: name,
        timezone: timezone,
        language: language,
      ));
      state = FamilyState.loaded(family: response.family);
    } catch (e) {
      state = FamilyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadFamily(String familyId) async {
    state = FamilyState.loading();
    try {
      final repo = ref.read(familyRepositoryProvider);
      final response = await repo.getFamily(familyId);
      state = FamilyState.loaded(family: response.family);
    } catch (e) {
      state = FamilyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadSummary(String familyId) async {
    try {
      final repo = ref.read(familyRepositoryProvider);
      final response = await repo.getFamilySummary(familyId);
      state = state.copyWith(summary: response.summary);
    } catch (e) {
      // Silently fail for summary
    }
  }

  Future<void> loadEntitlements(String familyId) async {
    try {
      final repo = ref.read(familyRepositoryProvider);
      final response = await repo.getEntitlements(familyId);
      state = state.copyWith(entitlements: response.entitlements);
    } catch (e) {
      // Silently fail for entitlements
    }
  }

  Future<void> updateFamily(String familyId, {String? name, String? timezone, String? language, Map<String, dynamic>? settings}) async {
    state = FamilyState.loading();
    try {
      final repo = ref.read(familyRepositoryProvider);
      final response = await repo.updateFamily(familyId, UpdateFamilyRequest(
        name: name,
        timezone: timezone,
        language: language,
        settings: settings,
      ));
      state = FamilyState.loaded(family: response.family, summary: state.summary, entitlements: state.entitlements);
    } catch (e) {
      state = FamilyState.error(e.toString());
      rethrow;
    }
  }

  Future<void> inviteCoParent(String familyId, String email, {String role = 'MEMBER', Map<String, dynamic>? permissions}) async {
    state = FamilyState.loading();
    try {
      final repo = ref.read(familyRepositoryProvider);
      await repo.inviteCoParent(familyId, InviteCoParentRequest(
        email: email,
        role: role,
        permissions: permissions ?? {'viewAlerts': true, 'viewLocation': true, 'approveRequests': false, 'modifyPolicies': false},
      ));
      state = state.copyWith();
    } catch (e) {
      state = FamilyState.error(e.toString());
      rethrow;
    }
  }

  Future<List<Member>> getMembers(String familyId) async {
    final repo = ref.read(familyRepositoryProvider);
    final response = await repo.getMembers(familyId);
    return response.members;
  }

  Future<void> removeMember(String familyId, String memberId) async {
    final repo = ref.read(familyRepositoryProvider);
    await repo.removeMember(familyId, memberId);
  }

  Future<void> updateMemberPermission(String familyId, String memberId, String role, Map<String, dynamic> permissions) async {
    final repo = ref.read(familyRepositoryProvider);
    await repo.updateMemberPermission(familyId, memberId, UpdateMemberRequest(role: role, permissions: permissions));
  }
}

class FamilyState {
  final Family? family;
  final FamilySummary? summary;
  final Entitlements? entitlements;
  final String? error;
  final bool isLoading;

  const FamilyState._({
    this.family,
    this.summary,
    this.entitlements,
    this.error,
    this.isLoading = false,
  });

  factory FamilyState.initial() => const FamilyState._();
  factory FamilyState.loading() => const FamilyState._(isLoading: true);
  factory FamilyState.loaded({Family? family, FamilySummary? summary, Entitlements? entitlements}) =>
      FamilyState._(family: family, summary: summary, entitlements: entitlements);
  factory FamilyState.error(String message) => FamilyState._(error: message);

  FamilyState copyWith({Family? family, FamilySummary? summary, Entitlements? entitlements, String? error, bool? isLoading}) {
    return FamilyState._(
      family: family ?? this.family,
      summary: summary ?? this.summary,
      entitlements: entitlements ?? this.entitlements,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}