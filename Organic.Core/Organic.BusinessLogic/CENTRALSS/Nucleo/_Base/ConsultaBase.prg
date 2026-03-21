define class ConsultaBase as zooSession of zooSession.prg

	#if .f.
		local this as ConsultaBase of ConsultaBase.prg
	#endif

	oMemos = null
		
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.oMemos = this.crearobjeto( "Memos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Obtener( toObjTrans as object ) as String
		this.AbrirEstructura( toObjTrans )
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirEstructura( toObjTrans as Object ) as Void

		if type( "toObjTrans.cEstructuraDeDatos" ) = "C"
			This.AbrirEstructuraExportacion( toObjTrans )
		else 
			This.AbrirEstructuraTransferencia( toObjTrans )	 
		endif 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirEstructuraExportacion( toObjTrans as Object ) as Void
		local loXMLAdapter as Object, lcCursor as string, lcRetorno  as string
		
		loXMLAdapter = CREATEOBJECT("xmladapter")
		loXMLAdapter.LoadXML( toObjTrans.cEstructuraDeDatos )
		loXMLAdapter.Tables.Item( 1 ).ToCursor()
		loXMLAdapter.destroy()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirEstructuraTransferencia( toObjTrans as Object ) as Void
		local loXMLAdapter as Object, lcCursor as string, lcRetorno  as string
		
		if type( "toObjTrans.oSetDatos[ 1 ]" ) = "C"
			loXMLAdapter = CREATEOBJECT("xmladapter")
			loXMLAdapter.LoadXML( toObjTrans.oSetDatos[ 1 ] )
			loXMLAdapter.Tables.Item( 1 ).ToCursor()
			loXMLAdapter.destroy()
		endif
	endfunc 


	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		use in select( "c_Estructura" )
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerWhere( tcEntidad as string, toObjTrans as object ) as string
		local lcRetorno as string, loItem as object, lcFiltro as string, i as Integer, lcCondicion as String 

		lcRetorno = ''
		if type( 'toObjTrans' ) = 'O'
			with this
				for i = 1 to toObjTrans.oFiltros.count
					loItem = toObjTrans.oFiltros.item[ i ]

					if alltrim( upper( loItem.cEntidad ) ) == alltrim( upper( tcEntidad ) )
						
						lcCondicion = alltrim( this.ObtenerCondicion( toObjTrans, i ) )
						
						if !empty( lcCondicion )
							lcRetorno = lcRetorno + ' and ' + lcCondicion
						endif
					endif
				endfor
			endwith
		endif
		lcRetorno = substr( lcRetorno, 6 )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerCondicion( toObjTrans as object, tnItemFiltro as integer ) as string
		local lcRetorno as string, loItem as object
		
		lcRetorno = ""
		loItem = toObjTrans.oFiltros.item[ tnItemFiltro  ]
		
		with this
			do case
				case upper( alltrim( loItem.Dominio ) ) == "DESDEHASTA"
					lcRetorno = .ObtenerDesdeHasta( toObjTrans, tnItemFiltro )
			endcase
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDesdeHasta( toObjTrans as object, tnItemFiltro as integer ) as string
			
		local lcRetorno as string, lcWhereAux1 as string, lcWhereAux2 as string, loItemCampo as object, ;
			lxValor1 as Variant, lxValor2 as Variant, lcCampo as string, loItemFiltro as object, ;
			lcFormatoValorInicio as String, lcFormatoValorFin as String 	

		lcWhereAux1 = ""
		lcWhereAux2 = ""
		lcRetorno = ""
		lcFormatoValorInicio = ""
		lcFormatoValorFin = ""
		loItemFiltro = toObjTrans.oFiltros.item[ tnItemFiltro  ]
		loItemCampo = this.ObtenerRegistroRelacionado( loItemFiltro.cEntidad, loItemFiltro.cAtributo )

		lcCampo = alltrim( loItemCampo.Tabla ) + "." + alltrim( loItemCampo.Campo )
		
		lxValor1 = this.TransformarValorSegunTipoDeDato( loItemFiltro.Valor1, loItemCampo.TipoDato )
		lxValor2 = this.TransformarValorSegunTipoDeDato( loItemFiltro.Valor2, loItemCampo.TipoDato )
		if loItemCampo.tipoDato = "C"
		
			lcFormatoValorInicio = this.ObtenerFormatoInicioParaCamposString()
			lcFormatoValorFin = this.ObtenerFormatoFinParaCamposString()
		
			lcCampo = lcFormatoValorInicio + lcCampo + lcFormatoValorFin

		endif

		with this

			if !isnull( lxValor1 ) and !isnull( lxValor2 ) and lxValor1 == lxValor2
				lcWhereAux1 = lcCampo + " == " + lcFormatoValorInicio + this.ValorAString( lxValor1 ) + lcFormatoValorFin
			else
				if !isnull( lxValor1 )
					lcWhereAux1 = lcCampo + " >= " + lcFormatoValorInicio + this.ValorAString( lxValor1 ) + lcFormatoValorFin
				endif
				if !isnull( lxValor2 )
					lcWhereAux2 = lcCampo + " <= " + lcFormatoValorInicio + this.ValorAString( lxValor2 ) + lcFormatoValorFin
				endif
			endif
			
			lcRetorno = lcWhereAux1
			if !empty( lcWhereAux2 )
				lcRetorno = lcRetorno + iif( !empty( lcRetorno ), ' and ', '' ) + lcWhereAux2
			endif

		endwith
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormatoInicioParaCamposString() as String
		return "UPPER( ALLTRIM( "
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFormatoFinParaCamposString() as String
		return " ) )"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValorAString( txValor as String ) as String
		local lcRetorno as String
		
		lcRetorno = goLibrerias.ValorAString( txValor )
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TransformarValorSegunTipoDeDato( txValor as Variant, tcTipoDato as String ) as variant
		local lxRetorno as Variant
		
		do case
			case isnull( txValor )
				lxRetorno = txValor
				
			case tcTipoDato = "C" 
				lxRetorno = txValor
				
			case tcTipoDato = "N" or tcTipoDato = "A"
				lxRetorno = val( transform( txValor ) )
				
			case tcTipoDato = "D" and _Screen.zoo.App.TipoDeBase = "SQLSERVER" and empty( txValor )
				lxRetorno = evaluate( alltrim( goRegistry.Nucleo.FechaEnBlancoParaSqlServer ) )

			otherwise
				lxRetorno = txValor
		endcase
		
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRegistroRelacionado( tcEntidad as String, tcAtributo as string ) as Void
		local lcCursor as string, loRetorno as object

		lcCursor = sys( 2015 )

		select * from c_Estructura ;
			where alltrim( upper( tcEntidad ) ) == alltrim( upper( Entidad ) ) and ;
				alltrim( upper( tcAtributo ) ) == alltrim( upper( Atributo ) ) ;
			into cursor ( lcCursor )

		loRetorno = null			
		if _tally > 0
			scatter name loRetorno
		endif
		
		use in select( lcCursor )
		
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DespuesDeObtener( toObjTrans as object ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerInSqlServer( tcCursor as String, tcSucursal as String, tcCampoPk as String ) as String
		local lcRetorno As String
		lcRetorno = ""
		select &tcCursor
		if empty( tcSucursal )
			scan all
				if vartype( &tcCursor..&tcCampoPk ) = "N"
					lcRetorno = lcRetorno + "," +  rtrim( transform( &tcCursor..&tcCampoPk ) )
				Else
					lcRetorno = lcRetorno + ",'" + rtrim( transform( &tcCursor..&tcCampoPk ) ) + "'"
				Endif
			endscan
		else
			scan all for upper( alltrim( Database ) ) == upper( alltrim( tcSucursal ) )
				if vartype( &tcCursor..&tcCampoPk ) = "N"
					lcRetorno = lcRetorno + "," +  rtrim( transform( &tcCursor..&tcCampoPk ) )
				Else
					lcRetorno = lcRetorno + ",'" + rtrim( transform( &tcCursor..&tcCampoPk ) ) + "'"
				Endif
			endscan
		endif
		if !empty( lcRetorno )
			lcRetorno = substr( lcRetorno, 2 )
			lcRetorno = " in (" + lcRetorno + ")"
		endif
		return lcRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionInSqlServer( tcCursor as String, tcSucursal as String, tcCampoPk as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcValor as String 
		
		loRetorno = _Screen.zoo.crearobjeto( "ZooColeccion" )		
		select &tcCursor
		if empty( tcSucursal )
			scan all
				lcValor = rtrim( transform( &tcCursor..&tcCampoPk ) )
				if vartype( &tcCursor..&tcCampoPk ) != "N"
					lcValor = "'" + lcValor + "'"
				endif
				loRetorno.Agregar( lcValor )
			endscan
		else
			scan all for upper( alltrim( Database ) ) == upper( alltrim( tcSucursal ) )
				lcValor = rtrim( transform( &tcCursor..&tcCampoPk ) )
				if vartype( &tcCursor..&tcCampoPk ) != "N"
					lcValor = "'" + lcValor + "'"
				endif
				loRetorno.Agregar( lcValor )
			endscan
		endif
		return loRetorno
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerFragmentoColeccionInSqlServer( toColeccion as zoocoleccion OF zoocoleccion.prg, tnInicio as Integer, tnCantidad as Integer ) as string
		local lcRetorno as string, lcValor as String, i as Integer, lnCantidad as Integer

		lcRetorno = ""
		
		for i = 0 to tnCantidad - 1
			if ( tnInicio + i ) > toColeccion.count
				exit
			else
				lcRetorno = lcRetorno + "," + toColeccion.Item( tnInicio + i )
			endif
		endfor
		
		if !empty( lcRetorno )
			lcRetorno = substr( lcRetorno, 2 )
			lcRetorno = " in (" + lcRetorno + ")"
		endif
		return lcRetorno	
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function LlenarCampoMemo( tcCursor as String, tcCampoMemo as String, tcCampoPK as String, tcTablaMemo as String )as Void
		local lcMemo as String, lcCursor as String

		alter table &tcCursor alter column &tcCampoMemo M
		lcCursor = sys( 2015 )
		
		this.CombinarTablaPrincipalConMemos( tcCampoPk , tcTablaMemo , tcCursor , tcCampoPk , lcCursor )

		index on ordenMemos tag ordenMemos
		select &tcCursor
		scan for !empty( &tcCursor..&tcCampoMemo )
			lcMemo = this.ObtenerMemoUnificado( &tcCursor..&tcCampoPK, tcTablaMemo, tcCampoPK, lcCursor )
			replace &tcCampoMemo with lcMemo in &tcCursor
		endscan

		use in select( lcCursor )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CombinarTablaPrincipalConMemos( tcCampoPk as String, tcTablaMemo as String, tcCursor as String, tcCampoPk as String, tcCursorFinal as String ) as Void
		*** La funcionalidad esta en transferenciabase y en exportacionbase, ya que joinean distinto.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMemoUnificado( txClave as Variant, tcTablaMemo as String, tcCampoClave as String, tcCursor as string ) as String
		local lcRetorno as String 
		lcRetorno = ""
		
		select &tcCursor
		if seek( transform( txClave, "@L" ) + str( 1 ,20 ) )
			lcRetorno = this.oMemos.Obtener( tcCursor, tcCampoClave, txClave )
		endif	
		
		return lcRetorno
	endfunc 
	
enddefine

