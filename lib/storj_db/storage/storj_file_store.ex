defmodule StorjDB.StorjFileStore do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias Krug.FileUtil
  alias StorjDB.TempFileService
  
  
  def store_file(bucket_name,filename,content) do
    pid = TempFileService.write_file(filename,content)
    cond do
      (nil == pid)
        -> false
      true
        -> bucket_name
             |> store_file2(filename)
    end
  end
  
  def store_file2(bucket_name,filename) do
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    cond do
      (only_local_disk == 1 or only_local_disk == "1")
        -> true
      true
        -> bucket_name
             |> store_file3(filename)
    end
  end
  
  defp store_file3(bucket_name,filename) do
    content = TempFileService.read_file(filename)
    "sj://#{bucket_name}/#{filename}"
      |> FileUtil.write(content)
  end
  
end