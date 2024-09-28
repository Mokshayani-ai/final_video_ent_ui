// login_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Screen/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignUp = false;

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variables for image picking
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery); // Or ImageSource.camera
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
          begin: Alignment(2.0, -0.6),
          end: Alignment(1.0, 0.5),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset("assets/images/white_nobg_logo.png"),
              ),
              const SizedBox(height: 16),
              const Text(
                'MOKSHAYANI.AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Aleo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 330,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF292D32),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SIGN-IN Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSignUp = false;
                          });
                        },
                        child: Text("SIGN-IN",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Aleo',
                              fontSize: 15,
                            )),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: isSignUp
                                ? Color(0xFF33363E)
                                : Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                            minimumSize: Size(0, 50)),
                      ),
                      SizedBox(width: 16),
                      // SIGN-UP Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSignUp = true;
                          });
                        },
                        child: Text("SIGN-UP",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Aleo',
                              fontSize: 15,
                            )),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: isSignUp
                                ? Colors.blueAccent
                                : Color(0xFF33363E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                            minimumSize: Size(0, 50)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sign-Up specific fields
                  if (isSignUp) ...[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/images/default_profile.png')
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Name Field
                    Container(
                      width: 260,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          filled: true,
                          fillColor: Color(0xFF444343),
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 150, 149, 149),
                            fontFamily: 'Aleo',
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  // Email Field
                  Container(
                    width: 260,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        filled: true,
                        fillColor: Color(0xFF444343),
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 150, 149, 149),
                          fontFamily: 'Aleo',
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password Field
                  Container(
                    width: 260,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        filled: true,
                        fillColor: Color(0xFF444343),
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 150, 149, 149),
                          fontFamily: 'Aleo',
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Continue Button
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isSignUp) {
                          // Handle sign-up logic
                          String name = nameController.text.trim();
                          String email = emailController.text.trim();
                          String password = passwordController.text;
                          File? profileImage = _profileImage;

                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please fill in all required fields')),
                            );
                            return;
                          }

                          // TODO: Implement sign-up logic with name, email, password, and profileImage
                          print('Signing up with: $name, $email');

                          // After successful sign-up
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                userName: name,
                                profileImage: profileImage,
                              ),
                            ),
                          );
                        } else {
                          // Handle sign-in logic
                          String email = emailController.text.trim();
                          String password = passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please enter your email and password')),
                            );
                            return;
                          }

                          // TODO: Implement sign-in logic with email and password
                          print('Signing in with: $email');

                          // Retrieve the user's name and profile image after sign-in
                          String name = await getUserNameByEmail(email);
                          File? profileImage = await getUserProfileImage(email);

                          // After successful sign-in
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                userName: name,
                                profileImage: profileImage,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Aleo',
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Colors.white70, width: 1)),
                          minimumSize: Size(0, 50)),
                    ),
                  ),
                  SizedBox(height: 10),
                ]),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // Placeholder function to simulate retrieving user's name by email
  Future<String> getUserNameByEmail(String email) async {
    // TODO: Replace with actual logic to retrieve user's name
    // For example, query your database or authentication service
    await Future.delayed(Duration(seconds: 1));
    return 'User'; // Replace with the actual name
  }

  // Placeholder function to simulate retrieving user's profile image by email
  Future<File?> getUserProfileImage(String email) async {
    // TODO: Replace with actual logic to retrieve user's profile image
    // For example, download from your server or load from local storage
    return null; // Replace with the actual profile image File
  }
}
