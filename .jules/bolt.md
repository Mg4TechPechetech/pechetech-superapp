## 2024-05-30 - [Parallelizing API Requests with Dart 3]
**Learning:** Sequential `await` calls for independent API requests create unnecessary performance bottlenecks and slow down initial screen loads. Using traditional `Future.wait([])` loses type safety and requires manual casting.
**Action:** When making multiple independent API requests (e.g., loading dashboard data, weather & zones), use Dart 3's records extension `(Future1, Future2).wait` to parallelize the requests while maintaining strict type safety for the awaited values.
