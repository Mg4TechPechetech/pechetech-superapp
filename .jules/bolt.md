## 2024-06-01 - Prevent rebuilds with specialized transition widgets
**Learning:** Using `AnimatedBuilder` combined with `Opacity` causes unnecessary widget tree rebuilds on every animation frame, which can lead to performance bottlenecks in loading screens.
**Action:** Always prefer specialized transition widgets like `FadeTransition` to avoid triggering rebuilds for child widgets.
