import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ai_personal_assistant/src/utils/logger.dart';

/// Collection of useful Dart extensions
extension ContextExtensions on BuildContext {
  /// Get theme data with less boilerplate
  ThemeData get theme => Theme.of(this);
  
  /// Get text theme with less boilerplate
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color scheme with less boilerplate
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Get media query with less boilerplate
  MediaQueryData get media => MediaQuery.of(this);
  
  /// Get screen size shortcut
  Size get screenSize => media.size;
  
  /// Get safe area dimensions
  EdgeInsets get safeArea => media.padding;
  
  /// Check if device is in landscape mode
  bool get isLandscape => media.orientation == Orientation.landscape;
  
  /// Check if device has notch
  bool get hasNotch => safeArea.top > 24 || safeArea.bottom > 0;
  
  /// Navigate to a new screen
  Future<T?> push<T>(Widget page) => Navigator.push(
    this,
    MaterialPageRoute(builder: (_) => page),
  );
  
  /// Replace current screen
  Future<T?> pushReplacement<T>(Widget page) => Navigator.pushReplacement(
    this,
    MaterialPageRoute(builder: (_) => page),
  );
  
  /// Show a snackbar
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}

extension StringExtensions on String {
  /// Capitalize first letter of a string
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  /// Format string to title case
  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  /// Truncate long text with ellipsis
  String truncate({int maxLength = 50, String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
  
  /// Simple email validation
  bool get isEmail {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(this);
  }
  
  /// Simple password strength validation
  bool get isStrongPassword {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[a-z]')) &&
        contains(RegExp(r'[0-9]'));
  }
  
  /// Estimate token count (1 token ≈ 4 characters)
  int estimateTokenCount() => (length / 4).ceil();
}

extension DateTimeExtensions on DateTime {
  /// Format date to human-readable string
  String format([String pattern = 'MMM dd, yyyy HH:mm']) {
    return DateFormat(pattern).format(this);
  }
  
  /// Get time ago string
  String timeAgo({bool numericDates = true}) {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return numericDates ? '1 year ago' : 'Last year';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return numericDates ? '$months months ago' : '$months months ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return numericDates ? '$weeks weeks ago' : '$weeks weeks ago';
    } else if (difference.inDays > 0) {
      return numericDates ? '${difference.inDays} days ago' : 'Yesterday';
    } else if (difference.inHours > 0) {
      return numericDates ? '${difference.inHours} hours ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
}

extension ListExtensions<T> on List<T> {
  /// Add item if it doesn't already exist
  void addUnique(T item) {
    if (!contains(item)) add(item);
  }
  
  /// Partition list based on predicate
  (List<T>, List<T>) partition(bool Function(T) predicate) {
    final first = <T>[];
    final second = <T>[];
    
    for (final item in this) {
      if (predicate(item)) {
        first.add(item);
      } else {
        second.add(item);
      }
    }
    
    return (first, second);
  }
  
  /// Safely get element at index
  T? elementAtOrNull(int index) {
    try {
      return this[index];
    } catch (_) {
      return null;
    }
  }
}

extension IterableExtensions<T> on Iterable<T> {
  /// Find first element or null
  T? firstOrNull() => isEmpty ? null : first;
  
  /// Find first element matching predicate or null
  T? firstWhereOrNull(bool Function(T) predicate) {
    for (final item in this) {
      if (predicate(item)) return item;
    }
    return null;
  }
}

extension DoubleExtensions on double {
  /// Convert degrees to radians
  double toRadians() => this * (3.1415926535 / 180.0);
  
  /// Convert radians to degrees
  double toDegrees() => this * (180.0 / 3.1415926535);
  
  /// Format to percentage string
  String toPercentString({int decimals = 1}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}

extension WidgetExtensions on Widget {
  /// Add standard padding
  Widget withPadding([EdgeInsetsGeometry? padding]) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
      child: this,
    );
  }
  
  /// Add standard margin
  Widget withMargin([EdgeInsetsGeometry? margin]) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppConstants.defaultPadding),
      child: this,
    );
  }
  
  /// Wrap in centered container
  Widget center() {
    return Center(child: this);
  }
  
  /// Add tap gesture
  Widget onTap(VoidCallback action, {bool opaque = true}) {
    return GestureDetector(
      behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onTap: action,
      child: this,
    );
  }
}