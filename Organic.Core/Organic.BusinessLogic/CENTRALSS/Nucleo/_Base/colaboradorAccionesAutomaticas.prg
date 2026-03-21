define class ColaboradorAccionesAutomaticas as Custom

	#IF .f.
		Local this as ColaboradorAccionesAutomaticas of ColaboradorAccionesAutomaticas.prg
	#ENDIF

	loEntAux = null
	cCodigoDeAAEnRetenciones = "EXPORTACIONAUTOMATICASIRESUSS"
	
	*-----------------------------------------------------------------------------------------
	Function GeneraAccionesAutomaticasAPSA() As Void
		local lnDisenos as integer, lcExpresion as String

		if glProcesaAPSA
			this.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

			With this.loEntAux
				lcExpresion = "APSA"
				This.EliminaAccionesAutomaticas( this.loEntAux, lcExpresion )

				If this.ValidarHabilitarExportacionAPSA()
					*Solo obtiene los primeros 8 comprobantes, no obtiene notas de débito
					For lnDisenos = 1 To 8
						.Entidad = this.ObtenerEntidad(lnDisenos)
						this.AgregarCabeceraConExpresion(lcExpresion, .Entidad)
						this.AgregarAccionesDetalle("AntesDeGrabar","Exportar", lcExpresion, 1)
						this.AgregarAccionesDetalle("AntesDeAnular","Exportar", lcExpresion, 2)
						this.AgregarAccionesDetalle("DespuesDeGrabar","Exportar", lcExpresion, 3)
						.Grabar()
				 	endfor
				 endif
				.Release()
			endwith
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function GeneraAccionesAutomaticasCABALLITOSHOPPING() As Void
		local lnDisenos as integer, lcExpresion as String

		if glProcesaCABALLITOSHOPPING
			this.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

			With this.loEntAux
				lcExpresion = "CABSHOPPING"
				This.EliminaAccionesAutomaticas( this.loEntAux, lcExpresion )

				If this.ValidarHabilitarExportacionCABALLITOSHOPPING()
					*Solo obtiene los primeros 8 comprobantes, no obtiene notas de débito
					For lnDisenos = 1 To 8
						.Entidad = this.ObtenerEntidad(lnDisenos)
						this.AgregarCabeceraConExpresion(lcExpresion, .Entidad)
						this.AgregarAccionesDetalle("AntesDeGrabar","Exportar", lcExpresion, 1)
						this.AgregarAccionesDetalle("AntesDeAnular","Exportar", lcExpresion, 2)
						this.AgregarAccionesDetalle("DespuesDeGrabar","Exportar", lcExpresion, 3)
						.Grabar()
				 	endfor
				 endif
				.Release()
			endwith
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GeneraAccionesAutomaticasPUNTASHOPPING() as Void
		local lnDisenos as Integer, lcExpresion as String

		if glProcesaPUNTASHOPPING
			this.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

			With this.loEntAux
				lcExpresion = "PUNTASHOPPING"
				This.EliminaAccionesAutomaticas( this.loEntAux, lcExpresion )

				If this.ValidarHabilitarExportacionPuntaShopping()
				*Solo obtiene los primeros 6 comprobantes, no obtiene notas de débito
					For lnDisenos = 1 To 12
						.Entidad = this.ObtenerEntidad(lnDisenos)
						this.AgregarCabeceraConExpresion(lcExpresion, .Entidad)
						this.AgregarAccionesDetalle("AntesDeAnular","Exportar", lcExpresion, 1)
						this.AgregarAccionesDetalle("DespuesDeGrabar","Exportar", lcExpresion, 2)
						.Grabar()
				 	endfor
				 endif
				.Release()
			endwith
		endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	function GeneraAccionesAutomaticasTOTALSALE() as Void
		local lnDisenos as Integer, loNuevoDespuesGrabar as Boolean, lcExpresion as String, loError as Exception 
 
		if glProcesaTOTALSALE
			this.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

			With this.loEntAux
				lcExpresion = "TOTALSALE"
				
				This.EliminaAccionesAutomaticas( this.loEntAux, lcExpresion  )

				If this.ValidarHabilitarExportacionTotalSale()
					For lnDisenos = 1 To 12
						.Entidad = this.ObtenerEntidad(lnDisenos)
						this.AgregarCabeceraConExpresion(lcExpresion, .Entidad)
						this.AgregarAccionesDetalle("DespuesDeAnular","Exportar",lcExpresion ,1)
						this.AgregarAccionesDetalle("DespuesDeGrabar","Exportar",lcExpresion ,2)
						.Grabar()
				 	endfor
				 Endif
				.Release()
			endwith
		Endif
	endfunc 
    
    *-----------------------------------------------------------------------------------------
    function GeneraAccionesAutomaticasVENTASFISERV() as Void
        local lnDisenos as Integer, loNuevoDespuesGrabar as Boolean, lcExpresion as String, loError as Exception 
 
        if glModuloVentasFiServ
            this.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

            With this.loEntAux
                lcExpresion = "VENTASFISERV"
                
                This.EliminaAccionesAutomaticas( this.loEntAux, lcExpresion  )

                If this.ValidarHabilitarExportacionFiServ()
                    For lnDisenos = 1 To 12
                        .Entidad = this.ObtenerEntidad(lnDisenos)
                        this.AgregarCabeceraConExpresion(lcExpresion, .Entidad)
                        this.AgregarAccionesDetalle("DespuesDeAnular","Exportar",lcExpresion ,1)
                        this.AgregarAccionesDetalle("DespuesDeGrabar","Exportar",lcExpresion ,2)
                        .Grabar()
                     endfor
                 Endif
                .Release()
            endwith
        Endif
    endfunc 

    **Función creada para aplicar en los test
    function ValidarHabilitarExportacionFiServ() as Void
        return goparametros.colorytalle.interfases.fiserv.habilitarenviodeventasfiserv
    endfunc 
	*-----------------------------------------------------------------------------------------
	**Función creada para aplicar en los test
	function ValidarHabilitarExportacionTotalSale() as Void
		return goParametros.Felino.Interfases.SolutionsMalls.HabilitarExportacionTOTALSALE
	endfunc 
	*-----------------------------------------------------------------------------------------
	**Función creada para aplicar en los test
	function ValidarHabilitarExportacionAPSA() as Void
		return goParametros.Felino.Interfases.APSA.HabilitarExportacionAPSA
	endfunc 
	*-----------------------------------------------------------------------------------------
	**Función creada para aplicar en los test
	function ValidarHabilitarExportacionCABALLITOSHOPPING() as Void
		return goParametros.Felino.Interfases.CABALLITOSHOPPING.HabilitarExportacionCABALLITOSHOPPING
	endfunc 
	*-----------------------------------------------------------------------------------------
	**Función creada para aplicar en los test
	function ValidarHabilitarExportacionPuntaShopping() as Void
		return goParametros.ColorYTalle.Interfases.PUNTASHOPPING.Habilitar
	endfunc 
	*-----------------------------------------------------------------------------------------
	function AgregarCabeceraConExpresion(tcExpresion as String, tcEntidad as String) as Void
	
		With this.loEntAux
			If .oad.consultarporclavecandidata()
				goDatos.EjecutarSentencias( "Select * From Accaut where Accaut.Codigo <> '' And Upper( Entidad ) == '" + .Entidad + "'" ,;
				 "Accaut", "", "c_Acciones", set( "Datasession" ) )
				
				if reccount( "c_Acciones" ) > 0
					.Codigo = c_Acciones.Codigo
					.Modificar()
				endif	
				Use in Select( "c_Acciones" )
			Else
				.Nuevo()
				.Entidad = tcEntidad
				.Codigo =  substr(tcExpresion + tcEntidad,1,40)
				.NuevoDespuesDeGrabar = .NuevoDespuesDeGrabarSegunEntidad(tcEntidad)
			endif
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarAccionesDetalle(tcMetodo as String, tcAccion as String, tcExpresion as String, tnOrden as Integer) as void
		
		With this.loEntAux
			.AccionesDetalle.limpiaritem()
			this.CrearAccionesDetalle(tcMetodo,tcAccion,tcExpresion,tnOrden)
			.AccionesDetalle.actualizar()
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function CrearAccionesDetalle(tcMetodo as String, tcAccion as String, tcExpresion as String, tnOrden as Integer) as void
		
		With this.loEntAux.AccionesDetalle.oItem
			.Metodo = tcMetodo
			.Accion = tcAccion
			.Expresion = tcExpresion
			.Orden = tnOrden
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EliminaAccionesAutomaticas( toEntidad as Object, tcDiseno as String ) as Void
		Local lnCantidadDetalleBorrado as Integer, lnDiseno as Integer

		For lnDiseno = 1 To 12
			with toEntidad
			
				.Entidad = this.ObtenerEntidad(lnDiseno)
						
				If .oad.consultarporclavecandidata()

					goDatos.EjecutarSentencias ( "Select * From Accaut where Accaut.Codigo <> '' And Upper( Entidad ) == '" + .Entidad + "'" ,;
						"Accaut", "", "c_Acciones", Set( "Datasession" ) )

					If Reccount( "c_Acciones" ) > 0
						.Codigo = c_Acciones.Codigo

						lnCantidadDetalleBorrado = 0

						For Each loItem In toEntidad.ACCIONESDETALLE FoxObject
							If ( tcDiseno $ Upper( loItem.Expresion ) ) Or Empty(loItem.Expresion)
								If lnCantidadDetalleBorrado = 0
									toEntidad.Modificar()
								Endif
								toEntidad.ACCIONESDETALLE.Cargaritem(loItem.nroitem)
								toEntidad.ACCIONESDETALLE.oitem.Metodo=""
								lnCantidadDetalleBorrado = lnCantidadDetalleBorrado + 1
								toEntidad.ACCIONESDETALLE.Actualizar()
							Endif
						endfor
						
						If lnCantidadDetalleBorrado > 0
								toEntidad.Grabar()
						endif
					Endif
					Use In Select( "c_Acciones" )
			  endif
			Endwith
		endfor	
	endfunc

	*-----------------------------------------------------------------------------------------
	function GeneraAccionesAutomaticasParaRetenciones() as Void
		local loColSentencias as zoocoleccion OF zoocoleccion.prg, lcSentencia as String, loDatosFiscales as Object

		if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			loDatosFiscales = _screen.Zoo.InstanciarEntidad( "DATOSFISCALES" )

			try
				loDatosFiscales.Codigo = goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry

			loColSentencias = this.ObtenerSentenciasDeAccionesAutomaticasParaRetenciones( loDatosFiscales )

			for each lcSentencia in loColSentencias
				goServicios.Datos.EjecutarSql( lcSentencia )
			endfor
			goServicios.Entidades.AccionesAutomaticas.RefrescarColeccionDeEntidadesConAccionesAutomaticas()

			loDatosFiscales.Release()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasDeAccionesAutomaticasParaRetenciones( toDatosFiscales as Object ) as zoocoleccion OF zoocoleccion.prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loColSentencias as zoocoleccion OF zoocoleccion.prg, lnAccion as Integer, ;
			loAccionesAutomaticas as Object, loError as Object, llAccionesAutomaticasYaExistentes as Boolean

		loColRetorno = _Screen.zoo.Crearobjeto( "zoocoleccion" )
		if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )

			llAccionesAutomaticasYaExistentes = .F.
			loAccionesAutomaticas = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )
			try
				loAccionesAutomaticas.Codigo = this.cCodigoDeAAEnRetenciones
				llAccionesAutomaticasYaExistentes = .T.
			catch to loError
			endtry

			do case
				case toDatosFiscales.ExportacionesAutomaticasEnOP and !llAccionesAutomaticasYaExistentes
					with loAccionesAutomaticas
						try
							.Nuevo()
							.Codigo = this.cCodigoDeAAEnRetenciones
							.Entidad = "COMPROBANTEDERETENCIONESSUSS"
							.Zadsfw = "Generado automáticamente debido a que el esquema de datos fiscales seteado en los parámetros del sistema tiene configurado que haga la exportación automática para el aplicativo SIRE."
							with .AccionesDetalle
								.limpiaritem()
								.oItem.Metodo = "DespuesDeGrabar"
								.oItem.Accion = "Exportar"
								.oItem.Expresion = "SIRESUSS"
								.oItem.Orden = 1
								.actualizar()
							endwith
							if .Validar()
								loColSentencias = .ObtenerSentenciasInsert()
								for each lcItem in loColSentencias
									loColRetorno.Agregar( lcItem )
								endfor
							else
								goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
							endIf	
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						finally
							.Cancelar()
						endtry	
					endwith

				case !toDatosFiscales.ExportacionesAutomaticasEnOP and llAccionesAutomaticasYaExistentes
					with loAccionesAutomaticas
						try
							.Codigo = this.cCodigoDeAAEnRetenciones
							loColSentencias = .ObtenerSentenciasDelete()
							for each lcItem in loColSentencias
								loColRetorno.Agregar( lcItem )
							endfor
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						endtry	
					endwith
			endcase

			loAccionesAutomaticas.Release()
		endif
		return loColRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidad(tnDiseno as Integer) as String
		local lnEntidad as String
	
		do case 
			case tnDiseno = 1 
				lnEntidad = "FACTURA"
			case tnDiseno = 2
				lnEntidad = "NOTADECREDITO"
			case tnDiseno = 3
				lnEntidad = "TICKETFACTURA"
			case tnDiseno = 4
				lnEntidad = "TICKETNOTADECREDITO"
			case tnDiseno = 5
				lnEntidad = "FACTURAELECTRONICA"
			case tnDiseno = 6
				lnEntidad = "NOTADECREDITOELECTRONICA"
			case tnDiseno = 7
				lnEntidad = "FACTURAELECTRONICADECREDITO"
			case tnDiseno = 8
				lnEntidad = "NOTADECREDITOELECTRONICADECREDITO"
			case tnDiseno = 9
				lnEntidad = "NOTADEDEBITO"
			case tnDiseno = 10
				lnEntidad = "TICKETNOTADEDEBITO"
			case tnDiseno = 11
				lnEntidad = "NOTADEDEBITOELECTRONICA"
			case tnDiseno = 12
				lnEntidad = "NOTADEDEBITOELECTRONICADECREDITO"
		endcase
		
		return lnEntidad
	endfunc 
	*-----------------------------------------------------------------------------------------
	*-----------------------------------------------------------------------------------------
enddefine
