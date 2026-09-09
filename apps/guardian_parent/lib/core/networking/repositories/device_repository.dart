import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api_client.dart';

part 'device_repository.g.dart';

@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(DeviceRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return DeviceRepository(dio);
}

class DeviceRepository {
  final Dio _dio;

  DeviceRepository(this._dio);

  Future<DeviceListResponse> getFamilyDevices(String familyId) async {
    final response = await _dio.get('/devices', queryParameters: {'familyId': familyId});
    return DeviceListResponse.fromJson(response.data);
  }

  Future<DeviceListResponse> getChildDevices(String childId) async {
    final response = await _dio.get('/children/$childId/devices');
    return DeviceListResponse.fromJson(response.data);
  }

  Future<DeviceResponse> getDevice(String deviceId) async {
    final response = await _dio.get('/devices/$deviceId');
    return DeviceResponse.fromJson(response.data);
  }

  Future<DeviceResponse> updateDevice(String deviceId, UpdateDeviceRequest request) async {
    final response = await _dio.patch('/devices/$deviceId', data: request.toJson());
    return DeviceResponse.fromJson(response.data);
  }

  Future<void> deleteDevice(String deviceId) async {
    await _dio.delete('/devices/$deviceId');
  }

  Future<DeviceResponse> reassignDevice(String deviceId, String newChildId) async {
    final response = await _dio.post('/devices/$deviceId/reassign', data: {'childId': newChildId});
    return DeviceResponse.fromJson(response.data);
  }

  Future<DeviceHealthResponse> getDeviceHealth(String deviceId) async {
    final response = await _dio.get('/devices/$deviceId/health');
    return DeviceHealthResponse.fromJson(response.data);
  }

  Future<CommandListResponse> getPendingCommands(String deviceId) async {
    final response = await _dio.get('/devices/$deviceId/commands');
    return CommandListResponse.fromJson(response.data);
  }

  Future<void> acknowledgeCommand(String commandId, String status, {String? error}) async {
    await _dio.post('/device/commands/$commandId/ack', data: {'status': status, 'error': error});
  }
}

class UpdateDeviceRequest {
  final String? name;
  final String? status;
  final String? connectionType;
  final String? lastIp;
  final Map<String, dynamic>? capabilities;
  final String? appVersion;
  final String? buildNumber;

  UpdateDeviceRequest({
    this.name,
    this.status,
    this.connectionType,
    this.lastIp,
    this.capabilities,
    this.appVersion,
    this.buildNumber,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (status != null) 'status': status,
    if (connectionType != null) 'connectionType': connectionType,
    if (lastIp != null) 'lastIp': lastIp,
    if (capabilities != null) 'capabilities': capabilities,
    if (appVersion != null) 'appVersion': appVersion,
    if (buildNumber != null) 'buildNumber': buildNumber,
  };
}

class DeviceResponse {
  final Device device;

  DeviceResponse({required this.device});

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(device: Device.fromJson(json['data'] ?? json));
  }
}

class Device {
  final String id;
  final String familyId;
  final String childId;
  final String platform;
  final String? platformVersion;
  final String? manufacturer;
  final String? model;
  final String appVersion;
  final String? buildNumber;
  final String? deviceName;
  final String internalId;
  final String installationId;
  final String publicKey;
  final int credentialVersion;
  final String status;
  final String connectionType;
  final Map<String, dynamic> capabilities;
  final DateTime? lastSeenAt;
  final DateTime? lastSyncAt;
  final String? lastIp;
  final int? batteryLevel;
  final int? storageUsed;
  final int? storageTotal;
  final int policyVersion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChildInfo? child;
  final List<PolicyInfo>? policies;

