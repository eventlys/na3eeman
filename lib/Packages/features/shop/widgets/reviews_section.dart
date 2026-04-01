import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../../core/enums/app_enums.dart';
import '../../profile/widgets/rating_with_points_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class ReviewsSection extends StatefulWidget {
  final Map<String, dynamic> shopData;

  const ReviewsSection({
    Key? key,
    required this.shopData, // Add this parameter
  }) : super(key: key);


  @override
  ReviewsSectionState createState() => ReviewsSectionState();
}

class ReviewsSectionState extends State<ReviewsSection> {
  final List<Map<String, dynamic>> reviews = [
    {'name': 'John Doe', 'rating': 5.0, 'comment': 'Great service! Very professional.'},
    {'name': 'Jane Smith', 'rating': 4.5, 'comment': 'Good haircut, friendly staff.'},
    {'name': 'Mike Johnson', 'rating': 4.0, 'comment': 'Nice atmosphere, will come again.'},
  ];

  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _addReview() {
    if (_reviewController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      reviews.insert(0, {
        'name': 'You',
        'rating': _userRating,
        'comment': _reviewController.text.trim(),
      });
    });

    // Get the customer ID from somewhere (you'll need to implement this)
    final customerId = _getCustomerId(); // You need to implement this method

    // Fixed points addition call
    Provider.of<PointsProvider>(context, listen: false).addPoints(
      customerId: customerId,
      type: PointsType.shopFeedback,
      metadata: {
        'shop_name': widget.shopData['name'] ?? 'Unknown Shop',
        'review': _reviewController.text.trim(),
        'rating': _userRating,
      },
    );

    _reviewController.clear();
    _userRating = 5.0;
    FocusScope.of(context).unfocus();
  }

  int _getCustomerId() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        return authProvider.user!.id;
      }

      throw Exception('User not authenticated');
    } catch (e) {
      debugPrint('Error getting customer ID: $e');
      throw Exception('Unable to retrieve customer ID. Please login again.');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('customer_reviews'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              Text('see_all'.tr(),
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...reviews.map((review) => _buildReviewItem(
            name: review['name'] as String,
            rating: review['rating'] as double,
            comment: review['comment'] as String,
          )),

          // Add Review Section
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('add_your_review'.tr(),
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),

                // Rating Section
               Row(
                children: [
                  Flexible(
                    child: RatingWithPointsWidget(
                      shopData: widget.shopData,
                      initialRating: _userRating,
                      onRatingChanged: (newRating) {
                        print('Rating changed to: $newRating');
                      },
                    ),
                  ),
                ],
              ),

                SizedBox(height: 12),

                // Comment TextField
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                  decoration: InputDecoration(
                    hintText: 'write_your_review_here'.tr(),
                    hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF2196F3)),
                    ),
                    filled: true,
                    fillColor: Color(0x1AFFFFFF),
                  ),
                ),

                SizedBox(height: 12),

                // Submit Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('submit_review'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required double rating,
    required String comment,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                  SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

