define class Ent_AccionesAutomaticas as Din_EntidadAccionesAutomaticas of Din_EntidadAccionesAutomaticas.prg

	oItemSegunOrden = null
	lEjecutarEnOtroHilo = .F.
	cDescripcionEntidad = ""
	
	*-----------------------------------------------------------------------------------------
	function IniciarAccionesAutomaticas()
		**** Para evitar el bucle
		this.lTieneAccionesAutomaticas = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Exportar( toEntidad as entidad OF entidad.prg, tcExpresion as String ) as Void
		local lcAtributo as String, lcEstado as String, llAccionTipoantes as Boolean, lcEvento as Boolean

		lcAtributo = toEntidad.ObtenerAtributoClavePrimaria()
		lcEstado = ""
		lcEvento = ""
		llAccionTipoAntes = .F.

		if toEntidad.lNuevo
			lcEstado = "Nuevo"
			lcEvento = toEntidad.cEvento
		endif
		if toEntidad.lEdicion
			lcEstado = "Modifica"
			lcEvento = toEntidad.cEvento
		endif
		if toEntidad.lAnular
			lcEstado = "Anula"
		endif		
		
		if pemstatus( toEntidad, "LACCIONAUTOMATICATIPOANTES",5)
			llAccionTipoAntes = toEntidad.LACCIONAUTOMATICATIPOANTES
		endif

		this.RealizarExportacion( tcExpresion, lcAtributo, toEntidad.&lcAtributo, toEntidad.&lcAtributo, lcEstado, llAccionTipoantes, toEntidad.ObtenerNombre(), lcEvento )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RealizarExportacion( tcCodigoDeExportacion as String, tcAtributoFiltro as String, tcCodigoDesde as String, ;
											tcCodigoHasta as String, tcEstado as String, tlAccionTipoAntes as Boolean, tcEntidad as String,  ;
											tcEvento as String ) as Void
											
		local loExportacion as ExportacionEnAccionAutomatica of ExportacionEnAccionAutomatica.prg

		loExportacion = _screen.zoo.crearobjeto( "ExportacionEnAccionAutomatica" )
		loExportacion.lDebeEjecutarEnOtroHilo = This.lEjecutarEnOtroHilo
		loExportacion.Enviar( tcCodigoDeExportacion, tcAtributoFiltro, tcCodigoDesde, tcCodigoHasta, tcEstado, tlAccionTipoAntes, tcEntidad, tcEvento )
		loExportacion.Release()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarMail( toEntidad as entidad OF entidad.prg, tcExpresion as String ) as Void
		local loGestorMail as GestorDeMail of GestorDeMail.prg

		goServicios.mensajes.Enviarsinesperaprocesando( "Enviando email" )

		loGestorMail = _screen.zoo.crearobjeto( "GestorDeMailEnAccionesAutomaticas" )
		loGestorMail.EnviarConDisenio( tcExpresion , toEntidad )
		loGestorMail.Release()

		goServicios.mensajes.Enviarsinesperaprocesando()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RealizarImpresion( toEntidad as entidad OF entidad.prg, tcExpresion as String ) as Void
		goservicios.impresion.imprimirDiseno( tcExpresion, toEntidad )
	Endfunc 

	*-----------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			goServicios.Entidades.AccionesAutomaticas.RefrescarColeccionDeEntidadesConAccionesAutomaticas()
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		llRetorno = llRetorno and this.VerificarCamposDetalle()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarCamposDetalle() as Boolean 
		local llRetorno as Boolean, lnCont as Integer
		llRetorno = .t.
		for lnCont = 1 to this.AccionesDetalle.count
			if !empty(this.AccionesDetalle.item[lnCont].metodo) and this.AccionesDetalle.item[lnCont].orden = 0
				llRetorno = .f.
				this.agregarinformacion("No puede quedar vacío el campo orden.")
			endif 
			
			if !empty(this.AccionesDetalle.item[lnCont].metodo) and this.AccionesDetalle.item[lnCont].Expresion = ""
				llRetorno = .f.
				this.agregarinformacion("No puede quedar vacío el campo expresión.")
			endif 
		endfor

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Eliminar() As void
		dodefault()
		goServicios.Entidades.AccionesAutomaticas.RefrescarColeccionDeEntidadesConAccionesAutomaticas()
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function ExisteRegistroParaLaEntidad( tcEntidad as String ) as Boolean 
		local llRetorno as Boolean
		
		llRetorno = .F.
		this.limpiar()
		this.entidad = tcEntidad
		try	
			this.Buscar()
			llRetorno = .T.
		catch 
			llRetorno = .F.
		endtry
		
		return llRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	Function CrearRegistro( tcEntidad as String ) as Boolean 		
		local lcPuesto as String, lcProducto as String, lcSql as String, lnIdPuesto as Number, lcIdParametro as String, llValor as Boolean, loError as Object, lbAux as Boolean
		
			with this
			.limpiar()
			.Nuevo()
			.Entidad = tcEntidad 
			lcNombre = tcEntidad  +'INICIOAUTOMATICO'
			try
				.Codigo = lcNombre
			catch to loExiste
				.codigo = left(lcNombre, 31) + right( sys(2015),9)
			endtry
			lcPuesto = goservicios.librerias.obtenernombrepuesto()
			lcProducto = _screen.zoo.app.obtenerprefijodb()
			lcSql = "Select ID as nump from ["+ lcProducto + "ZOOLOGICMASTER].[ZOOLOGIC].[PUESTOS] where [NOMBRE] = '" + lcPuesto + "'"
			goDatos.EjecutarSQL( lcSql , 'cur_puesto', set("Datasession" ) )
			lnIdPuesto = cur_puesto.nump
			lcIdParametro = this.ParametroSegunEntidad( alltrim( upper( tcEntidad ) ) )
			use in select ( 'cur_puesto' )
			lcSql = "Select Valor FROM ["+ lcProducto + "ZOOLOGICMASTER].[PARAMETROS].[PUESTO] where [IDUNICO] = '" + lcIdParametro + "' AND [IDPUESTO] = " + alltrim( str( lnIdPuesto ) )
			goDatos.EjecutarSQL( lcSql , 'cur_parametro', set("Datasession" ) )
					
			if reccount('cur_parametro')<1
				lbAux = this.NuevoDespuesDeGrabarSegunEntidad(tcEntidad)
				.NuevoDespuesDeGrabar = lbAux
				
			else
				llValor= iif( upper( alltrim( cur_parametro.Valor ) ) == '.T.', .T., .F. )
				.NuevoDespuesDeGrabar = llValor
				lcSql = "Delete from ["+ lcProducto + "ZOOLOGICMASTER].[PARAMETROS].[PUESTO] where [IDUNICO] = '" + lcIdParametro + "' AND [IDPUESTO] = " + alltrim( str( lnIdPuesto ) )
				try 
					goDatos.EjecutarSQL( lcSql , 'cur_parametro', set("Datasession" ) )
				catch to loError
				endtry	
			
			endif
			use in select ( 'cur_parametro' )
			.Grabar()
			
			endwith
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function NuevoDespuesDeGrabarSegunEntidad(tcEntidad as String) as Void
		local llRetorno as Boolean

		if inlist( tcEntidad, 'FACTURA', 'TICKETFACTURA', 'FACTURAELECTRONICA' )
			llRetorno = .T.
		else
			llRetorno = .F.
		endif
		
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function ParametroSegunEntidad( tcEntidad as String ) as string 		
		local lcCodigoParametro as String
		
		lcCodigoParametro = ''
		do case 
			case tcEntidad = 'REMITO'
				lcCodigoParametro = '1E2A988161335714B0F1917010698007638766'
			case tcEntidad = 'PEDIDO'
				lcCodigoParametro = '1E2A988161335714B0F1917010698007638767'
			case tcEntidad = 'MOVIMIENTODESTOCK'
				lcCodigoParametro = '1E2A988161335714B0F1917010698007638768'
			otherwise
				lcCodigoParametro = '1E2A988161335714B0F1917010698007638765'
		endcase 
		return lcCodigoParametro
	endfunc
	*-----------------------------------------------------------------------------------------
	function SetearValorSegunEntidad( tcEntidad as String ) as Void
		if !this.ExisteRegistroParaLaEntidad( tcEntidad ) and !_screen.zoo.app.obtenervalorreplicabd()
			this.CrearRegistro( tcEntidad )
		endif
	endfunc
	
