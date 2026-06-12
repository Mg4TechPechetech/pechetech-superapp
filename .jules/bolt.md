## 2024-05-24 - [Flutter Animation Optimization]
**Learning:** Using `AnimatedBuilder` with `Opacity` rebuilds the entire widget subtree on every animation tick, which is expensive for skeleton loading screens.
**Action:** Always prefer specialized transition widgets like `FadeTransition` over generic builders for opacity changes to prevent unnecessary render loop overhead.
