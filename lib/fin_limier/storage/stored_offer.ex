defmodule FinLimier.Storage.StoredOffer do
  @moduledoc """
  Canonical discovered offer shape returned by storage adapters.
  """

  alias FinLimier.Core.JobOffer

  @type t :: %__MODULE__{
          id: term(),
          source: String.t() | nil,
          source_id: String.t() | nil,
          source_url: String.t() | nil,
          company: String.t() | nil,
          title: String.t() | nil,
          stack: [String.t()],
          remote: JobOffer.remote_mode(),
          seniority: JobOffer.seniority(),
          location: String.t() | nil,
          salary: String.t() | nil,
          raw_payload: map(),
          discovered_at: DateTime.t() | nil
        }

  defstruct [
    :id,
    :source,
    :source_id,
    :source_url,
    :company,
    :title,
    :location,
    :salary,
    :discovered_at,
    stack: [],
    remote: :unknown,
    seniority: :unknown,
    raw_payload: %{}
  ]
end
