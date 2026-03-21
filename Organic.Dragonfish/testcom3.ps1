$vfp = New-Object -ComObject "VisualFoxPro.Application"; try { $vfp.DoCmd("DEFINE CLASS test as NotExist OF nonexistent.prg") } catch { $_.Exception.Message }; $vfp.Quit()
