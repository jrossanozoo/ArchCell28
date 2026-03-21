*!*	 ON ERROR DO LoguearErrorEnQUITVFP WITH ERROR( ), MESSAGE( ), MESSAGE(1), PROGRAM( ), LINENO( )

try
	set procedure to ('Organic.Core.app') additive
	set procedure to ('Organic.Drawing.app') additive

	_Screen.AddProperty( "Zoo" )
	_Screen.Zoo = Newobject( "Zoo", "Zoo.prg", "Organic.Core.app" )

	do AbrirManagerTaspein
catch to loError
	loEx = Newobject( 'ZooException', 'ZooException.prg', "Organic.Core.app" )
	loEx.Grabar( loError )

	messagebox(loEx.message)
endtry

return


*-----------------------------------------------------------------------------------------
function LoguearErrorEnQUITVFP( merror, mess, mess1, mprog, mlineno )
	local lcArchivo as string
    
    if !directory("log")
        mkdir("log")
    endif

    lcArchivo = "log\salidaunicaSistema.err"

	try    
		strtofile( transform( datetime()) + " Error en salidaunicaSistema.LoguearErrorEnQUITVFP" + chr(13) + chr(10) , lcArchivo, 1 )
		strtofile( "Error number...........:  " + LTRIM(STR(merror)) + chr(13) + chr(10), lcArchivo, 1 )
		strtofile( "Error message..........: " + mess + chr(13) + chr(10), lcArchivo, 1 )
		strtofile( "Line of code with error: " + mess1 + chr(13) + chr(10), lcArchivo, 1 )
		strtofile( "Line number of error...: " + LTRIM(STR(mlineno)) + chr(13) + chr(10), lcArchivo, 1 )
		strtofile( "Program with error.....: " + mprog + chr(13) + chr(10), lcArchivo, 1 )
	catch
		strtofile( "Error en salidaunicaSistema.LoguearErrorEnQUITVFP", lcArchivo, 1 )
	endtry
endfunc 

