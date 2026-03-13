import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> RegistrationUser(BuildContext context, String email, String password) async {
  try {
    // Добавляем await, чтобы дождаться завершения регистрации
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Если всё прошло успешно
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация прошла успешно!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    print('User created: ${credential.user?.uid}');

  } on FirebaseAuthException catch (e) {
    // Обработка конкретных ошибок Firebase
    String message = 'Произошла ошибка';
    
    if (e.code == 'weak-password') {
      message = 'Пароль слишком слабый';
    } else if (e.code == 'email-already-in-use') {
      message = 'Этот email уже занят';
    } else if (e.code == 'invalid-email') {
      message = 'Некорректный формат email';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    // Любые другие ошибки
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }
}