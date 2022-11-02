defmodule StorjDB.ConnectionConfigTest do

  use ExUnit.Case

  doctest StorjDB.ConnectionConfig
  
  alias StorjDB.ConnectionConfig
  alias Krug.FileUtil
  
  
  test "[config_connection()]" do
    "./storj_db.config.sample.txt" 
      |> FileUtil.drop_file()
    "./storj_db.config.txt" 
      |> FileUtil.drop_file()
    message = """
              A sample config file was writted to './storj_db.config.sample.txt'.
              Please edit this file and rename to './storj_db.config.txt' 
              """
    result = ConnectionConfig.config_connection()
    assert result == message
  end
  
  test "[config_connection(base_path)]" do
    base_path = "/var/www/html/storj_db"
    "#{base_path}/storj_db.config.sample.txt" 
      |> FileUtil.drop_file()
    "#{base_path}/storj_db.config.txt" 
      |> FileUtil.drop_file()
    message = """
              A sample config file was writted to '#{base_path}/storj_db.config.sample.txt'.
              Please edit this file and rename to '#{base_path}/storj_db.config.txt' 
              """
    result = base_path 
               |> ConnectionConfig.config_connection()
    assert result == message
  end
  
  test "[config_connection()] try read schema" do
    "./storj_db.config.sample.txt" 
      |> FileUtil.drop_file()
    "./storj_db.config.txt" 
      |> FileUtil.drop_file()
    message = """
              A sample config file was writted to './storj_db.config.sample.txt'.
              Please edit this file and rename to './storj_db.config.txt' 
              """
    result = ConnectionConfig.config_connection()
    assert result == message
    File.rename("./storj_db.config.sample.txt","./storj_db.config.txt")
    result = ConnectionConfig.config_connection()
    assert result == ["my_bucket", "my_database", nil]
  end

end