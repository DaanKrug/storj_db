defmodule StorjDB.Service do

  @moduledoc false

  require Logger
  use GenServer
  
  
  alias Krug.EtsUtil
  alias StorjDB.ConnectionConfig
  
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, named: __MODULE__)
  end

  def init(_opts) do
    EtsUtil.new(:storj_db_app)
    path = Application.get_env(:storj_db, :path)
    cond do
      (nil == path)
        -> ConnectionConfig.config_connection()
      true 
        -> path
             |> ConnectionConfig.config_connection()
    end
    "Started StorjDB.Service ..."
      |> Logger.info()
    {:ok, []}
  end
  
  def echo() do
    EtsUtil.read_from_cache(:storj_db_app,"ping")
      |> IO.inspect()
  end

end