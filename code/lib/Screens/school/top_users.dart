import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/models/school_dashboard.dart';
import 'package:msb_app/models/user.dart';

class TopUsersWidget extends StatelessWidget {
  final List<TopStudent> topUsers;

  const TopUsersWidget({super.key, required this.topUsers});

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Second Top User (Left)
        Expanded(
          child: topUsers.length > 1
              ? UserCard(
                  user: topUsers[1],
                  rank: 2,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        // Top User (Center)
        SizedBox(
          width: query.width / 3.0,
          child: topUsers.isNotEmpty
              ? UserCard(
                  user: topUsers[0],
                  rank: 1,
                  isCenter: true,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        // Third Top User (Right)
        Expanded(
          child: topUsers.length > 2
              ? UserCard(
                  user: topUsers[2],
                  rank: 3,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

Widget _buildProfileImage(String? name, String? profileImageUrl) {
  if (profileImageUrl != null) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage(profileImageUrl),
    );
  } else {
    return Image.asset(
      "assets/images/profile.png",
      height: 40,
    );
  }
}

class UserCard extends StatelessWidget {
  final TopStudent user;
  final int rank;
  final bool isCenter;

  const UserCard({
    super.key,
    required this.user,
    required this.rank,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfileScreen(id: user.user!.id!.toString())));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF094F9A),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (user.user?.name != null && user.user?.imageUrl != null)
                  ? _buildProfileImage(user.user?.name, user.user?.imageUrl)
                  : Image.asset("assets/images/profile.png"),
              SizedBox(height: isCenter ? 15 : 10),
              Text(
                "$rank. ${user.user?.name ?? 'Unknown'}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isCenter ? 20 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                "(${user.gradeId ?? 'N/A'})",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (isCenter) // Only show points for the top user
                Text(
                  "Points: ${user.points ?? 0}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
