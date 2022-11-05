defmodule StorjDB.Service do

  @moduledoc false

  require Logger
  use GenServer
  
  
  alias Krug.EtsUtil
  alias StorjDB.ConnectionConfig
  alias StorjDB.DataCreate
  alias StorjDB.DataRestore
  alias StorjDB.DataUpdate
  
  
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
  
  def reset_data_dir() do
    ConnectionConfig.reset_data_dir()
  end
  
  def create(table_name,object) do
    DataCreate.create(table_name,object)
  end
  
  def load_by_id(table_name,id) do
    DataRestore.load_by_id(table_name,id)
  end
  
  def load_all(table_name,object_criteria,max_results \\ -1,single_match \\ true,sort_desc \\ false) do
    DataRestore.load_all(table_name,object_criteria,max_results,single_match,sort_desc)
  end
  
  def update(table_name,object) do
    DataUpdate.update(table_name,object)
  end
  
end