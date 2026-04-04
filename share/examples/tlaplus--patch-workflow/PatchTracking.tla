---- MODULE PatchTracking ----
VARIABLES state

States == {"new", "in-review", "waiting", "applied", "dropped"}
IsDone == state \in {"applied", "dropped"}

Init == state = "new"

Done == IsDone /\ UNCHANGED state

Review == state = "new" /\ state' = "in-review"

Apply == state = "in-review" /\ state' = "applied"

Revise == state = "in-review" /\ state' = "waiting"

Drop == state \in {"new", "in-review", "waiting"}
    /\ state' = "dropped"

Reopen == state = "dropped" /\ state' = "new"

Next == Review \/ Apply \/ Revise \/ Drop \/ Reopen \/ Done

Spec == Init /\ [][Next]_state /\ WF_state(Next)

TypeOK == state \in States

EventuallyDone == <>(IsDone)

====
