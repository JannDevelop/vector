import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String type; // Hackathon, Meetup, Workshop
  final String location;
  final DateTime date;
  final String imageUrl;
  final bool isOnline;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.isOnline,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'Event',
      location: data['location'] ?? '',
      date: data['date'] is Timestamp 
    ? (data['date'] as Timestamp).toDate() 
    : DateTime.now(),
      imageUrl: data['imageUrl'] ?? '',
      isOnline: data['isOnline'] ?? false,
    );
  }
}