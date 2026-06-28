defmodule FinLimier.Persistence do
  @moduledoc """
  Ecto schemas for stored records.

  Persistence may depend on the core domain model and Ecto.
  """

  use Boundary, deps: [FinLimier.Core], exports: [DiscoveredJobOffer]
end
