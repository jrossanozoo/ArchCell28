define class ManagerTemporales as custom

	#IF .f.
		Local this as ManagerTemporales of ManagerTemporales.prg
	#ENDIF

	hidden cCarpetaTemporalRaiz as string, cRutaTmpActual as string, oLectorFpw as Object
	cCarpetaTemporalRaiz = addbs( getenv( "tmp" ) ) + "zooTmp"
	cRutaTmpActual = this.cCarpetaTemporalRaiz
	oLectorFpw = null
	cProyecto = ""

	*-----------------------------------------------------------------------------------------
	function Init( tcProyecto as string, toLectorFpw as Object ) as Void
		this.oLectorFpw = toLectorFpw
		this.SetearCarpetaTemporalRaiz()
		this.cProyecto = tcProyecto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function SetearCarpetaTemporalRaiz( tcCarpetaInicioAplicacion ) as Void
		local lcCarpeta as String
		lcCarpeta = this.oLectorFpw.Leer( "RutaTemporal" )
		this.cCarpetaTemporalRaiz = iif( empty( lcCarpeta ), this.cCarpetaTemporalRaiz, transform( lcCarpeta ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function cProyecto_assign( tcProyecto as string ) as Void
		this.cProyecto = iif( empty( tcProyecto ), "", transform( tcProyecto ) )
		this.SetearRutaParaProyecto( this.cProyecto )
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function SetearRutaParaProyecto( tcProyecto as string ) as Void
		local lcTemporal as string, loLibrerias as Object
		
		lcTemporal = addbs( this.cCarpetaTemporalRaiz ) + addbs( tcProyecto ) + ;
			this.ObtenerSufijoSegunFecha()
		lcTemporal = lcTemporal + sys( 2015 )

		this.CompilarClase( "librerias.prg" )
		
		loLibrerias = newobject( "librerias", "librerias.prg" )
		loLibrerias.CrearDirectorio( lcTemporal )

		this.cRutaTmpActual = upper( lcTemporal )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerSufijoSegunFecha() as String
		return addbs( "A_" + transform( year( date() ) ) ) + ;
			addbs( "M_" + padl( transform( month( date() ) ), 2, "0" ) ) + ;
			addbs( "D_" + padl( transform( day( date() ) ) , 2, "0" ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCarpeta( tlNuevo as Boolean ) as string
		local lcRuTaTemporal as string
		
		if tlNuevo or !this.ExisteCarpeta( addbs( this.cRutaTmpActual ) )
			this.BorrarCarpeta()
			this.SetearRutaParaProyecto( this.cProyecto )
		endif

		lcRutaTemporal = addbs( this.cRutaTmpActual )

		return lcRutaTemporal
	endfunc

	*-----------------------------------------------------------------------------------------
	function BorrarCarpeta( tcRutaTemp as string ) as Void
		local loArchivos as object
		this.CompilarClase( "ManejoArchivos.prg" )
		loArchivos = newobject( "ManejoArchivos", "ManejoArchivos.prg" )

		if vartype( loArchivos ) ="O"
			loArchivos.BorrarCarpeta( addbs( this.cRutaTmpActual ) )
			loArchivos.destroy()
			loArchivos = null
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CompilarClase( tcClase as String ) as Void
		try
			if file( tcClase )
				compile tcClase
			endif
		catch
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteCarpeta( tcCarpeta as String ) as Boolean
		local loFs as "Scripting.FileSystemObject" of "Scripting.FileSystemObject", llRetorno as Boolean

		loFs = Createobject( "Scripting.FileSystemObject" )
		llRetorno = loFs.FolderExists( tcCarpeta )
		loFs = null
		return llRetorno
	endfunc

enddefine
