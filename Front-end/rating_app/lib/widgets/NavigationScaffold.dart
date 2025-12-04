import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/widgets/nav-bar.dart';

class Navigationscaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTap;
  final PreferredSizeWidget? appBar;

  const Navigationscaffold({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "NORMAL";

    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: Navbar(page: currentIndex, onTap: onTap, role: role),
    );
  }
}