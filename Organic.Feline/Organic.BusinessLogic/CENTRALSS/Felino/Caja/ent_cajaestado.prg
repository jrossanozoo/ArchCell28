define class Ent_CajaEstado as Din_EntidadCajaEstado of Din_EntidadCajaEstado.prg

	#if .f.
		Local this as Ent_CajaEstado of Ent_CajaEstado.prg
	#endif

	SeguridadEntidadAbrirCaja = "IT"
 	SeguridadMetodoAbrirCaja = "138"	
 	SeguridadEntidadEstadoCaja = "IT"
	SeguridadMetodoEstadoCaja = "38"
	SeguridadEntidadCerrarCaja = "IT"
	SeguridadMetodoCerrarCaja = "40"
	
	*-----------------------------------------------------------------------------------------
	function EstaAbierta( tnCaja As Integer  ) As Boolean
		local llEstaAbierta as Boolean, lnCajaAnterior as Integer
		with this
			lnCajaAnterior = .Id
			.Id = tnCaja
			llEstaAbierta = ( .Estado == "A" )
			.Id = lnCajaAnterior
		endwith
		return llEstaAbierta
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault()
		This.Fecha = date()
		this.HabilitarControles()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		This.Fecha = date()
		this.HabilitarControles()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeCajaaEstados( tnNumeroDeCaja as Integer ) as Void
		with this
			try
				.ID = tnNumeroDeCaja
			catch
				This.CrearCaja( tnNumeroDeCaja )
			finally
				.id = 0
			endtry
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HabilitarControles() as Void
		if pemstatus( this, "lHabilitarUsaVendedorArqueoEnCierre", 5 ) and pemstatus( this, "ArqueoAlCierre", 5 )
			this.lHabilitarUsaVendedorArqueoEnCierre = this.ArqueoAlCierre
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CrearCaja( tnNumeroDeCaja as Integer ) as Void
		with this
			.Nuevo()
			.ID = tnNumeroDeCaja
			.Descripcion = "Caja " + transform( tnNumeroDeCaja )
			.Estado = "C"
			.Fecha = date()
			.Observacion = "Creada automáticamente."
			.Grabar()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.AsignarNumeroDeCajaaEstados( int( goCaja.ObtenerNumeroDeCajaActiva() ) )
		this.HabilitarControles()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Arqueoalcierre( txVal as variant ) as void
		dodefault( txVal )
		this.UsaVendedorArqueoEnCierre = iif( txVal, this.UsaVendedorArqueoEnCierre, .f. )
		this.HabilitarControles()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Estado( txVal as Variant ) as VOID
		local loFechaYHora as Object
		dodefault( txVal )
		this.DescripcionEstado = icase( this.Estado = "C", "Cerrada", this.Estado = "A", "Abierta", "" ) 
		
		if !this.CargaManual()
			if this.Estado = "A"
				loFechaYHora = goCaja.ObtenerFechaDeUltimaApertura( this.ID )
				this.FechaUltimaApertura = loFechaYHora.Fecha
				this.HoraUltimaApertura = loFechaYHora.Hora
			else
				this.FechaUltimaApertura = {}
				this.HoraUltimaApertura = ""
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadAbrirCaja() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.SeguridadEntidadAbrirCaja , this.SeguridadMetodoAbrirCaja ) 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadEstadoCaja() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.SeguridadEntidadEstadoCaja , this.SeguridadMetodoEstadoCaja ) 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadCerrarCaja() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.SeguridadEntidadCerrarCaja , this.SeguridadMetodoCerrarCaja ) 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAccionAbrir() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.ObtenerModo( this.SeguridadEntidadAbrirCaja +"_" + this.SeguridadMetodoAbrirCaja ) # 2
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAccionEstado() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.ObtenerModo( this.SeguridadEntidadEstadoCaja +"_" + this.SeguridadMetodoEstadoCaja ) # 2
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarAccionCerrar() as Boolean
		Local llRetorno as Boolean
		llRetorno = goServicios.Seguridad.ObtenerModo( this.SeguridadEntidadCerrarCaja +"_" + this.SeguridadMetodoCerrarCaja ) # 2
		return llRetorno
	endfunc	

enddefine
