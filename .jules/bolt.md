## 2024-05-24 - Flutter Fade Transition Optimization
**Learning:** Using AnimatedBuilder with Opacity causes the entire child widget tree to rebuild on every animation frame, which is an anti-pattern for simple opacity animations in Flutter.
**Action:** Always prefer specialized transition widgets like FadeTransition over AnimatedBuilder combined with Opacity to optimize rendering performance.
