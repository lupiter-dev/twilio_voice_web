@JS('Twilio')
library twilio_voice_web;

import 'dart:async';
import 'dart:js';
import 'dart:js_util';

import 'package:js/js.dart';

part 'src/audio_device.dart';

part 'src/call.dart';

part 'src/device.dart';

part 'src/device_event.dart';

part 'src/twilio_audio_helper.dart';

part 'src/volume.dart';

/// A web implementation of the TwilioVoice plugin.
class TwilioVoiceWeb {
  static final Map<Device, StreamController<DeviceEvent>> _devicesListeners = {};
  static final Map<Call, StreamController<CallEvent>> _callsListeners = {};
  static final Map<Call, StreamController<Volume>> _volumesListeners = {};

  /// Creates a Device object using the given [token].
  ///
  /// After you create the device, add listeners to it using [addDeviceListeners] and call [register] method.
  /// For debug version use [debug] parameter.
  ///
  static Device initializeDevice(String token,
      {bool debug = false, bool answerOnBridge = true}) {
    Device device = Device(
        token, DeviceOptions(debug: debug, answerOnBridge: answerOnBridge));
    return device;
  }


  /// Removes listeners from the [Device] object
  ///
  /// Call this method when you don`t use the [Device] object anymore.
  ///
  static void removeDeviceListeners(Device? device) {
    if(_devicesListeners.containsKey(device) && !(_devicesListeners[device]?.isClosed ?? true)){
      _devicesListeners[device]!.close();
      device?.removeAllListeners(["registered", 'error', 'incoming', 'deviceChange']);
    }
  }

  /// Removes listeners from the [Call] object
  ///
  /// Call this method when the [Call] is disconnected.
  ///
  static void removeCallListeners(Call? call) {
    if(_callsListeners.containsKey(call) && !(_callsListeners[call]?.isClosed ?? true)){
      _callsListeners[call]!.close();
      call?.removeAllListeners(["accept", 'disconnect', 'cancel']);
    }
  }

  /// Removes volume listener from the [Call] object
  ///
  /// Call this method when [Call] is disconnected.
  ///
  static void removeVolumeListener(Call? call) {
    if(_volumesListeners.containsKey(call) && !(_volumesListeners[call]?.isClosed ?? true)){
      _volumesListeners[call]!.close();
      call?.removeAllListeners(["volume"]);
    }
  }

  /// Adds an internal listener to handle volume changes.
  ///
  /// Takes a [call] object, and returns [Stream] that yields [Volume] objects.
  /// Before add listeners check if volume supported [Device.audio.isVolumeSupported].
  /// After call is disconnected remove listener using [removeVolumeListener].
  ///
  static Stream<Volume> addVolumeListener(Call? call) {
    if(_volumesListeners.containsKey(call) && !(_volumesListeners[call]?.isClosed ?? true)){
      return _volumesListeners[call]!.stream;
    }
    StreamController<Volume> _volumeStreamController = StreamController();
    call?.on('volume', allowInterop((inputVolume, outputVolume) {
      _volumeStreamController.sink
          .add(Volume(inputVolume: inputVolume, outputVolume: outputVolume));
    }));
    return _volumeStreamController.stream.asBroadcastStream();
  }

  /// Adds internal listeners to handle [Call] events.
  ///
  /// Takes [call] object and returns [Stream] that yields [CallEvent]s.
  /// After call is disconnected remove listeners using [removeCallListeners].
  ///
  /// [CallEvent.accept] emitted when call has been accepted
  /// [CallEvent.disconnect] emitted when media session has been disconnected
  /// [CallEvent.cancel] emitted when call has been canceled
  ///
  static Stream<CallEvent> addCallListeners(Call? call) {
    if(_callsListeners.containsKey(call) && !(_callsListeners[call]?.isClosed ?? true)){
      return _callsListeners[call]!.stream;
    }
    StreamController<CallEvent> _callEventsStreamController =
        StreamController();
    call?.addListener('accept', allowInterop((Call call) {
      _callEventsStreamController.sink.add(CallEvent.accept);
    }));
    call?.addListener('disconnect', allowInterop((Call call) {
      _callEventsStreamController.sink.add(CallEvent.disconnect);
    }));
    call?.addListener('cancel', allowInterop(() {
      _callEventsStreamController.sink.add(CallEvent.cancel);
    }));
    return _callEventsStreamController.stream.asBroadcastStream();
  }

  /// Adds internal listeners to handle [Device] events.
  ///
  /// Takes [device] object and returns [Stream] that yields [DeviceEvent]s .
  /// Remove listeners using [removeDeviceListeners] when you don`t use [Device] object anymore.
  ///
  static Stream<DeviceEvent> addDeviceListeners(Device device) {
    if(_devicesListeners.containsKey(device) && !(_devicesListeners[device]?.isClosed ?? true)){
      return _devicesListeners[device]!.stream;
    }
    StreamController<DeviceEvent> _deviceEventsStreamController =
        StreamController();
    device.on("registered", allowInterop(() {
      RegisteredEvent event = RegisteredEvent();
      _deviceEventsStreamController.sink.add(event);
    }));
    device.on('error', allowInterop((error) {
      ErrorEvent event = ErrorEvent("test");
      _deviceEventsStreamController.sink.add(event);
    }));
    device.on('incoming', allowInterop((Call incomingCall) {
      IncomingCallEvent event = IncomingCallEvent(incomingCall);
      _deviceEventsStreamController.sink.add(event);
    }));
    device.audio.on('deviceChange', allowInterop((device) {
      DeviceChangeEvent event = DeviceChangeEvent();
      _deviceEventsStreamController.sink.add(event);
    }));
    return _deviceEventsStreamController.stream.asBroadcastStream();
  }

  /// Sets output device for ringtone and speaker
  ///
  static String? setOutputDevice(Device device, String? outputDeviceId) {
    device.audio.ringtoneDevices.set(outputDeviceId);
    device.audio.speakerDevices.set(outputDeviceId);
    return outputDeviceId;
  }

  /// Sets input device
  ///
  static String? setInputDevice(Device device, String? inputDeviceId) {
    device.audio.setInputDevice(inputDeviceId);
    return inputDeviceId;
  }

  /// Makes outgoing call.
  ///
  /// Takes [device] and [phone] and returns new [Call] object.
  /// After that, call [addCallListeners] method for receiving events.
  ///
  static Future<Call> makeOutgoingCall(Device device, String phone) async {
    Call call = await promiseToFuture(
        device.connect(ConnectOptions(params: ParamOptions(To: phone))));
    return call;
  }

  /// Returns list of available output [AudioDevice]s.
  ///
  static List<AudioDevice> getAvailableOutputDevices(Device device) {
    List<AudioDevice> devices = [];
    device.audio.availableOutputDevices.forEach(allowInterop((key, value, map) {
      if (key is TwilioMediaDeviceInfo) {
        devices.add(AudioDevice(key.label, key.deviceId));
      }
    }));
    return devices;
  }

  /// Returns [List] of available input [AudioDevice]s.
  ///
  static List<AudioDevice> getAvailableInputDevices(Device device) {
    List<AudioDevice> devices = [];
    device.audio.availableInputDevices.forEach(allowInterop((key, value, map) {
      if (key is TwilioMediaDeviceInfo) {
        devices.add(AudioDevice(key.label, key.deviceId));
      }
    }));
    return devices;
  }
}
