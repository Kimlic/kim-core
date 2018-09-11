defmodule AttestationApi.Repo.Migrations.AddDocumentTypeColumnToDigitalVerification do
  use Ecto.Migration

  def change do
    alter table(:digital_verifications) do
      add(:document_type, :string)
    end
  end
end
