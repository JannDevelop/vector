import 'package:flutter/material.dart';
import 'package:vector/pages/statusselection.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // Список выбранных категорий (изначально пустой)
  final Set<String> _selectedInterests = {};

  void _toggleInterest(String title) {
    setState(() {
      if (_selectedInterests.contains(title)) {
        _selectedInterests.remove(title);
      } else {
        _selectedInterests.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Заголовок
              const Text(
                'Что вас интересует?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0D14),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Выберите минимум 3 темы, чтобы мы могли подобрать для вас подходящие возможности.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Секции интересов
              _buildSectionTitle('ПОПУЛЯРНОЕ'),
              _buildInterestWrap([
                _InterestItem('Технологии и IT', Icons.code),
                _InterestItem('Творчество', Icons.palette),
                _InterestItem('Стартапы', Icons.rocket_launch),
                _InterestItem('Бизнес', Icons.business_center),
              ]),

              _buildSectionTitle('ВЛИЯНИЕ И СООБЩЕСТВО'),
              _buildInterestWrap([
                _InterestItem('Экология', Icons.eco),
                _InterestItem('Волонтерство', Icons.volunteer_activism),
                _InterestItem('Правосудие', Icons.gavel),
              ]),

              _buildSectionTitle('ОБРАЗ ЖИЗНИ И НАВЫКИ'),
              _buildInterestWrap([
                _InterestItem('Спорт', Icons.fitness_center),
                _InterestItem('Велнес', Icons.spa),
                _InterestItem('Маркетинг', Icons.campaign),
                _InterestItem('Data Science', Icons.storage),
                _InterestItem('Писательство', Icons.edit_note),
                _InterestItem('Фотография', Icons.photo_camera),
              ]),

              const SizedBox(height: 120), // Место под кнопку
            ],
          ),
        ),
      ),

      // Фиксированная кнопка внизу
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            // Кнопка активна только если выбрано 3 и более интереса
            onPressed: _selectedInterests.length >= 3
                ? () async {
                    // Опционально: сохраняем интересы в базу перед переходом
                    // await UserService().saveUserInterests(_selectedInterests);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  StatusSelectionPage(),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Продолжить',
                  style: TextStyle(
                    color: _selectedInterests.length >= 3
                        ? Colors.white
                        : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: _selectedInterests.length >= 3
                      ? Colors.white
                      : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInterestWrap(List<_InterestItem> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final isSelected = _selectedInterests.contains(item.title);
        return GestureDetector(
          onTap: () => _toggleInterest(item.title),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF007AFF)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(25),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? Colors.white : const Color(0xFF0A0D14),
                ),
                const SizedBox(width: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF0A0D14),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, size: 18, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InterestItem {
  final String title;
  final IconData icon;
  _InterestItem(this.title, this.icon);
}
