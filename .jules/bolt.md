## 2024-05-24 - [Parallelize API calls using Dart 3 Records Extension]
**Learning:** Dart 3's `(<Future1>, <Future2>).wait` extension allows for parallelizing independent asynchronous requests with strict type safety, which is more robust and cleaner than using `Future.wait([])` and manually casting from `List<dynamic>`.
**Action:** Always look for sequential `await` calls that don't depend on each other's results and refactor them using the records `wait` extension to improve screen load times.
