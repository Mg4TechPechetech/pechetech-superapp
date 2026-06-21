## 2024-05-24 - Flutter Specialized Transition Widgets
**Learning:** In Flutter, `AnimatedBuilder` combined with `Opacity` rebuilds the entire widget tree inside the builder on every frame of the animation. For simple transitions like opacity, specialized widgets like `FadeTransition` are more efficient as they avoid unnecessary rebuilds of their children.
**Action:** Replace `AnimatedBuilder` with `FadeTransition` when animating opacity.
