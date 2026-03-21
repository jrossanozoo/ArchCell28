define class ent_SituacionFiscal as Din_EntidadSituacionFiscal of Din_EntidadSituacionFiscal.prg

	#DEFINE INSCRIPTO        1
	#DEFINE CONSUMIDORFINAL  3
	#DEFINE EXENTO           4
	#DEFINE NORESPONSABLE    5
	#DEFINE MONOTRIBUTO      7
	
	#if .f.
		local this as ent_SituacionFiscal as ent_SituacionFiscal
	#endif

	*-----------------------------------------------------------------------------------------
	function EsResponsableInscripto() as Boolean
		local llRetorno as Boolean
		llRetorno = (this.Codigo = INSCRIPTO)
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsResponsableExento() as Boolean
		local llRetorno as Boolean
		llRetorno = (this.Codigo = EXENTO)
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsResponsableMonotributo() as Boolean
		local llRetorno as Boolean
		llRetorno = (this.Codigo = MONOTRIBUTO)
		return llRetorno
	endfunc 

enddefine
