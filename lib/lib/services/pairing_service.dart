import 'dart:math';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class PairingService {
  
  Future<String> generatePairingCode(String phoneNumber) async {
    try {
      // Generate random 6 digit code
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();
      
      // Simulasi API call ke server pairing
      await Future.delayed(const Duration(seconds: 1));
      
      // Validasi nomor
      if (!_validatePhoneNumber(phoneNumber)) {
        throw Exception('Nomor telepon tidak valid');
      }
      
      // Simpan ke localStorage atau database
      await _savePairingCode(phoneNumber, code);
      
      return code;
    } catch (e) {
      throw Exception('Gagal generate pairing code: $e');
    }
  }
  
  bool _validatePhoneNumber(String number) {
    // Hapus semua karakter non-digit
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Validasi panjang minimal 10 digit, maksimal 15 digit
    if (cleanNumber.length < 10 || cleanNumber.length > 15) {
      return false;
    }
    
    // Validasi diawali dengan 62 atau 08
    if (!cleanNumber.startsWith('62') && !cleanNumber.startsWith('08')) {
      return false;
    }
    
    return true;
  }
  
  Future<void> _savePairingCode(String phoneNumber, String code) async {
    // Simpan ke shared_preferences atau database lokal
    // Ini contoh simulasi
    print('Pairing code for $phoneNumber: $code');
  }
  
  Future<void> openWhatsApp(String phoneNumber) async {
    try {
      // Bersihkan nomor
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Buat WhatsApp link
      final whatsappLink = WhatsAppUnilink(
        phoneNumber: cleanNumber,
      );
      
      // Buka WhatsApp
      await whatsappLink.open();
    } catch (e) {
      throw Exception('Gagal membuka WhatsApp: $e');
    }
  }
  
  Future<bool> verifyPairingCode(String phoneNumber, String code) async {
    // Verifikasi kode pairing ke server
    // Ini contoh sederhana
    await Future.delayed(const Duration(seconds: 1));
    return code.length == 6 && int.tryParse(code) != null;
  }
}