defmodule StorjDB.DataCommon do

  @moduledoc false
  
  alias Krug.NumberUtil
  alias Krug.MapUtil
  alias StorjDB.DatabaseSchema
  alias StorjDB.FileService
 
  def match_id(object_criteria,object) do
    id0 = object_criteria 
            |> MapUtil.get(:id)
    id1 = object 
            |> MapUtil.get(:id)
    cond do
      (nil == id0 or nil == id1)
        -> false
      true
        -> (id0 |> NumberUtil.to_integer()) == (id1 |> NumberUtil.to_integer())
    end
  end
  
  def match_keys(object_criteria,object,keys,single_match) do
    cond do
      (Enum.empty?(keys))
        -> false
      true
        -> object_criteria
             |> match_keys2(object,keys,single_match)
    end
  end
  
  defp match_keys2(object_criteria,object,keys,single_match) do
    match = match_key(object_criteria,object,keys |> hd())
    cond do
      (!single_match and !match)
        -> false
      (single_match and match)
        -> true
      true
        -> object_criteria
             |> match_keys(object,keys |> tl(),single_match)
    end
  end
  
  defp match_key(object_criteria,object,key) do
    criteria_value = object_criteria 
                       |> MapUtil.get(key)
    attribute_value = object 
                        |> MapUtil.get(key)
    cond do
      (nil == criteria_value or nil == criteria_value)
        -> false
      true
        -> String.contains?("#{attribute_value}","#{criteria_value}")
    end
  end
  
  #==============================
  
  def read_table_info(table_name) do
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
    [last_file,rows_perfile,total_rows,last_id]
  end
  
  def read_table_objects(bucket_name,table_name,file_number) do
    filename = "#{table_name}_#{file_number}.txt"
    content = bucket_name
      |> FileService.read_file_content(filename)
    cond do
      (nil == content or content == "")
        -> []
      true
        -> content
             |> Poison.decode!()
    end
  end
  
  #==============================
  
  def store_table_objects(bucket_name,objects_to_save,file_number,schema_info) do
    content = objects_to_save
                |> Poison.encode!() 
    table_name = schema_info
                   |> hd()
    filename = "#{table_name}_#{file_number}.txt"
    bucket_name
      |> FileService.write_file_content(filename,content)
    schema_info
      |> DatabaseSchema.update_schema_by_schema_info()
  end
  
  def calculate_last_file(rows_perfile,last_file,objects) do
    cond do
      (length(objects) > rows_perfile)
        -> last_file + 1
      true
        -> last_file
    end
  end
  
end