define class KontrolerBONIFICACIONIISS as din_KontrolerBONIFICACIONIISS of din_KontrolerBONIFICACIONIISS.prg

	oFormAPROBACION = null
	cEntidadAprobacion = "APROBACIONBONIFICACIONIISS"
	ColorClaroDefault = 0
	ColorNormalDefault = 0 
		
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local loGrillaDetalleiiss  AS Object, loGrillaDetalleDetalleZN as Object  
		dodefault()
		this.Enlazar( "oEntidad.EventoRefrescarDetalleIISS", "RefrescarDetalleIISS" )
		this.Enlazar( "oEntidad.EventoRefrescarDetalleZN", "RefrescarDetalleZN" )
		this.enlazar( "oEntidad.EventoActualizarRazonSocial", "RefrescarCombo" )
		this.enlazar( "oEntidad.EventoRefrescarRZ", "RefrescarRZ" )
		this.enlazar( "oEntidad.EventoRefrescarAtributosDeTipoBonificacionModificados", "RefrescarAtributosDeTipoBonificacionModificados" )
		this.ObtenerColorDefaultItemsDetalles()
		loGrillaDetalleiiss = this.ObtenerControl( "Detalleiiss" )
		this.Bindearevento( loGrillaDetalleiiss.oBarraDeDesplazamiento, "MoverGrilla", this, "ResaltarItemBONIFICACIONIISSDetalleIISSDespuesDeScrolar" )
		loGrillaDetalleDetalleZN = this.ObtenerControl( "DetalleZN" )
		this.Bindearevento( loGrillaDetalleDetalleZN.oBarraDeDesplazamiento, "MoverGrilla", this, "ResaltarItemBONIFICACIONIISSDetalleZNDespuesDeScrolar" )
		bindevent( this.oEntidad, "PreguntarBonificacionesOtorgadas", this, "PreguntarBonificacionesOtorgadas", 1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColorDefaultItemsDetalles() as Void
		local loControl as object, loDetalleiiss as object 
		loDetalleiiss = this.ObtenerControl( this.oEntidad.Detalleiiss.cNombre )
		loControl = loDetalleiiss .ObtenerCampoPorAtributo( 1, "PorcentajeDescuento" )
		this.ColorClaroDefault = loControl.nDISABLEDBACKCOLORCLARO 
		this.ColorNormalDefault = loControl.ndiSABLEDBACKCOLORNORMAL 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarAtributosDeTipoBonificacionModificados() as Void
		local lnForeColorSinFoco  as Integer,  lDisabledBackColor as Integer, lDisabledBackColorAux as Integer, loControl as object

		loControl = this.ObtenerControl('DescripNC')
		lDisabledBackColorAux = loControl.DisabledBackColor  
		lnForeColorSinFoco =  rgb( 255, 255, 255 )
		lDisabledBackColor = rgb( 255, 175, 175 )
		
		with  this.oEntidad 
			loControl = this.ObtenerControl('DescGral')
			if .DescGral  = .DescuentoOriginalDelTipo  
				loControl.DisabledBackColor = lDisabledBackColorAux 
			else 	 
				loControl.DisabledBackColor = lDisabledBackColor 
			endif
			
			loControl = this.ObtenerControl('FechaDsde')
			if .FechaDsde  = .FechaDesdeOriginalDelTipo 
				loControl.DisabledBackColor = lDisabledBackColorAux 
			else 	 
				loControl.DisabledBackColor = lDisabledBackColor 
			endif

			loControl = this.ObtenerControl('FechaHasta')
			if .FechaHasta = .FechaHastaOriginalDelTipo 
				loControl.DisabledBackColor = lDisabledBackColorAux 
			else 	 
				loControl.DisabledBackColor = lDisabledBackColor 
			endif
	    endwith                    

	    this.ResaltarItemBONIFICACIONIISSDetalleIISSNavegando()
	    this.ResaltarItemBONIFICACIONIISSDetalleZNNavegando()
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ResaltarItemBONIFICACIONIISSDetalleIISSNavegando() as Void
		this.ResaltarItemBONIFICACIONIISSDetalle( this.oEntidad.Detalleiiss, 'Navegando' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResaltarItemBONIFICACIONIISSDetalleZNNavegando() as Void
		this.ResaltarItemBONIFICACIONIISSDetalle( this.oEntidad.DetalleZN, 'Navegando' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResaltarItemBONIFICACIONIISSDetalleIISSDespuesDeScrolar() as Void
		this.ResaltarItemBONIFICACIONIISSDetalle( this.oEntidad.Detalleiiss, 'DespuesDeScrolar' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResaltarItemBONIFICACIONIISSDetalleZNDespuesDeScrolar() as Void
		this.ResaltarItemBONIFICACIONIISSDetalle( this.oEntidad.DetalleZN, 'DespuesDeScrolar' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResaltarItemBONIFICACIONIISSDetalle( toDetalleEntidad as Object, tcAccion as String  ) as Void
		local lnFilaAResaltar as Integer, lnDiferenciaEntreFilasAResaltar as integer, loDetalle as Object,;
			lnRegistroInicioDePantalla as Integer, lnCantidadItemsVisibles as Integer, lResaltar as Boolean,;
			loerr as exception, lnItem as Integer 
			
		loDetalle = this.ObtenerControl( toDetalleEntidad.cNombre )
		if upper( tcAccion ) = upper ( 'Navegando' )
			loDetalle.nRegistroInicioPantalla = 1
		endif 

		lnRegistroInicioDePantalla = loDetalle.nRegistroInicioPantalla
		lnCantidadItemsVisibles = loDetalle.nCantidadItemsVisibles  &&min(toDetalleEntidad.Count, loDetalle.nCantidadItemsVisibles )		

		for i = 1  to lnCantidadItemsVisibles 
			lResaltar  = .f.
			if upper( tcAccion ) = upper ( 'DespuesDeScrolar' )
				lnItem = i + lnRegistroInicioDePantalla - 1
			else
				lnItem = i
			endif	
			try 
				lResaltar  = ( toDetalleEntidad.item( lnItem ).OrdenAux < 999 )
			catch to loerr
			finally
				this.ResaltarItemConDiferencias( i , loDetalle, lResaltar ) 
			endtry 
			
		endfor
		
	endfunc	
		
	*-----------------------------------------------------------------------------------------
	function ResaltarItemConDiferencias( tnNumeroItem as Integer, toControlDetalle as Object, tCambio as Boolean ) as Void
		local loControl as object, lnColorClaro as Integer, lnColorNormal as Integer

		if  tCambio 
			lnColorClaro =   rgb( 220, 180, 180 ) 
			lnColorNormal =  rgb( 235, 205, 205 ) 
		else
			lnColorClaro = this.ColorClaroDefault 
			lnColorNormal = this.ColorNormalDefault 
		endif
       
		if upper(toControlDetalle.Name) = upper('BONIFICACIONIISSDetalleIISS')
			loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "NroItemServ" )		
			loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
			loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  

			loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "NroItemServDetalle" )
			loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
			loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  
		endif	

		if upper(toControlDetalle.Name) = upper('BONIFICACIONIISSDetalleZN')
			loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "Articulo" )		
			loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
			loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  

			loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "ArticuloDetalle" )
			loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
			loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  

			loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "Cantidad" )
			loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
			loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  
		endif	
		
		loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "PorcentajeDescuento" )		
		loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
		loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal 
		
		loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "Precio" )		
		loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
		loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  

		loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "MontoDescuento" )
		loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
		loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal  

		loControl = toControlDetalle.ObtenerCampoPorAtributo( tnNumeroItem, "SubTotalBonificacion" )				
		loControl.nDISABLEDBACKCOLORCLARO = lnColorClaro 
		loControl.ndiSABLEDBACKCOLORNORMAL = lnColorNormal 				
		
		toControlDetalle.CambiarColorDeFondoFila( tnNumeroItem )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarCombo() as Void
		local loControl as Object

		loControl = this.ObtenerControl( "RAZONSOCIAL" )
		with loControl
			.CargarDatosEnCursor( this.oentidad.cCursorCombo )
			.lDesplegarLista = iif( .ObtenerCantidadDeElementos() > 1, .t., .f. )
			this.oEntidad.lDesplegarComboRZ = .lDesplegarLista
			if .lDesplegarLista
			else
				.EjecutarValid()
			endif
			.refrescar()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarRZ() as Void
		local loControl as Object, lcSql as String, lcValor as String, lcDescripcionRazonSocial as String

		lcValor = alltrim( this.oEntidad.Razonsocial_PK )
		loControl = this.ObtenerControl( "RAZONSOCIAL" )
		with loControl
			lcDescripcionRazonSocial = .ObtenerDescripcionRazonSocial( lcValor )
			.BorrarCursor()
			.ActualizarDatosControl( lcDescripcionRazonSocial, lcValor )
			.lDesplegarLista = iif( .ObtenerCantidadDeElementos() > 1, .t., .f. )
			.refrescar()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function MostrarObserv() as Void
		local loControl as Object
		loControl = this.ObtenerControl( "Observ" )
		loControl.DblClick()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarBarra( tcEstado as String ) as Void
		dodefault( tcEstado )
		this.SetearEnabledMenu( "Acciones", "LanzarAprobacion", (!this.oEntidad.EsNuevo() and !this.oEntidad.EsEdicion() and this.Numero > 0 ) )
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function LanzarAprobacion() as Void
		With This
			.setearestadomenuytoolbar(.F.)
			with .oFormAPROBACION
				.Nuevo()
				.oEntidad.Bonificacion_Pk = This.Numero
				.oEntidad.Aprobacion_Pk   = '1'
				.Show(1)
			endwith 	
			.setearestadomenuytoolbar(.T.)
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function oFormAPROBACION_Access()
		If  !This.ldestroy And !Vartype( This.oFormAPROBACION ) = 'O'
			This.oFormAPROBACION = goformularios.procesarsubentidad( This.cEntidadAprobacion )
			Bindevent( This.oFormAPROBACION.okontroler.oEntidad, "DespuesdeGrabar", This, "OcultarFormularioCancelar"  )
			Bindevent( This.oFormAPROBACION.okontroler.oEntidad, "DespuesdeGrabar", This, "RefrescarDetalleAprobaciones" )
			Bindevent( This.oFormAPROBACION.okontroler.oEntidad, "Cancelar", This, "OcultarFormularioCancelar", 1 )
		Endif
		Return This.oFormAPROBACION
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function  OcultarFormularioCancelar()  As VOID
		This.oFormAPROBACION.Visible = .F.
	Endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalleAprobaciones() as Void
		local loDetalle as Object , loItem as Object 
		loItem = this.oEntidad.DetalleAprobaciones.CrearItemAuxiliar() 
		with loItem
			.NroItem 		= this.oEntidad.DetalleAprobaciones.ncANTIDADDEITEMSCARGADOS + 1
			.Numero_Pk		= This.oFormAPROBACION.okontroler.oEntidad.Numero
			.Estado_Pk		= This.oFormAPROBACION.okontroler.oEntidad.Aprobacion_Pk
			.Solicitante_Pk	= This.oFormAPROBACION.okontroler.oEntidad.UsuarioALTAFW
			.fecha			= This.oFormAPROBACION.okontroler.oEntidad.fechaALTAFW
		endwith 	
		This.oEntidad.DetalleAprobaciones.add( loItem )
		with this.oEntidad.DetalleAprobaciones
			.ncANTIDADDEITEMSCARGADOS = .ncANTIDADDEITEMSCARGADOS + 1
			.CambioSumarizado()
			.Sumarizar()
		endwith 	
		loDetalle = this.obtenerControl( "DetalleAprobaciones" )
		loDetalle.RefrescarGrilla()
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalleIISS() as Void
		local loControl as Object
		loControl = this.ObtenerControl( "DetalleIISS" )
		loControl.oBarraDeEstado.SetearTituloEtiqueta( "" )
		loControl.RefrescarGrilla()
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalleZN() as Void
		local loControl as Object
		loControl = this.ObtenerControl( "DetalleZN" )
		loControl.RefrescarGrilla()
	endfunc

	*-----------------------------------------------------------------------------------------
	function PreguntarBonificacionesOtorgadas( tcMensaje as String ) as Void
		this.oEntidad.lTieneBonificacionesOtorgadas = ( goServicios.Mensajes.Preguntar( tcMensaje, 4, 0 ) = 6 )
	endfunc
	
enddefine
