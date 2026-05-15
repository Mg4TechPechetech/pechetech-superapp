## 2024-05-24 - [Flutter Build Method Optimizations]
**Learning:** Found an anti-pattern in `_buildWelcomeSection` where a service (`ProfileService()`) was instantiated inside the build loop, which creates a new stream instance on every re-render and can cause a memory leak/performance bottleneck.
**Action:** Always verify that streams and services are instantiated outside the build loop (e.g. in `initState` or class fields) and that independent async data calls are parallelized using `Future.wait()`.
