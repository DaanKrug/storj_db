defmodule StorjDB.DataUpdate do

  @moduledoc false
  
  
  def update(table_name,object) do
    
    id = object 
               |> MapUtil.get(:id)
    
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
  end
  
end