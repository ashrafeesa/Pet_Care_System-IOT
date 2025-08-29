import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todoapp/Pages/home_page.dart';

class PetProfilePage extends StatefulWidget {
  const PetProfilePage({super.key});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _supabase = Supabase.instance.client;
  final TextEditingController _nameController = TextEditingController();
  String _gender = 'Male';
  final TextEditingController _ageController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  Map<String, dynamic>? _petData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final filePath = 'pet_profile_photos/${user.id}.png';

      final uploadedPath = await _supabase.storage
          .from('pet-photos')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _supabase.storage
          .from('pet-photos')
          .getPublicUrl(uploadedPath);

      await _supabase.from('pet_profile').upsert({
        'user_id': user.id,
        'photo_url': publicUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully!')),
      );

      _fetchProfile();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading photo: $error')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return;
      }

      final data = await _supabase
          .from('pet_profile')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _petData = data;
          _nameController.text = _petData!['name'] ?? '';
          _gender = _petData!['gender'] ?? 'Male';
          _ageController.text = (_petData!['age'] ?? '').toString();
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching profile: $error')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }

      final petProfileData = {
        'user_id': user.id,
        'name': _nameController.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_ageController.text) ?? 0,
      };

      await _supabase.from('pet_profile').upsert(petProfileData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile saved successfully!')),
      );

      _fetchProfile();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $error')));
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
                  "Pet Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Container(
                        //   width: 120,
                        //   height: 120,
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey[200],
                        //     borderRadius: BorderRadius.circular(60),
                        //     border: Border.all(color: Colors.grey[400]!, width: 2),
                        //   ),
                        //   child: _petData?['photo_url'] != null
                        //       ? ClipRRect(
                        //           borderRadius: BorderRadius.circular(60),
                        //           child: Image.network(
                        //             _petData!['photo_url'],
                        //             width: 120,
                        //             height: 120,
                        //             fit: BoxFit.cover,
                        //             errorBuilder: (context, error, stackTrace) {
                        //               return const Icon(Icons.pets, size: 40, color: Colors.grey);
                        //             },
                        //           ),
                        //         )
                        //       : _imageFile != null
                        //           ? ClipRRect(
                        //               borderRadius: BorderRadius.circular(60),
                        //               child: Image.file(
                        //                 _imageFile!,
                        //                 width: 120,
                        //                 height: 120,
                        //                 fit: BoxFit.cover,
                        //               ),
                        //             )
                        //           : const Icon(Icons.pets, size: 60, color: Colors.grey),
                        // ),
                        // CircleAvatar(
                        //   radius: 20,
                        //   backgroundColor: Colors.black,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        //     onPressed: _pickImage,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                // Text(
                //   'Tap to add pet photo',
                //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 50),
                _buildTextFormField(
                  controller: _nameController,
                  label: "Pet Name",
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildDropdownButtonFormField(
                  label: "Gender",
                  value: _gender,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _gender = val;
                      });
                    }
                  },
                  items: const ['Male', 'Female'],
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _ageController,
                  label: "Age",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
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
                if (_petData != null)
                  Text(
                    "Last updated: ${DateTime.parse(_petData!['created_at']).toLocal().toString().split('.')[0]}",
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
    required TextInputType keyboardType,
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
      keyboardType: keyboardType,
      validator: (val) =>
          val == null || val.isEmpty ? "Please enter a value" : null,
    );
  }

  Widget _buildDropdownButtonFormField({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
