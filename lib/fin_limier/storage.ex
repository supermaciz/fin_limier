defmodule FinLimier.Storage do
  @moduledoc """
  Storage adapters and shared storage-facing data structures.

  Storage covers durable and volatile backends.
  """

  use Boundary,
    deps: [FinLimier.Core, FinLimier.Ports, FinLimier],
    exports: [StoredOffer, Ets.JobOfferStore, Postgres.JobOfferStore]
end
