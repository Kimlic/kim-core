defmodule AttestationApi.Repo.Migrations.AddPersonDocumentToDigitalVerification do
  use Ecto.Migration

  def change do
    alter table :digital_verifications do
      add :veriffme_document, :jsonb
      add :veriffme_person, :jsonb
    end
  end
end
