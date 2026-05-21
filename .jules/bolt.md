## 2024-05-22 - [Dart 3 Parallelization]
**Learning:** Dart 3's records extension `(Future1, Future2).wait` is a safe and efficient way to parallelize independent async calls, avoiding the need for `Future.wait([])` and subsequent manual casting.
**Action:** Use this pattern whenever fetching independent data points in `initState` or data-loading methods.
