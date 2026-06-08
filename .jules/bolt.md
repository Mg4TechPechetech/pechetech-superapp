## 2024-06-08 - Parallelize Independent Futures in Initial Load
**Learning:** Sequential `await` statements for independent feature data calls significantly bottleneck screen load times in the codebase.
**Action:** Use Dart 3 `(Future1, Future2).wait` record extension to fetch independent data concurrently while preserving type safety instead of sequential awaits.
