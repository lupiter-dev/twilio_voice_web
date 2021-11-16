import 'package:flutter/material.dart';
import 'package:twilio_voice_web/twilio_voice_web.dart';
import 'package:twilio_voice_web_example/services/backend/backend_api.dart';
import 'package:twilio_voice_web_example/services/backend/backend_api_impl.dart';
import 'package:twilio_voice_web_example/services/backend/model/token_model.dart';

import 'widget/sound_indicator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BackendApi _backendApi = BackendApiImpl();
  Stream<DeviceEvent>? _deviceEventsStream;
  Stream<CallEvent>? _callEventsStream;
  Stream<Volume>? _volumeStream;

  List<AudioDevice> _outputDevices = [];
  String? _selectedOutputDevice;

  List<AudioDevice> _inputDevices = [];
  String? _selectedInputDevice;

  String _phone = "";
  bool isMuted = false;
  bool _isLoading = false;
  bool _isVolumeSupported = true;
  late Device _device;
  late TokenModel _tokenModel;
  Call? _currentCall;

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> _initializeDevice() async {
    setLoading(true);

    try {
      _tokenModel = await _backendApi.getToken();
    } catch (error) {
      print(error);
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error while getting token'),
          content: Text('Error: $error'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _device = TwilioVoiceWeb.platform.initializeDevice(_tokenModel.token);
    _deviceEventsStream = TwilioVoiceWeb.platform.addDeviceListeners(_device);
    _deviceEventsStream?.listen((event) {
      if (event is RegisteredEvent) {
        if(_device.audio.isOutputSelectionSupported) {
          _outputDevices = TwilioVoiceWeb.platform.getAvailableOutputDevices(_device);
          _selectedOutputDevice = _outputDevices.first.id;
        }
        _inputDevices = TwilioVoiceWeb.platform.getAvailableInputDevices(_device);
        _selectedInputDevice = _inputDevices.first.id;
        _isVolumeSupported = _device.audio.isVolumeSupported;
        setLoading(false);
      }
      if (event is IncomingCallEvent) {
        _showIncomingCall(event.call);
      }
    });
    _device.register();
  }

  void _onCallAccepted(Call call) {
    Navigator.pop(context);
    if (_currentCall != null) {
      _currentCall!.reject();
      TwilioVoiceWeb.platform.removeCallListeners(_currentCall!);
      TwilioVoiceWeb.platform.removeVolumeListener(_currentCall!);
    }
    _callEventsStream = TwilioVoiceWeb.platform.addCallListeners(call);
    _volumeStream = TwilioVoiceWeb.platform.addVolumeListener(call);
    setState(() {
      _currentCall = call;
    });
    call.accept();
  }

  void _onCallReject(Call call) {
    Navigator.pop(context);
    call.reject();
  }

  Future<void> _makeOutgoingCall() async {
    Call call = await TwilioVoiceWeb.platform.makeOutgoingCall(_device, _phone);
    _callEventsStream = TwilioVoiceWeb.platform.addCallListeners(call);
    _callEventsStream?.listen((event) {
      switch (event) {
        case CallEvent.accept:
          _volumeStream = TwilioVoiceWeb.platform.addVolumeListener(_currentCall!);
          break;
        case CallEvent.disconnect:
        case CallEvent.cancel:
          TwilioVoiceWeb.platform.removeVolumeListener(_currentCall!);
          TwilioVoiceWeb.platform.removeCallListeners(_currentCall!);
          break;
        default:
          break;
      }
    });
    setState(() {
      _currentCall = call;
    });
  }

  @override
  void dispose() {
    TwilioVoiceWeb.platform.removeDeviceListeners(_device);
    if (_currentCall != null){
      TwilioVoiceWeb.platform.removeCallListeners(_currentCall!);
      TwilioVoiceWeb.platform.removeVolumeListener(_currentCall!);
    }
    super.dispose();
  }

  void _showIncomingCall(Call call) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: const Text('AlertDialog description'),
        actions: <Widget>[
          TextButton(
            onPressed: () => _onCallReject(call),
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () => _onCallAccepted(call),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: _isLoading
                ? _buildLoadDeviceState()
                : _buildDeviceReadyState(_device)
            ));
  }

  Container _buildDeviceReadyState(Device device) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          const Text(
            'Client Name',
          ),
          SelectableText(
            _tokenModel.identity,
            style: Theme.of(context).textTheme.headline4,
          ),
          const Divider(),
          const SizedBox(height: 8,),
          TextField(
            onChanged: (value) {
              setState(() {
                _phone = value;
              });
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Phone or Client Name"),
          ),
          const SizedBox(
            height: 8,
          ),
          StreamBuilder<CallEvent>(
              stream: _callEventsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  CallEvent callEvent = snapshot.data!;
                  switch (callEvent) {
                    case CallEvent.accept:
                      return Column(
                        children: [
                          _isVolumeSupported ? StreamBuilder<Volume>(
                              stream: _volumeStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SoundIndicator(
                                    volume: snapshot.data!,
                                  );
                                }
                                return Container();
                              }) : Container(),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isMuted = !isMuted;
                                    });
                                    _currentCall?.mute(isMuted);
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  child: Text(
                                    "Mute: $isMuted",
                                    style: const TextStyle(color: Colors.white),
                                  )),
                              const SizedBox(
                                width: 8,
                              ),
                              TextButton(
                                  onPressed: () {
                                    _device.disconnectAll();
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  child: const Text(
                                    "Hang up",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ],
                      );
                    case CallEvent.disconnect:
                    case CallEvent.cancel:
                      return TextButton(
                          onPressed: _phone.isNotEmpty
                              ? () {
                                  _makeOutgoingCall();
                                }
                              : null,
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
                          child: const Text(
                            "Call",
                            style: TextStyle(color: Colors.white),
                          ));
                    default:
                      Container();
                  }
                }
                return TextButton(
                    onPressed: _phone.isNotEmpty
                        ? () {
                            _makeOutgoingCall();
                          }
                        : null,
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: const Text(
                      "Call",
                      style: TextStyle(color: Colors.white),
                    ));
              }),
          const SizedBox(
            height: 16,
          ),
          const Divider(),
          const Text(
            'Output Devices',
          ),
          const SizedBox(height: 8,),
          device.audio.isOutputSelectionSupported
              ? SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _outputDevices.length,
                    itemBuilder: (context, index) {
                      AudioDevice audioDevice = _outputDevices[index];
                      bool isSelected = audioDevice.id == _selectedOutputDevice;
                      return TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedOutputDevice = TwilioVoiceWeb.platform.setOutputDevice(_device, audioDevice.id);
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(child: Text(audioDevice.label ?? "-")),
                              isSelected ? const Icon(Icons.check) : Container()
                            ],
                          ));
                    },
                  ),
                )
              : const Text("Output devices not supported"),
          const Divider(),
          const Text(
            'Input Devices',
          ),
          const SizedBox(height: 8,),
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: _inputDevices.length,
              itemBuilder: (context, index) {
                AudioDevice audioDevice = _inputDevices[index];
                bool isSelected = audioDevice.id == _selectedInputDevice;
                return TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedInputDevice = TwilioVoiceWeb.platform.setInputDevice(_device, audioDevice.id);
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(child: Text(audioDevice.label ?? "-")),
                        isSelected ? const Icon(Icons.check) : Container()
                      ],
                    ));
              },
            ),
          )
        ],
      ),
    );
  }

  CircularProgressIndicator _buildLoadDeviceState() =>
      const CircularProgressIndicator();
}
