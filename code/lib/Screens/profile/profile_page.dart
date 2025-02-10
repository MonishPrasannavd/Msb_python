import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msb_app/Screens/profile/user_profile_screen.dart';
import 'package:msb_app/components/text_builder.dart';
import 'package:msb_app/main.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/msbuser.dart';
import 'package:msb_app/models/school.dart';
import 'package:msb_app/providers/master/master_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/user.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../components/button_builder.dart';
import '../../utils/colours.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({required this.onLogout, super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with RouteAware {
  File? _profileImage;
  bool isUploadingImage = false;
  String? userId;
  bool isEditing = false;
  String grade = "Grade 3";
  String schoolName = "Delhi Public School, Hyderabad";
  MsbUser? user;
  String? selectedSchoolId;
  TextEditingController gradeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String likesCount = "0";
  String commentsCount = "0";
  String totalPoints = "0";
  Grade? selectedGrade;
  School? selectedSchool;

  final ImagePicker _picker = ImagePicker();

  late UserProvider _userProvider;
  late UserAuthProvider _authProvider;
  late MasterProvider _masterProvider;

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    _masterProvider = Provider.of<MasterProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    loadUser();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadUser();
    });
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUser();
  }

  Future<void> loadUser() async {
    final result = await _authProvider.getUserMe(_userProvider.user);
    final user = result['user'] as MsbUser?;
    if (user == null) return;
    _userProvider.setUser(user);
    setState(() {
      nameController.text = _userProvider.user.user?.name ?? "";
      Grade? gradeResolve;
      School? schoolResolve;
      if (_userProvider.user.student.grade?.name != null &&
          _userProvider.user.student.grade?.name?.isNotEmpty != null) {
        gradeResolve = _userProvider.user.student.grade!;
      } else {
        gradeResolve = _masterProvider.grades.firstWhere(
            (grade) => grade.id == _userProvider.user.student.gradeId);
      }

      if (_userProvider.user.student.school?.name != null &&
          _userProvider.user.student.school?.name?.isNotEmpty != null) {
        schoolResolve = _userProvider.user.student.school!;
      } else {
        schoolResolve = _masterProvider.schools.firstWhere(
            (school) => school.id == _userProvider.user.student.schoolId);
      }

      gradeController.text = gradeResolve.name ?? "";
      grade = gradeResolve.name ?? "";
      selectedGrade = gradeResolve;
      selectedSchool = schoolResolve;
      schoolName = _userProvider.user.student.school?.name ?? "";
      likesCount = _userProvider.user.student.likes.toString();
      commentsCount = _userProvider.user.commentsCount.toString();
      totalPoints = _userProvider.user.student.points.toString();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfileDetails() async {
    try {
      Map<String, dynamic> response = await _authProvider.updateProfile(
        nameController.text,
        selectedGrade?.id ?? _userProvider.user.student.gradeId,
        selectedSchool?.id ?? _userProvider.user.student.schoolId,
        profileImage: _profileImage,
        schoolName: schoolName,
      );
      if (response['status'] == true) {
        var updatedUserRes = await _authProvider.getUserMe(_userProvider.user);
        var updatedUser = updatedUserRes['user'] as MsbUser;
        _userProvider.updateUserAndSchool(
            updatedStudent: updatedUser.student, updatedUser: updatedUser.user);
      }
      loadUser();
    } catch (e) {
      debugPrint("Error saving profile details: $e");
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
          "My Profile",
          style: GoogleFonts.poppins(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16),
        ),
      ),
      body: Consumer3<UserProvider, UserAuthProvider, MasterProvider>(
        builder: (ctxt, userProvider, userAuthProvider, masterProvider, child) {
          return mainUi();
        },
      ),
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
              SizedBox(height: query.height * 0.1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Container(
                  // height: isEditing ? query.height * 1 : query.height * 1,
                  // width: query.width,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (isEditing) {
                            _pickImage();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Enter edit mode to update image!");
                          }
                        },
                        child: isUploadingImage
                            ? const CircularProgressIndicator()
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: getUserProfileImage(
                                    _profileImage,
                                    _userProvider.user.user?.profileUrl),
                                // Explicitly cast to ImageProvider
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
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isEditing
                              ? Flexible(
                                  child: _buildEditableField(
                                      "Name", nameController))
                              : Text(
                                  fetchFirstName(
                                          _userProvider.user.user?.name) ??
                                      "*** Add name",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 32),
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
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),

                      /// school name
                      /// Non-editable school name
                      isEditing
                          ? _buildSchoolDropdown()
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
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
                          children: [
                            Expanded(
                              child: Center(
                                child: _buildStatCard(
                                  likesCount,
                                  "Likes",
                                  "unLike.svg",
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Center(
                                child: _buildStatCard(
                                  commentsCount,
                                  "Comments",
                                  "comment.svg",
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Center(
                                child: _buildStatCard(
                                  totalPoints,
                                  "Your Stars",
                                  "star",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: LayoutBuilder(
                          builder: (ctxt, constraints) {
                            // Calculate button width
                            final buttonWidth = constraints.maxWidth / 2 -
                                5; // Adjust for padding

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// edit details button
                                    SizedBox(
                                      width: buttonWidth,
                                      height: 50,
                                      child: ButtonBuilder(
                                        text: isEditing
                                            ? 'Save Details'
                                            : 'Edit Details',
                                        onPressed: () {
                                          if (isEditing) {
                                            _saveProfileDetails();
                                          } else {
                                            // fetchSchools();
                                          }
                                          setState(() {
                                            isEditing = !isEditing;
                                            if (isEditing) {
                                              gradeController.text = grade;
                                            }
                                          });
                                        },
                                        style: ButtonStyle(
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                                color: Color(0xFFE1C7FA),
                                                width: 1),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            const Color(0xFF6911BB),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                          side: WidgetStateProperty.all(
                                            const BorderSide(
                                                color: Color(0xFFE1C7FA),
                                                width: 1),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            const Color(0xFF6911BB),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: constraints
                                      .maxWidth, // Full width of the Row
                                  height: 50,
                                  child: ButtonBuilder(
                                    text: 'My entries',
                                    onPressed: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => UserProfileScreen(
                                          id: _userProvider.user.user!.id
                                              .toString()),
                                    ))
                                    // .then((val) async => await loadUserProfile()),
                                    ,
                                    style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                        const BorderSide(
                                            color: Color(0xFFE1C7FA), width: 1),
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                        const Color(0xFF6911BB),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                      const SizedBox(height: 10),
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

  ImageProvider getUserProfileImage(File? profileImage, String? profileUrl) {
    if (profileImage != null) {
      return FileImage(profileImage);
    } else if (profileUrl != null && profileUrl.isNotEmpty) {
      return CachedNetworkImageProvider(
        profileUrl,
        cacheKey: profileUrl,
      );
    } else {
      return const AssetImage("assets/images/profile1.png");
    }
  }

  Widget _buildSchoolDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownSearch<School>(
        compareFn: (item1, item2) => item1 == item2,
        items: (f, cs) => _masterProvider.schools,
        itemAsString: (item) => item.name!,
        selectedItem: selectedSchool,
        onChanged: (School? newSchool) {
          setState(() {
            selectedSchool = newSchool;
          });
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: "Search School",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
        decoratorProps: const DropDownDecoratorProps(
          baseStyle: TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: 'Select School',
          ),
        ),
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
              selectedGrade = newGrade;
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
          labelStyle: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16),
        ),
        style: GoogleFonts.poppins(
            color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  Widget _buildStarsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: 100,
        height: 110,
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
                style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextBuilder(
                text: totalPoints,
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.msbNeutral400),
              ),
              const SizedBox(height: 16.0),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset('assets/images/star.png')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, String iconPath) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF3F0A70),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          switch (iconPath) {
            'star' => Icon(
                Icons.star_outline,
                color: Colors.white,
              ),
            _ => SvgPicture.asset(
                "assets/svg/$iconPath",
                color: AppColors.white,
              ),
          },
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
