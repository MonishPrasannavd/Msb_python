import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csc_picker/csc_picker.dart';
// import 'package:csc_picker/dropdown_with_search.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:msb_app/Screens/dashboard/dashboard_setup.dart';
import 'package:msb_app/Screens/otp_sent/otp_sent_screen.dart';
import 'package:msb_app/components/country_state_dropdown.dart';
import 'package:msb_app/constants/navigation.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/school.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/providers/master/master_api_provider.dart';
import 'package:msb_app/providers/master/master_provider.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/utils/constants.dart';
import 'package:msb_app/utils/extention_text.dart';
import 'package:provider/provider.dart';
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

  late MasterApiProvider masterApiProvider;
  late MasterProvider masterProvider;
  late UserAuthProvider userAuthProvider;
  late UserProvider userProvider;

  final _formKey = GlobalKey<FormState>();
  bool _validate = false;
  School? selectedSchool;
  Grade? selectedGrade;
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
      debugPrint("Error fetching schools: $e");
    }
  }

  void fetchMaster() {
    var masterProvider = Provider.of<MasterProvider>(context, listen: false);
    masterApiProvider.getMasterData().then((result) {
      if (result['status']) {
        print("Master data fetched successfully.");
        masterProvider.countries = result['countries'];
        masterProvider.states = result['states'];
        masterProvider.schools = result['schools'];
        masterProvider.grades = result['grades'];
      }

      print(masterProvider.grades);
    }).catchError((error) {
      print("Error fetching master data: $error");
    });
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

  @override
  void initState() {
    super.initState();

    // Ensure Provider is available for initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      masterApiProvider =
          Provider.of<MasterApiProvider>(context, listen: false);
      masterProvider = Provider.of<MasterProvider>(context, listen: false);
      userAuthProvider = Provider.of<UserAuthProvider>(context, listen: false);
      userProvider = Provider.of<UserProvider>(context, listen: false);
      fetchMaster();
    });

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
    masterApiProvider = Provider.of<MasterApiProvider>(context);

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

                        const CountryStateDropdown(),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: cityController,
                          decoration: kTextFieldDecoration.copyWith(
                            labelText: "City",
                            hintText: "Enter city",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'City is required';
                            }
                            return null;
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
                            return null;
                          },
                          onTap: () =>
                              _selectDate(context), // Trigger the picker
                        ),
                        const SizedBox(height: 15),

                        // School selection dropdown
                        DropdownSearch<School>(
                          compareFn: (item1, item2) {
                            return item1.id == item2.id;
                          },
                          itemAsString: (item) => item.name!,
                          items: (f, cs) => masterProvider.schools,
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
                                  var newSchool = School(name: searchEntry);
                                  setState(() {
                                    masterProvider.addToSchools(newSchool);
                                    selectedSchool = newSchool;
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
                        DropdownSearch<Grade>(
                          compareFn: (item1, item2) {
                            return item1 == item2;
                          },
                          itemAsString: (item) => item.name!,
                          items: (f, cs) => masterProvider.grades,
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
                                  Map<String, dynamic> message =
                                      await userAuthProvider.register(
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text,
                                    selectedGrade!.id.toString(),
                                    userProvider.selectedCountry!.id.toString(),
                                    userProvider.selectedState!.id.toString(),
                                    cityController.text,
                                    selectedSchool?.id.toString(),
                                    selectedSchool?.name.toString(),
                                    dobController.text,
                                  );
                                  var user = message['user'];
                                  var responseMessage = message['message'];
                                  var responseStatus = message['status'];
                                  if (responseStatus == true) {
                                    Fluttertoast.showToast(
                                        msg: responseMessage);
                                    userProvider.setUser(user);
                                    callNextScreen(
                                        context, const DashboardSetup());
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: responseMessage);
                                  }
                                  // final newUserCredentail = await _auth
                                  //     .createUserWithEmailAndPassword(
                                  //   email: emailController.text,
                                  //   password: passwordController.text,
                                  // );
                                  // SharedPreferences prefs =
                                  //     await SharedPreferences.getInstance();
                                  // prefs.setString(
                                  //     "userId", newUserCredentail.user!.uid);
                                  // prefs.setString("nameEmail",
                                  //     newUserCredentail.user!.email.toString());
                                  // var newUser = newUserCredentail.user!;
                                  // // await createFirestoreRecord(newUser.uid);
                                  // await newUser.sendEmailVerification();
                                  //
                                } catch (e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                  debugPrint(e.toString());
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
