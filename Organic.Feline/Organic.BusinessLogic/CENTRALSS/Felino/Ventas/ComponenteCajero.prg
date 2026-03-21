define class ComponenteCajero as Din_componenteCajero of Din_ComponenteCajero.prg

	#if .f.
		Local this as ComponenteCajero as ComponenteCajero.prg
	#endif

	#define TIPOVALORCHEQUETERCERO 			4
	
	oDetalleAnterior = Null

	*--------------------------------------------------------------------------------------------------------
	function oDetalleAnterior_Access() as variant
		if !this.ldestroy
			if vartype( this.oDetalleAnterior ) != 'O'
				this.oDetalleAnterior = _Screen.zoo.CrearObjeto( 'ZooColeccion' )
			endif
		endif
		return this.oDetalleAnterior
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ProcesarItem( tcAtributo as String, toItem as Object ) as Void
		local loComponente as Object 

		loComponente = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull(loComponente)
			loComponente.ProcesarItem( tcAtributo , toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularTotales( toItem as Object ) as Void
		local loComponente as Object 

		loComponente = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull(loComponente)
			loComponente.RecalcularTotales( toItem )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InicializarComponentes( tlLimpiar as Boolean ) as Void
		local loColeccion as zoocoleccion OF zoocoleccion.prg, lcComponente as String
		This.oDetalleAnterior.Remove( -1 )
		if tlLimpiar
		else
			This.CopiarValoresAnteriores( )
		endif

		loColeccion = goCaja.ObtenerTodosLosComponentes()
		for each loItem in loColeccion
			lcComponente = "This.oComp" + alltrim( loItem )
			&lcComponente..InyectarDetalle( This.oDetallePadre )
			&lcComponente..InyectarEntidad( This.oEntidadPadre )
			&lcComponente..InyectarDetalleAnterior( This.oDetalleAnterior )

			&lcComponente..Reinicializar( tlLimpiar  )
		EndFor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CopiarValoresAnteriores( tcAccion as String ) as Void
		local loItem as Object, lnItem as Integer 
		this.oDetalleAnterior.Remove( -1 )
		for lnItem  = 1 to this.oDetallePadre.Count
			loItem = this.oDetallePadre.Item( lnItem  )
			if empty( loItem.Valor_PK )
			else
				loItemAux = newobject( "Custom" )
				loItemAux.addproperty( "Total", loItem.Total )
				loItemAux.addproperty( "Valor_PK", loItem.Valor_PK )
				loItemAux.addproperty( "Caja_PK", loItem.Caja_PK )
				loItemAux.addproperty( "ValorDetalle", loItem.ValorDetalle )
				loItemAux.addproperty( "Cotiza", loItem.Cotiza )
				loItemAux.addproperty( "Tipo", loItem.Tipo )
				loItemAux.AddProperty( "NroItem", loItem.NroItem )
				loItemAux.addproperty( "Fecha", loItem.Fecha )
				
				if pemstatus( loItem, "Recibido", 5 )
					loItemAux.addproperty( "Recibido", loItem.Recibido )
				endif
				if pemstatus( loItem, "NumeroCheque_PK", 5 )
					loItemAux.addproperty( "NumeroCheque_PK", loItem.NumeroCheque_PK )
				else
					loItemAux.addproperty( "NumeroCheque_PK", "" )
				endif
				if pemstatus( loItem, "NumeroChequePropio_PK", 5 )
					loItemAux.addproperty( "NumeroChequePropio_PK", loItem.NumeroChequePropio_PK )
				else
					loItemAux.addproperty( "NumeroChequePropio_PK", "" )
				endif
				if loItem.Tipo = TIPOVALORCHEQUETERCERO
					loItemAux.addproperty( "Observacion", "" )
				endif
				if pemstatus( loItem, "VisualizarEnEstadoDeCaja", 5 )
					loItemAux.addproperty( "VisualizarEnEstadoDeCaja", loItem.VisualizarEnEstadoDeCaja )
				else
					loItemAux.addproperty( "VisualizarEnEstadoDeCaja", "" )
				endif
				
				this.oDetalleAnterior.Agregar( loItemAux )
				loItemAux.destroy()
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoMODIFICAR( tcEstado as String ) as boolean
		local llRetorno as Boolean, loColComponentesAgrupados as zoocoleccion OF zoocoleccion.prg, ;
			lcComponente as String, lcItem as Object, i as integer
		
		llRetorno = .t.

		loColComponentesAgrupados = this.ObtenerColeccionDeComponentesAgrupados()

		for i = 1 to loColComponentesAgrupados.Count
			lcItem = loColComponentesAgrupados.Item[ i ]
			lcComponente = "This.oComp" + alltrim( lcItem )
			llRetorno = llRetorno and &lcComponente..VotarCambioEstadoMODIFICAR( tcEstado )
		endfor

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoANULAR( tcEstado as String ) as boolean
		local llRetorno as Boolean, i as integer, loColComponentesAgrupados as zoocoleccion OF zoocoleccion.prg, ;
			lcItem as Object, loComponentesQueDebenForzarLaVotacion as Object, i as Integer
		
		llRetorno = .t.

		loColComponentesAgrupados = this.ObtenerColeccionDeComponentesAgrupados()

		for i = 1 to loColComponentesAgrupados.Count
			lcItem = loColComponentesAgrupados.Item[ i ]
			lcComponente = "This.oComp" + alltrim( lcItem )
			llRetorno = llRetorno and &lcComponente..VotarCambioEstadoAnular( tcEstado )
		endfor
		
		if llRetorno &&Se fuerza votacion.

			loComponentesQueDebenForzarLaVotacion = this.ObtenerComponentesAForzarVotacionAnular()
			for i = 1 to loComponentesQueDebenForzarLaVotacion.Count
				lcItem = loComponentesQueDebenForzarLaVotacion.Item[ i ]
				lcComponente = "This.oComp" + alltrim( lcItem )
				llRetorno = llRetorno and &lcComponente..VotarCambioEstadoAnular( tcEstado )
			endfor
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoGRABAR( tcEstado as String ) as boolean
		local llRetorno as Boolean, i as integer, loColComponentesAgrupados as zoocoleccion OF zoocoleccion.prg, ;
			lcItem as Object

		llRetorno = .t.

		loColComponentesAgrupados = this.ObtenerColeccionDeComponentesAgrupados()
		
		for i = 1 to loColComponentesAgrupados.Count
			lcItem = loColComponentesAgrupados.Item[ i ]
			lcComponente = "This.oComp" + alltrim( lcItem )
			llRetorno = llRetorno and &lcComponente..VotarCambioEstadoGrabar( tcEstado )
		endfor
		
		release loColComponentesAgrupados

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function obtenerColeccionDeComponentesAgrupados() as zoocoleccion OF zoocoleccion.prg
		local i as Integer, loColRetorno as zoocoleccion OF zoocoleccion.prg, lcComponente as String, loItem as Object
		
		loColRetorno = newObject( "Collection" )
		for i = 1 to this.oDetallePadre.count
			loItem = this.oDetallePadre.Item[ i ]
			if vartype( loItem.AutorizacionPOS ) = "L" and loItem.Tipo = 0 and loItem.AutorizacionPOS
				loItem.Tipo = 3
			endif

			if loItem.Tipo > 0
				lcComponente = goCaja.ObtenerComponente( loItem.Tipo )
				
				local llExiste
				llExiste = .f.
				for each loItem IN loColRetorno
					if lcComponente == loItem 
						llExiste = .t.
						exit
					endif
				endfor
	
				if !llExiste
					loColRetorno.Add( lcComponente, lcComponente )
				endif
			endif
		endfor
		
		lcComponente = goCaja.ObtenerComponente( 10 )
		if !empty( lcComponente ) 

			local llExiste
			llExiste = .f.
			for each loItem IN loColRetorno
				if lcComponente == loItem 
					llExiste = .t.
					exit
				endif
			endfor

	 		if !llExiste
				loColRetorno.Add( lcComponente, lcComponente )
			endif
			
		endif
		
		return loColRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function obtenerComponente( tnTipo ) as Object 
		local lcComponente as String, loRetorno as Object

		loRetorno = null
		lcComponente = goCaja.ObtenerComponente( tnTipo )
		
		if !empty( lcComponente )
			lcComponente = "This.oComp" + alltrim( lcComponente )
			loRetorno = &lcComponente
		endif
		
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabarEntidadPadre() as Boolean
		local llRetorno as Boolean, loColComponentesAgrupados as zoocoleccion OF zoocoleccion.prg, ;
			lcComponente as String, lcItem as Object, lnNumeroI as integer
		
		llRetorno = .t.

		loColComponentesAgrupados = this.ObtenerColeccionDeComponentesAgrupados()

		for lnNumeroI = 1 to loColComponentesAgrupados.Count
			lcItem = loColComponentesAgrupados.Item[ lnNumeroI ]
			lcComponente = "This.oComp" + alltrim( lcItem )
			llRetorno = llRetorno and &lcComponente..AntesDeGrabarEntidadPadre()
		endfor
		
		if llRetorno and this.oEntidadPadre.cNombre == "PAGO"
			for lnNumeroI = 1 to this.oDetallePadre.Count
				loItem = this.oDetallePadre.Item[ lnNumeroI ]
				loItem.Caja_PK = iif( empty( loItem.Caja_PK ), goParametros.Felino.GestionDeVentas.NumeroDeCaja, loItem.Caja_PK )
			endfor
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Imprimir( toItem as object ) as Void
		local loComp as Object
		
		loComp = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull( loComp )
			loComp.Imprimir( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDatosDelValor( toItem as object, toDetalle as object  ) as VOID
	local llNumeroInternoHabiitado as Boolean 
		with this
			.RemoverDatosSiCambioTipo( toItem )

			if .VerificarSiSeteaDatos( toItem )
				.SetearYVerificarDatos( toItem )
			else
				toItem.NumeroCheque_PK = ""
				toItem.NumeroValeDeCambio_PK = ""
				if pemstatus( toitem, "lHabilitarNumeroInterno", 5 )
					llNumeroInternoHabiitado = toItem.lHabilitarNumeroInterno 
					toItem.lHabilitarNumeroInterno = .t.
					toItem.NumeroInterno = ""
					toItem.lHabilitarNumeroInterno = llNumeroInternoHabiitado
				else
					toItem.NumeroInterno = ""
				endif 
				toItem.NumeroChequePropio_PK = ""
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarYSetearRetiroEnEfectivo( tcAtributo as String, toItem as Object ) as Void
		local loComp as Object
		
		if upper( tcAtributo ) == "VALOR_PK"
			this.VerificarYEliminarRetiroEnEfectivo( toItem )
			if pemstatus( toItem, "Recibido", 5 ) and vartype( this.oEntidadPadre) = 'O'
				this.VerificarYSetearRetiroEnEfectivoEnEntidad( toItem )
			endif
		endif
	endfunc  

	*-----------------------------------------------------------------------------------------
	function VerificarYEliminarRetiroEnEfectivo( toItem as Object ) as Void
		if pemstatus( toItem, "iditemretiroenefectivo", 5 ) and !empty( toItem.iditemretiroenefectivo )
			this.oEntidadPadre.oColaboradorRetiroDeEfectivo.VerificarYEliminarRetiroEnEfectivo( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarYSetearRetiroEnEfectivoEnEntidad( toItem as Object ) as Void
		local lnMontoRetiroEfectivo as Integer, loValor as Object
	
		lnMontoRetiroEfectivo = 0
		loValor = toItem.valor

		if loValor.HabilitarRetiroEfectivo
				with this.oEntidadPadre
					if .RetiraEfectivo()
						if pemstatus( this.oEntidadPadre, "oColaboradorRetiroDeEfectivo", 5 )
					 		.oColaboradorRetiroDeEfectivo.CargarMontoRetiroEnEfectivo( loValor, toItem )
					 	endif
					endif
				endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarSiSeteaDatos( toItem as Object ) as boolean
		local loComp as Object, llRetorno as boolean
		
		llRetorno = .f.
		
		loComp = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull( loComp )
			llRetorno = loComp.VerificarSiSeteaDatos( toItem )
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearYVerificarDatos( toItem as object ) as Void
		local loComp as Object

		loComp = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull( loComp )
			loComp.SetearYVerificarDatos( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RemoverDatosSiCambioTipo( toItem as object ) as Void
		local loComp as Object

		if toItem.Tipo <> toItem.Valor.Tipo
			loComp = this.ObtenerComponente( toItem.Tipo )
			if !isnull( loComp ) 
				loComp.RemoverDatosSiCambioTipo( toItem )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeItemAlItemCero( toItem as object ) as Void
		local loComp as Object
		loComp = this.ObtenerComponente( toItem.Tipo )
		if !isnull( loComp )
			loComp.AsignarNumeroDeItemAlItemCero( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeSetearAtributo( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		local loComp as Object
		loComp = this.ObtenerComponente( toObject.Tipo )
		if !isnull( loComp )
			loComp.AntesDeSetearAtributo( toObject, tcAtributo, txValOld, txVal )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AplicarRecargoDirecto( toItem as Object ) as Void
		local loComp as Object
		loComp = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull( loComp )
			loComp.AplicarRecargoDirecto( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeCalcularRecargo( toItem as Object, toValor as Ent_Valor of Ent_Valor.prg ) as Void
		local loComp as Object
		loComp = this.ObtenerComponente( toItem.Valor.Tipo )
		if !isnull( loComp )
			loComp.DebeCalcularRecargo( toItem, toValor )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponentesAForzarVotacionAnular() as zoocoleccion OF zoocoleccion.prg
		local loColRetorno as zoocoleccion OF zoocoleccion.prg, loComponentes as zoocoleccion OF zoocoleccion.prg, ;
			lcComponente as String, lcItem as tring	
		
		loColRetorno = _screen.zoo.CrearObjeto( "zooColeccion" )
			
		loComponentes = goCaja.ObtenerTodosLosComponentes()
		for each lcItem in loComponentes FOXOBJECT
			if !loColRetorno.Buscar( lcItem )
				lcComponente = "This.oComp" + alltrim( lcItem )
				if &lcComponente..DebeForzarVotarCambioEstadoANULAR()
					loColRetorno.agregar( lcItem, lcItem)
				endif
			endif
		endfor
		return loColRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerGUIDChequeSegunNroInterno( tnTipoValor as Integer, tnNumeroInterno as Integer ) as string
		local loComponente as Object 
		loComponente = this.obtenerComponente( tnTipoValor )
		return loComponente.ObtenerGUIDSegunNroInterno( tnNumeroInterno)
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarChequeDesdeNroInterno(  tcGuid as String , toItem as Object  ) as string
		local loComponente as Object 
		loComponente = this.obtenerComponente( toItem.valor.tipo )
		loComponente.CargarChequeDesdeNroInterno( tcGuid , toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarNuevoCuponHuerfanoAlConjuntoDeCupones( toItem as Object ) as Void
		local loComponente as Object 
		loComponente = this.obtenerComponente( 3 )
		loComponente.AgregarNuevoCuponHuerfanoAlConjuntoDeCupones( toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarTextoAdicionalADescripcionDelValorPorCuponIntegrado( tcDescripcion as String ) as String
		local loComponente as Object, lcRetorno as String
		loComponente = this.obtenerComponente( 3 )
		lcRetorno = loComponente.AgregarTextoAdicionalADescripcionDelValorPorCuponIntegrado( tcDescripcion )
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanosAplicados() as zoocoleccion OF zoocoleccion.prg 
		local loComponente as Object 
		loComponente = this.obtenerComponente( 3 )
		return loComponente.ObtenerCuponesHuerfanosAplicados()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function QuitarCuponHuerfanoAplicado( tcItem as String ) as Void
		local loComponente as Object 
		loComponente = this.obtenerComponente( 3 )
		return loComponente.QuitarCuponHuerfanoAplicado( tcItem )			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCuponParaAnulacion( toItem as Object ) as Object 
		local loComponente as Object 
		loComponente = this.obtenerComponente( 3 )
		return loComponente.ObtenerCuponParaAnulacion( toItem )			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPrefijoDeCuponIntegrado() as string 
		local loComponente as Object 
		loComponente = this.obtenerComponente( 3 )
		return loComponente.ObtenerPrefijoDeCuponIntegrado()			
	endfunc 
	
enddefine
