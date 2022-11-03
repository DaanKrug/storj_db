defmodule StorjDB.DataCreate do

  @moduledoc false
  
  alias Krug.StringUtil
  alias Krug.EtsUtil
  alias StorjDB.DatabaseSchema
  alias StorjDB.DataCommon
  alias Krug.MapUtil
  alias StorjDB.FileService
  
  
  def create(table_name,object) do
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    table_info = table_name
                   |> DatabaseSchema.read_table_schema()
    last_file = table_info 
                |> MapUtil.get(:last_file)    
    rows_perfile = table_info 
                   |> MapUtil.get(:rows_perfile)
    total_rows = table_info 
                   |> MapUtil.get(:total_rows)
    last_id = table_info 
                |> MapUtil.get(:last_id)
    id = last_id + 1
    object = object 
               |> MapUtil.replace(:id,id)
    filename = "#{table_name}_#{last_file}.txt"
    objects = bucket_name
                |> FileService.read_file_content(filename)
                |> StringUtil.split("\n")
    last_file = rows_perfile
                  |> DataCommon.calculate_last_file(last_file,objects)
    bucket_name
      |> append_object_to_file(table_name,objects,object,rows_perfile,last_file)
    table_name
      |> DatabaseSchema.update_schema(rows_perfile,last_file,total_rows + 1,id,false)
  end
  
  defp append_object_to_file(bucket_name,table_name,objects,object,rows_perfile,last_file) do
    content = [
      object |> Poison.encode!() 
      | objects |> Enum.reverse()
    ]
      |> Enum.reverse()
      |> Enum.join("\n")
    filename = "#{table_name}_#{last_file}.txt"
    bucket_name
      |> FileService.write_file_content(filename,content)
  end
  
  
end














