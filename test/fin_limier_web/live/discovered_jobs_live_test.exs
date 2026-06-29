defmodule FinLimierWeb.DiscoveredJobsLiveTest do
  use FinLimierWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FinLimier.Persistence.DiscoveredJobOffer
  alias FinLimier.Repo

  defp insert_offer(attrs) do
    defaults = %{
      source: "france_travail",
      source_id: "offer-#{System.unique_integer([:positive])}",
      source_url: "https://candidat.francetravail.fr/offres/recherche/detail/123",
      raw_payload: %{},
      company: "Acme",
      title: "Elixir Engineer",
      remote: :hybrid,
      seniority: :senior,
      location: "Paris",
      discovered_at: ~U[2026-06-20 10:30:00Z]
    }

    %DiscoveredJobOffer{}
    |> DiscoveredJobOffer.changeset(Map.merge(defaults, attrs))
    |> Repo.insert!()
  end

  test "renders persisted discovered offers", %{conn: conn} do
    offer = insert_offer(%{})

    {:ok, view, _html} = live(conn, ~p"/jobs/discovered")

    assert has_element?(view, "#discovered-jobs-page")
    assert has_element?(view, "#discovered-jobs-list")
    assert has_element?(view, "#discovered-job-#{offer.id}")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=company]", "Acme")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=title]", "Elixir Engineer")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=remote]", "Hybrid")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=seniority]", "Senior")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=location]", "Paris")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=source]", "france_travail")
    assert has_element?(view, "#discovered-job-#{offer.id} [data-field=discovered-at]")
  end

  test "renders an empty state when no offers are persisted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/jobs/discovered")

    assert has_element?(view, "#discovered-jobs-page")
    assert has_element?(view, "#discovered-jobs-empty")
  end
end
