// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';

class RatingWithPointsWidget extends StatefulWidget {
  final Map<String, dynamic> salonData;
  final double initialRating;
  final Function(double)? onRatingChanged;

  const RatingWithPointsWidget({
    super.key,
    required this.salonData,
    this.initialRating = 0.0,
    this.onRatingChanged,
  });

  @override
  State<RatingWithPointsWidget> createState() => _RatingWithPointsWidgetState();
}

class _RatingWithPointsWidgetState extends State<RatingWithPointsWidget> {
  late double _userRating;
  bool _hasAwardedPoints = false;

  @override
  void initState() {
    super.initState();
    _userRating = widget.initialRating;
  }

  void _handleRatingTap(int rating) async {
    setState(() {
      _userRating = rating.toDouble();
    });

    // Call the callback if provided
    widget.onRatingChanged?.call(_userRating);

    // Award points only if they haven't been awarded yet and rating is valid
    if (!_hasAwardedPoints && rating > 0) {
      final pointsProvider = Provider.of<PointsProvider>(
        context,
        listen: false,
      );

      try {
        // You'll need to get the customer ID from somewhere
        // For now, using a placeholder
        final customerId = 1; // Replace with actual customer ID

        await pointsProvider.rateApp(customerId: customerId, rating: rating);

        setState(() {
          _hasAwardedPoints = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanks for rating ${widget.salonData['title']}! +25 points',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Show error message if points awarding fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to award points for rating'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rating: ',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
            ),
            SizedBox(width: 8),
            ...List.generate(5, (index) {
              return GestureDetector(
                onTap: () => _handleRatingTap(index + 1),
                child: Icon(
                  index < _userRating ? Icons.star : Icons.star_border,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              );
            }),
            SizedBox(width: 8),
            Text(
              _userRating.toStringAsFixed(1),
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
            ),
            if (!_hasAwardedPoints && _userRating > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '+25 pts',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Optional: Show message if points were already earned
        if (_hasAwardedPoints) ...[
          SizedBox(height: 4),
          Text(
            'Points earned for rating this salon!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
