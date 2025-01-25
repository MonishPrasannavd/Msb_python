import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:csc_picker/dropdown_with_search.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:msb_app/Screens/otp_sent/otp_sent_screen.dart';
import 'package:msb_app/constants/navigation.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/utils/constants.dart';
import 'package:msb_app/utils/extention_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/button_builder.dart';
import '../../utils/colours.dart';

InputDecoration kTextFieldDecoration = InputDecoration(
  labelText: 'Enter value',
  hintText: 'Enter value',
  labelStyle: GoogleFonts.poppins(
      color: AppColors.fontHint, fontWeight: FontWeight.w400),
  hintStyle: GoogleFonts.poppins(
      color: AppColors.fontHint, fontWeight: FontWeight.w400),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.fontHint, width: 1),
    borderRadius: BorderRadius.circular(8.0), // Border radius
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: AppColors.fontHint, width: 1),
    borderRadius: BorderRadius.circular(8.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 1),
    borderRadius: BorderRadius.circular(8.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 1),
    borderRadius: BorderRadius.circular(8.0),
  ),
  prefixIcon: Padding(
    padding: const EdgeInsets.all(10.0),
    child: SvgPicture.asset(
      "assets/svg/email.svg",
      colorFilter: const ColorFilter.mode(AppColors.fontHint, BlendMode.srcIn),
    ),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final isTest = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  final SchoolUserRepository schoolUserRepository = SchoolUserRepository();

  final _formKey = GlobalKey<FormState>();
  bool _validate = false;
  SchoolUser? selectedSchool;
  String? selectedGrade;
  List<SchoolUser> schools = [];

  bool acceptTerms = false; // Track if the terms are accepted

  // Function to fetch schools
  Future<void> _fetchSchools() async {
    try {
      List<SchoolUser> fetchedSchools = await schoolUserRepository.getAll();
      setState(() {
        schools = fetchedSchools;
      });
    } catch (e) {
      print("Error fetching schools: $e");
    }
  }

  Future<void> _showTermsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Terms and Conditions"),
          content: const SingleChildScrollView(
            child: Text(
              "By signing up, you agree to our Terms and Conditions. "
              "Please read these carefully before proceeding.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  Future<void> createFirestoreRecord(String uid) async {
    try {
      MsbUser newUser = MsbUser(
        id: uid,
        name: nameController.text,
        email: emailController.text,
        phone: null,
        profileImageUrl: null,
        grade: selectedGrade,
        schoolName: selectedSchool != null
            ? schools
                .firstWhere(
                    (school) => school.schoolId == selectedSchool?.schoolId)
                .schoolName
            : null,
        schoolId: selectedSchool?.schoolId,
        city: cityController.text,
        country: countryController.text,
        state: stateController.text,
        dob: dobController.text,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());

      schoolUserRepository.updateSchoolAverageOnUserAddOrUpdate(newUser, 0.0);
    } catch (e) {
      print('Error creating Firestore record: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    if (isTest) {
      nameController.text = "Vishwesh Shukla";
      emailController.text = "vishweshshukla20@gmail.com";
      passwordController.text = "vishwesh";
      confirmPasswordController.text = "vishwesh";
      cityController.text = "Ahmedabad";
      countryController.text = "India";
      stateController.text = "Gujarat";
    }

    _fetchSchools();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
  }

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  // Common dropdown function
  Widget buildDropdown<T>({
    required String hint,
    required T? selectedValue,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return FormBuilderDropdown<T>(
      name: hint,
      initialValue: selectedValue,
      // validator: (value) {
      //   if (value == null) {
      //     return 'Grade is required';
      //   }
      // },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fontHint, width: 1.5),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.fontHint,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Format as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var query = MediaQuery.of(context).size;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: const CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(40.0),
                    bottomLeft: Radius.circular(40.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/images/signup.png",
                        height: query.height * 0.18,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "sign up",
                        style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 36),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Let’s get your on onboarded.",
                        style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, bottom: 10),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _validate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: "Name",
                            labelText: "Name",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: "Email Address",
                            labelText: "Email Address",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ⓘ Please enter your email";
                            } else if (!emailController.text.isValidEmail) {
                              return "ⓘ Enter valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: "Password",
                            labelText: "Password",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ⓘ Please enter correct password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: "Confirm Password",
                            labelText: "Confirm Password",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ⓘ Enter your confirm password";
                            } else if (passwordController.text !=
                                confirmPasswordController.text) {
                              return "ⓘ Password & confirm password do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        CSCPicker(
                          layout: Layout.vertical,
                          dropdownDecoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.fontHint,
                                width: 1), // Border color and width
                            borderRadius:
                                BorderRadius.circular(8.0), // Border radius
                          ),
                          disabledDropdownDecoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.fontHint, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onCountryChanged: (val) {
                            setState(() {
                              countryController.text = val;
                            });
                          },
                          onCityChanged: (val) {
                            setState(() {
                              cityController.text = val ?? '';
                            });
                          },
                          onStateChanged: (val) {
                            setState(() {
                              stateController.text = val ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date of Birth',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date of Birth is required';
                            }
                            // final DateTime selectedDate = DateTime.parse(value);
                            // final DateTime today = DateTime.now();
                            // final int age = today.year -
                            //     selectedDate.year -
                            //     (today.isBefore(DateTime(today.year, selectedDate.month, selectedDate.day)) ? 1 : 0);
                            // if (age < 18) {
                            //   return 'You must be at least 18 years old';
                            // }
                            return null;
                          },
                          onTap: () =>
                              _selectDate(context), // Trigger the picker
                        ),
                        const SizedBox(height: 15),

                        // School selection dropdown
                        DropdownSearch<SchoolUser>(
                          compareFn: (item1, item2) {
                            return item1.schoolId == item2.schoolId;
                          },
                          itemAsString: (item) => item.schoolName!,
                          items: (f, cs) => schools,
                          onChanged: (school) => setState(() {
                            selectedSchool = school;
                          }),
                          validator: (value) {
                            if (value == null) {
                              return 'School is required';
                            }
                          },
                          // Populate with school names
                          selectedItem: selectedSchool,
                          decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select school')),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: "Search School",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                            ),
                            emptyBuilder: (context, searchEntry) {
                              return ListTile(
                                leading:
                                    const Icon(Icons.add, color: Colors.blue),
                                title:
                                    Text("Add '$searchEntry' as a new school"),
                                onTap: () async {
                                  var newSchool = SchoolUser(
                                      schoolId:
                                          searchEntry.replaceAll(" ", "_"),
                                      schoolName: searchEntry,
                                      studentCount: 0,
                                      totalSubmissions: 0,
                                      averagePoints: 0,
                                      createdAt: Timestamp.now());
                                  var createdSchool = newSchool.schoolName != ''
                                      ? schoolUserRepository.saveOne(newSchool)
                                      : null;
                                  setState(() {
                                    if (createdSchool != null) {
                                      selectedSchool =
                                          createdSchool as SchoolUser?;
                                      schools.add(newSchool);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Failed to create school');
                                    }
                                  });
                                  Navigator.of(context)
                                      .pop(); // Close the dropdown popup
                                  // showAddSchoolDialog(searchEntry); // Show the add school dialog
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownSearch<String>(
                          compareFn: (item1, item2) {
                            return item1 == item2;
                          },
                          itemAsString: (item) => item!,
                          items: (f, cs) => grades,
                          onChanged: (grade) => setState(() {
                            selectedGrade = grade;
                          }),
                          validator: (value) {
                            if (value == null) {
                              return 'Grade is required';
                            }
                          },
                          // Populate with school names
                          selectedItem: selectedGrade,
                          decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select Grade')),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: "Search Grade",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        // Grade selection dropdown
                        const SizedBox(height: 15),

                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: acceptTerms,
                              onChanged: (bool? value) {
                                setState(() {
                                  acceptTerms = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showTermsDialog,
                                child: Text(
                                  "I accept the Terms and Conditions",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!acceptTerms && _validate)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "You must accept the terms and conditions to proceed.",
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 15),

                        SizedBox(
                          width: query.width,
                          height: 60,
                          child: ButtonBuilder(
                            text: 'Sign Up',
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _validate = true;
                              });
                              if (!acceptTerms) {
                                Fluttertoast.showToast(
                                  msg:
                                      "You must accept the Terms and Conditions to proceed.",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                                return;
                              }

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  // showSpinner = _formKey.currentState!.validate() ? true : false;
                                  showSpinner = true;
                                });
                                try {
                                  final newUserCredentail = await _auth
                                      .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString(
                                      "userId", newUserCredentail.user!.uid);
                                  prefs.setString("nameEmail",
                                      newUserCredentail.user!.email.toString());
                                  var newUser = newUserCredentail.user!;
                                  await createFirestoreRecord(newUser.uid);
                                  await newUser.sendEmailVerification();

                                  callNextScreen(
                                      context, const OtpSentScreen());
                                } catch (e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                  print(e);
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(AppColors.primary),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
