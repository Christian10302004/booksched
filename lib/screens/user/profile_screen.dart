import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref('profile_images/${user!.uid}');
        final url = await ref.getDownloadURL();
        setState(() {
          _imageUrl = url;
        });
      } catch (e) {
        // Handle errors, e.g., image does not exist
        developer.log('Error loading profile image: $e', name: 'profile_screen');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || user == null) return;

    try {
      final ref = FirebaseStorage.instance.ref('profile_images/${user!.uid}');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    } catch (e) {
      // Handle errors
      developer.log('Error uploading image: $e', name: 'profile_screen');
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext dialogContext) {
        bool isLoggingOut = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: isLoggingOut
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 24),
                        Text('Logging out...'),
                      ],
                    )
                  : const Text('Are you sure you want to log out?'),
              actions: isLoggingOut
                  ? [] // Hide actions while logging out
                  : <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          setState(() {
                            isLoggingOut = true;
                          });
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (dialogContext.mounted) {
                              // Use root navigator to avoid issues with context
                              Navigator.of(dialogContext, rootNavigator: true).pop();
                              GoRouter.of(context).go('/login');
                            }
                          } catch (e) {
                            // Handle error, maybe show a snackbar
                            setState(() {
                              isLoggingOut = false;
                            });
                            // Optionally show an error message
                          }
                        },
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/user'),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmationDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
              child: _imageUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(user?.displayName ?? 'No Name',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 5),
            Text(user?.email ?? 'No Email',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
