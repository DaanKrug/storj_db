defmodule StorjDB.DataCommon do

  @moduledoc false
  
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
  
  
end