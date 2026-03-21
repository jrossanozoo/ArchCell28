*-----------------------------------------------------------------------------------------
define class ZooConstructor as custom

	#IF .f.
		Local this as ZooConstructor of ZooConstructor.prg
	#ENDIF

	protected oClasesProxy as Collection, nDataSessionId as Integer
	oClasesProxy = null
	nDataSessionId = 0
	
	*-----------------------------------------------------------------------------------------
	function Init() as Boolean
		dodefault()
		this.nDataSessionId = set( "Datasession" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oClasesProxy_Access() as ZooColeccion of ZooColeccion.prg
		if isnull( this.oClasesProxy )
			this.oClasesProxy = this.ObtenerClasesProxy()
		endif
		return this.oClasesProxy
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearObjeto( tcClase as String, tnDataSession as Integer ) as Object
		local loRetorno as Object, loError as Object

		try
			set datasession to ( tnDataSession )
			loRetorno = newobject( tcClase )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			set datasession to ( this.nDataSessionId )
		endtry

		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreClaseProxy( tcClase as String, tcLibreria as String ) as String
		local lcRetorno as String, loError as Exception
		lcRetorno = ""
		if upper( alltrim( tcClase ) ) == upper( alltrim( juststem( tcLibreria ) ) )
			try
				lcRetorno = this.oClasesProxy.Item[ upper( alltrim( tcClase ) ) ]
			catch to loError
			endtry
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClasesProxy() as Collection
		local loClasesProxy as Collection
		loClasesProxy = createobject( "collection" )

		loClasesProxy.Add( [ZOOCOLECCIONPROXY], [ZOOCOLECCION] )

		return loClasesProxy
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
* PROXIES
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ZOOCOLECCIONPROXY as ZOOCOLECCION of ZOOCOLECCION.PRG
	function Class_Access() as String
		return 'ZooColeccion'
	endfunc
	function ClassLibrary_Access() as String
		return 'zoocoleccion.fxp'
	endfunc
	function ParentClass_Access() as String
		local array laInfoClase[ 1 ]
		aclass( laInfoClase, this )
		return laInfoClase[ 3 ]
	endfunc
enddefine