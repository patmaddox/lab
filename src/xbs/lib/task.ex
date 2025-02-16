defmodule XBS.Task do
  def get(store, key) do
    XBS.Store.get(store, key)
  end
end
