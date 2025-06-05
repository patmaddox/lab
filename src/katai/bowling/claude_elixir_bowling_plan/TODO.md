# Bowling Code Refactoring Plan

## Issues to Address

1. **Magic Numbers**: Several hardcoded numbers that should be extracted to module attributes
2. **Strange Index Numbers**: Frame indices 7 and 8 should be named constants
3. **Verbose Pattern Matches**: `determine_frame_type/2` can be simplified
4. **Redundant Checks**: Remove unnecessary pattern matches that duplicate logic

## Implementation Steps

### Step 1: Extract Magic Numbers to Module Attributes

Add module attributes to replace hardcoded values:

```elixir
@max_pins 10
@min_pins 0
@total_frames 10
@last_regular_frame_index 9
@frame_8_index 7  # 0-indexed frame 8
@frame_9_index 8  # 0-indexed frame 9
```

**Files to modify:**
- `lib/bowling.ex` - Add attributes and replace all hardcoded numbers

### Step 2: Simplify determine_frame_type/2 Pattern Matches

**Current issues:**
- Frame 10 has 8 different patterns that can be consolidated
- Regular frames have redundant logic
- Logic for detecting strikes/spares is scattered

**Proposed solution:**
- Extract helper functions: `is_strike?/1`, `is_spare?/1`
- Consolidate Frame 10 logic using these helpers
- Reduce regular frame patterns to 3 cases maximum

**Files to modify:**
- `lib/bowling.ex` - Refactor `determine_frame_type/2`

### Step 3: Remove Redundant Pattern Matches

**Current issues:**
- Line 95: `when a + b == 10` is redundant since frame is already `:spare`
- Multiple places check for strikes with `[10]` when type is already `:strike`

**Proposed solution:**
- Remove redundant guards in `calculate_frame_score/3`
- Simplify pattern matches to rely on frame type rather than recalculating

**Files to modify:**
- `lib/bowling.ex` - Clean up `calculate_frame_score/3` patterns

### Step 4: Replace Frame Index Magic Numbers

**Current issues:**
- `index == 7` and `index == 8` are confusing (frames 8 and 9)
- Comments explain the mapping but constants would be clearer

**Proposed solution:**
- Replace `index == 7` with `index == @frame_8_index`
- Replace `index == 8` with `index == @frame_9_index`
- Add clear documentation about 0-indexed frame numbering

**Files to modify:**
- `lib/bowling.ex` - Update `strike_bonus/2` and `spare_bonus/2`

### Step 5: Add Helper Functions

Create private helper functions to improve readability:

```elixir
defp is_strike?([first_roll | _]), do: first_roll == @max_pins
defp is_spare?([a, b | _]), do: a + b == @max_pins
defp is_spare?(_), do: false
```

**Files to modify:**
- `lib/bowling.ex` - Add helper functions and use them throughout

### Step 6: Run Tests and Verify

**Actions:**
- Run full test suite to ensure no regressions
- Verify all magic numbers are replaced
- Check that code is more readable and maintainable

**Files to check:**
- All tests in `test/bowling_test.exs` should pass
- Code should have no hardcoded numbers (except in module attributes)
