---
description: >-
  Post a concise notification via ntfy.sh. Use this skill when the user
  asks to be notified, says "notify me", "ping me", "send a
  notification", or "let me know". Also invoke proactively at the end
  of any long-running task - the user should not have to ask.
user-invocable: true
allowed-tools: Read, Bash
---

# notify-me

Send a push notification via ntfy.sh.

## Process

1. Read `~/.ntfy.sh` to get the current topic URL (first line).
2. Compose the notification yourself. `$ARGUMENTS` is a prompt
   describing what to notify about, not a literal message. Distill
   it into a clear, concise notification in your own words. When
   invoked proactively, compose from the context of the work just
   completed.
3. Post with `curl` using headers appropriate to the occasion:

```
curl -s \
  -H "Title: <title>" \
  -H "Priority: <1-5>" \
  -H "Tags: <emoji-shortcodes>" \
  -d "<message body>" \
  "<url from ~/.ntfy.sh>"
```

## Choosing headers

Match the notification style to what happened:

| Occasion            | Priority | Tags              | Example title         |
|---------------------|----------|-------------------|-----------------------|
| Task complete       | 3        | white_check_mark  | Task complete         |
| Build/test passed   | 3        | green_circle      | Tests passed          |
| Build/test failed   | 4        | red_circle         | Build failed          |
| Error or problem    | 4        | warning           | Action needed         |
| Urgent/blocking     | 5        | rotating_light    | Urgent                |
| FYI / low priority  | 2        | information_source | FYI                   |
| Deployed            | 3        | rocket            | Deployed              |

- **Title**: short, specific to the event (not generic).
- **Priority**: 1=min, 5=max. Default to 3. Reserve 5 for genuinely
  urgent items.
- **Tags**: use ntfy emoji shortcodes. Pick 1-2 that fit.
- **Body**: 1-3 concise lines. Say what happened and any next step.
  No fluff.

## Rules

- Always read `~/.ntfy.sh` fresh each time - never hardcode the URL.
- Keep the total message under 200 characters when possible.
- Do not include sensitive data (passwords, tokens, keys) in the
  notification.
