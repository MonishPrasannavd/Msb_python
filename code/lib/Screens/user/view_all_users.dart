import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/colours.dart';

class ViewAllUsersInSchool extends StatefulWidget {
  final String schoolId;

  const ViewAllUsersInSchool({super.key, required this.schoolId});

  @override
  State<ViewAllUsersInSchool> createState() => _ViewAllUsersInSchoolState();
}

class _ViewAllUsersInSchoolState extends State<ViewAllUsersInSchool> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final UserRepository userRepository = UserRepository(usersCollection: FirebaseFirestore.instance.collection('users'));

  List<MsbUser> users = [];
  List<MsbUser> allUsers = []; // Master list to store all fetched users
  bool isLoading = false;
  bool isSearching = false;
  String? lastUserId; // To track the last user ID for pagination

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsers();

    // Add a scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!isLoading && !isSearching) {
          _fetchUsers();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<MsbUser> fetchedUsers = await userRepository.getUsersBySchoolId(widget.schoolId, limit: limit, lastDocumentId: lastUserId);

      setState(() {
        allUsers.addAll(fetchedUsers); // Update the master list
        users = List.from(allUsers); // Refresh the display list
        if (fetchedUsers.isNotEmpty) {
          lastUserId = fetchedUsers.last.id; // Update the last user ID
        }
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchUsers(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (isSearching) {
        users = allUsers
            .where((user) => (user.name ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        users = List.from(allUsers); // Reset to the full list when search is cleared
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: query.height / 6,
            width: query.width,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25.0),
                bottomLeft: Radius.circular(25.0),
              ),
            ),
            child: Column(
              children: [
                SafeArea(
                  child: Text(
                    "View All Users",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: users.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(
                      user.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: GoogleFonts.poppins(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(user.name ?? 'Unknown User'),
                  subtitle: Text(user.email ?? 'No email available'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
