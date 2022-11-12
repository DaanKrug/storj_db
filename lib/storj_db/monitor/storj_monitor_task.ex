defmodule StorjDB.StorjMonitorTask do
 
  use Task
  alias StorjDB.StorjFileDebugg
  
  @initialization_timer 1000
  
 
  def start_link(opts) do
    Task.start_link(__MODULE__, :run, [opts])
  end

  def run(_opts) do
  	:timer.sleep(@initialization_timer)
    run_loop()
  end
  
  defp run_loop() do
    try do
      "\n\n\n StorjMonitorTask run_loop"
        |> StorjFileDebugg.info()
      StorjDB.synchronize_all()
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