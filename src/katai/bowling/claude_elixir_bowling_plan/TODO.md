# Bowling Application TODO

## Implementation Tasks

- [x] 1. Replace placeholder code with core structs
  - [x] 1.1 Define Game struct
  - [x] 1.2 Define Frame struct  
  - [x] 1.3 Remove placeholder hello/0 function

- [x] 2. Implement roll recording logic
  - [x] 2.1 Implement new_game/0
  - [x] 2.2 Implement roll/2 function
  - [x] 2.3 Handle frame transitions
  - [x] 2.4 Track rolls within frames

- [x] 3. Add scoring algorithm with strike/spare bonuses
  - [x] 3.1 Calculate basic frame scores
  - [x] 3.2 Implement strike bonus calculation
  - [x] 3.3 Implement spare bonus calculation
  - [x] 3.4 Implement score/1 function

- [x] 4. Handle frame 10 special rules
  - [x] 4.1 Allow up to 3 rolls in frame 10
  - [x] 4.2 Handle strike in frame 10
  - [x] 4.3 Handle spare in frame 10

- [ ] 5. Add comprehensive tests for all scenarios
  - [ ] 5.1 Test basic open frames
  - [ ] 5.2 Test strikes
  - [ ] 5.3 Test spares
  - [ ] 5.4 Test perfect game (all strikes)
  - [ ] 5.5 Test gutter game (all zeros)
  - [ ] 5.6 Test frame 10 edge cases
  - [ ] 5.7 Test game completion detection