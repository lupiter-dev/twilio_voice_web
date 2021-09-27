# twilio_voice_web
Flutter Web wrapper for Twilio Voice JS SDK

This package was created, as the present plugin https://pub.dev/packages/twilio_voice doen't provide web support.
As this is a JavaScript wrapper and integration of other plattforms is unprobable, the project was created as a package and not a plugin. 

Unfortunately, the Twilio JS SDK has some logical differences compared to the Android/iOS SDKs.
Therefore, it wasn't easily possible to integrate web support to the mentioned twilio_voice plugin.

### Setup
You need a running backend service to retrieve an access token, which is needed to register a new device.
You can use one of the quick guides if you don't have your own backend at the moment: https://www.twilio.com/docs/voice/sdks/javascript/get-started

You need to add the 'twilio.min.js' file to the web folder of your project (s. example project as reference).
See the instructions [here](https://github.com/twilio/twilio-voice.js#github) for downloading the SDK code from GitHub.
You will download a zip or tarball for a specific release version of the Voice JavaScript SDK (ex: `2.0.0`), extract the
files, and retrieve the `twilio.min.js` file from the `dist/` folder.
The corresponding JS SDK version for each release is written in the CHANGELOG.md.
   
The Microphone permission is requested by the JS SDK, as soon as it is required.

### Usage

#### Init device
```
 _device = TwilioVoiceWeb.initializeDevice(_tokenModel.token);
 _deviceEventsStream = TwilioVoiceWeb.addDeviceListeners(_device);
 _device.register();
```

#### make call
```
 Call call = await TwilioVoiceWeb.makeOutgoingCall(_device, phoneNumber);
 _callEventsStream = TwilioVoiceWeb.addCallListeners(call);
 // listen to stream to react on call events
```

#### receive call
```
 _deviceEventsStream?.listen((event) {
   if (event is IncomingCallEvent) {
     _showIncomingCall(event.call);
   }
 });
```

#### mute call
```
 _call.mute(true);
```


#### Clean up
You need to remove the registered listeners, when you no longer need them.

Clean up after each call:
```
 TwilioVoiceWeb.removeCallListeners(_currentCall);
 TwilioVoiceWeb.removeVolumeListener(_currentCall);
```

Clean up device:
```
 TwilioVoiceWeb.removeDeviceListeners(_device);
```


See the example project for a minimal UI that shows the usage of this package.