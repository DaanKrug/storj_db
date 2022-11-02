defmodule StorjDB.FileService do

  @moduledoc false

  alias Krug.StringUtil

  def store_file(bucket_name,file_path) do
    executable = "uplink"
    arguments = ["cp",file_path,"sj://#{bucket_name}"]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    cond do
      (exit_status != 0) 
        -> ""
      (!(String.contains?(result,"Created ")))
        -> ""
      true 
        -> file_path 
             |> store_file2(bucket_name)
    end
  end
  
  defp store_file2(file_path,bucket_name) do
    path_array = file_path 
                   |> StringUtil.split("/")
    filename = path_array 
                 |> Enum.reverse()
                 |> hd()
    "sj://#{bucket_name}/#{filename}"
  end
  
  def drop_file(bucket_name,filename) do
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["rm",storj_link]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    cond do
      (exit_status != 0) 
        -> false
      (!(String.contains?(result,"Deleted #{storj_link}"))) 
        -> false
      true 
        -> true
    end
  end
  
  def download_file(bucket_name,filename,dest_path) do
    storj_link = "sj://#{bucket_name}/#{filename}"
    destination_file = "#{dest_path}/#{filename}"
    executable = "uplink"
    arguments = ["cp",storj_link,destination_file]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    cond do
      (exit_status != 0) 
        -> nil
      (!(String.contains?(result,"Downloaded "))) 
        -> nil
      true 
        -> true
    end
  end
  
end