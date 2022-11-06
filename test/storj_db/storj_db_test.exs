defmodule StorjDBTest do

  use ExUnit.Case

  doctest StorjDB
  
  alias StorjDB
  alias Krug.MapUtil
  
  
  test "[create(...) | load_by_id(...) - 1]" do
    "trutas" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
    
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
    
    "trutas" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
  end
  
  test "[create(...) | load_by_id(...) - 2]" do
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
    
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
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
    
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
  end
  
  test "[load_all(...) - 1]" do
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
    
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
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
    
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
  end
    
  test "[load_all(...) - 2]" do
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
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
    
    
    tt3 = tt3 
            |> MapUtil.replace(:nome, "truta t3")
            |> MapUtil.replace(:nome2, "truta t3")
            |> MapUtil.replace(:nome3, "truta t3")
            
    tt4 = tt4 
            |> MapUtil.replace(:nome, "truta t4")
            |> MapUtil.replace(:nome2, "truta t4")
            |> MapUtil.replace(:nome3, "truta t4")
            
    tt5 = tt5 
            |> MapUtil.replace(:nome, "truta t5")
            |> MapUtil.replace(:nome2, "truta t5")
            |> MapUtil.replace(:nome3, "truta t5")
    
    StorjDB.update("trutas",tt3)
    StorjDB.update("trutas",tt4)
    StorjDB.update("trutas",tt5)
    
    tt3 = StorjDB.load_by_id("trutas",1)
    tt4 = StorjDB.load_by_id("trutas",2)
    tt5 = StorjDB.load_by_id("trutas",3)
    
    assert (tt3 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt3 |> MapUtil.get(:nome)) == "truta t3"
    assert (tt3 |> MapUtil.get(:nome2)) == "truta t3"
    assert (tt3 |> MapUtil.get(:nome3)) == "truta t3"
    
    assert (tt4 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt4 |> MapUtil.get(:nome)) == "truta t4"
    assert (tt4 |> MapUtil.get(:nome2)) == "truta t4"
    assert (tt4 |> MapUtil.get(:nome3)) == "truta t4"
    
    assert (tt5 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt5 |> MapUtil.get(:nome)) == "truta t5"
    assert (tt5 |> MapUtil.get(:nome2)) == "truta t5"
    assert (tt5 |> MapUtil.get(:nome3)) == "truta t5"
    
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
  end
    
  test "[delete(...) | delete_by_id(...) | read_table_info(...) | drop_table(...) ]" do
    "trutas" 
          |> StorjDB.drop_table()
    "carnes" 
          |> StorjDB.drop_table()
    StorjDB.reset_data_dir()
    
    tt1 = StorjDB.load_by_id("trutas",1)
    cc1 = StorjDB.load_by_id("carnes",1)
    
    assert tt1 == nil
    assert cc1 == nil
    
    t3 = %{
      nome: "truta t3",
      qualidade: "Q3"
    }
    t4 = %{
      nome: "truta t4",
      qualidade: "Q4"
    }
    t5 = %{
      nome: "treta t5",
      qualidade: "Q3"
    }
    
    StorjDB.create("trutas",t3)
    StorjDB.create("trutas",t4)
    StorjDB.create("trutas",t5)
    
    tt3 = StorjDB.load_by_id("trutas",1)
    tt4 = StorjDB.load_by_id("trutas",2)
    
    StorjDB.delete_by_id("trutas",3)
    StorjDB.delete("trutas",tt4)
    
    assert (tt3 |> MapUtil.get(:found_on_file_number)) == 0
    assert (tt3 |> MapUtil.get(:nome)) == "truta t3"
    
    tt4 = StorjDB.load_by_id("trutas",2)
    tt5 = StorjDB.load_by_id("trutas",3)
    
    assert tt4 == nil
    assert tt5 == nil
    
    [
      last_file,
      rows_perfile,
      total_rows,
      last_id
    ] = "trutas" 
          |> StorjDB.read_table_info()
          
    assert last_file == 0
    assert rows_perfile == 100
    assert total_rows == 1
    assert last_id == (tt3 |> MapUtil.get(:id))
    
    "trutas" 
          |> StorjDB.drop_table()
    
    [
      last_file,
      rows_perfile,
      total_rows,
      last_id
    ] = "trutas" 
          |> StorjDB.read_table_info()
          
    assert last_file == nil
    assert rows_perfile == nil
    assert total_rows == nil
    assert last_id == nil  
    
       
  end
  
end





