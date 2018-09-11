defmodule AttestationApi.RequestDataFactory do
  @moduledoc false

  import AttestationApi.Factories
  alias Ecto.UUID

  @spec data_for(atom, map) :: map
  def data_for(atom, params \\ %{})

  def data_for(:verification_digital_create_session, params) do
    %{
      "first_name" => "John",
      "last_name" => "Doe",
      "lang" => "en",
      "document_type" => "ID_CARD",
      "timestamp" => generate(:unix_timestamp),
      "contract_address" => generate(:account_address),
      "device_os" => Enum.random(["ios", "android"]),
      "device_token" => UUID.generate()
    }
    |> Map.merge(params)
  end

  def data_for(:digital_verification_upload_media, params) do
    %{
      # present in request: session_id
      "country" => "US",
      "document_type" => "ID_CARD",
      "context" => Enum.random(["face", "document-front", "document-back"]),
      "content" => "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
      "timestamp" => generate(:unix_timestamp)
    }
    |> Map.merge(params)
  end

  def data_for(:digital_verification_result_webhook, params) do
    %{
      "status" => "success",
      "verification" => %{
        "id" => "f04bdb47-d3be-4b28-b028-a652feb060b5",
        "status" => "approved",
        "code" => 9001,
        "acceptanceTime" => "2017-01-18T12:22:50.239Z",
        "person" => %{
          "firstName" => "TestName",
          "lastName" => "TestName",
          "idNumber" => "1234567890"
        },
        "document" => %{
          "number" => "B01234567",
          "type" => "PASSPORT",
          "validFrom" => "2015-11-11",
          "validUntil" => "2021-12-09"
        },
        "additionalVerifiedData" => %{
          "citizenship" => "FI",
          "residency" => "Melbourne"
        },
        "comment" => [
          %{
            "type" => "video_call_comment",
            "comment" => "Person is from Bangladesh",
            "timestamp" => "2016-05-19T08:30:25.597Z"
          }
        ]
      },
      "technicalData" => %{
        "ip" => "186.153.67.122"
      }
    }
    |> Map.merge(params)
  end

  def data_for(:digital_verification_submission_webhook, params) do
    %{
      "id" => UUID.generate(),
      "feature" => "selfid",
      "code" => 7002,
      "action" => "submitted"
    }
    |> Map.merge(params)
  end
end
