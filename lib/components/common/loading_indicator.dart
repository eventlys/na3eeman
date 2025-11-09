import 'package:flutter/material.dart';

import '../../Utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator( // Remove const
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor), // Fixed
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle( // Remove const
                color: AppColors.textSecondary, // Fixed
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

