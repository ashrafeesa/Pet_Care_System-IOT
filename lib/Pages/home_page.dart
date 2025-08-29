import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'food_page.dart';
import 'pet_profile_page.dart';
import 'user_profile_page.dart';
import 'welcome_page.dart';

// The HomePage should not be a MaterialApp, it should be a Scaffold
// as MaterialApp should be the root of the app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  // A list of widgets to display in the body
  final List<Widget> _pages = [
    const HomeDashboard(), // A new dashboard widget for the home tab
    const PetProfilePage(),
    const UserProfilePage(),
    const FoodPage(),
  ];

  // A list of titles for the AppBar
  final List<String> _pageTitles = [
    "Dashboard",
    "Pet Profile",
    "User Profile",
    "Food Page"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to sign out.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Pet Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'User Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Food',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}

// A new widget for the Home Dashboard content
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pet Care Dashboard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: 160,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/tcat.png', // Change to your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.pets,
                  label: "Pet Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PetProfilePage()),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.person,
                  label: "User Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserProfilePage()),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.restaurant,
                  label: "Food",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoodPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
