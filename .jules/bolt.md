## 2024-05-24 - FadeTransition over AnimatedBuilder
**Learning:** In Flutter, combining `AnimatedBuilder` with `Opacity` causes the entire child widget tree to rebuild on every animation frame, which can be expensive for complex trees.
**Action:** Always prefer specialized transition widgets like `FadeTransition` which apply opacity changes efficiently at the compositing layer without rebuilding the widget tree.
