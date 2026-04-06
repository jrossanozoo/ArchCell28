**********************************************************************
DEFINE CLASS zTestKontrolerzlAltaGrupocom as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestKontrolerzlAltaGrupocom OF zTestKontrolerzlAltaGrupocom.PRG
	#ENDIF
	
	
	function Setup
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInstancioFormularioIS
		local loKontroler as Object, llRetorno as Boolean, loEntidad as Object
		

*!*			loKontroler = newobject( "Mock_KontrolerzlAltaGrupocom" )
*!*			llRetorno = loKontroler.Mock_InstancioFormularioIS()
*!*			This.asserttrue( "Debe devolver .F., el formulario de IS no esta instanciado.", !llRetorno )
*!*			
*!*			loEntidad = goFormularios.procesar( "ZLSERVICIOSLOTE" )
*!*	PrimerInstancia 
*!*			llRetorno = loKontroler.Mock_InstancioFormularioIS()
*!*			This.asserttrue( "Debe devolver .T., el formulario de IS esta instanciado.", llRetorno )
*!*			
*!*			loEntidad.Release()
*!*			loKontroler.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestPermitirNuevoEnEntidad
		local llRetorno as Boolean, loForm as Form
		
		loForm = _Screen.zoo.crearobjeto( "ZooFormulario" )
		loForm.Newobject( "oKontroler", "Mock_KontrolerzlAltaGrupocom" )
			
		loForm.oKontroler.lEjecutarInstancioFormularioIS = .F.
		loForm.oKontroler.lRetornoInstancioFormularioIS = .F.
		llRetorno = loForm.oKontroler.Mock_PermitirNuevoEnEntidad()
		This.asserttrue( "Debe Permitir hacer NUEVO.", llRetorno )
		
		loForm.oKontroler.lEjecutarInstancioFormularioIS = .F.
		loForm.oKontroler.lRetornoInstancioFormularioIS = .T.

		llRetorno = loForm.oKontroler.Mock_PermitirNuevoEnEntidad()
		This.asserttrue( "No debe Permitir hacer NUEVO.", !llRetorno )

		loForm.Release()
	endfunc 
	
ENDDEFINE

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_KontrolerzlAltaGrupocom as KontrolerzlAltaGrupocom of KontrolerzlAltaGrupocom.prg

	lEjecutarInstancioFormularioIS = .T.
	lRetornoInstancioFormularioIS = .F.
	PrimerInstancia = .f.
	
	*-----------------------------------------------------------------------------------------
	function Mock_InstancioFormularioIS() as Boolean
		return This.InstancioFormularioIS()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Mock_PermitirNuevoEnEntidad() as Boolean
		return This.PermitirNuevoEnEntidad()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InstancioFormularioIS() as Boolean
		local llRetorno as Boolean
		if This.lEjecutarInstancioFormularioIS
			llRetorno = dodefault()
		else
			llRetorno = This.lRetornoInstancioFormularioIS
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FormularioVisible( tni as integer ) as Boolean 
		local lRetorno as Boolean 
		lRetorno = this.PrimerInstancia 
*!*			if  upper( _screen.Forms( tni ).Class ) = 'DIN_ABMZLSERVICIOSLOTEAVANZADOESTILO2'
*!*				this.PrimerInstancia = .t.
*!*			endif 	
		return lRetorno 
	endfunc 
	
enddefine


