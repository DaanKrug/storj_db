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
              |> search_table_in_schema(table_name)
    cond do
      (nil == table)
        -> database_schema 
             |> add_table2(table_name,rows_perfile)
      true
        -> table 
             |> MapUtil.replace(:rows_perfile, rows_perfile)
             |> update_tables(database_schema)
    end
  end
  
  defp add_table2(database_schema,table_name,rows_perfile) do
    tables = database_schema
               |> MapUtil.get(:tables)
    tables = [new_table(table_name,rows_perfile) | tables]
               |> Enum.reverse()
    database_schema
      |> MapUtil.replace(:tables, tables)
  end
  
  defp new_table(table_name,rows_perfile) do
    %{
      table_name: table_name,
      rows_perfile: rows_perfile,
      last_file: 0
    }
  end
  
  defp update_tables(table,database_schema) do
    tables = database_schema
               |> MapUtil.get(:tables)
    tables = replace_table(table,tables)
    database_schema
      |> MapUtil.replace(:tables, tables)
  end
  
  defp replace_table(table,tables,tables_new \\ []) do
    cond do
      (Enum.empty?(tables))
        -> tables_new
             |> Enum.reverse()
      true
        -> table
             |> replace_table2(tables,tables_new)
    end
  end
  
  defp replace_table2(table,tables,tables_new) do
    table2 = tables
               |> hd()
    cond do
      (table |> MapUtil.get(:table_name)
        == table2 |> MapUtil.get(:table_name))
          -> table
               |> replace_table(tables |> tl(), [table | tables_new])
      true
        -> table
             |> replace_table(tables |> tl(), [table2 | tables_new])
    end
  end
  
  defp search_table_in_schema(database_schema,table_name) do
    database_schema
      |> MapUtil.get(:tables)
      |> search_table_in_schema2(table_name)
  end
  
  defp search_table_in_schema2(tables,table_name) do
    cond do
      (Enum.empty?(tables))
        -> nil
      (tables 
        |> hd() 
        |> MapUtil.get(:table_name) == table_name)
          -> tables
               |> hd()
      true
        -> tables
             |> tl()
             |> search_table_in_schema2(table_name)
    end
  end

end














