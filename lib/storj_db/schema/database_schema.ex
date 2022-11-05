defmodule StorjDB.DatabaseSchema do

  @moduledoc false

  alias Krug.MapUtil
  alias Krug.EtsUtil
  alias StorjDB.FileService
  alias StorjDB.ConnectionConfig
  

  def new() do
    %{
      tables: []
    }
  end
  
  def drop_database_schema() do
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    filename = EtsUtil.read_from_cache(:storj_db_app,"database_schema")
    FileService.drop_file(bucket_name,filename)
  end
  
  def remove_table_from_schema(table_name) do 
    database_schema = read_database_schema()
    tables = database_schema
               |> MapUtil.get(:tables)
               |> remove_table(table_name)
    database_schema
      |> MapUtil.replace(:tables, tables)
      |> write_database_schema()
  end
  
  def read_table_schema(table_name,nil_if_nil \\ false) do
    table = read_database_schema() 
              |> search_table_in_schema(table_name)
    cond do
      (nil_if_nil and nil == table)
        -> nil
      (nil == table)
        -> table_name
             |> update_schema(-1,0,0,0,true)
      true
        -> table
    end
  end
  
  def update_schema_by_schema_info(schema_info) do
    [
      table_name,
      rows_perfile,
      last_file,
      total_rows, 
      last_id, 
      return_table
    ] = schema_info
    table_name
      |> update_schema(rows_perfile,last_file,total_rows, last_id, return_table)
  end
  
  defp update_schema(table_name,rows_perfile,last_file,total_rows, last_id, return_table) do
    database_schema = read_database_schema()
                        |> update_schema2(table_name,rows_perfile,last_file,total_rows,last_id)
    database_schema
      |> write_database_schema()
    cond do
      (return_table)
        -> database_schema 
             |> search_table_in_schema(table_name)
      true
        -> :ok
    end
  end
  
  defp write_database_schema(database_schema) do
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    filename = EtsUtil.read_from_cache(:storj_db_app,"database_schema")
    content = database_schema 
                |> Poison.encode!() 
    FileService.write_file_content(bucket_name,filename,content)
  end
  
  defp read_database_schema() do
    bucket_name = EtsUtil.read_from_cache(:storj_db_app,"bucket_name")
    filename = EtsUtil.read_from_cache(:storj_db_app,"database_schema")
    database_schema = FileService.read_file_content(bucket_name,filename)
    cond do
      (nil == database_schema or database_schema == "")
        -> new()
      true
        -> database_schema
             |> Poison.decode!()
    end
  end
  
  defp update_schema2(database_schema,table_name,rows_perfile,last_file,total_rows,last_id) do
    table = database_schema 
              |> search_table_in_schema(table_name)
    cond do
      (nil == table)
        -> database_schema 
             |> add_table(table_name,rows_perfile)
      true
        -> table 
             |> MapUtil.replace(:rows_perfile, rows_perfile)
             |> MapUtil.replace(:last_file, last_file)
             |> MapUtil.replace(:total_rows, total_rows)
             |> MapUtil.replace(:last_id, last_id)
             |> update_tables(database_schema)
    end
  end
  
  defp add_table(database_schema,table_name,rows_perfile) do
    tables = database_schema
               |> MapUtil.get(:tables)
    tables = [new_table(table_name,rows_perfile) | tables]
               |> Enum.reverse()
    database_schema
      |> MapUtil.replace(:tables, tables)
  end
  
  defp new_table(table_name,rows_perfile) do
    rows_perfile = table_name 
                     |> ConnectionConfig.read_rows_perfile_if_undefined(rows_perfile)
    %{
      table_name: table_name,
      rows_perfile: rows_perfile,
      last_file: 0,
      total_rows: 0,
      last_id: 0
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
    cond do
      (nil == database_schema)
        -> nil
      true
        -> database_schema
             |> MapUtil.get(:tables)
             |> search_table_in_schema2(table_name)
    end
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
  
  defp remove_table(tables,table_name,tables_new \\ []) do
    cond do
      (Enum.empty?(tables))
        -> tables_new
             |> Enum.reverse()
      true
        -> remove_table2(tables,table_name,tables_new)
    end
  end
  
  defp remove_table2(tables,table_name,tables_new) do
    table = tables
              |> hd()
    cond do
      (table |> MapUtil.get(:table_name) == table_name)
        -> tables 
             |> tl()
             |> remove_table(table_name,tables_new) 
      true
        -> tables 
             |> tl()
             |> remove_table(table_name,[table | tables_new]) 
    end
  end

end


