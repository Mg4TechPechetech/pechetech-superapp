## 2024-05-23 - Flutter Animation Rebuilds
**Learning:** Using `AnimatedBuilder` with `Opacity` causes the entire widget subtree to rebuild on every animation frame, which can be a significant CPU bottleneck.
**Action:** Always prefer specialized transition widgets like `FadeTransition` which push the opacity animation directly to the compositing layer without rebuilding the widget tree.
