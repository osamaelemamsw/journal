import 'package:flutter/material.dart';
import 'package:journal/blocs/home_bloc.dart';

class HomeBlocProvider extends InheritedWidget {
  const HomeBlocProvider({Key? key, required Widget child, this.homeBloc, this.uid}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(HomeBlocProvider oldWidget) => homeBloc != oldWidget.homeBloc;

  static HomeBlocProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<HomeBlocProvider>() as HomeBlocProvider);
  }

  final HomeBloc? homeBloc;
  final String? uid;
}