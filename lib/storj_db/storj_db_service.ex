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
  
  def cleanup_all() do
    ConnectionConfig.ok_operation()
    StorjSynchronizeTo.cleanup_all()
  end
  
  def synchronize_all() do
    ConnectionConfig.ok_operation()
    StorjSynchronizeTo.synchronize_all()
  end
  
  def reset_data_dir() do
    ConnectionConfig.ok_operation()
    ConnectionConfig.reset_data_dir()
    DatabaseSchema.drop_database_schema()
  end
  
  def create(table_name,object) do
    ConnectionConfig.ok_operation()
    DataCreate.create(table_name,object)
  end
  
  def load_by_id(table_name,id) do
    ConnectionConfig.ok_operation()
    DataRestore.load_by_id(table_name,id)
  end
  
  def load_all(table_name,object_criteria,max_results \\ -1,single_match \\ true,sort_desc \\ false) do
    ConnectionConfig.ok_operation()
    DataRestore.load_all(table_name,object_criteria,max_results,single_match,sort_desc)
  end
  
  def update(table_name,object) do
    ConnectionConfig.ok_operation()
    DataUpdate.update(table_name,object)
  end
  
  def delete(table_name,object) do
    ConnectionConfig.ok_operation()
    DataDelete.delete(table_name,object)
  end
  
  def delete_by_id(table_name,id) do
    ConnectionConfig.ok_operation()
    DataDelete.delete_by_id(table_name,id)
  end
  
  def drop_table(table_name) do
    ConnectionConfig.ok_operation()
    DataDelete.drop_table(table_name)
  end
  
  def read_table_info(table_name) do
    ConnectionConfig.ok_operation()
    DataCommon.read_table_info(table_name,true)
  end
  
end


