defmodule StorjDBTest do

  use ExUnit.Case

  doctest StorjDB
  
  @time_sleep 10000
  @use_debugg true
  
  alias StorjDB
  alias Krug.MapUtil
  alias Krug.EtsUtil
  alias StorjDB.StorjFileDebugg
  
  
  test "[create(...) | load_by_id(...) - 1]" do
    EtsUtil.store_in_cache(:storj_db_app,"debugg",@use_debugg)
    "\n\n\n Test 001"
      |> StorjFileDebugg.info()
    
    @time_sleep 
      |> :timer.sleep()
      
    tt1 = StorjDB.load_by_id("trutas",1)
    
    assert tt1 == nil
    
    t1 = %{
      nome: "truta 1",
      qualidade: "Q3"
    }
    
    StorjDB.create("trutas",t1)
    tt1 = StorjDB.load_by_id("trutas",1)
    assert (tt1 |> MapUtil.get(:nome)) == (t1 |> MapUtil.get(:nome))
    assert (tt1 |> MapUtil.get(:found_on_file_number)) == 0
    
    @time_sleep 
      |> :timer.sleep()
      
    EtsUtil.store_in_cache(:storj_db_app,"debugg",false)
  end
  
end
