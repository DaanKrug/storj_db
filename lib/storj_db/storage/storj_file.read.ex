defmodule StorjDB.StorjFileRead do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias Krug.FileUtil
  alias StorjDB.TempFileService
  
  
  def read_file(bucket_name,filename) do
    synchronize = EtsUtil.read_from_cache(:storj_db_app,"synchronize_read_#{filename}")
    cond do
      (!synchronize)
        -> filename
             |> read_file2()
      true
        -> bucket_name
             |> synchronize_file(filename)
    end
  end
  
  defp read_file2(filename) do
    EtsUtil.remove_from_cache(:storj_db_app,"synchronize_read_#{filename}")
    filename
      |> TempFileService.read_file()
  end
  
  def synchronize_file(bucket_name,filename,return_content \\ true) do
    file_path = filename
                  |> TempFileService.get_temp_file()
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["cp",storj_link,file_path]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)   
    result = file_path
               |> synchronize_file_result(exit_status,result,return_content)
    file_path
      |> TempFileService.drop_temp_file()
    EtsUtil.remove_from_cache(:storj_db_app,"synchronize_read_#{filename}")
    ["result",result] |> IO.inspect()
    result
  end
  
  defp synchronize_file_result(file_path,exit_status,result,return_content) do
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
        -> file_path
             |> FileUtil.read_file()
    end
  end
  
end




