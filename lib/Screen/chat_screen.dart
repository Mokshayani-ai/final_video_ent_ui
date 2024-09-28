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
  File? _attachedFile;
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

  // Function to handle submitted message (either text or file)
  void _handleSubmitted(String text) {
    _textController.clear();
    if (_attachedFile != null) {
      _sendFileToBackend(_attachedFile!);
      _addUserMessage(text, _attachedFile);
      _attachedFile = null;
    } else {
      _addUserMessage(text, null);
      _sendMessageToBackend(text);
    }
  }

  // Function to add user message to the chat
  void _addUserMessage(String text, File? file) {
    ChatMessage message = ChatMessage(
      text: text,
      isUser: true,
      file: file,
    );
    setState(() {
      _messages.insert(0, message);
      _isLoading = true;
    });
  }

  // Function to send message to the backend
  Future<void> _sendMessageToBackend(String text) async {
    final String apiUrl =
        "http://192.168.43.81:5000/ask"; // Update this with your backend URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": text}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String botResponse = jsonResponse['response'];
        _addAIResponse(botResponse);
      } else {
        _addAIResponse('Error: Unable to fetch response from server.');
      }
    } catch (e) {
      _addAIResponse('Error: Failed to connect to the server.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to send attached file (PDF/Image) to the backend
  Future<void> _sendFileToBackend(File file) async {
    final String apiUrl =
        "http://10.103.119.157:5000/upload"; // Update this with your backend URL

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: path.basename(file.path),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = json.decode(responseData.body);
        String answer = data['response'];
        _addAIResponse(answer);
      } else {
        _addAIResponse('Error: Failed to upload file.');
      }
    } catch (e) {
      _addAIResponse('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to add AI response to the chat
  void _addAIResponse(String text) {
    ChatMessage aiMessage = ChatMessage(
      text: text,
      isUser: false,
    );
    setState(() {
      _messages.insert(0, aiMessage);
    });
  }

  // Function to pick a file (PDF or Image)
  void _pickFile() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _attachedFile = File(pickedFile.path);
      });
    }
  }

  // Widget to build message composer
  Widget _buildMessageComposer() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 50.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.white70),
            onPressed: _pickFile,
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
                  hintText: _attachedFile != null
                      ? 'File selected'
                      : 'Type a message...',
                  hintStyle:
                      TextStyle(color: Colors.white54, fontFamily: 'Aleo'),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty || _attachedFile != null) {
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
                if (_textController.text.isNotEmpty || _attachedFile != null) {
                  _handleSubmitted(_textController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build attached file preview
  Widget _buildAttachmentPreview() {
    if (_attachedFile != null) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Image.file(
              _attachedFile!,
              width: 100,
              height: 100,
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _attachedFile = null;
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

// ChatMessage Widget to display messages in the chat
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final File? file;

  ChatMessage({required this.text, required this.isUser, this.file});

  @override
  Widget build(BuildContext context) {
    Widget messageContent;

    if (file != null) {
      messageContent = Image.file(
        file!,
        width: 200,
        height: 200,
      );
    } else {
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
