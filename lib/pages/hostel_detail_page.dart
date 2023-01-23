import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hostel_booking_application/models/review.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:hostel_booking_application/widgets/hostel_details_shimmer_widget.dart';
import 'package:provider/provider.dart';

import '../services/shared_service.dart';
import '../widgets/hoste_owner_widget.dart';
import '../widgets/image_view_widget.dart';
import '../widgets/review_widget.dart';

class HostelDetailPage extends StatefulWidget {
  final String hostelId;
  const HostelDetailPage({
    Key? key,
    required this.hostelId,
  }) : super(key: key);

  static const routeName = '/rentFloorDetailPage';

  @override
  State<HostelDetailPage> createState() => _HostelDetailPageState();
}

class _HostelDetailPageState extends State<HostelDetailPage> {
  String _review = '';
  double _rating = 1.0;
  final _formKey = GlobalKey<FormState>();

  Widget floorDetailContainers(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await Provider.of<HostelsProvider>(context, listen: false)
          .fetchHostelDetailsById(widget.hostelId);
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostel = Provider.of<TheHostel>(context);

    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        body: FutureBuilder(
          future: Provider.of<HostelsProvider>(context, listen: false)
              .fetchHostelDetailsById(hostel.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const HostelDetailsShimmerWidget();
            } else if (snapshot.hasError) {
              if (snapshot.error.toString() ==
                  'Bad state: cannot get a field on a DocumentSnapshotPlatform which does not exist') {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No data found for this hostel.'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Sorry for the incovinience !!!',
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Check your Internet Connection'),
                    const Text('And'),
                    TextButton(
                      onPressed: () async {
                        setState(() {});
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return Consumer<HostelsProvider>(
                builder: (context, hostelData, child) {
                  final hostel = hostelData.hostelById;
                  return Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              8,
                            ),
                            child: CarouselSlider(
                              items: hostel!.images.map((image) {
                                return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ImageViewWidget(
                                          isNetworkImage: true,
                                          filePath: image,
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'images/hostel.png'),
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          image,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 230,
                                viewportFraction: 0.8,
                                aspectRatio: 8 / 10,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 13,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 15,
                                left: 20,
                                right: 20,
                                bottom: 1,
                              ),
                              color: Colors.white,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //       child: Column(
                                    //         children: [
                                    //           const Text(
                                    //             '4',
                                    //           ),
                                    //           RatingBar(
                                    //             initialRating: 3,
                                    //             direction: Axis.horizontal,
                                    //             allowHalfRating: true,
                                    //             itemCount: 5,
                                    //             ratingWidget: RatingWidget(
                                    //               full: Icon(Icons.star),
                                    //               half: Icon(Icons.star),
                                    //               empty: Icon(Icons.star),
                                    //             ),
                                    //             itemPadding:
                                    //                 EdgeInsets.symmetric(
                                    //                     horizontal: 4.0),
                                    //             onRatingUpdate: (rating) {
                                    //               print(rating);
                                    //             },
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            hostel.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: ThemeClass.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Rs. ${hostel.amount} per month',
                                            maxLines: 2,
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        floorDetailContainers(
                                          'Preference',
                                          hostel.preference,
                                        ),
                                        Text(
                                          hostel.availabilityStatus
                                              ? 'Available'
                                              : 'Packed',
                                          style: TextStyle(
                                            color: ThemeClass.primaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        floorDetailContainers(
                                          'Address',
                                          hostel.address,
                                        ),
                                        FloatingActionButton.small(
                                          heroTag: 'faq info',
                                          backgroundColor: Colors.white,
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              isDismissible: true,
                                              enableDrag: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    15,
                                                  ),
                                                  topRight: Radius.circular(
                                                    15,
                                                  ),
                                                ),
                                              ),
                                              backgroundColor: Colors.white,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: const [
                                                          Text(
                                                            'FAQ\'s',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(
                                                      thickness: 1.5,
                                                    ),
                                                    Expanded(
                                                      child: ListView(
                                                        children: [
                                                          FaqWidget(
                                                            theKey:
                                                                'Pet Friendly',
                                                            value: hostel
                                                                .petFriendly,
                                                          ),
                                                          FaqWidget(
                                                            theKey:
                                                                'Need To Pay Security-Deposit',
                                                            value: hostel
                                                                .needToPaySecurityDeposit,
                                                          ),
                                                          FaqWidget(
                                                            theKey:
                                                                'Internet Availability',
                                                            value: hostel
                                                                .internetAvailability,
                                                          ),
                                                          FaqWidget(
                                                            theKey:
                                                                'Parking for Car',
                                                            value: hostel
                                                                .parkingForCar,
                                                          ),
                                                          FaqWidget(
                                                            theKey:
                                                                'Parking for Motorcycle',
                                                            value: hostel
                                                                .parkingForMotorcycle,
                                                          ),
                                                          FaqWidget(
                                                            theKey:
                                                                'Payment Options',
                                                            value: hostel
                                                                .paymentOptions,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.info_outline_rounded,
                                            color: ThemeClass.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    floorDetailContainers(
                                      'City',
                                      hostel.city,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Learn more : ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      hostel.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    const Divider(
                                      thickness: 1.5,
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ratings and Reviews',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: ThemeClass.primaryColor,
                                          ),
                                        ),
                                        // Text(
                                        //   'Write your review',
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.bold,
                                        //     fontSize: 14,
                                        //     color: ThemeClass.primaryColor,
                                        //     decoration:
                                        //         TextDecoration.underline,
                                        //   ),
                                        // ),
                                        if (SharedService.role == 'User' &&
                                            SharedService.isAdminVerified)
                                          TextButton(
                                            onPressed: () {
                                              final user = FirebaseAuth
                                                  .instance.currentUser;
                                              final userId = user?.uid;
                                              List<String> reviewIds = [];
                                              Review? myReview;
                                              for (var review
                                                  in hostel.reviews) {
                                                reviewIds.add(review.id);
                                              }
                                              if (reviewIds.contains(userId)) {
                                                myReview = hostel.reviews
                                                    .firstWhere((review) =>
                                                        review.id == userId);
                                              }
                                              showModalBottomSheet(
                                                isDismissible: true,
                                                enableDrag: false,
                                                backgroundColor: Colors.white,
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (ctx,
                                                        StateSetter setState) {
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              clipBehavior:
                                                                  Clip.none,
                                                              children: [
                                                                Container(
                                                                  height: 100,
                                                                  width: double
                                                                      .infinity,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      begin: Alignment
                                                                          .topRight,
                                                                      end: Alignment
                                                                          .bottomLeft,
                                                                      colors: [
                                                                        Colors
                                                                            .lightBlueAccent,
                                                                        ThemeClass
                                                                            .primaryColor,
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  right: 0,
                                                                  left: 0,
                                                                  top: -42,
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 52,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          50,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black12,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                        SharedService
                                                                            .userImageUrl,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 6,
                                                                  right: 0,
                                                                  left: 0,
                                                                  child: Text(
                                                                    'Review By ${SharedService.userName}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Form(
                                                                  key: _formKey,
                                                                  child: Column(
                                                                    children: [
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      RatingBar
                                                                          .builder(
                                                                        initialRating: reviewIds.contains(userId)
                                                                            ? myReview!.rating
                                                                            : 2,
                                                                        minRating:
                                                                            1,
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        allowHalfRating:
                                                                            true,
                                                                        itemCount:
                                                                            5,
                                                                        itemPadding:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              5.0,
                                                                        ),
                                                                        itemBuilder:
                                                                            (context, _) =>
                                                                                Icon(
                                                                          Icons
                                                                              .star,
                                                                          color:
                                                                              ThemeClass.primaryColor,
                                                                        ),
                                                                        onRatingUpdate:
                                                                            (rating) {
                                                                          _rating =
                                                                              rating;
                                                                        },
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              20,
                                                                        ),
                                                                        child:
                                                                            TextFormField(
                                                                          initialValue: reviewIds.contains(userId)
                                                                              ? myReview!.review
                                                                              : '',
                                                                          maxLines:
                                                                              5,
                                                                          key:
                                                                              const ValueKey(
                                                                            'Write your review',
                                                                          ),
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            labelText:
                                                                                'Your review',
                                                                          ),
                                                                          validator:
                                                                              (value) {
                                                                            if (value!.trim().isEmpty) {
                                                                              return 'Please provide your review.';
                                                                            } else if (value.trim().length <
                                                                                5) {
                                                                              return 'Review is too short.';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          onSaved:
                                                                              (value) {
                                                                            _review =
                                                                                value!;
                                                                          },
                                                                          onChanged:
                                                                              (value) {
                                                                            _review =
                                                                                value;
                                                                          },
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          if (reviewIds
                                                                              .contains(userId))
                                                                            TextButton(
                                                                              onPressed: () async {
                                                                                try {
                                                                                  await Provider.of<HostelsProvider>(context, listen: false)
                                                                                      .deleteReview(
                                                                                    hostel.id,
                                                                                  )
                                                                                      .then((value) {
                                                                                    Navigator.of(context).pop();
                                                                                    SnackBars.showNormalSnackbar(context, 'Your review has been deleted.');
                                                                                  });
                                                                                } on SocketException {
                                                                                  Navigator.of(context).pop();
                                                                                  SnackBars.showNoInternetConnectionSnackBar(context);
                                                                                } catch (e) {
                                                                                  Navigator.of(context).pop();
                                                                                  SnackBars.showErrorSnackBar(context, e.toString());
                                                                                }
                                                                              },
                                                                              child: const Text(
                                                                                'Delete your review',
                                                                                style: TextStyle(color: Colors.redAccent),
                                                                              ),
                                                                            ),
                                                                          if (!reviewIds
                                                                              .contains(userId))
                                                                            Container(),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (!_formKey.currentState!.validate()) {
                                                                                return;
                                                                              }
                                                                              _formKey.currentState!.save();
                                                                              try {
                                                                                await Provider.of<HostelsProvider>(context, listen: false)
                                                                                    .updateReview(
                                                                                  Review(
                                                                                    id: userId as String,
                                                                                    rating: _rating,
                                                                                    review: _review,
                                                                                    reviewer: SharedService.userName,
                                                                                    image: SharedService.userImageUrl,
                                                                                  ),
                                                                                  hostel.id,
                                                                                )
                                                                                    .then((value) {
                                                                                  Navigator.of(context).pop();
                                                                                  SnackBars.showNormalSnackbar(context, 'Your review has been posted.');
                                                                                });
                                                                              } on SocketException {
                                                                                Navigator.of(context).pop();
                                                                                SnackBars.showNoInternetConnectionSnackBar(context);
                                                                              } catch (e) {
                                                                                Navigator.of(context).pop();
                                                                                SnackBars.showErrorSnackBar(context, e.toString());
                                                                              }
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              'Post your review',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Your review',
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (hostel.reviews.isEmpty)
                                      const Text(
                                        'No reviews till date!',
                                        textAlign: TextAlign.center,
                                      ),

                                    ReviewWidget(
                                      reviews: hostel.reviews.take(3).toList(),
                                    ),
                                    if (hostel.reviews.isNotEmpty)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            child: const Text('See more ...'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (SharedService.role == 'User')
                            HostelOwnerWidget(
                              hostelOwnerName: hostel.ownerName,
                              hostelContact: hostel.contact,
                              hostelEmail: hostel.ownerEmail,
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class FaqWidget extends StatelessWidget {
  const FaqWidget({
    Key? key,
    required this.theKey,
    required this.value,
  }) : super(key: key);

  final String theKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        top: 2,
        bottom: 8,
        right: 8,
        left: 8,
      ),
      elevation: 3,
      child: ListTile(
        title: Text(
          theKey,
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeClass.primaryColor,
          ),
        ),
      ),
    );
  }
}
