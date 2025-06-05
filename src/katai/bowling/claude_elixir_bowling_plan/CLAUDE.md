# General

- language: elixir

# Tools

- test: mix test
- format: mix format

# Rules

- write clear, concise code
- ensure all code paths are fully tested
- any new functionality will require new tests with it
- run tests after making a code change, make sure the tests pass
- format code after successful test run

# Tests

- organize tests with the simplest test first, and more complex tests later
- use `describe` blocks to organize tests for a specific function. Name the describe according to function signature.
