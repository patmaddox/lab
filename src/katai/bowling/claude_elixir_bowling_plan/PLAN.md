# Bowling Application Plan

## Bowling Rules (Standard 10-pin bowling)

- 10 frames per game
- Frames 1-9: 2 rolls maximum per frame
- Frame 10: up to 3 rolls (if strike/spare)
- Strike: all 10 pins down on first roll (10 + next 2 rolls)
- Spare: all 10 pins down in 2 rolls (10 + next 1 roll)
- Open frame: fewer than 10 pins total

## Core Data Structures

```elixir
%Game{
  frames: [%Frame{}],
  score: integer(),
  complete?: boolean()
}

%Frame{
  rolls: [integer()],
  score: integer(),
  type: :strike | :spare | :open
}
```

## API Design

- `Bowling.new_game/0` - Create new game
- `Bowling.roll/2` - Add roll to game
- `Bowling.score/1` - Calculate total score
- `Bowling.game_complete?/1` - Check if game finished

## Implementation Steps

1. Replace placeholder code with core structs
2. Implement roll recording logic
3. Add scoring algorithm with strike/spare bonuses
4. Handle frame 10 special rules
5. Add comprehensive tests for all scenarios
