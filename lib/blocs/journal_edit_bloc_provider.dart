import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';
import 'package:journal/models/journal.dart';

class JournalEditBlocProvider extends InheritedWidget {
  const JournalEditBlocProvider({Key? key, required Widget child, required this.journalEditBloc}) : super(key: key, child: child);

  final JournalEditBloc journalEditBloc;
  // final bool add;
  // final Journal journal;

  @override
  bool updateShouldNotify(JournalEditBlocProvider oldWidget) => false;

  static JournalEditBlocProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<JournalEditBlocProvider>() as JournalEditBlocProvider);
  }
}