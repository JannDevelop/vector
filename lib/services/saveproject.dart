import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> saveProjectToFirebase({
  required BuildContext context,
  required String name,
  required String description,
  required String rolesNeeded,
  required String city,
  required bool isRemote,
  required String category,
  required String status,
  required String ownerId,   // Добавили
  required String ownerName, // Добавили
}) async {
  // Внутри функции добавьте эти поля в Map для Firebase:
  await FirebaseFirestore.instance.collection('projects').add({
    'name': name,
    'description': description,
    'ownerId': ownerId,     // <--- ТЕПЕРЬ ОНО СОХРАНИТСЯ
    'ownerName': ownerName, // <--- И ЭТО
    'status': status,
    // ... все остальные ваши поля
  });
}
