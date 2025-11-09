import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../widgets/profile_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../address/address_model.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../address/address_list_screen.dart';
import '../address/add_edit_address_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final data = await ApiService.getUserInfo(widget.userId);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user info')));
    }
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settings = [
      {'icon': Icons.location_on, 'title': 'Manage Addresses'},
      {'icon': Icons.notifications, 'title': 'Notifications'},
      {'icon': Icons.security, 'title': 'Privacy & Security'},
      {'icon': Icons.help_outline, 'title': 'Help & Support'},
      {'icon': Icons.info_outline, 'title': 'About'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text("No user data found"))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.purple,
                    child: Text(
                      userData!['name'][0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData!['name'] ?? 'No Name',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          userData!['email'] ?? 'No Email',
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                                userData: userData!)),
                      );

                      if (updatedUser != null) {
                        setState(() => userData = updatedUser);
                      }
                    },
                    child: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Other Info
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow(Icons.phone, 'Mobile',
                      userData!['mobile'] ?? 'N/A'),
                  Divider(),
                  _infoRow(Icons.location_city, 'City',
                      userData!['city'] ?? 'N/A'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Settings List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: settings.length,
              itemBuilder: (context, index) {
                final item = settings[index];
                return ProfileItemCard(
                  icon: item['icon'],
                  title: item['title'],
                  onTap: () async {
                    if (item['title'] == 'Manage Addresses') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddressListScreen()),
                      );
                      fetchUserInfo(); // refresh after returning
                    } else if (item['title'] == 'Notifications') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Coming soon: Notifications settings')),
                      );
                    } else if (item['title'] ==
                        'Privacy & Security') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Coming soon: Privacy settings')),
                      );
                    } else if (item['title'] == 'Help & Support') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Help & Support section under development')),
                      );
                    } else if (item['title'] == 'About') {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Laundry Application',
                        applicationVersion: '1.0.0',
                        children: [
                          Text(
                              'This app helps manage laundry orders easily and efficiently.')
                        ],
                      );
                    }
                  },
                );
              },
            ),

            SizedBox(height: 20),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                final prefs =
                await SharedPreferences.getInstance();
                await prefs.remove('token');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LoginScreen()),
                      (route) => false,
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
