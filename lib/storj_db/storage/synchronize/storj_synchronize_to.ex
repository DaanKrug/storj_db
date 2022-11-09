defmodule StorjDB.StorjSynchronizeTo do

  @moduledoc false
  

  alias Krug.EtsUtil
  alias StorjDB.StorjFileDebugg
  alias StorjDB.StorjSynchronizeToTask
  
  
  def mark_to_synchronize(filename) do
    filename
      |> StorjSynchronizeToTask.mark_to_synchronize()
  end
  
  def mark_to_drop(filename) do
    filename
      |> StorjSynchronizeToTask.mark_to_drop()
  end
  
  def cleanup_all() do
    synchronize_all(true)
  end
  
  def synchronize_all(for_drop \\ false) do
  
    "\n\n\n ===   sync => #{StorjSynchronizeToTask.is_synchronizing?()} =========== "
      |> StorjFileDebugg.info()
    cond do
      (StorjSynchronizeToTask.is_synchronizing?())
        -> true
      true
        -> for_drop
             |> synchronize_all2()
    end
  end
  
  def synchronize_all2(for_drop) do
    StorjSynchronizeToTask.set_synchronizing(true)
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name") 
    sync_list = for_drop 
                  |> StorjSynchronizeToTask.read_sync_list()
    sync_list
      |> enqueue_all(for_drop)
    sync_list
      |> StorjSynchronizeToTask.run_synchronization(bucket_name,for_drop)
    true
  end
  
  defp enqueue_all(sync_list,for_drop) do
    cond do
      (Enum.empty?(sync_list))
        -> true
      true
        -> sync_list
             |> enqueue_all2(for_drop)
    end
  end
  
  defp enqueue_all2(sync_list,for_drop) do
    filename = sync_list
                 |> hd()
    cond do
      (for_drop)
        -> EtsUtil.store_in_cache(:storj_db_app,"synchronize_drop_#{filename}",true)
      true
        -> EtsUtil.store_in_cache(:storj_db_app,"synchronize_store_#{filename}",true)
    end
    sync_list
      |> tl()
      |> enqueue_all(for_drop)
  end
  
  
  
end