defmodule FinLimier.Core do
  @moduledoc """
  Stable domain model: pure value objects and changesets.

  The core must not depend on web, adapters, persistence, use cases, or workers.
  """

  use Boundary, deps: [], exports: [JobOffer, JobApplication, Profile]
end
