## 2024-05-18 - Avoid AnimatedBuilder for simple opacities
**Learning:** Using AnimatedBuilder combined with Opacity causes unnecessary widget tree rebuilds on every animation frame, which is an anti-pattern in Flutter.
**Action:** Use specialized transition widgets like FadeTransition instead, as they are highly optimized and avoid rebuilding their children.
