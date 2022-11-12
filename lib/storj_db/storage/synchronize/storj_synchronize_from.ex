defmodule StorjDB.StorjSynchronizeFrom do

  @moduledoc false
  
  @list_name "synchronize_read_list_table_names"
  
  alias Krug.EtsUtil
  alias StorjDB.StorjFileRead
  alias StorjDB.TempFileService
  
  
  def run_synchronization(bucket_name,result) do
    read_sync_list()
      |> run_synchronization2(bucket_name,result)
  end
  
  defp run_synchronization2(sync_list,bucket_name,result) do
    cond do
      (Enum.empty?(sync_list))
        -> result
      true
        -> sync_list
             |> dispatch_all(bucket_name,result)
    end
  end
  
  defp dispatch_all(sync_list,bucket_name,result) do
    filename = sync_list
                 |> hd()
    result = filename
               |> synchronize_single_file(bucket_name,result)
    sync_list
      |> tl()
      |> run_synchronization2(bucket_name,result)
  end
  
  defp synchronize_single_file(filename,bucket_name,result) do
    result2 = bucket_name
                |> StorjFileRead.synchronize_file(filename,true)
    cond do
      (nil == result2)
        -> filename
             |> mark_to_synchronize()
      (nil != result2 and result)
        -> filename
             |> write_to_tempfile(result2)
      true
        -> false
    end
  end
  
  defp write_to_tempfile(filename,content) do
    pid = filename
            |> TempFileService.write_file(content)
    nil != pid
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
    EtsUtil.store_in_cache(:storj_db_app,"synchronize_read_#{filename}",true)
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