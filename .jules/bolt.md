## 2024-07-06 - Parallelize Independent Future Awaits
**Learning:** Sequential `await` calls in Flutter/Dart, like waiting for weather and prediction data successively in `DashboardScreen`, unnecessarily block rendering.
**Action:** Always check if network requests or asynchronous tasks are independent. If they are, use the Dart 3 records `.wait` extension to parallelize execution and wait for all them simultaneously, which minimizes load time significantly.
