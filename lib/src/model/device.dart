import 'package:twilio_voice_web/src/model/audio_helper.dart';

abstract class Device {

  /// Registers [Device] instance in Twilio library
  ///
  /// When [Device] registered you will receive [RegisteredEvent]
  void register();

  /// Disconnect all calls
  void disconnectAll();

  AudioHelper get audio;
}