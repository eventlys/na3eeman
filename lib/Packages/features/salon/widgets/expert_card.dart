import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Helpers/expert_list_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import 'package:provider/provider.dart';

class ExpertCard extends StatelessWidget {
  final String expertId;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpertCard({
    super.key,
    required this.expertId,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExpertProvider>(
      builder: (context, expertProvider, child) {
        final expert = expertProvider.experts.firstWhere(
          (b) => b.id == expertId,
          orElse: () => _getFallbackExpertDto(expertId),
        );

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  (isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary)
                      .withValues(alpha: 0.1),
              child:
                  expert.profileImage != null && expert.profileImage!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        expert.profileImage!,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackAvatar(expert.name, isDarkTheme);
                        },
                      ),
                    )
                  : _buildFallbackAvatar(expert.name, isDarkTheme),
            ),
            title: Text(
              expert.name.isNotEmpty ? expert.name : 'Unknown Expert',
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
                      color: isDarkTheme
                          ? AppColor.darkWarning
                          : AppColor.lightWarning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      expert.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme
                            ? AppColor.darkText
                            : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${expert.totalAppointments} appointments',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkTheme
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary,
                  ),
                ),
                if (expert.specialties.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    expert.specialties.take(2).join(', '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkTheme
                          ? AppColor.darkTextSecondary
                          : AppColor.lightTextSecondary,
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
                        color: isDarkTheme
                            ? AppColor.darkText
                            : AppColor.lightText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "edit".tr(),
                        style: TextStyle(
                          color: isDarkTheme
                              ? AppColor.darkText
                              : AppColor.lightText,
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
                        color: isDarkTheme
                            ? AppColor.darkError
                            : AppColor.lightError,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "delete".tr(),
                        style: TextStyle(
                          color: isDarkTheme
                              ? AppColor.darkError
                              : AppColor.lightError,
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

  // Fallback ExpertDto in case the expert is not found in the provider
  ExpertDto _getFallbackExpertDto(String id) {
    return ExpertDto(
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
