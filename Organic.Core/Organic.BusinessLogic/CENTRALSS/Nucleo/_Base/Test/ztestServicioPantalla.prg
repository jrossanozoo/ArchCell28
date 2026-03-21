**********************************************************************
Define Class ztestServicioPantalla as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestServicioPantalla of ztestServicioPantalla.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestU_DeshabilitarFormularioActivoSinKontroler
		local loForm as FormTest of ztestServicioPantalla.prg
		loForm = newobject( "Form_Sin_Kontroler" )
		loForm.Show()
		loForm.LockScreen = .T.
		loForm.DesHabilitarFormularioActivo()	
		This.Asserttrue( "Cambio el lockScreen", loForm.LockScreen )
		loForm.Release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_DeshabilitarFormularioActivoConKontrolerSinEjecutar
		local loForm as FormTest of ztestServicioPantalla.prg
		loForm = newobject( "Form_Con_Kontroler_Sin_Ejecutar" )
		loForm.Show()		
		loForm.LockScreen = .T.
		loForm.DesHabilitarFormularioActivo()	
		This.Asserttrue( "Cambio el lockScreen", loForm.LockScreen )
		loForm.Release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_DeshabilitarFormularioActivoConKontrolerConEjecutar
		local loForm as FormTest of ztestServicioPantalla.prg
		loForm = newobject( "Form_Con_Kontroler_Con_Ejecutar" )
		loForm.Show()		
		loForm.LockScreen = .T.
		loForm.oKontroler.lProcesar_Funcion_Ejecutar = .T.
		loForm.lHayKontroler = .F.
		loForm.DesHabilitarFormularioActivo()
		This.Asserttrue( "No Cambio el lockScreen", !loForm.LockScreen )
		This.Asserttrue( "No Cambio el lProcesar_Funcion_Ejecutar", !loForm.oKontroler.lProcesar_Funcion_Ejecutar )
		This.Asserttrue( "No Cambio el lHayKontroler ", loForm.lHayKontroler )
		loForm.Release()
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestU_HabilitarFormularioActivoSinKontroler
		local loForm as FormTest of ztestServicioPantalla.prg
		loForm = newobject( "Form_Sin_Kontroler" )
		loForm.Show()		
		loForm.lLockScreen = .T.
		loForm.LockScreen = .F.
		loForm.lHayKontroler = .F.
		loForm.HabilitarFormularioActivo()
		This.Asserttrue( "Cambio el lockScreen", !loForm.LockScreen )
		loForm.Release()
	endfunc 	 
	*-----------------------------------------------------------------------------------------
	function ztestU_HabilitarFormularioActivoConKontroler
		local loForm as FormTest of ztestServicioPantalla.prg
		loForm = newobject( "Form_Con_Kontroler_Con_Ejecutar" )
		loForm.Show()		
		loForm.LockScreen = .F.
		loForm.lLockScreen = .T.
		loForm.oKontroler.lProcesar_Funcion_Ejecutar = .F.
		loForm.lProcesar_Funcion_Ejecutar = .T.

		loForm.lHayKontroler = .T.
		loForm.HabilitarFormularioActivo()
		This.Asserttrue( "No cambio el lockScreen", loForm.LockScreen )
		This.Asserttrue( "No Cambio el oKontroler.lProcesar_Funcion_Ejecutar", loForm.lProcesar_Funcion_Ejecutar )
		loForm.Release()
	endfunc 	 

EndDefine


*-----------------------------------------------------------------------------------------
define class FormTest as Form
	lHayKontroler = .F.
	lProcesar_Funcion_Ejecutar = .F.
	lLockScreen = .F.
	*-----------------------------------------------------------------------------------------
	function DeshabilitarFormularioActivo() as Void
		local loServicioPantalla As ServicioPantalla of ServicioPantalla.prg
		loServicioPantalla = _screen.zoo.CrearObjeto( "ServicioPantalla" )
		with loServicioPantalla
			.DesHabilitarFormularioActivo()
			This.lHayKontroler = .lHayKontroler
			.oFormulario = Null
			.Release()
		EndWith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function HabilitarFormularioActivo() as Void
		local loServicioPantalla As ServicioPantalla of ServicioPantalla.prg
		loServicioPantalla = _screen.zoo.CrearObjeto( "ServicioPantalla" )
		with loServicioPantalla
			.lHayKontroler = This.lHayKontroler
			.lLockScreen = This.lLockScreen
			.lEstadoAnterior = This.lProcesar_Funcion_Ejecutar
			.oFormulario = This
			.HabilitarFormularioActivo()
			.Release()
		EndWith
	endfunc 
enddefine
*-----------------------------------------------------------------------------------------
define class Form_Con_Kontroler_Con_Ejecutar as FormTest of ztestServicioPantalla.prg
	oKontroler = Null
	function init
		This.oKontroler = newobject( "Custom" )
		This.oKontroler.AddProperty( "lProcesar_Funcion_Ejecutar", .F. )
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class Form_Con_Kontroler_Sin_Ejecutar as FormTest of ztestServicioPantalla.prg
	oKontroler = Null
	function init
		This.oKontroler = newobject( "Custom" )
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class Form_Sin_Kontroler as FormTest of ztestServicioPantalla.prg
enddefine
