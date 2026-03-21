Define Class colorytalle_colaboradorCheques As colaboradorCheques Of colaboradorCheques.prg

	#If .F.
		Local This As colorytalle_colaboradorCheques As colorytalle_colaboradorCheques.prg
	#Endif

	#define ENCARTERA			"CARTE"
	#define ENCUSTODIA			"CUSTO"
	#define ENCURSO				"CURSO"
	#define COBRADO				"COBRA"
	#define ENTREGADO			"ENTRE"
	#define PREPARADO			"PREPA"
	#define DEPOSITADO			"DEPOS"
	#define ACREDITADO			"ACRED"
	#define DEBITADO			"DEBIT"
	#define ANULADO				"ANULA"
	#define BAJA				"BAJA"
	#define RECHAZADO			"RECHA"
	#define DEVOLUCIONRECHAZO	"DEVOL"
	#define ENTRANSITO			"TRANS"
	#define CANCELADO			"CANCE"
	#define ENVIADO				"ENVIA"
	#define ENVIORECHAZADO		"ENVRE"

	#define TIPONODEFINIDO	0
	#define TIPOENTRADA		1
	#define TIPOSALIDA		2

	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO 			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO	14

	*-----------------------------------------------------------------------------------------
	protected Function InicializarColaborador() as Void
		DoDefault()
		this.SetearConfiguracion()
		if this.ImplementaEstadosDeCheques()
			this.CargarFlujos()
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearConfiguracion() as Void
		local lcSentencia as String
		lcSentencia = this.ObtenerSentenciaConfiguracion()
		goServicios.Datos.Ejecutarsentencias( lcSentencia, 'concecaja', '', 'setEstados', this.DataSessionId )
		if used("setEstados")
			If Reccount("setEstados") = 1
				go top in setEstados
				this.lImplementaEstadosDeCheques = setEstados.Estados > 0
			else
				this.lImplementaEstadosDeCheques = .f.
			endif
			use in setEstados
		endif
		return
	EndFunc 

	*-----------------------------------------------------------------------------------------
    Protected Function ObtenerSentenciaConfiguracion() as String
		Local lcRetorno as String
			lcRetorno = "Select sum(case when estcheque  = '' then 0 else 1 end) Estados "
            lcRetorno = lcRetorno + "from zoologic.concecaja"
		Return lcRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarFlujos() as Void
		local loItem as Object
		this.oTabFlujo = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = this.ObtenerItemFlujo(ENCARTERA,"Descargadecheques",TIPOSALIDA,ENCURSO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(ENCURSO,"CanjeDeCupones",TIPOSALIDA,COBRADO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(ENCURSO,"Descargadecheques",TIPOENTRADA,RECHAZADO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(RECHAZADO,"CanjeDeCupones",TIPOSALIDA,DEVOLUCIONRECHAZO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(ENCARTERA,"ComprobanteDeCaja",TIPOSALIDA,DEPOSITADO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(ENCARTERA,"ComprobanteDeCaja",TIPOSALIDA,ENCUSTODIA)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(DEPOSITADO,"Descargadecheques",TIPOSALIDA,ACREDITADO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(ENCARTERA,"ComprobantePago",TIPOSALIDA,ENTREGADO)
		this.oTabFlujo.Agregar( loItem )
		loItem = this.ObtenerItemFlujo(DEPOSITADO,"ComprobanteDeCaja",TIPOSALIDA,RECHAZADO)
		this.oTabFlujo.Agregar( loItem )
	endfunc

EndDefine

