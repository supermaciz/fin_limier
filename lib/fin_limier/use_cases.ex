defmodule FinLimier.UseCases do
  @moduledoc """
  Application workflows orchestrating ports, core, and persistence.

  Use cases may depend on core, ports, persistence, and the Repo. They call
  ports through behaviours so the concrete adapters stay swappable.
  """

  use Boundary,
    deps: [FinLimier.Core, FinLimier.Ports, FinLimier.Persistence, FinLimier],
    exports: [DiscoverJobs, ListDiscoveredJobs]
end
