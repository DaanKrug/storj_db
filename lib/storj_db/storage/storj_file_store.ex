defmodule StorjDB.StorjFileStore do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.TempFileService
  
  
  def store_file(bucket_name,filename,content) do
    pid = TempFileService.write_file(filename,content)
    cond do
      (nil == pid)
        -> false
      true
        -> bucket_name
             |> synchronize_file(filename)
    end
  end
  
  def synchronize_file(bucket_name,filename) do
    synchronize = EtsUtil.read_from_cache(:storj_db_app,"synchronize_store_#{filename}")
    EtsUtil.remove_from_cache(:storj_db_app,"synchronize_store_#{filename}")
    cond do
      (!synchronize)
        -> true
      true
        -> bucket_name
             |> synchronize_file2(filename)
    end
  end
  
  defp synchronize_file2(bucket_name,filename) do
    file_path = filename
                  |> TempFileService.get_temp_file(true)
    executable = "uplink"
    arguments = ["cp",file_path,"sj://#{bucket_name}"]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    filename
      |> TempFileService.drop_temp_file()
    cond do
      (exit_status != 0) 
        -> false
      (!(String.contains?(result,"Created ")))
        -> false
      true 
        -> true
    end
  end
  
end