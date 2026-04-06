*--------------------------------------------------------------------------------*
* --------------- Libreria de proxy a controles para formularios --------------- *
*--------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------
Define Class PAGEFRAMEALTASProxy as pageframealtas of Pageframealtas.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'PAGEFRAMEALTAS'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'pageframealtas.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CONTENEDORSUBGRUPOProxy as contenedorsubgrupo of Contenedorsubgrupo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CONTENEDORSUBGRUPO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'contenedorsubgrupo.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class DATOSCABECERASUBGRUPOProxy as datoscabecerasubgrupo of Contenedorsubgrupo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'DATOSCABECERASUBGRUPO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'contenedorsubgrupo.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CONTENEDOREXTENSIBLEProxy as contenedorextensible of Contenedorextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CONTENEDOREXTENSIBLE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'contenedorextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOGRILLAEXTENSIBLEProxy as zoogrillaextensible of Zoogrillaextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOGRILLAEXTENSIBLE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoogrillaextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class TEXTBOXSINFOCOProxy as textboxsinfoco of Zoogrillaextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'TEXTBOXSINFOCO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoogrillaextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class TOOLTIPNUMERODEFILAProxy as tooltipnumerodefila of Zoogrillaextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'TOOLTIPNUMERODEFILA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoogrillaextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ITEMCOLUMNAGRILLAProxy as itemcolumnagrilla of Zoogrillaextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ITEMCOLUMNAGRILLA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoogrillaextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class DATOSCOLUMNAPARAACOMODARProxy as datoscolumnaparaacomodar of Zoogrillaextensible.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'DATOSCOLUMNAPARAACOMODAR'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoogrillaextensible.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class AUTOCOMPLETARProxy as autocompletar of Autocompletar.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'AUTOCOMPLETAR'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'autocompletar.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class BOTONProxy as boton of Boton.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'BOTON'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'boton.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class BOTONCONFOCOProxy as botonconfoco of Botonconfoco.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'BOTONCONFOCO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'botonconfoco.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOCARACTERProxy as campocaracter of Campocaracter.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCARACTER'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campocaracter.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOCLAVEProxy as campoclave of Campoclave.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCLAVE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campoclave.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOCOMBOXMLProxy as campocomboxml of Campocomboxml.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCOMBOXML'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campocomboxml.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPODESCRIPCIONProxy as campodescripcion of Campodescripcion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPODESCRIPCION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campodescripcion.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOFECHAProxy as campofecha of Campofecha.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOFECHA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campofecha.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPONUMERICOProxy as camponumerico of Camponumerico.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPONUMERICO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'camponumerico.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOSINOBOOLProxy as camposinobool of Camposinobool.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOSINOBOOL'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'camposinobool.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CARACTERProxy as caracter of Caracter.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CARACTER'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'caracter.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CODIGOVENDEDORProxy as codigovendedor of Codigovendedor.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CODIGOVENDEDOR'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'codigovendedor.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class COMBOProxy as combo of Combo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'COMBO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'combo.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ETIQUETADATOSDOBLEProxy as etiquetadatosdoble of Etiquetadatosdoble.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ETIQUETADATOSDOBLE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'etiquetadatosdoble.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class LETRADECOMPROBANTEProxy as letradecomprobante of Letradecomprobante.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'LETRADECOMPROBANTE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'letradecomprobante.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class NUMERICOProxy as numerico of Numerico.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'NUMERICO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'numerico.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class OBSERVACIONProxy as observacion of Observacion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'OBSERVACION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'observacion.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class TOTALMULTIMONEDAProxy as totalmultimoneda of Totalmultimoneda.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'TOTALMULTIMONEDA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'totalmultimoneda.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOCOMBOBOXProxy as zoocombobox of Zoocombobox.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOCOMBOBOX'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoocombobox.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOCONTENEDORProxy as zoocontenedor of Zoocontenedor.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOCONTENEDOR'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoocontenedor.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOIMAGENProxy as zooimagen of Zooimagen.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOIMAGEN'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zooimagen.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOLABELProxy as zoolabel of Zoolabel.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOLABEL'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoolabel.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOLABELVUELTOProxy as zoolabelvuelto of Zoolabelvuelto.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOLABELVUELTO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoolabelvuelto.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ZOOLINEAProxy as zoolinea of Zoolinea.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ZOOLINEA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'zoolinea.fxp'
	EndFunc

EndDefine

