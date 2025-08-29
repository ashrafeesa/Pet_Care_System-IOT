import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todoapp/Pages/home_page.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  Object? get dataToSave => null;

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mealsController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final TextEditingController _gapController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _firstMealTimeController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _foodData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _mealsController.dispose();
    _portionController.dispose();
    _waterController.dispose();
    _firstMealTimeController.dispose();
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
          .from('food')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .single()
          .maybeSingle();

      if (data != null) {
        setState(() {
          _foodData = data;
          _mealsController.text = _foodData!['meals_count'].toString();
          _portionController.text = _foodData!['portion_size_grams'].toString();
          _waterController.text = _foodData!['water_level'].toString();
          _firstMealTimeController.text = _foodData!['first_meal_time'] ?? '';
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $error')));
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
        'meals_count': int.parse(_mealsController.text),
        'portion_size_grams': int.parse(_portionController.text),
        'water_level': int.parse(_waterController.text),
        'first_meal_time': _firstMealTimeController.text,
        'user_id': user.id,
      };

      await Supabase.instance.client.from('food').insert(dataToSave);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food data saved successfully!')),
      );

      _mealsController.clear();
      _portionController.clear();
      _gapController.clear();
      _waterController.clear();
      _firstMealTimeController.clear();

      // Refresh data after saving
      _fetchData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
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
                  "Food Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                _buildTextFormField(
                  controller: _mealsController,
                  label: "Number of meals",
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _portionController,
                  label: "Portion size (grams)",
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _waterController,
                  label: "Water (level)",
                ),
                const SizedBox(height: 20),
                _buildTimeFormField(
                  controller: _firstMealTimeController,
                  label: "First meal time (HH:MM:SS)",
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
                if (_foodData != null)
                  Text(
                    "Last updated: ${DateTime.parse(_foodData!['created_at']).toLocal().toString().split('.')[0]}",
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (val) =>
          val == null || val.isEmpty ? "Please enter a value" : null,
    );
  }

  Widget _buildTimeFormField({
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      keyboardType: TextInputType.datetime,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Please enter a time";
        }
        // Basic validation for HH:MM:SS format
        final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$');
        if (!timeRegex.hasMatch(val)) {
          return "Please enter time in HH:MM:SS format (e.g., 08:30:00)";
        }
        return null;
      },
    );
  }
}
