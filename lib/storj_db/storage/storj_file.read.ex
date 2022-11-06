defmodule StorjDB.StorjFileRead do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.TempFileService
  
  
  defp read_file(bucket_name,filename) do
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    cond do
      (only_local_disk == 1 or only_local_disk == "1")
        -> filename
             |> TempFileService.read_file()
      true
        -> bucket_name
             |> download_file(filename)
    end
  end
  
  defp download_file(bucket_name,filename) do
    content = "sj://#{bucket_name}/#{filename}"
                |> FileUtil.read()
    filename 
      |> TempFileService.write_file(content)
    filename
      |> TempFileService.read_file()
  end
  
end