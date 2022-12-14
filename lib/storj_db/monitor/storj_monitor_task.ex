defmodule StorjDB.StorjMonitorTask do
 
  use Task
  alias StorjDB.StorjFileDebugg
  alias StorjDB.DatabaseSchema
  alias StorjDB.ConnectionConfig
 
  def start_link(opts) do
    Task.start_link(__MODULE__, :run, [opts])
  end

  def run(_opts) do
  	StorjDB.ConnectionConfig.ok_operation()
    run_loop()
  end
  
  defp run_loop() do
    try do
      "\n\n\n StorjMonitorTask run_loop"
        |> StorjFileDebugg.info()
      StorjDB.synchronize_all()
      StorjDB.cleanup_all()
      DatabaseSchema.synchronize_database_schema()
      :timer.sleep(10000)
      run_loop()
    rescue
      _ -> rescue_run_loop()
    end
  end
  
  defp rescue_run_loop() do
  	IO.puts("StorjMonitorTask: Rescued from Error: going sleep for 5 second before retry.")
    :timer.sleep(5000)
    run_loop()
  end
  
end