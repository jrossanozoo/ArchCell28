$vfp = New-Object -ComObject "VisualFoxPro.Application"; try { $vfp.DoCmd("DO C:\test.prg") } catch { $_.Exception.Message }; $vfp.Quit()
