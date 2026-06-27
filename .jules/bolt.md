## 2024-05-24 - Parallelizing Independent API Calls in Dart 3+
**Learning:** Sequential `await`s on independent API calls (like weather and zones) unnecessarily block each other, increasing total load time. Dart 3+ records provide a clean way to await multiple futures concurrently while maintaining strict type safety, which is much better than the old `Future.wait([])` list approach.
**Action:** Use `final (res1, res2) = await (future1, future2).wait;` to parallelize independent data fetching instead of sequential `await`s.
