import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobileMax = 600.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1024.0;
  static const double desktopMin = 1024.0;

  static const double maxContentWidth = 800.0;
  static const double maxFormWidth = 480.0;
  static const double maxModalWidth = 580.0;
  static const double maxFeedWidth = 640.0;
  static const double maxProfileWidth = 720.0;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isMobile => screenWidth < Breakpoints.mobileMax;
  bool get isTablet =>
      screenWidth >= Breakpoints.tabletMin && screenWidth < Breakpoints.desktopMin;
  bool get isDesktop => screenWidth >= Breakpoints.desktopMin;
  bool get isLargeScreen => screenWidth >= Breakpoints.tabletMin;
}

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          color: backgroundColor,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)? tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktopMin && desktop != null) {
          return desktop!(context, constraints);
        }
        if (constraints.maxWidth >= Breakpoints.tabletMin && tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}
