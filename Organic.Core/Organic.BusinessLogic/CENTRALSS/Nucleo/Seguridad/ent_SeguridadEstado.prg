define class ent_Seguridadestado as Din_EntidadSeguridadestado of Din_EntidadSeguridadestado.prg

	#if .f.
		local this as ent_Seguridadestado of ent_Seguridadestado.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		
		with this
			.GenerarDato( 1, "Habilitado" )
			.GenerarDato( 2, "Deshabilitado" )
			.GenerarDato( 3, "Requiere clave" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarDato( tcCodigo as string, tcDescripcion as string ) as VOID
		local loError as Exception, loEx as Exception, llCargar as Boolean

		with this
			llCargar = .f.
			try
				.Codigo = tcCodigo 
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					if loEx.nZooErrorNo = 9001
						llCargar = .t.
					else
						.Throw()
					endif
				EndWith
			Finally
			endtry
			
			if llCargar 
				.Nuevo()
				.Codigo = tcCodigo 
				.Descripcion = tcDescripcion 
				.Grabar()
			else
				if upper( alltrim( .Descripcion ) ) != upper( alltrim( tcDescripcion ) )
					.Modificar()
					.Descripcion = tcDescripcion 
					.Grabar()
				endif
			endif
		endwith
	endfunc 

enddefine
