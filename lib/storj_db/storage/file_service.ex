defmodule StorjDB.FileService do

  @moduledoc false

  alias Krug.StringUtil
  alias Krug.FileUtil
  alias StorjDB.ConnectionConfig
  
  
  def read_file_content(bucket_name,filename) do
    dest_path = ConnectionConfig.read_database_config_path()
    destination_file = download_file(bucket_name,filename,dest_path)
    # destination_file = "#{dest_path}/#{filename}" // TODO: remove after tests
    cond do
      (nil == destination_file)
        -> ""
      true
        -> destination_file
             |> FileUtil.read_file()
    end
  end
  
  def write_file_content(bucket_name,filename,content) do
    dest_path = ConnectionConfig.read_database_config_path()
    file_path = "#{dest_path}/#{filename}"
    file_path 
      |> FileUtil.write(content)
    bucket_name
      |> store_file(file_path)
  end

  defp store_file(bucket_name,file_path) do
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
  
  defp drop_file(bucket_name,filename) do
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
  
  defp download_file(bucket_name,filename,dest_path) do
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
        -> destination_file
    end
  end
 
end
