import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import '../../Providers/points_provider.dart'; // Make sure this path is correct
import '../../Models/points_model.dart'; // Make sure this path is correct

class RatingWithPointsWidget extends StatefulWidget {
  final Map<String, dynamic> shopData;
  final double initialRating;
  final Function(double)? onRatingChanged;

  const RatingWithPointsWidget({
    Key? key,
    required this.shopData,
    this.initialRating = 0.0,
    this.onRatingChanged,
  }) : super(key: key);

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

  void _handleRatingTap(int rating) {
    setState(() {
      _userRating = rating.toDouble();
    });

    // Call the callback if provided
    widget.onRatingChanged?.call(_userRating);

    // Award points only if they haven't been awarded yet and rating is valid
    if (!_hasAwardedPoints && rating > 0) {
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);

      if (pointsProvider.canEarnPoints(PointsType.rateShop)) {
        pointsProvider.addPoints(
          PointsType.rateShop,
          shopName: widget.shopData['title'] as String? ?? 'Shop'
        );
        _hasAwardedPoints = true;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanks for rating ${widget.shopData['title']}! +15 points'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        final canEarnPoints = pointsProvider.canEarnPoints(PointsType.rateShop) && !_hasAwardedPoints;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rating: ',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                  ),
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
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                  ),
                ),
                if (canEarnPoints) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      '+15 pts',
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
                'Points earned for rating this shop!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

