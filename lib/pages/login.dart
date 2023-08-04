import 'package:flutter/material.dart';
import 'package:journal/blocs/login_bloc.dart';
import 'package:journal/services/authentication.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginBloc? _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(AuthenticationService());
  }

  @override
  void dispose() {
    _loginBloc!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Column _buttonsCreateAccount() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder(
            initialData: false,
            stream: _loginBloc!.enableLoginCreateButton,
            builder: (context, snapshot) {
              return ElevatedButton(
                child: Text('Create Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade200,
                  disabledBackgroundColor: Colors.lightGreen.shade100,
                ),
                onPressed: snapshot.data! ? () => _loginBloc!.loginOrCreateChanged.add('Create Account') : null,
              );
            },
          ),
          TextButton(
            child: Text('Login'),
            onPressed: () {
              _loginBloc!.loginOrCreateButtonChanged.add('Login');
            },
          ),
        ],
      );
    }

    Column _buttonsLogin() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder(
            initialData: false,
            stream: _loginBloc!.enableLoginCreateButton,
            builder: (context, snapshot) {
              return ElevatedButton(
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade200,
                  disabledBackgroundColor: Colors.lightGreen.shade100,
                ),
                onPressed: snapshot.data! ? () => _loginBloc!.loginOrCreateChanged.add('Login') : null,
              );
            },
          ),
          TextButton(
            child: Text('Create Account'),
            onPressed: () {
              _loginBloc!.loginOrCreateButtonChanged.add('Create Account');
            },
          ),
        ],
      );
    }

    Widget _buildLoginAndCreateButtons() {
      return StreamBuilder(
        initialData: 'Login',
        stream: _loginBloc!.loginOrCreateButton,
        builder: (context, snapshot) {
          if (snapshot.data == 'Login') {
            return _buttonsLogin();
          } else if (snapshot.data == 'Create Account') {
            return _buttonsCreateAccount();
          } else {
            return _buttonsLogin();
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          child: Icon(
            Icons.account_circle,
            size: 88.0,
            color: Colors.white,
          ),
          preferredSize: Size.fromHeight(40.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 32.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder(
                stream: _loginBloc!.email,
                builder: (context, snapshot) {
                  return TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      icon: Icon(Icons.mail_outline),
                      errorText: snapshot.error != null ? snapshot.error.toString() : '',
                    ),
                    onChanged: _loginBloc!.emailChanged.add,
                  );
                },
              ),
              StreamBuilder(
                stream: _loginBloc!.password,
                builder: (context, snapshot) {
                  return TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.security),
                      errorText: snapshot.error != null ? snapshot.error.toString() : '',
                    ),
                    onChanged: _loginBloc!.passwordChanged.add,
                  );
                },
              ),
              SizedBox(height: 48.0),
              _buildLoginAndCreateButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
