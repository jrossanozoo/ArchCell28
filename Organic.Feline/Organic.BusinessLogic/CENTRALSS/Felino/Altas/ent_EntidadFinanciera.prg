define class Ent_EntidadFinanciera as Din_EntidadEntidadFinanciera of Din_EntidadEntidadFinanciera.prg

	#if .f.
		local this as Ent_EntidadFinanciera of Ent_EntidadFinanciera.prg
	#endif

	lHabilitarCUIT = .f.
	lHabilitarRUT = .f.
	lEstoyEnChile = .f.
	lEstoyEnUruguay = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.lEstoyEnChile = ( GoParametros.Nucleo.DatosGenerales.Pais == 2 )
		this.lEstoyEnUruguay = ( GoParametros.Nucleo.DatosGenerales.Pais == 3 )

		this.HabilitarAtributos()
	endfunc 
	
	*-------------------------------------------------------------------------------------------------
	Function Nuevo() As Boolean

		llRetorno = dodefault()	
		if llRetorno
			this.HabilitarAtributos()
		endif
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function Modificar() as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault()	
		if llRetorno
			this.HabilitarAtributos()
		endif
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAtributos() as Void

		this.lHabilitarRUT  = iif( this.lEstoyEnChile or this.lEstoyEnUruguay, .T., .F. )
		this.lHabilitarCUIT = iif( this.lEstoyEnChile or this.lEstoyEnUruguay, .F., .T. )
		
	endfunc 	

enddefine
