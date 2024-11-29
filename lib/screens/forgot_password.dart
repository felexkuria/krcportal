import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart'; // Assuming AuthService is in a services folder

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isProcessing = false;
  String _message = '';

  void _resetPassword() async {
    setState(() {
      _isProcessing = true;
      _message = ''; // Clear previous message
    });

    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter an email address';
        _isProcessing = false;
      });
      return;
    }

    try {
      // Call the reset password method in AuthService
      await AuthService.resetPassword(email);

      setState(() {
        _message = 'Password reset email sent. Please check your inbox.';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                hintText: 'example@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isProcessing ? null : _resetPassword,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Send Password Reset Email'),
            ),
            const SizedBox(height: 16.0),
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('sent') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
