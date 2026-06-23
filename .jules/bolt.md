
## 2024-05-24 - Parallelize API Calls with Dart 3 Records
**Learning:** Using sequential `await`s for independent API calls (like weather and prediction data) creates a performance bottleneck by summing their load times.
**Action:** Use Dart 3's `(Future1, Future2).wait` records extension to run independent futures in parallel while maintaining strict type safety.
