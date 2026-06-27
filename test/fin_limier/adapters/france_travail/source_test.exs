defmodule FinLimier.Adapters.FranceTravail.SourceTest do
  use ExUnit.Case, async: true

  alias FinLimier.Adapters.FranceTravail.Source

  test "fetches and normalizes France Travail raw offers" do
    Req.Test.stub(Source, fn conn ->
      assert conn.request_path == "/partenaire/offresdemploi/v2/offres/search"
      assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer token"]
      assert conn.query_params["motsCles"] == "Elixir"
      assert conn.query_params["range"] == "0-9"

      Req.Test.json(conn, %{
        "resultats" => [
          %{
            "id" => "123",
            "intitule" => "Elixir Developer",
            "origineOffre" => %{"urlOrigine" => "https://example.test/jobs/123"}
          }
        ]
      })
    end)

    assert {:ok, [offer]} =
             Source.fetch_offers(
               access_token: "token",
               query: "Elixir",
               limit: 10,
               req_options: [plug: {Req.Test, Source}]
             )

    assert offer.source == "france_travail"
    assert offer.source_id == "123"
    assert offer.source_url == "https://example.test/jobs/123"
    assert offer.payload["intitule"] == "Elixir Developer"
  end

  test "contains invalid France Travail responses" do
    Req.Test.stub(Source, fn conn ->
      conn
      |> Plug.Conn.put_status(503)
      |> Req.Test.json(%{"error" => "down"})
    end)

    assert {:error, {:france_travail_request_failed, 503, %{"error" => "down"}}} =
             Source.fetch_offers(
               access_token: "token",
               req_options: [plug: {Req.Test, Source}, retry: false]
             )
  end
end
