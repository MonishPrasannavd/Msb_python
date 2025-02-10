import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msb_app/Screens/blog/blog_screen.dart';
import 'package:msb_app/services/preferences_service.dart';
import 'package:msb_app/utils/auth.dart';
import 'package:msb_app/utils/colours.dart';

import '../competition/categories_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_page.dart';
import '../school/school_screen.dart';

class DashboardSetup extends StatefulWidget {
  const DashboardSetup({super.key});

  @override
  State<DashboardSetup> createState() => _DashboardSetupState();
}

class _DashboardSetupState extends State<DashboardSetup> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();
  final GlobalKey<SchoolScreenState> schoolScreenKey =
      GlobalKey<SchoolScreenState>();
  final GlobalKey<ProfileScreenState> profileScreenKey =
      GlobalKey<ProfileScreenState>();

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _screens = [];
  void checkShNow() async {
    // Debugging: Check if data is saved correctly
    String? storedUserId = await PrefsService.getUserId();
    String? storedEmail = await PrefsService.getUserNameEmail();

    print("Stored User ID: $storedUserId"); // Should print actual user ID
    print("Stored Email: $storedEmail"); // Should print email
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) {
      // If the current tab is re-selected, pop all screens to the root of the stack
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Reset the stack of the current tab before switching
      _navigatorKeys[_currentIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);

      // Update the current index to the new tab
      setState(() {
        _currentIndex = index;
      });

      // Perform additional actions based on the selected tab
      if (index == 0) {
        homeScreenKey.currentState?.homeTabKey.currentState?.refetchData();
      } else if (index == 2) {
        schoolScreenKey.currentState?.fetchData();
        schoolScreenKey.currentState?.refetchData();
      } else if (index == 4) {
        profileScreenKey.currentState?.loadUser();
      }
    }
  }

  // Future<bool> _onWillPop() async {
  //   return !await _navigatorKeys[_currentIndex].currentState!.maybePop();
  // }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState;
    if (currentNavigator == null || !await currentNavigator.maybePop()) {
      // If no history to pop, allow the app to close or navigate up.
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    checkShNow();
    _pageController = PageController(initialPage: 0);
    _screens.addAll([
      HomeScreen(
        key: homeScreenKey,
      ),
      const CategoriesScreen(),
      SchoolScreen(
        key: schoolScreenKey,
      ),
      const BlogScreen(),
      ProfileScreen(
        onLogout: AuthUtils.handleLogout(context),
        key: profileScreenKey,
      ),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back navigation
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens
              .asMap()
              .map((index, screen) => MapEntry(
                  index,
                  Navigator(
                    key: _navigatorKeys[index], // Unique navigator for each tab
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                        builder: (_) => screen,
                      );
                    },
                  )))
              .values
              .toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _onItemTapped(index);
            // _pageController.jumpToPage(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.fontHint,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/dash_1.svg"),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/dash_2.svg"),
              label: 'Talent',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/dash_3.svg"),
              label: 'School',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/dash_3.svg"),
              label: 'Blog',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("assets/svg/dash_4.svg"),
              label: 'Profile',
            ),
          ],
        ),

        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(15.0),
        //   child: Container(
        //     decoration:
        //         BoxDecoration(border: Border.all(color: AppColors.fontHint), borderRadius: BorderRadius.circular(50.0)),
        //     child: BottomNavyBar(
        //       backgroundColor: Colors.transparent,
        //       shadowColor: Colors.transparent,
        //       selectedIndex: _currentIndex,
        //       onItemSelected: (index) {
        //         _onItemTapped(index);
        //         setState(() => _currentIndex = index);
        //         //_pageController.jumpToPage(index);
        //       },
        //       itemPadding: const EdgeInsets.symmetric(horizontal: 5),
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       containerHeight: 60,
        //       items: <BottomNavyBarItem>[
        //         BottomNavyBarItem(
        //           title: Text(
        //             'Home',
        //             style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 12),
        //           ),
        //           icon: SvgPicture.asset("assets/svg/dash_1.svg"),
        //           inactiveColor: AppColors.fontHint,
        //           activeColor: AppColors.primary,
        //         ),
        //         BottomNavyBarItem(
        //             title: Text(
        //               'Competition',
        //               style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 12),
        //             ),
        //             icon: SvgPicture.asset("assets/svg/dash_2.svg"),
        //             inactiveColor: AppColors.fontHint,
        //             activeColor: AppColors.primary),
        //         BottomNavyBarItem(
        //             title: Text(
        //               'School',
        //               style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 12),
        //             ),
        //             icon: SvgPicture.asset("assets/svg/dash_3.svg"),
        //             inactiveColor: AppColors.fontHint,
        //             activeColor: AppColors.primary),
        //         BottomNavyBarItem(
        //             title: Text(
        //               'Profile',
        //               style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 12),
        //             ),
        //             icon: SvgPicture.asset("assets/svg/dash_4.svg"),
        //             activeColor: AppColors.primary),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

class BottomNavyBar extends StatelessWidget {
  const BottomNavyBar({
    super.key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.shadowColor = Colors.black12,
    this.itemCornerRadius = 50,
    this.containerHeight = 56,
    this.blurRadius = 2,
    this.spreadRadius = 0,
    this.borderRadius,
    this.shadowOffset = Offset.zero,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.animationDuration = const Duration(milliseconds: 270),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.showInactiveTitle = false,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  }) : assert(items.length >= 2 && items.length <= 5);

