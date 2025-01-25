import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/school/school_detail.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/utils/colours.dart';

class ViewAllSchools extends StatefulWidget {
  const ViewAllSchools({super.key});

  @override
  State<ViewAllSchools> createState() => _ViewAllSchoolsState();
}

class _ViewAllSchoolsState extends State<ViewAllSchools> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SchoolUserRepository schoolUserRepository = SchoolUserRepository();

  List<SchoolUser> schools = [];
  List<SchoolUser> allSchools = []; // Master list to store all fetched schools
  bool isLoading = false;
  bool isSearching = false;
  String? lastSchoolId; // To track the last school ID for pagination

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchSchools();

    // Add a scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!isLoading && !isSearching) {
          _fetchSchools();
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

  Future<void> _fetchSchools() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<SchoolUser> fetchedSchools =
      await schoolUserRepository.getRecentlyJoinedSchoolsPaginated(
        limit: limit,
        lastDocumentId: lastSchoolId,
      );

      setState(() {
        allSchools.addAll(fetchedSchools); // Update the master list
        schools = List.from(allSchools); // Refresh the display list
        if (fetchedSchools.isNotEmpty) {
          lastSchoolId = fetchedSchools.last.id; // Update the last school ID
        }
      });
    } catch (e) {
      print('Error fetching schools: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchSchools(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (isSearching) {
        schools = allSchools
            .where((school) =>
            (school.schoolName ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        schools = List.from(allSchools); // Reset to the full list when search is cleared
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
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(25.0), bottomLeft: Radius.circular(25.0))),
            child: Column(
              children: [
                SafeArea(
                  child: Text(
                    "View All Schools",
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
                labelText: 'Search Schools',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchSchools,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: schools.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == schools.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final school = schools[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchoolDetailPage(
                          schoolId: school.schoolId!,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(school.schoolName ?? 'Unknown School'),
                    subtitle: Text('Students: ${school.studentCount}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

