**********************************************************************
Define Class zTestEspecificacionMonitorQA As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestEspecificacionMonitorQA Of zTestEspecificacionMonitorQA.prg
	#Endif

	*---------------------------------
	Function zTestClase_Mensajes
		local lcFirma as string, lcOk as String
			
		this.asserttrue( "La propiedad MENSAJES del objeto _Screen.zoo.oServicios no existe. Es necesario para el monitor QA ", ;
			pemstatus( _screen.zoo.oServicios, "mensajes", 5 ) )

		lcFirma = ObtenerFirma( _Screen.zoo.oServicios.Mensajes, "SeteaFormMensaje" )
		lcOk = "function seteaformmensaje( t1 as variant, t2 as variant, t3 as variant, t4 as variant, t5 as variant ) as void"
		
		this.assertequals( "El metodo SETEAFORMMENSAJE de la clase MENSAJES no existe o la firma es incorrecta. Es necesario para el monitor QA", lcOk, lcFirma ) 
	Endfunc

	*---------------------------------
	Function zTestClase_FormInformacion
		local lcFirma as string, lcOk as String
	
		lcFirma = ObtenerFirma( "formInformacion", "FormatearMensaje" )
		lcOk = "function formatearmensaje( tvmensaje as variant ) as void"

		this.assertequals( "El metodo FORMATEARMENSAJE de la clase FORMINFORMACION no existe o la firma es incorrecta. Es necesario para el monitor QA", lcOk, lcFirma ) 
	Endfunc

	*---------------------------------
	Function zTestClase_ManagerEjecucion
		local lcFirma as string, lcOk as String

		this.asserttrue( "La propiedad EJECUCION del objeto _Screen.zoo.oServicios no existe. Es necesario para el monitor QA ", ;
			pemstatus( _screen.zoo.oServicios, "Ejecucion", 5 ) )

		lcFirma = ObtenerFirma( _Screen.zoo.oServicios.Ejecucion, "CerrarEjecuciones" )
		lcOk = "function cerrarejecuciones() as void"
		
		this.assertequals( "El metodo CERRAREJECUCIONES de la clase EJECUCION no existe o la firma es incorrecta. Es necesario para el monitor QA", lcOk, lcFirma ) 
	Endfunc

	*---------------------------------
	Function zTestClase_ServiciosAplicacion
		lcFirma = ObtenerFirma( _Screen.zoo.oServicios, "AsignarServicios" )
		lcOk = "function asignarservicios() as void"
		
		this.assertequals( "El metodo ASIGNARSERVICIOS de la clase SERVICIOSAPLICACION no existe o la firma es incorrecta. Es necesario para el monitor QA", lcOk, lcFirma ) 
	Endfunc

	*---------------------------------
	Function zTestClase_Zoo
		this.asserttrue( "El metodo DESTROY de la clase ZOO no existe o la firma es incorrecta. Es necesario para el monitor QA", ;
			pemstatus( _screen.zoo, "Destroy", 5 ) )

		this.asserttrue( "El metodo CREAROBJETO de la clase ZOO no existe o la firma es incorrecta. Es necesario para el monitor QA ", ;
			pemstatus( _screen.zoo, "CrearObjeto", 5 ) )

		this.asserttrue( "La propiedad OSERVICIOS del objeto _Screen.Zoo no existe. Es necesario para el monitor QA ", ;
			pemstatus( _screen.zoo, "oServicios", 5 ) )
	endfunc
	
	*---------------------------------
	Function zTestClase_AplicacionBase
		lcFirma = ObtenerFirma( _Screen.zoo.app, "CrearFormPrincipal" )
		lcOk = "function crearformprincipal() as void"
		
		this.assertequals( "El metodo CREARFORMPRINCIPAL de la clase APLICACIONBASE no existe o la firma es incorrecta. Es necesario para el monitor QA", lcOk, lcFirma ) 
	endfunc

	*---------------------------------
	Function zTestClase_FormTransferencias
		local loForm 
		
		loForm = _screen.zoo.crearobjeto( "Frm_FrmTransferenciasEstilo2" )
		this.assertequals( "El form de seleccion de transferencias no contiene un arbol", "O", type( "loForm.oArbol" ) ) 
		this.assertequals( "El form de seleccion de transferencias no contiene un arbol", "O", type( "loForm.oArbol.Nodes" ) ) 
		this.assertequals( "El form de seleccion de transferencias no contiene un arbol", "Olecontrol", loForm.oArbol.class ) 
	endfunc

	*---------------------------------
	Function zTestClase_FormListados
		local loForm 
		
		loForm = _screen.zoo.crearobjeto( "Frm_FrmListadosEstilo2" )
		this.assertequals( "El form de seleccion de Listados no contiene un arbol", "O", type( "loForm.oArbol" ) ) 
		this.assertequals( "El form de seleccion de Listados no contiene un arbol", "O", type( "loForm.oArbol.Nodes" ) ) 
		this.assertequals( "El form de seleccion de Listados no contiene un arbol", "Olecontrol", loForm.oArbol.class ) 
	endfunc

	*---------------------------------
	Function zTestClase_FormExportaciones
		local loForm 
		
		loForm = _screen.zoo.crearobjeto( "Frm_FrmExportacionesEstilo2" )
		this.assertequals( "El form de seleccion de Exportaciones no contiene un arbol", "O", type( "loForm.oArbol" ) ) 
		this.assertequals( "El form de seleccion de Exportaciones no contiene un arbol", "O", type( "loForm.oArbol.Nodes" ) ) 
		this.assertequals( "El form de seleccion de Exportaciones no contiene un arbol", "Olecontrol", loForm.oArbol.class ) 
	endfunc

	*---------------------------------
	Function zTestClase_FormImportaciones
		local loForm 
		
		loForm = _screen.zoo.crearobjeto( "Frm_FrmImportacionesEstilo2" )
		this.assertequals( "El form de seleccion de Importaciones no contiene un arbol", "O", type( "loForm.oArbol" ) ) 
		this.assertequals( "El form de seleccion de Importaciones no contiene un arbol", "O", type( "loForm.oArbol.Nodes" ) ) 
		this.assertequals( "El form de seleccion de Importaciones no contiene un arbol", "Olecontrol", loForm.oArbol.class ) 
	endfunc
Enddefine

*-----------------------------------------------------------------------------------------
function ObtenerFirma( txClase as variant, tcMetodo as String ) as String
	local lcRetorno as String , loObj as object
	
	lcRetorno  = ""
	
	if vartype( txClase ) = "O"
		lcRetorno = ObtenerFirmaDeUnObjeto( txClase, tcMEtodo )
	else
		loObj = _Screen.zoo.crearobjeto( txClase )
		try
			lcRetorno = ObtenerFirmaDeUnObjeto( loObj , tcMEtodo )
		finally
			try
				loObj.release()
			catch
			endtry
			
			loObj = null
		endtry	
	endif
	
	return lcRetorno 
endfunc
	
*-----------------------------------------------------------------------------------------
function ObtenerFirmaDeUnObjeto( toObj as object, tcMetodo as String ) as Void
	local i as Integer, lcRetorno as string
	local array loMiembros[1]
	
	lcRetorno = ""
	AMEMBERS( loMiembros, toObj, 3 )
		
	i = int(ascan( loMiembros, upper( tcMetodo ), 1, 0, 1 ) / 4 )
	if i > 0
		lcRetorno = loMiembros[ i + 1, 3 ]
	endif

	return strtran( alltrim( lower( lcRetorno ) ), chr(9), "" )
endfunc 
