import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vector/pages/mainpage.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  Future<void> _showAddCustomTagDialog(String title, List<String> selectedTags) async {
  final TextEditingController customController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Добавить свой вариант', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: customController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Например: Редкий навык',
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final text = customController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (!selectedTags.contains(text)) {
                    selectedTags.add(text);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
  bool _isLoading = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  DateTime? _selectedDate;

  final List<String> _selectedSkills = [];
  final List<String> _selectedAchievements = [];
  final List<String> _selectedGoals = [];
  final List<String> _selectedInterests = [];

  final List<Map<String, String>> _certificates = [];

  final List<String> _availableSkills = [
    'Python', 'Flutter', 'Java', 'Kotlin', 'Swift', 'C++', 'C# (.NET)', 
    'JavaScript/TypeScript', 'React/Vue', 'SQL', 'UI/UX Дизайн', 
    'Графический дизайн', 'Motion Design', 'QA (Тестирование)', 
    'Project Management', 'Product Management', 'Маркетинг', 'SMM', 
    'Data Science', 'BI Аналитика', 'DevOps', 'Кибербезопасность', 
    'Copywriting', 'Public Speaking'
  ];
 final List<String> _availableAchievements = [
    'Республиканская олимпиада (Диплом)', 'Областная олимпиада (Диплом)', 
    '100 идей для Беларуси (Победитель)', '100 идей для Беларуси (Финалист)',
    'Хакатон (Победитель)', 'Хакатон (Участник)', 'Стартап-акселератор (Выпускник)',
    'Сертификат ПВТ (IT-Academy)', 'Стипендиат фонда Президента', 
    'Научная работа (БГУ/БГУИР/БНТУ)', 'Волонтерство (LSP/ЮНИСЕФ/RedCross)',
    'Мастер спорта / Разряд', 'Победа в международном конкурсе'
  ];
  final List<String> _availableGoals = [
    'Стажировка в крупной IT-компании', 'Первая работа (Junior role)', 
    'Резиденство в ПВТ (стартап)', 'Поиск ментора', 'Запуск MVP', 
    'Сбор команды для хакатона', 'Поступление в зарубежный вуз/магистратуру',
    'Нетворкинг и связи', 'Изучение нового стека', 'Создание личного бренда',
    'Участие в open-source проектах', 'Удаленная работа на зарубежный рынок'
  ];
  final List<String> _availableInterests = [
    'IT и Технологии', 'Искусственный интеллект', 'GameDev (Разработка игр)', 
    'Экология и GreenTech', 'Спорт и киберспорт', 'Современное искусство', 
    'Финансы и Инвестиции', 'Психология', 'Путешествия', 
    'Настольные игры',  'Урбанистика', 'Кинематограф', 
    'Робототехника', 'Предпринимательство'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Логика сохранения в Firestore
  Future<void> _handleSave() async {
  if (_firstNameController.text.isEmpty || _usernameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пожалуйста, заполните Имя и Username'), backgroundColor: Colors.red),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Пользователь не авторизован');

    final Map<String, dynamic> userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'dateOfBirth': _selectedDate?.toIso8601String(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'bio': _bioController.text.trim(),
      'skills': _selectedSkills,
      'achievements': _selectedAchievements,
      'goals': _selectedGoals,
      'interests': _selectedInterests,
      'certificates': _certificates,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // 1. Сохраняем в БД
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set(userData, SetOptions(merge: true));

    // 2. Проверяем, что виджет еще "жив" перед навигацией
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль успешно сохранен!'), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FeedScreen ()), // Замените FeedScreen на ваш следующий экран
        (route) => false, 
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // Метод выбора даты рождения
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF), // Ваш фирменный цвет
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Диалог добавления сертификата
  Future<void> _showAddCertificateDialog() async {
    final orgController = TextEditingController();
    final nameController = TextEditingController();
    final idController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Добавить сертификат', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField('Организация', orgController),
                const SizedBox(height: 12),
                _buildDialogTextField('Название сертификата', nameController),
                const SizedBox(height: 12),
                _buildDialogTextField('ID сертификата (необязательно)', idController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (orgController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  setState(() {
                    _certificates.add({
                      'organization': orgController.text.trim(),
                      'name': nameController.text.trim(),
                      'id': idController.text.trim(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // --- Базовая информация ---
                    _buildSectionTitle('Личная информация'),
                    _buildTextField('Имя', _firstNameController),
                    _buildTextField('Фамилия', _lastNameController),
                    _buildTextField('Username', _usernameController, prefix: '@'),
                    
                    // Выбор даты
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.transparent),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null 
                                  ? 'Дата рождения' 
                                  : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 16, 
                                color: _selectedDate == null ? const Color(0xFF6B7280) : Colors.black
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Color(0xFF007AFF)),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(child: _buildTextField('Страна', _countryController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Город', _cityController)),
                      ],
                    ),
                    _buildTextField('Немного о себе (Био)', _bioController, maxLines: 3),

                    const SizedBox(height: 20),

                    // --- Выбор тегов ---
                    _buildTagSection('Мои навыки', _availableSkills, _selectedSkills),
                    _buildTagSection('Достижения', _availableAchievements, _selectedAchievements),
                    _buildTagSection('Цели', _availableGoals, _selectedGoals),
                    _buildTagSection('Интересы', _availableInterests, _selectedInterests),

                    const SizedBox(height: 20),

                    // --- Сертификаты ---
                    _buildSectionTitle('Сертификаты'),
                    ..._certificates.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> cert = entry.value;
                      return _buildCertificateCard(cert, idx);
                    }),
                    
                    OutlinedButton.icon(
                      onPressed: _showAddCertificateDialog,
                      icon: const Icon(Icons.add, color: Color(0xFF007AFF)),
                      label: const Text('Добавить сертификат', style: TextStyle(color: Color(0xFF007AFF))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF007AFF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // --- Вспомогательные виджеты ---

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Создание профиля',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, String? prefix}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix != null ? '$prefix ' : null,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> availableTags, List<String> selectedTags) {
  // Объединяем стандартные теги и те, что пользователь ввел вручную (чтобы они отображались в списке)
  final allDisplayTags = {...availableTags, ...selectedTags}.toList();

  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...allDisplayTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedTags.remove(tag);
                    } else {
                      selectedTags.add(tag);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
                    ],
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),

            // Кнопка для добавления своего варианта
            GestureDetector(
              onTap: () => _showAddCustomTagDialog(title, selectedTags),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF007AFF), style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Color(0xFF007AFF)),
                    SizedBox(width: 4),
                    Text(
                      'Свой вариант',
                      style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildCertificateCard(Map<String, String> cert, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Color(0xFF007AFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(cert['organization']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                if (cert['id']!.isNotEmpty)
                  Text('ID: ${cert['id']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _certificates.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Сохранить и продолжить', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}