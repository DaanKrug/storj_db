defmodule StorjDB.DataCommon do

  @moduledoc false
  
  
  alias Krug.MapUtil
  alias StorjDB.DatabaseSchema
  alias StorjDB.FileService
  
  
  def first_of_list(list) do
    cond do
      (Enum.empty?(list))
        -> nil
      true
        -> list
            |> hd()
    end
  end
 
  def match_keys(object,object_criteria,keys,single_match) do
    cond do
      (nil == object)
        -> false
      (Enum.empty?(keys))
        -> !single_match
      true
        -> object
             |> match_keys2(object_criteria,keys,single_match)
    end
  end
  
  defp match_keys2(object,object_criteria,keys,single_match) do
    match = match_key(object,object_criteria,keys |> hd())
    cond do
      (!single_match and !match)
        -> false
      (single_match and match)
        -> true
      true
        -> object
             |> match_keys(object_criteria,keys |> tl(),single_match)
    end
  end
  
  defp match_key(object,object_criteria,key) do
    criteria_value = object_criteria 
                       |> MapUtil.get(key)
    attribute_value = object 
                        |> MapUtil.get(key)
    cond do
      (nil == criteria_value or nil == attribute_value)
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