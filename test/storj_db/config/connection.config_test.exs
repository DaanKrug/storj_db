defmodule StorjDB.ConnectionConfigTest do

  use ExUnit.Case

  doctest StorjDB.ConnectionConfig
  
  alias StorjDB.ConnectionConfig
  alias Krug.FileUtil
  
  test "[config_connection()]" do
    "./storj_db.config.txt" 
      |> FileUtil.drop_file()
    result = ConnectionConfig.config_connection()
    assert result == true
  end
  
end