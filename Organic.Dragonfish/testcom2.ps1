$vfp = New-Object -ComObject "VisualFoxPro.Application"; try { $vfp.DoCmd("CANCEL") } catch { $_.Exception.Message }; $vfp.Quit()
