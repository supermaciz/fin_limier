defmodule FinLimier.Ports.JobOfferExtractor do
  @moduledoc """
  Port for parsing a raw offer payload into a normalized `FinLimier.Core.JobOffer`.
  """

  alias FinLimier.Core.JobOffer
  alias FinLimier.Ports.JobSource

  @callback extract(raw_offer :: JobSource.raw_offer()) ::
              {:ok, JobOffer.t() | %JobOffer{}} | {:error, term()}
end
