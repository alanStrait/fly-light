defmodule FlyDashWeb.PageController do
  use FlyDashWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
