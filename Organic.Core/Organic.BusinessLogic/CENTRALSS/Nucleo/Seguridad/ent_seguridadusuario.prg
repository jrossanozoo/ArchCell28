define class Ent_Seguridadusuario as din_EntidadSeguridadusuario of din_EntidadSeguridadusuario.prg

	#if .f.
		local this as Ent_Seguridadusuario of Ent_Seguridadusuario.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
	
		do case
		case llRetorno
		case this.ValidaIngresoDeClaves()
			llRetorno = .F.
		case this.ValidarClaveIguales()
			llRetorno = .F.
		case this.ValidarCantidadItemsPerfiles()
			llRetorno = .F.
		endcase
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidaIngresoDeClaves() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		
		if ( empty( this.clave ) OR empty( this.clave2 ) )
			llRetorno = .f.
			this.AgregarInformacion( "Debe ingresar la contraseña del usuario y su validación.", 1 )
		endif		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarClaveIguales() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		
		if llRetorno and ( this.clave == this.clave2 )
		else
			llRetorno = .f.
			this.AgregarInformacion( "Las contraseñas ingresadas no son iguales.", 1 )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadItemsPerfiles() As Boolean
		Local llRetorno As boolean, loItem as Object
		llRetorno = dodefault()

		if type( "This.Perfiles" ) == "O" and llRetorno 
			llRetorno = .f.
			for each loItem in this.Perfiles
				if empty( loItem.Perfil_pk )
				else
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		if !llRetorno
			this.AgregarInformacion( "Debe agregar por lo menos un perfil al usuario.", 1 )
		endif
		
		Return llRetorno
	endfunc 	

enddefine
