import 'package:flutter/material.dart';
import '../models/hobby.dart';
import 'app_colors.dart';
import 'app_icons.dart';

/// Extension to provide UI-derived fields (icon, color) on Hobby.
/// These fields were previously stored on the model but cannot be serialized.
extension HobbyUi on Hobby {
  IconData get catIcon => AppIcons.categoryIcon(category);
  Color get catColor => AppColors.categoryColor(category);
}

/// Extension to provide UI-derived fields on HobbyCategory.
extension CategoryUi on HobbyCategory {
  IconData get icon => AppIcons.categoryIcon(id);
  Color get color => AppColors.categoryColor(id);
}
