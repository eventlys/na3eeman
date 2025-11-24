import 'package:flutter/material.dart';
import '../../../../Helpers/barber_list_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import 'package:provider/provider.dart';

class BarberCard extends StatelessWidget {
  final String barberId;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BarberCard({
    super.key,
    required this.barberId,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Consumer<BarberProvider>(
      builder: (context, barberProvider, child) {
        final barber = barberProvider.barbers.firstWhere(
          (b) => b.id == barberId,
          orElse: () => _getFallbackBarberDto(barberId),
        );

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: (isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary)
                  .withValues(alpha: 0.1),
              child: barber.profileImage != null && barber.profileImage!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        barber.profileImage!,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackAvatar(barber.name, isDarkTheme);
                        },
                      ),
                    )
                  : _buildFallbackAvatar(barber.name, isDarkTheme),
            ),
            title: Text(
              barber.name.isNotEmpty ? barber.name : 'Unknown Barber',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: isDarkTheme ? AppColor.darkWarning : AppColor.lightWarning,
                      size: 16
                    ),
                    const SizedBox(width: 4),
                    Text(
                      barber.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${barber.totalAppointments} appointments',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                  ),
                ),
                if (barber.specialties.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    barber.specialties.take(2).join(', '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Image.asset(
                isDarkTheme ? AppImages.three_dots : AppImages.three_dots,
                width: 20,
                height: 20,
                color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Image.asset(
                        isDarkTheme ? AppImages.pencil_view : AppImages.pencil,
                        width: 18,
                        height: 18,
                        color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Image.asset(
                        isDarkTheme ? AppImages.trash_view : AppImages.trash,
                        width: 18,
                        height: 18,
                        color: isDarkTheme ? AppColor.darkError : AppColor.lightError,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: isDarkTheme ? AppColor.darkError : AppColor.lightError,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }

  Widget _buildFallbackAvatar(String name, bool isDarkTheme) {
    return Text(
      name.isNotEmpty ? name[0] : 'B',
      style: TextStyle(
        color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Fallback BarberDto in case the barber is not found in the provider
  BarberDto _getFallbackBarberDto(String id) {
    return BarberDto(
      id: id,
      name: 'Loading...',
      email: '',
      phone: '',
      rating: 0.0,
      totalAppointments: 0,
      specialties: [],
      isActive: false,
    );
  }
}
