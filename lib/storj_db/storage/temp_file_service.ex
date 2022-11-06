defmodule StorjDB.TempFileService do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias Krug.FileUtil
  alias StorjDB.ConnectionConfig
  
  
  def write_file(filename,content) do
    filename 
      |> drop_file()               
    {:ok,pid} = "#{content}"
                  |> StringIO.open()
    cond do
      (nil == pid or !Process.alive?(pid))
        -> nil
      true
        -> EtsUtil.store_in_cache(:storj_db_app,filename,pid)
    end
    pid
  end
  
  #============================
  
  def read_file(filename) do
    pid = EtsUtil.read_from_cache(:storj_db_app,filename)
    cond do
      (nil == pid or !Process.alive?(pid))
        -> nil
      true
        -> pid
             |> StringIO.contents() 
             |> Tuple.to_list()
             |> hd()
    end
  end
  
  #============================
  
  def get_temp_file(filename) do
    content = filename
                |> read_file()
    dest_path = ConnectionConfig.read_database_config_path()
    file_path = "#{dest_path}/#{filename}"
    file_path
      |> FileUtil.write("#{content}")
    file_path
  end
  
  def drop_temp_file(file_path) do
    file_path
      |> FileUtil.drop_file()
  end
 
  #============================
  
  def drop_file(filename) do
    pid = EtsUtil.read_from_cache(:storj_db_app,filename)
    cond do
      (nil == pid or !Process.alive?(pid))
        -> true
      true
        -> pid  
             |> StringIO.close()  
             |> drop_file2(filename)
    end
  end
  
  defp drop_file2({:ok,_},filename) do
    EtsUtil.remove_from_cache(:storj_db_app,filename)
    pid = EtsUtil.read_from_cache(:storj_db_app,filename)
    (nil == pid)
  end
  
end




