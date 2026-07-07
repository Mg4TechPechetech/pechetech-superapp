## 2024-05-24 - FadeTransition over AnimatedBuilder+Opacity
**Learning:** In Flutter, combining `AnimatedBuilder` with `Opacity` causes the entire subtree inside the builder to rebuild on every animation frame, which is an anti-pattern for performance when only opacity is changing.
**Action:** Always prefer specialized transition widgets like `FadeTransition` which handle the animation internally and avoid unnecessary widget tree rebuilds.
