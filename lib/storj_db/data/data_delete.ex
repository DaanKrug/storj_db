defmodule StorjDB.DataDelete do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias Krug.MapUtil
  alias StorjDB.DataCommon
  alias StorjDB.DataRestore
  
  
  def drop_table(table_name) do
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    bucket_name
      |> DataCommon.drop_table(table_name)
  end
  
  def delete_by_id(table_name,id) do
    object = table_name
               |> DataRestore.load_by_id(id)
    delete(table_name,object)
  end
  
  def delete(table_name,object) do
    [
      last_file,
      rows_perfile,
      total_rows,
      last_id
    ] = table_name 
          |> DataCommon.read_table_info()
    id = object 
           |> MapUtil.get(:id)
    file_number = object 
                    |> MapUtil.get(:found_on_file_number)
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    objects = bucket_name  
                |> DataCommon.read_table_objects(table_name,file_number)
    objects_to_update = objects
                          |> prepare_object_to_update(id)
    [last_file,last_id] = 
      bucket_name
        |> calculate_last_id_after_delete(table_name,objects,last_id,id,file_number,last_file) 
    schema_info = [
      table_name,
      rows_perfile,
      last_file,
      total_rows - 1,
      last_id,
      false
    ]
    bucket_name
      |> DataCommon.update_table_objects(table_name,objects_to_update,file_number,schema_info)
  end
  
  defp prepare_object_to_update(objects,id,objects_to_update \\ []) do
    cond do
      (Enum.empty?(objects))
        -> objects_to_update
             |> Enum.reverse()
      true
        -> objects
             |> prepare_object_to_update2(id,objects_to_update)
    end
  end
  
  defp prepare_object_to_update2(objects,id,objects_to_update) do
    object = objects 
               |> hd()
    delete_object = object 
                      |> delete_object?(id)
    cond do
      (delete_object)
        -> objects
             |> tl()
             |> prepare_object_to_update(id,objects_to_update)
      true
        -> objects
             |> tl()
             |> prepare_object_to_update(id,[object | objects_to_update]) 
    end
  end
  
  defp delete_object?(object,id) do
    cond do
      (object |> MapUtil.get(:id) == id)
        -> true
      true
        -> false
    end
  end
  
  defp calculate_last_id_after_delete(bucket_name,table_name,objects,
                                      last_id,id_to_delete,file_number,last_file) do
    cond do
      (last_id != id_to_delete)
        -> [
             last_file,
             last_id
           ]
      (length(objects) == 1 and file_number == last_file and last_file > 0)
        -> [
             last_file - 1, 
             bucket_name  
               |> DataCommon.read_table_objects(table_name,last_file - 1)
               |> Enum.reverse()
               |> calculate_last_id_after_delete2(last_id,id_to_delete,0)
           ]
      true
        -> [
             last_file, 
             objects
               |> Enum.reverse()
               |> calculate_last_id_after_delete2(last_id,id_to_delete,0)
           ]
    end
  end
  
  defp calculate_last_id_after_delete2(objects,last_id,id_to_delete,major_id) do
    cond do
      (Enum.empty?(objects))
        -> major_id
      true
        -> objects
             |> calculate_last_id_after_delete3(last_id,id_to_delete,major_id)
    end
  end
  
  defp calculate_last_id_after_delete3(objects,last_id,id_to_delete,major_id) do
    id = objects
           |> hd()
           |> MapUtil.get(:id)
    cond do
      (id > major_id and id_to_delete != id)
        -> objects
             |> tl()
             |> calculate_last_id_after_delete2(last_id,id_to_delete,id)
      true
        -> objects
             |> tl()
             |> calculate_last_id_after_delete2(last_id,id_to_delete,major_id)
    end 
  end
  
end

