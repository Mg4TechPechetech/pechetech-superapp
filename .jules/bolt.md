## 2024-05-18 - [Flutter Animation Performance Optimization]
**Learning:** Using `AnimatedBuilder` with `Opacity` forces the entire subtree to be rebuilt on every animation frame (e.g. 60 times a second), even if the children themselves aren't changing. This leads to massive unnecessary CPU/GPU overhead.
**Action:** Always prefer specialized transition widgets like `FadeTransition`, `SlideTransition`, etc., when animating properties like opacity or position. They update the render object directly without triggering expensive widget tree rebuilds.
