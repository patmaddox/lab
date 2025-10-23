# PostgreSQL

## High Availability

- Do's and Dont's of High Availability [1](https://www.enterprisedb.com/blog/the-dos-donts-postgres-high-availability-part1) [2](https://www.enterprisedb.com/blog/dos-donts-postgres-high-availability-pt-two) [3](https://mktgsite.enterprisedb.com/blog/dos-donts-postgres-high-availability-pt-3-tools-rules)

## connection pooling tools

- https://github.com/agroal/pgagroal
- https://github.com/aws/pgactive
- https://github.com/CrunchyData/crunchy-proxy
- https://github.com/postgresml/pgcat
- https://github.com/yandex/odyssey
- https://pgpool.net

## supabase supavisor

- https://github.com/supabase/supavisor
- https://supabase.com/blog/supavisor-postgres-connection-pooler
- https://elixirmerge.com/p/supavisor-a-postgres-connection-pooler-for-huge-scale

## notes from author of postgres high availability cookbook

https://www.reddit.com/r/PostgreSQL/comments/122p5am/can_someone_share_experience_configuring_highly/jds555v/

**recommendations**

- cloud: CloudNativePG - kube operator manages everything
- general purpose: patroni. Set up etc, haproxy, patroni, postgres and it manages itself
- simplified, probably okay: pg_auto_failover. Needs a witness node. Good docs, much simpler than patroni.
- multi-master: edb postgres distributed. Commercial, the only option

**avoid**

- pgcluster: dead
- pgpool-ii: used for read/write load balancing, not HA. Not great for failover
- bucardo: trigger-based replication, deprecated after postgres logical replication
- repmgr: legacy
