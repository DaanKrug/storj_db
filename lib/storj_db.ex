defmodule StorjDB do

  alias StorjDB.Service

  @moduledoc """
  Documentation for "Storj DB" utilitaries modules.
  """
  
  def reset_data_dir() do
    Service.reset_data_dir()
  end
  
  def create(table,object) do
    Service.create(table,object)
  end
  
  def load_by_id(table_name,id) do
    Service.load_by_id(table_name,id)
  end
  
  def load_all(table_name,object_criteria,max_results \\ -1,single_match \\ true,sort_desc \\ false) do
    Service.load_all(table_name,object_criteria,max_results,single_match,sort_desc)
  end
  
  def update(table,object) do
    Service.update(table,object)
  end
  
end
