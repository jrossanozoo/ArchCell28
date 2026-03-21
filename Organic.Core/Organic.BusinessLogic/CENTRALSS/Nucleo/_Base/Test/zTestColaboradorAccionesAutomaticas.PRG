define class zTestColaboradorAccionesAutomaticas as FxuTestCase of FxuTestCase.prg
	
	#if .f.
		local this as zTestColaboradorAccionesAutomaticas of zTestColaboradorAccionesAutomaticas.PRG
	#endif
	
	oColaborador = null

	*-----------------------------------------------------------------------------------------
	function setup
		this.oColaborador = newobject( "ColaboradorTest" )
		this.oColaborador.EliminaAccionesAutomaticasTodas()
	endfunc
	*-----------------------------------------------------------------------------------------
	function teardown
		this.oColaborador = null
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTest_ObtenerEntidad_Todas
		this.assertequals( "La entidad no es correcta. 1", "FACTURA", this.oColaborador.ObtenerEntidadTest(1))
		this.assertequals( "La entidad no es correcta. 2", "NOTADECREDITO", this.oColaborador.ObtenerEntidadTest(2))
		this.assertequals( "La entidad no es correcta. 3", "TICKETFACTURA", this.oColaborador.ObtenerEntidadTest(3))
		this.assertequals( "La entidad no es correcta. 4", "TICKETNOTADECREDITO", this.oColaborador.ObtenerEntidadTest(4))
		this.assertequals( "La entidad no es correcta. 5", "FACTURAELECTRONICA", this.oColaborador.ObtenerEntidadTest(5))
		this.assertequals( "La entidad no es correcta. 6", "NOTADECREDITOELECTRONICA", this.oColaborador.ObtenerEntidadTest(6))
		this.assertequals( "La entidad no es correcta. 7", "FACTURAELECTRONICADECREDITO", this.oColaborador.ObtenerEntidadTest(7))
		this.assertequals( "La entidad no es correcta. 8", "NOTADECREDITOELECTRONICADECREDITO", this.oColaborador.ObtenerEntidadTest(8))
		this.assertequals( "La entidad no es correcta. 9", "NOTADEDEBITO", this.oColaborador.ObtenerEntidadTest(9))
		this.assertequals( "La entidad no es correcta. 10", "TICKETNOTADEDEBITO", this.oColaborador.ObtenerEntidadTest(10))
		this.assertequals( "La entidad no es correcta. 11", "NOTADEDEBITOELECTRONICA", this.oColaborador.ObtenerEntidadTest(11))
		this.assertequals( "La entidad no es correcta. 12", "NOTADEDEBITOELECTRONICADECREDITO", this.oColaborador.ObtenerEntidadTest(12))
	endfunc
	*-----------------------------------------------------------------
	function zTest_GeneraAccionesAutomaticasTOTALSALE_SinComportamientosPrevios() as Void
		local lcExpresion as String, loEntidad as Object
		
		lcExpresion = "TOTALSALE"
		glProcesaTOTALSALE = .t.

		this.oColaborador.GeneraAccionesAutomaticasTOTALSALE()
		
		loEntidad = _screen.zoo.instanciarentidad( "AccionesAutomaticas" )

		try
			loEntidad.Codigo = lcExpresion + "FACTURA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "TICKETFACTURA"
			loEntidad.Codigo = lcExpresion + "TICKETNOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICA"
			loEntidad.Codigo = lcExpresion + "NOTADEDEBITO"
			loEntidad.Codigo = lcExpresion + "TICKETNOTADEDEBITO"
			loEntidad.Codigo = lcExpresion + "NOTADEDEBITOELECTRONICA"
			loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICADECREDITO"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICADECREDI"
			loEntidad.Codigo = lcExpresion + "NOTADEDEBITOELECTRONICADECREDIT"
		catch
			this.assertequals( "Deben estar cargados correctamente 12 compartamientos de atributos (acciones automaticas)", .t., .f.)		
		endtry
		
		loEntidad.release()
	endfunc
	*-----------------------------------------------------------------
	function zTest_GeneraAccionesAutomaticasPuntaShopping_SinComportamientosPrevios() as Void
		local lcExpresion as String, loEntidad as Object

		lcExpresion = "PUNTASHOPPING"
		glProcesaPUNTASHOPPING = .t.
		
		this.oColaborador.GeneraAccionesAutomaticasPUNTASHOPPING()
				
		loEntidad = _screen.zoo.instanciarentidad( "accionesautomaticas" )
		
		try
			loEntidad.Codigo = lcExpresion + "FACTURA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "TICKETFACTURA"
			loEntidad.Codigo = lcExpresion + "TICKETNOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICA"
			loEntidad.Codigo = lcExpresion + "NOTADEDEBITO"
			loEntidad.Codigo = lcExpresion + "TICKETNOTADEDEBITO"
			loEntidad.Codigo = lcExpresion + "NOTADEDEBITOELECTRONICA"
		catch
			this.assertequals( "Deben estar cargados correctamente 9 compartamientos de atributos (acciones automaticas)", .t., .f.)		
		endtry
		
		loEntidad.release()
	endfunc
	*-----------------------------------------------------------------
	function zTest_GeneraAccionesAutomaticasApsa_SinComportamientosPrevios() as Void
		local lcExpresion as String, loEntidad as Object
		
		lcExpresion = "APSA"
		glProcesaAPSA = .t.
		loEntidad = _screen.zoo.instanciarentidad( "accionesautomaticas" )
	
		this.oColaborador.GeneraAccionesAutomaticasAPSA()
				
		try
			loEntidad.Codigo = lcExpresion + "FACTURA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "TICKETFACTURA"
			loEntidad.Codigo = lcExpresion + "TICKETNOTADECREDITO"
			loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICA"
			loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICA"
		catch
			this.assertequals( "Deben estar cargados correctamente 6 compartamientos de atributos (acciones automaticas)", .t., .f.)		
		endtry
		
		loEntidad.release()
	endfunc
    
    *-----------------------------------------------------------------
    function zTest_GeneraAccionesAutomaticasVENTASFISERV_SinComportamientosPrevios() as Void
        local lcExpresion as String, loEntidad as Object

        lcExpresion = "VENTASFISERV"
        glModuloVentasFiServ = .t.

        this.oColaborador.GeneraAccionesAutomaticasVENTASFISERV()
        
        loEntidad = _screen.zoo.instanciarentidad( "AccionesAutomaticas" )

        try
            loEntidad.Codigo = lcExpresion + "FACTURA"
            loEntidad.Codigo = lcExpresion + "NOTADECREDITO"
            loEntidad.Codigo = lcExpresion + "TICKETFACTURA"
            loEntidad.Codigo = lcExpresion + "TICKETNOTADECREDITO"
            loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICA"
            loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICA"
            loEntidad.Codigo = lcExpresion + "NOTADEDEBITO"
            loEntidad.Codigo = lcExpresion + "TICKETNOTADEDEBITO"
            loEntidad.Codigo = lcExpresion + "NOTADEDEBITOELECTRONICA"
            loEntidad.Codigo = lcExpresion + "FACTURAELECTRONICADECREDITO"
            loEntidad.Codigo = lcExpresion + "NOTADECREDITOELECTRONICADECR"
            loEntidad.Codigo = lcExpresion + "NOTADEDEBITOELECTRONICADECRE"
        catch
            this.assertequals( "Deben estar cargados correctamente 12 comportamientos de atributos (acciones automaticas)", .t., .f.)        
        endtry
        
        loEntidad.release()
    endfunc
	*-----------------------------------------------------------------
	function zTest_CrearAccionesDetalle() as Void
		this.oColaborador.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )
		this.oColaborador.CrearAccionesDetalleTest("AntesDeGrabar","Exportar","TOTALSALEINICIOAUTOMATICO",1)
		
		this.assertequals( "La entidad no es correcta.", "AntesDeGrabar", this.oColaborador.loEntAux.AccionesDetalle.oItem.Metodo)
		this.assertequals( "La entidad no es correcta.", "Exportar", this.oColaborador.loEntAux.AccionesDetalle.oItem.Accion)
		this.assertequals( "La entidad no es correcta.", "TOTALSALEINICIOAUTOMATICO", this.oColaborador.loEntAux.AccionesDetalle.oItem.Expresion)
		this.assertequals( "La entidad no es correcta.", 1, this.oColaborador.loEntAux.AccionesDetalle.oItem.Orden)
		this.oColaborador.loEntAux.release()
	endfunc 
	*-----------------------------------------------------------------
	function zTest_AgregarAccionesDetalle() as Void
		local aux as String

		this.oColaborador.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

		this.oColaborador.AgregarAccionesDetalleTest("AntesDeGrabar","Exportar","TOTALSALE",1)
			
		this.assertequals( "AccionesDetalle debe tener un item cargado.",1, this.oColaborador.loEntAux.AccionesDetalle.count)
		this.oColaborador.loEntAux.release()
	endfunc 
	*-----------------------------------------------------------------
	function zTest_AgregarCabeceraConExpresion() as Void
		local aux as String
				
		this.oColaborador.loEntAux = _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )
		this.oColaborador.loEntAux.entidad = "FACTURA"
		this.oColaborador.AgregarCabeceraConExpresion("TOTALSALE","FACTURA")
			
		*El metodo Modificar de la entidad Acciones automaticas, devuelve los datos con espacios, por lo que el test se verifica con el alltrim
		this.assertequals( "El código se encuentra mal seteado","TOTALSALEFACTURA", alltrim(this.oColaborador.loEntAux.Codigo))
		this.assertequals( "La entidad se encuentra mal seteada.","FACTURA", alltrim(this.oColaborador.loEntAux.Entidad))
		this.assertequals( "NuevoDespuesDeGrabar debe ser true.",.t., this.oColaborador.loEntAux.NuevoDespuesDeGrabar)
		
		this.oColaborador.loEntAux.release()
	endfunc 
	*-----------------------------------------------------------------
