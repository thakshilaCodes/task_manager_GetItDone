import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmanager_app_getitdone/components/build_text_field.dart';
import 'package:taskmanager_app_getitdone/components/widgets.dart';
import 'package:taskmanager_app_getitdone/routes/pages.dart';
import 'package:taskmanager_app_getitdone/utils/color_palette.dart';
import 'package:taskmanager_app_getitdone/utils/font_sizes.dart';
import 'package:taskmanager_app_getitdone/utils/shared_preferences_helper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _nameError = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _validateName() {
    final name = _nameController.text.trim();
    setState(() {
      _nameError = name.isEmpty || name.length < 2;
    });
    return !_nameError;
  }

  Future<void> _saveName() async {
    if (!_validateName()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();

      // Save the name and set not first time
      final success = await SharedPreferencesHelper.saveUserName(name);
      await SharedPreferencesHelper.setNotFirstTime();

      if (success && mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, $name!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Navigate to home after a short delay
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Pages.home,
                (route) => false,
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save name. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skipForNow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await SharedPreferencesHelper.saveUserName('User');
      await SharedPreferencesHelper.setNotFirstTime();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Pages.home,
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
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
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top spacing
                              SizedBox(height: size.height * 0.1),

                              // Welcome illustration
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: kWhiteColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_add,
                                    size: 60,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Welcome text
                              buildText(
                                'Welcome!',
                                kWhiteColor,
                                textBold + 6,
                                FontWeight.w800,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),

                              const SizedBox(height: 12),

                              buildText(
                                'Let\'s get to know you better',
                                kWhiteColor.withOpacity(0.9),
                                textMedium,
                                FontWeight.w500,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),

                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: buildText(
                                  'Enter your name to personalize your experience',
                                  kWhiteColor.withOpacity(0.7),
                                  textSmall,
                                  FontWeight.w400,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ),

                              const SizedBox(height: 60),

                              // Name input section
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: kWhiteColor.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          color: kPrimaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        buildText(
                                          'Your Name',
                                          kBlackColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.start,
                                          TextOverflow.clip,
                                        ),
                                        buildText(
                                          ' *',
                                          kRed,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.start,
                                          TextOverflow.clip,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: _nameError
                                            ? Border.all(color: kRed.withOpacity(0.5))
                                            : null,
                                      ),
                                      child: BuildTextField(
                                        hint: "Enter your full name",
                                        controller: _nameController,
                                        inputType: TextInputType.name,
                                        fillColor: kGrey3.withOpacity(0.1),
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: kPrimaryColor.withOpacity(0.7),
                                          size: 20,
                                        ),
                                        onChange: (value) {
                                          if (_nameError && value.trim().length >= 2) {
                                            setState(() {
                                              _nameError = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),

                                    if (_nameError) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.error, size: 16, color: kRed),
                                          const SizedBox(width: 4),
                                          buildText(
                                            'Please enter at least 2 characters',
                                            kRed,
                                            textTiny,
                                            FontWeight.w500,
                                            TextAlign.start,
                                            TextOverflow.clip,
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    // Continue button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor,
                                          foregroundColor: kWhiteColor,
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: _isLoading ? null : _saveName,
                                        child: _isLoading
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              kWhiteColor,
                                            ),
                                          ),
                                        )
                                            : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.arrow_forward, size: 20),
                                            const SizedBox(width: 8),
                                            buildText(
                                              'Continue',
                                              kWhiteColor,
                                              textMedium,
                                              FontWeight.w600,
                                              TextAlign.center,
                                              TextOverflow.clip,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: size.height * 0.1),

                              // Skip option
                              TextButton(
                                onPressed: _isLoading ? null : _skipForNow,
                                child: buildText(
                                  'Skip for now',
                                  kWhiteColor.withOpacity(0.7),
                                  textSmall,
                                  FontWeight.w500,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}