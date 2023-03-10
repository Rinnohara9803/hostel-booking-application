import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hostel_booking_application/Utilities/snackbars.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/the_hostel.dart';
import '../services/shared_service.dart';
import '../widgets/image_view_widget.dart';

class AddYourHostel extends StatefulWidget {
  const AddYourHostel({Key? key}) : super(key: key);
  static const routeName = '/addYourHostelPage';

  @override
  State<AddYourHostel> createState() => _AddYourHostelState();
}

class _AddYourHostelState extends State<AddYourHostel>
    with AutomaticKeepAliveClientMixin<AddYourHostel> {
  @override
  bool get wantKeepAlive => true;
  String _address = '';
  String _name = '';
  String _city = '';
  int _amountPm = 0;
  String _contact = '';
  String _description = '';
  String _preference = '';
  String _petFriendly = '';
  String _needToPaySecurityDeposit = '';
  String _paymentOption = '';
  String _parkingForCar = '';
  String _parkingForMotorcycle = '';
  String _internetAvailability = '';
  double _latitude = SharedService.currentPosition.latitude;
  double _longitude = SharedService.currentPosition.longitude;

  final List<String> answers = ['Yes', 'No'];
  final List<String> _paymentMethods = ['Hand Cash', 'Online Payment'];
  final List<String> _internetOptions = ['Available', 'Not Available'];

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

  Future<void> _onSaved() async {
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
        TheHostel newHostel = TheHostel(
          images: images,
          id: DateTime.now().toIso8601String(),
          name: _name,
          ownerName: SharedService.userName,
          ownerEmail: SharedService.email,
          city: _city,
          address: _address,
          amount: _amountPm,
          contact: _contact,
          ownerId: userId as String,
          preference: _preference,
          description: _description,
          availabilityStatus: true,
          petFriendly: _petFriendly,
          needToPaySecurityDeposit: _needToPaySecurityDeposit,
          paymentOptions: _paymentOption,
          parkingForCar: _parkingForCar,
          parkingForMotorcycle: _parkingForMotorcycle,
          internetAvailability: _internetAvailability,
          latitude: _latitude,
          longitude: _longitude,
          reviews: [],
        );
        await Provider.of<HostelsProvider>(context, listen: false)
            .addHostel(newHostel)
            .then((value) {
          Navigator.of(context).pop();
          SnackBars.showNormalSnackbar(context, 'Hostel added successfully.');

          setState(() {
            _isLoading = false;
          });
        }).catchError((e) {
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

  late GoogleMapController _googleMapController;

  final Marker _locationMarker = Marker(
    markerId: const MarkerId('rino'),
    infoWindow: const InfoWindow(
      title: 'CurrentLocation',
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    ),
    position: LatLng(SharedService.currentPosition.latitude,
        SharedService.currentPosition.longitude),
  );

  Marker getCurrentMarker(double lat, double long) {
    return Marker(
      markerId: const MarkerId('rino1'),
      infoWindow: const InfoWindow(
        title: 'Hostel Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      position: LatLng(
        lat,
        long,
      ),
    );
  }

  final _cameraPosition = CameraPosition(
    target: LatLng(
      SharedService.currentPosition.latitude,
      SharedService.currentPosition.longitude,
    ),
    zoom: 12.5,
    tilt: 0,
  );
  final List<Marker> _markers = [];

  @override
  void initState() {
    _markers.add(_locationMarker);

    super.initState();
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Add Your Hostel',
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
                        TextFormField(
                          key: const ValueKey('Hostel Name'),
                          decoration: const InputDecoration(
                            labelText: 'Hostel Name',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please enter the name of Hostel.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'City',
                            ),
                          ),
                          items: cities.map(
                            (city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            _city = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a city';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Preferences',
                            ),
                          ),
                          items: preferences.map(
                            (preference) {
                              return DropdownMenuItem(
                                value: preference,
                                child: Text(preference),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            _preference = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select the preference type';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('Address'),
                          decoration: const InputDecoration(
                            labelText: 'Address',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please enter your address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _address = value!;
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('Amount/month'),
                          decoration: const InputDecoration(
                            labelText: 'Amount/month',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please enter rent/permonth.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _amountPm = int.parse(value!);
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text('Contact'),
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please provide your Contact Number';
                            } else if (value.length < 10) {
                              return 'Please provide valid Contact Numer';
                            }
                            return null;
                          },
                          maxLength: 10,
                          onSaved: (value) {
                            _contact = value!;
                          },
                        ),
                        TextFormField(
                          maxLines: 5,
                          key: const ValueKey('Description'),
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Please provider some description.';
                            } else if (value.trim().length < 5) {
                              return 'Description is too short.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _description = value!;
                          },
                          onChanged: (value) {
                            _description = value;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
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
                          height: 10,
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              height: 350,
                              width: double.infinity,
                              child: GoogleMap(
                                gestureRecognizers:
                                    // ignore: prefer_collection_literals
                                    <Factory<OneSequenceGestureRecognizer>>[
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                ].toSet(),
                                onTap: (latLng) {
                                  setState(() {
                                    if (_markers.length > 1) {
                                      _markers.removeLast();
                                      _latitude = latLng.latitude;
                                      _longitude = latLng.longitude;
                                      print(_latitude);
                                      print(_longitude);
                                      _markers.add(
                                        getCurrentMarker(
                                          latLng.latitude,
                                          latLng.longitude,
                                        ),
                                      );
                                    } else {
                                      _latitude = latLng.latitude;
                                      _longitude = latLng.longitude;
                                      print(_latitude);
                                      print(_longitude);
                                      _markers.add(
                                        getCurrentMarker(
                                          latLng.latitude,
                                          latLng.longitude,
                                        ),
                                      );
                                    }
                                  });
                                },
                                mapType: MapType.normal,
                                markers: _markers.map((e) => e).toSet(),
                                initialCameraPosition: _cameraPosition,
                                onMapCreated: (controller) =>
                                    _googleMapController = controller,
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: IconButton(
                                color: ThemeClass.primaryColor,
                                onPressed: () {
                                  _googleMapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          SharedService
                                              .currentPosition.latitude,
                                          SharedService
                                              .currentPosition.longitude,
                                        ),
                                        zoom: 15.5,
                                        tilt: 50,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  size: 35,
                                ),
                              ),
                            )
                          ],
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Pet Friendly',
                            ),
                          ),
                          items: answers.map(
                            (preference) {
                              return DropdownMenuItem(
                                value: preference,
                                child: Text(preference),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            _petFriendly = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select the preference type';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Need to pay security deposit',
                            ),
                          ),
                          items: answers.map(
                            (ntpsd) {
                              return DropdownMenuItem(
                                value: ntpsd,
                                child: Text(ntpsd),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value == 'Yes') {
                              _needToPaySecurityDeposit = 'Yes';
                            } else {
                              _needToPaySecurityDeposit = 'No';
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a value.';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Preferred Payment Method',
                            ),
                          ),
                          items: _paymentMethods.map(
                            (paymentMethod) {
                              return DropdownMenuItem(
                                value: paymentMethod,
                                child: Text(paymentMethod),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            _paymentOption = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a value.';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Parking for car',
                            ),
                          ),
                          items: answers.map(
                            (preference) {
                              return DropdownMenuItem(
                                value: preference,
                                child: Text(preference),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value == 'Yes') {
                              _parkingForCar = 'Yes';
                            } else {
                              _parkingForCar = 'No';
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a value.';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Parking for Motorcycle',
                            ),
                          ),
                          items: answers.map(
                            (preference) {
                              return DropdownMenuItem(
                                value: preference,
                                child: Text(preference),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value == 'Yes') {
                              _parkingForMotorcycle = 'Yes';
                            } else {
                              _parkingForMotorcycle = 'No';
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a value.';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            label: Text(
                              'Internet',
                            ),
                          ),
                          items: _internetOptions.map(
                            (ip) {
                              return DropdownMenuItem(
                                value: ip,
                                child: Text(ip),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            _internetAvailability = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a value.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _onSaved();
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
                                    'Add Your Hostel',
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
