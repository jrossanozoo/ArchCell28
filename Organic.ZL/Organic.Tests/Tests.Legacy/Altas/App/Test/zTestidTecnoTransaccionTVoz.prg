**********************************************************************
Define Class zTestidTecnoTransaccionTVoz as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestidTecnoTransaccionTVoz of zTestidTecnoTransaccionTVoz.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerValorSugeridoTecnoVoz
		local loLibrerias as librerias of librerias.prg, lcTexto as String 
		local lcTexto as string, lcRutaParametro as string, lcCadenaArchivo as String, ;
		lcCadenaArchivoIni as String, lcRutaIni as String   
		
		store '' to lcTexto  
		
text to lcCadenaArchivo noShow
\TECNOVOZ\TBL\RECSAMP7
19442
I
  Serie: 501795 // R. Social: 05374-Esposito Andrea Graciela; // Cliente: 01462-Grisino Ramos Mejia
0
20081002
16212801
004



VIR
7
374136001
1144645061
8100

0

endtext 

	   lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "Pos006.dat"

	   strtofile( lcCadenaArchivo, lcRutaParametro )

text to lcCadenaArchivoIni noShow
[Call-Center]
TecnoDrive=S
WsNumber=6
ACDNum=1
Extension=217
Trace=1
Address=192.168.0.22
Port=5024
;permite pasar tonos DTMF
ipcall=yes
CallAlert=0
endtext 

	   lcRutaIni =  addbs( _screen.zoo.obtenerrutatemporal() ) + "archivoini.ini"

	   strtofile( lcCadenaArchivoIni , lcRutaIni )

	   goparametros.zl.teCNOVOZ.ruTAARCHIVOTECNOVOZ = alltrim(lcRutaIni)
	   goregistry.zl.teCNOVOZ.sECCION = 'Call-Center'
	   goregistry.zl.tECNOVOZ.ENTRADA = 'WsNumber'
	   goparametros.zl.tECNOVOZ.RUTAARCHIVOPUESTO = addbs( _screen.zoo.obtenerrutatemporal() )
	   goparametros.zl.teCNOVOZ.nUMEROLINEASERIE = 4
	   goparametros.zl.teCNOVOZ.pOSICIONDESDESERIE = 10
	   goparametros.zl.teCNOVOz.loNGITUDNUMEROSERIE = 6

	   loApp = _Screen.zoo.crearobjeto( "ItemMdaincmdaDetalletransacciones", "ItemMdaincmdaDetalletransacciones.prg" )
	   lcTexto = loApp.ObtenerValorSugeridoTecnoVoz()

	   this.assertequals( "El numero de serie esperado es el 501795", "501795", upper( alltrim( lcTexto ) ) ) 

	endfunc 
EndDefine
