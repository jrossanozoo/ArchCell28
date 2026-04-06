define class ColaboradorClientCare  as ZooSession of ZooSession.prg

	cUsuario = ''

	*-------------------------------------------------------------------
	Function SeteosPrivados() as VOID 
		dodefault()
		this.cUsuario = goServicios.Seguridad.cUltimoUsuarioLogueado
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ValidarCierre( toEntidad as Object ) as Boolean
		local lRetorno as Boolean, lcMensaje as String  
		lRetorno = .t.
		if  toEntidad.MotivoCierre_pk = 2 
			if empty(toEntidad.MotivoBaja_Pk)
				lRetorno = .f.
				lcMensaje = 'Debe completar el atributo Motivo de baja.'
			endif
			if lRetorno and empty(alltrim(toEntidad.Obs))
				lRetorno = .f.
				lcMensaje = 'Debe completar el atributo Observaciones.'
			endif
		endif
		if lRetorno and !empty( toEntidad.MotivoCierre_pk )
			if toEntidad.MotivoCierre.Tipo_pk <> toEntidad.NumeroClientCare.Tipo_pk
				lRetorno = .f.
				lcMensaje = 'El Tipo de actividad del Motivo difiere del tipo de actividad del Client Care.'
			endif 
		endif 
		if !lRetorno
			goServicios.Errores.levantarexcepcion ( lcMensaje )
		endif
		return lRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionesClientCare( toEntidad as Object ) as Boolean
		local lRetorno as Boolean 
		lRetorno = .t.
		if !lRetorno
			goServicios.Errores.levantarexcepcion ( '' )
		endif
		return lRetorno
	endfunc 

enddefine
