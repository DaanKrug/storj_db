defmodule StorjDB do

  alias StorjDB.Service

  @moduledoc """
  Documentation for "Storj DB" utilitaries modules.
  """
  
  def create(table,object) do
    Service.create(table,object)
  end
  
  
end
