import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/models/student.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/school/school_api_provider.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:provider/provider.dart';

class ViewAllUsersInSchool extends StatefulWidget {
  final String schoolId;

  const ViewAllUsersInSchool({super.key, required this.schoolId});

  @override
  State<ViewAllUsersInSchool> createState() => _ViewAllUsersInSchoolState();
}

class _ViewAllUsersInSchoolState extends State<ViewAllUsersInSchool> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Student> users = [];
  List<Student> allUsers = []; // Master list to store all fetched users
  bool isLoading = false;
  bool isSearching = false;
  int? lastUserId; // To track the last user ID for pagination

  int limit = 10;
  int page = 1;
  int total = 0;
  int totalPage = 1;
  late SchoolApiProvider _schoolApiProvider;

  @override
  void initState() {
    super.initState();
    // Add a scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!isLoading && !isSearching) {
          _fetchUsers();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _schoolApiProvider = Provider.of<SchoolApiProvider>(context, listen: false);

      _fetchUsers();
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
      Map<String, dynamic> response = await _schoolApiProvider.getStudentsBySchoolId(int.parse(widget.schoolId), limit: limit, page: page);

      if(response['students'] != null) {
        var fetchedUsers = response['students'] as List<Student>;
        var fetchedPage = response['page'];
        var fetchedLimit = response['limit'];
        var fetchedTotal = response['total'];
        var fetchedTotalPages = response['total_pages'];
        setState(() {
          allUsers.addAll(fetchedUsers); // Update the master list
          users = List.from(allUsers); // Refresh the display list
          page = page > totalPage ? totalPage : fetchedPage++;
          limit = fetchedLimit;
          total = fetchedTotal;
          totalPage = fetchedTotalPages;

          if (fetchedUsers.isNotEmpty) {
            lastUserId = fetchedUsers.last.user!.id!; // Update the last user ID
          }

          if (page > totalPage) {
            page = totalPage; // Prevent exceeding the max pages
          }
        });
      }

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
            .where((user) => (user.user!.name ?? '').toLowerCase().contains(query.toLowerCase()))
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
      body: Consumer<SchoolApiProvider>(builder: (ctx, schoolApiProvider, child) {
        return Column(
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
                      backgroundImage: user.user!.image != null
                          ? NetworkImage(user.user!.image)
                          : null,
                      child: user.user!.image == null
                          ? Text(
                        user.user!.image?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.poppins(color: Colors.white),
                      )
                          : null,
                    ),
                    title: Text(user.user!.name ?? 'Unknown User'),
                    subtitle: Text(user.user!.email ?? 'No email available'),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
