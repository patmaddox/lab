defmodule EFE.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :file_name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
