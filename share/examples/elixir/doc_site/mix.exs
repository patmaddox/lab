defmodule DocSite.MixProject do
  use Mix.Project

  def project do
    [
      app: :doc_site,
      version: "20250320.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "My Documentation",
      docs: [
        main: "home",
        api_reference: false,
        extras: [
          "docs/home.md",
          "livebook/test.md",
          "livebook/test2.md"
        ],
        filter_modules: fn _, _ -> false end
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37", only: :dev, runtime: false}
    ]
  end
end
