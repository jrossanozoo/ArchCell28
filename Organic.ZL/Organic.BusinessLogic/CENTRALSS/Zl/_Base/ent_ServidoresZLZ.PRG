define class ent_ServidoresZLZ as din_entidadServidoresZLZ of din_entidadServidoresZLZ.prg
	#if .f.
		local this as ent_ServidoresZLZ of ent_ServidoresZLZ.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function ActualizarEstado() as void
		dodefault()
		this.ActivarAtributosSegunModo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActivarAtributosSegunModo() as Void
		this.lHabilitarServidorZLZ = ( this.ModoSubida = 1 ) or ( this.ModoSubida = 3 ) &&FTP o Bucket
		this.lHabilitarUsuarioZLZ = ( this.ModoSubida = 1 ) or ( this.ModoSubida = 3 ) &&FTP o Bucket
		this.lHabilitarContraseñaZLZ = ( this.ModoSubida = 1 ) or ( this.ModoSubida = 3 ) &&FTP o Bucket
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCambioEtiquetas() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_Modosubida( txVal as variant ) as Void
		dodefault( txVal )
		this.EventoCambioEtiquetas()
	endfunc 


enddefine