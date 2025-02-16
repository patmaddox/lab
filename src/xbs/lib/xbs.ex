defmodule XBS do
  alias XBS.Build

  defmodule KeyNotFoundError do
    defexception [:key]

    def message(exception) do
      ":#{exception.key}"
    end
  end

  def new_build(tasks) do
    Build.new(tasks)
  end

  def update(build, inputs) do
    Build.update(build, inputs)
  end
end
