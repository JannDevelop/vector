import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector/pages/qr_scanner.dart';
import 'package:vector/services/dobavlenie_tovara.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'Все';
  // Убедитесь, что названия категорий здесь точно совпадают с теми, что в Firebase
  final List<String> _categories = ['Все', 'Техника', 'Еда', 'Обучение'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'Маркет',
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner_rounded, // Изменили иконку
                color: Color(0xFF111827),
                size: 22,
              ),
              onPressed: () {
                // Открываем экран сканирования по нажатию
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildPromotionalBanners(),
              const SizedBox(height: 10),
              _buildBalanceCard(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildFirestoreRewards(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  

  // --- Выбор категорий ---
  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isActive = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? Color(0xFF007AFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Color(0xFF007AFF).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat[0].toUpperCase() + cat.substring(1),
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildPromotionalBanners() {
  return StreamBuilder<QuerySnapshot>(
    // Слушаем коллекцию banners, сортируем по дате создания (самые новые — первыми)
    stream: FirebaseFirestore.instance
        .collection('banners')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        // Если баннеров в базе нет, ничего не показываем
        return const SizedBox.shrink();
      }

      final banners = snapshot.data!.docs;

      return SizedBox(
        height: 170, // Высота блока с баннерами
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9), // Видны края соседних баннеров
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final data = banners[index].data() as Map<String, dynamic>;
            final String imageUrl = data['imageUrl'] ?? '';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // Заглушка пока картинка грузится
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  // Если ссылка битая
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

  Widget _buildFirestoreRewards() {
    // 1. Сначала создаем базовый запрос
    Query query = FirebaseFirestore.instance.collection('market');

    // 2. Если выбрана категория, добавляем фильтр
    if (_selectedCategory != 'Все') {
      query = query.where('category', isEqualTo: _selectedCategory);
      // ВАЖНО: Если есть where и orderBy по разным полям, нужен индекс!
      query = query.orderBy('name', descending: false);
    } else {
      // Если категории нет, просто сортируем
      query = query.orderBy('name', descending: false);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        // Обработка ошибки индексов (ты ее уже начал писать)
        if (snapshot.hasError) {
          print(
            "DEBUG FIRESTORE ERROR: ${snapshot.error}",
          ); // Загляни сюда в консоль!
          return Center(child: Text('Ошибка загрузки данных'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('Пусто'));
        }

        return GridView.builder(
          // Оставляем твои настройки
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            // Передаем ID документа, если он понадобится для покупки
            data['id'] = docs[index].id;
            return _buildProductCard(data);
          },
        );
      },
    );
  }

  // --- Карточка товара ---
  Widget _buildProductCard(Map<String, dynamic> product) {
    final String name = product['name'] ?? 'Без названия';
    final String price = product['price']?.toString() ?? '0';
    final String imageUrl = product['image'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Colors.black12,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$price P',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    // Находим этот блок в вашем методе _buildProductCard
                    InkWell(
                      onTap: () {
                        // Вызываем диалог подтверждения
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            // Используем dialogContext для ясности
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Подтверждение'),
                            content: Text('Купить "$name" за $price поинтов?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  'Отмена',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);

                                  await MarketService.purchaseProduct(
                                    context,
                                    product,
                                  );
                                },
                                child: const Text(
                                  'Купить',
                                  style: TextStyle(
                                    color: Color(0xFF007AFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 24,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _balanceContent(0);

    return StreamBuilder<DocumentSnapshot>(
      // Слушаем изменения в документе текущего пользователя
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        int points = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          points = data['balance'] ?? 0;
        }

        return _balanceContent(points);
      },
    );
  }

  Widget _balanceContent(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$points',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            'Доступные Поинты',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
