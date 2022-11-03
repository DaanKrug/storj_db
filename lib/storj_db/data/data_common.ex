defmodule StorjDB.DataCommon do

  @moduledoc false
  
  alias Krug.NumberUtil
  alias Krug.MapUtil
  
  def calculate_last_file(rows_perfile,last_file,objects) do
    cond do
      (Enum.empty?(objects))
        -> last_file
      (length(objects) > rows_perfile)
        -> last_file + 1
      true
        -> last_file
    end
  end
  
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
  
  
end