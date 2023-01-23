import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/profile_provider.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/image_view_widget.dart';

class UserCredentialPage extends StatefulWidget {
  static String routeName = '/userCredentialPage';
  const UserCredentialPage({Key? key}) : super(key: key);

  @override
  State<UserCredentialPage> createState() => _UserCredentialPageState();
}

class _UserCredentialPageState extends State<UserCredentialPage> {
  File? _selectedImage;
  String? _imageName;
  bool _isLoading = false;

  Future<void> _getUserPicture(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: imageSource,
    );
    if (image == null) {
      return;
    }
    _imageName = path.basename(image.path);

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> updateUserCredential() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      if (_imageName == null && _selectedImage == null) {
        setState(() {
          _isLoading = false;
        });
        return Future.error('Upload your credential to save.');
      } else if (_imageName != null && _selectedImage == null) {
        setState(() {
          _isLoading = false;
        });
        return Future.error('Upload your new credential to save.');
      } else if (_selectedImage != null) {
        await FirebaseStorage.instance
            .ref(
              'image_file/$userId/$_imageName',
            )
            .putFile(_selectedImage!);

        String imageUrl = await FirebaseStorage.instance
            .ref('image_file/$userId/$_imageName')
            .getDownloadURL();
        // ignore: use_build_context_synchronously
        await Provider.of<ProfileProvider>(context, listen: false)
            .updateUserCredential(
          imageUrl,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        await Provider.of<ProfileProvider>(context, listen: false)
            .updateUserCredential(
          SharedService.userImageUrl,
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      return Future.error(e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _imageName =
        Provider.of<ProfileProvider>(context, listen: false).userCredential;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                height: 145,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.lightBlueAccent,
                      ThemeClass.primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(
                      50,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.navigate_before,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      SharedService.role == 'User'
                          ? 'User Credential'
                          : 'Hostel Owner Credential',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    left: 15,
                    right: 15,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (Provider.of<ProfileProvider>(context)
                            .userCredential
                            .isEmpty)
                          Stack(
                            children: [
                              Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: _selectedImage == null
                                    ? const Center(
                                        child: Text('Upload your credential'),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                        child: Image(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _selectedImage!,
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  color: Colors.black12,
                                  onPressed: () async {
                                    await _getUserPicture(
                                      ImageSource.gallery,
                                    ).then((value) {
                                      if (_selectedImage != null) {}
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.file_upload_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (Provider.of<ProfileProvider>(context)
                            .userCredential
                            .isNotEmpty)
                          Stack(
                            children: [
                              Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(
                                    5,
                                  ),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: _selectedImage == null
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ImageViewWidget(
                                                isNetworkImage: true,
                                                filePath: Provider.of<
                                                            ProfileProvider>(
                                                        context)
                                                    .userCredential,
                                              );
                                            },
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              Provider.of<ProfileProvider>(
                                                      context)
                                                  .userCredential,
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ImageViewWidget(
                                                isNetworkImage: false,
                                                filePath: _selectedImage!.path,
                                              );
                                            },
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                              _selectedImage!,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  color: Colors.black12,
                                  onPressed:
                                      Provider.of<ProfileProvider>(context)
                                              .isAdminVerified
                                          ? null
                                          : () async {
                                              await _getUserPicture(
                                                ImageSource.gallery,
                                              ).then((value) {
                                                if (_selectedImage != null) {}
                                              });
                                            },
                                  icon: const Icon(
                                    Icons.file_upload_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          child: InkWell(
                            onTap: Provider.of<ProfileProvider>(context)
                                    .isAdminVerified
                                ? null
                                : () async {
                                    await updateUserCredential().then((value) {
                                      SnackBars.showNormalSnackbar(
                                          context, 'Credential Saved.');
                                      Navigator.of(context).pop();
                                    }).catchError((e) {
                                      SnackBars.showErrorSnackBar(
                                          context, e.toString());
                                    });
                                  },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Provider.of<ProfileProvider>(context)
                                        .isAdminVerified
                                    ? Colors.grey
                                    : ThemeClass.primaryColor,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const ProgressIndicator1()
                                    : Text(
                                        Provider.of<ProfileProvider>(context)
                                                .userCredential
                                                .isEmpty
                                            ? 'Upload Credential'
                                            : 'Update Credential',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
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
