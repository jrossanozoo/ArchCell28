**********************************************************************
Define Class zTestManagerImpresionNucleo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestManagerImpresionNucleo of zTestManagerImpresionNucleo.prg
	#ENDIF
		
	*-----------------------------------------------------------------------------------------
	function Setup
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TearDown

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ChequearPorSentenciaVacia
		local lcCadena as String, loManagerImpresion as Object
		
		lcCadena = "  " + "[" + "<!>" + "]" + "/" + "  "
		loManagerImpresion = newobject( "ManagerImpresion_access" )
		with loManagerImpresion
			this.asserttrue( "No ha chequeado que es una sentencia vacía.", .EsSentenciaVacia_new(lcCadena) )
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_FiltrarCaracteresEspeciales
		local loManagerImpresion as Object, lcResultado10 as String, lcResultado13 as String, lcResultado1013 as String, lcResultado1310 as String
		
		loManagerImpresion = newobject( "ManagerImpresion_access" )
		with loManagerImpresion
			lcResultado10 = .FiltrarCaracteresEspeciales_new( "Hola" + chr(10) + "mundo." )
			lcResultado13 = .FiltrarCaracteresEspeciales_new( "Hola" + chr(13) + "mundo." )
			lcResultado1013 = .FiltrarCaracteresEspeciales_new( "Hola" + chr(10) + chr(13) + "mundo." )
			lcResultado1310 = .FiltrarCaracteresEspeciales_new( "Hola" + chr(13) + chr(10) + "mundo." )
		endwith
		
		this.assertequals( "No se filtra el chr(10).", "Hola]+chr(13)+chr(10)+[mundo.", lcResultado10 )
		this.assertequals( "No se filtra el chr(13).", "Hola]+chr(13)+chr(10)+[mundo.", lcResultado13 )
		this.assertequals( "No se filtra el chr(10)+chr(13).", "Hola]+chr(13)+chr(10)+[mundo.", lcResultado1013 )
		this.assertequals( "No se filtra el chr(13)+chr(10).", "Hola]+chr(13)+chr(10)+[mundo.", lcResultado1310 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_CambiarCantidadParaImpresionAPuerto() as 
		local loManager as Object, loResultado as String 
		_screen.mocks.agregarmock( "DISENOIMPRESION" )
		_screen.mocks.AgregarSeteoMetodo( 'disenoimpresion', 'Cargamanual', .T. )		
		
		loEntidad = _screen.zoo.instanciarentidad( "disenoimpresion" )
		loEntidad.columnas = 2
		loManager = _screen.zoo.crearobjeto( "managerimpresion" )
		loManager.oDisenoImpresion = loEntidad
		loManager.oColumnaNumerarPorCombinacion = _screen.zoo.crearobjeto("ZooColeccion")
		
		loResultado = loManager.CambiarCantidadParaImpresionAPuerto( "ALLTRIM(STR(.CANTIDAD))" )	
		this.assertequals( "Error en la sustitución 1.", "ALLTRIM(STR(ceiling(.CANTIDAD/2)))", loResultado )
		
		loEntidad.columnas = 0
		
		loResultado = loManager.CambiarCantidadParaImpresionAPuerto( "ALLTRIM(STR(.CANTIDAD))" )
		this.assertequals( "Error en la sustitución 2.", "ALLTRIM(STR(ceiling(.CANTIDAD/1)))", loResultado )
		
		loResultado = loManager.CambiarCantidadParaImpresionAPuerto( "PRUEBA" )
		this.assertequals( "Error en la sustitución 3.", "PRUEBA", loResultado )
		
		loManager.oColumnaNumerarPorCombinacion.Agregar(7)
		loResultado = loManager.CambiarCantidadParaImpresionAPuerto( "PQ#.CANTIDAD" )
		this.assertequals( "Error en la sustitución 4.", "PQ#1", loResultado )
		
		loManager.oColumnaNumerarPorCombinacion.release()
		loEntidad.release()
		loManager.release()
				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_EnviarAPuerto() as Void
		local loManager as Object 
		
		loManager = _screen.zoo.crearobjeto( "managerimpresion" )		
		loManager.EnviarAPuerto( "prueba.txt", "prueba impresion" )
		loResultado = filetostr( "prueba.txt")
		this.assertequals( "Error en el envío a puerto", loResultado, "prueba impresion" )
		delete file "prueba.txt"
		loManager.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestGenerarPdfSegundoPlanoDesdeElMenu
		local loManager as ManagerImpresion of ManagerImpresion.prg
		
		_screen.mocks.agregarmock( "ConectorAgenteDeAccionesOrganic" )	
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Obtenerdisponibilidadaao', 3 )
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Enviainstrucciones', .T., "'*OBJETO'" )

		_screen.mocks.agregarmock( "AccionEnSegundoPlano" )
		_screen.mocks.AgregarSeteoMetodo( 'AccionEnSegundoPlano', 'Enviar', .T. )
		loAccion = _screen.zoo.crearobjeto( "AccionEnSegundoPlano" )
		loAccion.oParametros = _screen.zoo.crearobjeto( "Zoocoleccion" )

		_screen.mocks.agregarmock( "FactoryAccionEnSegundoPlano" )
		_screen.mocks.AgregarSeteoMetodo( 'FactoryAccionEnSegundoPlano', 'Obtener', loAccion, "[GeneracionPdf]" )

		loCol = _screen.zoo.crearobjeto( "Zoocoleccion" )
		loCol.Agregar( "1", "1" )
		_screen.mocks.agregarmock( "ParametrosInstruccionesGeneracionPdf" )	
		_screen.mocks.AgregarSeteoMetodo( 'PARAMETROSINSTRUCCIONESGENERACIONPDF', 'Obtener', loCol, "'*OBJETO',[Codigo12]" ) && ztestmanagerimpresionnucleo.ztestgenerarpdfsegundoplanodesdeelmenu 22/02/16 11:34:22
		loManager = newobject( "ManagerImpresion_Real" )
		loEntidad = _screen.zoo.instanciarEntidad( "francia" )

		loManager.GenerarPdfEnSegundoPlano_New( loEntidad, "Codigo12" )

		_screen.mocks.verificarejecuciondemocks( "AccionEnSegundoPlano" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SetearImpresoraAReporte() as Void
		local loManager as object, lcNombreArchivo as String, loReporte as Object, lcImpresora as String
		loManager = newobject( "ManagerImpresion_Real" )
		lcNombreArchivo = addbs( _screen.zoo.CRUTAINICIAL ) +"clasesdeprueba\lis_listado5salida.rpt"
		loReporte = loManager.FK_AbrirReporte( lcNombreArchivo )
		lcImpresora = loManager.FK_ObtenerImpresoraPredeterminada()
		loManager.FK_SetearImpresoraAReporte( loReporte, lcImpresora )
		this.assertequals("No se seteo correctamente la impresora en el reporte", lcImpresora, loReporte.PrinterName )
		try 
			loManager.FK_SetearImpresoraAReporte( loReporte, "IMPresoraError" )
			this.asserttrue(" Debe dar error por intentar setear una impresora inexistente", .f. )
		catch to loError
		endtry
		 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAgregarNroSecuencial
		local loManager as object, lcLinea as String, lcCantidad as Integer, lcValorEsperado as Separator

		loManager = _screen.zoo.crearobjeto( "Fake_managerimpresion", "ztestmanagerimpresionnucleo.prg" )
		loManager.oEntidadImprimir.EtiquetaDetalle.Sum_Cantidad = 3
		lcLinea = "[Art1]<!> [VE]<!> [VERDE]<!> [S]<!> [*A1!VE!S!ØØØØØ*][*A1!VE!S!ØØØØØ*][*A1!VE!S!ØØØØØ*]"
		lcCantidad = "ØØØØØ"
		lcValorEsperado = "[Art1]<!> [VE]<!> [VERDE]<!> [S]<!> [*A1!VE!S!01695*][*A1!VE!S!01695*][*A1!VE!S!01695*]"

		this.assertequals("El valor no es el esperado", lcValorEsperado, loManager.AgregarNroSecuencial( lcLinea, lcCantidad ) )

		loManager.nUltimoNroSecuencial = 0
		this.assertequals("El valor no es el esperado", lcValorEsperado, loManager.AgregarNroSecuencial( lcLinea, lcCantidad, 3 ) )

		loManager.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAgregarCheckSumACodigoConSecuencial
		local loManager as object, lcLinea as String, lcValorEsperado as Separator

		loManager = _screen.zoo.crearobjeto( "Fake_managerimpresion", "ztestmanagerimpresionnucleo.prg" )		

		lcLinea = "[Art1]<!> [VE]<!> [VERDE]<!> [S]<!> [*A1!VE!S!01816*]"
		lcValorEsperado = "[Art1]<!> [VE]<!> [VERDE]<!> [S]<!> [ˆA1!VE!S!01816YŠ]"
		
		this.assertequals("El valor no es el esperado", lcValorEsperado, loManager.AgregarCheckSumACodigoConSecuencial( lcLinea ) )

		loManager.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarImpresoraDePuesto
		local loManager as object
		
		loManager = _screen.zoo.crearobjeto( "Fake_managerimpresion", "ztestmanagerimpresionnucleo.prg" )		

		loManager.Fake_ValidarImpresoraDePuesto( sys(2015) )

		this.asserttrue("Debería haber pasado por el método 'ObtenerImpresoraMasSimilar'", loManager.lPasoPorMetodoObtenerImpresoraMasSimilar )

		loManager.release()		

	endfunc 


enddefine


*-----------------------------------------------------------------------------------------
Define Class ManagerImpresion_access as DatosArea OF ManagerImpresion.prg

	*-----------------------------------------------------------------------------------------
	function EsSentenciaVacia_new( tcCadena as String ) as Boolean
		return this.EsSentenciaVacia( tcCadena )
	endfunc

	*-----------------------------------------------------------------------------------------
	function FiltrarCaracteresEspeciales_new( tcCadena as String ) as String
		return this.FiltrarCaracteresEspeciales( tcCadena )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarPdfEnSegundoPlano_New( tcEntidad as String, tcCodigo as String ) as Void
		this.GenerarPdfSegundoPlano( tcEntidad , tcCodigo )
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
Define Class ManagerImpresion_Real as ManagerImpresion OF ManagerImpresion.prg

	*-----------------------------------------------------------------------------------------
	function GenerarPdfEnSegundoPlano_New( tcEntidad as String, tcCodigo as String ) as Void
		this.GenerarPdfSegundoPlano( tcEntidad , tcCodigo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FK_AbrirReporte( tcReporte as String ) as Object
		return this.AbrirReporte( tcReporte )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FK_SetearImpresoraAReporte( toReporte as Object, tcImpresora as String ) as Void
		return this.SetearImpresoraAReporte( toReporte, tcImpresora )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FK_ObtenerImpresoraPredeterminada() as Void
		return this.ObtenerImpresoraPredeterminada()
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Fake_managerimpresion as Managerimpresion of Managerimpresion.prg
	lPasoPorMetodoObtenerImpresoraMasSimilar = .F.
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.oEntidadImprimir = newobject( "Fake_Entidad", "ztestmanagerimpresionnucleo.prg" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Funcionalidades_Access() as variant
		if !this.ldestroy and ( !vartype( this.Funcionalidades ) = 'O' or isnull( this.Funcionalidades ) )
			this.Funcionalidades = newobject( "Fake_Funcionesimpresionfelino", "ztestmanagerimpresionnucleo.prg" )
		endif
		return this.Funcionalidades

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Fake_ValidarImpresoraDePuesto( tcImpresora as string ) as String
		local lcRetorno as String
		lcRetorno = this.ValidarImpresoraDePuesto ( tcImpresora )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImpresoraMasSimilar( tcImpresora as string ) as String
		this.lPasoPorMetodoObtenerImpresoraMasSimilar = .T.
		return dodefault( tcImpresora )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Fake_Funcionesimpresionfelino as custom
	cCaracterDeRellonoSecuencial = "Ø"
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoSecuencial( lnCantidadAReservar ) as integer
		return 1694
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSecuencial( tnCantDigSecuencial as Integer, tnNroSecuencial as Integer ) as string
		return "01695"
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Fake_Entidad as Custom

	EtiquetaDetalle = null
	
	*-----------------------------------------------------------------------------------------
	function init() as Void

		this.EtiquetaDetalle = newobject("custom")
		this.EtiquetaDetalle.AddProperty("Sum_Cantidad", 0)

	endfunc 

enddefine
