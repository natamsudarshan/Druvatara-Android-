import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/child_repository.dart';

part 'child_provider.g.dart';

@Riverpod(keepAlive: true)
class ChildNotifier extends _$ChildNotifier {
  @override
  ChildState build() {
    return ChildState.initial();
  }

  Future<void> createChild(String familyId, String displayName, String ageGroup, {String? avatarId}) async {
    state = ChildState.loading();
    try {
      final repo = ref.read(childRepositoryProvider);
      final response = await repo.createChild(familyId, CreateChildRequest(
        displayName: displayName,
        ageGroup: ageGroup,
        avatarId: avatarId,
      ));
      state = ChildState.loaded(children: [response.child, ...state.children]);
    } catch (e) {
      state = ChildState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadChildren(String familyId) async {
    state = ChildState.loading();
    try {
      final repo = ref.read(childRepositoryProvider);
      final response = await repo.getChildren(familyId);
      state = ChildState.loaded(children: response.children);
    } catch (e) {
      state = ChildState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadChild(String childId) async {
    state = ChildState.loading();
    try {
      final repo = ref.read(childRepositoryProvider);
      final response = await repo.getChild(childId);
      state = ChildState.loaded(selectedChild: response.child, children: state.children);
    } catch (e) {
      state = ChildState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadChildSummary(String childId) async {
    try {
      final repo = ref.read(childRepositoryProvider);
      final response = await repo.getChildSummary(childId);
      state = state.copyWith(summary: response.summary);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updateChild(String childId, {String? displayName, String? ageGroup, String? avatarId, Map<String, dynamic>? settings}) async {
    state = ChildState.loading();
    try {
      final repo = ref.read(childRepositoryProvider);
      final response = await repo.updateChild(childId, UpdateChildRequest(
        displayName: displayName,
        ageGroup: ageGroup,
        avatarId: avatarId,
        settings: settings,
      ));
      final updatedChildren = state.children.map((c) => c.id == childId ? response.child : c).toList();
      Child? selected = state.selectedChild?.id == childId ? response.child : state.selectedChild;
      state = ChildState.loaded(children: updatedChildren, selectedChild: selected, summary: state.summary);
    } catch (e) {
      state = ChildState.error(e.toString());
      rethrow;
    }
  }

  Future<void> deleteChild(String childId) async {
    final repo = ref.read(childRepositoryProvider);
    await repo.deleteChild(childId);
    final updatedChildren = state.children.where((c) => c.id != childId).toList();
    Child? selected = state.selectedChild?.id == childId ? null : state.selectedChild;
    state = ChildState.loaded(children: updatedChildren, selectedChild: selected);
  }
}

class ChildState {
  final List<Child> children;
  final Child? selectedChild;
  final ChildSummary? summary;
  final String? error;
  final bool isLoading;

  const ChildState._({
    this.children = const [],
    this.selectedChild,
    this.summary,
    this.error,
    this.isLoading = false,
  });

  factory ChildState.initial() => const ChildState._();
  factory ChildState.loading() => const ChildState._(isLoading: true);
  factory ChildState.loaded({List<Child> children = const [], Child? selectedChild, ChildSummary? summary}) =>
      ChildState._(children: children, selectedChild: selectedChild, summary: summary);
  factory ChildState.error(String message) => ChildState._(error: message);

  ChildState copyWith({List<Child>? children, Child? selectedChild, ChildSummary? summary, String? error, bool? isLoading}) {
    return ChildState._(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      summary: summary ?? this.summary,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}