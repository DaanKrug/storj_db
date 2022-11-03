defmodule StorjDB.DataRestore do

  @moduledoc false
  
  alias StorjDB.DataCommon
  
  def restore(table_name,object) do
    keys = object 
             |> Map.keys()
  end
  
  
  
  defp match_criteria() do
    # DataCommon.match_id(object_criteria,object)
    # DataCommon.match_key(object_criteria,object,key)
  end
  
  
  def list(table_name,object_criteria,max_results,single_match, filtered_objects \\[]) do
    objects = []
    keys = object_criteria 
             |> Map.keys()
    filtered_objects = filter_results(object_criteria,keys,max_results,objects,filtered_objects,single_match)
  end
  
  defp filter_results(object_criteria,keys,max_results,objects,filtered_objects,single_match) do
    cond do
      (Enum.empty?(objects))
        -> filtered_objects 
             |> Enum.reverse()
      (max_results > 0 and length(filtered_objects) >= max_results)
        -> filtered_objects 
             |> Enum.reverse()
      true
        -> object_criteria
             |> filter_results2(keys,max_results,objects,filtered_objects,single_match)
    end
  end
  
  defp filter_results2(object_criteria,keys,max_results,objects,filtered_objects,single_match) do
    object = objects 
               |> hd()
    objects = objects 
                |> tl()
    match = match_keys(object_criteria,object,keys,single_match)
    cond do
      (!match) 
        -> object_criteria
             |> filter_results(keys,max_results,objects,filtered_objects,single_match)
      true
        -> object_criteria
             |> filter_results(keys,max_results,objects,[object | filtered_objects],single_match)
    end
  end


  
end



