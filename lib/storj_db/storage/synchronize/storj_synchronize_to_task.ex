defmodule StorjDB.StorjSynchronizeToTask do

  @moduledoc false
  
  @store_list_name "synchronize_store_list_filename_names"
  @drop_list_name "synchronize_drop_list_filename_names"
  @synchronizing_key "synchronizing_lists_to_storj"
 
  alias Krug.EtsUtil
  alias StorjDB.StorjFileStore
  alias StorjDB.StorjFileDrop
  
  
  def is_synchronizing?() do
    synchronizing = EtsUtil.read_from_cache(:storj_db_app,@synchronizing_key)
    synchronizing == true
  end
  
  def set_synchronizing(sinchronizing) do
    EtsUtil.store_in_cache(:storj_db_app,@synchronizing_key,sinchronizing)
    true
  end
  
  def mark_to_synchronize(filename) do
    sync_list = false
                  |> read_sync_list()
    filename2 = Enum.find(sync_list, fn(x) -> x == filename end)
    cond do
      (nil != filename2)
        -> true
      true
        -> [filename | sync_list]
             |> store_sync_list(@store_list_name)
    end
  end
  
  def mark_to_drop(filename) do
    sync_list = true
                  |> read_sync_list()
    filename2 = Enum.find(sync_list, fn(x) -> x == filename end)
    cond do
      (nil != filename2)
        -> true
      true
        -> [filename | sync_list]
             |> store_sync_list(@drop_list_name)
    end
  end
  
  def run_synchronization(sync_list,bucket_name,for_drop) do
    Task.async(
	  fn -> 
	    result = sync_list
                   |> dispatch_all(bucket_name,for_drop,true)
        cond do
          (result)
            -> false
                 |> set_synchronizing()
          true
            -> sync_list
                 |> run_synchronization(bucket_name,for_drop)
        end
	  end
	)
  end
  
  defp dispatch_all(sync_list,bucket_name,for_drop,result) do
    cond do
      (Enum.empty?(sync_list))
        -> result
      true
        -> sync_list
             |> dispatch_all2(bucket_name,for_drop,result)
    end
  end
  
  defp dispatch_all2(sync_list,bucket_name,for_drop,result) do
    filename = sync_list
                 |> hd()
    result = filename
               |> synchronize_single_file(bucket_name,for_drop,result)
    sync_list
      |> tl()
      |> dispatch_all(bucket_name,for_drop,result)
  end
  
  defp synchronize_single_file(filename,bucket_name,for_drop,result) do
    result2 = filename
                |> synchronize_single_file2(bucket_name,for_drop)
    cond do
      (result2 and result)
        -> true
      (!result2)
        -> filename
             |> re_mark_to_synchronize(for_drop)
      true
        -> false
    end
  end
  
  defp synchronize_single_file2(filename,bucket_name,for_drop) do
    cond do
      (for_drop)
        -> bucket_name
             |> StorjFileDrop.drop_file(filename)
      true
        -> bucket_name
             |> StorjFileStore.synchronize_file(filename)
    end
  end
  
  defp re_mark_to_synchronize(filename,for_drop) do
    cond do
      (for_drop)
        -> filename
             |> mark_to_synchronize()
      true
        -> filename
             |> mark_to_synchronize()
    end
    false
  end
  
  def read_sync_list(for_drop) do
    cond do
      (for_drop)
        -> @drop_list_name
             |> read_sync_list2()
      true
        -> @store_list_name
             |> read_sync_list2()
    end
  end  
  
  defp read_sync_list2(list_name) do
    list = EtsUtil.read_from_cache(:storj_db_app,list_name)
    cond do
      (nil == list)
        -> []
      true
        -> list
    end
  end
  
  defp store_sync_list(list,list_name) do
    EtsUtil.store_in_cache(:storj_db_app,list_name,list)
  end
  
end
