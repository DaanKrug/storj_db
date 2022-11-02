defmodule StorjDB.Application do
  
  @moduledoc false

  use Application

  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end
  
  def children() do
  	[
  	  StorjDB.Service
  	]
  end
  
  def opts() do 
  	[strategy: :one_for_one, name: StorjDB.Supervisor]
  end 
  
end
