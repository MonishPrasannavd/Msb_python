import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:msb_app/providers/master/master_provider.dart';

import '../../enums/post_filter.dart';
import '../../providers/master/master_provider.dart';

class FilterSelector extends StatelessWidget {
  final PostFilter? selectedFilter;
  final Function(PostFilter, {int? schoolId, int? gradeId, int? userId}) onFilterChange;

  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PostFilter>(
      onSelected: (PostFilter choice) async {
        if (choice == PostFilter.school) {
          int? selectedSchool = await _selectSchool(context);
          if (selectedSchool != null) {
            onFilterChange(PostFilter.school, schoolId: selectedSchool);
          }
        } else if (choice == PostFilter.grade) {
          int? selectedGrade = await _selectGrade(context);
          if (selectedGrade != null) {
            onFilterChange(PostFilter.grade, gradeId: selectedGrade);
          }
        } else if (choice == PostFilter.myPosts) {
          final userId = Provider.of<UserProvider>(context, listen: false).user.user!.id;
          onFilterChange(PostFilter.myPosts, userId: userId);
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
      case PostFilter.all:
        return "All Submissions";
      case PostFilter.myPosts:
        return "My Posts";
      case PostFilter.school:
        return "Filter by School";
      case PostFilter.grade:
        return "Filter by Grade";
      default:
        return "";
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
                onTap: () => Navigator.pop(context, school.id), // Ensure ID is an int
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
                onTap: () => Navigator.pop(context, grade.id), // Ensure ID is an int
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
