import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart'; // Пакет Яндекса
import 'package:geolocator/geolocator.dart';

class FireMapScreen extends StatefulWidget {
  const FireMapScreen({super.key});

  @override
  State<FireMapScreen> createState() => _FireMapScreenState();
}

class _FireMapScreenState extends State<FireMapScreen> {
  late YandexMapController _controller;
  Point? _initialPosition;
  List<MapObject> _mapObjects = []; // Список объектов на карте (маркеры)

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = Point(latitude: position.latitude, longitude: position.longitude);
    });
  }

  // Метод создания маркеров из данных Firestore
  List<MapObject> _buildMarkers(List<DocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint pos = data['position'];

      return PlacemarkMapObject(
        mapId: MapObjectId('marker_${doc.id}'),
        point: Point(latitude: pos.latitude, longitude: pos.longitude),
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            // В Яндексе сложнее сделать кастомный виджет-маркер, 
            // обычно используется ассет (иконка)
            image: BitmapDescriptor.fromAssetImage('assets/event_icon.png'), 
            scale: 1.5,
          ),
        ),
        onTap: (object, point) => _onMarkerTap(data),
      );
    }).toList();
  }

  void _onMarkerTap(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Событие: ${data['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Яндекс.Карта
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('mapevents').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _mapObjects = _buildMarkers(snapshot.data!.docs);
              }

              return YandexMap(
                mapObjects: _mapObjects,
                onMapCreated: (controller) async {
                  _controller = controller;
                  // Перемещаем камеру на текущую позицию
                  await _controller.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: _initialPosition!, zoom: 14),
                    ),
                  );
                },
              );
            },
          ),
          
          _buildStaticUI(),
        ],
      ),
    );
  }

  Widget _buildStaticUI() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: FloatingActionButton(
        onPressed: () async {
          // Пример: кнопка "Где я"
          if (_initialPosition != null) {
            await _controller.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: _initialPosition!, zoom: 16),
              ),
              animation: const MapAnimation(type: MapAnimationType.smooth),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}