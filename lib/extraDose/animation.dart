import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimateDemoPage extends StatefulWidget {
  const AnimateDemoPage({super.key});

  @override
  State<AnimateDemoPage> createState() => _AnimateDemoPageState();
}

class _AnimateDemoPageState extends State<AnimateDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Animate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Shimmer effect (loop)
            Container(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  color: Colors.blueGrey[300],
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds),

            /// Fade in with scale and delay
            Text("Fade + Scale")
                .animate()
                .fadeIn(duration: 5000.ms)
                .scale(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 20),

            /// Slide with curve
            Container(
                  width: 200,
                  height: 50,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: const Text("Slide"),
                )
                .animate()
                .slide(begin: const Offset(-1, 0), curve: Curves.easeOutBack)
                .fadeIn(),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            /// Shake
            const Text(
              "Shake",
            ).animate().shake(hz: 4, offset: Offset(8, 0), duration: 600.ms),

            const SizedBox(height: 20),

            /// Blur + Tint
            Container(
                  width: 200,
                  height: 100,
                  color: Colors.orange,
                  alignment: Alignment.center,
                  child: const Text(
                    "Blur + Tint",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                )
                .animate()
                .blurXY(begin: 10, end: 0, duration: 1200.ms)
                .tint(color: Colors.red.withOpacity(0.3), duration: 1200.ms),

            const SizedBox(height: 20),

            /// Custom effect + loop
            const Text(
                  "Custom Effect",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
                .animate(onPlay: (c) => c.repeat())
                .custom(
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 2 * 3.1415,
                      child: child,
                    );
                  },
                  duration: 2.seconds,
                ),

            const SizedBox(height: 40),

            /// Chained with onComplete
            Center(
              child: const Text("Chained Animation with onComplete")
                  .animate()
                  .fadeIn()
                  .then(delay: 500.ms)
                  .slide(begin: const Offset(1, 0))
                  .then()
                  .scaleXY(end: 1.5)
                  .callback(
                    duration: 0.ms,
                    callback:
                        (bool completed) => debugPrint(
                          "Animation complete! Success: $completed",
                        ),
                  ),
            ),

            /// newCustomEffect
            Text("Hello World").animate().custom(
              duration: 1000.ms,
              builder:
                  (context, value, child) => Container(
                    color: Color.lerp(Colors.red, Colors.blue, value),
                    padding: EdgeInsets.all(8),
                    child: child,
                  ),
            ),

            /// change text according to time
            Animate().toggle(
              duration: 4.seconds,
              builder: (_, value, __) => Text(value ? "Before" : "After"),
            ),
            Text("Hello")
                .animate()
                .fadeIn(curve: Curves.bounceIn, duration: 2000.ms)
                .listen(callback: (value) => print('current opacity: $value')),

            ///keep blinking
            Text(
                  "Stock Alert !",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
                .animate(
                  delay: 1800.ms,
                  onPlay: (controller) => controller.repeat(), // loop
                )
                .fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
