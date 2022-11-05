defmodule StorjDBTest do

  use ExUnit.Case

  doctest StorjDB
  
  alias StorjDB
  alias Krug.MapUtil
  
  
  test "[create(...) | load_by_id(...) | load_all(...)]" do
    StorjDB.reset_data_dir()
    
    tt1 = StorjDB.load_by_id("trutas",1)
    cc1 = StorjDB.load_by_id("carnes",1)
    
    assert tt1 == nil
    assert cc1 == nil
    
    t1 = %{
      nome: "truta 1",
      qualidade: "Q3"
    }
    t2 = %{
      nome: "truta 2",
      qualidade: "Q7"
    }
    c1 = %{
      nome: "File de Primeira",
      qualidade: "Q0"
    }
    c2 = %{
      nome: "Costelinha Barbecue do Madero",
      qualidade: "Q0+"
    }
    
    StorjDB.create("trutas",t1)
    tt1 = StorjDB.load_by_id("trutas",1)
    assert (tt1 |> MapUtil.get(:nome)) == (t1 |> MapUtil.get(:nome))
    assert (tt1 |> MapUtil.get(:found_on_file_number)) == 0
    
    StorjDB.reset_data_dir()
    
    tt1 = StorjDB.load_by_id("trutas",1)
    cc1 = StorjDB.load_by_id("carnes",1)
    
    assert tt1 == nil
    assert cc1 == nil
    
    ok = StorjDB.create("trutas",t1)
    ok2 = StorjDB.create("trutas",t2)
    ok3 = StorjDB.create("carnes",c1)
    ok4 = StorjDB.create("carnes",c2)
    assert ok == ok2
    assert ok3 == ok2
    assert ok3 == ok4
    assert ok4 == ok
    
    tt1 = StorjDB.load_by_id("trutas",1)
    tt2 = StorjDB.load_by_id("trutas",2)
    tt3 = StorjDB.load_by_id("trutas",3)
    
    assert (tt1 |> MapUtil.get(:nome)) == (t1 |> MapUtil.get(:nome))
    assert (tt2 |> MapUtil.get(:nome)) == (t2 |> MapUtil.get(:nome))
    assert (tt1 |> MapUtil.get(:qualidade)) == (t1 |> MapUtil.get(:qualidade))
    assert (tt2 |> MapUtil.get(:qualidade)) == (t2 |> MapUtil.get(:qualidade))
    assert (tt1 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt2 |> MapUtil.get(:found_on_file_number)) == 0
    assert tt3 == nil
    
    cc1 = StorjDB.load_by_id("carnes",1)
    cc2 = StorjDB.load_by_id("carnes",2)
    cc3 = StorjDB.load_by_id("carnes",3)
    
    assert (cc1 |> MapUtil.get(:nome)) == (c1 |> MapUtil.get(:nome))
    assert (cc2 |> MapUtil.get(:nome)) == (c2 |> MapUtil.get(:nome))
    assert (cc1 |> MapUtil.get(:qualidade)) == (c1 |> MapUtil.get(:qualidade))
    assert (cc2 |> MapUtil.get(:qualidade)) == (c2 |> MapUtil.get(:qualidade))
    assert (cc1 |> MapUtil.get(:found_on_file_number)) == 0
    assert (cc2 |> MapUtil.get(:found_on_file_number)) == 0
    assert cc3 == nil
    
    object_criteria = %{
      nome: "echo ping"
    }
    max_results = 1
    single_match = true
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert Enum.empty?(results)
    
    object_criteria = %{
      nome: "truta"
    }
    max_results = 1
    single_match = true
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 1
    assert (tt1 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == 0
    
    object_criteria = %{
      nome: "truta"
    }
    max_results = 1
    single_match = true
    sort_desc = true
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 1
    assert (tt2 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == 0
    
    StorjDB.reset_data_dir()
    
    tt1 = StorjDB.load_by_id("trutas",1)
    cc1 = StorjDB.load_by_id("carnes",1)
    
    assert tt1 == nil
    assert cc1 == nil
    
    t3 = %{
      nome: "truta boa",
      qualidade: "Q3"
    }
    t4 = %{
      nome: "truta boa",
      qualidade: "Q4"
    }
    t5 = %{
      nome: "treta ruim",
      qualidade: "Q3"
    }
    
    StorjDB.create("trutas",t3)
    StorjDB.create("trutas",t4)
    StorjDB.create("trutas",t5)
    
    tt3 = StorjDB.load_by_id("trutas",1)
    tt4 = StorjDB.load_by_id("trutas",2)
    tt5 = StorjDB.load_by_id("trutas",3)
    
    assert (tt3 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt4 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt5 |> MapUtil.get(:found_on_file_number)) == 0
    
    object_criteria = %{
      nome: "truta boa"
    }
    max_results = 10
    single_match = true
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 2
    assert (tt3 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    assert (results |> tl() |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    
    object_criteria = %{
      qualidade: "Q3"
    }
    max_results = 10
    single_match = true
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 2
    assert (tt3 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    assert (results |> tl() |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    
    object_criteria = %{
      nome: "truta boa",
      qualidade: "Q3"
    }
    max_results = 10
    single_match = true
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 3
    assert (tt3 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    assert (results |> tl() |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    assert (results |> tl() |> tl() |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    
    object_criteria = %{
      nome: "truta boa",
      qualidade: "Q3"
    }
    max_results = 10
    single_match = false
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 1
    assert (tt3 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    
    object_criteria = %{
      nome: "truta boa",
      qualidade: "Q4"
    }
    max_results = 10
    single_match = false
    sort_desc = false
    results = StorjDB.load_all("trutas",object_criteria,max_results,single_match,sort_desc)
    assert length(results) == 1
    assert (tt4 |> MapUtil.get(:id)) == (results |> hd() |> MapUtil.get(:id))
    assert (results |> hd() |> MapUtil.get(:found_on_file_number)) == nil
    
  end
  
end





