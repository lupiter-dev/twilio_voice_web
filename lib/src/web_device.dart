part of twilio_voice_web_internal;

@JS("Device")
class WebDevice implements Device {

  external WebDevice(String token, DeviceOptions mapOptions);

  @override
  external AudioHelper get audio;

  /// Registers [WebDevice] instance in Twilio library
  ///
  /// When [WebDevice] registered you will receive [RegisteredEvent]
  @override
  external register();

  /// Disconnect all calls
  @override
  external disconnectAll();

  external connect(WebConnectOptions connectOptions);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addDeviceListeners] instead
  external on(dynamic name, Function callback);

  /// Removes all listeners
  ///
  /// Don`t use this method, use [removeDeviceListeners] instead
  external removeAllListeners(List<String> events);

  @override
  external updateToken(String token);
}

@JS()
@anonymous
class DeviceOptions {
  external factory DeviceOptions(
      {bool debug, bool answerOnBridge, List<String> codecPreferences});
}

@JS()
@anonymous
class WebConnectOptions {
  external factory WebConnectOptions({
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
