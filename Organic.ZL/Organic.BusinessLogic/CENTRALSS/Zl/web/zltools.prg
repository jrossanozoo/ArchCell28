define class ZLTools as custom olepublic
	name = "ZLTools"
	Conexion = null
	pb_Ok = .f.
	_Provider = ""
	_DataBase = ""
	_InitialCatalog = ""
	_User = ""
	_Password = ""
	Mensaje = ''

	*-----------------------------------------------------------------------------------------
	function init()
		this.Conexion = null
		this.pb_Ok = .f.
		this._Provider = ""
		this._DataBase = ""
		this._InitialCatalog = ""
		this._User = ""
		this._Password = ""
	endfunc

	*-----------------------------------------------------------------------------------------
	function conectSQL() as Variant 
		local lo_Error as exception

		try
			this.Conexion = newobject('ADODB.Connection')
			with this.Conexion
				.Provider = 'SQLOLEDB'
				.Properties("Data Source").value = 'ZLLOPSFSI02'   &&'DATAWEB\dataweb2012' 
				.Properties("Initial Catalog").value = 'ZL'
				.Properties("User ID").value = 'blanqueo_lince'
				.Properties("Password").value = '24-05$uihDr2g0n-2013'
				.open
			endwith
			this.pb_Ok = .t.
		catch to lo_Error
			this.pb_Ok = .f.
		endtry
		return this.pb_Ok
	endfunc

	*-----------------------------------------------------------------------------------------
	function unconectSQL() as Boolean
		local lRetorno as boolean, loerror as Object   

		lRetorno = .f.

		try
			this.Conexion.close
		catch to loerror
		finally
			this.Conexion = null
		endtry
		return lRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	function blanqueoClaveLince(psVersion as string, pnSerie as number) as Variant

		local lcQuery as string, loError as exception
	
		this.pb_Ok  = .t.
		if this.pb_Ok
			try
				this.pb_Ok = this.conectSQL()
				
				if this.pb_Ok
					lcQuery = this.queryString(pnSerie, psVersion)
					if empty(lcQuery)
						this.pb_Ok = .f.
						this.Mensaje = "Error de ejecución de consulta inesperado." 
					else
						this.pb_Ok = this.ejecutarSQL(lcQuery)
					endif
				endif
			catch to loError
				this.Mensaje = "Error de conexión inesperado." 
				this.pb_Ok = .f.
			finally 
				this.unconectSQL()	
			endtry
		endif

		loError = null

		return this.Mensaje
*!*			return this.pb_Ok

	endfunc


	*-----------------------------------------------------------------------------------------
	function queryString(pnSerie as number, psVersion as string) as string

		local lcQuery as string

		lcQuery = "EXEC [ZL].[stp_EnvioDeClavesDeProductos] @Serie = N'"+transform(pnSerie)+"', @Version = N'"+psVersion +"'"  

		return lcQuery

	endfunc

	*-----------------------------------------------------------------------------------------
	function ejecutarSQL(psQuery as string) as Boolean
		local lsComand as object, lRetorno as Boolean , loError as object

		lsComand = createobject("ADODB.Command")
		lsComand.ActiveConnection = this.Conexion
		lsComand.CommandText = psQuery
		lsComand.CommandTimeout = 90 

		lRetorno = .t.

		try
			lsComand.Execute
		catch to loError
		
			this.Mensaje = this.TraducirResultado( loError )

			if left( loError.message, 2 )  = 'OK'
 				lRetorno = .t.
 			else
 				lRetorno = .f.
 			endif 
 		endtry
		return lRetorno 
	endfunc

	*---------------------------------------------
	Function TraducirResultado( toError as exception ) as VOID 
		local lcResultado as String, lnIDLogMail as number, lcConcultaResultado as String,;
			  loError as Exception, loRecordset as Object, loCursorAdapter as Object, lcCursor as String 
			  
		
		lcResultado = ''
		lcCursor = 'C' + sys( 2015 )
		lnIDLogMail = transform( strtran( ;
								strtran( ;
									strtran( alltrim( toError.Message ), 'OLE IDispatch exception code 0 from Microsoft OLE DB Provider for SQL Server: ', ''  )  ;
								, 'Mail (Id:'   , '' ) 	;
							, ') queued...' , '' ) ;
							)
						
		
		text  to lcConcultaResultado textmerge noshow 
			select CodigoDeError  from [ZL].[dbo].[logEnvioClavesProductos] 
				where mailitem_id = <<lnIDLogMail>>
		endtext 				

		loRecordset = CREATEOBJECT("adodb.recordset")

		try
			loRecordSet = this.Conexion.Execute( lcConcultaResultado )
			loCursorAdapter = CREATEOBJECT( "CursorAdapter" )
			loCursorAdapter.Alias = lcCursor
			loCursorAdapter.DataSourceType = "ADO"
			loCursorAdapter.CursorFill(,,,loRecordSet)
			loCursorAdapter.CursorDetach()
			select &lcCursor 
			go top
			lcResultado = &lcCursor..CodigoDeError 
			use in select( lcCursor )
		catch to loError	
		endtry 
		
		return lcResultado 
		
	endfunc  

	*-----------------------------------------------------------------------------------------
	function ReadXML() as Variant 
		local cRootTagName  AS String
		local oRootNode, oNodeList, oNode, oAttributeList as Object
		local nNumNodes as Number
		local lRetorno
		LOCAL oXML as "MSXML2.DOMDocument.4.0"

		lRetorno = .T.		
		oXML = CREATEOBJECT("MSXML2.DOMDocument.4.0")

		oXML.async = .F.
		oXML.load("data.xml")

		IF oXML.parseError.errorCode <> 0
		  lRetorno = .F.
		endif

		if oRootNode = oXML.documentElement THEN
		else
			return "Error a asignar contenido del XML al objeto"
			
		ENDIF

		cRootTagName = oRootNode.tagName

		oNodeList = oRootNode.getElementsByTagName("*")

		nNumNodes = oNodeList.length

		oNode = oNodeList.item(0)
		nType = oNode.nodeType

		if nType = 1
			oAttributeList = oNode.attributes
	
			cAttrValue = oAttributeList.getNamedItem("driver")
			this._Provider = cAttrValue.Value
 	
 			cAttrValue = oAttributeList.getNamedItem("host")
			this._Database = cAttrValue.Value
 	
 			cAttrValue = oAttributeList.getNamedItem("database")
			this._InitialCatalog = cAttrValue.Value
 	
 			cAttrValue = oAttributeList.getNamedItem("user")
			this._User = cAttrValue.Value
 	
 			cAttrValue = oAttributeList.getNamedItem("pass")
			this._Password = cAttrValue.Value
		else
			lRetorno = .F.
		endif
		return lRetorno
	endfunc

enddefine
