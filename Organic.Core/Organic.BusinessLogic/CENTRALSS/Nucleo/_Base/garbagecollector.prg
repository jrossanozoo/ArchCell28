Define Class GarbageCollector As Custom

	#if .f.
		local this as GarbageCollector of GarbageCollector.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function GarbageCollectorArchivos( tcPath as String ) as Void
		this.GarbageCollectorSegunExtension( tcPath, "dbf", "_" )
		this.GarbageCollectorSegunExtension( tcPath, "cdx", "_" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GarbageCollectorSegunExtension( tcPath as String, tcExtension as String, tcPatron as String ) as Void
		local loCol as zoocoleccion OF zoocoleccion.prg, lcFullPath as string, lcExtension as String

		loCol = this.ObtenerColeccionGarbage( tcPath, tcExtension, tcPatron )

		for each lcFile in loCol
			try
				lcFullPath = addbs( tcPath ) + lcFile
				delete file &lcFullPath
			catch
			endtry
		next
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionGarbage( tcPath as String, tcExtension as String, tcPatron as String ) as zoocoleccion OF zoocoleccion.prg
		local loCol as zoocoleccion OF zoocoleccion.prg, lnCant as Integer, i as Integer, lcPath as string

		loCol = _screen.zoo.app.CrearObjeto( "ZooColeccion" )
		
		if empty( tcPatron )
			tcPatron = ""
		endif
		
		lcPath = addbs( tcPath )
		lnCant = adir( laDir, lcPath + tcPatron + "*." + tcExtension )
		for i = 1 to lnCant
			if this.ValidarFecha( laDir( i, 3 ), goLibrerias.ObtenerFecha(), 2 )
				loCol.Agregar( upper( laDir( i, 1 ) ) )
			endif
		next
		
		return loCol
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarFecha( tdFechaFile as Date, tdFechaComparar as Date, tnCantDias as Integer ) as Boolean
		return ( tdFechaComparar - tdFechaFile >= tnCantDias )
	endfunc 
	
enddefine