import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _waterAmountController = TextEditingController();
  final TextEditingController _waterIntervalController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _waterData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _waterAmountController.dispose();
    _waterIntervalController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return;
      }

      final data = await Supabase.instance.client
          .from('water')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .single()
          .maybeSingle();

      if (data != null) {
        setState(() {
          _waterData = data;
          _waterAmountController.text = _waterData!['water_amount_ml'].toString();
          _waterIntervalController.text = _waterData!['water_interval_hours'].toString();
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final dataToSave = {
        'water_amount_ml': int.parse(_waterAmountController.text),
        'water_interval_hours': int.parse(_waterIntervalController.text),
        'user_id': user.id,
      };

      await Supabase.instance.client.from('water').insert(dataToSave);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Water data saved successfully!')),
      );

      _waterAmountController.clear();
      _waterIntervalController.clear();

      // Refresh data after saving
      _fetchData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate back to the HomePage
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Water Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                _buildTextFormField(
                  controller: _waterAmountController,
                  label: "Water Amount (ml)",
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _waterIntervalController,
                  label: "Water Interval (hours)",
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                if (_waterData != null)
                  Text(
                    "Last updated: ${DateTime.parse(_waterData!['created_at']).toLocal().toString().split('.')[0]}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      keyboardType: TextInputType.number,
      validator: (val) => val == null || val.isEmpty ? "Please enter a value" : null,
    );
  }
}