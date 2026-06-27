defmodule FinLimier.Adapters.FranceTravail.AuthTest do
  use ExUnit.Case, async: false

  alias FinLimier.Adapters.FranceTravail.Auth

  test "fetches an OAuth access token with client credentials" do
    Req.Test.stub(Auth, fn conn ->
      assert conn.request_path == "/connexion/oauth2/access_token"

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      params = URI.decode_query(body)

      assert params["grant_type"] == "client_credentials"
      assert params["client_id"] == "client"
      assert params["client_secret"] == "secret"
      assert params["scope"] =~ "api_offresdemploiv2"

      Req.Test.json(conn, %{"access_token" => "token", "expires_in" => 1_499})
    end)

    assert {:ok, "token"} =
             Auth.fetch_token(
               client_id: "client",
               client_secret: "secret",
               req_options: [plug: {Req.Test, Auth}]
             )
  end

  test "fetches credentials from application runtime config" do
    put_runtime_config(
      france_travail_client_id: "runtime-client",
      france_travail_client_secret: "runtime-secret"
    )

    Req.Test.stub(Auth, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      params = URI.decode_query(body)

      assert params["client_id"] == "runtime-client"
      assert params["client_secret"] == "runtime-secret"

      Req.Test.json(conn, %{"access_token" => "token", "expires_in" => 1_499})
    end)

    assert {:ok, "token"} = Auth.fetch_token(req_options: [plug: {Req.Test, Auth}])
  end

  test "contains token request failures" do
    Req.Test.stub(Auth, fn conn ->
      conn
      |> Plug.Conn.put_status(401)
      |> Req.Test.json(%{"error" => "invalid_client"})
    end)

    assert {:error, {:france_travail_auth_failed, 401, %{"error" => "invalid_client"}}} =
             Auth.fetch_token(
               client_id: "client",
               client_secret: "bad",
               req_options: [plug: {Req.Test, Auth}, retry: false]
             )
  end

  defp put_runtime_config(config) do
    previous = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    Application.put_env(:fin_limier, FinLimier.JobDiscovery, Keyword.merge(previous, config))

    on_exit(fn -> Application.put_env(:fin_limier, FinLimier.JobDiscovery, previous) end)
  end
end
