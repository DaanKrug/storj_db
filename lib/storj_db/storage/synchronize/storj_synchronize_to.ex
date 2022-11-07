defmodule StorjDB.StorjSynchronizeTo do

  @moduledoc false
  
  @list_name "synchronize_store_list_table_names"
  
  alias Krug.EtsUtil
  alias StorjDB.StorjFileStore
  
  
  def synchronize_all() do
    sync_list = read_sync_list()
    sync_list
      |> enqueue_all()
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name") 
    sync_list
      |> dispatch_all(bucket_name)
  end
  
  defp enqueue_all(sync_list) do
    cond do
      (Enum.empty?(sync_list))
        -> :ok
      true
        -> sync_list
             |> enqueue_all2()
    end
  end
  
  defp enqueue_all2(sync_list) do
    filename = sync_list
                 |> hd()
    EtsUtil.store_in_cache(:storj_db_app,"synchronize_store_#{filename}",true)
    sync_list
      |> tl()
      |> enqueue_all()
  end
  
  defp dispatch_all(sync_list,bucket_name) do
    cond do
      (Enum.empty?(sync_list))
        -> :ok
      true
        -> sync_list
             |> dispatch_all2(bucket_name)
    end
  end
  
  defp dispatch_all2(sync_list,bucket_name) do
    filename = sync_list
                 |> hd()
    bucket_name
      |> StorjFileStore.synchronize_file(filename)
    sync_list
      |> tl()
      |> dispatch_all(bucket_name)
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