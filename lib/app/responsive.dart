import 'package:flutter/widgets.dart';

class AppBreakpoints {
  static const mobile = 700.0;
  static const desktop = 1100.0;
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  static int columnsFor(
    BuildContext context, {
    required int mobileColumns,
    required int desktopColumns,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 380) return 1;
    if (width < AppBreakpoints.mobile) return mobileColumns.clamp(1, 2);
    if (width < AppBreakpoints.desktop) return 3;
    return desktopColumns.clamp(3, 8);
  }
}
