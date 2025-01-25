import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('School Safety')
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Navigate to home
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help desk'),
            onTap: () {
              // Navigate to help desk
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Navigate to profile
            },
          ),
        ],
      ),
    );
  }
}
