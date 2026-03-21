**********************************************************************
Define Class ztestAccionesAutomaticas as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestAccionesAutomaticas of ztestAccionesAutomaticas.prg
	#ENDIF
	
	oEnt_Acciones = null
	oBKPExportaciones = null
	
	*---------------------------------
	Function Setup
		This.oEnt_Acciones = newobject( "AuxEnt_AccionesAutomaticas" )
		this.oBKPExportaciones = goServicios.Exportaciones
		goServicios.Exportaciones = newobject( "AuxExportaciones" )
		goServicios.Exportaciones.oFxu = This
	EndFunc
	
	*---------------------------------
	Function TearDown
		This.oEnt_Acciones.Release()
		goServicios.Exportaciones.oFxu = Null
		goServicios.Exportaciones = this.oBKPExportaciones
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_ExportarConRutaPorParametro
		local loEntidad as Object

		goServicios.Exportaciones = newobject( "AuxExportaciones2" )
		goServicios.Exportaciones.oFxu = This

		This.AgregarMocks( "Cuba" )
		_Screen.Mocks.AgregarSeteometodo( "Cuba", "ObtenerAtributoClavePrimaria", "CODIGO" )

		loEntidad = _Screen.zoo.instanciarEntidad( "Cuba" )
		This.oEnt_Acciones.Exportar( loEntidad, "MANZANA" )		
		
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_EntidadConAccionAutomaticaDuplicada
		local loEntidadAccion as Object, llValido as Boolean, lcMensajeError as String, loInformacion as Object
		
		loEntidadAccion = _Screen.zoo.instanciarEntidad( "AccionesAutomaticas" )
		with loEntidadAccion
			try
				.Codigo = "LETONIAACCAUTOM"
				.Eliminar()
			catch
			endtry
			
			.Nuevo()
			.Codigo = "LETONIAACCAUTOM"
			.Entidad = "LETONIA"
			.Grabar()
			
			.Nuevo()
			.Codigo = "LETONIA2"
			try 
				.Entidad = "LETONIA"
				this.asserttrue( "Deberia pinchar.", .f. )
			catch to loError
				loInformacion = loError.uservalue.ObtenerInformacion()
				lcMensajeError = loInformacion.Item(1).cMensaje
				this.assertTrue( "Falla la validación de varias acciones automáticas para una misma entidad.", !llValido )
				this.assertEquals( "El mensaje de error por varias acciones automáticas para una misma entidad no es el correcto.", ;
					"Atención! La entidad LETONIA posee un comportamiento previamente cargado (LETONIAACCAUTOM).", ;
					lcMensajeError )
			endtry
			
			try
				.Codigo = "LETONIAACCAUTOM"
				.Eliminar()
			catch
			endtry
			.Release()
		endwith
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestU_VerificarOrden() as Void
		local loEntidadAccion as Object, llResultado as Boolean
		
		llResultado = .t.
		
		loEntidadAccion = _Screen.zoo.instanciarEntidad( "AccionesAutomaticas" )
		with loEntidadAccion
			try
				.Codigo = "FACTURAACCIONAUTOMATICA"
				.Eliminar()
			catch
			endtry

			.Nuevo()
			.Codigo = "FACTURAACCIONAUTOMATICA"
			.Entidad = "FACTURAMANUAL"
			
			loItem = .AccionesDetalle.CrearItemAuxiliar()
			loItem.Codigo = "COMPROBANTE1"
			loItem.NroItem = 1
			loItem.Orden = 1
			loItem.Metodo = "Metodo1"
			loItem.Expresion = "Metodo1"
			.AccionesDetalle.add( loItem )
			
			loItem = .AccionesDetalle.CrearItemAuxiliar()
			loItem.Codigo = "COMPROBANTE2"
			loItem.NroItem = 2
			loItem.Orden = 2
			loItem.Metodo = "Metodo2"
			loItem.Expresion = "Metodo2"
			.AccionesDetalle.add( loItem )
			
			try
				.Grabar()
			catch to loError
				llResultado = .f.
			endtry
			
			this.assertTrue( "Falla la validacion del orden.", llResultado )
			
			try
				.Codigo = "FACTURAACCIONAUTOMATICA"
				.Eliminar()
			catch
			endtry
			.Release()
			
		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ZtestU_VerificarOrdenConError() as Void
	
		local loEntidadAccion as Object, llResultado as Boolean, lcMensajeError as String
		
		llResultado = .f.
		
		loEntidadAccion = _Screen.zoo.instanciarEntidad( "AccionesAutomaticas" )
		with loEntidadAccion
			try
				.Codigo = "FACTURAACCIONAUTOMATICA2"
				.Eliminar()
			catch
			endtry
			
			.Nuevo()
			.Codigo = "FACTURAACCIONAUTOMATICA2"
			.Entidad = "FACTURAMANUAL"
			
			loItem = .AccionesDetalle.CrearItemAuxiliar()
			loItem.Codigo = "COMPROBANTE1"
			loItem.NroItem = 1
			loItem.Orden = 0
			loItem.Metodo = "Metodo1"
			.AccionesDetalle.add( loItem )
			
			loItem = .AccionesDetalle.CrearItemAuxiliar()
			loItem.Codigo = "COMPROBANTE2"
			loItem.NroItem = 2
			loItem.Orden = 2
			loItem.Metodo = "Metodo2"
			.AccionesDetalle.add( loItem )
			
			try
				.Grabar()
			catch to loError
				llResultado = .t.
				
				loInformacion = loError.uservalue.ObtenerInformacion()
				lcMensajeError = loInformacion.Item(1).cMensaje
				this.assertEquals( "El mensaje de error es incorrecto.", "No puede quedar vacío el campo orden.", lcMensajeError )
				
			endtry
			
			this.assertTrue( "Deberia haber dado error la validacion del orden.", llResultado )
			
			try
				.Codigo = "FACTURAACCIONAUTOMATICA"
				.Eliminar()
			catch
			endtry
			.Release()
			
		endwith

	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		function ztestU_PoseeValorDeCierreEntidad
