defmodule StorjDB.StorjFileRead do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.StorjFileDebugg
  alias StorjDB.TempFileService
  
  
  def read_file(bucket_name,filename) do
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
    file_path = filename
                  |> TempFileService.get_temp_file()
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["cp",storj_link,file_path]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    ["download_file",result, exit_status] 
      |> StorjFileDebugg.info()
    file_path
      |> TempFileService.drop_temp_file()
    cond do
      (exit_status != 0) 
        -> nil
      (!(String.contains?(result,"Downloaded "))) 
        -> nil
      true 
        -> filename
             |> TempFileService.read_file()
    end
  end
  
end