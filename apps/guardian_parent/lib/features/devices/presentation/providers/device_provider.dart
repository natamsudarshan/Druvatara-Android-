import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/networking/repositories/device_repository.dart';

part 'device_provider.g.dart';

@Riverpod(keepAlive: true)
class DeviceNotifier extends _$DeviceNotifier {
  @override
  DeviceState build() {
    return DeviceState.initial();
  }

  Future<void> loadFamilyDevices(String familyId) async {
    state = DeviceState.loading();
    try {
      final repo = ref.read(deviceRepositoryProvider);
      final response = await repo.getFamilyDevices(familyId);
      state = DeviceState.loaded(devices: response.devices);
    } catch (e) {
      state = DeviceState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadChildDevices(String childId) async {
    state = DeviceState.loading();
    try {
      final repo = ref.read(deviceRepositoryProvider);
      final response = await repo.getChildDevices(childId);
      state = DeviceState.loaded(devices: response.devices);
    } catch (e) {
      state = DeviceState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadDevice(String deviceId) async {
    state = DeviceState.loading();
    try {
      final repo = ref.read(deviceRepositoryProvider);
      final response = await repo.getDevice(deviceId);
      state = DeviceState.loaded(selectedDevice: response.device, devices: state.devices);
    } catch (e) {
      state = DeviceState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loadDeviceHealth(String deviceId) async {
    try {
      final repo = ref.read(deviceRepositoryProvider);
      final response = await repo.getDeviceHealth(deviceId);
      state = state.copyWith(deviceHealth: response.health);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updateDevice(String deviceId, {String? name, String? status, String? connectionType, String? lastIp, Map<String, dynamic>? capabilities, String? appVersion, String? buildNumber}) async {
    state = DeviceState.loading();
    try {
      final repo = ref.read(deviceRepositoryProvider);
      final response = await repo.updateDevice(deviceId, UpdateDeviceRequest(
        name: name,
        status: status,
        connectionType: connectionType,
        lastIp: lastIp,
        capabilities: capabilities,
        appVersion: appVersion,
        buildNumber: buildNumber,
      ));
      final updatedDevices = state.devices.map((d) => d.id == deviceId ? response.device : d).toList();
      Device? selected = state.selectedDevice?.id == deviceId ? response.device : state.selectedDevice;
      state = DeviceState.loaded(devices: updatedDevices, selectedDevice: selected, deviceHealth: state.deviceHealth);
    } catch (e) {
      state = DeviceState.error(e.toString());
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final repo = ref.read(deviceRepositoryProvider);
    await repo.deleteDevice(deviceId);
    final updatedDevices = state.devices.where((d) => d.id != deviceId).toList();
    Device? selected = state.selectedDevice?.id == deviceId ? null : state.selectedDevice;
    state = DeviceState.loaded(devices: updatedDevices, selectedDevice: selected);
  }

  Future<void> reassignDevice(String deviceId, String newChildId) async {
    final repo = ref.read(deviceRepositoryProvider);
    await repo.reassignDevice(deviceId, newChildId);
  }

  Future<List<DeviceCommand>> getPendingCommands(String deviceId) async {
    final repo = ref.read(deviceRepositoryProvider);
    final response = await repo.getPendingCommands(deviceId);
    return response.commands;
  }

  Future<void> acknowledgeCommand(String commandId, String status, {String? error}) async {
    final repo = ref.read(deviceRepositoryProvider);
    await repo.acknowledgeCommand(commandId, status, error: error);
  }
}

class DeviceState {
  final List<Device> devices;
  final Device? selectedDevice;
  final DeviceHealth? deviceHealth;
  final String? error;
  final bool isLoading;

  const DeviceState._({
    this.devices = const [],
    this.selectedDevice,
    this.deviceHealth,
    this.error,
    this.isLoading = false,
  });

  factory DeviceState.initial() => const DeviceState._();
  factory DeviceState.loading() => const DeviceState._(isLoading: true);
  factory DeviceState.loaded({List<Device> devices = const [], Device? selectedDevice, DeviceHealth? deviceHealth}) =>
      DeviceState._(devices: devices, selectedDevice: selectedDevice, deviceHealth: deviceHealth);
  factory DeviceState.error(String message) => DeviceState._(error: message);

  DeviceState copyWith({List<Device>? devices, Device? selectedDevice, DeviceHealth? deviceHealth, String? error, bool? isLoading}) {
    return DeviceState._(
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      deviceHealth: deviceHealth ?? this.deviceHealth,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}