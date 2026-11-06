## 2024-05-24 - Future.wait Records Extension Optimization
**Learning:** Dart 3 records extension `(Future1, Future2).wait` is a great way to parallelize requests without losing type safety or having to use `Future.wait([])` and cast dynamic values.
**Action:** Use it to batch concurrent independent API or database calls to improve load times and avoid sequential execution.
