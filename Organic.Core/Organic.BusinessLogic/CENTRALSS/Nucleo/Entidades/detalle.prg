define class Detalle as zoocoleccion OF zoocoleccion.prg

	#IF .f.
		Local this as Detalle of Detalle.prg
	#ENDIF

	datasession = 1

	oItem = null
	cAtributosUnicidad = ""
	lHabilitado = .T.
	lLimpiando = .f.
	lCargando = .f.
	nCantidadItems = 0
	oLogueo = null
	oInformacion = null
	lPermitirDetalleVacio = .T.
	nCantidadDeItemsCargados = 0
	oMensaje = null
	nTipoDeValidacionSegunDisenoImpresion = 0
	nLimiteSegunDisenoImpresion = 0
	cDisenoLimitador = ""
	cAtributosAgrupamiento = ""
	cAtributosAgrupamientoDefault = "NroItem"
	oColAgrupamientos = Null
	lCancelarCargaLimitePorDiseno = .F.
	lVerificarLimitesEnDisenoImpresion = .F.
	lHabilitaInsertarDetalle = .f.
	cCopiadorDeDetalle = "CopiadorDeDetalles"
	cNombreVisual = "Impuestos"
	cMensajeErrorUnicidad = "La columna Impuesto no admite valores repetidos."
	nCantidadItemsAdicionales = 0
	oItemAuxCotiza = null
	lEsNavegacion = .F.
	cContexto = ""
	oColCBAltYaLeidos = null
	oColCBAltYaLeidosConIDArt = null
	lCargoDatosDesdeTXT = .F.
	lControlaSecuencialEnCodBarAlt = .F.
	lReemplazarItemExistenteAlImportar = .f.
	
	*-----------------------------------------------------------------------------------------
	function oMensaje_Access() as Void
		if !this.ldestroy and ( !vartype( this.oMensaje ) = 'O' or isnull( this.oMensaje ) )
			this.oMensaje = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		endif
		
		return this.oMensaje
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function Init() as boolean
		return DoDefault() And ( This.Class # "Detalle" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEsNavegacion( tlvalor ) as Void
		&& Se vale de la propiedad lProcesando para saber si esta en momento de navegacion
		this.lEsNavegacion = !tlvalor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadItems() as Boolean
		local llRetorno as Booleano
		llRetorno = .t.
		if This.nCantidadItems + this.nCantidadItemsAdicionales > This.Count
		else
			llRetorno = .f.
			This.AgregarInformacion( "La cantidad de líneas supera a la permitida. Deberá realizar otro comprobante para completar la operación." , 9006 )
		EndIf
		return llRetorno

	endfunc	

	*-----------------------------------------------------------------------------------------
	function ValidarItemsSegunDisenoImpresion() as boolean		
		local llRetorno as Boolean
		llRetorno = .T.
		if this.nTipoDeValidacionSegunDisenoImpresion > 0 and this.oItem.ValidarExistenciaCamposFijos()
			llRetorno = this.ValidarCantidadesSegunDisenoImpresion()
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoAdvertirLimitePorDiseno( toInfoAuxiliar ) as Void
		&&Evento disparado desde el detalle para advertir que alcanzó el limite segun el diseño de impresión
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InformarCantidadSuperaDiseno( toItem as Object ) as Boolean
		local llRetorno as Boolean, lcMensaje as String
		llRetorno = .t.
		if this.nTipoDeValidacionSegunDisenoImpresion = 1
			lcMensaje = ""
			if vartype( toItem ) = 'O'
				lcMensaje = this.ObtenerClave( toItem )
				if at("-",lcMensaje,5) == 0
					lcMensaje = strtran(substr(lcMensaje,1,at("-",lcMensaje,2)-1),"-", " ")
				else
					lcMensaje = strtran(substr(lcMensaje,1,at("-",lcMensaje,5)-1),"-", " ")
				endif
				this.EventoGenerarInformeLimitePorDiseno( lcMensaje )
			else
				lcMensaje =  "Se superará el límite de " + alltrim( transform( this.nLimiteSegunDisenoImpresion ))+ " ítems establecido en el diseño de salida '"+ alltrim( this.cDisenoLimitador ) + "'."
				this.EventoAdvertirLimitePorDiseno( lcMensaje )   
			endif
		else
			if lower( this.cDisenoLimitador ) = 'facturafiscalhasar320f'
				This.AgregarInformacion( "La cantidad de líneas supera a la permitida. Deberá realizar otro comprobante para completar la operación.")
			else
				This.AgregarInformacion( "Se superó el límite de " + alltrim( transform( this.nLimiteSegunDisenoImpresion ))+ " ítems establecido en el diseño de salida '"+ alltrim( this.cDisenoLimitador ) + "'.")
			endif
			This.lCancelarCargaLimitePorDiseno = .F.
			this.EventoCancelarCargaLimitePorDiseno( this.cNombre )
			if This.lCancelarCargaLimitePorDiseno
				llRetorno = .F.
			Endif
		endif
		return llRetorno 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadesSegunDisenoImpresionDesdeEnBaseA() as Boolean
		local llRetorno as Boolean 
		llRetorno = .T.
		
		if this.nLimiteSegunDisenoImpresion > 0 and this.CantidadDeItemsCargados() >= this.nLimiteSegunDisenoImpresion
			llRetorno = this.InformarCantidadSuperaDiseno()
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidadesSegunDisenoImpresionDesdeEnBaseAConAgrupamientos( toItem as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		
		if this.nLimiteSegunDisenoImpresion > 0 and this.SuperaCantidadMaximaDeItemsAgrupadosAlCargar( toItem )
			llRetorno = this.InformarCantidadSuperaDiseno( toItem )
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidadesSegunDisenoImpresionDesdeColeccion( toColeccion as Object ) as Boolean
		local llRetorno as Boolean, lnCantidadCargados as Integer, lnLimite as Integer
		llRetorno = .T.
		
		lnCantidadCargados = this.nCantidadDeItemsCargados
		lnLimite = this.nLimiteSegunDisenoImpresion 
		
		if lnCantidadCargados + toColeccion.Count > lnLimite
			llRetorno = this.InformarCantidadSuperaDiseno()
		endif
		return llRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCantidadesSegunDisenoImpresion() as Boolean
		local llRetorno as Boolean, lnCantidadCargados as Integer, lnLimite as Integer, lcCamposConsulta as String
		llRetorno = .T.
		lnCantidadCargados = this.nCantidadDeItemsCargados
		lnLimite = this.nLimiteSegunDisenoImpresion 
		
		if lnCantidadCargados > lnLimite
			llRetorno = this.InformarCantidadSuperaDiseno()
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoGenerarInformeLimitePorDiseno( tcMensaje as String ) as Void
		***Para que se bindeen
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCancelarCargaLimitePorDiseno( tcDetalle ) as Void
		***Para que se bindeen
	endfunc 

	*-----------------------------------------------------------------------------------------
	*** limpia la coleccion y el item activo
	function Limpiar() as Void
		with this
			.remove( -1 )
			.oColAgrupamientos = Null
			.oItem.Limpiar()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	*** Cargar la coleccion con los datos de las tablas
	function Cargar() as Void
		*** Este método se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarItem( tnItem as Integer ) as Void
		This._CargarItem( tnItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	*** carga el iten activo con los datos de la coleccion
	protected function _CargarItem( tnItem as Integer ) as Void
		*** Este método se genera
	endfunc 

	*-----------------------------------------------------------------------------------------		
	*** decide si el item activo se agrega o modifica un item ya agregado
	function Actualizar( tcClave as String ) as Void
		local llAgregado as Boolean, loError as Exception, llCargandoAnt as Boolean, loItem as Object, llAgregarItemAColeccionAgrupada as Boolean
		llAgregarItemAColeccionAgrupada = .T.
		with this
			if .oItem.NroItem = 0
				if this.oItem.ValidarExistenciaCamposFijos()
					This.BuscarEnDetalle()
				endif
				.Agregar( tcClave )
				llAgregado = .t.
			else
				if empty( evaluate( "this.oItem." + this.oItem.cAtributoPK ) ) and this.oItem.ValidarExistenciaCamposFijos()
					This.BuscarEnDetalle()
				endif
				
				loItem = This.ObtenerCopiaItemPlanoParaColeccion( This.Item[ this.oItem.NroItem ] )
				llAgregarItemAColeccionAgrupada = .oItem.ValidarExistenciaCamposFijos()
				.EventoAntesDeModificarItem()			
				.Modificar()
				.EventoDespuesDeModificarItem()
				This.EliminarItemAColeccionAgrupada( loItem )
				if llAgregarItemAColeccionAgrupada
					This.AgregarItemAColeccionAgrupada( This.Item[ this.oItem.NroItem ] )
				Endif
				llAgregado = .f.
			endif
			
			if llAgregado
				try
					llCargandoAnt = .lCargando
					.lCargando = .t.
					.oItem.NroItem = .Count
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.lCargando = llCargandoAnt
				endtry
			endif
		endwith
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	protected function Modificar() As void
		*** esta funcion se genera
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	protected function Agregar( tcClave as String ) As void
		local loItem as Object, llAgregarAColeccionAgrupada As Boolean
		llAgregarAColeccionAgrupada = .T.
		with this
			if .ValidarItem() and .ValidarCantidadItems() 
				if .oItem.ValidarExistenciaCamposFijos()
				else
					llAgregarAColeccionAgrupada = .F.
					.oItem.Limpiar( .t. )
				endif
				loItem = .AplanarItem()
				this.AgregarItemAlDetalle( loItem, tcClave )
				.EventoSeAgregounItem()
				if llAgregarAColeccionAgrupada
					This.AgregarItemAColeccionAgrupada( loItem )
				Endif	
			else
				goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarItemAlDetalle( toItem as Object, tcClave as String ) as Void
		if empty( tcClave )
			this.add( toItem )
		else
			this.add( toItem, tcClave )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClaveParaDetalle( toItem as Object ) as String
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function EstaLimpiando() As Boolean
		Return This.lLimpiando
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EstaCargando() As Boolean
		Return This.lCargando
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarItem() as object
		this.oItem.Limpiar()
		*** Este método se sobrecarga por el usuario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	*** agrega a la coleccion lo que esta en el item activo
	protected function AplanarItem() as object
		*** Este método se genera
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	*** Se ejecuto cuando el item dispara el mensaje de CambioSumarizado
	function CambiosItem() as object
		this.CambioSumarizado()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CambioSumarizado() as Void
		*** mensaje... aca no se escribe codigo!!!!!!!!!!!!!!!!!!!!!!!!!!
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Sumarizar() as boolean
		*** Este método se genera
	endfunc

	*-----------------------------------------------------------------------------------------
	function habilitarItems( tlHabilitar as Boolean ) as void
		this.lHabilitado = tlHabilitar 
		this.oItem.Habilitar( tlHabilitar )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarItem() as Boolean
		local llRetorno
		llRetorno = dodefault()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.

		with this
			llRetorno = .ValidarFormatoAtributos()
			if llRetorno
				llRetorno = .ValidarUnicidadDetalle()
				if llRetorno
				else
					.AgregarInformacion( "Problemas de unicidad" + evl( " en el detalle " + this.cNombreVisual + ".", "." ) )
				endif
			endif
		endwith 
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidacionDetalleObligatorio() as Boolean
		local llRetorno as Boolean 
		
		llRetorno = .t.
		
		if This.lPermitirDetalleVacio
		Else
			llRetorno = ( This.CantidadDeItemsCargados() > 0 )
		endif 

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneAlMenosUnItemValido( ) as Boolean
		local lnI as Integer, lnItems as Integer, llRetorno as Boolean
		lnI = 0
		for lnI = 1 to this.Count
			if this.ValidarExistenciaCamposFijosItemPlano( lnI )
				llRetorno = .t.
				exit
			endif
		endfor

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CantidadDeItemsCargados() as integer
		local lnI as Integer, lnItems as Integer, lnAgregar as Integer, llChequeoAplanadoConNroItemDelActivo as Boolean
		* Aca llega si el detalle no tiene Agrupamientos en el diseño, sólo chequea por cantidad de items
		if this.lCargando
			lnItems = this.Count
		else
			lnI = 0
			lnItems = 0
			lnAgregar = 0
			for lnI = 1 to this.Count
				if this.oItem.NroItem = this.Item[ lnI ].NroItem
					with this.oItem
						if .lEdicion or .lNuevo or .lCargando or .lLimpiando
							if .ValidarExistenciaCamposFijos()
								lnItems = lnItems + 1
							endif
						else
							if this.ValidarExistenciaCamposFijosItemPlano( lnI )
								lnItems = lnItems + 1
							endif
						endif
					endwith
				else
					if this.ValidarExistenciaCamposFijosItemPlano( lnI )
						lnItems = lnItems + 1
					endif
				endif
			endfor

			if this.oItem.NroItem = 0
				with this.oItem
					if .lEdicion or .lNuevo or .lCargando or .lLimpiando
						if .ValidarExistenciaCamposFijos()
							lnAgregar = 1
						endif
					endif
				endwith
			endif
		endif
		lnItems = lnItems + lnAgregar
		return lnItems
	endfunc

	*-----------------------------------------------------------------------------------------
	function CantidadDeTipoDeValoresCargados() as Integer
		local lnI as Integer, lnItems as Integer, lnCantidad as Integer, llEncontre as Integer, lnPosicion as Integer, lnJ as Integer
		local laTipoValores as array

		llEncontre = .F.
		lnCantidad = this.Count
		lnPosicion = 1
		
		if lnCantidad != 0
			dimension laTipoValores[lnCantidad]				
			lnI = 0
			lnJ = 0
			lnItems = 0		
			laTipoValores = 0

			for lnI = 1 to lnCantidad 
			
				if this.ValidarExistenciaCamposFijosItemPlano( lnI )
					llEncontre = .F.
					for lnJ = 1 to lnCantidad
						if this.item[ lnI].tipo = laTipoValores[lnJ] 
							llEncontre = .T.
							exit
						endif
					endfor
					
					if !llEncontre
						laTipoValores[lnPosicion] = this.item[ lnI ].tipo
						lnPosicion = lnPosicion + 1
					endif		

				endif
			endfor
		endif	

		return ( lnPosicion - 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarFormatoAtributos() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadDetalle() as Boolean
		local llRetorno as Boolean, i As Integer, llHayIguales As Boolean, j As Integer, lcCombinacionesRepetidas as String,;
			  lcEnter as String
		llRetorno = .T.
		lcAtributoRepetido = ""
		lcCombinacionesRepetidas = ""
		lcEnter = chr(13) + chr(10)

		if !empty( This.cAtributosUnicidad )
			for i = 1 to This.Count - 1
				For j = i + 1 To This.Count
					lcAtributoRepetido = This.CompararItemConItem( This.Item( i ), This.Item( j ) )
					if !empty( lcAtributoRepetido )
						llRetorno = .F.
						if this.cContexto = "I"
							lcCombinacionesRepetidas = lcCombinacionesRepetidas +  lcAtributoRepetido + "- Linea: " + transform( i )
							lcCombinacionesRepetidas = lcCombinacionesRepetidas + " con la Linea: " + transform( j ) + lcEnter
						else
							j = this.Count
							i = j
						endif
					EndIf	
				endfor
			EndFor
		EndIf
		if !empty( lcCombinacionesRepetidas )
			this.AgregarInformacion( this.cMensajeErrorUnicidad + lcEnter + "Las lineas con atributos repetidos son las siguientes: " + lcEnter + lcCombinacionesRepetidas ) 
		else
			if !llRetorno
				this.AgregarInformacion( this.cMensajeErrorUnicidad )
			endif
		Endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompararItemConItem( toItem1 As Collection, toItem2 As Collection ) as String
		local	lcAtributoUnicidad As String, i as Integer, llRetorno as Boolean, llTodosVacios As Boolean, lcCombinacionesRepetidas as String
		lcCombinacionesRepetidas = ""
		llAtributoRepetido = .T.
		llTodosVacios = .T.

		for i = 1 to getwordcount( This.cAtributosUnicidad, "," )
			lcAtributoUnicidad = getwordnum( This.cAtributosUnicidad, i , "," )
			
			if type( "toItem1.&lcAtributoUnicidad" ) = "C"
				llAtributoRepetido  = ( rtrim( toItem1.&lcAtributoUnicidad ) == rtrim( toItem2.&lcAtributoUnicidad ) )
				lcCombinacionesRepetidas = lcCombinacionesRepetidas +  transform( rtrim( toItem1.&lcAtributoUnicidad ) )
			else
				llAtributoRepetido  = ( toItem1.&lcAtributoUnicidad == toItem2.&lcAtributoUnicidad )
				lcCombinacionesRepetidas = lcCombinacionesRepetidas + transform( toItem1.&lcAtributoUnicidad )
			endif
			
			llTodosVacios = llTodosVacios .And. Empty( toItem1.&lcAtributoUnicidad ) .And. Empty( toItem2.&lcAtributoUnicidad )
			
			if !llAtributoRepetido 
				lcCombinacionesRepetidas = ""
				i = getwordcount( This.cAtributosUnicidad, "," )
			EndIf	
		endfor
		if llTodosVacios
			lcCombinacionesRepetidas = ""
		EndIf
		return lcCombinacionesRepetidas + " "
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargaManual() as Boolean
		return !this.lLimpiando and !this.lCargando and !this.lDestroy
	endfunc

	*-----------------------------------------------------------------------------------------
	function setearLogueo( toLogueo as Object ) as Void
		this.oLogueo = toLogueo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function inyectarLogueo( toQuienLlama as Object ) as Void
		this.EventoObtenerLogueo( this )
		toQuienLlama.setearLogueo( this.oLogueo )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function eventoObtenerLogueo( toYoMismo as Object ) as Void
		****Si hay algun otro zooSession escuchando le va a inyectar un objeto logueo
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function oInformacion_Access() as variant
		with this
			if !.ldestroy and !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
				this.eventoObtenerInformacion( this )
				if !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
					*** 03/06/2010 mrusso: Se sacó _screen.zoo.crearobjeto ya que si el ZOO da error
					.oInformacion = newobject( "ZooInformacion", "ZooInformacion.prg" )
				endif	
			endif
		endwith
		return this.oInformacion
	endfunc

	*----------------------------------------------------------------------------------------- REPETISO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function setearInformacion( toInformacion as Object ) as Void
		this.oInformacion = toInformacion
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function inyectarInformacion( toQuienLlama as Object ) as Void
		this.EventoObtenerInformacion( this )
		toQuienLlama.setearInformacion( this.oInformacion )
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function eventoObtenerInformacion( toYoMismo as Object ) as Void
		****Si hay algun otro zooSession escuchando le va a inyectar un objeto logueo
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function AgregarInformacion( tcInformacion as String, tnNumero as Integer, txInfoExtra as Variant ) as Void
		do case
		case pcount() = 1
				this.oInformacion.AgregarInformacion( tcInformacion )
		case pcount() = 2
				this.oInformacion.AgregarInformacion( tcInformacion, tnNumero )
		case pcount() = 3
			this.oInformacion.AgregarInformacion( tcInformacion, tnNumero, txInfoExtra )
		otherwise
			assert pcount() = 0 message "Llamaron al AgregarInformacion del zooSession con parametros incorrectos"
		endcase
	endfunc 	

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function ObtenerInformacion() as zooInformacion of zooInformacion.prg
		return this.oInformacion
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	function LimpiarInformacion() as Void
		this.oInformacion.Limpiar()
	endfunc 

	*----------------------------------------------------------------------------------------- REPETIDO EN ZOOSESSION
	***METODO COPIADO DE ZOOSESSION PORQUE DETALLE NO HEREDA DE EL. MANTENER SIEMPRE IGUAL QUE EN ZOOSESSION
	function LevantarExcepcionTexto( tcTexto as String, tnNumeroError as Integer ) as zooexception OF zooexception.prg
		local loex as exception

		loex = newobject(  "zooexception", "zooexception.prg" )
		with loex
			.message = tcTexto
			.details = .message
			.lEsValidacion = .T.
			
			if empty( tnNumeroError )
			else
				.nZooErrorNo = tnNumeroError
			endif
			.throw()
			
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarItemPlano( toItem as Object ) as Void
		with this
			if .ValidarCantidadItems() 
				.add( toItem  )
			else
				goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function nCantidadDeItemsCargados_Access() as Number
		local lnRetorno as Integer
		
		lnRetorno = 0
		if !this.lDestroy
			if This.cAtributosAgrupamiento != This.cAtributosAgrupamientoDefault
				lnRetorno = this.CantidadDeItemsAgrupadosCargados()
			else
				lnRetorno = this.CantidadDeItemsCargados()
			endif
		endif
		
		return lnRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function cAtributosAgrupamiento_Assign( tcVal AS String ) as Void
		if This.cAtributosAgrupamiento == tcVal
		else
			This.cAtributosAgrupamiento = iif( empty( tcVal ), "NroItem", tcVal )
			This.RegenerarColeccionAgrupamientos()
		EndIf
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RegenerarColeccionAgrupamientos() as Void
		local lnI as Integer
		with this
			.oColAgrupamientos = Null
			for lnI = 1 to .Count
				if .ValidarExistenciaCamposFijosItemPlano( lnI )
					.AgregarItemAColeccionAgrupada( .Item[lnI] )
				endif
			endfor
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cAtributosAgrupamiento_Access() as String
		local lcRetorno as String
		
		if empty( This.cAtributosAgrupamiento )
			lcRetorno = "NroItem"
		else
			lcRetorno = This.cAtributosAgrupamiento
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColAgrupamientos_Access() as Void
		if !this.ldestroy and ( !vartype( this.oColAgrupamientos ) = 'O' or isnull( this.oColAgrupamientos ) )
			this.oColAgrupamientos = _screen.zoo.crearobjeto( "ZooColeccion" )
		endif
		return this.oColAgrupamientos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarClave( tcClave As String ) as Void
		This.oColAgrupamientos.Agregar( newobject( "itemAgrupamiento" ), tcClave )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClave( toItem as Object ) as String
		local lnI as Integer, lnCant as Integer, lcAtributo as String, lcClave as String, lcContenido as String
		
		lnCant = getwordcount( This.cAtributosAgrupamiento, "," )
		lcClave = ""
		lcContenido = ""
		
		for lnI = 1 to lnCant
			lcAtributo = getwordnum( This.cAtributosAgrupamiento, lnI, ","  )
			lcContenido = this.ObtenerContenidoDelAtributo( toItem, lcAtributo )
			lcClave = lcClave + "-" + lcContenido
		endfor
		
		return lcClave
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerContenidoDelAtributo( toItem as Object, tcAtributo as String ) as String
		local lcRetorno as String, loItemDestino as Object, lcAtributo as String
		
		if getwordcount( tcAtributo, "." ) > 1
			this.ObtenerItemYAtributoParaAgrupamiento( @toItem, @tcAtributo )
		endif
		
		if pemstatus( toItem, tcAtributo, 5 )
			lcRetorno = alltrim( goServicios.Librerias.ConvertirAString( toItem.&tcAtributo ) )
		else
			*Lo uso para saber el tipo de dato
			loItemDestino = this.CrearItemAuxiliar()
			do case
				case vartype( loItemDestino.&tcAtributo ) = 'C'
					lcRetorno = ""
				case vartype( loItemDestino.&tcAtributo ) = 'N'
					lcRetorno = goServicios.Librerias.ConvertirAString( 0 )
				case inlist( vartype( loItemDestino.&tcAtributo ), "D", "T" )
					lcRetorno = ""
				otherwise
					lcRetorno = ""
			endcase
			loItemDestino = null
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemYAtributoParaAgrupamiento( toItem as Object, tcAtributo as String ) as String
		local lcRetorno as String, lnCant as Integer
		
		lnCant = getwordcount( tcAtributo, "." )
		
		for lnI = 1 to lnCant - 1
			lcAtributoAux = getwordnum( tcAtributo, lnI, "."  )
			if pemstatus( toItem, lcAtributoAux, 5 )
				toItem = toItem.&lcAtributoAux
			endif
		endfor
		
		tcAtributo = getwordnum( tcAtributo, lnCant, "."  )
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function AgregarItemPlanoAColeccionAgrupada( toItem as Object ) as Void
		this.AgregarItemAColeccionAgrupada( toItem )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarItemAColeccionAgrupada( toItem as Object ) as Void
		local lcClave as String, lcAtributo as String
		* Es para evitar poblar una coleccion que la mayoria de las veces no se utiliza
		if empty(This.cAtributosAgrupamiento) or (upper(This.cAtributosAgrupamientoDefault) == upper(This.cAtributosAgrupamiento))
		else
			lcClave = This.ObtenerClave( toItem )
			if This.oColAgrupamientos.Buscar( lcClave )
				This.oColAgrupamientos.Item( lcClave).Cantidad = This.oColAgrupamientos.Item( lcClave ).Cantidad + 1
			else
				This.AgregarClave( lcClave )
			Endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EliminarItemPlanoAColeccionAgrupada( toItem as Object ) as Void
		this.EliminarItemAColeccionAgrupada( toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarItemAColeccionAgrupada( toItem as Object ) as Void
		local lcClave as String
		lcClave = This.ObtenerClave( toItem )
		if This.oColAgrupamientos.Buscar( lcClave )
			if This.oColAgrupamientos.Item( lcClave).Cantidad > 1
				This.oColAgrupamientos.Item( lcClave).Cantidad = This.oColAgrupamientos.Item( lcClave ).Cantidad - 1
			else
				This.oColAgrupamientos.Quitar( lcClave )
			Endif
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCopiaItemPlanoParaColeccion( toItem as Object ) as Object
		local loItem as Object, lnI as Integer, lnCant as Integer, lcAtributo as String 
		loItem = This.CrearItemAuxiliar()
		lnCant = getwordcount( This.cAtributosAgrupamiento, "," )
		for lnI = 1 to lnCant
			lcAtributo = getwordnum( This.cAtributosAgrupamiento, lnI, ","  )
			loItem.&lcAtributo = toItem.&lcAtributo
		endfor
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CantidadDeItemsAgrupadosCargados() as integer
		local lnItems as Integer, lcClaveItemActivo as String, lcClaveItemPlano as String, llAgregar as Boolean, llSacar as Boolean
		store .F. to llAgregar, llSacar
		
		lcClaveItemActivo = This.ObtenerClave( This.oItem )
		if This.oColAgrupamientos.Buscar( lcClaveItemActivo )
		else
			llAgregar = This.oItem.ValidarExistenciaCamposFijos()
		endif
		If This.oItem.NroItem = 0
		else
			if this.count > 0 and this.count >= This.oItem.NroItem
				lcClaveItemPlano = This.ObtenerClave( This.Item[ This.oItem.NroItem ] )
				if lcClaveItemPlano == lcClaveItemActivo
				else
					if This.oColAgrupamientos.Buscar( lcClaveItemPlano ) and This.oColAgrupamientos.Item( lcClaveItemPlano ).Cantidad = 1
						llSacar = .T.
					Endif
				endif
			endif
		endif
		lnItems = This.oColAgrupamientos.Count + iif( llAgregar, 1, 0 )	- iif( llSacar, 1, 0 )
		
		return lnItems
	endfunc

	*-----------------------------------------------------------------------------------------
	function SuperaCantidadMaximaDeItemsAgrupadosAlCargar( toItem as Object ) as boolean
		local lcClaveItemPlano as String, llRetorno as Boolean
		
		llRetorno = .t.
		
		if this.lCargando
			llRetorno = .f.
		else
			lcClaveItemPlano = This.ObtenerClave( toItem )
			if This.oColAgrupamientos.Buscar( lcClaveItemPlano )
				llRetorno = .f.
			else
				if This.oColAgrupamientos.Count < this.nLimiteSegunDisenoImpresion
					This.AgregarItemAColeccionAgrupada( toItem )
					llRetorno = .f.
				else
					llRetorno = .t.
				endif
			endif
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeAgregounItem() as Void
		*- Evento para que se bindeen
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeInsertarDetalle() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemActual( tnIndice as Number ) as Object
		local lni as Integer , lnItem as Integer, loItem as Object
		
		if vartype( this.oItem ) = "O" 
			lnItem = this.oItem.NroItem
			if tnIndice = lnItem
				loItem = this.oItem
			else
				loItem = this.Item( tnIndice )
			endif
		else
			loItem = this.Item( tnIndice )
		endif
	
		return loItem
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidadDeItemsEnDetalle( toItem as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		local lnCant as Integer, lnI as Integer, lcAtributo as String, lcClave as String, lcAtributosAgrupamiento as String,;
		lcCampoInicialObligatorioDelDetalle as String
		if occurs( ",", this.cAtributosAgrupamiento ) >= 1 && Tiene agrupamiento por mas de un campo, valida al actualizar()
		else
			lcCampoInicialObligatorioDelDetalle = This.ObtenerCampoInicialYOBligatorioDelDetalle()
			if upper( lcCampoInicialObligatorioDelDetalle ) = upper( tcAtributo ) and this.oItem.ValidarExistenciaCamposFijos() and ;
				!empty( txVal ) and empty( evaluate( "this.oItem." + this.oItem.cAtributoPK ) )
				This.BuscarEnDetalle()
			endif
		endif
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function BuscarEnDetalle() as Void
		if this.nTipoDeValidacionSegunDisenoImpresion > 0
			if this.ValidarCantidadesSegunDisenoImpresion()
			else
				goServicios.Errores.LevantarExcepcion( this.ObtenerInformacion() )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarInsertarCondicionDePagoEnDetalle( toColeccion as Object ) as Void

		if this.nTipoDeValidacionSegunDisenoImpresion > 0
			if this.ValidarCantidadesSegunDisenoImpresionDesdeColeccion( toColeccion )
			else
				goServicios.Errores.LevantarExcepcion( "No es posible aplicar la condicion de pago ingresada, ya que con esta se superará el límite de " + alltrim( transform( this.nLimiteSegunDisenoImpresion ))+ " ítems establecido en el diseño de salida '"+ alltrim( this.cDisenoLimitador ) + "'." )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCampoInicialYOBligatorioDelDetalle() as string
		return ""
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerItemAuxiliarCotizacion() as Void
		local loRetorno as object
		loRetorno = _screen.zoo.crearObjeto( "ItemAuxCotiza" )
		with loRetorno 
			if alltrim( this.oItem.Valor.SimboloMonetario_PK ) = this.cMonedaSistema
				.Moneda = this.cMonedaComprobante
			else 
				.Moneda = this.oItem.Valor.SimboloMonetario_PK
			endif
			.FechaUltimaCotizacion = this.oItem.FechaUltCotizacion
			.FechaNuevaCotizacion = this.oItem.Fecha
			.MontoUltimaCotizacion = this.oItem.UltimaCotizacion
			.MontoNuevaCotizacion = this.oItem.UltimaCotizacion			
		endwith
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeModificarItem() as Void
		&&Hola soy un evento para bindearme, no me escribas codigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeModificarItem() as Void
		&&Hola soy un evento para bindearme, no me escribas codigo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTipoDeItemAlCopiar( toItem as Object ) as Void
		local llRetorno as Boolean
		llRetorno = .t.
		if llRetorno and pemstatus( toItem, "Comportamiento", 5 ) and toItem.Comportamiento = 4
			llRetorno = .f.
		endif
		return llRetorno
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Totalizar( toItem as Object ) as Void
		*** Este método se genera
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Acumular( tlForzar as Boolean, tcAtributo as String, tnValor as Decimal, tnValorAnt as Decimal ) as Void
		*** Este método se genera
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oColCBAltYaLeidos_access() as object
		if !this.lDestroy and (type("this.oColCBAltYaLeidos") <> "O" or isnull(this.oColCBAltYaLeidos))
			this.oColCBAltYaLeidos = _screen.zoo.CrearObjeto( "ZooColeccion", "zooColeccion.prg" )
		endif
		return this.oColCBAltYaLeidos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oColCBAltYaLeidosConIDArt_access() as object
		if !this.lDestroy and (type("this.oColCBAltYaLeidosConIDArt") <> "O" or isnull( this.oColCBAltYaLeidosConIDArt ))
			this.oColCBAltYaLeidosConIDArt = _screen.zoo.CrearObjeto( "ZooColeccion", "zooColeccion.prg" )
		endif
		return this.oColCBAltYaLeidosConIDArt
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarDetalleCodBarAlt() as Void
		this.oColCBAltYaLeidos = null
		this.oColCBAltYaLeidosConIDArt = null
		this.lCargoDatosDesdeTXT = .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AnularItemAnteriorEnDetalle() as Void
		** Si es necesario que en la importación los items existentes en detalle se reemplacen por los nuevos, 
		** sobreescribir este método en el detalle que corresponda. Esto se ejecutará inmediatamente antes de
		** que se importe cada item.
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class ItemAgrupamiento as Custom
	Cantidad = 1
enddefine
