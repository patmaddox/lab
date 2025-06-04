# Input Format (IF)

- Each game is one line.
- Rolls are comma-separated numeric values representing the number of pins knocked down with that roll.

# Bowling Score Format (BSF)

- Each game is one line.
- Frames are separated by `|`. A game always has a leading and trailing `|`.
- Each frame includes its frame number followed by a colon, then the rolls.
- Rolls in a frame are separated by a space.
- Strikes are represented by `X`.
- Spares are represented by `/`.
- Misses are always represented by '-'.
- All other rolls are represented by the number of pins knocked down.
- An unrolled ball is represented by `?`.
- All 10th frame bonus balls are included within the 10th frame.
- The cumulative score appears at the end of the line, separated by ` # `.
- The cumulative score does not include any unresolved frames. An unresolved frame is one in which all balls have not yet been rolled, or the bonus balls have not yet been rolled.
- If the cumulative score cannot be calculated yet, do not include the ` # `.
