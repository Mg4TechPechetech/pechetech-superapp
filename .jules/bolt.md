## 2024-05-24 - Initial Performance Journal\n**Learning:** Started journal\n**Action:** Keep updating with codebase specific findings

## 2024-05-24 - Dart 3 Parallel Awaits
**Learning:** Using Dart 3 records extension `(Future1, Future2).wait` allows for elegant parallelization of independent requests while maintaining strict type safety.
**Action:** Always look for sequential awaits in `_loadData()` functions and convert them to parallel records.waits to improve screen load times.
