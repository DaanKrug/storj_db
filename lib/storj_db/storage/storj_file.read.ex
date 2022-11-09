defmodule StorjDB.StorjFileRead do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.StorjFileDebugg
  alias StorjDB.TempFileService
  
  
  def read_file(bucket_name,filename) do
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    synchronize = EtsUtil.read_from_cache(:storj_db_app,"synchronize_read_#{filename}")
    EtsUtil.remove_from_cache(:storj_db_app,"synchronize_read_#{filename}")
    cond do
      (!synchronize or only_local_disk == 1 or only_local_disk == "1")
        -> filename
             |> TempFileService.read_file()
      true
        -> bucket_name
             |> synchronize_file(filename)
    end
  end
  
  def synchronize_file(bucket_name,filename,return_content \\ true) do
    file_path = filename
                  |> TempFileService.get_temp_file()
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["cp",storj_link,file_path]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    ["synchronize_file",result, exit_status] 
      |> StorjFileDebugg.info()
    file_path
      |> TempFileService.drop_temp_file()
    cond do
      (exit_status != 0 and !return_content) 
        -> false
      (exit_status != 0) 
        -> nil
      (!(String.contains?(result,"Downloaded ")) and !return_content) 
        -> false
      (!(String.contains?(result,"Downloaded "))) 
        -> nil
      (!return_content)
        -> true
      true 
        -> filename
             |> TempFileService.read_file()
    end
  end
  
end