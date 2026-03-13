import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector/models/event_model.dart';
import 'package:vector/pages/chatlist.dart';
import 'package:vector/pages/chatscreen.dart';
import 'package:vector/pages/mapscreen.dart';
import 'package:vector/pages/marketpade.dart';
import 'package:vector/pages/profile_view_page.dart';
import 'package:vector/pages/projectspage.dart';
import 'package:vector/services/eventsservice.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final EventService _eventService = EventService();
  int _currentIndex = 2; 
  String selectedLocation = "Все города";
  final List<String> locations = ["Все города", "Гомель", "Минск", "Брест", "Гродно", "Могилев", "Витебск"];

  @override
  Widget build(BuildContext context) {
    // 1. ОДИН метод build. Здесь мы определяем, какой экран показать.
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = const MarketScreen();
        break;
      case 1:
        currentScreen = ProjectsScreen();
        break;
      case 2:
       
        currentScreen = _buildEventsList();
        break;
      case 3:
        currentScreen = ChatsListScreen();
        break;
      case 4:
        currentScreen = const ProfileViewPage();
        break;
      default:
        currentScreen = _buildEventsList();
    }

    // 2. Возвращаем Scaffold с выбранным экраном
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentIndex == 2 ? _buildAppBar(context) : null,
      body: currentScreen,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- ЛЕНТА ФИЛЬТРОВ ---
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final city = locations[index];
          final isSelected = selectedLocation == city;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedLocation = city;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- ЛЕНТА СОБЫТИЙ С ФИЛЬТРОМ ---
  Widget _buildEventsList() {
    return Column(
      children: [
        _buildFilterChips(), // Добавляем полосу с городами
        Expanded(
          child: StreamBuilder<List<EventModel>>(
            stream: _eventService.getEvents(locationFilter: selectedLocation),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return const Center(
                  child: Text(
                    'Мероприятий не найдено',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                itemCount: events.length,
                itemBuilder: (context, index) => _buildEventCard(events[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- КАРТОЧКА СОБЫТИЯ ---
 Widget _buildEventCard(EventModel event) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 15,
          offset: const Offset(0, 5),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Изображение и тип мероприятия
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                event.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Контент карточки
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${DateFormat('dd MMM').format(event.date).toUpperCase()} • ${event.isOnline ? 'ОНЛАЙН' : event.location.toUpperCase()}",
                style: const TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Логика присоединения или перехода в чат
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Присоединиться',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // --- ВЕРХНЯЯ ПАНЕЛЬ ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: const Text(
                  'Лента',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FireMapScreen()),
                ),
                child: const Center(
                  child: Text(
                    'Карта',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- НИЖНЯЯ НАВИГАЦИЯ ---
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF007AFF),
      unselectedItemColor: const Color(0xFF9CA3AF),
      backgroundColor: Colors.white,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined), label: 'Маркет'),
        BottomNavigationBarItem(
            icon: Icon(Icons.layers_outlined), label: 'Проекты'),
        BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), label: 'Главная'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Общение'),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFFF3E5D0),
            child: Icon(Icons.person, size: 16, color: Colors.orange),
          ),
          label: 'Профиль',
        ),
      ],
    );
  }
}