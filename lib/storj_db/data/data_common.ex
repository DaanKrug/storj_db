defmodule StorjDB.DataCommon do

  @moduledoc false
  
  
  alias Krug.MapUtil
  alias Krug.EtsUtil
  alias StorjDB.DatabaseSchema
  alias StorjDB.StorjFileDrop
  alias StorjDB.StorjFileStore
  alias StorjDB.StorjFileRead
  alias StorjDB.StorjSynchronizeTo
  
  
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
  
  def read_table_info(table_name,nil_if_nil \\ false) do
    table_info = table_name
                   |> DatabaseSchema.read_table_schema(nil_if_nil)
    cond do
      (nil == table_info)
        -> [nil,nil,nil,nil]
      true
        -> table_info
             |> read_table_info2()
    end
  end
  
  def read_table_info2(table_info) do
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
      |> StorjFileRead.read_file(filename)
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
      |> StorjFileStore.store_file(filename,content)
    table_name
      |> mark_to_synchronize(file_number)
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
  
  #==============================
  
  def update_table_objects(bucket_name,table_name,objects_to_save,file_number,schema_info) do
    content = objects_to_save
                |> Poison.encode!() 
    filename = "#{table_name}_#{file_number}.txt"
    bucket_name
      |> StorjFileStore.store_file(filename,content)
    table_name
      |> mark_to_synchronize(file_number)
    cond do
      (nil == schema_info)
        -> :ok
      true
        -> schema_info
             |> DatabaseSchema.update_schema_by_schema_info()
    end
  end
  
  #==============================
  
  def drop_table(bucket_name,table_name) do
    table_info = table_name
                   |> DatabaseSchema.read_table_schema(true)
    cond do
      (nil == table_info)
        -> :ok
      true
        -> table_info 
             |> MapUtil.get(:last_file)
             |> drop_table_files(bucket_name,table_name)
    end
  end
  
  defp drop_table_files(file_number,bucket_name,table_name) do
    cond do
      (file_number < 0)
        -> table_name
             |> DatabaseSchema.remove_table_from_schema()
      true
        -> file_number
             |> drop_table_files2(bucket_name,table_name)
    end
  end
  
  defp drop_table_files2(file_number,bucket_name,table_name) do
    filename = "#{table_name}_#{file_number}.txt"
    bucket_name
      |> StorjFileDrop.drop_file(filename)
    table_name
      |> mark_to_synchronize(file_number)
    drop_table_files(file_number - 1,bucket_name,table_name)
  end
  
  #==================================================
  
  defp mark_to_synchronize(table_name,file_number) do
    EtsUtil.read_from_cache(:storj_db_app,"database_schema")
      |> StorjSynchronizeTo.mark_to_synchronize()
    "#{table_name}_#{file_number}.txt"
      |> StorjSynchronizeTo.mark_to_synchronize()
  end
  
end








