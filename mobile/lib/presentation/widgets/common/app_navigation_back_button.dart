import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back button that pops when possible, otherwise navigates to [fallbackRoute].
class AppNavigationBackButton extends StatelessWidget {
  final String? fallbackRoute;

  const AppNavigationBackButton({super.key, this.fallbackRoute});

  void _handlePress(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    if (fallbackRoute != null) {
      context.go(fallbackRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => _handlePress(context),
    );
  }
}
