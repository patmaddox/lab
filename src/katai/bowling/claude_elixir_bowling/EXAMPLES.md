# Regular Frame (No Strike/Spare)

Input:

```
1,2
```

Output:

```
| 1 2 | # 3
```

# Frame with Miss

Input:

```
3,0
```

Output:

```
| 3 - | # 3
```

# Strike

Input:

```
10,3,4
```

Output:

```
| X | 3 4 | # 24
```

# Strike (Incomplete - Only One Ball Rolled After)

Input:

```
10,5
```

Output:

```
| X | 5 ? |
```

# Strike in Second Frame (Incomplete)

Input:

```
3,4,10,6
```

Output:

```
| 3 4 | X | 6 ? | # 7
```

# Spare

Input:

```
7,3,5,2
```

Output:

```
| 7 / | 5 2 | # 22
```

# 10th Frame - Strike with Bonus Rolls

Input:

```
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,5,3
```

Output:

```
| 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | X 5 3 | # 36
```

# 10th Frame - Spare with Bonus Roll

Input:

```
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7,3,5
```

Output:

```
| 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 1 1 | 7 / 5 | # 33
```

# Perfect Game

Input:

```
10,10,10,10,10,10,10,10,10,10,10,10
```

Output:

```
| X | X | X | X | X | X | X | X | X | X X X | # 300
```
