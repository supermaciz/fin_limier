defmodule FinLimier.Adapters.FranceTravail.AuthTest do
  use ExUnit.Case, async: false

  alias FinLimier.Adapters.FranceTravail.Auth

  defmodule SuccessClient do
    def post(url, opts) do
      send(self(), {:france_travail_token_request, url, opts})

      {:ok, %Req.Response{status: 200, body: %{"access_token" => "token", "expires_in" => 1_499}}}
    end
  end

  defmodule ErrorClient do
    def post(_url, _opts),
      do: {:ok, %Req.Response{status: 401, body: %{"error" => "invalid_client"}}}
  end

  test "fetches an OAuth access token with client credentials" do
    assert {:ok, "token"} =
             Auth.fetch_token(
               http_client: SuccessClient,
               client_id: "client",
               client_secret: "secret"
             )

    assert_received {:france_travail_token_request, url, opts}
    assert url =~ "/connexion/oauth2/access_token"
    assert opts[:form][:grant_type] == "client_credentials"
    assert opts[:form][:client_id] == "client"
    assert opts[:form][:client_secret] == "secret"
    assert opts[:form][:scope] =~ "api_offresdemploiv2"
  end

  test "fetches credentials from application runtime config" do
    put_runtime_config(
      france_travail_client_id: "runtime-client",
      france_travail_client_secret: "runtime-secret"
    )

    assert {:ok, "token"} = Auth.fetch_token(http_client: SuccessClient)

    assert_received {:france_travail_token_request, _url, opts}
    assert opts[:form][:client_id] == "runtime-client"
    assert opts[:form][:client_secret] == "runtime-secret"
  end

  test "contains token request failures" do
    assert {:error, {:france_travail_auth_failed, 401, %{"error" => "invalid_client"}}} =
             Auth.fetch_token(http_client: ErrorClient, client_id: "client", client_secret: "bad")
  end

  defp put_runtime_config(config) do
    previous = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    Application.put_env(:fin_limier, FinLimier.JobDiscovery, Keyword.merge(previous, config))

    on_exit(fn -> Application.put_env(:fin_limier, FinLimier.JobDiscovery, previous) end)
  end
end
