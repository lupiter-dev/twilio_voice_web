part of twilio_voice_web;

@JS("Device")
class Device {

  external Device(String token, DeviceOptions mapOptions);

  external TwilioAudioHelper get audio;

  /// Registers [Device] instance in Twilio library
  ///
  /// When [Device] registered you will receive [RegisteredEvent]
  external register();

  /// Disconnect all calls
  external disconnectAll();

  /// Creates [Call] object
  ///
  /// Don`t use this method, use [makeOutgoingCall] instead
  external connect(ConnectOptions connectOptions);

  /// Adds listener to the specific event
  ///
  /// Don`t use this method, use [addDeviceListeners] instead
  external on(dynamic name, Function callback);

  /// Removes all listeners
  ///
  /// Don`t use this method, use [closeDeviceListener] instead
  external removeAllListeners(List<String> events);
}

@JS()
@anonymous
class DeviceOptions {
  external factory DeviceOptions(
      {bool debug, bool answerOnBridge, List<String> codecPreferences});
}
