# katai

An exploration of code kata using LLMs.

I will do my best to keep a record of how I use the tools.

## Bowling game kata

I did this years ago.

- https://kata-log.rocks/bowling-game-kata
- https://codingdojo.org/kata/Bowling/

Write a program to calculate the score of a bowling game.
A game is made up of ten frames, with each frame having 2 scores (1 in the case of a strike).
A game's scores are defined by a single line.
Each frame is separated by `|`.

A strike is represented by `X`, and a spare by `/`.
A missed ball is represented by '-'.
The tenth frame may have three scores, if it is a strike or a spare.

(note: double check rule on tenth frame for a strike. Do they always get two rolls?)

A strike adds the score of the next two balls to the frame.
A spare adds the score of the next ball to the frame.

Examples:

- `1 2 # => 3`
- `1 2 | 3 - # => 6`
- `X | 1 2 # => 16`
- `1 / | 1 2 # => 14`

(note: this is from memory. I can probably use an LLM to produce a summary of the rules of bowling)

## Resources

- https://codingdojo.org/kata/
- https://kata-log.rocks/
- http://codekata.com/

## Code Kata

These katas interest me just from the names and short descriptions:

- 01: Supermarket Pricing
- 04: Data Munging
- 05: Bloom Filters
- 06: Anagrams
- 08: Conflicting Objectives
- 09: Back to the Checkout
- 12: Best Sellers
- 13: Counting Code Lines
- 17: More Business Rules
- 18: Transitive Dependencies
- 19: Word Chains
- 21: Simple Lists

## Conway's Game of Life

Classic.
