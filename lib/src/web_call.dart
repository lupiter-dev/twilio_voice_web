import 'package:twilio_voice_web/src/twilio_voice_web_internal.dart';
import 'package:twilio_voice_web/twilio_voice_web.dart';

class WebCall implements Call {
  final WebCallInternal _instance;

  WebCall(this._instance);

  @override
  void accept() {
    _instance.accept();
  }

  @override
  void addListener(name, Function callback) {
    _instance.addListener(name, callback);
  }

  @override
  void mute(bool mute) {
    _instance.mute(mute);
  }

  @override
  void on(name, Function callback) {
    _instance.on(name, callback);
  }

  @override
  void reject() {
    _instance.reject();
  }

  @override
  void removeAllListeners(List<String> events) {
    _instance.removeAllListeners(events);
  }
}
