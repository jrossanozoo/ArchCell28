$vfp = New-Object -ComObject "VisualFoxPro.Application"; try { $vfp.DoCmd("ERROR 1099") } catch { $_.Exception.Message }; $vfp.Quit()
