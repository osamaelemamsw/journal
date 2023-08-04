import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/blocs/journal_entry_bloc.dart';
import 'package:journal/classes/FormatDates.dart';
import 'package:journal/classes/mood_icons.dart';

class EditEntry extends StatefulWidget {
  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEditBloc? _journalEditBloc;
  FormatDates? _formatDates;
  MoodIcons? _moodIcons;
  TextEditingController? _noteController;

  @override
  void initState() {
    super.initState();
    _formatDates = FormatDates();
    _moodIcons = MoodIcons();
    _noteController = TextEditingController();
    _noteController!.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journalEditBloc = JournalEditBlocProvider.of(context).journalEditBloc;
  }

  @override
  void dispose() {
    _noteController!.dispose();
    _journalEditBloc!.dispose();
    super.dispose();
  }

  Future<String> _selectDate(String selectedDate) async {
    DateTime _initialDate = DateTime.parse(selectedDate);

    final DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (_pickedDate != null) {
      selectedDate = DateTime(
        _pickedDate.year,
        _pickedDate.month,
        _pickedDate.day,
        _pickedDate.hour,
        _pickedDate.minute,
        _pickedDate.second,
        _pickedDate.millisecond,
        _pickedDate.microsecond,
      ).toString();
    }

    return selectedDate;
  }

  void _addOrUpdateJournal() {
    _journalEditBloc!.saveJournalChanged.add('Save');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entry',
          style: TextStyle(color: Colors.lightGreen.shade800),
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                stream: _journalEditBloc!.dateEdit,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return TextButton(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 22.0,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          _formatDates!.dateFormatShortMonthDayYear(snapshot.data!),
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      String _pickerDate = await _selectDate(snapshot.data!);
                      _journalEditBloc!.dateEditChanged.add(_pickerDate);
                    },
                  );
                },
              ),
              StreamBuilder(
                stream: _journalEditBloc!.moodEdit,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<MoodIcons>(
                      value:
                          _moodIcons!.getMoodIconslist()[_moodIcons!.getMoodIconslist().indexWhere((icon) => icon.title == snapshot.data)],
                      onChanged: (selected) {
                        _journalEditBloc!.moodEditChanged.add(selected!.title!);
                      },
                      items: _moodIcons!.getMoodIconslist().map((MoodIcons selected) {
                        return DropdownMenuItem<MoodIcons>(
                          value: selected,
                          child: Row(
                            children: [
                              Transform(
                                transform: Matrix4.identity()..rotateZ(_moodIcons!.getMoodRotation(selected.title!)!),
                                alignment: Alignment.center,
                                child: Icon(
                                  _moodIcons!.getMoodIcon(selected.title!),
                                  color: _moodIcons!.getMoodColor(selected.title!),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Text(selected.title!),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              StreamBuilder(
                stream: _journalEditBloc!.noteEdit,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  _noteController!.value = _noteController!.value.copyWith(text: snapshot.data);

                  return TextField(
                    controller: _noteController,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      icon: Icon(Icons.subject),
                    ),
                    maxLines: null,
                    onChanged: (note) => _journalEditBloc!.noteEditChanged.add(note),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('Cancel'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 8.0),
                  TextButton(
                    child: Text('Save'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightGreen.shade100,
                    ),
                    onPressed: () {
                      _addOrUpdateJournal();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
