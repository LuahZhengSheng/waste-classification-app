import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:fyp/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:fyp/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:fyp/common/widgets/texts/section_heading.dart';
import 'package:fyp/features/personalization/screens/profile/profile.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            FPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  FAppBar(title: Text('Account', style: Theme.of(context).textTheme.headlineMedium!.apply(color: FColors.white))),

                  /// User Profile Card
                  FUserProfileTile(onPressed: () => Get.to(() => const ProfileScreen())),
                  const SizedBox(height: FSizes.spaceBtwSections),
                ],
              ),
            ),

            /// -- Body
            Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Account Settings
                  const FSectionHeading(title: 'Account Settings', showActionButton: false),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),
                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),
                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),
                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),
                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),
                  FSettingsMenuTile(icon: Iconsax.safe_home, title: 'F Addresses', subtitle: 'Set shopping delivery address', onTap: (){}),

                  /// -- App Settings
                  const SizedBox(height: FSizes.spaceBtwSections),
                  const FSectionHeading(title: 'App Settings', showActionButton: false),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  FSettingsMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subtitle: 'Set shopping delivery address', trailing: Switch(value: false, onChanged: (value) {})),
                  FSettingsMenuTile(icon: Iconsax.location, title: 'Geolocation', subtitle: 'Set recommendation based on location', trailing: Switch(value: false, onChanged: (value) {})),
                  FSettingsMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subtitle: 'Set shopping delivery address', trailing: Switch(value: false, onChanged: (value) {})),
                  FSettingsMenuTile(icon: Iconsax.document_upload, title: 'Load Data', subtitle: 'Set shopping delivery address', trailing: Switch(value: false, onChanged: (value) {})),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


