import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/kebaikan_input.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<AppProvider>(context, listen: false).profile;
      nameController.text = profile['user_name'] ?? '';
      emailController.text = profile['user_email'] ?? '';
      phoneController.text = profile['user_phone'] ?? '';
      setState(() {
        isDarkMode = profile['is_dark_mode'] ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AppProvider>(context).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Akun Tangan Kebaikan"),
        backgroundColor: const Color(0xFF11998e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF11998e),
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['user_name'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Aksi Kebaikan: ${profile['total_donation_count'] ?? 0} Kali",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            KebaikanInput(
              controller: nameController,
              label: "Ubah Nama",
              icon: Icons.edit,
            ),
            KebaikanInput(
              controller: emailController,
              label: "Ubah Email",
              icon: Icons.email,
            ),
            KebaikanInput(
              controller: phoneController,
              label: "Ubah Telepon",
              icon: Icons.phone,
            ),
            SwitchListTile(
              title: const Text("Mode Gelap (Dark Mode)"),
              value: isDarkMode,
              onChanged: (val) {
                setState(() => isDarkMode = val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).updateProfile(
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  isDarkMode,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profil Berhasil Diperbarui secara Lokal!"),
                  ),
                );
              },
              child: const Text(
                "Simpan Perubahan Akun",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
