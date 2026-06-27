defmodule FinLimier.Adapters.FranceTravail.SourceTest do
  use ExUnit.Case, async: true

  alias FinLimier.Adapters.FranceTravail.Source

  defmodule SuccessClient do
    def get(url, opts) do
      send(self(), {:france_travail_request, url, opts})

      {:ok,
       %Req.Response{
         status: 200,
         body: %{
           "resultats" => [
             %{
               "id" => "123",
               "intitule" => "Elixir Developer",
               "origineOffre" => %{"urlOrigine" => "https://example.test/jobs/123"}
             }
           ]
         }
       }}
    end
  end

  defmodule ErrorClient do
    def get(_url, _opts), do: {:ok, %Req.Response{status: 503, body: %{"error" => "down"}}}
  end

  test "fetches and normalizes France Travail raw offers" do
    assert {:ok, [offer]} =
             Source.fetch_offers(
               http_client: SuccessClient,
               access_token: "token",
               query: "Elixir",
               limit: 10
             )

    assert offer.source == "france_travail"
    assert offer.source_id == "123"
    assert offer.source_url == "https://example.test/jobs/123"
    assert offer.payload["intitule"] == "Elixir Developer"

    assert_received {:france_travail_request, url, opts}
    assert url =~ "/partenaire/offresdemploi/v2/offres/search"
    assert opts[:auth] == {:bearer, "token"}
    assert opts[:params][:motsCles] == "Elixir"
    assert opts[:params][:range] == "0-9"
  end

  test "contains invalid France Travail responses" do
    assert {:error, {:france_travail_request_failed, 503, %{"error" => "down"}}} =
             Source.fetch_offers(http_client: ErrorClient, access_token: "token")
  end
end
