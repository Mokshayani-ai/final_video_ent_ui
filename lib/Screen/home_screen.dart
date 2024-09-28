// home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/Screen/Corpus_screen.dart';
import 'package:my_app/Screen/chat_screen.dart';
import 'package:my_app/Screen/login_page.dart';
import 'package:my_app/Screen/org_corpus_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class HomeScreen extends StatefulWidget {
  final String userName;
  final File? profileImage;

  HomeScreen({required this.userName, this.profileImage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greetingMessage = '';
  File? selectedFile;
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    greetingMessage = _getGreetingMessage();
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good\nmorning,';
    } else if (hour < 17) {
      return 'Good\nafternoon,';
    } else {
      return 'Good\nevening,';
    }
  }

  // Function to pick a file or image
  Future<void> _pickFile() async {
    try {
      final option = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Color(0xFF292D32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Colors.white),
                  title: Text('Take a photo',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.white),
                  title: Text('Choose from gallery',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: Icon(Icons.file_copy, color: Colors.white),
                  title: Text('Choose a file',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, 'file'),
                ),
              ],
            ),
          );
        },
      );

      if (option == null) return;

      File? file;
      final picker = ImagePicker();

      switch (option) {
        case 'camera':
          final pickedFile = await picker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) file = File(pickedFile.path);
          break;
        case 'gallery':
          final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) file = File(pickedFile.path);
          break;
        case 'file':
          final pickedFile =
              await FilePicker.platform.pickFiles(type: FileType.any);
          if (pickedFile != null) file = File(pickedFile.files.single.path!);
          break;
      }

      if (file != null) {
        // After selecting the file, ask user where to upload
        _showCorpusSelectionDialog(file);
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  // Function to show corpus selection dialog
  void _showCorpusSelectionDialog(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Corpus',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Aleo',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: Color(0xFF292D32),
          content: Text('Where do you want to add this file?',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Aleo',
                fontSize: 15,
              )),
          actions: <Widget>[
            TextButton(
              child: Text('My Corpus',
                  style: TextStyle(
                    fontFamily: 'Aleo',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                String fileName = path.basename(file.path);
                _sendFileToBackend(file, fileName, 'my_corpus');
              },
            ),
            TextButton(
              child: Text('Org. Corpus',
                  style: TextStyle(
                    fontFamily: 'Aleo',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                String fileName = path.basename(file.path);
                _sendFileToBackend(file, fileName, 'org_corpus');
              },
            ),
          ],
        );
      },
    );
  }

  // Function to send file to the backend
  Future<void> _sendFileToBackend(
      File file, String fileName, String corpusType) async {
    String apiUrl = 'http://localhost:5000/upload'; // Replace with your API URL

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path,
        filename: fileName));

    // Add corpus type to the request
    request.fields['corpus_type'] = corpusType;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Handle successful upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully')),
        );

        // Optionally, navigate to the corresponding corpus screen
        if (corpusType == 'my_corpus') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCorpus()),
          );
        } else if (corpusType == 'org_corpus') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrgCorpus()),
          );
        }
      } else {
        // Handle upload failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed')),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during file upload')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF164858),
              Color(0xFF272222),
            ],
            begin: Alignment(2.3, -0.5),
            end: Alignment(1.0, 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MOKSHAYANI.AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Aleo",
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$greetingMessage\n${widget.userName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          // Logout logic
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('LOG-OUT',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Aleo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    )),
                                backgroundColor: Color(0xFF292D32),
                                content:
                                    Text('Are you sure you want to logout?',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'Aleo',
                                          fontSize: 15,
                                        )),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel',
                                        style: TextStyle(
                                          fontFamily: 'Aleo',
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Log-out',
                                        style: TextStyle(
                                          fontFamily: 'Aleo',
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: widget.profileImage != null
                              ? FileImage(widget.profileImage!)
                              : AssetImage('assets/images/default_profile.png')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // Corpus buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyCorpus()),
                        );
                      },
                      child: Text(
                        'My Corpus',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Aleo',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF353C53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(10, 50),
                      ),
                    ),
                    SizedBox(width: 7),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrgCorpus()),
                        );
                      },
                      child: Text(
                        'Org. Corpus',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Aleo',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF353C53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey, width: 0.35),
                        ),
                        minimumSize: Size(0, 50),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Color(0xFF33363E),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.attach_file,
                //         color: Colors.white60,
                //       ),
                //       Expanded(
                //         child: Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //           child: TextField(
                //             maxLines: 1,
                //             decoration: InputDecoration(
                //               hintText: 'What do you wanna know?',
                //               hintStyle: TextStyle(
                //                   color: Colors.grey,
                //                   fontSize: 13,
                //                   fontFamily: 'Aleo'),
                //               border: InputBorder.none,
                //             ),
                //           ),
                //         ),
                //       ),
                //       ElevatedButton(
                //         onPressed: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (context) => ChatScreen()),
                //           );
                //         },
                //         child: Text(
                //           '➤',
                //           style: TextStyle(
                //             color: Colors.black,
                //             fontFamily: 'Aleo',
                //             fontSize: 20,
                //           ),
                //         ),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.white70,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(50),
                //           ),
                //         ),
                //       ),
                //       SizedBox(height: 20),
                //     ],
                //   ),
                // ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF33363E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Colors.white60,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            maxLines: 1,
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'What do you wanna know?',
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontFamily: 'Aleo'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  initialMessage: query,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          '➤',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Aleo',
                            fontSize: 20,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Upload button
                Center(
                  child: ElevatedButton(
                    onPressed: _pickFile,
                    child: Text(
                      'Upload File or Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Aleo',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF353C53),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey, width: 0.35)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // "Chat History" section
                Text(
                  "Chat History",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Aleo',
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF292D32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF33363E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Sample chat message #$index',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Aleo',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
