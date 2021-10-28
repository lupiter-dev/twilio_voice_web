abstract class AudioHelper {
  bool get isOutputSelectionSupported;

  bool get isVolumeSupported;

  /// Sets input device
  ///
  /// Don`t use this method directly, use [TwilioVoiceWeb.setInputDevice] instead.
   setInputDevice(String? deviceId);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method outside of [TwilioVoiceWeb].
   on(dynamic name, Function callback);
}

