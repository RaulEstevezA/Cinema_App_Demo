import 'package:cinema_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends StatefulWidget {

  static const name = 'home-screen';

  final StatefulNavigationShell navigationShell;

  const HomeScreen({super.key, required this.navigationShell});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _opacity = 1;
  Duration _duration = Duration.zero;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      setState(() {
        _opacity = 0;
        _duration = Duration.zero;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _opacity = 1;
          _duration = const Duration(milliseconds: 200);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: _duration,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: CustomBottomNavigation(navigationShell: widget.navigationShell),
    );
  }
}

