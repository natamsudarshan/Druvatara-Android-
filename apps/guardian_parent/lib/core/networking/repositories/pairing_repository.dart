import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';

part 'pairing_repository.g.dart';

@Riverpod(keepAlive: true)
PairingRepository pairingRepository(PairingRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return PairingRepository(dio);
}

class PairingRepository {
  final Dio _dio;

  PairingRepository(this._dio);

  Future<PairingResponse> createPairing(CreatePairingRequest request) async {
    final response = await _dio.post('/pairing/sessions', data: request.toJson());
    return PairingResponse.fromJson(response.data);
  }

  Future<PairingResponse> getPairingStatus(String pairingId) async {
    final response = await _dio.get('/pairing/sessions/$pairingId');
    return PairingResponse.fromJson(response.data);
  }

  Future<PairingConfirmResponse> confirmPairing(String pairingId) async {
    final response = await _dio.post('/pairing/sessions/$pairingId/confirm');
    return PairingConfirmResponse.fromJson(response.data);
  }

  Future<void> cancelPairing(String pairingId) async {
    await _dio.delete('/pairing/sessions/$pairingId');
  }

  Future<PairingClaimResponse> claimPairing(String pairingCode, Map<String, dynamic> deviceInfo) async {
    final response = await _dio.post('/pairing/device/claim', data: {'pairingCode': pairingCode, ...deviceInfo});
    return PairingClaimResponse.fromJson(response.data);
  }
}

class CreatePairingRequest {
  final String familyId;
  final String childId;
  final String platform;
  final String? deviceInternalId;

  CreatePairingRequest({
    required this.familyId,
    required this.childId,
    required this.platform,
    this.deviceInternalId,
  });

  Map<String, dynamic> toJson() => {
    'familyId': familyId,
    'childId': childId,
    'platform': platform,
    'deviceInternalId': deviceInternalId,
  };
}

class PairingResponse {
  final PairingSession session;

  PairingResponse({required this.session});

  factory PairingResponse.fromJson(Map<String, dynamic> json) {
    return PairingResponse(session: PairingSession.fromJson(json['data'] ?? json));
  }
}

class PairingSession {
  final String id;
  final String familyId;
  final String childId;
  final String platform;
  final String pairingCode;
  final String qrPayload;
  final String? deviceInternalId;
  final Map<String, dynamic>? deviceInfo;
  final String status;
  final DateTime expiresAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? usedAt;
  final DateTime? claimedAt;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FamilyInfo? family;
  final ChildInfo? child;

  PairingSession({
    required this.id,
    required this.familyId,
    required this.childId,
    required this.platform,
    required this.pairingCode,
    required this.qrPayload,
    this.deviceInternalId,
    this.deviceInfo,
    required this.status,
    required this.expiresAt,
    this.confirmedAt,
    this.cancelledAt,
    this.usedAt,
    this.claimedAt,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    this.family,
    this.child,
  });

  factory PairingSession.fromJson(Map<String, dynamic> json) {
    return PairingSession(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      childId: json['childId'] ?? '',
      platform: json['platform'] ?? '',
      pairingCode: json['pairingCode'] ?? '',
      qrPayload: json['qrPayload'] ?? '',
      deviceInternalId: json['deviceInternalId'],
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
      status: json['status'] ?? 'PENDING',
      expiresAt: DateTime.parse(json['expiresAt']),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      claimedAt: json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
      deviceId: json['deviceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      family: json['family'] != null ? FamilyInfo.fromJson(json['family']) : null,
      child: json['child'] != null ? ChildInfo.fromJson(json['child']) : null,
    );
  }
}

class FamilyInfo {
  final String id;
  final String name;

  FamilyInfo({required this.id, required this.name});

  factory FamilyInfo.fromJson(Map<String, dynamic> json) {
    return FamilyInfo(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class ChildInfo {
  final String id;
  final String displayName;
  final String ageGroup;

  ChildInfo({required this.id, required this.displayName, required this.ageGroup});

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
    );
  }
}

class PairingConfirmResponse {
  final bool success;
  final String pairingId;

  PairingConfirmResponse({required this.success, required this.pairingId});

  factory PairingConfirmResponse.fromJson(Map<String, dynamic> json) {
    return PairingConfirmResponse(success: json['success'] ?? false, pairingId: json['pairingId'] ?? '');
  }
}

class PairingClaimResponse {
  final PairingSession session;

  PairingClaimResponse({required this.session});

  factory PairingClaimResponse.fromJson(Map<String, dynamic> json) {
    return PairingClaimResponse(session: PairingSession.fromJson(json['data'] ?? json));
  }
}