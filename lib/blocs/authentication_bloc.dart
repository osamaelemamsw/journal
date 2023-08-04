import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/services/authentication_api.dart';

class AuthenticationBloc {
  AuthenticationBloc(this.authenticationApi) {
    onAuthChanged();
  }

  final AuthenticationApi authenticationApi;

  final StreamController<String?> _authenticationController = StreamController<String?>();
  Sink<String?> get addUser => _authenticationController.sink;
  Stream<String?> get user => _authenticationController.stream;

  final StreamController<bool> _logoutController = StreamController<bool>();
  Sink<bool> get logoutUser => _logoutController.sink;
  Stream<bool> get listLogoutUser => _logoutController.stream;

  void dispose() {
    _authenticationController.close();
    _logoutController.close();
  }

  void onAuthChanged() {
    authenticationApi.getFirebaseAuth().authStateChanges().listen((User? user) {
      if (user != null) {
        final String uid = user.uid;
        addUser.add(uid);
      } else {
        addUser.add(null);
      }

      _logoutController.stream.listen((logout) {
        if (logout) {
          _signOut();
        }
      });
    });
  }

  void _signOut() {
    authenticationApi.signOut();
  }
}