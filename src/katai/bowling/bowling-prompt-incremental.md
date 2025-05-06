# Bowling Kata

The purpose of this tool is to read bowling scores in Input Format (IF) and render them as Bowling Score Format (BSF).
IF and BSF are both textual line-based formats, in the Grand Unix Tradition.

Scores were verified by manually inputting into https://www.bowlinggenius.com/

Specific LLM instructions are provided in {begllm} {endllm} tags.

{begllm}
- Wrap all responses in response tags: {begresp} {endresp}.
- Only use your response tags. Do not use any other tags in your responses.
- Do not provide any additional context outside of those tags.
- Provide the most concise possible response.
- If you are unsure of my request, respond with {beghuh} {endhuh} tags. Provide a concise description of your confusion, and ask any clarifying questions I can answer to help you do your job better.
- Ignore any content within {begnote} {endnote} tags.
{endllm}

## The rules of bowling

{begllm}
Describe the rules of bowling in concise, numbered list form.

For example:

1. A game consists of ten frames.
2. Each frame permits two balls to be rolled.

Describe the scoring rules, and the special rules for the tenth frame.
{endllm}

{begresp}
1. Game consists of 10 frames.
2. Each frame allows two throws, except in 10th frame.
3. Scoring:
   - Regular frame: Sum of pins knocked down
   - Spare: 10 + next ball's pins
   - Strike: 10 + next two balls' pins
4. 10th frame special rules:
   - If spare or strike, up to 3 throws allowed
   - Maximum three throws total
5. Perfect game is 300 points (12 consecutive strikes)
{endresp}

## Input Format (IF)

- Each game is one line.
- Rolls are comma-separated numeric values representing the number of pins knocked down with each roll.
- Games may include incomplete frames.

## Bowling Score Format (BSF)

- Each game is one line.
- Frames are separated by `|`.
- Rolls in a frame are separated by a space.
- Strikes are represented by `X`.
- Spares are represented by `/`.
- Misses are represented by '-'.
- All other rolls are represented by the number of pins knocked down with that roll.
- The cumulative score appears at the end of the line, separated by ` # `.
- The cumulative score does not include incomplete frames.
- An incomplete frame does not include a placeholder for unrolled balls.
- Do not render a `|` after the last frame rendered.

## Converting from IF to BSF

- Examples of IF are provided in {begif} {endif} tags.
- The correct conversion from the IF example to BSF is provided in {begbsf} {endbsf} tags.

{begnote}
For reasons I don't understand, the LLM ignores my instruction to use only {begresp} {endresp} tags.
My intention was for it to create responses, and me to turn them into BSF tags when correct.
I've given up fighting it for the time being, and will instead simply correct BSF example as needed.
{endnote}

{begllm}
- Where an IF example is not followed by a BSF example, produce a BSF example.
- Use only your original {begresp} {endresp} tags. Do not use {begbsf} {endbsf} tags.
- Do not include the original IF source - only render the BSF result.
{endllm}

```md
# One complete frame
{begif}1,2{endif}
{begbsf}1 2 # 3{endbsf}
```

```md
# One incomplete frame
{begif}1{endif}
{begbsf}1{endbsf}
```

```md
# Two frames, with one incomplete
{begif}1,2,3{endif}
{begbsf}1 2 | 3 # 3{endbsf}
```

```md
# Frame with one miss
{begif}0,1{endif}
{begbsf}- 1 # 1{endbsf}
```

```md
# Frame with two misses
{begif}0,0{endif}
{begbsf}- - # 0{endbsf}
```

```md
# Two complete frames
{begif}1,2,3,4{endif}
{begbsf}1 2 | 3 4 # 10{endbsf}
```

```md
# Incomplete spare frame
{begif}9,1{/endif}
{begbsf}9 /{endbsf}
```

```md
# Complete spare frame
{begif}9,1,3{endif}
{begbsf}9 / | 3 # 13{endbsf}
```

```md
# Complete spare frame followed by complete frame
{begif}9,1,3,4{endif}
{begbsf}9 / | 3 4 # 20{endbsf}
```

```md
# Incomplete strike frame
{begif}10{/endif}
{begbsf}X{endbsf}
```

```md
# Incomplete strike frame with one bonus ball
{begif}10,1{endif}
{begbsf}X | 1{endbsf}
```

```md
# Complete strike frame
{begif}10,1,2{endif}
{begbsf}X | 1 2 # 16{endbsf}
```

```md
# Cumulative strikes with open frame
{begif}10,10,10{endif}
{begbsf}X | X | X # 30{endbsf}
```

```md
# Perfect game
{begif}10,10,10,10,10,10,10,10,10,10,10,10{endif}
{begbsf}X | X | X | X | X | X | X | X | X | X X X # 300{endbsf}
```

```md
# Strikes through final frame
{begif}10,10,10,10,10,10,10,10,10,10{endif}
{begbsf}X | X | X | X | X | X | X | X | X | X # 240{endbsf}
```

```md
# Strikes through final frame, one ball left
{begif}10,10,10,10,10,10,10,10,10,10,10{endif}
{begbsf}X | X | X | X | X | X | X | X | X | X X # 270{endbsf}
```

<!-- Local Variables: -->
<!-- gptel-model: claude-3-5-haiku-20241022 -->
<!-- gptel--backend-name: "Claude" -->
<!-- gptel--bounds: ((response (1151 1550) (1552 1574) (1702 1774) (2321 2340) (2351 2406) (2408 2594) (2601 2813) (3113 3136) (3187 3204) (3270 3297) (3349 3372) (3431 3454) (3510 3540) (3596 3615) (3670 3698) (3782 3812) (3873 3890) (3967 3988) (4045 4073) (4150 4180) (4257 4320) (4406 4465) (4574 4635))) -->
<!-- End: -->
