## 2024-05-30 - [Parallelized Async Dashboard Loading]
**Learning:** Sequential `await` statements for independent network requests in dashboard screens (e.g., fetching weather and zone data separately) cause unnecessary latency. Dart 3 records `.wait` extension allows parallel execution with strict type safety.
**Action:** Use `await (Future1, Future2).wait` pattern instead of sequential `await`s when loading independent dashboard data to significantly reduce total load time while preserving readability and type safety.