*!*		*--------------------------------------------------------------------------------------------------------
*!*		function ValidarEntidad() as boolean
*!*			local llRetorno as boolean
*!*			llRetorno = dodefault()
*!*			if llRetorno
*!*				llRetorno = this.ValidarEntidadConComportamiento()
*!*			endif
*!*			return llRetorno
*!*		endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidadConComportamiento( txval as String ) as Boolean
		local llRetorno as Boolean, lcSentencia as String, lcMensaje as String, lcEntidad as String

		lcSentencia = "select * from Accaut where Accaut.Codigo <> '' and Accaut.Codigo <> '" + alltrim( this.Codigo ) + "'" + ;
			" and upper( Entidad ) == '" + alltrim( txVal ) + "'"
		goDatos.EjecutarSentencias( lcSentencia , "Accaut", "", "c_ConsultaAcciones", set( "Datasession" ) )
		
		if reccount( "c_ConsultaAcciones" ) > 0
			llRetorno = .F.
			lcEntidad = iif( empty( this.cDescripcionEntidad ), txVal, this.cDescripcionEntidad )
			lcMensaje = "Atención! La entidad " + alltrim( lcEntidad ) + " posee un comportamiento previamente cargado " + ;
				"(" + alltrim( c_ConsultaAcciones.Codigo ) + ")."
			this.AgregarInformacion( lcMensaje )
		else
			llRetorno = .T.
		endif
		use in select( "c_ConsultaAcciones" )
		
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Entidad( txVal as variant ) as void

		if this.CargaManual() and ( this.esNuevo() or this.esEdicion() ) 
			if !empty( txval ) and !this.ValidarEntidadConComportamiento( txVal )
				goservicios.errores.Levantarexcepcion( this.obtenerInformacion() )
			endif
			if !empty( this.entidad ) and upper( alltrim( this.entidad )) <> upper( alltrim( txval))
				this.accionesDetalle.limpiar()
				this.EventoRefrescarDetalle()
			endif

		endif	

		dodefault( txVal )

		if !goServicios.Estructura.VerificarFuncionalidad( alltrim( txVal ), "<PICKING>" )
			this.lHabilitarRestringirPicking = .f.
		else
			this.lHabilitarRestringirPicking = .t.
		endif
		
		if this.PoseeValorDeCierreEntidad( txVal )
			this.lHabilitarValorDeCierre_PK = .T.
		else
			this.ValorDeCierre_PK			= ""
			this.lHabilitarValorDeCierre_PK = .f.
		endif 

	endfunc

	*-----------------------------------------------------------------------------------------
	function PoseeValorDeCierreEntidad( tcEntidad as String ) as Boolean
		local lbRetorno as Boolean
		lbRetorno = .f.
		if !empty(tcEntidad)
			try 
				if select("lCursorFuncionalidades")=0
					=xmltocursor(goservicios.estrUCTURA.obtenerfuncionalidades(),"lCursorFuncionalidades",4)
				endif 
				select lCursorFuncionalidades
				locate for alltrim( upper( lCursorFuncionalidades.entidad) ) == alltrim( upper( tcEntidad ) )
				if found()
					if "<VALORCIERRE>" $ funcionalidades
						lbRetorno	= .t.
					endif
				endif
			catch
			endtry
		endif
		return lbRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		if select("lCursorFuncionalidades")>0
			select lCursorFuncionalidades
			use
		endif
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoRefrescarDetalle() as Void
		* evento 
	endfunc 
	
enddefine