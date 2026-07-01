defmodule FinLimier.UseCases do
  @moduledoc """
  Application workflows orchestrating ports, core, and storage.

  Use cases may depend on core, ports, and storage contracts. They call ports
  through behaviours so the concrete adapters stay swappable.
  """

  use Boundary,
    deps: [FinLimier.Core, FinLimier.Ports, FinLimier.Storage],
    exports: [DiscoverJobs, ListDiscoveredJobs]
end
