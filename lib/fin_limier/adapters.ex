defmodule FinLimier.Adapters do
  @moduledoc """
  Concrete implementations of the ports, wired through configuration.

  Adapters may depend on ports, core types, and external libraries. Adapter
  internals (such as OAuth token handling) stay private to this boundary.
  """

  use Boundary,
    deps: [FinLimier.Core, FinLimier.Ports],
    exports: [FranceTravail.Source, InstructorLiteExtractor]
end
