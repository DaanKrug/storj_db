defmodule StorjDB.StorjFileDebugg do

  @moduledoc false
  
  alias Krug.BooleanUtil
  alias Krug.EtsUtil
  
  def info(anything) do
    debugg = EtsUtil.read_from_cache(:storj_db_app,"debugg")
    cond do
      (BooleanUtil.equals(true,debugg))
        -> anything
             |> IO.inspect()
      true
        -> :ok
    end
  end
  
end