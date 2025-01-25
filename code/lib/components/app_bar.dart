import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msb_app/utils/colours.dart';

class MsbAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;

  const MsbAppBar({super.key, this.automaticallyImplyLeading = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Image.asset(
        "assets/images/home_appbar_img.png",
        height: 36,
        fit: BoxFit.cover,
      ),
      actions: [
        SvgPicture.asset(
          "assets/svg/notification.svg",
          height: 36,
          color: AppColors.white,
        ),
        const SizedBox(width: 20)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
