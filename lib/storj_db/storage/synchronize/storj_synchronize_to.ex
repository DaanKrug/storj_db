defmodule StorjDB.StorjSynchronizeTo do

  @moduledoc false
  
  @list_name "synchronize_store_list_table_names"
  
  alias Krug.EtsUtil
  
  
  
  def synchronize_all() do
    # synchronize_file(bucket_name,filename)
  end
  
  
  def mark_to_synchronize(filename) do
    sync_list = read_sync_list()
    filename2 = Enum.find(sync_list, fn(x) -> x == filename end)
    cond do
      (nil != filename2)
        -> :ok
      true
        -> [filename | sync_list]
             |> store_sync_list()
    end
    EtsUtil.store_in_cache(:storj_db_app,"synchronize_store_#{filename}",true)
  end
  
  defp read_sync_list() do
    list = EtsUtil.read_from_cache(:storj_db_app,@list_name)
    cond do
      (nil == list)
        -> []
      true
        -> list
    end
  end
  
  defp store_sync_list(list) do
    EtsUtil.store_in_cache(:storj_db_app,@list_name,list)
  end
  
end