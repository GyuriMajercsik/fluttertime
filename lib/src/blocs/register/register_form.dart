import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/authentication/bloc.dart';
import 'package:flutter_time/src/blocs/register/bloc.dart';
import 'package:flutter_time/src/blocs/register/register_button.dart';
import 'package:flutter_time/src/blocs/register/register_keys.dart';
import 'package:logging/logging.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final Logger _logger = Logger('RegisterForm');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerBloc = getIt<RegisterBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _registerBloc,
      listener: (BuildContext context, RegisterState state) {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registering...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          getIt<AuthenticationBloc>().dispatch(LoggedIn());
          Navigator.of(context).pop();
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registration Failure'),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder(
        bloc: _registerBloc,
        builder: (BuildContext context, RegisterState state) {
          _logger.finest(('New register state received: $state and '
              'the register button is ${isRegisterButtonEnabled(state) ? 'enabled' : 'disabled'}'));
          return Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              child: ListView(
                children: <Widget>[
                  _buildEmailTextFormField(state),
                  _buildPasswordTextFormField(state),
                  RegisterButton(
                    onPressed: isRegisterButtonEnabled(state)
                        ? _onFormSubmitted
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextFormField _buildPasswordTextFormField(RegisterState state) {
    return TextFormField(
      key: registerPasswordKey,
      controller: _passwordController,
      decoration: InputDecoration(
        icon: Icon(Icons.lock),
        labelText: 'Password',
      ),
      obscureText: true,
      autocorrect: false,
      autovalidate: true,
      validator: (_) {
        return !state.isPasswordValid ? 'Invalid Password' : null;
      },
    );
  }

  TextFormField _buildEmailTextFormField(RegisterState state) {
    return TextFormField(
      key: registerEmailKey,
      controller: _emailController,
      decoration: InputDecoration(
        icon: Icon(Icons.email),
        labelText: 'Email',
      ),
      autocorrect: false,
      autovalidate: true,
      validator: (_) {
        return !state.isEmailValid ? 'Invalid Email' : null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _logger.finest('Email changed ${_emailController.text}');
    _registerBloc.dispatch(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _logger.finest('Password changed ${_emailController.text}');
    _registerBloc.dispatch(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.dispatch(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
