class Journal {
  Journal({
    this.documentID,
    this.date,
    this.mood,
    this.note,
    required this.uid,
  });

  factory Journal.fromDoc(dynamic doc) => Journal(
        documentID: doc.id,
        date: doc['date'],
        mood: doc['mood'],
        note: doc['note'],
        uid: doc['uid'],
      );

  String? documentID;
  String? date;
  String? mood;
  String? note;
  String uid;
}
