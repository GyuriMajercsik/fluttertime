import 'package:flutter/material.dart';
import 'package:flutter_time/src/blocs/register/register_form.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: RegisterForm(),
      ),
    );
  }
}
