defmodule StorjDB.DataUpdate do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias Krug.MapUtil
  alias StorjDB.DataCommon
  
  
  def update(table_name,object) do
    id = object 
           |> MapUtil.get(:id)
    file_number = object 
                    |> MapUtil.get(:found_on_file_number)
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    objects = bucket_name  
                |> DataCommon.read_table_objects(table_name,file_number)
    objects_to_update = objects
                        |> prepare_object_to_update(object,id)
    bucket_name
      |> DataCommon.update_table_objects(table_name,objects_to_update,file_number)
  end
  
  defp prepare_object_to_update(objects,object,id,objects_to_update \\ []) do
    cond do
      (Enum.empty?(objects))
        -> objects_to_update
             |> Enum.reverse()
      true
        -> objects
             |> prepare_object_to_update2(object,id,objects_to_update)
    end
  end
  
  defp prepare_object_to_update2(objects,object,id,objects_to_update) do
    replaced_object = objects 
                        |> hd() 
                        |> replace_by_new_object(object,id)
    objects
       |> tl()
       |> prepare_object_to_update(object,id,[replaced_object | objects_to_update])
  end
  
  defp replace_by_new_object(old_object,object_to_update,id) do
    cond do
      (old_object |> MapUtil.get(:id) == id)
        -> object_to_update
             |> Map.delete(:found_on_file_number)
      true
        -> old_object
    end
  end
  
end

