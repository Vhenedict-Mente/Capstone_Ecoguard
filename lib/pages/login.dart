import 'dart:convert'; // Import for JSON decoding
import 'package:ecoguard/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isPasswordVisible = false; // Add variable to manage password visibility

  Future<void> login(BuildContext cont) async {
    if (username.text.isEmpty || password.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Both fields cannot be blank!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return; // Exit the function if fields are empty
    }

    var url =
        "https://ecoguard.cc.nf/localconnect/login.php"; // Adjust URL if necessary
    var response = await http.post(
      Uri.parse(url),
      body: {
        "username": username.text,
        "password": password.text,
      },
    );

    var data = json.decode(response.body);
    if (data == "success") {
      Navigator.of(cont).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
      // Custom duration (e.g., 5 seconds)
    } else {
      Fluttertoast.showToast(
        msg: "The user and password combination does not exist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  void navigateToSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignUpPage()), // Change to SignUpPage
    );
  }

  void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ForgotPasswordPage()), // Change to ForgotPasswordPage
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 15.0 : 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                width: mediaQuery.size.width *
                    (isPortrait ? 0.5 : 0.3), // Adapt width to screen size
                height: mediaQuery.size.height * (isPortrait ? 0.25 : 0.15),
              ),
              const Text(
                'Ecoguard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 55, 122, 38),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.03),
              Container(
                width: mediaQuery.size.width * 0.85, // Adaptive width
                child: TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              Container(
                width: mediaQuery.size.width * 0.85, // Adaptive width
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: !_isPasswordVisible,
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              TextButton(
                onPressed: () {
                  navigateToForgotPassword(context);
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              ElevatedButton(
                onPressed: () {
                  login(context);
                },
                child: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    mediaQuery.size.width * 0.4,
                    mediaQuery.size.height * 0.06,
                  ),
                  backgroundColor: const Color.fromARGB(255, 240, 244, 247),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(color: Colors.blueGrey),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          navigateToSignUp(context);
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(248, 252, 249, 111),
    );
  }
}

// SignUp Page
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController(); // New email controller
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> signUp() async {
    if (username.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "All fields are required!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    // Send data to your PHP backend for registration
    var url =
        "https://ecoguard.cc.nf/localconnect/signup.php"; // Replace with your local IP if needed
    var response = await http.post(
      Uri.parse(url),
      body: {
        "username": username.text,
        "email": email.text, // Add email field
        "password": password.text,
      },
    );

    var data = json.decode(response.body);
    if (data == "success") {
      Navigator.of(context)
          .pop(); // Go back to the login page after successful sign-up
      // Custom duration (e.g., 5 seconds)
      Future.delayed(Duration(seconds: 5), () {
        Fluttertoast.cancel(); // Dismiss the toast after 5 seconds
      });
    } else {
      Fluttertoast.showToast(
        msg: data, // Show the actual error message returned from the server
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 252, 249, 111),
        title: Text("Sign Up"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                width: 500,
                child: TextField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 500,
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 500,
                child: TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 500,
                child: TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: const Color.fromARGB(255, 240, 244, 247),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Email field cannot be blank!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      Future.delayed(Duration(seconds: 5), () {
        Fluttertoast.cancel(); // Dismiss the toast after 5 seconds
      });
      return;
    }

    var url =
        "https://ecoguard.cc.nf/localconnect/reset_password.php"; // Adjust URL as needed
    var response = await http.post(
      Uri.parse(url),
      body: {
        "email": emailController.text,
      },
    );

    var data = json.decode(response.body);
    if (data == "success") {
      Fluttertoast.showToast(
        msg: "Email Validation is successful.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewPasswordPage(email: emailController.text),
      ));
    } else {
      Fluttertoast.showToast(
        msg: "This email address is not registered. Please try another.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(248, 252, 249, 111),
        title: Text("Forgot Password"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Enter your email account to reset your password.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Container(
                width: 500,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => resetPassword(context),
                child: Text('Validate Email'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: const Color.fromARGB(255, 240, 244, 247),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }
}

class NewPasswordPage extends StatefulWidget {
  final String email;

  NewPasswordPage({required this.email});

  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> updatePassword() async {
    // Validate input fields
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in both password fields.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    if (newPasswordController.text.length < 8) {
      Fluttertoast.showToast(
        msg: "Password must be at least 8 characters long.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    // Define the API endpoint
    var url =
        "https://ecoguard.cc.nf/localconnect/update_password.php"; // Update with the correct URL

    // Send the POST request to the server
    var response = await http.post(
      Uri.parse(url),
      body: {
        "email": widget.email,
        "new_password": newPasswordController.text,
      },
    );

    var data = json.decode(response.body);

    // Check the response from the server
    if (data["status"] == "success") {
      Fluttertoast.showToast(
        msg: "Password updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      // Navigate back to the login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      Fluttertoast.showToast(
        msg: data["message"] ?? "Failed to update password.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set New Password"),
        backgroundColor: Color.fromARGB(248, 252, 249, 111),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width:
                    500, // Set a max width to keep it centered and consistent
                child: TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: !_isNewPasswordVisible,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 500, // Same max width as above
                child: TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updatePassword,
                child: Text('Update Password'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  backgroundColor: Color.fromARGB(255, 240, 244, 247),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(248, 252, 249, 111),
    );
  }
}
