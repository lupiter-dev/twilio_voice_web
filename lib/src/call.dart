part of twilio_voice_web;

enum CallEvent {
  accept,
  disconnect,
  cancel
}

@JS("Call")
class Call {
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

@JS()
@anonymous
class ConnectOptions {
  external factory ConnectOptions({
    ParamOptions params,
  });
}

@JS()
@anonymous
class ParamOptions {
  external factory ParamOptions({
    // ignore: non_constant_identifier_names
    String To,
  });
}