  /// The selected item is index. Changing this property will change and animate
  /// the item being selected. Defaults to zero.
  final int selectedIndex;

  /// The icon size of all items. Defaults to 24.
  final double iconSize;

  /// The background color of the navigation bar. It defaults to
  /// [ThemeData.BottomAppBarTheme.color] if not provided.
  final Color? backgroundColor;

  /// Defines the shadow color of the navigation bar. Defaults to [Colors.black12].
  final Color shadowColor;

  /// Whether this navigation bar should show a elevation. Defaults to true.
  final bool showElevation;

  /// Use this to change the item's animation duration. Defaults to 270ms.
  final Duration animationDuration;

  /// Defines the appearance of the buttons that are displayed in the bottom
  /// navigation bar. This should have at least two items and five at most.
  final List<BottomNavyBarItem> items;

  /// A callback that will be called when a item is pressed.
  final ValueChanged<int> onItemSelected;

  /// Defines the alignment of the items.
  /// Defaults to [MainAxisAlignment.spaceBetween].
  final MainAxisAlignment mainAxisAlignment;

  /// The [items] corner radius, if not set, it defaults to 50.
  final double itemCornerRadius;

  /// Defines the bottom navigation bar height. Defaults to 56.
  final double containerHeight;

  /// Used to configure the blurRadius of the [BoxShadow]. Defaults to 2.
  final double blurRadius;

  /// Used to configure the spreadRadius of the [BoxShadow]. Defaults to 0.
  final double spreadRadius;

  /// Used to configure the offset of the [BoxShadow]. Defaults to null.
  final Offset shadowOffset;

  /// Used to configure the borderRadius of the [BottomNavyBar]. Defaults to null.
  final BorderRadiusGeometry? borderRadius;

  /// Used to configure the padding of the [BottomNavyBarItem] [items].
  /// Defaults to EdgeInsets.symmetric(horizontal: 4).
  final EdgeInsets itemPadding;

  /// Used to configure the animation curve. Defaults to [Curves.linear].
  final Curve curve;

  /// Whether this navigation bar should show a Inactive titles. Defaults to false.
  final bool showInactiveTitle;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (Theme.of(context).bottomAppBarTheme.color ?? Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          if (showElevation)
            BoxShadow(
              color: shadowColor,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              offset: shadowOffset,
            ),
        ],
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: containerHeight,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: _ItemWidget(
                  item: item,
                  iconSize: iconSize,
                  isSelected: index == selectedIndex,
                  backgroundColor: bgColor,
                  itemCornerRadius: itemCornerRadius,
                  animationDuration: animationDuration,
                  itemPadding: itemPadding,
                  curve: curve,
                  showInactiveTitle: showInactiveTitle,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final EdgeInsets itemPadding;
  final Curve curve;
  final bool showInactiveTitle;

  const _ItemWidget({
    required this.iconSize,
    required this.isSelected,
    required this.item,
    required this.backgroundColor,
    required this.itemCornerRadius,
    required this.animationDuration,
    required this.itemPadding,
    required this.showInactiveTitle,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        width: (showInactiveTitle)
            ? ((isSelected)
                ? MediaQuery.of(context).size.width * 0.25
                : MediaQuery.of(context).size.width * 0.2)
            : ((isSelected)
                ? MediaQuery.of(context).size.width * 0.3
                : MediaQuery.of(context).size.width * 0.1),
        height: double.maxFinite,
        duration: animationDuration,
        curve: curve,
        decoration: BoxDecoration(
          color: isSelected ? item.activeColor : backgroundColor,
          borderRadius: BorderRadius.circular(itemCornerRadius),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: (showInactiveTitle)
                ? ((isSelected)
                    ? MediaQuery.of(context).size.width * 0.25
                    : MediaQuery.of(context).size.width * 0.2)
                : ((isSelected)
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconTheme(
                  data: IconThemeData(
                    size: iconSize,
                    color: isSelected
                        ? AppColors.white
                        : item.inactiveColor ?? item.activeColor,
                  ),
                  child: item.icon,
                ),
                if (showInactiveTitle)
                  Flexible(
                    child: Container(
                      padding: itemPadding,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: item.activeColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        textAlign: item.textAlign,
                        overflow: TextOverflow.ellipsis,
                        child: item.title,
                      ),
                    ),
                  )
                else if (isSelected)
                  Flexible(
                    child: Container(
                      padding: itemPadding,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: item.activeColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        textAlign: item.textAlign,
                        overflow: TextOverflow.ellipsis,
                        child: item.title,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The [BottomNavyBar.items] definition.
class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.icon,
    required this.title,
    this.activeColor = Colors.blue,
    this.textAlign,
    this.inactiveColor,
  });

  /// Defines this item's icon which is placed in the right side of the [title].
  final Widget icon;

  /// Defines this item's title which placed in the left side of the [icon].
  final Widget title;

  /// The [icon] and [title] color defined when this item is selected. Defaults
  /// to [Colors.blue].
  final Color activeColor;

  /// The [icon] and [title] color defined when this item is not selected.
  final Color? inactiveColor;

  /// The alignment for the [title].
  ///
  /// This will take effect only if [title] it a [Text] widget.
  final TextAlign? textAlign;
}
