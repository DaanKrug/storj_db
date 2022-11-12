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
    sinchronize = EtsUtil.read_from_cache(:storj_db_app,"synchronize_drop_#{filename}")
    cond do
      (!sinchronize)
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
    [result, exit_status]
      |> IO.inspect()
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