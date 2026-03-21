Define Class zooColeccion As Collection

	#IF .f.
		Local this as zooColeccion of zooColeccion.prg
	#ENDIF

	nSiguienteElemento = 1
	lDestroy = .f.
		
	*-----------------------------------------------------------------------------------------
	Function Agregar ( teItem As Variant, tcClave As String, teAntes As Variant, teDespues As Variant ) As boolean
		Local llRetorno As Logical
		Store .F. To llRetorno
		
		Do Case
			Case Empty(tcClave) And Empty(teAntes) And Empty(teDespues)
				llRetorno = This.Add( teItem )
			Case Empty(teAntes) And Empty(teDespues)
				llRetorno = This.Add( teItem, tcClave )
			Case Empty(teDespues)
				llRetorno = This.Add( teItem, tcClave, teAntes )
			Otherwise
				llRetorno = This.Add( teItem, tcClave, teAntes, teDespues )
		endcase

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarRango( toColeccion as zoocoleccion OF zoocoleccion.prg ) as Void
		local lnItem as integer, loItem as Variant, lcClave as String
		
		for lnItem = 1 to toColeccion.Count
			loItem = toColeccion.item[lnItem]
			
			lcClave = toColeccion.GetKey( lnItem )
			if empty( lcClave )
			*No tengo claves
				this.Agregar( loItem )
			else
				this.Agregar( loItem, lcClave )
			endif		
		endfor
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Quitar( teItem As Variant ) As void
		This.Remove( teItem )
		if this.Count = 0 
			this.EventoSeVacioLaColeccion()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSeVacioLaColeccion() as Void
		&& Indica cuando quedó la colección sin elementos solo cuando el útimo de
		&& sus elementos se eliminó mediante el método Quitar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Release() As void
		Release This
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Destroy()
		Local lnCantidad As Integer, laPropiedades As Array,;
			lnPropiedadActual As Integer, lcPropiedad As String, lcEliminaReferencia As String
		local array laPropiedades(1)
		lnCantidad = Amembers(laPropiedades,This,0,"U" )

		this.lDestroy = .t.

		For lnPropiedadActual = 1 To lnCantidad
			lcPropiedad = "this."+ Alltrim(laPropiedades(lnPropiedadActual))
			If Vartype( Evaluate(lcPropiedad) ) = "O"
				If Pemstatus(&lcPropiedad,"release",5)
					lcEliminaReferencia = lcPropiedad + ".release"
					&lcEliminaReferencia
				Else
					lcEliminaReferencia = lcPropiedad + " = null"
					&lcEliminaReferencia
				Endif
			Endif
		Endfor

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Buscar( tcClave As String ) As boolean
		Local leItem As Variant, llRetorno As boolean

		llRetorno = .T.
		Try
			leItem = This.Item( tcClave )
		Catch
			&& Si no encuentra el item
			llRetorno = .F.
		Endtry

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSiguiente( tlPrimero as Boolean ) as Variant
		local lxRetorno as variant 
		
		if this.Count = 0 
			lxRetorno = null
		else 
			if tlPrimero
				this.nSiguienteElemento = 1 
			endif 
			try
				lxRetorno = this.Item( this.nSiguienteElemento )
				this.nSiguienteElemento = this.nSiguienteElemento + 1 
			catch 
				&& La coleccion no tiene el elemento deseado
				lxRetorno = null
			endtry
			
		endif 
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Enlazar( tcDelegando as String , tcDelegado As String ) as Void
		local lnPunto as Integer, lcObjeto as String, lcEvento As String, lcDelegando As String
	
		lcDelegando = tcDelegando
		if substr( lcDelegando, 1, 1 ) = "."
			lcDelegando = substr( lcDelegando, 2 )
		else

		Endif
		lnPunto  = at( ".", lcDelegando )
		
		if lnPunto = 0
			lcObjeto = "this"
		else
			lcObjeto = "this." + substr( lcDelegando, 1, lnPunto - 1 )
		endif
		lcEvento = substr( lcDelegando, lnPunto + 1 )
		bindevent( &lcObjeto, lcEvento, this, tcDelegado, 1 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	* El método Filtrar devuelve un subconjunto de ítems filtrados.
	* La expresion de filtrado debe hacer referencia al item con la cadena #ITEM de tal forma
	* que si queremos filtrar los items que tengan la propiedad Nombre igual a "PEDRO" y la
	* propiedad Edad mayor a 21 la expresion de filtrado será:
	* 				'UPPER( ALLTRIM ( #ITEM.Nombre ) ) == "PEDRO" and #ITEM.Edad > 21'
	* Si la coleccion contiene solo strings y queremos obtener los que contienen la palabra
	* "CAJA" dentro de si misma la expresion de filtrado será:
	* 				'"CAJA" $ UPPER( ALLTRIM ( "#ITEM" ) )'
	* Si la coleccion es una lista de numeros y queremos obtener los items entre 6 y 9 la
	* expresion de filtrado será:
	* 				'between( #ITEM, 6, 9 )'
	function Filtrar( tcExpresionDeFiltrado as String ) as zoocoleccion OF zoocoleccion.prg
		local loSubconjunto as zoocoleccion OF zoocoleccion.prg, lxItem as Variant,;
			  lnIndice as Integer, lxClave as Variant
		
		loSubconjunto = _screen.zoo.crearobjeto( 'zooColeccion' )
		
		lnIndice = 0
		for each lxItem in this foxobject
			lnIndice = lnIndice + 1 
			lxClave = this.GetKey( lnIndice )
			
			if this.ElItemCumpleConLaExpresionDeFiltro( lxItem, tcExpresionDeFiltrado )
				if empty( lxClave )
					loSubconjunto.Add( lxItem )
				else
					loSubconjunto.Add( lxItem, lxClave )
				endif
			endif
		endfor 
		
		return loSubconjunto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ElItemCumpleConLaExpresionDeFiltro( txItem as Variant, tcExpresionDeFiltrado as String ) as Boolean
		local llCumpleConElFiltro as Boolean, lcExpresionActual as String
		
		if vartype( txItem ) == "O"
			lcExpresionActual = strtran( tcExpresionDeFiltrado, "#ITEM", "txItem" )
		else
			lcExpresionActual = strtran( tcExpresionDeFiltrado, "#ITEM", transform( txItem ) )
		endif
		
		Try
			llCumpleConElFiltro = &lcExpresionActual
		Catch
			llCumpleConElFiltro = .f.
		EndTry

		return llCumpleConElFiltro 
	endfunc 

Enddefine
