## 2024-05-24 - Prefer specialized transition widgets
**Learning:** Using `AnimatedBuilder` combined with `Opacity` rebuilds the entire widget tree beneath it on every animation frame, which is an anti-pattern.
**Action:** Always prefer specialized transition widgets like `FadeTransition` instead of `AnimatedBuilder` + `Opacity` to prevent unnecessary widget tree rebuilds.
