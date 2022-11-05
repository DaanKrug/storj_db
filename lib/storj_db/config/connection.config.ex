defmodule StorjDB.ConnectionConfig do

  @moduledoc false

  alias Krug.FileUtil
  alias Krug.EtsUtil
  alias Krug.StructUtil
  alias Krug.StringUtil
  alias StorjDB.DatabaseSchema
  
  
  @config_filename "storj_db.config.txt"


  def read_database_config_path() do
    read_path()
      |> create_data_dir()
  end
  
  def reset_data_dir() do
    path = read_path()
    path
      |> FileUtil.drop_dir(true)
    path
      |> create_data_dir()
  end
  
  def config_connection() do
    base_path = read_database_config_path()
    content = "#{base_path}/#{@config_filename}" 
                |> FileUtil.read_file()
    cond do
      (nil == content)
        -> base_path
             |> init_connection_sample()
      true
        -> content 
             |> init_connection_to_ets()
    end
  end
  
  defp read_path() do
    path = Application.get_env(:storj_db,:path)
    cond do
      (nil == path)
        -> "./storj_db_data_files"
      true 
        -> "#{path}/storj_db_data_files"
    end
  end
  
  defp create_data_dir(path) do
    cond do
      (File.exists?(path))
        -> :ok
      true
        -> path
             |> FileUtil.create_dir()
    end
    path
  end
  
  defp init_connection_sample(base_path) do
    database_schema_path = "database_schema.txt"
    DatabaseSchema.update_schema("table_1",100)
    content = """
              bucket_name=sample_database
              database_schema=#{database_schema_path}
              only_local_disk=1
              """
    "#{base_path}/#{@config_filename}" 
      |> FileUtil.write(content)
    base_path 
      |> write_path_info()
    content
      |> init_connection_to_ets()
  end
  
  defp write_path_info(base_path) do
    cond do
      (base_path == ".")
        -> write_path_info2()
      true 
        -> base_path
             |> write_path_info3()
    end
  end
  
  defp write_path_info3(base_path) do
    """
    A sample config file was writted to '#{base_path}/#{@config_filename}'.
    Please edit this file to match your configurations 
    """ 
      |> IO.inspect()
  end
  
  defp write_path_info2() do
    """
    Maybe you wish configure you elixir app config file to map 
    the Storj DB root path to an absolute path:
    
    config :storj_db, path: "/var/www/html/my_app_dir"
    """
      |> IO.inspect()
  end
  
  defp init_connection_to_ets(content) do
    list = content 
             |> StringUtil.split("\n")
    bucket_name = "bucket_name" 
                     |> StructUtil.get_key_par_value_from_list(list)
    database_schema = "database_schema" 
                        |> StructUtil.get_key_par_value_from_list(list)
    only_local_disk = "only_local_disk" 
                        |> StructUtil.get_key_par_value_from_list(list)
    EtsUtil.store_in_cache(:storj_db_app,"bucket_name",bucket_name)
    EtsUtil.store_in_cache(:storj_db_app,"database_schema",database_schema)
    EtsUtil.store_in_cache(:storj_db_app,"only_local_disk",only_local_disk)
    :ok
  end
 
end
