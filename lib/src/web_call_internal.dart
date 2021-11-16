part of twilio_voice_web_internal;

@JS("Call")
class WebCallInternal {
  ///Mute call
  external mute(bool mute);

  /// Reject call
  external reject();

  /// Accept call
  external accept();

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  external on(dynamic name, Function callback);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  external addListener(dynamic name, Function callback);

  /// Removes all listeners
  ///
  /// Don`t use this method, use [removeCallListeners] and [removeVolumeListener] instead
  external removeAllListeners(List<String> events);
}
