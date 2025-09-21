import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemChrome

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Shutdown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake Shutdown Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FakeShutdownScreen()),
            );
          },
          child: const Text('Start Fake Shutdown'),
        ),
      ),
    );
  }
}

class FakeShutdownScreen extends StatefulWidget {
  const FakeShutdownScreen({super.key});

  @override
  State<FakeShutdownScreen> createState() => _FakeShutdownScreenState();
}

class _FakeShutdownScreenState extends State<FakeShutdownScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  bool _showBackButton = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    // Hide system UI overlays with immersive sticky mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      setState(() {
        _animationComplete = true;
        // Show back button after a delay
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showBackButton = true;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    // Restore system UI overlays to edgeToEdge mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main shutdown animation
            if (!_animationComplete)
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              size: 100,
                              color: Colors.white,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Shutting down...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Blank screen after animation
            if (_animationComplete)
              const ColoredBox(
                color: Colors.black,
              ),

            // Hidden back button in bottom right corner
            if (_showBackButton)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
