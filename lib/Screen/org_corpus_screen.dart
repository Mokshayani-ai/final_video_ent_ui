import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrgCorpus extends StatefulWidget {
  @override
  _OrgCorpusState createState() => _OrgCorpusState();
}

class _OrgCorpusState extends State<OrgCorpus> {
  List<FileInfo> files = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoadingTimer();
    _fetchFiles();
  }

  Future<void> _startLoadingTimer() async {
    await Future.delayed(Duration(seconds: 5));
    if (isLoading) {
      setState(() {
        isLoading = false;
        if (files.isEmpty) {
          _loadDefaultFiles(); // Load default files after 5 seconds
        }
      });
    }
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
        _loadDefaultFiles(); // Load default files if fetching fails
      }
    } catch (e) {
      print('Error fetching files: $e');
      _loadDefaultFiles(); // Load default files in case of an error
    }
  }

  void _loadDefaultFiles() {
    setState(() {
      files = [
        FileInfo(name: 'HR_Policies_Doc.pdf', uploadDate: 1694870400.0),
        FileInfo(name: 'PRD_1.pdf', uploadDate: 1694946000.0),
        FileInfo(name: 'Events2024.pdf', uploadDate: 1695032400.0),
        FileInfo(name: 'Handbook.pdf', uploadDate: 1695118800.0),
      ];
    });
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
        title: Text('Org. Corpus'),
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
