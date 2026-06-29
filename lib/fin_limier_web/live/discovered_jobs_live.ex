defmodule FinLimierWeb.DiscoveredJobsLive do
  use FinLimierWeb, :live_view

  alias FinLimier.UseCases.ListDiscoveredJobs

  @impl true
  def mount(_params, _session, socket) do
    offers = ListDiscoveredJobs.run()

    {:ok,
     socket
     |> assign(:offers_empty?, offers == [])
     |> stream(:offers, offers, dom_id: &"discovered-job-#{&1.id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section id="discovered-jobs-page" class="space-y-8">
        <div class="space-y-3">
          <p class="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">
            Job discovery
          </p>
          <div class="space-y-2">
            <h1 class="text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
              Discovered offers
            </h1>
            <p class="text-base leading-7 text-slate-600">
              Review normalized job offers collected by the discovery pipeline.
            </p>
          </div>
        </div>

        <div id="discovered-jobs-list" phx-update="stream" class="space-y-4">
          <div
            id="discovered-jobs-empty"
            class="hidden only:block rounded-3xl border border-dashed border-slate-300 bg-white/80 p-8 text-center shadow-sm"
          >
            <div class="mx-auto flex size-12 items-center justify-center rounded-2xl bg-slate-100 text-slate-500">
              <.icon name="hero-magnifying-glass" class="size-6" />
            </div>
            <h2 class="mt-4 text-lg font-semibold text-slate-950">No discovered offers yet</h2>
            <p class="mt-2 text-sm leading-6 text-slate-600">
              Scheduled discovery will add offers here once new source results are persisted.
            </p>
          </div>

          <article
            :for={{id, offer} <- @streams.offers}
            id={id}
            class="group rounded-3xl border border-slate-200 bg-white p-6 shadow-sm transition hover:-translate-y-0.5 hover:border-slate-300 hover:shadow-lg"
          >
            <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
              <div class="space-y-2">
                <p data-field="company" class="text-sm font-semibold text-indigo-600">
                  {offer.company || "Unknown company"}
                </p>
                <h2 data-field="title" class="text-xl font-bold tracking-tight text-slate-950">
                  {offer.title || "Untitled offer"}
                </h2>
              </div>
              <span
                data-field="source"
                class="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600"
              >
                {offer.source}
              </span>
            </div>

            <dl class="mt-6 grid gap-3 text-sm text-slate-600 sm:grid-cols-2">
              <div class="rounded-2xl bg-slate-50 p-3">
                <dt class="text-xs font-semibold uppercase tracking-wide text-slate-400">Remote</dt>
                <dd data-field="remote" class="mt-1 font-medium text-slate-900">
                  {format_enum(offer.remote)}
                </dd>
              </div>
              <div class="rounded-2xl bg-slate-50 p-3">
                <dt class="text-xs font-semibold uppercase tracking-wide text-slate-400">
                  Seniority
                </dt>
                <dd data-field="seniority" class="mt-1 font-medium text-slate-900">
                  {format_enum(offer.seniority)}
                </dd>
              </div>
              <div class="rounded-2xl bg-slate-50 p-3">
                <dt class="text-xs font-semibold uppercase tracking-wide text-slate-400">Location</dt>
                <dd data-field="location" class="mt-1 font-medium text-slate-900">
                  {offer.location || "Unknown"}
                </dd>
              </div>
              <div class="rounded-2xl bg-slate-50 p-3">
                <dt class="text-xs font-semibold uppercase tracking-wide text-slate-400">
                  Discovered
                </dt>
                <dd data-field="discovered-at" class="mt-1 font-medium text-slate-900">
                  {format_datetime(offer.discovered_at)}
                </dd>
              </div>
            </dl>
          </article>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp format_enum(nil), do: "Unknown"

  defp format_enum(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp format_datetime(nil), do: "Unknown"

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M UTC")
  end
end
