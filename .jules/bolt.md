
## 2024-05-24 - Flutter Transition Optimization
**Learning:** Using `AnimatedBuilder` combined with `Opacity` and building the child widget tree inside the builder function causes unnecessary widget rebuilds on every animation frame.
**Action:** Always prefer specialized transition widgets like `FadeTransition` over `AnimatedBuilder` + `Opacity` to prevent unnecessary widget tree rebuilds and improve rendering performance.
