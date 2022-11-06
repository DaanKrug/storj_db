defmodule StorjDB.TempFileService do

  @moduledoc false
  
  alias Krug.EtsUtil
  
  def write_file(filename,content) do
    drop_file(filename)
    {:ok, pid} = StringIO.open("")
    IO.write(pid,content)
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
    EtsUtil.remove_from_cache(:storj_db_app,filename)
  end

  # EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")

end