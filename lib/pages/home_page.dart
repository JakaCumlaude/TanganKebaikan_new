import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/kebaikan_card.dart';
import '../widgets/kebaikan_input.dart';
import '../widgets/kebaikan_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // MEMICU AMBIL DATA DARI SQLITE SAAT HALAMAN DIBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchDonations();
    });
  }

  void _showDonationDialog(BuildContext context, String type) {
    final targetController = TextEditingController();
    final valController =
        TextEditingController(); // Jumlah uang atau Qty barang
    final nameController =
        TextEditingController(); // Nama barang (khusus BARANG)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Donasi ${type == 'UANG' ? 'Uang' : 'Barang'}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              KebaikanInput(
                controller: targetController,
                label: "Target Penyaluran (Misal: Panti Asuhan X)",
                icon: Icons.flag,
              ),
              if (type == 'BARANG')
                KebaikanInput(
                  controller: nameController,
                  label: "Nama Barang Logistics",
                  icon: Icons.inventory,
                ),
              KebaikanInput(
                controller: valController,
                label: type == 'UANG'
                    ? "Nominal Donasi (Rp)"
                    : "Jumlah/Kuantitas Barang",
                icon: type == 'UANG'
                    ? Icons.attach_money
                    : Icons.production_quantity_limits,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11998e),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  final provider = Provider.of<AppProvider>(
                    context,
                    listen: false,
                  );
                  provider.addDonation({
                    'type': type,
                    'target': targetController.text,
                    'amount': type == 'UANG'
                        ? double.tryParse(valController.text) ?? 0.0
                        : 0.0,
                    'itemQuantity': type == 'BARANG'
                        ? int.tryParse(valController.text) ?? 0
                        : 0,
                    'itemName': type == 'BARANG' ? nameController.text : '',
                    'date': DateTime.now().toString(),
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kirim Donasi",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: Column(
        children: [
          const KebaikanHeader(title: "Tangan Kebaikan"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                KebaikanCard(
                  title: "Donasi Uang Amanah",
                  subtitle:
                      "Salurkan bantuan finansial langsung cepat terverifikasi",
                  icon: Icons.account_balance_wallet,
                  onPressed: () => _showDonationDialog(context, 'UANG'),
                ),
                KebaikanCard(
                  title: "Donasi Barang & Logistik",
                  subtitle: "Kirim pakaian, makanan, perlengkapan medis",
                  icon: Icons.card_giftcard,
                  onPressed: () => _showDonationDialog(context, 'BARANG'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Donasi Terkini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.donations.isEmpty) {
                  return const Center(
                    child: Text("Belum ada riwayat transaksi kebaikan."),
                  );
                }
                return ListView.builder(
                  itemCount: provider.donations.length,
                  itemBuilder: (context, index) {
                    final item = provider.donations[index];
                    bool isUang = item['type'] == 'UANG';
                    return Dismissible(
                      key: Key(item['id'].toString()),
                      background: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) =>
                          provider.removeDonation(item['id']),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUang
                              ? Colors.green[100]
                              : Colors.orange[100],
                          child: Icon(
                            isUang ? Icons.money : Icons.widgets,
                            color: isUang ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(item['target']),
                        subtitle: Text(
                          isUang
                              ? currencyFormat.format(item['amount'])
                              : "${item['itemName']} (${item['itemQuantity']} pcs)",
                        ),
                        trailing: const Icon(Icons.arrow_left, size: 14),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
