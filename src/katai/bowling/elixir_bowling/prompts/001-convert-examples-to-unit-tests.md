# Create Unit Tests from Examples

Tools:

- language: elixir
- test framework: ExUnit

Context:

- `bowling-prompt-incremental.md`
- `bowling_test.exs`

Instructions:

- produce partial examples - just the test function, not the surrounding structure

### Convert example `One complete frame` to a unit test

{begresp}
```elixir
test "one complete frame" do
  game =
    %Bowling{}
    |> Bowling.roll(1)
    |> Bowling.roll(2)

  assert game.score == 3
  assert game.frames == [[1, 2]]
end
```
{endresp}

### Convert example `Two frames, with one incomplete` to a unit test

{begresp}
```elixir
test "two frames, with one incomplete" do
  game =
    %Bowling{}
    |> Bowling.roll(1)
    |> Bowling.roll(2)
    |> Bowling.roll(3)

  assert game.score == 3
  assert game.frames == [[1, 2], [3]]
end
```
{endresp}

<!-- Local Variables: -->
<!-- gptel-model: claude-3-5-haiku-20241022 -->
<!-- gptel--backend-name: "Claude" -->
<!-- gptel--bounds: ((response (311 506) (578 814))) -->
<!-- End: -->
