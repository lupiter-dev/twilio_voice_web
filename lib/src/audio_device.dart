part of twilio_voice_web;

class AudioDevice {
  final String? label;
  final String? id;

  AudioDevice(this.label, this.id);

  factory AudioDevice.fromJsObject(JsObject device) {
    return AudioDevice(device["label"], device["deviceId"]);
  }
}
