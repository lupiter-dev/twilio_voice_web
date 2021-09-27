part of twilio_voice_web;

@JS("AudioHelper")
class TwilioAudioHelper {
  external bool get isOutputSelectionSupported;

  external bool get isVolumeSupported;

  /// Returns [JsMap] of output devices
  ///
  /// Don`t use this method, use [getAvailableOutputDevices] instead
  external JsMap get availableOutputDevices;

  /// Returns collection of input devices
  ///
  /// Don`t use this method, use [getAvailableInputDevices] instead
  external JsMap get availableInputDevices;


  /// Returns collection of ringtone devices
  ///
  /// Don`t use this method outside of [TwilioVoiceWeb].
  external TwilioOutputDeviceCollection get ringtoneDevices;

  /// Returns collection of speaker devices
  ///
  /// Don`t use this method outside of [TwilioVoiceWeb].
  external TwilioOutputDeviceCollection get speakerDevices;

  /// Sets input device
  ///
  /// Don`t use this method directly, use [TwilioVoiceWeb.setInputDevice] instead.
  external setInputDevice(String? deviceId);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method outside of [TwilioVoiceWeb].
  external on(dynamic name, Function callback);
}

@JS("Map")
class JsMap {
  external forEach(Function(dynamic key, dynamic value, dynamic map) callback);
}

@JS("MediaDeviceInfo")
class TwilioMediaDeviceInfo {
  external String get deviceId;

  external String get label;
}

@JS("OutputDeviceCollection")
class TwilioOutputDeviceCollection {
  /// Sets collection devices
  ///
  /// Don`t use this method outside of [TwilioVoiceWeb].
  external set(String? deviceId);
}
