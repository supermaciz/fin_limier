# FinLimier

[![codecov](https://codecov.io/gh/supermaciz/fin_limier/branch/main/graph/badge.svg)](https://codecov.io/gh/supermaciz/fin_limier)

## Goals

FinLimier is a learning project built with [Phoenix](https://www.phoenixframework.org/) and driven by three main objectives:

- **Build a job search assistant** — an AI-powered tool that helps users find and analyze job offers, starting with data from the [France Travail API](https://francetravail.io/produits-partages/catalogue/offres-emploi?tabgroup-api=documentation).
- **Explore spec-driven development with [OpenSpec](https://github.com/zinc-collective/openspec)** — use executable specifications to guide design and implementation throughout the project.
- **Practice clean / hexagonal architecture** — apply architectural patterns (ports & adapters, domain isolation, dependency inversion) to keep the codebase maintainable and testable.

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment variables

The following environment variables are required for the application to run:

| Variable | Description |
| --- | --- |
| `FRANCE_TRAVAIL_CLIENT_ID` | Client ID for the France Travail API, used to authenticate when fetching job offers. |
| `FRANCE_TRAVAIL_CLIENT_SECRET` | Client secret for the France Travail API, paired with the client ID to obtain access tokens. |
| `OPENAI_API_KEY` | API key for OpenAI, used for AI-powered features. |

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## APIs

* [France Travail API](https://francetravail.io/produits-partages/catalogue/offres-emploi?tabgroup-api=documentation)

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
