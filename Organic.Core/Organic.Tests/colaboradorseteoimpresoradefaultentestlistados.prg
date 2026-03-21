Define Class ColaboradorSeteoImpresoraDefaultEnTestListados As Custom

	#If .F.
		Local This As ColaboradorSeteoImpresoraDefaultEnTestListados Of ColaboradorSeteoImpresoraDefaultEnTestListados.prg
	#Endif
	
	protected cPrinterBackup
	cPrinterBackup = "" && Backup de impresora
	cImpresoraParaTest = "FINEPRINT"
	cDriverImpresora = "FINEPRINT 7"
	
	*-----------------------------------------------------------------------------------------
	function EsMaquinaVirtual() as Void
		local pcname as string 
		pcname = getenv("COMPUTERNAME")
		return left(pcname,6)=="ABTEST" or (left(pcname,2) == "AB" and len(pcname)<=4)
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	Function SetearImpresoraFinePrint() As Void
		This.cPrinterBackup = Upper( Alltrim( Set( "Printer", 2 ) ) )

		Local llOk As boolean, lcImpresora As String, liPrint As Integer, i As Integer
		Local Array laImpresoras(1)

		llOk = .F.
		lcImpresora = ""
		liPrint = 0

		if _screen.zoo.EsBuildAutomatico and this.EsMaquinaVirtual()
			this.cImpresoraParaTest = "Microsoft Print to PDF"
			this.cDriverImpresora = "Microsoft Print To PDF"			
		endif

		Aprinters( laImpresoras, 1 )
		For i = 1 To Alen( laImpresoras, 1 )
			If upper(This.cImpresoraParaTest) == Upper( Alltrim( laImpresoras[ i, 1 ] ) )
				lcImpresora = Upper( Alltrim( laImpresoras[ i, 1 ] ) )
				llOk = .T.
				liPrint = i
				Exit
			Endif
		Endfor

		If !llOk
			goServicios.Errores.LevantarExcepcion( "La impresora que contenga " + This.cImpresoraParaTest + " en el nombre no esta instalada. Los test no son válidos." )
		Endif

		If liPrint == 0
			goServicios.Errores.LevantarExcepcion( "No se puede correr el test sin la impresora necesaria." )
		Else
			this.SetearImpresoraPredeterminada(lcImpresora)
			Set Printer To Name ( lcImpresora )
			If upper(this.cDriverImpresora) != Upper( Alltrim( laImpresoras[ liPrint , 3 ] ) )
				goServicios.Errores.LevantarExcepcion( "No esta bien configurado el driver de la impresora (Driver: " + this.cDriverImpresora + " - Nombre:" + lcImpresora + ")" )
			Endif
			If lcImpresora != Set( "Printer", 3 )
				goServicios.Errores.LevantarExcepcion( "No se seteo la impresora seleccionada (Driver: " + this.cDriverImpresora + " - Nombre:" + lcImpresora + ")"  )
			Endif
		Endif
	Endfunc

	*TearDown
	*-----------------------------------------------------------------------------------------
	Function SetearImpresoraPredeterminadaAntesDelTest() As Void
*!*			LOCAL lcPrinter as string
*!*			lcPrinter = This.ObtenerImpresoraPredeterminada()
*!*			If _Screen.zoo.lDesarrollo Or !_vfp.StartMode = 4 Or _Screen.zoo.EsBuildAutomatico
*!*				IF this.cImpresoraParaTest $ UPPER(lcPrinter)
*!*					&& En el contexto de Autobuild y bancos de prueba, se deja siempre la impresora FINEPRINT.
*!*					RETURN
*!*				endif
*!*			ENDIF
*!*			
		this.SetearImpresoraPredeterminada(This.cPrinterBackup)
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearImpresoraPredeterminada( tcImpresora As String ) As Void 
		This.SetearImpresoraPredeterminadaTecnicaUno(tcImpresora)
		lcPrinter = This.ObtenerImpresoraPredeterminada()
		If Upper( Alltrim(tcImpresora) ) $ Upper(lcPrinter )
			Return
		Endif

		This.SetearImpresoraPredeterminadaTecnicaDos(tcImpresora)
		lcPrinter = This.ObtenerImpresoraPredeterminada()
		If Upper( Alltrim(tcImpresora) ) $ Upper(lcPrinter )
			Return
		Endif

		This.SetearImpresoraPredeterminadaTecnicaTres(tcImpresora)
		lcPrinter = This.ObtenerImpresoraPredeterminada()
		If Upper( Alltrim(tcImpresora) ) $ Upper(lcPrinter )
			Return
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearImpresoraPredeterminadaTecnicaTres( tcImpresora As String ) As Void
		Declare Long WriteProfileString In "kernel32" String lpszSection, String lpszKeyName, String lpszString
		WriteProfileString( 'windows','device', Upper( tcImpresora  ))
		Clear Dlls "WriteProfileString"
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearImpresoraPredeterminadaTecnicaDos( tcPrinter As String ) As Void
		Local lobjWMI, lcCadWMI, lobjImp, lobjPrinter, strComputer
		lobjWMI = Getobject("winmgmts:\\")
		lcCadWMI = "Select *  from Win32_Printer "
		lobjImp = lobjWMI.ExecQuery( lcCadWMI )

		For Each lobjPrinter In lobjImp FoxObject
			lcImpresora = Upper( Alltrim( lobjPrinter.Name ) )
			If lcImpresora == Upper( Alltrim( tcPrinter ) )
				lobjPrinter.SetDefaultPrinter
				Set Printer To Name ( tcPrinter )
			Endif
		Endfor
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearImpresoraPredeterminadaTecnicaUno( tcPrinter As String ) As Void
		Local loWSHNetwork As "WScript.Network"
		loWSHNetwork = Createobject( "WScript.Network" )
		loWSHNetwork.SetDefaultPrinter( tcPrinter )
		Set Printer To Name ( tcPrinter )
		loWSHNetwork = Null
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerImpresoraPredeterminada() As String
		Local lcImpresora As String, lnTamanioBuffer As Integer
		lcImpresora = ""

		Declare Integer GetDefaultPrinter ;
			in winspool.drv ;
			string  @pszBuffer,;
			integer @pcchBuffer

		lnTamanioBuffer = 250
		lcImpresora = Replicate( Chr( 0 ), lnTamanioBuffer )
		GetDefaultPrinter( @lcImpresora, @lnTamanioBuffer )
		lcImpresora = Substr( lcImpresora, 1, At( Chr( 0 ), lcImpresora ) -1 )
		Return lcImpresora
	Endfunc

Enddefine
