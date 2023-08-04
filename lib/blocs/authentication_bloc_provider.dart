import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';

class AuthenticationBlocProvider extends InheritedWidget {
  AuthenticationBlocProvider({Key? key, Widget? child, this.authenticationBloc}) : super(key: key, child: child!);

  @override
  bool updateShouldNotify(AuthenticationBlocProvider oldWidget) => authenticationBloc != oldWidget.authenticationBloc;

  final AuthenticationBloc? authenticationBloc;

  static AuthenticationBlocProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<AuthenticationBlocProvider>() as AuthenticationBlocProvider);
  }
}