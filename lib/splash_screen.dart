import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmanager_app_getitdone/routes/pages.dart';
import 'package:taskmanager_app_getitdone/utils/color_palette.dart';
import 'package:taskmanager_app_getitdone/utils/font_sizes.dart';
import 'package:taskmanager_app_getitdone/utils/shared_preferences_helper.dart';

import 'components/widgets.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  bool _showProgressIndicator = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutQuart),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _showProgressIndicator = true;
      });
    }

    // Check if first time and navigate accordingly
    await Future.delayed(const Duration(milliseconds: 1700)); // Reduced delay to 3500ms total
    if (mounted) {
      await _checkFirstTimeAndNavigate();
    }
  }

  Future<void> _checkFirstTimeAndNavigate() async {
    try {
      final isFirstTime = await SharedPreferencesHelper.isFirstTime();

      if (mounted) {
        if (isFirstTime) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Pages.welcome,
                (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Pages.home,
                (route) => false,
          );
        }
      }
    } catch (e) {
      // In case of error, default to welcome screen
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Pages.welcome,
              (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor,
              kPrimaryColor.withOpacity(0.8),
              kPrimaryColor.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo section
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: kWhiteColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: kWhiteColor.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.task_alt,
                                      size: 80,
                                      color: kPrimaryColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Animated text section
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlideAnimation,
                          child: Opacity(
                            opacity: _textOpacityAnimation.value,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kWhiteColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: kWhiteColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: buildText(
                                    'Everything Tasks',
                                    kWhiteColor,
                                    textBold + 4,
                                    FontWeight.w800,
                                    TextAlign.center,
                                    TextOverflow.clip,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                buildText(
                                  'Schedule your week with ease',
                                  kWhiteColor.withOpacity(0.9),
                                  textMedium,
                                  FontWeight.w500,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),

                                const SizedBox(height: 8),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: buildText(
                                    'Stay organized, boost productivity, and never miss a deadline',
                                    kWhiteColor.withOpacity(0.7),
                                    textSmall,
                                    FontWeight.w400,
                                    TextAlign.center,
                                    TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _showProgressIndicator ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kWhiteColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kWhiteColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      kWhiteColor,
                                    ),
                                    backgroundColor: kWhiteColor.withOpacity(0.3),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                buildText(
                                  'Loading your workspace...',
                                  kWhiteColor.withOpacity(0.8),
                                  textTiny,
                                  FontWeight.w500,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    buildText(
                      'Version 1.0.0',
                      kWhiteColor.withOpacity(0.5),
                      textTiny - 2,
                      FontWeight.w400,
                      TextAlign.center,
                      TextOverflow.clip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}