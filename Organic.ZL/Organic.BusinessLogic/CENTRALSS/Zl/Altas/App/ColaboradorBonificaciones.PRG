define class ColaboradorBonificaciones as zoosession of zoosession.prg
	
	oEntidad =  null 
	oFormBONIFICACIONIISS = null

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as entidad OF entidad.prg ) as Void
		this.oEntidad = toEntidad
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function LlenarSugeridos() as Void
		With This.oFormBONIFICACIONIISS
			.oEntidad.Cliente_Pk  = This.oEntidad.Cliente_Pk
			.oEntidad.RazonSocial_Pk  = This.oEntidad.Razonsocial_Pk
			.oEntidad.nPresupuestoOrigen = This.oEntidad.Numero
			.oEntidad.ListaDePrecios_PK = This.oEntidad.ListaDePrecios_PK
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LanzarBONIFICACIONIISS() as Void
		With This
			with .oFormBONIFICACIONIISS
				.Nuevo()
				this.LlenarSugeridos() 
				.Show(1)
			endwith 	
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function oFormBONIFICACIONIISS_Access()
		If  !This.ldestroy And !Vartype( This.oFormBONIFICACIONIISS ) = 'O'
			This.oFormBONIFICACIONIISS = goformularios.procesarsubentidad( 'BONIFICACIONIISS' )
			Bindevent( This.oFormBONIFICACIONIISS.okontroler.oEntidad, "DespuesdeGrabar", This, "OcultarFormularioCancelar" )
			Bindevent( This.oFormBONIFICACIONIISS.okontroler.oEntidad, "Cancelar", This, "OcultarFormularioCancelar", 1 )
		Endif
		Return This.oFormBONIFICACIONIISS
	Endfunc	

	*-----------------------------------------------------------------------------------------
	Function  OcultarFormularioCancelar()  As VOID
		This.oFormBONIFICACIONIISS.oEntidad.nPresupuestoOrigen = 0
		This.oFormBONIFICACIONIISS.Visible = .F.
	Endfunc	
	
enddefine 