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
Define Class BARRAESTADOGRILLAEXTProxy as barraestadogrillaext of Barraestadogrillaext.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'BARRAESTADOGRILLAEXT'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'barraestadogrillaext.fxp'
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
Define Class CABECERASUBGRUPOProxy as cabecerasubgrupo of Cabecerasubgrupo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CABECERASUBGRUPO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'cabecerasubgrupo.fxp'
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
Define Class CAMPOCLAVENUMERICAProxy as campoclavenumerica of Campoclavenumerica.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCLAVENUMERICA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campoclavenumerica.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CAMPOCODIGOVALORProxy as campocodigovalor of Campocodigovalor.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCODIGOVALOR'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campocodigovalor.fxp'
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
Define Class CAMPOCOMBOXMLIMPUESTOProxy as campocomboxmlimpuesto of Campocomboxmlimpuesto.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOCOMBOXMLIMPUESTO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campocomboxmlimpuesto.fxp'
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
Define Class CAMPOEXTGRILLAEXTProxy as campoextgrillaext of Campoextgrillaext.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CAMPOEXTGRILLAEXT'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'campoextgrillaext.fxp'
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
Define Class CARACTERSOLONUMEROSProxy as caractersolonumeros of Caractersolonumeros.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CARACTERSOLONUMEROS'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'caractersolonumeros.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CLAVEProxy as clave of Clave.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CLAVE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'clave.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CODIGOCLIENTECOMPROBANTEProxy as codigoclientecomprobante of Codigoclientecomprobante.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CODIGOCLIENTECOMPROBANTE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'codigoclientecomprobante.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CODIGODESCRIPCIONProxy as codigodescripcion of Codigodescripcion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CODIGODESCRIPCION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'codigodescripcion.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CODIGOSINDESCRIPCIONProxy as codigosindescripcion of Codigosindescripcion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CODIGOSINDESCRIPCION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'codigosindescripcion.fxp'
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
Define Class COMBOCLAVEProxy as comboclave of Comboclave.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'COMBOCLAVE'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'comboclave.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class COMBOCOMBOProxy as combocombo of Combocombo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'COMBOCOMBO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'combocombo.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class COMBOXMLProxy as comboxml of Comboxml.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'COMBOXML'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'comboxml.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class COMBOXMLIMPUESTOProxy as comboxmlimpuesto of Comboxmlimpuesto.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'COMBOXMLIMPUESTO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'comboxmlimpuesto.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class CUITProxy as cuit of Cuit.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'CUIT'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'cuit.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class DESCRIPCIONProxy as descripcion of Descripcion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'DESCRIPCION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'descripcion.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class DIRECCIONProxy as direccion of Direccion.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'DIRECCION'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'direccion.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ENCABEZADOGRILLAEXTProxy as encabezadogrillaext of Encabezadogrillaext.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ENCABEZADOGRILLAEXT'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'encabezadogrillaext.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class ETIQUETADATOProxy as etiquetadato of Etiquetadato.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'ETIQUETADATO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'etiquetadato.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class FECHAProxy as fecha of Fecha.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'FECHA'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'fecha.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class FECHACALENDARIOProxy as fechacalendario of Fechacalendario.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'FECHACALENDARIO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'fechacalendario.fxp'
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
Define Class TEXTOProxy as texto of Texto.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'TEXTO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'texto.fxp'
	EndFunc

EndDefine

*------------------------------------------------------------------------------------------------------------
Define Class TITULOSUBGRUPOProxy as titulosubgrupo of Titulosubgrupo.prg

	lTieneSaltoCampo = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .F.
	lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.

	*------------------------------------------------------------------------------------------------------------
	Function Class_Access() as String 
		Return 'TITULOSUBGRUPO'
	EndFunc
	*------------------------------------------------------------------------------------------------------------
	Function ClassLibrary_Access() as String 
		Return 'titulosubgrupo.fxp'
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

