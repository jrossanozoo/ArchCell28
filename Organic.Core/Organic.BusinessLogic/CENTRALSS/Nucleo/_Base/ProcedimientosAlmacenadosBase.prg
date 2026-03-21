Define Class ProcedimientosAlmacenadosBase As Custom

	#IF .f.
		Local this as ProcedimientosAlmacenadosBase of ProcedimientosAlmacenadosBase.prg
	#ENDIF

	oConexion = null

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerGuidPK() As String
		local lcRetorno as String
		
		if goServicios.Datos.EsSqlServer()
			lcRetorno = "NEWID()"
		else
			lcRetorno = "goServicios.Librerias.ObtenerGuidPK()"
		endif
		
		Return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function Obtener_TCDesdeHasta( tcCampo as String, txParamDesde as Variant, txParamHasta as Variant ) as String
		local lcCondicion as String

		if isnull( txParamDesde )
			if isnull( txParamHasta )
				lcCondicion = "1 = 1"
			else
				lcCondicion = tcCampo + " <= " + this.ObtenerDatoSegunTipo( txParamHasta )
			endif
		else
			if isnull( txParamHasta )
				lcCondicion = tcCampo + " >= " + this.ObtenerDatoSegunTipo( txParamDesde )
			else
				lcCondicion = tcCampo + " <= " + this.ObtenerDatoSegunTipo( txParamHasta ) + " and " + tcCampo + " >= " + this.ObtenerDatoSegunTipo( txParamDesde )
			endif
		endif

		return lcCondicion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDatoSegunTipo( txParametro as variant ) as String
		local lcRetorno as String, lcTipoDato as String

		lcTipoDato = vartype( txParametro )
		do case
			case inlist(lcTipoDato, "N", "A" )
				lcRetorno = transform( txParametro )

			case lcTipoDato = "C"
				lcRetorno = "'" + txParametro + "'"

			case lcTipoDato = "D" or lcTipoDato = "T"
                lcRetorno = goServicios.Datos.ObtenerFechaFormateada( txParametro )
			case isnull( txParametro )	
				lcRetorno = 'NULL'
		endcase
	
		return lcRetorno
	endfunc 

Enddefine
