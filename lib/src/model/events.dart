import 'package:twilio_voice_web/src/model/call.dart';

abstract class DeviceEvent {}

class RegisteredEvent extends DeviceEvent {}

class ErrorEvent extends DeviceEvent {
  final String error;

  ErrorEvent(this.error);
}

class DeviceChangeEvent extends DeviceEvent {}

class IncomingCallEvent extends DeviceEvent {
  final Call call;

  IncomingCallEvent(this.call);
}

enum CallEvent {
  accept,
  disconnect,
  cancel
}