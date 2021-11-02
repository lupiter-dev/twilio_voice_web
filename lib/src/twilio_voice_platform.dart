import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:twilio_voice_web/src/model/device.dart';
import 'package:twilio_voice_web/src/model/events.dart';
import 'package:twilio_voice_web/src/model/volume.dart';
import 'package:twilio_voice_web/src/model/web_call.dart';

import '../twilio_voice_web.dart';

abstract class TwilioVoiceWeb extends PlatformInterface {
  TwilioVoiceWeb() : super(token: _token);

  static final Object _token = Object();

  static TwilioVoiceWeb _instance = _DummyImpl();

  static TwilioVoiceWeb get platform => _instance;

  static set platform(TwilioVoiceWeb instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Creates a Device object using the given [token].
  ///
  /// After you create the device, add listeners to it using [addDeviceListeners] and call [register] method.
  /// For debug version use [debug] parameter.
  ///
  Device initializeDevice(String token,
      {bool debug = false, bool answerOnBridge = true}) {
    throw UnimplementedError('initializeDevice() has not been implemented.');
  }

  /// Removes listeners from the [Device] object
  ///
  /// Call this method when you don`t use the [Device] object anymore.
  ///
  void removeDeviceListeners(Device? device) {
    throw UnimplementedError(
        'removeDeviceListeners() has not been implemented.');
  }

  /// Removes listeners from the [WebCall] object
  ///
  /// Call this method when the [WebCall] is disconnected.
  ///
  void removeCallListeners(WebCall call) {
    throw UnimplementedError('removeCallListeners() has not been implemented.');
  }

  /// Removes volume listener from the [WebCall] object
  ///
  /// Call this method when [WebCall] is disconnected.
  ///
  void removeVolumeListener(WebCall? call) {
    throw UnimplementedError(
        'removeVolumeListener() has not been implemented.');
  }

  /// Adds an internal listener to handle volume changes.
  ///
  /// Takes a [call] object, and returns [Stream] that yields [Volume] objects.
  /// Before add listeners check if volume supported [Device.audio.isVolumeSupported].
  /// After call is disconnected remove listener using [removeVolumeListener].
  ///
  Stream<Volume> addVolumeListener(WebCall? call) {
    throw UnimplementedError('addVolumeListener() has not been implemented.');
  }

  /// Adds internal listeners to handle [WebCall] events.
  ///
  /// Takes [call] object and returns [Stream] that yields [CallEvent]s.
  /// After call is disconnected remove listeners using [removeCallListeners].
  ///
  /// [CallEvent.accept] emitted when call has been accepted
  /// [CallEvent.disconnect] emitted when media session has been disconnected
  /// [CallEvent.cancel] emitted when call has been canceled
  ///
  Stream<CallEvent> addCallListeners(WebCall call) {
    throw UnimplementedError('addCallListeners() has not been implemented.');
  }

  /// Adds internal listeners to handle [Device] events.
  ///
  /// Takes [device] object and returns [Stream] that yields [DeviceEvent]s .
  /// Remove listeners using [removeDeviceListeners] when you don`t use [Device] object anymore.
  ///
  Stream<DeviceEvent> addDeviceListeners(Device device) {
    throw UnimplementedError('addDeviceListeners() has not been implemented.');
  }

  /// Sets output device for ringtone and speaker
  ///
  String? setOutputDevice(Device device, String? outputDeviceId) {
    throw UnimplementedError('setOutputDevice() has not been implemented.');
  }

  /// Sets input device
  ///
  String? setInputDevice(Device device, String? inputDeviceId) {
    throw UnimplementedError('setInputDevice() has not been implemented.');
  }

  /// Makes outgoing call.
  ///
  /// Takes [device] and [phoneNumber] and returns new [WebCall] object.
  /// After that, call [addCallListeners] method for receiving events.
  ///
  Future<dynamic> makeOutgoingCall(Device device, String phoneNumber) async {
    throw UnimplementedError('makeOutgoingCall() has not been implemented.');
  }

  /// Returns list of available output [AudioDevice]s.
  ///
  List<AudioDevice> getAvailableOutputDevices(Device device) {
    throw UnimplementedError(
        'getAvailableOutputDevices() has not been implemented.');
  }

  /// Returns [List] of available input [AudioDevice]s.
  ///
  List<AudioDevice> getAvailableInputDevices(Device device) {
    throw UnimplementedError(
        'getAvailableInputDevices() has not been implemented.');
  }
}

class _DummyImpl extends TwilioVoiceWeb {}
