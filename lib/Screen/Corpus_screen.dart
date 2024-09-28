// my_corpus.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting

class MyCorpus extends StatefulWidget {
  @override
  _MyCorpusState createState() => _MyCorpusState();
}

class _MyCorpusState extends State<MyCorpus> {
  List<FileInfo> files = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    String apiUrl =
        'http://10.103.119.157:5000/ask'; // Replace with your API URL

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          files = (data['files'] as List)
              .map((file) => FileInfo.fromJson(file))
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to load files');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching files: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(double timestamp) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Corpus'),
        backgroundColor: Color(0xFF14323C),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF14323C),
              Color(0xFF272222),
            ],
            begin: Alignment(1.0, -0.5),
            end: Alignment(1.0, 0.5),
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : files.isEmpty
                ? Center(
                    child: Text(
                      'No files uploaded yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade600, width: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                files[index].name,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                _formatDate(files[index].uploadDate),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class FileInfo {
  final String name;
  final double uploadDate;

  FileInfo({required this.name, required this.uploadDate});

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      name: json['name'],
      uploadDate: json['uploadDate'],
    );
  }
}
