defmodule StorjDB.ConnectionConfig do

  @moduledoc false

  alias Krug.FileUtil
  alias Krug.EtsUtil
  alias Krug.StructUtil
  alias Krug.StringUtil
  alias StorjDB.FileService  
  alias StorjDB.DatabaseSchema
  
  
  @config_filename "storj_db.config.txt"
  @sample_filename "storj_db.config.sample.txt"


  def config_connection(base_path \\ ".") do
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
  
  defp init_connection_sample(base_path) do
    database_schema = DatabaseSchema.new()
                        |> DatabaseSchema.add_table("table_1",100)
    content = """
              bucket_name=sample_database
              database_schema=#{database_schema |> Poison.encode!()}
              """
    "#{base_path}/#{@sample_filename}" 
      |> FileUtil.write(content)
    base_path 
      |> write_path_info()
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
    A sample config file was writted to '#{base_path}/#{@sample_filename}'.
    Please edit this file and rename to '#{base_path}/#{@config_filename}' 
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
    database_schema = list
                        |> read_database_schema()
    EtsUtil.store_in_cache(:storj_db_app,"bucket_name",bucket_name)
    EtsUtil.store_in_cache(:storj_db_app,"database_schema",database_schema)
    bucket_name
      |> IO.inspect()
    database_schema
      |> IO.inspect()
  end
  
  defp read_database_schema(list) do
    database_schema = "database_schema" 
                        |> StructUtil.get_key_par_value_from_list(list)
    cond do
      (nil == database_schema
        or database_schema == "")
          -> ""
      true
        -> database_schema
             |> Poison.decode!()
    end
  end

end








