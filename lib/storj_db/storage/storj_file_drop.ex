defmodule StorjDB.StorjFileDrop do

  @moduledoc false
  
  alias Krug.EtsUtil
  alias StorjDB.TempFileService


  def drop_file(bucket_name,filename) do
    deleted = TempFileService.drop_file(filename)
    cond do
      (!deleted)
        -> false
      true
        -> bucket_name
             |> drop_file2(filename)
    end
  end
  
  def drop_file2(bucket_name,filename) do
    only_local_disk = EtsUtil.read_from_cache(:storj_db_app,"only_local_disk")
    cond do
      (only_local_disk == 1 or only_local_disk == "1")
        -> true
      true
        -> bucket_name
             |> drop_file3(filename)
    end
  end
  
  defp drop_file3(bucket_name,filename) do
    storj_link = "sj://#{bucket_name}/#{filename}"
    executable = "uplink"
    arguments = ["rm",storj_link]
    {result, exit_status} = System.cmd(executable, arguments, stderr_to_stdout: true)
    cond do
      (exit_status != 0) 
        -> false
      (!(String.contains?(result,"Deleted #{storj_link}"))) 
        -> false
      true 
        -> true
    end
  end

end