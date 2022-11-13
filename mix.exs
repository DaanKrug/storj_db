defmodule StorjDB.MixProject do
  use Mix.Project
  
  @project_url "https://github.com/DaanKrug/storj_db"

  def project do
    [
      app: :storj_db,
      version: "0.0.5",
      elixir: "~> 1.13",
      source_url: @project_url,
      homepage_url: @project_url,
      name: "Storj DB",
      description: "A decentralized JSON database based on Storj network: https://www.storj.io/",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :poison],
      mod: {StorjDB.Application, []}
    ]
  end

  defp deps do
    [
      {:earmark, "~> 1.4.13", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:poison, "~> 4.0.1"},
      {:krug, "~> 1.1.14"}
    ]
  end
  
  defp aliases do
    [c: "compile", d: "docs"]
  end
  
  defp package do
    [
      maintainers: ["Daniel Augusto Krug @daankrug <daniel-krug@hotmail.com>"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
  
end