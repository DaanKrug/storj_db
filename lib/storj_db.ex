defmodule StorjDB do

  alias StorjDB.Service

  @moduledoc """
  Documentation for "Storj DB" utilitaries modules.
  """
  
  def echo() do
    Service.echo()
  end
  
end
