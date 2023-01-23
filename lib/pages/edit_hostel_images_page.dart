import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hostel_booking_application/Utilities/snackbars.dart';
import 'package:provider/provider.dart';

import '../providers/the_hostel.dart';
import '../widgets/image_view_widget.dart';

class EditHostelImagesPage extends StatefulWidget {
  const EditHostelImagesPage({Key? key}) : super(key: key);

  @override
  State<EditHostelImagesPage> createState() => _EditHostelImagesPageState();
}

class _EditHostelImagesPageState extends State<EditHostelImagesPage> {
  @override
  final List<XFile> _imageFiles = [];

  File? _selectedImage;

  Future<void> _getUserPicture(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (images == null) {
      return;
    } else if (images.length > 5) {
      // ignore: use_build_context_synchronously
      SnackBars.showNormalSnackbar(context, 'You can only chooose 5 images.');
      return;
    }

    setState(() {
      _imageFiles.addAll(images);
    });
  }

  void showImageChooseOptions() async {
    await _getUserPicture(
      ImageSource.camera,
    ).then((value) {
      if (_selectedImage != null) {
        Navigator.of(context).pop();
      }
    });
  }

  List<String> preferences = [
    'Students',
    'Friends',
    'Family',
    'Couple',
  ];
  List<String> cities = [
    'Kathmandu',
    'Bhaktapur',
    'Lalitpur',
  ];

  List<String> images = [];

  final _globalKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> getImageUrls() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    try {
      for (var image in _imageFiles) {
        await FirebaseStorage.instance
            .ref(
              'image_file/$userId/${image.name}',
            )
            .putFile(File(image.path))
            .then((p0) {});

        String imageUrl = await FirebaseStorage.instance
            .ref('image_file/$userId/${image.name}')
            .getDownloadURL();
        images.add(imageUrl);
      }
    } catch (e) {
      SnackBars.showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _onSaved(TheHostel hostel) async {
    if (!_globalKey.currentState!.validate()) {
      SnackBars.showErrorSnackBar(
          context, 'Please fill in all the required fields!!!');
      return;
    } else if (_imageFiles.isEmpty) {
      SnackBars.showErrorSnackBar(context, 'Please choose a photo!!!');
      return;
    } else if (_imageFiles.length > 5) {
      SnackBars.showErrorSnackBar(context, 'You can only chooose 5 images.');
      return;
    } else if (_imageFiles.length < 2) {
      SnackBars.showErrorSnackBar(
          context, 'You have to choose at least 2 images.');
      return;
    }

    _globalKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    try {
      getImageUrls().then((value) async {
        await hostel.updateHostelImages(images).then((value) {
          Navigator.of(context).pop();
          SnackBars.showNormalSnackbar(context, 'Hostel Images updated successfully.');

          setState(() {
            _isLoading = false;
          });
        }).catchError((e) {
          setState(() {
            _isLoading = false;
          });
          SnackBars.showErrorSnackBar(context, e.toString());
        });
      });
    } on SocketException {
      setState(() {
        _isLoading = false;
      });
      SnackBars.showNoInternetConnectionSnackBar(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackBars.showErrorSnackBar(context, e.toString());
    }
  }

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final hostel = Provider.of<TheHostel>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Hostel Images',
                  style: TextStyle(
                    color: ThemeClass.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                          child: Container(
                            padding: const EdgeInsets.all(
                              8,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showImageChooseOptions();
                                    },
                                    child: const Text(
                                      'Add Images',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (_imageFiles.isEmpty)
                                  const Text(
                                    'No files chosen!!!',
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (_imageFiles.isNotEmpty)
                                  Column(
                                    children: _imageFiles.map((image) {
                                      return Container(
                                        margin: const EdgeInsets.all(
                                          8,
                                        ),
                                        height: 80,
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return ImageViewWidget(
                                                        isNetworkImage: false,
                                                        filePath: image.path,
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Card(
                                                  elevation: 6,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      5,
                                                    ),
                                                    child: Image(
                                                      fit: BoxFit.cover,
                                                      image: FileImage(
                                                        File(image.path),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _imageFiles.removeWhere(
                                                      (imagen) =>
                                                          imagen == image);
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _onSaved(hostel);
                            },
                            child: _isLoading
                                ? const SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : const Text(
                                    'Update Hostel Images',
                                  ),
                          ),
                        ),
                      ],
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
