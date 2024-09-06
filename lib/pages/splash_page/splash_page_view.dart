part of '../pages.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      // Navigate to DashboardView after delay
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return TestFirst(
              // data: null,
              );
        }),
        (route) => false,
      );
    });
    // Placeholder widget for the splash screen
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
