define class ent_stockproduccion as entidad of entidad.prg

	#if .f.
		local this as ent_stockproduccion of ent_stockproduccion.prg
	#endif

	GeneraStock = 1
	Cantidad = 0
	CantidadOriginal = 0
	lHabilitaControlStock = .T.
	lPiezaCerrada = .F.
	cMensajeSinStock = "No se puede realizar esta operación. Sin stock ó stock afectado por otro/s comprobante/s."
	nCodigoDeErrorPorFaltaDeStock = 65454
	lGrabandoComponente = .f.
	nCantidadDisponibleEnAgrupamiento = 0
	lSinBuscarNiCargar = .f.
	lFlagEsNuevo = .F.
	*-----------------------------------------------------------------------------------------
	function ObtenerStock( toItem ) as integer 
		local lnStock as Integer 
		lnStock = 0
		return 	lnStock
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		local llRetorno as Boolean
		llRetorno = dodefault() and This.ValidarCantidad()
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		This.CantidadOriginal = This.Cantidad
		This.oAtributosAuditoria.CantidadOriginal = This.Cantidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ModificarSinBuscarYCargar() as Void

		This.lEdicion = .T.
		This.lNuevo = .F.
		This.CantidadOriginal = This.Cantidad
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CancelarSinBuscarYCargar() as Void
		This.lEdicion = .F.
		This.lNuevo = .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidad() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if This.NoVerificaStock() or this.IncorporaStockDePedidosDeCompras()
		else
			if	( This.EsNuevo() and This.Cantidad < 0 ) or ;
				( This.EsEdicion() and This.Cantidad < 0 and ( This.ObtenerCantidadOriginal() + This.Cantidad < 0 ) )
				This.AgregarInformacion( This.cMensajeSinStock )
				llRetorno = .F.
			endif
		Endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadOriginal( ) as Integer
		local lnRetorno as Integer, lcXml as String, lcAtributo As String, lxValorAtributo as Variant
		lnRetorno = 0
		lcAtributo = This.ObtenerAtributoClavePrimaria()
		lxValorAtributo = This.&lcAtributo
		lcXml = This.oAd.ObtenerDatosEntidad( "", lcAtributo + " == '" + lxValorAtributo + "'" )
		This.XmlACursor( lcXml, "c_CursorAux" )
		lnRetorno = c_CursorAux.Cantidad
		use in select( "c_CursorAux" )
		return lnRetorno		

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_Cantidad( txVal as Variant ) as Boolean
		local llRetorno as Boolean, llCondicionValidar as Boolean
		llRetorno = dodefault( txVal )

		if llRetorno and !this.lSinBuscarNiCargar
			if This.NoVerificaStock()
			else
				if this.VerificaStockAgrupamiento()
					this.DelegarEventoSetearCantidadDisponibleEnAgrupamiento()
					llCondicionValidar = ( This.nCantidadDisponibleEnAgrupamiento + iif( this.lFlagEsNuevo  , txVal, 0 ) < 0 )
				else
					llCondicionValidar = ( This.EsNuevo() and txVal < 0 ) Or ( This.EsEdicion() and txVal < 0 and ( This.CantidadOriginal + txVal < 0 ) )
				endif
				
				if	llCondicionValidar
					llRetorno = .F.
					if this.lGrabandoComponente and goParametros.Felino.Generales.PermitirPasarSinStock
						this.EventoNoHayStock()
						llRetorno = .t.
					else
						this.ExcepcionNoHayStock()
					endif
				endif
			endif
		endif

		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function DelegarEventoSetearCantidadDisponibleEnAgrupamiento() as Void
	endfunc 


	*-----------------------------------------------------------------------------------------
	function EventoNoHayStock() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExcepcionNoHayStock() as Void
		goServicios.Errores.LevantarExcepcionTexto( This.cMensajeSinStock, this.nCodigoDeErrorPorFaltaDeStock ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function NoVerificaStock() as Boolean
		return This.GeneraStock = 2 or !This.lHabilitaControlStock &&or !empty( goParametros.Nucleo.AgrupamientoParaConsultaDeStock ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificaStockAgrupamiento() as Boolean
		return !empty( goParametros.Nucleo.AgrupamientoParaConsultaDeStock ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasSql( tlEsNuevo as Boolean ) as zoocoleccion OF zoocoleccion.prg 
		local loColRetorno as zoocoleccion Of zoocoleccion.prg
		if tlEsNuevo
			loColRetorno = this.ObtenerSentenciasInsert()
		else
			loColRetorno = this.ObtenerSentenciasUpdate()
		endif
		return loColRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IncorporaStockDePedidosDeCompras() as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus(goParametros, "ColorYTalle", 5 ) and goParametros.ColorYTalle.GestionDeVentas.IncorporaElStockDePedidosDeCompraAlDisponible
		return llRetorno 
	endfunc 

	
enddefine
