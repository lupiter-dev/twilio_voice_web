import 'package:flutter/material.dart';
import 'package:twilio_voice_web/twilio_voice_web.dart';

class SoundIndicator extends StatelessWidget {
  final Volume volume;

  const SoundIndicator({Key? key, required this.volume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Input Volume"),
        LinearProgressIndicator(
          value: volume.inputVolume,
        ),
        const Text("Output Volume"),
        LinearProgressIndicator(value: volume.outputVolume),
      ],
    );
  }
}
