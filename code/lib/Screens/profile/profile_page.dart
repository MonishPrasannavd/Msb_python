import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/components/text_builder.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/providers/master/master_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/repository/comment_repository.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/user_repository.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/utils/auth.dart';
import 'package:msb_app/utils/firestore_collections.dart';
import 'package:msb_app/utils/user.dart';
import 'package:provider/provider.dart';
import '../../components/button_builder.dart';
import '../../utils/colours.dart';
import 'package:msb_app/services/preferences_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({required this.onLogout, super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool isUploadingImage = false;
  String? userId;
  bool isEditing = false;
  String grade = "Grade 3";
  String schoolName = "Delhi Public School, Hyderabad";
  MsbUser? user;
  String? selectedSchoolId;
  List<SchoolUser> schools = [];
  TextEditingController gradeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final PostFeedRepository postRepository = PostFeedRepository();
  final CommentRepository commentRepository =
      CommentRepository(commentCollection: FirebaseFirestore.instance.collection(FirestoreCollections.comments));
  String likesCount = "0";
  String commentsCount = "0";
  String totalPoints = "0";
  Grade? selectedGrade;
  final UserRepository userRepository = UserRepository(
    usersCollection: FirebaseFirestore.instance.collection('users'),
  );

  final ImagePicker _picker = ImagePicker();
  late Future<void> _initProfile;

  late UserProvider _userProvider;
  late UserAuthProvider _authProvider;
  late MasterProvider _masterProvider;

  @override
  void initState() {
    super.initState();
    _initProfile = loadUserProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _authProvider = Provider.of<UserAuthProvider>(context, listen: false);
      _masterProvider = Provider.of<MasterProvider>(context, listen: false);
      print('user :: ${_userProvider.user.user?.email}');

      setState(() {
        nameController.text = _userProvider.user.user?.name ?? "";
        Grade? gradeResolve;
        if (_userProvider.user.student.grade?.name != null &&
            _userProvider.user.student.grade?.name?.isNotEmpty != null) {
          gradeResolve = _userProvider.user.student.grade!;
        } else {
          gradeResolve =
              _masterProvider.grades.firstWhere((grade) => grade.id == _userProvider.user.student.gradeId);
        }

        setState(() {
          gradeController.text = gradeResolve?.name ?? "";
          grade = gradeResolve?.name ?? "";
          selectedGrade = gradeResolve;
          schoolName = _userProvider.user.student.school?.name ?? "";
          likesCount = _userProvider.user.student.likes.toString();
          totalPoints = _userProvider.user.student.score.toString();
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUserId(); // Ensures user data is reloaded when dependencies change.
  }

  void loadUserId() async {
    var fetchedUserId = await PrefsService.getUserId();
    if (mounted) {
      setState(() {
        userId = fetchedUserId;
      });
      if (fetchedUserId != null) {
        await loadUserProfile(); // Load the profile when the user ID is available
      }
    }
  }

  Future<void> loadUserProfile() async {
    if (userId != null) {
      MsbUser? retrievedUser = await userRepository.getOne(userId!);
      var posts = await postRepository.getPostsByUserId(userId!);
      var postids = posts.map((p) => p.id).where((id) => id != null).cast<String>().toList();
      var comments = await commentRepository.getCommentsByPostIds(postids);
      if (retrievedUser != null) {
        setState(() {
          // grade = retrievedUser.grade ?? grade;
          // schoolName = retrievedUser.schoolName ?? schoolName;
          // nameController.text = retrievedUser.name ?? ''; // Set empty if no name
          // user = retrievedUser;
          //
          // likesCount = (retrievedUser.totalLikePoints ?? 0).toString();
          // commentsCount = comments.length.toString();
          // totalPoints = retrievedUser.totalPoints.toString();
        });
      }
    }
  }

  Future<void> fetchSchools() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('school_users').get();
      List<SchoolUser> fetchedSchools =
          snapshot.docs.map((doc) => SchoolUser.fromJson(doc.data() as Map<String, dynamic>)).toList();
      setState(() {
        schools = fetchedSchools;
      });
    } catch (e) {
      print("Error fetching schools: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _handleProfileImageUpdate();
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    if (userId == null) {
      print('User ID not available');
      return null;
    }

    try {
      setState(() {
        isUploadingImage = true;
      });

      String fileName = imageFile.path.split('/').last;
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("$userId/profile_images/$fileName");

      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    } finally {
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfileImageUrl(String imageUrl) async {
    try {
      if (userId != null) {
        MsbUser? user = await userRepository.getOne(userId!);

        if (user != null) {
          MsbUser updatedUser = user.copyWith(
            profileImageUrl: imageUrl,
            grade: gradeController.text.isNotEmpty ? gradeController.text : grade,
            schoolName: selectedSchoolId != null
                ? schools.firstWhere((school) => school.id == selectedSchoolId).schoolName
                : schoolName,
            schoolId: selectedSchoolId,
            name: nameController.text.isNotEmpty ? nameController.text : "*** Add name",
          );
          await userRepository.updateOne(updatedUser);
        } else {
          MsbUser newUser = MsbUser(
            id: userId,
            profileImageUrl: imageUrl,
            grade: gradeController.text.isNotEmpty ? gradeController.text : grade,
            schoolName: selectedSchoolId != null
                ? schools.firstWhere((school) => school.id == selectedSchoolId).schoolName
                : schoolName,
            schoolId: selectedSchoolId,
            name: nameController.text.isNotEmpty ? nameController.text : "*** Add name",
          );
          await userRepository.saveOne(newUser);
        }
      }
    } catch (e) {
      print("Error saving profile image URL: $e");
    } finally {
      loadUserProfile();
    }
  }

  Future<void> _saveProfileDetails() async {
    try {
      await _authProvider.updateProfile(nameController.text, selectedGrade?.id ?? _userProvider.user.student.gradeId);
      // if (userId != null) {
      //   MsbUser? user = await userRepository.getOne(userId!);
      //
      //   if (user != null) {
      //     MsbUser updatedUser = user.copyWith(
      //       grade: gradeController.text.isNotEmpty ? gradeController.text : grade,
      //       schoolName: selectedSchoolId != null
      //           ? schools.firstWhere((school) => school.id == selectedSchoolId).schoolName
      //           : schoolName,
      //       schoolId: selectedSchoolId,
      //       name: nameController.text.isNotEmpty ? nameController.text : null,
      //     );
      //     await userRepository.updateOne(updatedUser);
      //   } else {
      //     MsbUser newUser = MsbUser(
      //       id: userId,
      //       grade: gradeController.text.isNotEmpty ? gradeController.text : grade,
      //       schoolName: selectedSchoolId != null
      //           ? schools.firstWhere((school) => school.id == selectedSchoolId).schoolName
      //           : schoolName,
      //       schoolId: selectedSchoolId,
      //       name: nameController.text.isNotEmpty ? nameController.text : null,
      //     );
      //     await userRepository.saveOne(newUser);
      //   }
      // }
    } catch (e) {
      print("Error saving profile details: $e");
    }
  }

  Future<void> _handleProfileImageUpdate() async {
    if (_profileImage != null) {
      String? imageUrl = await _uploadImage(_profileImage!);
      if (imageUrl != null) {
        await _saveProfileImageUrl(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? GestureDetector(
                child: const Icon(Icons.arrow_back),
                onTap: () => Navigator.pop(context),
              )
            : null, // If there's no history, do not show the back button
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
      body: FutureBuilder<void>(
          future: _initProfile, // Reference the _initProfile Future
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show progress indicator while the Future is running
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle errors
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return mainUi();
          }),
    );
  }

  Widget mainUi() {
    var query = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Stack(
        children: [
          Image.asset("assets/images/profile_frame.png"),
          Column(
            children: [
              SizedBox(height: query.height * 0.15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Container(
                  // height: isEditing ? query.height * 1 : query.height * 1,
                  // width: query.width,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: isUploadingImage
                            ? const CircularProgressIndicator()
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!) // Use the newly picked image if available
                                    : user?.profileImageUrl != null // Check if a profile image URL exists
                                        ? CachedNetworkImageProvider(user!.profileImageUrl!) // Load from URL
                                        : const AssetImage("assets/images/profile1.png") // Fallback to local asset
                                            as ImageProvider, // Explicitly cast to ImageProvider
                              ),
                      ),
                      const SizedBox(height: 10),
                      isUploadingImage
                          ? const Text(
                              "Uploading...",
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              "Tap to change",
                              style: GoogleFonts.poppins(
                                  color: AppColors.white, fontWeight: FontWeight.w300, fontSize: 14),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isEditing
                              ? Flexible(child: _buildEditableField("Name", nameController))
                              : Text(
                                  fetchFirstName(_userProvider.user.user?.name) ?? "*** Add name",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 32),
                                ),
                          // _buildEditToggle(),
                        ],
                      ),

                      /// grade
                      isEditing
                          ? _buildGradeDropdown()
                          : Text(
                              grade,
                              style: GoogleFonts.poppins(
                                  color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
                            ),

                      /// school name
                      /// Non-editable school name
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            schoolName,
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(likesCount, "Likes", "unLike.svg"),
                            // _buildStatCard(user?.follower.length.toString() ?? "0", "Followers", "users.svg"),
                            _buildStatCard(commentsCount, "Comments", "comment.svg"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// stars card
                      _buildStarsCard(context),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: LayoutBuilder(
                          builder: (ctxt, constraints) {
                            // Calculate button width
                            final buttonWidth = constraints.maxWidth / 2 - 5; // Adjust for padding

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// edit details button
                                    SizedBox(
                                      width: buttonWidth,
                                      height: 50,
                                      child: ButtonBuilder(
                                        text: isEditing ? 'Save Details' : 'Edit Details',
                                        onPressed: () {
                                          if (isEditing) {
                                            _saveProfileDetails();
                                          } else {
                                            fetchSchools();
                                          }
                                          setState(() {
                                            isEditing = !isEditing;
                                            if (isEditing) {
                                              gradeController.text = grade;
                                            }
                                          });
                                        },
                                        style: ButtonStyle(
                                          side: MaterialStateProperty.all(
                                            const BorderSide(color: Color(0xFFE1C7FA), width: 1),
                                          ),
                                          backgroundColor: MaterialStateProperty.all(
                                            const Color(0xFF6911BB),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: buttonWidth,
                                      height: 50,
                                      child: ButtonBuilder(
                                        text: 'Logout',
                                        onPressed: widget.onLogout,
                                        style: ButtonStyle(
                                          side: MaterialStateProperty.all(
                                            const BorderSide(color: Color(0xFFE1C7FA), width: 1),
                                          ),
                                          backgroundColor: MaterialStateProperty.all(
                                            const Color(0xFF6911BB),
                                          ),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: constraints.maxWidth, // Full width of the Row
                                  height: 50,
                                  child: ButtonBuilder(
                                    text: 'My entries',
                                    onPressed: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                          builder: (context) => UserProfileScreen(id: userId!),
                                        ))
                                        .then((val) async => await loadUserProfile()),
                                    style: ButtonStyle(
                                      side: MaterialStateProperty.all(
                                        const BorderSide(color: Color(0xFFE1C7FA), width: 1),
                                      ),
                                      backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFF6911BB),
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    textStyle: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGradeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownSearch<Grade>(
        compareFn: (item1, item2) => item1 == item2,
        itemAsString: (item) => item.name!,
        items: (f, cs) => _masterProvider.grades,
        selectedItem: selectedGrade,
        onChanged: (Grade? newGrade) {
          setState(() {
            if (newGrade != null) {
              grade = newGrade.name!;
            }
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Grade is required';
          }
          return null;
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: "Search Grade",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
        decoratorProps: const DropDownDecoratorProps(
          baseStyle: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Select Grade',
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: '*** Add name',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
        style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  Widget _buildStarsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        // width: double.infinity,
        // margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: AppColors.msbMain100,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const TextBuilder(
                text: 'Your Stars',
                style: TextStyle(fontSize: 20.0, color: AppColors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextBuilder(
                text: totalPoints,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.msbNeutral400),
              ),
              const SizedBox(height: 16.0),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Image.asset('assets/images/star.png')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AbsorbPointer(
        absorbing: selectedSchoolId != null,
        child: DropdownButton<String>(
          value: selectedSchoolId,
          dropdownColor: AppColors.primary,
          hint: Text(
            'Select School',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              selectedSchoolId = newValue;
            });
          },
          items: schools.map((SchoolUser school) {
            return DropdownMenuItem<String>(
              value: school.schoolId,
              child: Text(
                school.schoolName!,
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEditToggle() {
    return IconButton(
      icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
      onPressed: () {
        setState(() {
          if (!isEditing) {
            fetchSchools();
          }
          isEditing = !isEditing;
          if (isEditing) {
            gradeController.text = grade;
          }
        });
      },
    );
  }

  Widget _buildStatCard(String value, String label, String iconPath) {
    return Container(
      height: 100,
      width: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF3F0A70),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/svg/$iconPath",
            color: AppColors.white,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
