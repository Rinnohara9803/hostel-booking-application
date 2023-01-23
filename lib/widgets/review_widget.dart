import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/review.dart';
import '../utilities/themes.dart';

class ReviewWidget extends StatelessWidget {
  final List<Review> reviews;
  const ReviewWidget({Key? key, required this.reviews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews.map((review) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 5,
          ),
          child: Card(
            elevation: 2,
            child: Padding( 
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: ThemeClass.primaryColor,
                        backgroundImage: NetworkImage(review.image),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(review.reviewer),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RatingBarIndicator(
                    rating: review.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 15.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    review.review,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
