import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:msb_app/providers/master/master_provider.dart';

import '../../enums/post_filter.dart';
import '../../providers/master/master_provider.dart';

class FilterSelector extends StatelessWidget {
  final PostFilter? selectedFilter;
  final Function(PostFilter, {int? schoolId, int? gradeId}) onFilterChange;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PostFilter>(
      onSelected: (PostFilter choice) async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user.student;

        if (choice == PostFilter.myClass) {
          // Pass logged-in user's schoolId and gradeId
          onFilterChange(PostFilter.myClass, schoolId: user.schoolId, gradeId: user.gradeId);
        } else if (choice == PostFilter.mySchool) {
          // Pass only logged-in user's schoolId
          onFilterChange(PostFilter.mySchool, schoolId: user.schoolId);
        } else if (choice == PostFilter.otherSchools) {
          // Let user select a school and class
          int? selectedSchool = await _selectSchool(context);
          if (selectedSchool != null) {
            int? selectedGrade = await _selectGrade(context);
            if (selectedGrade != null) {
              onFilterChange(PostFilter.otherSchools, schoolId: selectedSchool, gradeId: selectedGrade);
            }
          }
        } else {
          onFilterChange(choice);
        }
      },
      itemBuilder: (BuildContext context) {
        return PostFilter.values.map((PostFilter choice) {
          return PopupMenuItem<PostFilter>(
            value: choice,
            child: Text(
              _getFilterText(choice),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList();
      },
      icon: Icon(Icons.filter_list, color: Colors.black54),
    );
  }

  String _getFilterText(PostFilter filter) {
    switch (filter) {
      case PostFilter.myClass:
        return "My Class";
      case PostFilter.mySchool:
        return "My School";
      case PostFilter.otherSchools:
        return "Other Schools";
      case PostFilter.all:
        return "All Submissions";
    }
  }

  Future<int?> _selectSchool(BuildContext context) async {
    final schools = Provider.of<MasterProvider>(context, listen: false).schools;
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select School"),
          content: schools.isEmpty
              ? Text("No schools available")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: schools.map((school) {
                    return ListTile(
                      title: Text(school.name!),
                      onTap: () => Navigator.pop(context, school.id),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Future<int?> _selectGrade(BuildContext context) async {
    final grades = Provider.of<MasterProvider>(context, listen: false).grades;
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Grade"),
          content: grades.isEmpty
              ? Text("No grades available")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: grades.map((grade) {
                    return ListTile(
                      title: Text(grade.name!),
                      onTap: () => Navigator.pop(context, grade.id),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
