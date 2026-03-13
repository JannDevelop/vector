import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> redeemQRCode(String scannedCode) async {
    final user = _auth.currentUser;
    if (user == null) throw 'Пользователь не авторизован';

    // 1. Ищем QR-код в базе
    final codeDoc = await _db.collection('event_codes').doc(scannedCode).get();
    if (!codeDoc.exists) throw 'Неверный QR-код';

    final int pointsToAdd = codeDoc.data()?['points'] ?? 0;

    // 2. Проверяем, не сканировал ли уже (защита от повторов)
    final historyRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .doc(scannedCode);
    
    final historyDoc = await historyRef.get();
    if (historyDoc.exists) throw 'Вы уже сканировали этот код';

   await _db.runTransaction((transaction) async {
    final userRef = _db.collection('users').doc(user.uid);
    // Ссылка на новую коллекцию для аналитики (генерируем ID автоматически)
    final logRef = _db.collection('point_logs').doc(); 

    final userSnapshot = await transaction.get(userRef);

    // Обновляем баланс пользователя
    if (!userSnapshot.exists) {
      transaction.set(userRef, {
        'balance': pointsToAdd,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      int currentBalance = userSnapshot.data()?['balance'] ?? 0;
      transaction.update(userRef, {
        'balance': currentBalance + pointsToAdd,
      });
    }

    // Записываем в личную историю пользователя
    transaction.set(historyRef, {
      'scannedAt': FieldValue.serverTimestamp(),
      'points': pointsToAdd,
      'code': scannedCode,
    });

    // --- НОВОЕ: Запись в общую коллекцию для графиков аналитики ---
    transaction.set(logRef, {
      'amount': pointsToAdd,
      'timestamp': FieldValue.serverTimestamp(), // Используем серверное время для точности
      'userId': user.uid,
      'type': 'qr_scan', // Полезно, если потом добавишь баллы за проекты или чаты
    });
  });
}
}