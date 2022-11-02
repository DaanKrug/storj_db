defmodule StorjDB.DatabaseSchema do

  @moduledoc false

  alias Krug.MapUtil

  def new() do
    %{
      tables: []
    }
  end
  
  def add_table(database_schema,table_name,rows_perfile \\ 1000) do
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

end