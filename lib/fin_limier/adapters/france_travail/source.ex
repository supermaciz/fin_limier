defmodule FinLimier.Adapters.FranceTravail.Source do
  @moduledoc """
  France Travail implementation of the job source port.
  """

  @behaviour FinLimier.Ports.JobSource

  @base_url "https://api.francetravail.io/partenaire/offresdemploi/v2/offres/search"
  @source "france_travail"

  alias FinLimier.Adapters.FranceTravail.Auth

  @impl true
  def fetch_offers(opts \\ []) do
    http_client = Keyword.get(opts, :http_client, Req)
    url = Keyword.get(opts, :url, @base_url)

    query =
      Keyword.get(
        opts,
        :query,
        Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])[:france_travail_query] ||
          "Elixir"
      )

    limit = Keyword.get(opts, :limit, 50)

    with {:ok, access_token} <- fetch_access_token(opts),
         {:ok, %{status: 200, body: %{"resultats" => results}}} when is_list(results) <-
           http_client.get(url,
             auth: {:bearer, access_token},
             params: %{motsCles: query, range: "0-#{limit - 1}"}
           ) do
      {:ok, Enum.map(results, &to_raw_offer/1)}
    else
      {:ok, %{status: status, body: body}} ->
        {:error, {:france_travail_request_failed, status, body}}

      {:error, reason} ->
        {:error, reason}

      _ ->
        {:error, :invalid_france_travail_response}
    end
  end

  defp fetch_access_token(opts) do
    case Keyword.fetch(opts, :access_token) do
      {:ok, access_token} -> {:ok, access_token}
      :error -> Auth.fetch_token(opts)
    end
  end

  defp to_raw_offer(%{"id" => source_id} = payload) do
    %{
      source: @source,
      source_id: to_string(source_id),
      source_url: get_in(payload, ["origineOffre", "urlOrigine"]),
      payload: payload
    }
  end
end
