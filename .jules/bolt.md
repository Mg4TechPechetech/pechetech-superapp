## 2024-10-25 - Parallelizing Independent Futures in Dart 3
**Learning:** Found sequential `await` calls for independent asynchronous requests (like weather and prediction services) which block each other and degrade load time. This is a common anti-pattern in the codebase.
**Action:** Always use the Dart 3 `(Future1, Future2).wait` records extension to parallelize independent futures, which improves load time while maintaining strict type safety.
