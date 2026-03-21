define class ent_ModificacionDeCostosDeProduccion as Din_EntidadMODIFICACIONDECOSTOSDEPRODUCCION of Din_EntidadMODIFICACIONDECOSTOSDEPRODUCCION.prg

	#IF .f.
		Local this as ent_ModificacionDeCostosDeProduccion of ent_ModificacionDeCostosDeProduccion.prg
	#ENDIF

	oColaboradorCalculoDeCostos = null

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.ModCostos.InyectarEntidad( this )
		this.ModCostos.oItem.InyectarDetalle( this.ModCostos )
		this.ModCostos.oItem.oCompCostosProduccion.lProcesarCostos = .T.
		This.ModCostos.oItem.oCompCostosProduccion.InyectarEntidad( this )
		this.lEliminar = .F.
	endfunc 

*!*		*-------------------------------------------------------------------------------------------------
*!*		Function Init( t1, t2, t3, t4 ) As Boolean
*!*			Local llRetorno As Boolean

*!*			llRetorno = DoDefault(t1, t2, t3, t4 )
*!*			If llRetorno
*!*				if _Screen.Zoo.nVersionSQLNo < 2014
*!*					messagebox("Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022",16,"Restricción de acceso",10000)
*!*					this.release()
*!*				endif
*!*			Endif
*!*			Return llRetorno
*!*		endfunc

*!*	*!*		*-------------------------------------------------------------------------------------------------
*!*	*!*		Function Init( t1, t2, t3, t4 ) As Boolean
*!*	*!*			Local llRetorno As Boolean

*!*	*!*			llRetorno = DoDefault(t1, t2, t3, t4 )
*!*	*!*			If llRetorno
*!*	*!*				if _Screen.VersionSQLNo < '2014'
*!*	*!*					messagebox("Para usar costos en el módulo de producción debe actualizar el motor de base de datos a SQL Server 2022",16,"Restricción de acceso",10000)
*!*	*!*	*!*					goMensajes.Alertar('Para usar costos en el modulo de producción debe actualizar el motor de base de datos a SQL Server 2022')
*!*	*!*					this.release()
*!*	*!*	*!*					goServicios.Errores.LevantarExcepcion( "Para usar costos en el modulo de producción debe actualizar el motor de base de datos a SQL Server 2022" )
*!*	*!*				endif
*!*	*!*			Endif
*!*	*!*			Return llRetorno
*!*	*!*		endfunc

	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		dodefault()
		this.ModCostos.oItem.Habilitar(.f.)
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EventoMensajeProcesando( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinMensajeProcesando() as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeSugerirCodigo() as Boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoMensajeAletarVersionSQL() as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

enddefine
