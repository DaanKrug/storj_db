defmodule StorjDB.TempFileService do

  @moduledoc false
  
  alias Krug.EtsUtil
  
  def write_file(filename,content) do
    drop_file(filename)
    {:ok, pid} = StringIO.open(content)
    EtsUtil.store_in_cache(:storj_db_app,filename,pid)
    pid
  end
  
  def read_file(filename) do
    pid = EtsUtil.read_from_cache(:storj_db_app,filename)
    cond do
      (nil == pid)
        -> nil
      true
        -> pid
             |> StringIO.contents()
             |> read_file2()
    end
  end
  
  def read_file2({_, content}) do
    content
  end
  
  def drop_file(filename) do
    pid = EtsUtil.read_from_cache(:storj_db_app,filename)
    EtsUtil.remove_from_cache(:storj_db_app,filename)
    pid2 = EtsUtil.read_from_cache(:storj_db_app,filename)
    cond do
      (nil == pid2)
        -> pid
             |> StringIO.close()
             |> drop_file2()
      true
        -> false    
    end
  end
  
  defp drop_file2({:ok,_}) do
    true
  end
  
  defp drop_file2(_) do
    false
  end

end