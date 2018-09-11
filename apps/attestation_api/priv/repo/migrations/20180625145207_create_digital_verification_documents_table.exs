defmodule AttestationApi.Repo.Migrations.CreateDigitalVerificationDocumentsTable do
  use Ecto.Migration

  def change do
    create table(:digital_verification_documents, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:verification_id, references(:digital_verifications, type: :uuid))
      add(:context, :string, null: false)
      add(:content, :text, null: false)
      add(:timestamp, :bigint, null: false)
    end

    create(unique_index(:digital_verification_documents, [:verification_id, :context]))
  end
end
