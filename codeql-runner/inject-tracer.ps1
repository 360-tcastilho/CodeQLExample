
      Param(
          [Parameter(Position=0)]
          [String]
          $tracer
      )

      $id = $PID
      for ($i = 0; $i -le 3; $i++) {
        $p = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $id"
        Write-Host "Parent process ${i}: $p"
        if ($p -eq $null) {
          throw "Process tree ended before reaching required level"
        }
        # Special case just in case the runner is used on actions
        if ($p[0].Name -eq "Runner.Worker.exe") {
          Write-Host "Found Runner.Worker.exe process which means we are running on GitHub Actions"
          Write-Host "Aborting search early and using process: $p"
          Break
        } elseif ($p[0].Name -eq "Agent.Worker.exe") {
          Write-Host "Found Agent.Worker.exe process which means we are running on Azure Pipelines"
          Write-Host "Aborting search early and using process: $p"
          Break
        } else {
          $id = $p[0].ParentProcessId
        }
      }
      Write-Host "Final process: $p"

      Invoke-Expression "&$tracer --inject=$id"