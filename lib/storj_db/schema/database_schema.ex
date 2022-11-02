defmodule StorjDB.DatabaseSchema do

  @moduledoc false

  alias Krug.MapUtil

  def new() do
    %{
      tables: []
    }
  end
  
  def add_table(database_schema,table_name,rows_perfile \\ 1000) do
    table = database_schema 
              |> search_table_in_schema()
    cond do
      (nil == table)
        -> database_schema 
             |> add_table2(table_name,rows_perfile)
      true
        -> table 
             |> MapUtil.replace(:rows_perfile, rows_perfile)
             |> update_table(database_schema)
    end
  end
  
  defp add_table2(database_schema,table_name,rows_perfile) do
    tables = database_schema
               |> MapUtil.get(:tables)
    tables = tables 
               |> MapUtil.replace(:tables, [new_table(table_name,rows_perfile) | tables])
    database_schema
      |> MapUtil.replace(:tables, tables)
  end
  
  defp new_table(table_name,rows_perfile) do
    %{
      table_name: table_name,
      rows_perfile: rows_perfile
    }
  end
  
  defp update_table(table,database_schema, tables \\ []) do
  
  end

end