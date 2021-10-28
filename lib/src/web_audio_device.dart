part of twilio_voice_web_internal;

class WebAudioDevice implements AudioDevice{
  @override
  final String? label;

  @override
  final String? id;

  WebAudioDevice(this.label, this.id);

  factory WebAudioDevice.fromJsObject(JsObject device) {
    return WebAudioDevice(device["label"] as String?, device["deviceId"] as String?);
  }
}
