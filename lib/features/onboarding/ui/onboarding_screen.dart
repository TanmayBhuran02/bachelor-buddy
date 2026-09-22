/// Onboarding screen featuring a 3-step walkthrough of Bachelor Buddy.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.primary,
      title: 'Track Expenses &\nRoommate Splits',
      description:
          'Record daily chai, rent, groceries, and split bills effortlessly. Set monthly budgets with safe-to-spend daily calculations.',
    ),
    _OnboardingPageData(
      icon: Icons.lunch_dining_outlined,
      iconColor: AppColors.secondary,
      title: 'Tiffin Tracking &\nAutomatic Billing',
      description:
          'Never forget whether lunch or dinner arrived. Mark tiffins as received or skipped, and let the app calculate your vendor bill automatically.',
    ),
    _OnboardingPageData(
      icon: Icons.auto_awesome,
      iconColor: AppColors.tertiary,
      title: 'Task Automations &\nSmart Reminders',
      description:
          'Create tasks like "Buy groceries for ₹450" and watch them turn into expenses when completed. Stay hydrated with intelligent water reminders.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding(BuildContext context) {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => _finishOnboarding(context),
                  child: const Text('Skip',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: data.iconColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(data.icon,
                              size: 60, color: data.iconColor),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white60, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation (Dots & Next/Get Started button)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Button
                  FilledButton(
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: Text(isLastPage ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
