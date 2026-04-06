Define Class blankClaveLince As custom OlePublic
	name = "blankClaveLince"
	pn_Serie = 0
	pc_Version = ""
	pn_Operacion = 0
	Conexion = null
	pb_Ok = .F.
		
	Function Init()
		Store 0 To this.pn_Serie
		Store 3 To this.pn_Operacion &&hardcode temporal
		Store "" To this.pc_Version
		this.Conexion = NewObject('ADODB.Connection') 
		this.pb_Ok = .F.
	Endfunc

	Function conectSQL() AS Variant 
		local lo_Error as Exception
		try
			With this.Conexion 
				.Provider = 'SQLOLEDB' 
				.Properties("Data Source").Value = 'FLICCIARDI\SQL2008R2' 
				.Properties("Initial Catalog").Value = 'ZL' 
				.Properties("User ID").Value = 'usweb' 
				.Properties("Password").Value = 'usweb'
				.Open
			EndWith 
			THiS.pb_Ok = .T.
		catch to lo_Error 
			THIS.pb_Ok = .F.
		endtry
		return THIS.pb_Ok
	Endfunc

	Function unconectSQL()
		try
			this.Conexion.close
			this.pb_Ok = .t.
		catch
			this.pb_Ok = .F.
		endtry
		Return this.pb_Ok
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function envioOperacion() As Boolean 

		Local lcQuery As String
		Local loError as Exception
		local lsComand as Object  
		
		this.pb_Ok = .T.
		lcRetorno = ""
		
		if this.pb_Ok
			try
				this.pb_Ok = This.conectSQL()
				if this.pb_Ok
					lsComand = createobject("ADODB.Command")
					lsComand.ActiveConnection = this.Conexion
					lcQuery = this.createQuery()
					if empty(lcQuery)
						this.pb_Ok = .F.
						this.loggin('Query vacío!!!')
					else
						this.loggin('Query creado')
						lsComand.CommandText = lcQuery
						try
							lsComand.Execute
							this.pb_Ok = .T.
							this.loggin('Query ejecutado')
						catch to loError
							this.pb_Ok = .F.
							this.loggin('Falló la ejecución del query')
						endtry
					ENDIF
				endif
				this.unconectSQL()
			catch to loError
				this.pb_Ok = .F.
			endtry
		endif
		
		loError = null
		
		return this.pb_Ok

	Endfunc

	function createQuery() AS String 

		local lcQuery as String 

		lcQuery = "DECLARE	@return_value int "+chr(13)+"EXEC	@return_value = [ZL].[stp_EnvioDeClavesDeProductos]"+chr(13) ;
		+"@Serie = N'"+transform(this.pn_Serie)+"',"+chr(13)+"@Version = N'"+this.pc_Version+"',"+chr(13)+"@TipoOperacion = "+transform(this.pn_Operacion)
			
		return lcQuery
	endfunc
	
	Function Destroy()
	Return
	
	function loggin(psMensaje as String)

		=strtofile(dtoc(date()) + " " + time() + ": " + psMensaje + chr(13) + chr(10), 'C:\errores.txt', 1)

	endfunc

Enddefine