*!*			local lbRetorno as Boolean
*!*			lbRetorno = .f.
*!*			try 
*!*				if select("lCursorFuncionalidades")=0
*!*					=xmltocursor(goservicios.estrUCTURA.obtenerfuncionalidades(),"lCursorFuncionalidades",4)
*!*				endif 
*!*				select lCursorFuncionalidades
*!*				go top
*!*				do while !eof()
*!*					if lower(alltrim(tcEntidad)) == lower(alltrim(entidad))
*!*						if "<VALORCIERRE>" $ funcionalidades
*!*							lbRetorno	= .t.
*!*						endif
*!*						exit
*!*					endif
*!*					skip
*!*				enddo
*!*			catch
*!*			endtry
*!*			return lbRetorno
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestU_PoseeValorDeCierreEntidad
		local loEntidad as Object
	*Arrange (Preparar)
	*Act (Actuar)
		loEntidad = _screen.zoo.instanciarentidad("AccionesAutomaticas")
		loEntidad.PoseeValorDeCierreEntidad( "Recibo" )
		set datasession to loEntidad.datasessionid
	*Assert (Afirmar)
		this.assertequals("No genera Curso de Consulta de Acciones Automaticas",.f.,select("lCursorFuncionalidades")=0)
		this.assertequals("Devuelve un valor no esperado","L",vartype(loEntidad.PoseeValorDeCierreEntidad( "ALquiera" )))
		loEntidad.release
	endfunc 

	
EndDefine




