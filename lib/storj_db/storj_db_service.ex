defmodule StorjDB.Service do

  @moduledoc false

  require Logger
  use GenServer
  
  
  alias Krug.EtsUtil
  alias StorjDB.ConnectionConfig
  alias StorjDB.DataCreate
  
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, named: __MODULE__)
  end

  def init(_opts) do
    EtsUtil.new(:storj_db_app)
    ConnectionConfig.config_connection()
    "Started StorjDB.Service ..."
      |> Logger.info()
    {:ok, []}
  end
  
  def create(table,object) do
    DataCreate.create(table,object)
  end
  

end