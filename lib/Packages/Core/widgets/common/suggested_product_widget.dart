import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/inventory_helpers.dart';
import '../../../../Services/business_service.dart';
import '../../constants/app_color.dart';
import '../../constants/app_images.dart';
import '../../utils/helpers/themes_helpers.dart';
import '../base/error_boundary.dart';

class SuggestedProductWidget extends StatefulWidget {
  final Map<String, dynamic> productData;
  final VoidCallback onAddToCart;
  final bool isDarkMode;
  final UserGender? userGender;

  const SuggestedProductWidget({
    super.key,
    required this.productData,
    required this.onAddToCart,
    this.isDarkMode = false,
    this.userGender,
  });

  @override
  State<SuggestedProductWidget> createState() => _SuggestedProductWidgetState();
}

class _SuggestedProductWidgetState extends State<SuggestedProductWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final String productName = widget.productData['productName'] ?? 'Unknown Product';
    final String productDescription = widget.productData['productDescription'] ?? 'No description available';
    final double productPrice = (widget.productData['productPrice'] ?? 0.0).toDouble();
    final int quantityInStock = (widget.productData['quantityInStock'] ?? 0).toInt();
    final int minStockLevel = (widget.productData['minStockLevel'] ?? 3).toInt();
    final String itemId = widget.productData['id'] ?? '';

    final colors = _getThemeColors();
    final textStyles = _getTextStyles(colors);

    return ErrorBoundary(
      isDarkMode: widget.isDarkMode,
      userGender: widget.userGender,
      onRetry: _clearError,
      child: Card(
        color: colors['cardBackground'],
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colors['border'] ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Using placeholder with theme
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: 150,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors['imageBackground']!,
                      colors['imageBackground']!.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colors['imageIcon'],
                  size: 40,
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message if any
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors['errorBackground'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            widget.isDarkMode ? AppImages.error_view : AppImages.error,
                            width: 16,
                            height: 16,
                            color: colors['error'],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textStyles['error'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: _clearError,
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: colors['error'],
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Product name with stock status indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: textStyles['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        InventoryHelpers.getStockEmoji(quantityInStock, minStockLevel),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Stock status message
                  Text(
                    InventoryHelpers.getStockStatusMessage(quantityInStock, minStockLevel),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStockStatusColor(colors, quantityInStock, minStockLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Product description
                  Text(
                    productDescription,
                    style: textStyles['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price and actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(productPrice),
                        style: textStyles['price'],
                      ),

                      // Action buttons based on stock status
                      if (_isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colors['primary']!),
                          ),
                        )
                      else if (quantityInStock > 0)
                        _buildActionButtons(itemId, quantityInStock, colors)
                      else
                        _buildOutOfStockActions(itemId, colors),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String itemId, int currentQuantity, Map<String, Color> colors) {
    final minStockLevel = (widget.productData['minStockLevel'] ?? 3).toInt();
    return Row(
      children: [
        // Quick restock button for low stock
        if (InventoryHelpers.isLowStock(currentQuantity, minStockLevel))
          IconButton(
            onPressed: () => _quickRestock(itemId, currentQuantity),
            icon: Icon(Icons.inventory_2, size: 18, color: colors['warning']),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Quick Restock',
          ),

        // Add to cart button
        IconButton(
          onPressed: widget.onAddToCart,
          icon: Icon(Icons.add_shopping_cart, size: 20, color: colors['primary']),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildOutOfStockActions(String itemId, Map<String, Color> colors) {
    return IconButton(
      onPressed: () => _restockItem(itemId),
      icon: Icon(Icons.add_box_outlined, size: 20, color: colors['error']),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'Restock Item',
    );
  }

  Future<void> _quickRestock(String itemId, int currentQuantity) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final inventoryService = Provider.of<InventoryService>(context, listen: false);
      final newQuantity = currentQuantity + 5; // Add 5 units for quick restock

      await inventoryService.updateItemQuantity(
        itemId: itemId,
        newQuantity: newQuantity,
        reason: 'Quick restock from suggested products',
      );

      // Update local data
      widget.productData['quantityInStock'] = newQuantity;

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restocked to $newQuantity units'),
            backgroundColor: _getSuccessColor(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to restock: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restockItem(String itemId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final inventoryService = Provider.of<InventoryService>(context, listen: false);

      await inventoryService.updateItemQuantity(
        itemId: itemId,
        newQuantity: 10, // Default restock quantity
        reason: 'Restocked from suggested products',
      );

      // Update local data
      widget.productData['quantityInStock'] = 10;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item restocked to 10 units'),
            backgroundColor: _getSuccessColor(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to restock: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Color _getSuccessColor() {
    return widget.isDarkMode ? AppColor.darkSuccess : AppColor.lightSuccess;
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  Color _getStockStatusColor(Map<String, Color> colors, int quantity, int minStockLevel) {
    if (quantity == 0) {
      return colors['error']!;
    } else if (InventoryHelpers.isCriticalStock(quantity, minStockLevel)) {
      return colors['warning']!;
    } else if (quantity < 10) {
      return colors['info']!;
    } else {
      return colors['success']!;
    }
  }

  Map<String, Color> _getThemeColors() {
    final isDark = widget.isDarkMode;

    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return {
            'cardBackground': isDark ? AppColor.darkMaleBackground : AppColor.maleBackground,
            'primary': AppColor.maleAccent,
            'secondary': isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'border': isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG,
            'imageBackground': isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG,
            'imageIcon': isDark ? AppColor.darkText : AppColor.lightText,
            'success': isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
            'warning': isDark ? AppColor.darkWarning : AppColor.lightWarning,
            'error': isDark ? AppColor.darkError : AppColor.lightError,
            'info': isDark ? AppColor.darkInfo : AppColor.lightInfo,
            'errorBackground': isDark ? AppColor.darkError.withValues(alpha: 0.1) : AppColor.lightError.withValues(alpha: 0.1),
          };
        case UserGender.female:
          return {
            'cardBackground': isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground,
            'primary': AppColor.femaleAccent,
            'secondary': isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'border': isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG,
            'imageBackground': isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG,
            'imageIcon': isDark ? AppColor.darkText : AppColor.lightText,
            'success': isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
            'warning': isDark ? AppColor.darkWarning : AppColor.lightWarning,
            'error': isDark ? AppColor.darkError : AppColor.lightError,
            'info': isDark ? AppColor.darkInfo : AppColor.lightInfo,
            'errorBackground': isDark ? AppColor.darkError.withValues(alpha: 0.1) : AppColor.lightError.withValues(alpha: 0.1),
          };
        case UserGender.nonBinary:
          return {
            'cardBackground': isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground,
            'primary': AppColor.nonBinaryAccent,
            'secondary': isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'border': isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG,
            'imageBackground': isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG,
            'imageIcon': isDark ? AppColor.darkText : AppColor.lightText,
            'success': isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
            'warning': isDark ? AppColor.darkWarning : AppColor.lightWarning,
            'error': isDark ? AppColor.darkError : AppColor.lightError,
            'info': isDark ? AppColor.darkInfo : AppColor.lightInfo,
            'errorBackground': isDark ? AppColor.darkError.withValues(alpha: 0.1) : AppColor.lightError.withValues(alpha: 0.1),
          };
      }
    }

    // Default theme colors
    return {
      'cardBackground': isDark ? AppColor.darkCard : AppColor.lightCard,
      'primary': isDark ? AppColor.darkPrimary : AppColor.primary,
      'secondary': isDark ? AppColor.darkSecondary : AppColor.secondary,
      'text': isDark ? AppColor.darkText : AppColor.lightText,
      'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
      'border': isDark ? AppColor.darkSecondary : AppColor.lightSecondary,
      'imageBackground': isDark ? AppColor.darkBackground : AppColor.lightBackground,
      'imageIcon': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
      'success': isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
      'warning': isDark ? AppColor.darkWarning : AppColor.lightWarning,
      'error': isDark ? AppColor.darkError : AppColor.lightError,
      'info': isDark ? AppColor.darkInfo : AppColor.lightInfo,
      'errorBackground': isDark ? AppColor.darkError.withValues(alpha: 0.1) : AppColor.lightError.withValues(alpha: 0.1),
    };
  }

  Map<String, TextStyle> _getTextStyles(Map<String, Color> colors) {
    return {
      'title': TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: colors['text'],
      ),
      'description': TextStyle(
        fontSize: 12,
        color: colors['textSecondary'],
      ),
      'price': TextStyle(
        fontSize: 14,
        color: colors['success'],
        fontWeight: FontWeight.bold,
      ),
      'error': TextStyle(
        fontSize: 12,
        color: colors['error'],
      ),
    };
  }
}
