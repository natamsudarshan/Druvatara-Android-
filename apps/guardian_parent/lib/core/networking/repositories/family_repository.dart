import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';

part 'family_repository.g.dart';

@Riverpod(keepAlive: true)
FamilyRepository familyRepository(FamilyRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return FamilyRepository(dio);
}

class FamilyRepository {
  final Dio _dio;

  FamilyRepository(this._dio);

  Future<FamilyResponse> createFamily(CreateFamilyRequest request) async {
    final response = await _dio.post('/families', data: request.toJson());
    return FamilyResponse.fromJson(response.data);
  }

  Future<FamilyResponse> getFamily(String familyId) async {
    final response = await _dio.get('/families/$familyId');
    return FamilyResponse.fromJson(response.data);
  }

  Future<FamilyResponse> updateFamily(String familyId, UpdateFamilyRequest request) async {
    final response = await _dio.patch('/families/$familyId', data: request.toJson());
    return FamilyResponse.fromJson(response.data);
  }

  Future<void> deleteFamily(String familyId) async {
    await _dio.delete('/families/$familyId');
  }

  Future<FamilySummaryResponse> getFamilySummary(String familyId) async {
    final response = await _dio.get('/families/$familyId/summary');
    return FamilySummaryResponse.fromJson(response.data);
  }

  Future<EntitlementsResponse> getEntitlements(String familyId) async {
    final response = await _dio.get('/families/$familyId/entitlements');
    return EntitlementsResponse.fromJson(response.data);
  }

  Future<MemberListResponse> getMembers(String familyId) async {
    final response = await _dio.get('/families/$familyId/members');
    return MemberListResponse.fromJson(response.data);
  }

  Future<InvitationResponse> inviteCoParent(String familyId, InviteCoParentRequest request) async {
    final response = await _dio.post('/families/$familyId/invitations', data: request.toJson());
    return InvitationResponse.fromJson(response.data);
  }

  Future<InvitationResponse> getInvitation(String token) async {
    final response = await _dio.get('/family-invitations/$token');
    return InvitationResponse.fromJson(response.data);
  }

  Future<void> acceptInvitation(String token) async {
    await _dio.post('/family-invitations/$token/accept');
  }

  Future<void> removeMember(String familyId, String memberId) async {
    await _dio.delete('/families/$familyId/members/$memberId');
  }

  Future<MemberResponse> updateMemberPermission(String familyId, String memberId, UpdateMemberRequest request) async {
    final response = await _dio.patch('/families/$familyId/members/$memberId', data: request.toJson());
    return MemberResponse.fromJson(response.data);
  }
}

class CreateFamilyRequest {
  final String name;
  final String timezone;
  final String language;

  CreateFamilyRequest({required this.name, this.timezone = 'Asia/Kolkata', this.language = 'en'});

  Map<String, dynamic> toJson() => {'name': name, 'timezone': timezone, 'language': language};
}

class UpdateFamilyRequest {
  final String? name;
  final String? timezone;
  final String? language;
  final Map<String, dynamic>? settings;

  UpdateFamilyRequest({this.name, this.timezone, this.language, this.settings});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (timezone != null) 'timezone': timezone,
    if (language != null) 'language': language,
    if (settings != null) 'settings': settings,
  };
}

class FamilyResponse {
  final Family family;

  FamilyResponse({required this.family});

  factory FamilyResponse.fromJson(Map<String, dynamic> json) {
    return FamilyResponse(family: Family.fromJson(json['data'] ?? json));
  }
}

