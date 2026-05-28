## 2024-05-28 - Optimize Opacity Animation
**Learning:** Using AnimatedBuilder combined with Opacity causes unnecessary full widget tree rebuilds on every animation frame. Specialized transition widgets like FadeTransition are much more performant because they optimize the animation process and prevent these excessive rebuilds.
**Action:** When animating opacity, always use FadeTransition instead of AnimatedBuilder + Opacity.
