// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  ChatScreen({this.initialMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> _messages = [];
  TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  File? _attachedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _handleSubmitted(widget.initialMessage!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (_attachedImage != null) {
      // Send image to backend
      _sendImageToBackend(_attachedImage!);
      // Add image message to chat
      ChatMessage imageMessage = ChatMessage(
        text: '',
        isUser: true,
        image: _attachedImage,
      );
      setState(() {
        _messages.insert(0, imageMessage);
        _attachedImage = null;
        _isLoading = true;
      });
    } else {
      // Send text message to backend
      ChatMessage message = ChatMessage(
        text: text,
        isUser: true,
      );
      setState(() {
        _messages.insert(0, message);
        _isLoading = true;
      });
      _sendMessageToBackend(text);
    }
  }

  void _sendMessageToBackend(String text) async {
    try {
      var response = await http.post(
        Uri.parse(
            'http://10.103.119.157:5000/ask'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': text}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String answer = data['response'];
        _addAIResponse(answer);
      } else {
        _addAIResponse('Error: ${response.statusCode}');
      }
    } catch (e) {
      _addAIResponse('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendImageToBackend(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://10.103.119.157:5000/ask'), // Replace with your backend URL
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String answer = data['response'];
        _addAIResponse(answer);
      } else {
        _addAIResponse('Error: ${response.statusCode}');
      }
    } catch (e) {
      _addAIResponse('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addAIResponse(String text) {
    ChatMessage aiMessage = ChatMessage(
      text: text,
      isUser: false,
    );
    setState(() {
      _messages.insert(0, aiMessage);
    });
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _attachedImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 50.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.white70),
            onPressed: _pickImage,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF444343),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.white, fontFamily: 'Aleo'),
                decoration: InputDecoration(
                  hintText: _attachedImage != null
                      ? 'Image selected'
                      : 'Type a message...',
                  hintStyle:
                      TextStyle(color: Colors.white54, fontFamily: 'Aleo'),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty || _attachedImage != null) {
                    _handleSubmitted(text);
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_textController.text.isNotEmpty || _attachedImage != null) {
                  _handleSubmitted(_textController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    if (_attachedImage != null) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Image.file(
              _attachedImage!,
              width: 100,
              height: 100,
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _attachedImage = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MOKSHAYANI.AI',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Aleo',
            fontSize: 15,
          ),
        ),
        backgroundColor: Color(0xFF15343E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF15343E), Color(0xFF272222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildAttachmentPreview(),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _messages[index],
                  ),
                  if (_isLoading)
                    Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final File? image;

  ChatMessage({required this.text, required this.isUser, this.image});

  @override
  Widget build(BuildContext context) {
    Widget messageContent;

    if (image != null) {
      // Display the image
      messageContent = Image.file(
        image!,
        width: 200,
        height: 200,
      );
    } else {
      // Display the text message
      messageContent = Text(
        text,
        style: TextStyle(color: Colors.white, fontFamily: 'Aleo'),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color:
                  isUser ? Color(0xFF393F4D) : Color.fromARGB(255, 46, 51, 56),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: messageContent,
          ),
        ],
      ),
    );
  }
}
