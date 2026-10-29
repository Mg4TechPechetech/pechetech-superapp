## 2026-05-11 - Virtualization in Flutter ListView
**Learning:** In Flutter, using `ListView(children: [...])` forces synchronous rendering of all elements, which is extremely expensive for items with complex UI effects like `BackdropFilter` and `BoxShadow`.
**Action:** Use `ListView.builder` or `ListView.separated` combined with a data source to enable virtualization for lists that can potentially grow, deferring rendering of elements until they enter the visible viewport.
