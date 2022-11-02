defmodule StorjDB.ConnectionConfig do

  @moduledoc false

  alias Krug.FileUtil
  alias Krug.EtsUtil
  alias Krug.StructUtil
  alias Krug.StringUtil
  alias StorjDB.FileService  
  
  
  @config_filename "storj_db.config.txt"
  @sample_filename "storj_db.config.sample.txt"


  def config_connection(base_path \\ ".") do
    content = "#{base_path}/#{@config_filename}" 
                |> FileUtil.read_file()
    cond do
      (nil == content)
        -> init_connection_sample(base_path)
      true
        -> content 
             |> init_connection_to_ets(base_path)
    end
  end
  
  defp init_connection_sample(base_path) do
    content = """
              bucket_name=my_bucket
              database_name=my_database
              """
    "#{base_path}/#{@sample_filename}" 
      |> FileUtil.write(content)
    """
    A sample config file was writted to '#{base_path}/#{@sample_filename}'.
    Please edit this file and rename to '#{base_path}/#{@config_filename}' 
    """ 
      |> IO.inspect()
  end
  
  defp init_connection_to_ets(content,base_path) do
    list = content 
             |> StringUtil.split("\n")
    bucket_name = "bucket_name" 
                     |> StructUtil.get_key_par_value_from_list(list)
    database_name = "database_name" 
                       |> StructUtil.get_key_par_value_from_list(list)
    filename_schema = "#{database_name}_schema"
    filename_schema_result = bucket_name 
                               |> FileService.download_file(filename_schema,base_path)     
    EtsUtil.store_in_cache(:storj_db_app,"ping","paang")
    [
      bucket_name,
      database_name,
      filename_schema_result
    ]
  end

end








