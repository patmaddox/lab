# Regular Frame (No Strike/Spare)

Input:

```
1,2
```

Output:

```
|1: 1 2 (3)| # 3
```

# Frame with Miss

Input:

```
3,0
```

Output:

```
|1: 3 - (3)| # 3
```

# Strike

Input:

```
10,3,4
```

Output:

```
|1: X (17)|2: 3 4 (24)| # 24
```

# Strike (Incomplete - Only One Ball Rolled After)

Input:

```
10,5
```

Output:

```
|1: X|2: 5|
```

# Strike in Second Frame (Incomplete)

Input:

```
3,4,10,6
```

Output:

```
|1: 3 4 (7)|2: X|3: 6| # 7
```

# Spare

Input:

```
7,3,5,2
```

Output:

```
|1: 7 / (15)|2: 5 2 (22)| # 22
```

# 10th Frame - Strike with Bonus Rolls

Input:

```
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,5,3
```

Output:

```
|1: 1 1 (2)|2: 1 1 (4)|3: 1 1 (6)|4: 1 1 (8)|5: 1 1 (10)|6: 1 1 (12)|7: 1 1 (14)|8: 1 1 (16)|9: 1 1 (18)|10: X 5 3 (36)| # 36
```

# 10th Frame - Spare with Bonus Roll

Input:

```
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,3,5
```

Output:

```
|1: 1 1 (2)|2: 1 1 (4)|3: 1 1 (6)|4: 1 1 (8)|5: 1 1 (10)|6: 1 1 (12)|7: 1 1 (14)|8: 1 1 (16)|9: 1 1 (18)|10: 7 / 5 (33)| # 33
```

# Perfect Game

Input:

```
10,10,10,10,10,10,10,10,10,10,10,10
```

Output:

```
|1: X (30)|2: X (60)|3: X (90)|4: X (120)|5: X (150)|6: X (180)|7: X (210)|8: X (240)|9: X (270)|10: X X X (300)| # 300
```
