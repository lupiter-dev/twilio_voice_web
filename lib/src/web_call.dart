part of twilio_voice_web_internal;

@JS("Call")
class WebCall implements Call {
  ///Mute call
  @override
  external mute(bool mute);

  /// Reject call
  @override
  external reject();

  /// Accept call
  @override
  external accept();

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  @override
  external on(dynamic name, Function callback);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addVolumeListener] and [addCallListeners] instead
  @override
  external addListener(dynamic name, Function callback);

  /// Removes all listeners
  ///
  /// Don`t use this method, use [removeCallListeners] and [removeVolumeListener] instead
  @override
  external removeAllListeners(List<String> events);
}
