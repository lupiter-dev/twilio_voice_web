part of twilio_voice_web;

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
