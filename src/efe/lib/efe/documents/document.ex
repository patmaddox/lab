defmodule EFE.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :file_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:file_name])
    |> validate_required([:file_name])
  end
end
