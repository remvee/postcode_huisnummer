defmodule PostcodeHuisnummer.Router do
  use PostcodeHuisnummer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PostcodeHuisnummer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/show", PageController, :show
    get "/version", PageController, :version
    get "/versions", PageController, :versions
  end

  # Other scopes may use custom stacks.
  # scope "/api", PostcodeHuisnummer do
  #   pipe_through :api
  # end
end
