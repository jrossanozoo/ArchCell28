define class Modulos as Servicio of Servicio.prg

	#IF .f.
		Local this as Modulos of Modulos.prg
	#ENDIF

	protected oModulos, oEntidadesModulos
	oModulos = null
	oEntidadesModulos = null
	oEquivalencias = null
	oExcepciones = null
	nPosicionModuloSaaS = 0
	nVersion = 1 && Versionado de módulos para poder saber en la PC del cliente cuando debe pedir códigos de desactivación para actualizar los módulos del sistema. Aumentar la versión con números enteros.

	*-----------------------------------------------------------------------------------------
	function init() as Void
		this.oModulos = _screen.zoo.crearobjeto( "zooColeccion" )
		this.oEquivalencias = _screen.zoo.crearobjeto( "zooColeccion" )
		this.LlenarColeccion()
		this.LlenarEquivalencias()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ExisteModulo( tcLetraModulo as String ) as Boolean
		return this.oModulos.Buscar( tcLetraModulo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oEntidadesModulos_Access() as ZooColeccion of ZooColeccion.Prg
		if !this.ldestroy and ( !vartype( this.oEntidadesModulos ) = 'O' or isnull( this.oEntidadesModulos )  )
			this.oEntidadesModulos = goServicios.Estructura.ObtenerColeccionModulosPorEntidad()
		endif
		return this.oEntidadesModulos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LlenarColeccion() as Void
		if this.esProductoModularizado()
		else
			this.oModulos.Agregar( this.ObtenerModulo( 999, "Base", "Base", "B" ), "B" )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function esProductoModularizado() as Boolean
		return ( _screen.Zoo.App.cProducto =  "06" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulo( tnId as integer, tcNombre as String, tcDescripcion as string, tcLetra as string, tcCodModuZl as String ) as ItemModulo
		local loItem as object

		loItem = newobject( "ItemModulo" )
		loItem.LlenarItem( tnId, tcNombre, tcDescripcion, tcLetra, tcCodModuZl )

		return loItem
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerModulos() as zooColeccion of zooColeccion.prg
		return this.oModulos
	endfunc

	*-----------------------------------------------------------------------------------------
	function ModuloHabilitado( tcModulo as string ) as Boolean
		local llRetorno as Boolean, lcModulo as string

		lcModulo = alltrim( upper( tcModulo ) )
		if this.oModulos.Buscar( lcModulo )
			llRetorno = this.oModulos.item[ tcModulo ].lHabilitado
		else
			goServicios.Errores.LevantarExcepcion( "No se encuentra el módulo " + alltrim( proper( lcModulo ) ) )
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarModulo( tcModulo as string ) as Void
		this.SetearModulo( tcModulo, .t. )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DeshabilitarModulo( tcModulo as string ) as Void
		this.SetearModulo( tcModulo, .f. )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearModulo( tcModulo as string, tlEstado as Boolean ) as Void
		local loItem as object

		tcModulo = alltrim( upper( tcModulo ) )
		if this.oModulos.Buscar( tcModulo )
			loItem = this.oModulos.item[ tcModulo ]
			goFormularios.escribir( loItem.nId, iif( tlEstado, "1", "0" ) )
			loItem.lHabilitado = tlEstado
		else
			goServicios.Errores.LevantarExcepcion( "No se encuentra el módulo a " + iif( tlEstado, "habilitar (", "deshabilitar (" ) + alltrim( proper( tcModulo ) ) + ")" )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function RegModAct( tcCodigo as string ) as Void
		local i as integer, loItem as object, lcValor as string, lcValorEquivalencia as string

		for i = 1 to len( tcCodigo )
			if this.oEquivalencias.buscar( transform( i ) )
				lcValorEquivalencia = this.oEquivalencias.item( transform( i ) )
				if !empty( lcValorEquivalencia )
					lcValor = substr( tcCodigo, i, 1 )
					if lcValor = "1"
						this.HabilitarModulo( lcValorEquivalencia )
					else
						this.DeshabilitarModulo( lcValorEquivalencia )
					endif
				endif
			else
				goServicios.Errores.LevantarExcepcion( "No se encuentra la equivalencia Nº " + transform( i ) )
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		&&Implementar en el prg correspondiente a cada producto. ej ModulosColorYTalle.prg
		with this.oEquivalencias
			.agregar( "", "1" )
			.agregar( "", "2" )
			.agregar( "", "3" )
			.agregar( "", "4" )
			.agregar( "", "5" )
			.agregar( "", "6" )
			.agregar( "", "7" )
			.agregar( "", "8" )
			.agregar( "", "9" )
			.agregar( "", "10" )
			.agregar( "", "11" )
			.agregar( "", "12" )
			.agregar( "", "13" )
			.agregar( "", "14" )
			.agregar( "", "15" )
			.agregar( "", "16" )
			.agregar( "", "17" )
			.agregar( "", "18" )
			.agregar( "", "19" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarModuloSaaS() as Boolean
		local llRetorno
		llRetorno = .f.

		if this.nPosicionModuloSaaS > 0 and goFormularios.Leer( this.nPosicionModuloSaaS ) == "1"
			llRetorno = .t.
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EntidadHabilitada( tcEntidad as string ) as Boolean
		local llRetorno as Boolean, lcEntidad as string, lcLetras as string, i as integer, llValidador as String

		lcEntidad = upper( alltrim( tcEntidad ) )
		llRetorno = .f.
		if this.EntidadTieneMenu( lcEntidad )
			if this.oEntidadesModulos.Buscar( lcEntidad )
				if this.oExcepciones.Buscar( lcEntidad )
					llValidador = this.oExcepciones.item( lcEntidad )
					try
						llRetorno = &llValidador.
					catch
						llRetorno = .f.
					endtry
				else
					lcLetras = alltrim( this.oEntidadesModulos.item( lcEntidad ) )
					for i = 1 to len( lcLetras )
						lcLetraActual = upper( substr( lcLetras, i, 1 ))
						if this.ModuloHabilitado( lcLetraActual )
							llRetorno = .t.
							exit
						endif
					endfor
				endif
			endif
		else
			llRetorno = .t.
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oExcepciones_Access() as ZooColeccion of ZooColeccion.Prg
		&& Agregar entidades que tienen uan regla excepcional para habilitarla en la seguridad con su metodo que valide la particularidad
		if !this.ldestroy and ( !vartype( this.oExcepciones ) = 'O' or isnull( this.oExcepciones )  )
			this.oExcepciones = _screen.zoo.crearobjeto("zooColeccion")
			this.oExcepciones.Agregar("this.EstaHabilitadoPedidoDeCompra()","PEDIDODECOMPRA")
		endif
		return this.oExcepciones
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EstaHabilitadoPedidoDeCompra() as Boolean
		local ldevuelve as Boolean
		do case
			case this.ModuloHabilitado("J") and this.ExisteBuzonDeCasaCentral()
				ldevuelve = .t.
			case this.ModuloHabilitado("D") and this.ExisteBuzonDeCasaCentral()
				ldevuelve = .t.
			case this.ModuloHabilitado("K")
				ldevuelve = .t.
		endcase
		return ldevuelve
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EntidadTieneMenu( tcEntidad as String ) as Boolean
		local llRetorno as Boolean, lnSelect as Integer, lcEntidad as string, loCol
		lnSelect = Select()
		llRetorno = .f.
		lcEntidad = upper( alltrim( tcEntidad ) )
		loCol = goservicios.estructura.odiNESTRUCTURAADN.ObtenerColeccionEntidadesConMenu()
		if loCol.Buscar( lcEntidad )
			llRetorno = .t.
		endif

		select( lnSelect )

		return llRetorno
	endfunc

	*---------------------------------------------------------------------------------------------
	function ActualizarModulosDemo() as Void
		local loItem as Object 
		if upper( alltrim( _screen.zoo.app.cSerie )) == "DEMO"
			for each loItem in this.oModulos
				if loItem.SoyModuloBase()
					loItem.lHabilitado = .t.
				else
					this.SetearModulo( loItem.cLetra, .t. )
				endif
			endfor 
		endif 
	endfunc

    *-----------------------------------------------------------------------------------------
    function TieneModuloHabilitadoSegunAlias( tcAlias as String ) as Boolean  
        local llRetorno as Boolean, lcLetra as String
        llRetorno = .f.
        lcLetra = this.ObtenerLetraDeUnModuloSegunAlias( upper( alltrim( tcAlias ) ) )
        if !empty( lcLetra )
        	llRetorno = this.ModuloHabilitado( lcLetra )
        else
			&& Si se desea que no de error validar la existencia con el Metodo "ExisteModuloSegunAlias".
			goServicios.Errores.LevantarExcepcion( "El módulo solicitado " + transform(tcAlias) + " no existe." )                
        endif
        return llRetorno 
    endfunc

    *-----------------------------------------------------------------------------------------
    function ExisteModuloSegunAlias( tcAlias as String ) as Boolean  
        local llRetorno as Boolean, lcLetra as String
        llRetorno = .f.
        lcLetra = this.ObtenerLetraDeUnModuloSegunAlias( upper( alltrim( tcAlias ) ) )
        if !empty( lcLetra )
	        llRetorno = this.ExisteModulo( lcLetra )
	    endif
        return llRetorno 
    endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraDeUnModuloSegunAlias( tcAlias as String ) as  
		local lcModulo as String
		&& Implementar en el prg correspondiente a cada producto. ej ModulosColorYTalle.prg
		lcModulo = ""
		return lcModulo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
    function ObtenerNombreModuloSegunAlias( tcAlias as String ) as String  
        local llRetorno as Boolean, lcLetra as String
        llRetorno = .f.
        lcLetra = this.ObtenerLetraDeUnModuloSegunAlias( upper( alltrim( tcAlias ) ) )
        if !empty( lcLetra )
        	llRetorno = this.ModuloNombre( lcLetra )
        else
			&& Si se desea que no de error validar la existencia con el Metodo "ExisteModuloSegunAlias".
			goServicios.Errores.LevantarExcepcion( "El módulo solicitado " + transform(tcAlias) + " no existe." )                
        endif
        return llRetorno 
    endfunc

	*-----------------------------------------------------------------------------------------
	protected function ModuloNombre( tcModulo as string ) as String
		local lcNombre as string, lcModulo as string

		lcModulo = alltrim( upper( tcModulo ) )
		if this.oModulos.Buscar( lcModulo )
			lcNombre = this.oModulos.item[ tcModulo ].cNombre
		else
			goServicios.Errores.LevantarExcepcion( "No se encuentra el módulo " + alltrim( proper( lcModulo ) ) )
		endif

		return lcNombre
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerLetraDelModuloSegunCodigoDeModuloEnZL( tcCodigoDeModulo as String ) as String
		local loModulo as ItemModulo of modulos.prg
		lcRetorno = ""
		for each loModulo in this.oModulos foxobject
			if loModulo.cCodigoDeModuloEnZl == tcCodigoDeModulo
				lcRetorno = loModulo.cLetra
				exit
			endif
		endfor
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteBuzonDeCasaCentral() as boolean
		local llRetorno as Boolean, lcCursor as String, lcSelect as string
				
		llRetorno = .F.
		lcCursor = sys( 2015 )
		lcSelect = "Select hoscod from [" + _Screen.Zoo.App.cBDMaster + "].Puesto.Host where Comport = 4"
		
		goServicios.Datos.EjecutarSentencias(lcSelect, "Host", "", lcCursor, this.DataSessionId )
		
		select( lcCursor )
		if reccount( lcCursor ) > 0
			llRetorno = .T.
		endif
		
		use in select( lcCursor )
		
		return llRetorno			
	endfunc
	    
    
enddefine












*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class ItemModulo as custom
	nId = 0
	cDescripcion = ""
	cNombre = ""
	lHabilitado = .f.
	cLetra = ""
	cCodigoDeModuloEnZl = ""

	*-----------------------------------------------------------------------------------------
	function LlenarItem( tnId as integer, tcNombre as String, tcDescripcion as string, tcLetra as string, tcCodModuZl as String ) as Void
		local lcSerie as string

		lcSerie = goFormularios.Leer( 1 )
		with this
			.nId = tnId
			.cNombre = tcNombre
			.cDescripcion = tcDescripcion
			.cLetra = tcLetra
			if vartype( tcCodModuZl ) != "C"
				tcCodModuZl = ""
			endif
			.cCodigoDeModuloEnZl = tcCodModuZl
			if this.EsDemo( lcSerie ) or this.EsModuloBase( tnId )
				.lHabilitado = .t.
			else
				.lHabilitado = ( goFormularios.Leer( .nId ) == "1" )
			endif
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function EsDemo( tcSerie as string ) as Boolean
		return upper( alltrim( tcSerie ) ) = "DEMO"
	endfunc

	*-----------------------------------------------------------------------------------------
	hidden function EsModuloBase( tnId as integer ) as Boolean
		return ( tnId == 999 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SoyModuloBase() as Boolean
		return this.EsModuloBase( this.nId  )
	endfunc 

enddefine