class Family {
  final String id;
  final String name;
  final String ownerId;
  final String timezone;
  final String language;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Family({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.timezone,
    required this.language,
    required this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ownerId: json['ownerId'] ?? '',
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      language: json['language'] ?? 'en',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FamilySummaryResponse {
  final FamilySummary summary;

  FamilySummaryResponse({required this.summary});

  factory FamilySummaryResponse.fromJson(Map<String, dynamic> json) {
    return FamilySummaryResponse(summary: FamilySummary.fromJson(json['data'] ?? json));
  }
}

class FamilySummary {
  final int childrenCount;
  final int devicesCount;
  final int unresolvedAlerts;
  final int pendingRequests;
  final String protectionState;

  FamilySummary({
    required this.childrenCount,
    required this.devicesCount,
    required this.unresolvedAlerts,
    required this.pendingRequests,
    required this.protectionState,
  });

  factory FamilySummary.fromJson(Map<String, dynamic> json) {
    return FamilySummary(
      childrenCount: json['childrenCount'] ?? 0,
      devicesCount: json['devicesCount'] ?? 0,
      unresolvedAlerts: json['unresolvedAlerts'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      protectionState: json['protectionState'] ?? 'unknown',
    );
  }
}

class EntitlementsResponse {
  final Entitlements entitlements;

  EntitlementsResponse({required this.entitlements});

  factory EntitlementsResponse.fromJson(Map<String, dynamic> json) {
    return EntitlementsResponse(entitlements: Entitlements.fromJson(json['data'] ?? json));
  }
}

class Entitlements {
  final int maxDevices;
  final bool taraEnabled;
  final bool weeklyReports;
  final bool premiumWebSafety;
  final bool locationHistory;
  final bool geofencing;

  Entitlements({
    required this.maxDevices,
    required this.taraEnabled,
    required this.weeklyReports,
    required this.premiumWebSafety,
    required this.locationHistory,
    required this.geofencing,
  });

  factory Entitlements.fromJson(Map<String, dynamic> json) {
    return Entitlements(
      maxDevices: json['maxDevices'] ?? 1,
      taraEnabled: json['taraEnabled'] ?? false,
      weeklyReports: json['weeklyReports'] ?? false,
      premiumWebSafety: json['premiumWebSafety'] ?? false,
      locationHistory: json['locationHistory'] ?? false,
      geofencing: json['geofencing'] ?? false,
    );
  }
}

class MemberListResponse {
  final List<Member> members;

  MemberListResponse({required this.members});

  factory MemberListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return MemberListResponse(members: data.map((e) => Member.fromJson(e)).toList());
  }
}

class Member {
  final String id;
  final String familyId;
  final String userId;
  final String role;
  final bool isActive;
  final Map<String, dynamic> permissions;
  final DateTime joinedAt;

  Member({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.isActive,
    required this.permissions,
    required this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      userId: json['userId'] ?? '',
      role: json['role'] ?? 'MEMBER',
      isActive: json['isActive'] ?? true,
      permissions: json['permissions'] as Map<String, dynamic>? ?? {},
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

class InvitationResponse {
  final Invitation invitation;

  InvitationResponse({required this.invitation});

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(invitation: Invitation.fromJson(json['data'] ?? json));
  }
}

class Invitation {
  final String id;
  final String familyId;
  final String senderId;
  final String email;
  final String role;
  final String status;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.familyId,
    required this.senderId,
    required this.email,
    required this.role,
    required this.status,
    required this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      senderId: json['senderId'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'PENDING',
      expiresAt: DateTime.parse(json['expiresAt']),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class InviteCoParentRequest {
  final String email;
  final String role;
  final Map<String, dynamic> permissions;

  InviteCoParentRequest({
    required this.email,
    this.role = 'MEMBER',
    this.permissions = const {'viewAlerts': true, 'viewLocation': true, 'approveRequests': false, 'modifyPolicies': false},
  });

  Map<String, dynamic> toJson() => {'email': email, 'role': role, 'permissions': permissions};
}

class UpdateMemberRequest {
  final String role;
  final Map<String, dynamic> permissions;

  UpdateMemberRequest({required this.role, required this.permissions});

  Map<String, dynamic> toJson() => {'role': role, 'permissions': permissions};
}

class MemberResponse {
  final Member member;

  MemberResponse({required this.member});

  factory MemberResponse.fromJson(Map<String, dynamic> json) {
    return MemberResponse(member: Member.fromJson(json['data'] ?? json));
  }
}