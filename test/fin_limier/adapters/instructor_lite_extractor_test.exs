defmodule FinLimier.Adapters.InstructorLiteExtractorTest do
  use ExUnit.Case, async: false

  alias FinLimier.Adapters.InstructorLiteExtractor
  alias FinLimier.Core.JobOffer

  defmodule SuccessInstructor do
    def instruct(params, opts) do
      send(self(), {:instructor_request, params, opts})

      {:ok,
       %JobOffer{
         company: "Acme",
         title: "Elixir Developer",
         stack: ["Elixir"],
         remote: :hybrid,
         seniority: :senior,
         location: "Paris",
         salary: "60k"
       }}
    end
  end

  defmodule ErrorInstructor do
    def instruct(_params, _opts), do: {:error, :invalid_response}
  end

  test "extracts a normalized job offer with instructor_lite" do
    raw_offer = %{
      source: "france_travail",
      source_id: "123",
      payload: %{"intitule" => "Elixir Developer", "description" => "Build Phoenix apps"}
    }

    assert {:ok, %JobOffer{} = offer} =
             InstructorLiteExtractor.extract(raw_offer, instructor: SuccessInstructor)

    assert offer.company == "Acme"
    assert offer.remote == :hybrid

    assert_received {:instructor_request, params, opts}
    assert [%{role: "user", content: content}] = params.input
    assert content =~ "Elixir Developer"
    assert opts[:response_model] == JobOffer
    assert opts[:adapter] == InstructorLite.Adapters.OpenAI
  end

  test "uses adapter context from application runtime config" do
    put_runtime_config(openai_api_key: "runtime-key")

    raw_offer = %{source: "france_travail", source_id: "123", payload: %{}}

    assert {:ok, %JobOffer{}} =
             InstructorLiteExtractor.extract(raw_offer, instructor: SuccessInstructor)

    assert_received {:instructor_request, _params, opts}
    assert opts[:adapter_context] == [api_key: "runtime-key"]
  end

  test "contains instructor_lite extraction failures" do
    raw_offer = %{source: "france_travail", source_id: "123", payload: %{}}

    assert {:error, :invalid_response} =
             InstructorLiteExtractor.extract(raw_offer, instructor: ErrorInstructor)
  end

  defp put_runtime_config(config) do
    previous = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    Application.put_env(:fin_limier, FinLimier.JobDiscovery, Keyword.merge(previous, config))

    on_exit(fn -> Application.put_env(:fin_limier, FinLimier.JobDiscovery, previous) end)
  end
end