  Device({
    required this.id,
    required this.familyId,
    required this.childId,
    required this.platform,
    this.platformVersion,
    this.manufacturer,
    this.model,
    required this.appVersion,
    this.buildNumber,
    this.deviceName,
    required this.internalId,
    required this.installationId,
    required this.publicKey,
    required this.credentialVersion,
    required this.status,
    required this.connectionType,
    required this.capabilities,
    this.lastSeenAt,
    this.lastSyncAt,
    this.lastIp,
    this.batteryLevel,
    this.storageUsed,
    this.storageTotal,
    required this.policyVersion,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.child,
    this.policies,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      familyId: json['familyId'] ?? '',
      childId: json['childId'] ?? '',
      platform: json['platform'] ?? '',
      platformVersion: json['platformVersion'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      appVersion: json['appVersion'] ?? '',
      buildNumber: json['buildNumber'],
      deviceName: json['deviceName'],
      internalId: json['internalId'] ?? '',
      installationId: json['installationId'] ?? '',
      publicKey: json['publicKey'] ?? '',
      credentialVersion: json['credentialVersion'] ?? 1,
      status: json['status'] ?? 'PAIRING',
      connectionType: json['connectionType'] ?? 'UNKNOWN',
      capabilities: json['capabilities'] as Map<String, dynamic>? ?? {},
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
      lastSyncAt: json['lastSyncAt'] != null ? DateTime.parse(json['lastSyncAt']) : null,
      lastIp: json['lastIp'],
      batteryLevel: json['batteryLevel'],
      storageUsed: json['storageUsed'],
      storageTotal: json['storageTotal'],
      policyVersion: json['policyVersion'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      child: json['child'] != null ? ChildInfo.fromJson(json['child']) : null,
      policies: json['policies'] != null
          ? (json['policies'] as List).map((e) => PolicyInfo.fromJson(e)).toList()
          : null,
    );
  }
}

class ChildInfo {
  final String id;
  final String name;
  final String? avatarId;

  ChildInfo({required this.id, required this.name, this.avatarId});

  factory ChildInfo.fromJson(Map<String, dynamic> json) {
    return ChildInfo(id: json['id'] ?? '', name: json['name'] ?? '', avatarId: json['avatarId']);
  }
}

class PolicyInfo {
  final String id;
  final int version;
  final DateTime createdAt;

  PolicyInfo({required this.id, required this.version, required this.createdAt});

  factory PolicyInfo.fromJson(Map<String, dynamic> json) {
    return PolicyInfo(
      id: json['id'] ?? '',
      version: json['version'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DeviceListResponse {
  final List<Device> devices;

  DeviceListResponse({required this.devices});

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return DeviceListResponse(devices: data.map((e) => Device.fromJson(e)).toList());
  }
}

class DeviceHealthResponse {
  final DeviceHealth health;

  DeviceHealthResponse({required this.health});

  factory DeviceHealthResponse.fromJson(Map<String, dynamic> json) {
    return DeviceHealthResponse(health: DeviceHealth.fromJson(json['data'] ?? json));
  }
}

class DeviceHealth {
  final String deviceId;
  final bool isOnline;
  final String status;
  final DateTime? lastSeenAt;
  final String? lastIp;
  final int? batteryLevel;
  final int? storageUsed;
  final int? storageTotal;
  final int recentEventCount;

  DeviceHealth({
    required this.deviceId,
    required this.isOnline,
    required this.status,
    this.lastSeenAt,
    this.lastIp,
    this.batteryLevel,
    this.storageUsed,
    this.storageTotal,
    required this.recentEventCount,
  });

  factory DeviceHealth.fromJson(Map<String, dynamic> json) {
    return DeviceHealth(
      deviceId: json['deviceId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      status: json['status'] ?? 'unknown',
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
      lastIp: json['lastIp'],
      batteryLevel: json['batteryLevel'],
      storageUsed: json['storageUsed'],
      storageTotal: json['storageTotal'],
      recentEventCount: json['recentEventCount'] ?? 0,
    );
  }
}

class CommandListResponse {
  final List<DeviceCommand> commands;

  CommandListResponse({required this.commands});

  factory CommandListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return CommandListResponse(commands: data.map((e) => DeviceCommand.fromJson(e)).toList());
  }
}

class DeviceCommand {
  final String id;
  final String deviceId;
  final String commandId;
  final String type;
  final Map<String, dynamic> payload;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final DateTime? appliedAt;
  final DateTime? failedAt;
  final String? error;
  final DateTime? expiresAt;

  DeviceCommand({
    required this.id,
    required this.deviceId,
    required this.commandId,
    required this.type,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.receivedAt,
    this.appliedAt,
    this.failedAt,
    this.error,
    this.expiresAt,
  });

  factory DeviceCommand.fromJson(Map<String, dynamic> json) {
    return DeviceCommand(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      commandId: json['commandId'] ?? '',
      type: json['type'] ?? '',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
      status: json['status'] ?? 'QUEUED',
      createdAt: DateTime.parse(json['createdAt']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      receivedAt: json['receivedAt'] != null ? DateTime.parse(json['receivedAt']) : null,
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : null,
      failedAt: json['failedAt'] != null ? DateTime.parse(json['failedAt']) : null,
      error: json['error'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}