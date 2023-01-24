import 'package:flutter/material.dart';
import 'package:hostel_booking_application/models/review.dart';

import '../widgets/review_widget.dart';

class RatingsAndReviewsPage extends StatelessWidget {
  final List<Review> reviews;
  static String routeName = '/ratingsAndReviewsPage';
  const RatingsAndReviewsPage({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reviews and Ratings',
          ),
          centerTitle: true,
        ),
        body: ReviewWidget(reviews: reviews),
      ),
    );
  }
}
