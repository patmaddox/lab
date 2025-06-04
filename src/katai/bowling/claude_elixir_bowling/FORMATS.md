# Input Format (IF)

- Each game is one line.
- Rolls are comma-separated numeric values representing the number of pins knocked down with that roll.

# Bowling Score Format (BSF)

- Each game is one line.
- Frames are separated by `|`.
- Rolls in a frame are separated by a space.
- Strikes are represented by `X`.
- Spares are represented by `/`.
- Misses are always represented by '-'.
- All other rolls are represented by the number of pins knocked down.
- The cumulative score appears at the end of the line, separated by ` # `.
- The cumulative score does not include any unresolved frames. An unresolved frame is one in which all balls have not yet been rolled, or the bonus balls have not yet been rolled.

Examples:

```
| 3 6 |
| 9 / |
| X | X |
```
