defmodule StorjDB.DataCreate do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.DataCommon
  alias Krug.MapUtil
  alias StorjDB.StorjSynchronizeTo
  
 
  def create(table_name,object) do
    [
      last_file,
      rows_perfile,
      total_rows,
      last_id
    ] = table_name 
          |> DataCommon.read_table_info()
    id = last_id + 1
    object = object 
               |> MapUtil.replace(:id,id)
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    objects = bucket_name  
                |> DataCommon.read_table_objects(table_name,last_file)
    [file_number,objects_to_save] = 
      last_file
        |> prepare_object_to_store(objects,object,rows_perfile)
    schema_info = [
      table_name,
      rows_perfile,
      file_number,
      total_rows + 1,
      id,
      false
    ]
    DataCommon.store_table_objects(bucket_name,objects_to_save,file_number,schema_info)
    EtsUtil.read_from_cache(:storj_db_app,"database_schema")
      |> StorjSynchronizeTo.mark_to_synchronize()
    StorjSynchronizeTo.mark_to_synchronize(table_name)
  end
  
  defp prepare_object_to_store(last_file,objects,object,rows_perfile) do
    cond do
      (Enum.empty?(objects))
        -> [last_file,[object]]
      true
        -> last_file
             |> prepare_object_to_store2(objects,object,rows_perfile)
    end
  end
  
  defp prepare_object_to_store2(last_file,objects,object,rows_perfile) do
    last_file = rows_perfile
                  |> DataCommon.calculate_last_file(last_file,objects)
    objects_to_save = [
      object
      | objects |> Enum.reverse()
    ]         
      |> Enum.reverse() 
    [last_file,objects_to_save]
  end
  
end