*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class AuxExportaciones as Custom
	oFxu = Null
	*-----------------------------------------------------------------------------------------
	function Procesar( tcDiseno as String, tlAgrupada as Boolean ) as Object
		local loObj as Object

		loObj = _screen.zoo.CrearObjeto( "Din_ExportacionArgentinaObjeto" )
		loObj.Inicializar()
		loObj.oDisenoImpoExpo = newobject( "AuxEnt_ImpoExpo" )

		loObj.lObtenerDatosExportacion = .F.
		return loObj
	endFunc
	
	*-----------------------------------------------------------------------------------------
	function Enviar( toObjetoExpo as Object, tlMuestra as Boolean ) as Void
		This.oFxu.AssertTrue( "Mal seteada la propiedad lObtenerDatosExportacion" , toObjetoExpo.lObtenerDatosExportacion )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCreandoObjetoImpoExpo( toObjecto as Object ) as Void
	endfunc 
	
enddefine

define class AuxExportaciones2 as Custom
	oFxu = Null
	loTestEntidadDisenoExpo = Null

	*-----------------------------------------------------------------------------------------
	function init

		this.loTestEntidadDisenoExpo = newobject( "TestEntidadDisenoExpo" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Procesar( tcDiseno as String, tlAgrupada as Boolean, tcEntidad as String ) as Object
		local loObj as Object

		loObj = _screen.zoo.CrearObjeto( "Din_ExportacionArgentinaObjeto" )
		loObj.Inicializar()
		loObj.oDisenoImpoExpo = newobject( "AuxEnt_DisenoExpo" )
		Bindevent( loObj.oDisenoImpoExpo , "EsRutaPorParametro", this.loTestEntidadDisenoExpo , "EsRutaPorParametro" )
		Bindevent( loObj.oDisenoImpoExpo, "ObtenerRutaPorParametro", this.loTestEntidadDisenoExpo , "ObtenerRutaPorParametro" )
		loObj.lObtenerDatosExportacion = .F.
		return loObj
	endFunc
	*-----------------------------------------------------------------------------------------
	function Enviar( toObjetoExpo as Object, tlMuestra as Boolean ) as Void
		this.oFxu.AssertTrue("No existe la funcion 'EsRutaPorParametro'", this.loTestEntidadDisenoExpo.lExisteEsRutaPorParametro )
		this.oFxu.AssertTrue("No existe la funcion 'ObtenerRutaPorParametro'", this.loTestEntidadDisenoExpo.lExisteObtenerRutaPorParametro )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoCreandoObjetoImpoExpo( toObjecto as Object ) as Void

	endfunc 
enddefine

define class TestEntidadDisenoExpo as custom
	lExisteEsRutaPorParametro = .F.
	lExisteObtenerRutaPorParametro = .F.
	*-----------------------------------------------------------------------------------------
	function EsRutaPorParametro( tcCadena as String) as Boolean
		this.lExisteEsRutaPorParametro = .T.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaPorParametro( tcParametro as String ) as String
		this.lExisteObtenerRutaPorParametro = .T.
	endfunc 

enddefine

define class AuxEnt_DisenoExpo as Ent_DisenoExpo of Ent_DisenoExpo.prg
	RutaSalida = "goParametros.TestRuta"
	RutaBackup = "goParametros.TestRuta"

	*-----------------------------------------------------------------------------------------
	function EsRutaPorParametro( tcCadena as String) as Boolean
		return .T.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaPorParametro( tcCadena as String) as String
		return "C:\"
	endfunc 


enddefine

define class AuxEnt_ImpoExpo as Custom
	RutaSalida = ""
	ArchivoSalida = ""
	AppendArchivo = ""
	RutaBackup = ""
	ArchivoBackup = ""
	AppendBackup = ""

	function ObtenerClaseHook() as String
		return ""
	endfunc 
enddefine

define class AuxEnt_AccionesAutomaticas as Ent_AccionesAutomaticas of Ent_AccionesAutomaticas.prg

	function EsUnaExportacionTuneada( toDisenoImpoExpo as Object) as Boolean
		return .T.
	endfunc 

enddefine
