import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';

part 'policy_repository.g.dart';

@Riverpod(keepAlive: true)
PolicyRepository policyRepository(PolicyRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return PolicyRepository(dio);
}

class PolicyRepository {
  final Dio _dio;

  PolicyRepository(this._dio);

  Future<PolicyResponse> createPolicy(String familyId, String childId, CreatePolicyRequest request) async {
    final response = await _dio.post('/families/$familyId/children/$childId/policies', data: request.toJson());
    return PolicyResponse.fromJson(response.data);
  }

  Future<PolicyResponse> getLatestPolicy(String familyId, String childId) async {
    final response = await _dio.get('/families/$familyId/children/$childId/policies/latest');
    return PolicyResponse.fromJson(response.data);
  }

  Future<PolicyResponse> getPolicyByVersion(String familyId, String childId, int version) async {
    final response = await _dio.get('/families/$familyId/children/$childId/policies/$version');
    return PolicyResponse.fromJson(response.data);
  }

  Future<PolicyListResponse> getPolicyHistory(String familyId, String childId) async {
    final response = await _dio.get('/families/$familyId/children/$childId/policies');
    return PolicyListResponse.fromJson(response.data);
  }

  Future<PolicyResponse> updatePolicy(String familyId, String childId, UpdatePolicyRequest request) async {
    final response = await _dio.patch('/families/$familyId/children/$childId/policies', data: request.toJson());
    return PolicyResponse.fromJson(response.data);
  }

  Future<PolicyAcknowledgeResponse> acknowledgePolicy(String deviceId, int policyVersion, bool success, {String? error}) async {
    final response = await _dio.post('/families/$familyId/children/$childId/policies/$deviceId/acknowledge',
        queryParameters: {'familyId': familyId, 'childId': childId},
        data: {'policyVersion': policyVersion, 'success': success, 'error': error});
    return PolicyAcknowledgeResponse.fromJson(response.data);
  }

  Future<PolicyResponse> rollbackPolicy(String familyId, String childId, int version) async {
    final response = await _dio.post('/families/$familyId/children/$childId/policies/$version/rollback');
    return PolicyResponse.fromJson(response.data);
  }
}

class CreatePolicyRequest {
  final Map<String, dynamic> screenTime;
  final List<Map<String, dynamic>> applications;
  final List<Map<String, dynamic>> schedules;
  final Map<String, dynamic> webSafety;
  final Map<String, dynamic> location;
  final List<Map<String, dynamic>> safeZones;
  final List<String> essentialApps;
  final Map<String, dynamic> temporaryOverrides;

  CreatePolicyRequest({
    required this.screenTime,
    required this.applications,
    required this.schedules,
    required this.webSafety,
    required this.location,
    required this.safeZones,
    required this.essentialApps,
    this.temporaryOverrides = const {},
  });

  Map<String, dynamic> toJson() => {
    'screenTime': screenTime,
    'applications': applications,
    'schedules': schedules,
    'webSafety': webSafety,
    'location': location,
    'safeZones': safeZones,
    'essentialApps': essentialApps,
    'temporaryOverrides': temporaryOverrides,
  };
}

class UpdatePolicyRequest {
  final Map<String, dynamic>? screenTime;
  final List<Map<String, dynamic>>? applications;
  final List<Map<String, dynamic>>? schedules;
  final Map<String, dynamic>? webSafety;
  final Map<String, dynamic>? location;
  final List<Map<String, dynamic>>? safeZones;
  final List<String>? essentialApps;
  final Map<String, dynamic>? temporaryOverrides;

  UpdatePolicyRequest({
    this.screenTime,
    this.applications,
    this.schedules,
    this.webSafety,
    this.location,
    this.safeZones,
    this.essentialApps,
    this.temporaryOverrides,
  });

  Map<String, dynamic> toJson() => {
    if (screenTime != null) 'screenTime': screenTime,
    if (applications != null) 'applications': applications,
    if (schedules != null) 'schedules': schedules,
    if (webSafety != null) 'webSafety': webSafety,
    if (location != null) 'location': location,
    if (safeZones != null) 'safeZones': safeZones,
    if (essentialApps != null) 'essentialApps': essentialApps,
    if (temporaryOverrides != null) 'temporaryOverrides': temporaryOverrides,
  };
}

class PolicyResponse {
  final Policy policy;

  PolicyResponse({required this.policy});

  factory PolicyResponse.fromJson(Map<String, dynamic> json) {
    return PolicyResponse(policy: Policy.fromJson(json['data'] ?? json));
  }
}

class Policy {
  final String id;
  final String familyId;
  final String childId;
  final String? deviceId;
  final int version;
  final Map<String, dynamic> screenTime;
  final List<Map<String, dynamic>> applications;
  final List<Map<String, dynamic>> schedules;
  final Map<String, dynamic> webSafety;
  final Map<String, dynamic> location;
  final List<Map<String, dynamic>> safeZones;
  final List<String> essentialApps;
  final Map<String, dynamic> temporaryOverrides;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? appliedAt;

  Policy({
    required this.id,
    required this.familyId,
    required this.childId,
    this.deviceId,
    required this.version,
    required this.screenTime,
    required this.applications,
    required this.schedules,
    required this.webSafety,
    required this.location,
    required this.safeZones,
    required this.essentialApps,
    required this.temporaryOverrides,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.appliedAt,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      childId: json['childId'] ?? '',
      deviceId: json['deviceId'],
      version: json['version'] ?? 1,
      screenTime: json['screenTime'] as Map<String, dynamic>? ?? {},
      applications: json['applications'] != null ? List<Map<String, dynamic>>.from(json['applications']) : [],
      schedules: json['schedules'] != null ? List<Map<String, dynamic>>.from(json['schedules']) : [],
      webSafety: json['webSafety'] as Map<String, dynamic>? ?? {},
      location: json['location'] as Map<String, dynamic>? ?? {},
      safeZones: json['safeZones'] != null ? List<Map<String, dynamic>>.from(json['safeZones']) : [],
      essentialApps: json['essentialApps'] != null ? List<String>.from(json['essentialApps']) : [],
      temporaryOverrides: json['temporaryOverrides'] as Map<String, dynamic>? ?? {},
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : null,
    );
  }
}

class PolicyListResponse {
  final List<Policy> policies;

  PolicyListResponse({required this.policies});

  factory PolicyListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return PolicyListResponse(policies: data.map((e) => Policy.fromJson(e)).toList());
  }
}

class PolicyAcknowledgeResponse {
  final bool success;
  final String message;

  PolicyAcknowledgeResponse({required this.success, required this.message});

  factory PolicyAcknowledgeResponse.fromJson(Map<String, dynamic> json) {
    return PolicyAcknowledgeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}