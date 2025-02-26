defmodule EFE.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EFE.Documents` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        file_name: "some file_name"
      })
      |> EFE.Documents.create_document()

    document
  end
end
