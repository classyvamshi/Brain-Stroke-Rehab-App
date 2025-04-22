import 'package:flutter/material.dart';
import 'package:my_app/services/chat_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  late stt.SpeechToText _speech;
  final AudioRecorder _recorder = AudioRecorder();
  bool _isListening = false;
  String? _audioPath;
  int _recordDuration = 0;
  Timer? _timer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeRecorder();
    _addInitialBotMessage();
  }

  void _addInitialBotMessage() {
    setState(() {
      _messages.add({
        "role": "bot",
        "message": "Hi! I'm your Brain Stroke Assistant. How can I help you today?"
      });
    });
  }

  Future<void> _initializeRecorder() async {
    try {
      bool hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        print("Permission denied for audio recording.");
      }
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;
    
    setState(() {
      _messages.add({"role": "user", "message": message});
      _isTyping = true;
    });
    _scrollToBottom();

    _controller.clear();
    try {
      final response = await _chatService.sendMessage(message);
      setState(() {
        _messages.add({"role": "bot", "message": response});
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "message": "Error: $e"});
        _isTyping = false;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        Directory tempDir = await getTemporaryDirectory();
        _audioPath = "${tempDir.path}/recorded_audio.wav";

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _audioPath!,
        );

        setState(() {
          _isListening = true;
          _recordDuration = 0;
        });

        _startTimer();
      } else {
        print("Recording permission not granted.");
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() => _messages.add({"role": "bot", "message": "Error recording: $e"}));
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stop();
      _stopTimer();

      if (_audioPath != null) {
        File recordedFile = File(_audioPath!);
        if (await recordedFile.exists()) {
          _sendAudio(recordedFile);
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() => _messages.add({"role": "bot", "message": "Error stopping recording: $e"}));
    }
    setState(() => _isListening = false);
  }

  void _sendAudio(File audioFile) async {
    setState(() {
      _messages.add({"role": "user", "message": "🎤 Audio Message"});
      _isTyping = true;
    });
    _scrollToBottom();
    
    try {
      final response = await _chatService.sendAudio(audioFile);
      setState(() {
        _messages.add({"role": "bot", "message": response});
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "message": "Error: $e"});
        _isTyping = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Brain Stroke Assistant",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Voice-Enabled Support",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D3A4A),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About Brain Stroke Assistant"),
                  content: const Text(
                    "Your AI-powered mental health companion. You can interact through text or voice messages. "
                    "Long press the microphone button to record your voice message.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Got it"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["role"] == "user";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3A4A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF2D3A4A) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isUser ? 20 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
                            ),
                            child: Text(
                              message["message"]!,
                              style: TextStyle(
                                color: isUser ? Colors.white : const Color(0xFF2D3A4A),
                              ),
                            ),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3A4A)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Assistant is typing...",
                    style: TextStyle(
                      color: Color(0xFF2D3A4A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D3A4A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text.trim()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressUp: _stopRecording,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : const Color(0xFF2D3A4A),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _isListening
                          ? Text(
                              "$_recordDuration s",
                              style: const TextStyle(color: Colors.white),
                            )
                          : const Icon(Icons.mic, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
