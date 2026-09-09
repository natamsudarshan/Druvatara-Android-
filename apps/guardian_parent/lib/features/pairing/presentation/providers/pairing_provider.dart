import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/pairing_repository.dart';

part 'pairing_provider.g.dart';

@Riverpod(keepAlive: true)
class PairingNotifier extends _$PairingNotifier {
  @override
  PairingState build() {
    return PairingState.initial();
  }

  Future<void> createPairing(String familyId, String childId, String platform, {String? deviceInternalId}) async {
    state = PairingState.loading();
    try {
      final repo = ref.read(pairingRepositoryProvider);
      final response = await repo.createPairing(CreatePairingRequest(
        familyId: familyId,
        childId: childId,
        platform: platform,
        deviceInternalId: deviceInternalId,
      ));
      state = PairingState.loaded(session: response.session);
    } catch (e) {
      state = PairingState.error(e.toString());
      rethrow;
    }
  }

  Future<void> getPairingStatus(String pairingId) async {
    state = PairingState.loading();
    try {
      final repo = ref.read(pairingRepositoryProvider);
      final response = await repo.getPairingStatus(pairingId);
      state = PairingState.loaded(session: response.session);
    } catch (e) {
      state = PairingState.error(e.toString());
      rethrow;
    }
  }

  Future<void> confirmPairing(String pairingId) async {
    state = PairingState.loading();
    try {
      final repo = ref.read(pairingRepositoryProvider);
      final response = await repo.confirmPairing(pairingId);
      state = state.copyWith(confirmed: response.success);
    } catch (e) {
      state = PairingState.error(e.toString());
      rethrow;
    }
  }

  Future<void> cancelPairing(String pairingId) async {
    final repo = ref.read(pairingRepositoryProvider);
    await repo.cancelPairing(pairingId);
    state = PairingState.initial();
  }

  Future<PairingSession?> claimPairing(String pairingCode, Map<String, dynamic> deviceInfo) async {
    try {
      final repo = ref.read(pairingRepositoryProvider);
      final response = await repo.claimPairing(pairingCode, deviceInfo);
      return response.session;
    } catch (e) {
      return null;
    }
  }

  void reset() {
    state = PairingState.initial();
  }
}

class PairingState {
  final PairingSession? session;
  final bool confirmed;
  final String? error;
  final bool isLoading;

  const PairingState._({
    this.session,
    this.confirmed = false,
    this.error,
    this.isLoading = false,
  });

  factory PairingState.initial() => const PairingState._();
  factory PairingState.loading() => const PairingState._(isLoading: true);
  factory PairingState.loaded({PairingSession? session, bool confirmed = false}) =>
      PairingState._(session: session, confirmed: confirmed);
  factory PairingState.error(String message) => PairingState._(error: message);

  PairingState copyWith({PairingSession? session, bool? confirmed, String? error, bool? isLoading}) {
    return PairingState._(
      session: session ?? this.session,
      confirmed: confirmed ?? this.confirmed,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}