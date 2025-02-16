defmodule XBS do
  alias XBS.Build

  defmodule KeyNotFoundError do
    defexception [:key]

    def message(exception) do
      ":#{exception.key}"
    end
  end

  defmodule NeedsUpdateError do
    defexception [:key]

    def message(exception) do
      ":#{exception.key}"
    end
  end

  def new_build(targets) do
    Build.new(targets)
  end

  def compute(build, inputs) do
    Build.compute(build, inputs)
  end

  def update(build, inputs) do
    Build.update(build, inputs)
  end
end
