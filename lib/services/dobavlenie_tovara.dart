import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MarketService {
  static Future<void> purchaseProduct(BuildContext context, Map<String, dynamic> product) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final String productName = product['name'] ?? 'Товар';
  
  final dynamic rawPrice = product['price'];
  final int productPrice = (rawPrice is String) 
      ? int.tryParse(rawPrice) ?? 0 
      : (rawPrice as num).toInt();

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final purchasesQuery = await userRef
          .collection('purchases')
          .where('name', isEqualTo: productName)
          .get();


      if (purchasesQuery.docs.isNotEmpty) {
        throw "Вы уже приобрели товар «$productName»";
      }

      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) throw "Профиль не найден";

      final dynamic rawBalance = userSnapshot.data()?['balance'];
      int currentBalance = (rawBalance is String) 
          ? int.tryParse(rawBalance) ?? 0 
          : (rawBalance as num? ?? 0).toInt();

      if (currentBalance < productPrice) throw "Недостаточно поинтов";

      transaction.update(userRef, {'balance': currentBalance - productPrice});

      // 4. Добавляем в подколлекцию
      final newPurchaseRef = userRef.collection('purchases').doc(); // создаем новый ID
      transaction.set(newPurchaseRef, {
        'productId': product['id'],
        'name': productName,
        'price': productPrice,
        'image': product['image'],
        'purchasedAt': FieldValue.serverTimestamp(),
      });
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Покупка успешна!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()), 
        backgroundColor: Colors.orange
      ),
    );
  }
}
}

