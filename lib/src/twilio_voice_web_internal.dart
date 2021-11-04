@JS('Twilio')
library twilio_voice_web_internal;

import 'dart:async';
import 'dart:js';
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:twilio_voice_web/src/model/audio_device.dart';
import 'package:twilio_voice_web/src/model/call.dart';
import 'package:twilio_voice_web/src/model/device.dart';
import 'package:twilio_voice_web/src/model/events.dart';
import 'package:twilio_voice_web/src/model/volume.dart';
import 'package:twilio_voice_web/src/model/web_call.dart';
import 'package:twilio_voice_web/twilio_voice_web.dart';

import 'model/audio_helper.dart';

part 'twilio_audio_helper.dart';

part 'web_audio_device.dart';

part 'web_call_internal.dart';

part 'web_device.dart';

/// A web implementation of the TwilioVoice plugin.
class TwilioVoiceWebImpl extends TwilioVoiceWeb {
  final Map<WebDevice, StreamController<DeviceEvent>> _devicesListeners = {};
  final Map<WebCallInternal, StreamController<CallEvent>> _callsListeners = {};
  final Map<WebCallInternal, StreamController<Volume>> _volumesListeners = {};

  static final TwilioVoiceWebImpl platform = TwilioVoiceWebImpl._();

  TwilioVoiceWebImpl._();

  static void registerWith(Registrar registrar) {
    TwilioVoiceWeb.platform = platform;
  }

  /// Creates a Device object using the given [token].
  ///
  /// After you create the device, add listeners to it using [addDeviceListeners] and call [register] method.
  /// For debug version use [debug] parameter.
  ///
  @override
  Device initializeDevice(String token,
      {bool debug = false, bool answerOnBridge = true}) {
    WebDevice device = WebDevice(
        token, DeviceOptions(debug: debug, answerOnBridge: answerOnBridge));
    return device;
  }

  /// Removes listeners from the [Device] object
  ///
  /// Call this method when you don`t use the [Device] object anymore.
  ///
  @override
  void removeDeviceListeners(Device? device) {
    if (_devicesListeners.containsKey(device) &&
        !(_devicesListeners[device]?.isClosed ?? true)) {
      _devicesListeners[device]!.close();
      (device as WebDevice).removeAllListeners(
          ["registered", 'error', 'incoming', 'deviceChange']);
    }
  }

  /// Removes listeners from the [Call] object
  ///
  /// Call this method when the [Call] is disconnected.
  ///
  @override
  void removeCallListeners(Call? call) {
    if (_callsListeners.containsKey(call) &&
        !(_callsListeners[call]?.isClosed ?? true)) {
      _callsListeners[call]!.close();
      call?.removeAllListeners(["accept", 'disconnect', 'cancel']);
    }
  }

  /// Removes volume listener from the [Call] object
  ///
  /// Call this method when [Call] is disconnected.
  ///
  @override
  void removeVolumeListener(Call? call) {
    if (_volumesListeners.containsKey(call) &&
        !(_volumesListeners[call]?.isClosed ?? true)) {
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
  @override
  Stream<Volume> addVolumeListener(Call? call) {
    if (_volumesListeners.containsKey(call) &&
        !(_volumesListeners[call]?.isClosed ?? true)) {
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
  @override
  Stream<CallEvent> addCallListeners(Call? call) {
    if (_callsListeners.containsKey(call) &&
        !(_callsListeners[call]?.isClosed ?? true)) {
      return _callsListeners[call]!.stream;
    }
    StreamController<CallEvent> _callEventsStreamController =
        StreamController();
    call?.addListener('accept', allowInterop((WebCallInternal call) {
      _callEventsStreamController.sink.add(CallEvent.accept);
    }));
    call?.addListener('disconnect', allowInterop((WebCallInternal call) {
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
  @override
  Stream<DeviceEvent> addDeviceListeners(Device device) {
    var webDevice = device as WebDevice;
    if (_devicesListeners.containsKey(device) &&
        !(_devicesListeners[webDevice]?.isClosed ?? true)) {
      return _devicesListeners[webDevice]!.stream;
    }
    StreamController<DeviceEvent> _deviceEventsStreamController =
        StreamController();
    webDevice.on("registered", allowInterop(() {
      RegisteredEvent event = RegisteredEvent();
      _deviceEventsStreamController.sink.add(event);
    }));
    webDevice.on('error', allowInterop((error) {
      ErrorEvent event = ErrorEvent("test");
      _deviceEventsStreamController.sink.add(event);
    }));
    webDevice.on('incoming', allowInterop((WebCallInternal incomingCall) {
      IncomingCallEvent event = IncomingCallEvent(WebCall(incomingCall));
      _deviceEventsStreamController.sink.add(event);
    }));
    webDevice.audio.on('deviceChange', allowInterop((webDevice) {
      DeviceChangeEvent event = DeviceChangeEvent();
      _deviceEventsStreamController.sink.add(event);
    }));
    return _deviceEventsStreamController.stream.asBroadcastStream();
  }

  /// Sets output device for ringtone and speaker
  ///
  @override
  String? setOutputDevice(Device device, String? outputDeviceId) {
    var audio = (device as WebDevice).audio as TwilioAudioHelper;
    audio.ringtoneDevices.set(outputDeviceId);
    audio.speakerDevices.set(outputDeviceId);
    return outputDeviceId;
  }

  /// Sets input device
  ///
  @override
  String? setInputDevice(Device device, String? inputDeviceId) {
    (device as WebDevice).audio.setInputDevice(inputDeviceId);
    return inputDeviceId;
  }

  /// Makes outgoing call.
  ///
  /// Takes [device] and [phoneNumber] and returns new [WebCallInternal] object.
  /// After that, call [addCallListeners] method for receiving events.
  ///
  @override
  Future<Call> makeOutgoingCall(Device device, String phoneNumber) async {
    WebCallInternal call = await promiseToFuture((device as WebDevice)
        .connect(WebConnectOptions(params: ParamOptions(To: phoneNumber))));
    return WebCall(call);
  }

  /// Returns list of available output [WebAudioDevice]s.
  ///
  @override
  List<WebAudioDevice> getAvailableOutputDevices(Device device) {
    List<WebAudioDevice> devices = [];
    var audio = (device as WebDevice).audio as TwilioAudioHelper;
    audio.availableOutputDevices.forEach(allowInterop((key, value, map) {
      if (key is TwilioMediaDeviceInfo) {
        devices.add(WebAudioDevice(key.label, key.deviceId));
      }
    }));
    return devices;
  }

  /// Returns [List] of available input [WebAudioDevice]s.
  ///
  @override
  List<WebAudioDevice> getAvailableInputDevices(Device device) {
    List<WebAudioDevice> devices = [];
    var audio = (device as WebDevice).audio as TwilioAudioHelper;

    audio.availableInputDevices.forEach(allowInterop((key, value, map) {
      if (key is TwilioMediaDeviceInfo) {
        devices.add(WebAudioDevice(key.label, key.deviceId));
      }
    }));
    return devices;
  }
}
