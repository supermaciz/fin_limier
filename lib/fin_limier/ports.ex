defmodule FinLimier.Ports do
  @moduledoc """
  Behaviours describing the unstable I/O the use cases depend on.

  Ports may depend on the core domain model only.
  """

  use Boundary,
    deps: [FinLimier.Core],
    exports: [JobSource, JobOfferExtractor, JobOfferStore]
end
