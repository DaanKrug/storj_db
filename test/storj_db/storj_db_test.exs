

defmodule StorjDBTest do

  use ExUnit.Case

  doctest StorjDB
  
  alias StorjDB
  
  
  test "[create(table,object)]" do
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
    ok = StorjDB.create("trutas",t1)
    ok2 = StorjDB.create("trutas",t2)
    ok3 = StorjDB.create("carnes",c1)
    ok4 = StorjDB.create("carnes",c2)
    assert ok == ok2
    assert ok3 == ok2
    assert ok3 == ok4
    assert ok4 == ok
  end
  
end