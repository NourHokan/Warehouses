import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../theme/app_colors.dart';
import 'warehouses_list_screen.dart';

class GovernoratesScreen extends StatefulWidget {
  @override
  State<GovernoratesScreen> createState() => _GovernoratesScreenState();
}

class _GovernoratesScreenState extends State<GovernoratesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final governorates = dataProvider.governorates
        .where((g) => g.arabicName.contains(_searchQuery) || g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحافظات'),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'بحث عن محافظة',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: governorates.map((g) => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_city, color: AppColors.primaryGreen),
                  title: Text(g.arabicName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text(g.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WarehousesListScreen(
                          governorateId: g.id,
                        ),
                      ),
                    );
                  },
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

}
