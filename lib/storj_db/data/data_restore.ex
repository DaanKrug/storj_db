defmodule StorjDB.DataRestore do

  @moduledoc false
  
  
  alias StorjDB.DataCommon
  alias Krug.EtsUtil
  alias Krug.MapUtil
  
 
  def load_by_id(table_name,id) do
    [
      last_file,
      _rows_perfile,
      _total_rows,
      last_id
    ] = table_name 
          |> DataCommon.read_table_info()
    object_criteria = %{
      id: id
    }
    keys = object_criteria
             |> Map.keys()
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    sort_desc = id >= (last_id/2)
    cond do
      (sort_desc)
        -> bucket_name
             |> list_from_filepages_desc(table_name,object_criteria,1,true,keys,last_file)
             |> DataCommon.first_of_list()
      true
        -> bucket_name
             |> list_from_filepages_asc(table_name,object_criteria,1,true,keys,0,last_file)
             |> DataCommon.first_of_list()
    end
  end
  
  def load_all(table_name,object_criteria,max_results \\ -1,single_match \\ true,sort_desc \\ false) do
    [
      last_file,
      _rows_perfile,
      _total_rows,
      _last_id
    ] = table_name 
          |> DataCommon.read_table_info()
    keys = object_criteria 
             |> Map.keys()
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    cond do
      (sort_desc)
        -> bucket_name
             |> list_from_filepages_desc(table_name,object_criteria,max_results,single_match,keys,last_file)
      true
        -> bucket_name
             |> list_from_filepages_asc(table_name,object_criteria,max_results,single_match,keys,0,last_file)
    end
  end
  
  defp list_from_filepages_desc(bucket_name,table_name,object_criteria,
                                max_results,single_match,keys,file_number,all_filtered_objects \\ []) do
    cond do
      (file_number < 0)
        -> all_filtered_objects
      (max_results > 0 and length(all_filtered_objects) >= max_results)
        -> all_filtered_objects
      true
        -> bucket_name
             |> list_from_filepages_desc2(table_name,object_criteria,
                                          max_results,single_match,keys,file_number,all_filtered_objects)
    end
  end
  
  defp list_from_filepages_desc2(bucket_name,table_name,object_criteria,
                                 max_results,single_match,keys,file_number,all_filtered_objects) do
    all_filtered_objects = 
      list_from_filepage(bucket_name,table_name,object_criteria,max_results,
                         single_match,keys,file_number,true,all_filtered_objects)    
    list_from_filepages_desc(bucket_name,table_name,object_criteria,
                             max_results,single_match,keys,file_number - 1,all_filtered_objects)          
  end
  
  defp list_from_filepages_asc(bucket_name,table_name,object_criteria,
                               max_results,single_match,keys,file_number,
                               max_file_number,all_filtered_objects \\ []) do
    cond do
      (file_number > max_file_number)
        -> all_filtered_objects
      (max_results > 0 and length(all_filtered_objects) >= max_results)
        -> all_filtered_objects
      true
        -> bucket_name
             |> list_from_filepages_asc2(table_name,object_criteria,
                                         max_results,single_match,keys,file_number,
                                         max_file_number,all_filtered_objects)
    end
  end
  
  defp list_from_filepages_asc2(bucket_name,table_name,object_criteria,
                                max_results,single_match,keys,file_number,
                                max_file_number,all_filtered_objects) do
    all_filtered_objects = 
      list_from_filepage(bucket_name,table_name,object_criteria,max_results,
                         single_match,keys,file_number,false,all_filtered_objects)    
    list_from_filepages_asc(bucket_name,table_name,object_criteria,
                               max_results,single_match,keys,file_number + 1,
                               max_file_number,all_filtered_objects)          
  end
  
  defp list_from_filepage(bucket_name,table_name,object_criteria,max_results,
                          single_match,keys,file_number,sort_desc,filtered_objects) do
    objects = DataCommon.read_table_objects(bucket_name,table_name,file_number)
    cond do
      (Enum.empty?(objects))
        -> []
      (sort_desc)
        -> objects
             |> Enum.reverse()
             |> filter_results(object_criteria,keys,max_results,filtered_objects,single_match,file_number)
      true
        -> objects
             |> filter_results(object_criteria,keys,max_results,filtered_objects,single_match,file_number)
    end
  end
  
  defp filter_results(objects,object_criteria,keys,max_results,filtered_objects,single_match,file_number) do
    cond do
      (Enum.empty?(objects))
        -> filtered_objects 
             |> Enum.reverse()
      (max_results > 0 and length(filtered_objects) >= max_results)
        -> filtered_objects 
             |> Enum.reverse()
      true
        -> objects 
             |> filter_results2(object_criteria,keys,max_results,filtered_objects,single_match,file_number)
    end
  end
  
  defp filter_results2(objects,object_criteria,keys,max_results,filtered_objects,single_match,file_number) do
    object = objects 
              |> hd()
    match = object
              |> DataCommon.match_keys(object_criteria,keys,single_match)
    cond do
      (!match) 
        -> objects
             |> tl()
             |> filter_results(object_criteria,keys,max_results,filtered_objects,single_match,file_number)
      true
        -> objects
             |> tl()
             |> filter_results(object_criteria,keys,max_results,
                               [object |> prepare_matched_object(file_number,max_results) | filtered_objects],
                               single_match,file_number)
    end
  end
  
  defp prepare_matched_object(object,file_number,max_results) do
    cond do
      (max_results != 1)
        -> object
      true
        -> object
             |> MapUtil.replace(:found_on_file_number,file_number)
    end
  end
  
end



