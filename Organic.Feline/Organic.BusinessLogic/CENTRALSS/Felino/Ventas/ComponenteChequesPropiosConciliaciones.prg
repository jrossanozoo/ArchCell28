define class ComponenteChequesPropiosConciliaciones as din_ComponenteChequesPropiosConciliaciones of din_ComponenteChequesPropiosConciliaciones.prg

	#If .F.
		Local This As ComponenteChequesPropiosConciliaciones As ComponenteChequesPropiosConciliaciones.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		DoDefault()
		This.oDetalleAnterior = _Screen.zoo.crearobjeto( "zooColeccion" )
	endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function Grabar() as zoocoleccion OF zoocoleccion.prg 
*!*			local loColSentencias as Object

*!*			loColSentencias = dodefault()
*!*			return loColSentencias
*!*		endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdentificadorComprobante() as String
		return this.oEntidadPadre.Codigo	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCuentaBancariaDeItem( toItem ) as String
		return ''   && 'CTA01'   &&& return this.oEntidadPadre.Concepto.CuentaBancaria_pk
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarEntidad() as Boolean
		return .t.
	endfunc
	
enddefine