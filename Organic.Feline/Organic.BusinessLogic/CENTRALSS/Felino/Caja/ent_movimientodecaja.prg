define class ent_MovimientodeCaja as Din_EntidadMovimientodeCaja of Din_EntidadMovimientodeCaja.prg

	#if .f.
		local this as ent_MovimientodeCaja of ent_MovimientodeCaja.prg
	#endif

*!* -->		#include valores.h
	#define TIPOVALORMONEDALOCAL			1
	#define TIPOVALORMONEDAEXTRANJERA		2
	#define TIPOVALORTARJETA       			3
	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO  			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO  	14
	#define TIPOVALORCUENTABANCARIA			13
	#define TIPOVALORPAGOELECTRONICO		11
	#define TIPOVALORCUENTACORRIENTE   		6
	#define TIPOVALORVALEDECAMBIO			8
	#define TIPOVALORPAGARE					5
	#define TIPOVALORTICKET					7
	#define TIPOVALORAJUSTEDECUPON  10

	#define TIPOMOVIMIENTONODEFINIDO 0
	#define TIPOMOVIMIENTOENTRADA			1
	#define TIPOMOVIMIENTOSALIDA			2
	#define ESTADOINGRESADO					1
	#define ESTADOSELECCIONADO				2
*!*		#include valores.h   <--


	*-----------------------------------------------------------------------------------------
	function ObtenerSiguienteNumerico() as Integer
		local lcXml as String
		
		lcXml = this.oAD.ObtenerDatosEntidad( "ID", , , "Max" )
				
		this.xmlACursor( lcXml, "c_Valores" )
		
		lnMaximo = nvl( c_Valores.max_Id , 0 ) + 1
		use in select( "c_Valores" )
		return lnMaximo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTurno() as Integer 
		Local lnTurno As Integer , lcParametroDelTurno As String, lcHora as String

		lcParametroDelTurno = goParametros.Felino.Sugerencias.CambioDeTurno
		lcHora = goServicios.Librerias.ObtenerHora()
		If ( Val( Substr( lcHora, 1, 2 ) ) * 100) + Val( Substr( lcHora, 4, 2 ) ) < lcParametroDelTurno
			If !Between( ( Val( Substr( lcHora, 1, 2 ) ) * 100) + Val( Substr( lcHora, 4, 2 ) ) , 0, 600 )
				lnTurno = 1
			Else
				lnTurno = 2
			Endif
		Else
			lnTurno = 2
		Endif

		Return lnTurno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCajaEstado() as Boolean 
		local loCajaEstado as Ent_CajaEstado of Ent_CajaEstado.prg, llRetorno as Boolean 
		llRetorno = dodefault()
		loCajaEstado = _Screen.zoo.instanciarEntidad( "CajaEstado" )
		if loCajaEstado.EstaAbierta( This.CajaEstado_Pk )
		else
			This.AgregarInformacion( "La caja " + transform( This.CajaEstado_Pk ) + " no esta abierta." )
			llRetorno = .F.
		Endif
		loCajaEstado.Release()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCierreDetallado( tnCaja as Integer, tnIdAuditoria as Integer, tcFiltro as String ) as Collection
		local loRetorno as Collecion, lcCursor as String, lcXml as String, loValor as Object, lcFiltro as String, lcEstado as String
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		lcCursor = sys( 2015 )
		lcFiltro = "CajaAuditoria = " + transform( tnIdAuditoria ) + " and  TipoValor = " + alltrim(str(TIPOVALORCIRCUITOCHEQUETERCERO))
		lcXml = This.oAd.obtenerdatosentidad( "Valor,Monto,TipoValor,ItemValor,CajaEstado", lcFiltro+" " , "", "" )
		this.XmlACursor( lcXml, lcCursor )
		select &lcCursor
		go top in select( lcCursor )
		scan
		 	if &lcCursor..TipoValor = TIPOVALORCIRCUITOCHEQUETERCERO
		 		lcEstado = this.ObtenerEstadoDeCheque( &lcCursor..ItemValor )
		 		lcFiltro = "inlist(lcEstado," + tcFiltro + ")"
				if  evaluate(lcFiltro)
					loCustom = newobject( "ItemDetalleSaldo" )
					loCustom.Monto = &lcCursor..Monto
					loCustom.Valor = alltrim(&lcCursor..Valor)
					loCustom.NumeroInterno = this.ObtenerNumeroInternoCheque( &lcCursor..ItemValor )
					if !loRetorno.Buscar( loCustom.NumeroInterno )
						loRetorno.Agregar( loCustom, loCustom.NumeroInterno )
					endif
				endif
			endif
			select &lcCursor
		endscan
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroInternoCheque( tcItemValor as String ) as String
		local loCheque as entidad OF entidad.prg, lcRetorno as String, lcNumeroInterno as String
		loCheque = _Screen.Zoo.InstanciarEntidad( "Cheque" )
		try
			loCheque.Codigo = tcItemValor
			lcNumeroInterno = padl( transform( loCheque.PuntoDeVenta ), 4, "0" ) + "-" + padl( transform( loCheque.NumeroC ), 8, "0" )
		catch
			lcNumeroInterno = ""
		finally
			lcRetorno = lcNumeroInterno
		endtry
		loCheque.Release()
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoDeCheque( tcItemValor as String ) as String
		local loCheque as entidad OF entidad.prg, lcRetorno as String, lcEstado as String
		loCheque = _Screen.Zoo.InstanciarEntidad( "Cheque" )
		try
			loCheque.Codigo = tcItemValor
			lcEstado = loCheque.Estado
		catch
			lcEstado = ""
		finally
			lcRetorno = lcEstado
		endtry
		loCheque.Release()
		return lcRetorno
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
Define Class ItemDetalleSaldo as Custom

	Monto = 0
	Valor = ""
	MedioDePago = ""
	NumeroInterno = ""

enddefine
