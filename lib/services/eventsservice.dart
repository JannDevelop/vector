import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector/models/event_model.dart';

class EventService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

 Stream<List<EventModel>> getEvents({String? locationFilter}) {
  Query query = db.collection('events');

  // Если фильтр НЕ равен "Все города", тогда добавляем where
  if (locationFilter != null && locationFilter != "Все города" && locationFilter != "Все") {
    query = query.where('location', isEqualTo: locationFilter);
  }

  // Сортировка всегда в конце
  query = query.orderBy('date', descending: false);

  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
}
}