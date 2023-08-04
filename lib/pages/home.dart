import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';
import 'package:journal/classes/FormatDates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/pages/edit_entry.dart';
import 'package:journal/services/db_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    AuthenticationBloc? _authenticationBloc = AuthenticationBlocProvider.of(context).authenticationBloc;
    HomeBloc? _homeBloc = HomeBlocProvider.of(context).homeBloc;
    String? _uid = HomeBlocProvider.of(context).uid;
    MoodIcons _moodIcons = MoodIcons();
    FormatDates _formatDates = FormatDates();

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _authenticationBloc = AuthenticationBlocProvider.of(context).authenticationBloc;
      _homeBloc = HomeBlocProvider.of(context).homeBloc;
      _uid = HomeBlocProvider.of(context).uid;
    }

    @override
    void dispose() {
      _homeBloc!.dispose();
      super.dispose();
    }

    void _addOrEditJournal({required bool add, required Journal journal}) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return JournalEditBlocProvider(
              journalEditBloc: JournalEditBloc(add, journal, DbFirestoreService()),
              child: EditEntry(),
            );
          },
          fullscreenDialog: true,
        ),
      );
    }

    Future<bool> _confirmDeleteJournal() async {
      return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Journal'),
            content: Text('Are you sure you would like to Delete?'),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              TextButton(
                child: Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      );
    }

    Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
      return ListView.separated(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          String _titleDate = _formatDates.dateFormatShortMonthDayYear(snapshot.data[index].date);
          String _subtitle = snapshot.data[index].mood + '\n' + snapshot.data[index].note;
          return Dismissible(
            key: Key(snapshot.data[index].documentID),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: [
                  Text(
                    _formatDates.dateFormatDayNumber(snapshot.data[index].date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.lightGreen,
                    ),
                  ),
                  Text(_formatDates.dateFormatShortDayName(snapshot.data[index].date)),
                ],
              ),
              trailing: Transform(
                transform: Matrix4.identity()..rotateZ(_moodIcons.getMoodRotation(snapshot.data[index].mood)!),
                alignment: Alignment.center,
                child: Icon(
                  _moodIcons.getMoodIcon(snapshot.data[index].mood),
                  color: _moodIcons.getMoodColor(snapshot.data[index].mood),
                  size: 42.0,
                ),
              ),
              title: Text(
                _titleDate,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_subtitle),
              onTap: () {
                _addOrEditJournal(
                  add: false,
                  journal: snapshot.data[index],
                );
              },
            ),
            confirmDismiss: (direction) async {
              bool confirmDelete = await _confirmDeleteJournal();
              if (confirmDelete) {
                _homeBloc!.deleteJournal.add(snapshot.data[index]);
              }
            },
          );
        },
        separatorBuilder: (context, index) => Divider(color: Colors.grey),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        bottom: PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(32.0),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          'Journal',
          style: TextStyle(
            color: Colors.lightGreen.shade800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _authenticationBloc!.logoutUser.add(true);
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.lightGreen.shade800,
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen.shade50, Colors.lightGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _addOrEditJournal(add: true, journal: Journal(uid: _uid!));
        },
        tooltip: 'Add Journal Entry',
        backgroundColor: Colors.lightGreen.shade300,
        child: Icon(
          Icons.add,
        ),
      ),
      body: StreamBuilder(
        stream: _homeBloc!.listJournal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            print(snapshot.data);
            return _buildListViewSeparated(snapshot);
          } else {
            return Center(
              child: Container(
                child: Text('Add Journals'),
              ),
            );
          }
        },
      ),
    );
  }
}
