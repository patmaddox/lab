---- MODULE Counter ----
EXTENDS Naturals

VARIABLE count

Init == count = 0

Next ==
    \/ /\ count < 5
       /\ count' = count + 1
    \/ /\ count = 5
       /\ UNCHANGED count
    

Inv == count <= 5
========================
