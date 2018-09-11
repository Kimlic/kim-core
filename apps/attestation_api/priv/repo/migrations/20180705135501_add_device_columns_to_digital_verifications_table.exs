defmodule AttestationApi.Repo.Migrations.AddDeviceColumnsToDigitalVerificationsTable do
  use Ecto.Migration

  def change do
    alter table(:digital_verifications) do
      add(:device_os, :string)
      add(:device_token, :string)
    end
  end
end
