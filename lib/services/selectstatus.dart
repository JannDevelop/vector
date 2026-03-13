import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Список меток статуса (теперь хранится в одном месте)
  static const List<String> statusLabels = [
    'School Student',
    'University Student',
    'Young Professional'
  ];

  /// Сохраняет выбранный статус в документ пользователя
  Future<void> updateUserStatus(int selectedIndex) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      if (selectedIndex < 0 || selectedIndex >= statusLabels.length) {
        throw Exception('Некорректный выбор статуса');
      }

      await _db.collection('users').doc(user.uid).set({
        'status': statusLabels[selectedIndex],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      // Пробрасываем ошибку дальше, чтобы UI мог её обработать
      rethrow;
    }
  }

  /// Проверка, авторизован ли пользователь
  bool isUserLoggedIn() => _auth.currentUser != null;
}