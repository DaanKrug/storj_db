defmodule StorjDB.Service do

  @moduledoc false

  require Logger
  use GenServer
  
  
  alias Krug.EtsUtil
  alias StorjDB.ConnectionConfig
  alias StorjDB.DatabaseSchema
  alias StorjDB.DataCommon
  alias StorjDB.DataCreate
  alias StorjDB.DataRestore
  alias StorjDB.DataUpdate
  alias StorjDB.DataDelete
  alias StorjDB.StorjSynchronizeTo

    
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
  
  def synchronize_all() do
    StorjSynchronizeTo.synchronize_all()
  end
  
  def reset_data_dir() do
    ConnectionConfig.reset_data_dir()
    DatabaseSchema.drop_database_schema()
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
  
  def delete(table_name,object) do
    DataDelete.delete(table_name,object)
  end
  
  def delete_by_id(table_name,id) do
    DataDelete.delete_by_id(table_name,id)
  end
  
  def drop_table(table_name) do
    DataDelete.drop_table(table_name)
  end
  
  def read_table_info(table_name) do
    DataCommon.read_table_info(table_name,true)
  end
  
end


