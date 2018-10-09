defmodule AttestationApi.Repo.Migrations.RemoveVeriffComments do
  use Ecto.Migration

  def change do
    alter table :digital_verifications do
      remove :veriffme_comments
    end
  end
end
