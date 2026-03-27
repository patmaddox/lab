---
status: draft
---

# Make plan status optional with proper index ordering

Plans without a status field should be implicitly "new" — just
captured, not yet being worked on. The INDEX.md should display
groups in this order: active, accepted, draft, new, done,
abandoned, rejected.

Requires extracting the index generation from inline Makefile
shell into a script that can handle the two-pass logic cleanly
(first pass: grep for known statuses, second pass: find files
missing any status field).
