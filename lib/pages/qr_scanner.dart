import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vector/services/qr_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanning = true;
  final QRService _qrService = QRService(); // Инициализируем сервис

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканировать QR-код'), automaticallyImplyLeading: false, titleTextStyle: TextStyle(
        fontSize: 22,
        color: Color(0xFF111827),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      )),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!isScanning) return;
              final barcode = capture.barcodes.first;
              if (barcode.rawValue != null) {
                setState(() => isScanning = false);
                _handleCodeScanned(barcode.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCodeScanned(String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF))),
    );

    try {
      // Вызываем нашу бизнес-логику из сервиса
      await _qrService.redeemQRCode(code);

      if (!mounted) return;
      Navigator.pop(context); // Убираем лоадер

      _showResultSheet(true, "Баллы успешно начислены!");
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Убираем лоадер

      _showResultSheet(false, e.toString());
    }
  }

  void _showResultSheet(bool isSuccess, String message) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Делаем фон прозрачным для кастомного скругления
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          
          // Иконка
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: isSuccess ? const Color(0xFF007AFF) : Colors.redAccent,
            size: 64,
          ),
          const SizedBox(height: 16),
          
          // Текст сообщения
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 32),
          
          // Кнопка в стиле iOS
          SizedBox(
            width: double.infinity,
            height: 56, 
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                if (isSuccess) {
                  Navigator.pop(context); 
                } else {
                  setState(() => isScanning = true); 
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF), 
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              child: Text(isSuccess ? "Отлично" : "Попробовать снова"),
            ),
          ),
        ],
      ),
    ),
  );
}
}