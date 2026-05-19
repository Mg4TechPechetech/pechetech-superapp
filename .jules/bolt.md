## 2024-05-19 - Dashboard Parallel Requests
**Learning:** In Dart 3+, sequential `await` statements for independent network requests create unnecessary bottlenecks. The `DashboardScreen` and `BenefitsDashboard` sequentially fetch profile, weather, and zone data, which blocks rendering.
**Action:** Use the `(Future1, Future2).wait` records extension to parallelize independent asynchronous requests to improve load times without losing type safety.
