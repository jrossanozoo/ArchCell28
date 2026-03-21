define class ColaboradorConsultasDeStockProduccion as ColaboradorConsultasEntreBasesDeDatos of ColaboradorConsultasEntreBasesDeDatos.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerStockDisponible( toFiltros as ZooColeccion of ZooColeccion.prg ) as Double
		local lnCantidadDisponible as Double, lcSucursal as String
		lnCantidadDisponible = 0
		
		for each lcSucursal in this.oListaDeSucursales foxobject
			lnCantidadDisponible = lnCantidadDisponible + this.ObtenerStockDisponibleEnBaseDeDatos( lcSucursal, toFiltros )
		endfor
		
		return lnCantidadDisponible
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStockDisponibleEnBaseDeDatos( tcSucursal as String, toFiltros as ZooColeccion of ZooColeccion.prg ) as Double
		local lnCantidadDisponible as Double, lcRuta as String, lcConsulta as String, lcCursor as String, lcCampoCantidad as String

		lcConsulta = this.ObtenerConsultaAEjecutar( tcSucursal, toFiltros )
		lcRuta = addbs( _screen.Zoo.App.ObtenerRutaSucursal( tcSucursal ) ) + "DBF"
		lcCampoCantidad = this.cCampoCantidad
		lcCursor = sys( 2015 )
		goServicios.Datos.EjecutarSentencias( lcConsulta, this.cTabla, lcRuta, lcCursor, this.DataSessionId )
		
		lnCantidadDisponible = &lcCursor..&lcCampoCantidad
		use in select( lcCursor )

		return lnCantidadDisponible
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFiltrosParaConsultaStockCombinacion( toItem as Object, toEntidadStockCombinacion  as Object ) as ZooColeccion of ZooColeccion.prg
		local loFiltrosConsulta as ZooColeccion of ZooColeccion.prg, loFiltro as Object, lcAtributo as String
		loFiltrosConsulta = _screen.zoo.CrearObjeto( "ZooColeccion" )

		for each lcAtributo in toEntidadStockCombinacion.oAtributosCC
			loFiltro = newobject( "FiltroConsultaStock" )
			loFiltro.cCampo = toEntidadStockCombinacion.oAD.ObtenerCampoentidad( strtran( upper( lcAtributo ), "_PK", "" ) )
			loFiltro.Valor = toItem.&lcAtributo
			loFiltrosConsulta.Agregar( loFiltro )
		endfor

		return loFiltrosConsulta
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionConUnFiltro( tcAtributo as String, txValor as Object ) as Void
		local loFiltrosConsulta as ZooColeccion of ZooColeccion.prg, loFiltro as Object, lcAtributo as String

		loFiltrosConsulta = _screen.zoo.CrearObjeto( "ZooColeccion" )

		loFiltro = newobject( "FiltroConsultaStock" )
		loFiltro.cCampo = tcAtributo
		loFiltro.Valor = txValor 
		loFiltrosConsulta.Agregar( loFiltro )
		
		return loFiltrosConsulta
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerFiltrosParaConsultaStockCombinacionesDeInsumo( tcInsumo as String, toEntidadStockCombinacion as Object ) as Object
		return this.ObtenerColeccionConUnFiltro( toEntidadStockCombinacion.oAD.ObtenerCampoentidad( "Insumo" ), tcInsumo )
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function ObtenerCombinacionesConStockDeInsumo( toFiltros as Object, tcAtributosCombinacion as String, tcAtributosCombinacionAsAtributos as String ) as Object
		local loColeccionXmlStock as ZooColeccion of ZooColeccion.prg, lcCursor as String, toFiltroNulo as zoocoleccion OF zoocoleccion.prg, ;
		lcConsulta as String, lcRuta as String
		
		lcCursor = sys( 2015 )

		toFiltroNulo=this.ObtenerColeccionConUnFiltro( "1" , 0 )
		lcConsulta = this.ObtenerConsultaDeCombinacionDeInsumoAEjecutar( _screen.zoo.app.csUCURSALACTIVA, toFiltroNulo, tcAtributosCombinacion  )
		lcRuta = addbs( _screen.Zoo.App.ObtenerRutaSucursal( _screen.zoo.app.csUCURSALACTIVA ) ) + "DBF"

		goServicios.Datos.EjecutarSentencias( lcConsulta, this.cTabla, lcRuta, lcCursor, this.DataSessionId )

		
		for each lcSucursal in this.oListaDeSucursales foxobject
			this.ObtenerCombinacionesConStockDeInsumoEnBaseDeDatos( lcSucursal, toFiltros, tcAtributosCombinacion, lcCursor )
		endfor
		
		this.Agrupar( lcCursor, tcAtributosCombinacion, tcAtributosCombinacionAsAtributos )
		
		lcRetorno = this.CursorAXml( lcCursor )
		use in select( lcCursor )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Agrupar( tcCursor as String, tcAtributos as String, tcAtributosCombinacionAsAtributos as String ) as Void
	
		lcSql = "select " + tcAtributosCombinacionAsAtributos + ", sum( " + this.cCampoCantidad + " ) as cantidad " + ;
				" from " + tcCursor + ;
				" group by " + tcAtributos + ;
				" into cursor " + tcCursor
				
		&lcSql

	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ObtenerCombinacionesConStockDeInsumoEnBaseDeDatos( tcSucursal as String, toFiltros as Object, tcAtributosCombinacion as String, tcCursorAcumulado as String ) as Object
		local lcCursor as String, lcConsulta as String, lcRuta as String, lcCampoCantidad as String
		
		lcConsulta = this.ObtenerConsultaDeCombinacionDeInsumoAEjecutar( tcSucursal, toFiltros, tcAtributosCombinacion  )
		lcRuta = addbs( _screen.Zoo.App.ObtenerRutaSucursal( tcSucursal ) ) + "DBF"
		lcCampoCantidad = this.cCampoCantidad
		lcCursor = sys( 2015 )
		
		goServicios.Datos.EjecutarSentencias( lcConsulta, this.cTabla, lcRuta, lcCursor, this.DataSessionId )


		select &tcCursorAcumulado
		append from dbf( lcCursor )
		
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerConsultaDeCombinacionDeInsumoAEjecutar( tcSucursal as String, toFiltros as ZooColeccion of ZooColeccion.prg, tcAtributosCombinacion as String ) as String
		local lcConsulta as String, lcTabla as String, lcWhere as String, lcCampoCantidad as string
		lcTabla = this.ObtenerTabla( tcSucursal )
		lcWhere = this.ObtenerWhere( toFiltros )
		lcCampoCantidad = this.cCampoCantidad
		lcConsulta = "select "+ tcAtributosCombinacion + "," + lcCampoCantidad + " from " + lcTabla + " where " + lcWhere
		return lcConsulta
	endfunc

enddefine

define class FiltroConsultaStock as Custom
	cCampo = ""
	Valor = null
enddefine
