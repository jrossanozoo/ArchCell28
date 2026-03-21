define class ColaboradorInfoAdicional as Custom

	#IF .f.
		Local this as ColaboradorInfoAdicional of ColaboradorInfoAdicional.prg
	#ENDIF

	cEntidad = ""
	esComprobante = .f.	
	cCampoNumero = ""
	cCursor = ""
	cPrefijo = ""
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaInsertTransferencia( tcEntidad as String ) as Void
		local lcSentencia as String, lcCamposInfoAdicional as String ,lcCadenaValores as String 
		this.cEntidad = tcEntidad
		this.cCursor = alltrim( this.cPrefijo ) +  alltrim( this.cEntidad )
		lcSentencia = ""
		lcCamposInfoAdicional = this.ObtenerAtributosInfoAdicional()
		lcCadenaValores = this.ObtenerCadenaValoresAInsertar()
		lcSentencia = lcCamposInfoAdicional + chr(13)+ chr(10)+ "( "+ lcCadenaValores + ")"
		return lcSentencia
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosInfoAdicional() as String 
		local lcCadena as String 
		lcCadena = "insert into "+ alltrim( this.cPrefijo ) +"itemcomprobante ( codigo, AfeTipoCom, AfeLetra, AfePtoVen, AfeNumCom, Afecta, AfeComprob, AfeFecha, AfeTipo, origen, AfeTotal ) values ;"
		return lcCadena
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCadenaValoresAInsertar() as String 
		local lcCadena as String, lcGuid as String  
		with this
			lcGuid = .ObtenerGuidPK()
			lcCadena = lcGuid + ", " +.ObtenerDatosDelComprobante() + ", " + lcGuid + ", "
			lcCadena = lcCadena + .ObtenerDescripcionEntidad() + ", " + .ObtenerFecha() + ", "
			lcCadena = lcCadena + .ObtenerTipoAfectacion() + ", "+ .ObtenerOrigen() + ", "+ .ObtenerTotal()
		endwith 
		return lcCadena 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerGuidPK() as String
		local lcRetorno as String, lcCampoPK as String  
		select c_diccionario
		locate for upper( alltrim( entidad )) == upper( alltrim( this.cEntidad )) and claveprimaria
		if found()
			lcCampoPK = alltrim( c_diccionario.campo )
		else 
			lcCampoPK = "codigo"
		endif 
		lcRetorno = this.cCursor + "." + lcCampoPK 
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDatosDelComprobante() as String 
		local lcRetorno as String 
		with this
			lcRetorno = .ObtenerTipoComprobante() + ", " + .ObtenerLetra() + ", " + .ObtenerPtoVta() + ", " + .ObtenerNumero()
		endwith 
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoComprobante() as String 
		local lcTipoComprobante as String 
		lcTipoComprobante = this.ObtenerCampoSegunAtributo( "TipoComprobante" )
		if empty(lcTipoComprobante)
			lcTipoComprobante = "99"
		endif 
		return lcTipoComprobante
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetra( ) as String
		local lcLetra as String 
		lcLetra = this.ObtenerCampoSegunAtributo( "Letra" )
		if empty( lcLetra )
			lcLetra = "'X'"
		endif
		return lcLetra
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPtoVta( ) as String
		local lcPtoVta as String 
		lcPtoVta = this.ObtenerCampoSegunAtributo( "PuntoDeVenta" )
		if empty( lcPtoVta )
			lcPtoVta  = "9999"
		endif	
		return lcPtoVta
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumero() as String
		local lcNumero as String 
		lcNumero = this.ObtenerCampoSegunAtributo( "Numero" )		
		if empty( lcNumero )
			lcNumero = "9999"
		endif	
		this.cCampoNumero = lcNumero
		return lcNumero

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFecha() as String
		local lcFecha as String 
		lcFecha = this.ObtenerCampoSegunAtributo( "Fecha" )		
		if empty( lcFecha )
			lcFecha = "{//}"
		endif	
		return lcFecha

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoSegunAtributo(tcAtributo as String ) as String 
		local lcRetorno as String 
		lcRetorno = ""
		if used( "c_diccionario" )
			select c_diccionario
			locate for upper( alltrim( Entidad ) ) == upper( alltrim(  this.cEntidad ) ) and upper( alltrim( atributo ) ) == upper( alltrim(  tcAtributo ) )
			if found()
				lcRetorno = this.cCursor + "." + alltrim( c_diccionario.campo )
			endif 	
		endif 
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionEntidad() as String 
		local lcRetorno as string
		lcRetorno = ""
		select c_Entidad
		locate for upper( alltrim( Entidad ) ) == upper( alltrim(  this.cEntidad ) )
		if found()
			lcRetorno = "'" + alltrim(c_entidad.descripcion) + " Nro ' +transform( " + this.cCampoNumero + " )"
		endif 
		return lcRetorno 

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoAfectacion() as Void
		return "'Afectado'"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerOrigen() as Void
		return "alltrim( _screen.Zoo.App.cSucursalActiva )"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTotal() as String
		local lnTotal as Integer  
		lnTotal = this.ObtenerCampoSegunAtributo( "Total" )		
		if empty( lnTotal )
			lnTotal = "0"
		endif	
		return lnTotal

	endfunc 

enddefine
