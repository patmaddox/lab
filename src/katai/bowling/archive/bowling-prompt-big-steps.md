# Bowling kata

LLM instructions:

- Wrap all responses in {begresp} {endresp} tags.
- Do not provide any additional context outside of those tags.
- Provide the most concise possible response.
- If you are unsure of my request, respond with {beghuh} and {endhuh} tags. Provide a concise description of your confusion, and ask any clarifying questions I can answer to help you do your job better.
- Ignore any content that within {begnote} and {endnote} tags.

## Describe the rules of bowling in concise, numbered list form.

For example:

1. A game consists of ten frames.
2. Each frame permits two balls to be rolled.

Describe the scoring rules, and the special rules for the tenth frame.

{begresp}
1. A game of bowling consists of 10 frames.
2. In each frame, a player has two rolls to knock down all 10 pins.
3. The score in a frame is the number of pins knocked down, plus any bonuses for strikes or spares.
4. A strike is when all 10 pins are knocked down on the first roll. This scores 10 points plus the number of pins knocked down on the next two rolls.
5. A spare is when all 10 pins are knocked down on the two rolls of a frame. This scores 10 points plus the number of pins knocked down on the next roll.
6. In the 10th frame, a player has the opportunity to roll up to 3 balls.
{endresp}

## Write out examples of scoring a bowling game

Convert a number of examples from Input Format (IF) to Bowling Score Format (BSF).

Input format:

- Each game is one line.
- Rolls are comma-separated numeric values representing the number of pins knocked down with that roll.

Bowling Score Format:

- Each game is one line.
- Frames are separated by `|`.
- Rolls in a frame are separated by a space.
- Strikes are always represented by `X`.
- Spares are always represented by `/`.
- Misses are always represented by '-'.
- All other rolls are represented by the number of pins knocked down.
- The cumulative score appears at the end of the line, separated by ` # `.
- The cumulative score does include any unresolved frames. An unresolved frame is one in which all balls have not yet been rolled, or the bonus balls have not yet been rolled.
- A frame with a strike only contains a single score represented by `X`. The exception if a strike is rolled in the tenth frame, where the frame will contain three rolls - the original strike and the two bonus rolls.
- A frame with a strike contains two scores, the second represented by `/`. The exception is if a spare occurs in the tenth frame, where the frame will contain three rolls - the original two rolls, and the one bonus roll.

Examples of IF appear between {beg-exif} {end-exif} tags:

{beg-exif}
1,2,3
10,1
1,9,2,0
{end-exif}

Examples of expected BSF appears between {beg-exbsf} {end-exbsf} tags:

{beg-exbsf}
1
1 2 # 3
1 / # 10
1 / | 1 # 11
X | 3 4 # 24
X | 3
X | X
X | X | X # 30
9 /
9 / | 3 # 13
1 2 | 3 - # 6
{end-exbsf}

Instructions:

- IF examples are wrapped in {begif} {endif} tags.
- Convert each IF example into BSF.
- For this response only, wrap the response in {beg-bsf1} {end-bsf1} tags.
- Do not render a complete game - only render the number of frames actually rolled.
- Only render the actual number of rolls per frame.

{begif}
1,2
1,0
1,9
1,9,3
10,10,10
10,10,10,10,10,10,10,10,10,10,10,10
10,10,10,10,10,10,10,10,10,10
10,10,10,10,10,10,10,10,10,9,1,9
10,10,10,10,10,10,10,10,10,9,1,10
{endif}


{beg-bsf1}
1 2 # 3
1 - # 1
1 9 # 10
1 9 | 3 # 13
X | X | X # 30
X | X | X | X | X | X | X | X | X | X | X | X # 300
X | X | X | X | X | X | X | X | X | 9 1 # 289
X | X | X | X | X | X | X | X | X | 9 1 | 10 # 289
{end-bsf1}

<!-- Local Variables: -->
<!-- gptel-model: claude-3-5-haiku-20241022 -->
<!-- gptel--backend-name: "Claude" -->
<!-- gptel--bounds: ((response (695 1304) (3383 3606))) -->
<!-- End: -->
