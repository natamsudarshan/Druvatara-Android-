import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';

part 'child_repository.g.dart';

@Riverpod(keepAlive: true)
ChildRepository childRepository(ChildRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return ChildRepository(dio);
}

class ChildRepository {
  final Dio _dio;

  ChildRepository(this._dio);

  Future<ChildResponse> createChild(String familyId, CreateChildRequest request) async {
    final response = await _dio.post('/families/$familyId/children', data: request.toJson());
    return ChildResponse.fromJson(response.data);
  }

  Future<ChildListResponse> getChildren(String familyId) async {
    final response = await _dio.get('/families/$familyId/children');
    return ChildListResponse.fromJson(response.data);
  }

  Future<ChildResponse> getChild(String childId) async {
    final response = await _dio.get('/children/$childId');
    return ChildResponse.fromJson(response.data);
  }

  Future<ChildResponse> updateChild(String childId, UpdateChildRequest request) async {
    final response = await _dio.patch('/children/$childId', data: request.toJson());
    return ChildResponse.fromJson(response.data);
  }

  Future<void> deleteChild(String childId) async {
    await _dio.delete('/children/$childId');
  }

  Future<ChildSummaryResponse> getChildSummary(String childId) async {
    final response = await _dio.get('/children/$childId/summary');
    return ChildSummaryResponse.fromJson(response.data);
  }
}

class CreateChildRequest {
  final String displayName;
  final String ageGroup;
  final String? avatarId;

  CreateChildRequest({required this.displayName, required this.ageGroup, this.avatarId});

  Map<String, dynamic> toJson() => {'displayName': displayName, 'ageGroup': ageGroup, 'avatarId': avatarId};
}

class UpdateChildRequest {
  final String? displayName;
  final String? ageGroup;
  final String? avatarId;
  final Map<String, dynamic>? settings;

  UpdateChildRequest({this.displayName, this.ageGroup, this.avatarId, this.settings});

  Map<String, dynamic> toJson() => {
    if (displayName != null) 'displayName': displayName,
    if (ageGroup != null) 'ageGroup': ageGroup,
    if (avatarId != null) 'avatarId': avatarId,
    if (settings != null) 'settings': settings,
  };
}

class ChildResponse {
  final Child child;

  ChildResponse({required this.child});

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    return ChildResponse(child: Child.fromJson(json['data'] ?? json));
  }
}

class Child {
  final String id;
  final String familyId;
  final String displayName;
  final String name;
  final String ageGroup;
  final String? avatarId;
  final int? birthYear;
  final int? birthMonth;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.familyId,
    required this.displayName,
    required this.name,
    required this.ageGroup,
    this.avatarId,
    this.birthYear,
    this.birthMonth,
    required this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      displayName: json['displayName'] ?? '',
      name: json['name'] ?? '',
      ageGroup: json['ageGroup'] ?? 'PRE_TEEN',
      avatarId: json['avatarId'],
      birthYear: json['birthYear'],
      birthMonth: json['birthMonth'],
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ChildListResponse {
  final List<Child> children;

  ChildListResponse({required this.children});

  factory ChildListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return ChildListResponse(children: data.map((e) => Child.fromJson(e)).toList());
  }
}

class ChildSummaryResponse {
  final ChildSummary summary;

  ChildSummaryResponse({required this.summary});

  factory ChildSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ChildSummaryResponse(summary: ChildSummary.fromJson(json['data'] ?? json));
  }
}

class ChildSummary {
  final String id;
  final String displayName;
  final String ageGroup;
  final String? avatarId;
  final String protectionState;
  final int? screenTimeToday;
  final int? screenTimeLimit;
  final bool hasPendingRequests;
  final int unresolvedAlerts;
  final DeviceInfo? currentDevice;

  ChildSummary({
    required this.id,
    required this.displayName,
    required this.ageGroup,
    this.avatarId,
    required this.protectionState,
    this.screenTimeToday,
    this.screenTimeLimit,
    required this.hasPendingRequests,
    required this.unresolvedAlerts,
    this.currentDevice,
  });

  factory ChildSummary.fromJson(Map<String, dynamic> json) {
    return ChildSummary(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
      avatarId: json['avatarId'],
      protectionState: json['protectionState'] ?? 'unknown',
      screenTimeToday: json['screenTimeToday'],
      screenTimeLimit: json['screenTimeLimit'],
      hasPendingRequests: json['hasPendingRequests'] ?? false,
      unresolvedAlerts: json['unresolvedAlerts'] ?? 0,
      currentDevice: json['currentDevice'] != null ? DeviceInfo.fromJson(json['currentDevice']) : null,
    );
  }
}

class DeviceInfo {
  final String id;
  final String name;
  final String platform;
  final String status;
  final DateTime? lastSeenAt;

  DeviceInfo({
    required this.id,
    required this.name,
    required this.platform,
    required this.status,
    this.lastSeenAt,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      platform: json['platform'] ?? '',
      status: json['status'] ?? 'unknown',
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
    );
  }
}