define class EntColoryTalle_Valor as Ent_Valor of Ent_Valor.prg

	#if .f.
		local this as EntColoryTalle_Valor of EntColoryTalle_Valor.prg
	#endif

	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO  			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO  	14

	*--------------------------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetear_Tipo() as void
		dodefault()
		this.HabilitarArrastraSaldo()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HabilitarArrastraSaldo() as Void
		if inlist(this.Tipo,TIPOVALORCIRCUITOCHEQUETERCERO,TIPOVALORCIRCUITOCHEQUEPROPIO)
			if this.ArrastraSaldo
				this.lHabilitarArrastraSaldo = .t.
				this.ArrastraSaldo = .f.
			endif
			this.lHabilitarArrastraSaldo = .f.
		else
			this.lHabilitarArrastraSaldo = .t.
		endif
	endfunc 

EndDefine
