defmodule FinLimier.Ports.JobSource do
  @moduledoc """
  Port for fetching raw job offers from an external source.

  An adapter returns opaque raw offers along with the source identity needed
  to deduplicate them. The use case does not interpret the raw payload.
  """

  @type raw_offer :: %{
          required(:source) => String.t(),
          required(:source_id) => String.t(),
          optional(:source_url) => String.t() | nil,
          required(:payload) => map()
        }

  @callback fetch_offers(opts :: keyword()) :: {:ok, [raw_offer()]} | {:error, term()}
end
