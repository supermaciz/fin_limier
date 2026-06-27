defmodule FinLimier.Adapters.FranceTravail.Auth do
  @moduledoc """
  France Travail OAuth client credentials token handling.
  """

  @token_url "https://entreprise.francetravail.fr/connexion/oauth2/access_token?realm=/partenaire"
  @scope "api_offresdemploiv2 o2dsoffre"

  def fetch_token(opts \\ []) do
    http_client = Keyword.get(opts, :http_client, Req)
    url = Keyword.get(opts, :token_url, @token_url)

    with {:ok, client_id} <- fetch_credential(opts, :client_id, :france_travail_client_id),
         {:ok, client_secret} <-
           fetch_credential(opts, :client_secret, :france_travail_client_secret),
         {:ok, %{status: 200, body: %{"access_token" => access_token}}} <-
           http_client.post(url,
             form: %{
               grant_type: "client_credentials",
               client_id: client_id,
               client_secret: client_secret,
               scope: @scope
             }
           ) do
      {:ok, access_token}
    else
      {:ok, %{status: status, body: body}} ->
        {:error, {:france_travail_auth_failed, status, body}}

      {:error, reason} ->
        {:error, reason}

      :error ->
        {:error, :missing_france_travail_credentials}

      _ ->
        {:error, :invalid_france_travail_auth_response}
    end
  end

  defp fetch_credential(opts, opts_key, config_key) do
    config = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])

    case Keyword.get(opts, opts_key) || Keyword.get(config, config_key) do
      nil -> :error
      value -> {:ok, value}
    end
  end
end
