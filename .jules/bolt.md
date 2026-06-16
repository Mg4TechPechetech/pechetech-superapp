## 2024-05-24 - Parallelize independent async requests with Dart 3 Records
**Learning:** Sequential `await` statements for independent network requests (e.g., fetching weather and fishing zones) block the main thread unnecessarily and increase load times linearly. Dart 3 provides a `(Future1, Future2).wait` records extension that parallelizes these requests while maintaining strict type safety, unlike `Future.wait([])` which returns `List<dynamic>`.
**Action:** Always use the `(Future1, Future2).wait` records extension for parallelizing independent `Future`s to improve load times safely.
