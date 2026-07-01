defmodule FinLimier.Ports.JobOfferStore do
  @moduledoc """
  Storage boundary for discovered job offers.

  Adapters own backend-specific duplicate handling and return
  `FinLimier.Storage.StoredOffer` values to callers.
  """

  alias FinLimier.Core.JobOffer

  @type raw_offer :: %{
          required(:source) => String.t(),
          required(:source_id) => String.t(),
          optional(:source_url) => String.t() | nil,
          optional(:payload) => map()
        }

  @callback insert_new(raw_offer(), JobOffer.t()) ::
              {:ok, term()} | {:error, :duplicate} | {:error, term()}

  @callback list_discovered(keyword()) :: [StoredOffer.t()]
end
