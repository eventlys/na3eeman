import 'package:flutter/material.dart';
import '../../../../Models/salon/category_model.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/enums/gender.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/category_card.dart';

class CategorySelectionPage extends StatefulWidget {
  final bool giftMode;
  final String? giftGender;

  const CategorySelectionPage({
    super.key,
    this.giftMode = false,
    this.giftGender,
  });

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final List<dynamic> rawCategories = await _apiService.getCategories();
      final List<Category> categories = rawCategories.map((e) => Category.fromJson(e)).toList();
      
      // Determine target gender for filtering
      Gender? targetGender;
      if (widget.giftGender != null) {
        targetGender = GenderExtension.fromString(widget.giftGender!);
      }

      final filtered = categories.where((cat) {
        final catGender = cat.targetGender.toLowerCase();
        if (catGender == 'all') return true;
        if (targetGender == Gender.female && catGender == 'female') return true;
        if (targetGender == Gender.male && catGender == 'male') return true;
        return false;
      }).toList();

      if (mounted) {
        setState(() {
          _categories = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Select Category', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.giftMode ? 'What service would you like to gift?' : 'Which service are you looking for?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                          category: _categories[index],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/category_details',
                            arguments: {
                              'category': _categories[index],
                              'giftMode': widget.giftMode,
                              'giftGender': widget.giftGender,
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
