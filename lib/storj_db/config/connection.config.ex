defmodule StorjDB.ConnectionConfig do

  @moduledoc false

  alias Krug.FileUtil
  alias Krug.EtsUtil
  alias Krug.StructUtil
  alias Krug.StringUtil
  alias Krug.MapUtil
  alias StorjDB.StorjFileDebugg
  alias StorjDB.StorjSynchronizeFrom
  alias StorjDB.DatabaseSchema
  
  
  @config_filename "storj_db.config.txt"
  @default_table_rows 100


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
             |> init_connection_to_ets(true)
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
    content = """
              bucket_name=sample-database
              database_schema=#{database_schema_path}
              only_local_disk=0
              debugg=0
              """
    "#{base_path}/#{@config_filename}" 
      |> FileUtil.write(content)
    base_path 
      |> write_path_info()
    content
      |> init_connection_to_ets(false)
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
  
  defp init_connection_to_ets(content,init_tables) do
    list = content 
             |> StringUtil.split("\n")
    bucket_name = "bucket_name" 
                     |> StructUtil.get_key_par_value_from_list(list)
    database_schema = "database_schema" 
                        |> StructUtil.get_key_par_value_from_list(list)
    only_local_disk = "only_local_disk" 
                        |> StructUtil.get_key_par_value_from_list(list)
    debugg = "debugg" 
               |> StructUtil.get_key_par_value_from_list(list)
    EtsUtil.store_in_cache(:storj_db_app,"bucket_name",bucket_name)
    EtsUtil.store_in_cache(:storj_db_app,"database_schema",database_schema)
    EtsUtil.store_in_cache(:storj_db_app,"only_local_disk",only_local_disk)
    EtsUtil.store_in_cache(:storj_db_app,"debugg",debugg)
    cond do
      (!init_tables)
        -> :ok
      true
        -> bucket_name
             |> initialize_tables(database_schema)
    end
  end
  
  defp initialize_tables(bucket_name,database_schema) do
    EtsUtil.store_in_cache(:storj_db_app,"synchronize_read_#{database_schema}",true)
    database_schema
      |> StorjSynchronizeFrom.mark_to_synchronize()
    DatabaseSchema.read_database_schema()
      |> MapUtil.get(:tables)
      |> initialize_tables2()
    bucket_name
      |> StorjSynchronizeFrom.run_synchronization(true)  
  end
  
  defp initialize_tables2(tables) do
    cond do
      (Enum.empty?(tables))
        -> :ok
      true
        -> initialize_tables3(tables)
    end
  end
  
  defp initialize_tables3(tables) do
    table = tables
              |> hd()
    "#{table |> MapUtil.get(:table_name)}_#{table |> MapUtil.get(:last_file)}.txt"
      |> StorjSynchronizeFrom.mark_to_synchronize()
    tables
      |> tl()
      |> initialize_tables2()
  end
  
  def read_rows_perfile_if_undefined(table_name,rows_perfile) do
    cond do
      (rows_perfile > 0)
        -> rows_perfile
      true
        -> table_name 
             |> read_rows_perfile_from_application_env()
    end
  end
  
  defp read_rows_perfile_from_application_env(table_name) do
    tables_config = Application.get_env(:storj_db,:tables_config)
    cond do
      (nil == tables_config)
        -> @default_table_rows
      true
        -> table_name
             |> read_rows_perfile_from_application_env2(tables_config)
    end
  end
  
  defp read_rows_perfile_from_application_env2(table_name,tables_config) do
    table_config = tables_config 
                     |> MapUtil.get(table_name)
    cond do
      (nil == table_config)
        -> @default_table_rows
      true
        -> table_config
             |> read_rows_perfile_from_application_env3()
    end
  end
  
  defp read_rows_perfile_from_application_env3(table_config) do
    table_rows = table_config 
                   |> MapUtil.get(:rows_perfile)
    ["it works: table rows number perfile for table => ", table_rows] 
      |> StorjFileDebugg.info()
    cond do
      (nil == table_rows or table_rows <= 0)
        -> @default_table_rows
      true
        -> table_rows
    end
  end
 
end




