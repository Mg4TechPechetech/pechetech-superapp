## 2024-06-19 - Parallelize independent Futures with Dart 3 Records
**Learning:** Sequential `await` calls on independent asynchronous operations create artificial bottlenecks, increasing total load time. Dart 3's `(Future1, Future2).wait` provides a type-safe, elegant way to run them in parallel without losing type information or resorting to `Future.wait([])` which returns `List<dynamic>`.
**Action:** Always identify independent network requests or async operations in loading sequences and group them using the records `.wait` extension to improve screen load times.
