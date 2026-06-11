import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/kebaikan_input.dart';
import '../widgets/signature_pad.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({Key? key}) : super(key: key);
  @override
  _VolunteerPageState createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final nameController = TextEditingController();
  final campaignController = TextEditingController();
  final phoneController = TextEditingController();
  bool hasSigned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrasi Relawan Aktivis"),
        backgroundColor: const Color(0xFF11998e),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            KebaikanInput(
              controller: nameController,
              label: "Nama Lengkap",
              icon: Icons.person,
            ),
            KebaikanInput(
              controller: campaignController,
              label: "Aksi Sosial yang Diikuti",
              icon: Icons.volunteer_activism,
            ),
            KebaikanInput(
              controller: phoneController,
              label: "Nomor WhatsApp",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SignaturePad(
              onDraw: (points) {
                hasSigned = points.isNotEmpty && points.contains(null);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF11998e),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                // <-- 1. Tambahkan kata 'async' disini
                if (nameController.text.isEmpty ||
                    campaignController.text.isEmpty ||
                    !hasSigned) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Harap isi formulir dan tanda tangan"),
                    ),
                  );
                  return;
                }

                final provider = Provider.of<AppProvider>(
                  context,
                  listen: false,
                );

                // 2. Tambahkan kata 'await' saat menyimpan data
                await provider.registerVolunteer({
                  'name': nameController.text,
                  'campaignName': campaignController.text,
                  'phoneNumber': phoneController.text,
                  'status': 'Aktif Terverifikasi',
                });

                // 3. Paksa aplikasi menarik data terbaru dari SQLite
                await provider.fetchVolunteers();

                nameController.clear();
                campaignController.clear();
                phoneController.clear();

                // Opsional: Jika kamu punya cara mereset SignaturePad, letakkan disini
                // hasSigned = false;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Berhasil Bergabung Menjadi Relawan!"),
                  ),
                );
              },
              child: const Text(
                "Daftar Sekarang",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Divider(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Relawan Terdaftar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.volunteers.length,
                  itemBuilder: (context, index) {
                    final vol = provider.volunteers[index];

                    // BUNGKUS DENGAN DISMISSIBLE AGAR BISA DI-DELETE DENGAN DIGESER
                    return Dismissible(
                      key: Key(vol['id'].toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection
                          .endToStart, // Geser ke kiri untuk hapus
                      onDismissed: (direction) {
                        // Panggil fungsi removeVolunteer yang baru kita buat
                        provider.removeVolunteer(vol['id']);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${vol['name']} dihapus dari relawan",
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: const Icon(
                          Icons.verified_user,
                          color: Colors.blue,
                        ),
                        // --- TAMBAHKAN BAGIAN INI ---
                        title: Text(vol['name']?.toString() ?? "Tanpa Nama"),
                        subtitle: Text(
                          vol['campaignName']?.toString() ?? "Tanpa Kampanye",
                        ),
                        trailing: Chip(
                          label: Text(vol['status']?.toString() ?? "-"),
                        ),
                        // ----------------------------
                        onTap: () {
                          debugPrint("Mencoba update ID: ${vol['id']}");
                          if (vol['id'] != null) {
                            provider.editVolunteer(vol['id'], {
                              'name': vol['name'],
                              'campaignName': vol['campaignName'],
                              'phoneNumber': vol['phoneNumber'],
                              'status': 'Terverifikasi 🚀',
                            });
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
