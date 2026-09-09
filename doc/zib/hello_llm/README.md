# hello_llm

A two-call Anthropic Messages API demo in Elixir. `hello_llm.exs` asks
Claude for one non-English language per continent, then feeds those
languages back to ask for "Hello World" in each, and prints the result.

    ANTHROPIC_API_KEY=sk-ant-... elixir hello_llm.exs

## Library choice: call the API directly with Req

There is no official Anthropic SDK for Elixir (Anthropic ships Python,
TypeScript, Java, Go, Ruby, C#, and PHP). The Messages API is a single
endpoint -- `POST https://api.anthropic.com/v1/messages` with `x-api-key`
and `anthropic-version: 2023-06-01` headers -- so a thin `Req` call is
both the smallest and the most transparent option. Req is mature and the
de-facto HTTP client in the modern Elixir ecosystem; it decodes the JSON
response, so pulling `content[0].text` is a one-liner. One dependency,
no framework lock-in, the whole request visible in the source. This
matches the Req-style minimalism the task called for.

### Considered and not used

- **Anthropix** (dedicated Anthropic client: tool use, extended
  thinking, prompt caching, batching, streaming). The strongest
  purpose-built option and the right pick the moment streaming or
  caching is needed. For two plain message calls it adds a dependency
  and an abstraction over a trivial JSON shape.
- **Elixir LangChain** (`LangChain.ChatModels.ChatAnthropic`). A full
  LangChain-style framework -- chains, message structs, tool
  orchestration. Capable, but far too much surface for a two-call
  script. Reach for it when building a multi-step agent.
- **Instructor / InstructorLite** (Req-based, Anthropic adapter).
  Purpose-built for *structured* outputs -- Ecto schemas, validation,
  retries -- which this does not need; the task wants free text then
  plaintext lines.
- **req_llm** (Req plugins, many providers). A multi-provider
  abstraction; useful to swap providers, but more indirection than a
  direct Req call for one known endpoint.

Model: `claude-opus-4-8`. Swap `@model` for `claude-sonnet-5` for a
cheaper/faster run; the request shape is identical.
