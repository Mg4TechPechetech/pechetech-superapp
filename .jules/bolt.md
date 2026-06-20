## 2024-05-20 - Parallelize Independent Async Requests
**Learning:** In Dart 3+, sequential `await`s for independent API requests unnecessarily block execution and increase overall load time. Using the `(Future1, Future2).wait` records extension is the optimal way to parallelize them while maintaining type safety.
**Action:** Always look for sequential `await` calls that don't depend on each other's results. Replace them with the `(..., ...).wait` syntax to execute them concurrently and improve performance.
