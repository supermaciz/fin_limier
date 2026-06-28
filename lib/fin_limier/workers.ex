defmodule FinLimier.Workers do
  @moduledoc """
  Background workers that drive application use cases.
  """

  use Boundary,
    deps: [FinLimier.UseCases],
    exports: [DiscoverJobsWorker]
end
