---- MODULE PatchTracking ----
CONSTANTS new, review, waiting, applied, dropped

VARIABLES state

States == {new, review, waiting, applied, dropped}

IsDone == state \in {applied, dropped}

Init == state = new

Done == IsDone /\ UNCHANGED state

Review == state = new /\ state' = review

Apply == state = review /\ state' = applied

Revise == state = review /\ state' = waiting

Drop == state \in {new, review, waiting}
    /\ state' = dropped

Reopen == state = dropped /\ state' = new

Next == Review \/ Apply \/ Revise \/ Drop \/ Reopen \/ Done

Spec == Init /\ [][Next]_state /\ WF_state(Next)

TypeOK == state \in States

NoAppliedEscape == [](state = applied => [](state = applied))

EventuallyDone == <>(IsDone)

====
