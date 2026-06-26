defmodule FinLimierWeb.PageController do
  use FinLimierWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
