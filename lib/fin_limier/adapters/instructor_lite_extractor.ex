defmodule FinLimier.Adapters.InstructorLiteExtractor do
  @moduledoc """
  InstructorLite-backed extractor for raw job offer payloads.
  """

  @behaviour FinLimier.Ports.JobOfferExtractor

  alias FinLimier.Core.JobOffer

  @impl true
  def extract(raw_offer), do: extract(raw_offer, [])

  def extract(raw_offer, opts) do
    instructor = Keyword.get(opts, :instructor, InstructorLite)

    instructor.instruct(
      %{input: [%{role: "user", content: prompt(raw_offer)}]},
      response_model: JobOffer,
      adapter: Keyword.get(opts, :adapter, InstructorLite.Adapters.OpenAI),
      adapter_context: Keyword.get(opts, :adapter_context, adapter_context())
    )
  end

  defp prompt(raw_offer) do
    """
    Extract a normalized job offer from this raw source payload.

    Source: #{raw_offer.source}
    Source ID: #{raw_offer.source_id}
    Payload: #{Jason.encode!(raw_offer.payload)}
    """
  end

  defp adapter_context do
    config = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])

    case Keyword.get(config, :openai_api_key) do
      nil -> []
      api_key -> [api_key: api_key]
    end
  end
end
