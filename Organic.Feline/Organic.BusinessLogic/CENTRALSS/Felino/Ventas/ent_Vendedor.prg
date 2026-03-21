define class Ent_Vendedor as Din_EntidadVendedor of Din_EntidadVendedor.prg

	#IF .f.
		Local this as Ent_Vendedor of Ent_Vendedor.prg
	#ENDIF	

    oComisiones = NULL

	*--------------------------------------------------------------------------------------------------------
	function oComisiones_Access() as variant
		if !this.ldestroy and ( !vartype( this.oComisiones ) = 'O' or isnull( this.oComisiones ) )
			this.oComisiones = _screen.zoo.instanciarentidad( 'COMISION' )
		endif
		
		return this.oComisiones
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function CambiosDetalleComisionesdetalle() as void
		local loError as Object
		
		dodefault()

		try
			this.CargarAtributosVirtualesEnDetalle( this.ComisionesDetalle )
		catch to loError
			this.EventoAlAsignarCodigoDeComisionInexistente()
		endtry 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoAlAsignarCodigoDeComisionInexistente() as void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarAtributosVirtualesEnDetalle( toDetalle as Object ) as Void
		local loItem as Object
		for each loItem in toDetalle foxobject
			with this.oComisiones
				.Codigo = loItem.Comision_pk
 				loItem.ComisionDetalle = .Descripcion
				loItem.FechaModificacion = .FechaModificacionFW
				loItem.HoraModificacion = .HoraModificacionFW
				loItem.VigenciaDesde = .FechaVigenciaDesde
				loItem.VigenciaHasta = .FechaVigenciaHasta
				loItem.Porcentaje = .Porcentaje
				loItem.MontoFijo = .MontoFijo
			endwith			
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_Fechanacimiento( txVal as variant ) as Boolean
		local ldFecha, lcSetCentury, llRetorno

		llRetorno = dodefault( txVal )
		lcSetCentury = set("Century")
		set century on
		ldFecha = date()

		if ldFecha < txVal
			llRetorno = .F.
			set century &lcSetCentury
			goServicios.Errores.LevantarExcepcion( "La fecha de nacimiento no puede ser posterior a la fecha actual." )
		endif

		set century &lcSetCentury

		return llRetorno
		
	endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = .F. 
		if dodefault() and this.ValidarDescuento()
			llRetorno = .T.
		else 
			this.AgregarInformacion( "El Descuento seleccionado tiene un modo de funcionamiento no permitido para la operación." )
		endif
		return llRetorno
	Endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function ValidarDescuento() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno
			if alltrim( this.DescuentoPreferente_PK ) != "" and this.DescuentoPreferente.ModoFuncionamiento != 4 and this.DescuentoPreferente.ModoFuncionamiento != 6
					llRetorno = .F.
			endif
		endif
		
		Return llRetorno
	Endfunc

enddefine
