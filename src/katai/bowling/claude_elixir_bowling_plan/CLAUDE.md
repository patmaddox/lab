# General

- language: elixir

# Tools

- test: mix test
- format: mix format

# Rules

- write clear, concise code
- run tests after making a code change, make sure the tests pass
- format code after successful test run

# Tests

- ensure all code paths are fully tested
- organize tests with the simplest test first, and more complex tests later
- use `describe` blocks to organize tests for a specific function. Name the describe according to function signature.
