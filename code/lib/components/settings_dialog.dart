import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                TextButton(
                  onPressed: () {
                    // Logout action
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.stars),
              title: const Text('Points'),
              trailing: const Text('554'),
              onTap: () {
                // Points action
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // Change password action
              },
            ),
            const SizedBox(height: 16),
            const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                // Edit profile action
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_num),
              title: const Text('Tickets'),
              onTap: () {
                // Tickets action
              },
            ),
          ],
        ),
      ),
    );
  }
}
