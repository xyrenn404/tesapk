import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pairing_service.dart';
import '../widgets/custom_button.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final PairingService _pairingService = PairingService();
  
  String _pairingCode = '';
  String _status = '';
  bool _isLoading = false;
  bool _isPaired = false;
  String _pairedNumber = '';

  @override
  void initState() {
    super.initState();
    _checkSavedPairing();
  }

  Future<void> _checkSavedPairing() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('paired_number');
    if (saved != null) {
      setState(() {
        _isPaired = true;
        _pairedNumber = saved;
      });
    }
  }

  Future<void> _generatePairingCode() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showSnackBar('Masukkan nomor telepon!', Colors.red);
      return;
    }

    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length < 10) {
      _showSnackBar('Nomor tidak valid! Minimal 10 digit', Colors.red);
      return;
    }

    if (!cleanNumber.startsWith('62') && !cleanNumber.startsWith('+')) {
      cleanNumber = '62$cleanNumber';
    }

    setState(() {
      _isLoading = true;
      _status = '🔐 Menghasilkan kode pairing...';
    });

    try {
      final code = await _pairingService.generatePairingCode(cleanNumber);
      
      setState(() {
        _pairingCode = code;
        _status = '✅ Kode pairing berhasil dibuat!';
        _isLoading = false;
      });

      await _savePairing(cleanNumber);
      
    } catch (e) {
      setState(() {
        _status = '❌ Gagal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePairing(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paired_number', number);
    setState(() {
      _isPaired = true;
      _pairedNumber = number;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('paired_number');
    setState(() {
      _isPaired = false;
      _pairedNumber = '';
      _pairingCode = '';
      _phoneController.clear();
      _status = '🔓 Berhasil logout';
    });
    _showSnackBar('Berhasil logout', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _pairingCode));
    _showSnackBar('Kode disalin!', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Pairing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isPaired)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header Icon
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaired ? Icons.check_circle : Icons.qr_code_scanner,
                      size: 60,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Status Card
                  if (_isPaired) ...[
                    _buildPairedCard(),
                  ] else ...[
                    _buildInputCard(),
                  ],

                  const SizedBox(height: 20),
                  
                  // Status Message
                  if (_status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _status.contains('✅') 
                            ? Colors.green.shade100 
                            : _status.contains('❌')
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _status.contains('✅') ? Icons.check_circle :
                            _status.contains('❌') ? Icons.error :
                            Icons.info,
                            color: _status.contains('✅') ? Colors.green :
                                   _status.contains('❌') ? Colors.red :
                                   Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _status,
                              style: TextStyle(
                                color: _status.contains('✅')
                                    ? Colors.green.shade900
                                    : _status.contains('❌')
                                        ? Colors.red.shade900
                                        : Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                  
                  // Info Card
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPairedCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            const Text(
              '✅ Sudah Terhubung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Nomor Terhubung',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _pairedNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Buka WhatsApp',
              icon: Icons.chat,
              color: Colors.green,
              onPressed: () => _pairingService.openWhatsApp(_pairedNumber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Tautkan Nomor WhatsApp',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Masukkan nomor WhatsApp yang ingin ditautkan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp',
                hintText: '6281234567890',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                helperText: 'Contoh: 6281234567890',
                helperStyle: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: 'Buat Kode Pairing',
              icon: Icons.qr_code,
              color: Colors.green,
              isLoading: _isLoading,
              onPressed: _generatePairingCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📌 Cara Penggunaan:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildInfoStep('1', 'Masukkan nomor WhatsApp Anda'),
            _buildInfoStep('2', 'Klik "Buat Kode Pairing"'),
            _buildInfoStep('3', 'Buka WhatsApp Web/Desktop'),
            _buildInfoStep('4', 'Masukkan kode pairing yang muncul'),
            const Divider(height: 20),
            const Text(
              '⚠️ Catatan Penting:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
            ),
            const SizedBox(height: 5),
            const Text(
              '• Pastikan nomor yang dimasukkan benar\n• Kode pairing berlaku 5 menit\n• WhatsApp harus terinstall di device',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}