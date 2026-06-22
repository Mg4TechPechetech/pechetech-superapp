## 2024-10-24 - Parallelize independent data fetching on Dashboard
**Learning:** The dashboard initially loaded independent API requests (weather and fishing zones) sequentially using `await`, which increases the network idle time and blocks the UI initial render longer than necessary.
**Action:** Always audit `_loadData` methods in screen widgets to parallelize independent `Future`s using Dart 3's `(Future1, Future2).wait` records extension to minimize perceived load time and maintain type safety.
