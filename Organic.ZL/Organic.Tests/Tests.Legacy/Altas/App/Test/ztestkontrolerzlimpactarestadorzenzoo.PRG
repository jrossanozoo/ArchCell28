**********************************************************************
define class zTestKontrolerZlImpactarEstadoRZenZoo as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestKontrolerZlImpactarEstadoRZenZoo of zTestKontrolerZlImpactarEstadoRZenZoo.PRG
	#endif

	*-----------------------------------------------------------------------------------------
	function zTestEnlaces

*		local loKontroler As KontrolerZlImpactarEstadoRZenZoo of KontrolerZlImpactarEstadoRZenZoo.Prg, loForm As Form

		loKontroler = newObject( "AuxKontroler", "zTestKontrolerZlImpactarEstadoRZenZoo.prg")
		
		loKontroler.oEntidad = newObject( "AuxEntidad", "zTestKontrolerZlImpactarEstadoRZenZoo.prg" )
		loKontroler.oEntidad.oActualizadorZoo = newObject( "AuxActualizarZoo" ,"zTestKontrolerZlImpactarEstadoRZenZoo.prg")
		
		loKontroler.Inicializar()

		lokontroler.oEntidad.oActualizadorZoo.InformarProgresoProcesoDeRechazos()
		This.Asserttrue( 'Mal 1', lokontroler.lLlamoInformarProgresoProcesoDeRechazos )

		lokontroler.oEntidad.oActualizadorZoo.InformarProgresoProcesoDeRechazos("Test")
		This.AssertEquals( 'Mal 2', lokontroler.cMensaje, "Test" )

		lokontroler.oEntidad.oActualizadorZoo.EnviarInformacion()
		This.Asserttrue( 'Mal 3', lokontroler.lLlamoInformacion )
	EndFunc	
enddefine

 
*-----------------------------------------------------------------------------------------
define class AuxEntidad as Custom
	oActualizadorZoo = null
enddefine

define class AuxKontroler as KontrolerZlImpactarEstadoRZenZoo of KontrolerZlImpactarEstadoRZenZoo.prg

	lLlamoInformarProgresoProcesoDeRechazos = .f.
	lLlamoInformacion = .f.
	cMensaje = ""
	
	*-----------------------------------------------------------------------------------------
	function Inicializar()
		this.Enlaces()
	endfunc

	
	*-----------------------------------------------------------------------------------------
	function InformarProgresoProcesoDeRechazos( tcMensaje as String ) as Void
		this.lLlamoInformarProgresoProcesoDeRechazos = .t.

		if !empty(tcMensaje)
			this.cMensaje = tcMensaje 
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Informacion() as Void
		this.lLlamoInformacion = .t.
	endfunc 
	
enddefine


define class AuxActualizarZoo as custom

	function InformarProgresoProcesoDeRechazos( tcMensaje as String ) as Void
	endfunc
	
	function EnviarInformacion() as Void
	endfunc
	
enddefine