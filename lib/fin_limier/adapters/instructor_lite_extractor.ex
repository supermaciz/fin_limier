defmodule FinLimier.Adapters.InstructorLiteExtractor do
  @moduledoc """
  InstructorLite-backed extractor for raw job offer payloads.
  """

  @behaviour FinLimier.Ports.JobOfferExtractor

  alias FinLimier.Adapters.InstructorLite.JobOfferInstruction
  alias FinLimier.Core.JobOffer

  @impl true
  def extract(raw_offer), do: extract(raw_offer, [])

  def extract(raw_offer, opts) do
    instructor = Keyword.get(opts, :instructor, InstructorLite)

    result =
      instructor.instruct(
        %{input: [%{role: "user", content: prompt(raw_offer)}]},
        response_model: JobOfferInstruction,
        adapter: Keyword.get(opts, :adapter, InstructorLite.Adapters.OpenAI),
        adapter_context: Keyword.get(opts, :adapter_context, adapter_context()),
        max_retries: Keyword.get(opts, :max_retries, runtime_max_retries())
      )

    with {:ok, %JobOfferInstruction{} = instruction} <- result do
      {:ok, to_core(instruction)}
    end
  end

  defp to_core(%JobOfferInstruction{} = instruction) do
    %JobOffer{
      company: instruction.company,
      title: instruction.title,
      stack: instruction.stack,
      remote: instruction.remote,
      seniority: instruction.seniority,
      location: instruction.location,
      salary: instruction.salary
    }
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

  defp runtime_max_retries do
    Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    |> Keyword.get(:max_retries, 0)
  end
end
