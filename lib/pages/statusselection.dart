import 'package:flutter/material.dart';
import 'package:vector/pages/mainpage.dart';
import 'package:vector/services/selectstatus.dart';
import 'package:vector/pages/profile.dart';

class StatusSelectionPage extends StatefulWidget {
  const StatusSelectionPage({super.key});

  @override
  State<StatusSelectionPage> createState() => _StatusSelectionPageState();
}

class _StatusSelectionPageState extends State<StatusSelectionPage> {
  final UserService _userService = UserService(); 
  int selectedIndex = -1;
  bool _isLoading = false;

 Future<void> _handleNextStep() async {
  setState(() => _isLoading = true);

  try {
    await _userService.updateUserStatus(selectedIndex);

    if (mounted) {
      // 1. Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Статус обновлен!'), backgroundColor: Colors.green),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  ProfileFormPage()),
        (route) => false, 
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),

              _statusCard(0, Icons.backpack, Colors.blue, 'Школьник', 'Средняя / Старшая школа'),
              const SizedBox(height: 16),
              _statusCard(1, Icons.school, Colors.purple, 'Студент', 'Колледж / Университет / Магистратура'),
              const SizedBox(height: 16),
              _statusCard(2, Icons.work, Colors.teal, 'Молодой специалист', 'Работа / Стажировка '),

              const Spacer(),

              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  

 

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Какой у вас текущий\nстатус?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Мы настроим вашу ленту на основе выбора',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (selectedIndex == -1 || _isLoading) ? null : _handleNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Далее', style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
      ),
    );
  }

  Widget _statusCard(int index, IconData icon, Color iconColor, String title, String subtitle) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF007AFF) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
