#! /usr/bin/env elixir
#
# hello_llm.exs -- two chained calls to the Anthropic Messages API.
#
# The first call asks Claude for one non-English language per continent
# (South America, Europe, Africa, Asia).  The second call feeds those
# languages back and asks for "Hello World" in each.  The script then
# prints Hello World in English, followed by the other languages.
#
# Run with:  ANTHROPIC_API_KEY=sk-ant-... elixir hello_llm.exs
#
# We call the Messages API directly with Req rather than pulling in a
# dedicated client or an LLM framework.  There is no official Anthropic
# SDK for Elixir, the endpoint is a single POST, and Req is the small,
# focused HTTP client this calls for.  See README.md for the libraries
# considered.

Mix.install([{:req, "~> 0.5"}])

defmodule HelloLLM do
  @endpoint "https://api.anthropic.com/v1/messages"
  @version "2023-06-01"
  @model "claude-opus-4-8"

  @doc """
  Send a single user prompt to the Messages API and return the text of
  the first content block (content[0].text).
  """
  def ask(prompt, api_key) do
    body = %{
      model: @model,
      max_tokens: 1024,
      messages: [%{role: "user", content: prompt}]
    }

    case Req.post(@endpoint,
           json: body,
           headers: [
             {"x-api-key", api_key},
             {"anthropic-version", @version}
           ]
         ) do
      {:ok, %Req.Response{status: 200, body: %{"content" => [%{"text" => text} | _]}}} ->
        String.trim(text)

      {:ok, %Req.Response{status: status, body: body}} ->
        raise "Anthropic API returned #{status}: #{inspect(body)}"

      {:error, reason} ->
        raise "request to Anthropic API failed: #{inspect(reason)}"
    end
  end
end

api_key =
  System.get_env("ANTHROPIC_API_KEY") ||
    raise "ANTHROPIC_API_KEY is not set"

# First call: one non-English language per continent.
languages =
  HelloLLM.ask(
    "Excluding English, list one language spoken on each of the continents of South America, Europe, Africa, Asia.",
    api_key
  )

# Second call: greet the world in each of those languages.  (The brief
# had a typo, "prduces"; the prompt text below is otherwise verbatim.)
greetings =
  HelloLLM.ask(
    ~s(One per line, write "Hello World" in each of the following languages: #{languages}),
    api_key
  )

# English first, then the other languages.
IO.puts("Hello World")
IO.puts(greetings)
