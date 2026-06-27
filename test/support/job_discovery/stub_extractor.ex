defmodule FinLimier.JobDiscovery.StubExtractor do
  @moduledoc """
  Deterministic extractor used by tests only. Parses raw offer payloads that
  already follow the normalized JobOffer shape: payload fields are returned
  as-is. Pass `payload: %{"_fail" => reason}` to simulate parsing failure.
  """

  @behaviour FinLimier.Ports.JobOfferExtractor

  alias FinLimier.Core.JobOffer

  @impl true
  def extract(%{payload: %{"_fail" => reason}}), do: {:error, reason}

  def extract(%{payload: payload}) when is_map(payload) do
    case JobOffer.changeset(%JobOffer{}, payload) |> Ecto.Changeset.apply_action(:insert) do
      {:ok, offer} -> {:ok, offer}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
