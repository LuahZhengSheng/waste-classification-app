import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/common/widgets/images/circular_image.dart';
import 'package:fyp/common/widgets/texts/section_heading.dart';
import 'package:fyp/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FAppBar(showBackArrow: true, title: Text('Profile'),),

      /// -- Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    FCircularImage(image: FImages.user, width: 80, height: 80),
                    TextButton(onPressed: (){}, child: const Text('Change Profile Picture')),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: FSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: FSizes.spaceBtwItems),

              /// Heading Profile Info
              const FSectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: FSizes.spaceBtwItems),

              FProfileMenu(title: 'Name', value: 'John Smith', onPressed: (){}),
              FProfileMenu(title: 'Username', value: 'John Smith', onPressed: (){}),

              const SizedBox(height: FSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: FSizes.spaceBtwItems),

              /// Heading Personal Info
              const FSectionHeading(title: 'Personal Information', showActionButton: false),
              const SizedBox(height: FSizes.spaceBtwItems),

              FProfileMenu(title: 'User ID', value: '13526', icon: Iconsax.copy, onPressed: (){}),
              FProfileMenu(title: 'E-mail', value: 'johnSmith@gmail.com', onPressed: (){}),
              FProfileMenu(title: 'Phone Number', value: '+60123456789', onPressed: (){}),
              FProfileMenu(title: 'Gender', value: 'Male', onPressed: (){}),
              FProfileMenu(title: 'Date of Birth', value: '10 Oct, 1998', onPressed: (){}),
              const Divider(),
              const SizedBox(height: FSizes.spaceBtwItems),
              
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Close Account', style: TextStyle(color: Colors.red)),
                ),
              )
            ],

          ),
        ),
      ),
    );
  }
}


