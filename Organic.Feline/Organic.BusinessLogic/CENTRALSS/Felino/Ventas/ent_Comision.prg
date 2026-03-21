define class ent_Comision as din_entidadcomision of din_entidadcomision.prg

	#IF .f.
		Local this as ent_Comision of ent_Comision.prg
	#ENDIF

	*--------------------------------------------------------------------------------------------------------
	function Validar_Porcentaje( txVal as variant ) as Boolean

		if txVal > 100
			goServicios.Errores.LevantarExcepcion( "No se puede asignar un porcentaje mayor a 100." ) 
		endif

		Return dodefault( txVal )

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Fechavigenciadesde( txVal as variant ) as Boolean
		if !empty( this.FechavigenciaHasta ) and txVal > this.FechavigenciaHasta
			goServicios.Errores.LevantarExcepcion( "No se puede asignar una fecha inicial mayor que la de finalización." ) 
		endif

		Return dodefault( txVal )

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_FechavigenciaHasta( txVal as variant ) as Boolean
		if !empty( this.FechavigenciaDesde ) and txVal < this.FechavigenciaDesde
			goServicios.Errores.LevantarExcepcion( "No se puede asignar una fecha de finalización menor que la inicial." ) 
		endif

		Return dodefault( txVal )

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() AS boolean
		local llRetorno as boolean
		llRetorno = dodefault() and This.ValidarComision()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarComision() as Boolean 
		local llRetorno as Boolean 
		llRetorno = .t.	

		if empty( this.MontoFijo ) and empty( this.Porcentaje )
			llRetorno = .f.
			this.AgregarInformacion( "Debe ingresar un porcentaje o un monto fijo para la comisión" )
		else
			if !empty( this.MontoFijo ) and !empty( this.Porcentaje )
				llRetorno = .f.
				this.AgregarInformacion( "No se puede ingresar un porcentaje y un monto fijo para la comisión" )
			endif 	
		endif 

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarConformacionComision() as Void
		local loAdapter as XMLAdapter, loCol as zoocoleccion OF zoocoleccion.prg , lcCadena as String, lcPropiedad as String, lcAtributo as String       

		try	
			loAdapter = createobject( "xmladapter" )
			loCol = _screen.zoo.crearobjeto( "zooColeccion" )
			loCol.add( filetostr( 'Din_EstructuracomisionObjeto.Xml' ) )
			loAdapter.LoadXML( loCol.item[ 1 ] )
			loAdapter.tables.Item(1).tocursor()
			lcCadena = ""
			select * from c_estructura where "_desde" $ lower( atributo ) and dominio = "EtiquetaCaracterDesdeHastaBusc" into cursor c_atrib
			select c_atrib
			scan
				lcPropiedad = alltrim( c_atrib.Etiqueta )
				lcAtributo = lower( alltrim( c_atrib.atributo )) + "_pk"
				if !empty( this.&lcAtributo )
					lcCadena = lcCadena + lcPropiedad + ": " + alltrim( transform( this.&lcAtributo ))
					lcAtributo = strtran( lcAtributo , "_desde", "_hasta" )
					lcCadena = lcCadena + " - " + alltrim( transform( this.&lcAtributo )) + "; "
				endif
			endscan
			use in select( "c_atrib" )	
			use in select( "c_estructura" )	
			this.Conformacion1 = this.ObtenerCadena( lcCadena, 180, ";")
			lcCadena = strtran( lcCadena, this.Conformacion1, "" )
			this.Conformacion2 = this.ObtenerCadena( lcCadena, 180, ";")
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		finally 
		
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Validar() As Boolean
		local llRetorno as Boolean 
		llRetorno = dodefault()
		if llRetorno
			this.CargarConformacionComision()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCadena( tcCadena as String, tcCantidadMaxima as String, tcDelimitador as String ) as String 
		local lcRetorno as String 
		lcRetorno = substr( tcCadena, 1, tcCantidadMaxima )
		if len( alltrim( lcRetorno )) = tcCantidadMaxima 
			lcRetorno = substr( lcRetorno, 1, at( tcDelimitador, lcRetorno, getwordcount( lcRetorno, tcDelimitador ) - 1 )) 
		endif 
		return lcRetorno
	endfunc 

enddefine