enddefine
	*-----------------------------------------------------------------
define class ColaboradorTest as ColaboradorAccionesAutomaticas of ColaboradorAccionesAutomaticas.prg
	llHabilitaExportacion = .t.
	
	function ObtenerEntidadTest(tnDiseno as Integer) as String
		return this.ObtenerEntidad(tnDiseno)
	endfunc
	*-----------------------------------------------------------------
	function CrearAccionesDetalleTest(tcMetodo as String, tcAccion as String, tcExpresion as String, tnOrden as Integer) as void
		return this.CrearAccionesDetalle(tcMetodo, tcAccion, tcExpresion, tnOrden)
	endfunc
	*-----------------------------------------------------------------------------------------
	function AgregarAccionesDetalleTest(tcMetodo as String, tcAccion as String, tcExpresion as String, tnOrden as Integer) as void
		this.AgregarAccionesDetalle(tcMetodo, tcAccion, tcExpresion, tnOrden)		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarHabilitarExportacionTotalSale() as Void
		return this.llHabilitaExportacion
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarHabilitarExportacionAPSA() as Void
		return this.llHabilitaExportacion
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarHabilitarExportacionPuntaShopping() as Void
		return this.llHabilitaExportacion
	endfunc 
   *-----------------------------------------------------------------------------------------
    function ValidarHabilitarExportacionFiServ() as Void
        return this.llHabilitaExportacion
    endfunc 
		*-----------------------------------------------------------------------------------------
	function EliminaAccionesAutomaticasTodas() as Void
		Local lnCantidadDetalleBorrado as Integer, lnDiseno as Integer, cantidadDetalle as Integer, loEntidad as Object
		
		loEntidad= _Screen.zoo.InstanciarEntidad( "AccionesAutomaticas" )

		For lnDiseno = 1 to 12
			with loEntidad
			
				.Entidad = this.ObtenerEntidad(lnDiseno)
						
				If .oad.consultarporclavecandidata()

					goDatos.EjecutarSentencias ( "Select * From Accaut where Accaut.Codigo <> '' And Upper( Entidad ) == '" + .Entidad + "'" ,;
						"Accaut", "", "c_Acciones", Set( "Datasession" ) )

					If Reccount( "c_Acciones" ) > 0
						.Codigo = c_Acciones.Codigo
						.Eliminar()
					Endif
					Use In Select( "c_Acciones" )
			  endif
			Endwith
		endfor

		loEntidad.release()	
	endfunc
enddefine
