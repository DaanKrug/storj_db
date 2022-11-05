defmodule StorjDB.FileService do

  @moduledoc false

  alias Krug.StringUtil
  alias Krug.FileUtil
  alias Krug.EtsUtil
  alias Krug.DateUtil
  alias StorjDB.ConnectionConfig
  
  
  def read_file_content(bucket_name,filename) do
    destination_file = read_destination_file(bucket_name,filename)
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
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    cond do
      (only_local_disk == 1 or only_local_disk == "1")
        -> :ok
      true
        -> bucket_name
             |> store_file(file_path)
    end
  end
  
  def drop_file(bucket_name,filename) do
    dest_path = ConnectionConfig.read_database_config_path()
    file_path = "#{dest_path}/#{filename}"
    deleted = file_path 
                |> FileUtil.drop_file()
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    cond do
      (!deleted)
        -> :error
      (only_local_disk == 1 or only_local_disk == "1")
        -> :ok
      true
        -> bucket_name
             |> drop_file2(filename)
    end
  end
  
  defp read_destination_file(bucket_name,filename) do
    dest_path = ConnectionConfig.read_database_config_path()
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    debugg = EtsUtil.read_from_cache(:storj_db_app,"debugg")
    cond do
      (only_local_disk == 1 or only_local_disk == "1")
        -> "#{dest_path}/#{filename}"
      true
        -> download_file(bucket_name,filename,dest_path,(debugg == 1 or debugg == "1"))
    end
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
  
  defp download_file(bucket_name,filename,dest_path,for_log) do
    storj_link = "sj://#{bucket_name}/#{filename}"
    destination_file = dest_path 
                         |> get_destination_path(filename,for_log)
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
  
  defp get_destination_path(dest_path,filename,for_log) do
    cond do
      (for_log)
        -> "#{dest_path}/#{read_random_prefix()}_#{filename}"
      true
        -> "#{dest_path}/#{filename}" 
    end
  end
  
  defp read_random_prefix() do
    DateUtil.get_date_and_time_now_string() 
      |> StringUtil.replace(" ","_") 
      |> StringUtil.replace("-","_") 
      |> StringUtil.replace(":","_")
      |> StringUtil.replace("/","_")
  end
  
  defp drop_file2(bucket_name,filename) do
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["rm",storj_link]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    
    [result, exit_status] |> IO.inspect()
    
    cond do
      (exit_status != 0) 
        -> false
      (!(String.contains?(result,"Deleted #{storj_link}"))) 
        -> false
      true 
        -> true
    end
  end
 
end
