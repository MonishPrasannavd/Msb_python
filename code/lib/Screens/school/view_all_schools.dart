import 'package:flexible_text/flexible_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/school/school_detail.dart';
import 'package:msb_app/models/school.dart';
import 'package:msb_app/models/school_rank.dart';
import 'package:msb_app/providers/school/school_api_provider.dart';
import 'package:msb_app/utils/colours.dart';
import 'package:provider/provider.dart';

class ViewAllSchools extends StatefulWidget {
  const ViewAllSchools({super.key});

  @override
  State<ViewAllSchools> createState() => _ViewAllSchoolsState();
}

class _ViewAllSchoolsState extends State<ViewAllSchools> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  bool isSearching = false;
  String? lastSchoolId; // To track the last school ID for pagination

  late SchoolApiProvider _schoolApiProvider;
  final int limit = 10;
  late Future<Map<String, dynamic>> _fetchSchoolsFuture;

  @override
  void initState() {
    super.initState();

    _schoolApiProvider = Provider.of<SchoolApiProvider>(context, listen: false);
    _fetchSchoolsFuture = _schoolApiProvider.getAllSchools();
    // Add a scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading && !isSearching) {}
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchSchools(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      // if (isSearching) {
      //   schools = allSchools
      //       .where((school) => (school.schoolName ?? '').toLowerCase().contains(query.toLowerCase()))
      //       .toList();
      // } else {
      //
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Consumer<SchoolApiProvider>(
        builder: (context, schoolApiProvider, child) {
          return FutureBuilder(
            future: _fetchSchoolsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data?['schools'] == null) {
                return const Center(child: Text('No schools available'));
              }

              List<School> schools = snapshot.data?['schools'] != null
                  ? snapshot.data!['schools'] as List<School>
                  : [];
              schools.sort((a, b) => (b.points ?? 0).compareTo(a.points ?? 0));
              return Column(
                children: [
                  Container(
                    height: query.height / 6,
                    width: query.width,
                    decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25.0),
                            bottomLeft: Radius.circular(25.0))),
                    child: Center(
                      child: SafeArea(
                        child: Text(
                          "All Schools",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                      ),
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
                  const Divider(
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                        controller: _scrollController,
                        itemCount: schools.length,
                        itemBuilder: (context, index) {
                          final school = schools[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SchoolDetailPage(
                                    schoolId: school.id!.toString(),
                                    schoolRank: SchoolRank(
                                      id: school.id,
                                      name: school.name,
                                      rank: school.rank,
                                      createdBy: school.createdBy,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: AppColors.white,
                              child: ListTile(
                                title: Text(
                                  school.name ?? 'Unknown School',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: FlexibleText(
                                  text: '#Students:# ${school.studentCount}',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  richStyles: [
                                    GoogleFonts.poppins(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
