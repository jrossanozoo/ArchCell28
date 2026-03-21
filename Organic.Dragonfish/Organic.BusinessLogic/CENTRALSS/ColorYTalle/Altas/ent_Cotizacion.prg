define class Ent_Cotizacion as Din_EntidadCOTIZACION of Din_EntidadCOTIZACION.prg

	#IF .f.
		Local this as ent_Cotizacion of ent_Cotizacion.prg
	#ENDIF

	*--------------------------------------------------------------------------------------------------------
	function Setear_Moneda( txVal as variant ) as void
		dodefault( txVal )
		this.CargarUltimaCotizacion()
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarUltimaCotizacion() as Void
		local loItemUltimaCotizacion as ItemAuxiliar of Din_DetalleMONEDACotizaciones.prg
		
		if !empty( this.MONEDA.CODIGO )
			loItemUltimaCotizacion = this.MONEDA.ObtenerItemUltimaCotizacion()
			this.UltimaFecha = loItemUltimaCotizacion.Fecha
			this.UltimaHora = loItemUltimaCotizacion.Hora
			this.UltimaCotizacion = loItemUltimaCotizacion.Cotizacion

			this.NuevaFecha = date()
			this.NuevaHora = left( strtran( time(), ":", "" ), 4 )
		endif
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	Function Grabar() As Void
		Local llRetorno As Boolean, llValidar as boolean, ;
		loEx As Exception, loError As Exception, llNuevo as Boolean, llEdicion as Boolean, llErrorAlValidar as Boolean 
		
		this.Codigo = "V"
		llValidar = .F.
		This.LimpiarRegistrosDeActividadAlGrabar()
		With This
			if .EsNuevo()
				try
					.lProcesando = .T.
					.LimpiarInformacion()
					
					local lcAgrupadorDeActividad as String
					lcAgrupadorDeActividad = '<GDA:' + sys( 2015 ) + '>'
					This.IniciarRegistroDeActividadExtendido( 'Grabar' )
					This.IniciarRegistroDeActividadExtendido( 'AntesDeGrabar' )
					
					If .AntesDeGrabar()
						This.EstablecerTiemposEnRegistroDeActividadExtendido( 'AntesDeGrabar' )
						this.ActualizarProgressBar( 40 )
						try
							This.IniciarRegistroDeActividadExtendido( 'Validar' )
							llValidar = .Validar()
							This.EstablecerTiemposEnRegistroDeActividadExtendido( 'Validar' )
							
						Catch To loError
							llErrorAlValidar = .t.
							.ErrorAlValidar()
							This.EliminarRegistrosDeActividad()
							goServicios.Errores.LevantarExcepcion( loError )
							
						finally
							if !llErrorAlValidar and !llValidar
								.ErrorAlValidar()
							endif
						endtry
						
						If llValidar
							try
								.SetearComponentes()
								This.IniciarRegistroDeActividadExtendido( 'oAD_Insertar' )
								lxCodigo = this.GuardarNuevaCotizacion()
								This.EstablecerTiemposEnRegistroDeActividadExtendido( 'oAD_Insertar' )
							Catch To loError
								This.EliminarRegistrosDeActividad()
								goServicios.Errores.LevantarExcepcion( loError )
							endtry
							
							This.IniciarRegistroDeActividadExtendido( 'DespuesDeGrabar' )
							Try
								llValidar = .DespuesDeGrabar()
							Catch to loError
								llValidar = .T.
								loEx = Newobject( 'ZooException', 'ZooException.prg' )
								loEx.Grabar( loError )
								This.oMensaje.Advertir( 'Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.')
							endtry
							
							This.EstablecerTiemposEnRegistroDeActividadExtendido( 'DespuesDeGrabar' )
							Store .F. To .lEdicion , .lNuevo
							.actualizarEstado()
						endif
					endif
					
				Catch To loError
					This.EliminarRegistrosDeActividad()
					loEx = Newobject( 'ZooException', 'ZooException.prg' )
					With loEx
						.Grabar( loError )
						.Throw()
					endwith
				
				finally
					.lProcesando = .F.
				EndTry
			else
				This.EliminarRegistrosDeActividad()
				local loEx as Object
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				With loEx
					.Message = 'Error al intentar Grabar'
					.Details = 'No se puede grabar sin estar en estado NUEVO o EDICION'
					.Grabar()
					.Throw()
				endwith
			endif
			
			If llValidar
				This.EstablecerTiemposEnRegistroDeActividadExtendido( 'Grabar' )
				lcAgrupadorDeActividad = lcAgrupadorDeActividad + '<PK:' + transform( This.CODIGO ) + '>'
				This.FinalizarRegistrosDeActividad( lcAgrupadorDeActividad )
			else
				This.EliminarRegistrosDeActividad()
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				loEx.oInformacion = .ObtenerInformacion()
				loEx.Throw()
			endif

		Endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GuardarNuevaCotizacion() as Void
		if !empty( this.MONEDA.CODIGO )
			with this.MONEDA
				.Modificar()
	
				.COTIZACIONES.LimpiarItem()
				.COTIZACIONES.oItem.Fecha = this.NuevaFecha
				.COTIZACIONES.oItem.Hora = left(strtran(this.NuevaHora,":",""),4)
				.COTIZACIONES.oItem.Cotizacion = this.NuevaCotizacion
				.COTIZACIONES.Actualizar()

				loSentencias = .oAD.ObtenerSentenciasUpdate() 
				.Cancelar() 
				for each sentencia in loSentencias
					if at ("ZOOLOGIC.COTIZA",alltrim(upper(sentencia))) > 0
						goServicios.Datos.EjecutarSQL( sentencia )
					endif
				endfor
				
				text to lcSentencia noshow textmerge
				update zoologic.MONEDA set 
					  FModiFW = '<<dtoc( goServicios.Librerias.obtenerfecha(), 1 )>>' , 
					  HModiFW = '<<golibrerias.obtenerhora()>>' , 
					  UmodiFW = '<<goServicios.Seguridad.cUsuarioLogueado>>' , 
					  SmodiFW = '<<_Screen.Zoo.App.cSerie>>' , 
					  VmodiFW = '<<_screen.zoo.app.cVersionSegunIni>>' , 
					  BDmodiFW = '<<_screen.zoo.app.cSucursalActiva>>'
				where codigo = '<<this.MONEDA.CODIGO>>'
			endtext			
			goServicios.Datos.EjecutarSQL( lcSentencia )
			
			endwith
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_NuevaCotizacion( txVal as variant ) as Boolean
		local llValido as Boolean
		
		if txVal > 0
			llValido = dodefault( txVal ) 
		else
			llValido = .F.
			goServicios.Errores.LevantarExcepcion( "La cotización debe ser mayor a 0." )
		endif
		
		return llValido
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		this.lNuevo = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarExistencia() as Boolean
		return .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AjustarObjetoBusqueda( toBusqueda as Object ) as Void
		toBusqueda.Filtro  = "MONEDA.CODIGO != '" + goparametros.felino.generales.monedasistema + "'"
	endfunc

enddefine	
