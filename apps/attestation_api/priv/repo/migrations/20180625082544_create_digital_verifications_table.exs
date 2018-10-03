defmodule AttestationApi.Repo.Migrations.CreateDigitalVerificationsTable do
  use Ecto.Migration

  def change do
    create table(:digital_verifications, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:account_address, :string, null: false)
      add(:session_id, :string, null: false)
      add(:contract_address, :string)
      add(:status, :string, null: false)
      add(:veriffme_code, :integer)
      add(:veriffme_status, :string)
      add(:veriffme_reason, :string)
      add(:veriffme_comments, :json)

      timestamps()
    end
  end
end
 