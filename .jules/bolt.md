## 2024-05-29 - Optimize Opacity Animations with FadeTransition
**Learning:** Using AnimatedBuilder combined with an Opacity widget rebuilds the entire child tree on every frame, causing unnecessary CPU usage and potential frame drops.
**Action:** Use specialized transition widgets like FadeTransition instead of AnimatedBuilder + Opacity. FadeTransition pushes the opacity change directly to the rendering layer, completely avoiding widget tree rebuilds during the animation.
