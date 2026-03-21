Define Class ZooException As Exception

	#if .f.
		local this as ZooException of ZooException.prg
	#endif

	**el atributto lPrimero idncia si es la primera vez que se va a grabar la excepcion
	hidden lPrimero, cTab
	lPrimero = .t.
	cTab = "          "
	
	Details = ""
	ErrorNo = 0
	LineContents = ""
	Lineno = 0
	Message = ""
	Procedure = ""
	StackLevel = 0
	cStackInfo = ""
	nZooErrorNo = 0
*	Program = ""
	lEsValidacion = .f.
	oInformacion = null
	
	ProgramActual = ""
	ProcedureActual = ""
	LinenoActual = 0
	LineContentsActual = ""
	
	*-----------------------------------------------------------------------------------------
	Function Grabar( toError As Object ) As Void
		local loErrorAux as Exception, lcError as string
		
		With This
			.IniciarAtributos( toError )
			.SetearAtributos( toError )

			if this.nZooErrorNo # 9001
				.Logerror()
			endif
		
			**esto siempre tiene que estar ultimo
			.lPrimero = .f.
		endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function EsPrimerGrabacion() as Void
		return this.lPrimero
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTabulacionActual() as string
		local lcTab as string
		
		if this.lPrimero
			lcTab = ""
		else
			lcTab = this.cTab 
		endif

		return lcTab
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Si no se envia una excepcion por parametro en el GRABAR entonces estos datos son los que importan
	protected function IniciarAtributos( toError as Exception ) as Void
		Local lnI as integer, lnStackLevel As Integer
		local array laStackArray[ 1 ]

		with this
			*El numero de error nZooErrrorNo no es el de la excepcion original porque se puede cambiar en el burbujeo
			if Vartype( toError ) = "O" and vartype( toError.UserValue ) = "O" 
				if pemstatus( toError.UserValue, "nZooErrorNo" ,5 )
					.nZooErrorNo = toError.UserValue.nZooErrorNo
				endif
			endif
		
			.ErrorNo = iif( empty( .ErrorNo ), 2071, .ErrorNo )
			.Details = iif( empty( .Details ), "Error Generado Manualmente" ,.Details )
			
			lnStackLevel = Astackinfo( laStackArray )
			lnI = .ObtenerIndicePrograma( @laStackArray, lnStackLevel )

			.ProcedureActual = iif( empty( .ProcedureActual ), lower( program( lnI ) ), .ProcedureActual )
			.ProgramActual = justfname( lower( laStackArray[ lnI, 4 ] ) )
			.LinenoActual = laStackArray[ lnI, 5 ]
			.LineContentsActual = Alltrim( Strtran( laStackArray[ lnI, 6 ], Chr( 9 ), ""  ) )

			.Procedure = .ProcedureActual
*			.Program = .ProgramActual
			.Lineno = .LinenoActual 
			.LineContents = .LineContentsActual 

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIndicePrograma( taStackArray, tnStackLevel ) as Void
		Local lnStackLevel As Integer, lnI as integer, lcTexto as string
		external array taStackArray

		with this
			for lnI = tnStackLevel to 1 step - 1
*				lcTexto = lower( taStackArray[ lni, 4 ] )
				lcTexto = lower( taStackArray[ lni, 3 ] )
				if !( "managererrores" $ lcTexto ) and !( "zooexception" $ lcTexto )
					exit
				endif
			endfor
		endwith
		
		return lnI
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Si se envio una excepcion en el GRABAR debe pizar los datos de la zooexcepcion con los datos de la excepcion que inicializo el burbujeo del error
	protected function SetearAtributos( toError as Exception ) as void
		local lcStackActual as String, lcStackInfo as string
		
		with this
			If Vartype( toError ) = "O"
				* Elimino los "User thrown errors" y me quedo con el error "original"
				Do While Vartype( toError.UserValue ) = "O"
					toError = toError.UserValue

					if pemstatus( toError, "EsPrimerGrabacion" ,5 ) and !toError.EsPrimerGrabacion()
						.lPrimero = .f.
					endif
				enddo
				.Details = toError.Details
				.ErrorNo = toError.ErrorNo
				.Message = toError.Message
				.StackLevel = toError.StackLevel
				.Lineno = toError.Lineno
				.LineContents = toError.LineContents
				.procedure = toError.procedure

				if pemstatus( toError, "cStackInfo" ,5 ) and !empty( toError.cStackInfo )
					lcStackInfo = toError.cStackInfo
				endif

				if pemstatus( toError, "lEsValidacion", 5 )
					.lEsValidacion = toError.lEsValidacion 
				endif
				
				if pemstatus( toError, "TengoInformacion", 5 ) and toError.TengoInformacion()
					.oInformacion = toError.oInformacion
				endif
			Endif

			lcStackActual = .ObtenerStack()
			if empty( lcStackInfo )
				lcStackInfo =  lcStackActual 
			endif
			.cStackInfo = lcStackInfo
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerInformacionDelError( tlSinStack as Boolean ) as String 
		Local lcError As String, lcEnter As String, lcTab as string

		lcTab = this.ObtenerTabulacionActual()
		lcEnter = Chr( 13 ) + chr( 10 )

		With This
			lcError = lcEnter + lcTab + "*********** ERROR ***********" 


			*** mrusso: Se pone programa dESCONOCIDO debido a que no se encontró la manera de obtener el PRG del cual nace la excepcion y
			*** al no aparecer el program daba a interpretaciones erradas
			***	
			lcError = lcError + lcEnter + this.ExcepcionToString( this )

			if .TengoInformacion()
				lcError = lcError + lcTab + "******** INFORMACION ********" + ;
									lcTab + this.ObtenerTextoInformacion() + lcEnter
			endif
			
			if tlSinStack
			else
				lcError = lcError + lcTab + "*********** STACK ***********" 
				lcError = lcError + lcEnter + ; 
					lcTab + [StackInfo: ] + Alltrim( .cStackInfo ) + lcEnter
			endif
		Endwith

		Return ( lcError )
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTextoInformacion() as string
		local lcRetorno as string, lcError As String, lcEnter As String, lcTab as string

		lcTab = this.ObtenerTabulacionActual()
		lcEnter = Chr( 13 ) + chr( 10 )
		lcRetorno = strtran( this.oInformacion.SerializarInformacion(), lcEnter, lcEnter + lcTab )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Logerror() as Void
		Local lcError As String, loLog as Object, lcRuta as String, lcEnter As String, lcTab as string, ;
			lcErrorAux as string


		lcTab = this.ObtenerTabulacionActual()
		lcEnter = Chr( 13 ) + chr( 10 )
		lcCabecera = lcEnter + lcTab + Replicate( "*", 80 )
		loLog = null
		lcError = this.ErrorToString( !this.lPrimero )
		
		if vartype( goServicios ) = 'O' &&and vartype( goServicios.Logueos ) = "O"
			try
				if goservicios.SeDebeLoguear()
					lcError = lcCabecera + lcError
					loLog = goServicios.Logueos.ObtenerObjetoLogueo( This )
					loLog.Escribir( lcError )
					goServicios.Logueos.guardar( loLog )
				endif
			catch to loErrorAux
				lcErrorAux = lcError + lcEnter + this.ExcepcionToString( loErrorAux )
				this.LogerrorManual( lcErrorAux )
			finally
				if !isnull(loLog) and vartype(loLog)="O"
					loLog.release
				endif
			endtry
		else
			this.LogerrorManual( lcError )
		endif

	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ExcepcionToString( toErrorAux as Exception ) as string
		local lcRetorno as string, lcTab as String, lcEnter as string

		lcTab = this.ObtenerTabulacionActual()
		lcEnter = Chr( 13 ) + chr( 10 )
		
		with toErrorAux
			lcRetorno = lcTab + [Nº Error: ] + Alltrim( Transform( .ErrorNo ) ) + lcEnter + ;
				lcTab + [Programa: ] + iif( empty( .Procedure ), "", "Desconocido" ) + lcEnter + ;
				lcTab + [Procedimiento: ] + Alltrim( .Procedure ) + lcEnter + ;
				lcTab + [Message: ] + Alltrim( .Message ) + lcEnter + ;
				lcTab + [LineNo: ] + Transform( .Lineno ) + lcEnter + ;
				lcTab + [Details: ] + Alltrim( .Details ) + lcEnter + ;
				lcTab + [LineContents: ] + Alltrim( .LineContents ) + lcEnter + ;
				lcTab + [StackLevel: ] + Transform( .StackLevel ) + lcEnter
		endwith
	
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LogerrorManual( tcError as string ) as Void
		local lcCabecera as String, lcError as String, lcTab as String, lcEnter as string
		
		if type( "_screen.zoo.cRutaInicial" ) == "C"
			if empty( "tcError" )
				lcError = ""
			else
				lcError = tcError
			endif
			
			lcTab = this.ObtenerTabulacionActual()
			lcEnter = Chr( 13 ) + chr( 10 )
			lcCabecera = lcEnter + lcTab + Replicate( "*", 80 )
			
			lcCabecera = lcCabecera + lcEnter ;
				+ lcTab + [Date: ] + Alltrim( Transform( Date(), "@D" ) ) + lcEnter ;
				+ lcTab + [Time: ] + Alltrim( Time() )
			lcError = lcCabecera + lcError

			lcRuta = addbs( alltrim( _screen.zoo.cRutaInicial ) ) + "Log"
			this.CrearRutaLogueo( lcRuta )
			Strtofile( lcError, lcRuta + "\Log.err", 1 )
		endif 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ErrorToString( tlSinStack ) as Void
		Local lcRetorno As String, lcEnter As String, lcTab as string

		lcTab = this.ObtenerTabulacionActual()
		lcEnter = Chr(13) + chr( 10 )

		lcRetorno = lcEnter + lcTab + [Programa: ] + Alltrim( this.programActual ) + lcEnter + ;
					lcTab + [Procedimiento: ] + Alltrim( this.ProcedureActual ) + lcEnter + ;
					lcTab + [Nº Linea: ] + transform( this.LinenoActual ) + lcEnter + ;
					This.ObtenerInformacionDelError( tlSinStack ) + ;
					lcTab + Replicate( "*", 80 ) + lcEnter 

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearRutaLogueo( tcRuta as String ) as Void
		if directory( tcRuta )
		else 
			md ( tcRuta )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Throw()
		Throw This
	endfunc

	*-----------------------------------------------------------------------------------------		
	function TengoInformacion() as Boolean
		with this
			return vartype( .oInformacion ) = "O" and !isnull( .oInformacion );
				and upper( .oInformacion.class ) = "ZOOINFORMACION" and .oInformacion.count > 0 
		endwith
	endfunc 

	*---------------------------------------------------------------------------------------------------------------------------------------------------------
	function ExceptionToInformacion( toInformacion as zooinformacion of zooinformacion.prg ) as Void
		toInformacion.AgregarInformacion( This.Message, This.ErrorNO )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as variant
		with this
			if !vartype( .oInformacion ) = 'O' and isnull( .oInformacion )
				*** 03/06/2010 mrusso: Se sacó _screen.zoo.crearobjeto ya que si el ZOO da error
				.oInformacion = newobject( "ZooInformacion", "ZooInformacion.prg" )
			endif
		endwith
		return this.oInformacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarInformacion( tcInformacion as String, tnNumero as Integer, txInfoExtra as Variant ) as Void
		do case
		case pcount() = 1
				this.oInformacion.AgregarInformacion( tcInformacion )
		case pcount() = 2
				this.oInformacion.AgregarInformacion( tcInformacion, tnNumero )
		case pcount() = 3
			this.oInformacion.AgregarInformacion( tcInformacion, tnNumero, txInfoExtra )
		otherwise
			assert pcount() = 0 message "Llamaron al AgregarInformacion del zooSession con parametros incorrectos"
		endcase
	endfunc 	
	*-----------------------------------------------------------------------------------------
	function ObtenerInformacion() as zooInformacion of zooInformacion.prg
		return this.oInformacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarInformacion( toInformacion as zooInformacion of zooInformacion.prg ) as VOID
		local lnCont as Integer
		with toInformacion
			for lnCont = 1 to toInformacion.Count
				This.AgregarInformacion( .item[ lnCont ].cMensaje, .item[ lnCont ].nNumero , .item[ lnCont ].xInfoExtra )
			endfor
		endwith		
		toInformacion.Limpiar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStack() as String
		local lcEnter as String, lcStackInfo as String, i as Integer, lcTab as string
		Local Array laStackArray[1]

		lcTab = this.ObtenerTabulacionActual()
		lnStackLevel = Astackinfo( laStackArray ) - 1
		
		lcEnter = Chr(13) + chr( 10 )
		lcStackInfo = lcEnter
		For i = lnStackLevel To 1 Step -1
			*	Array 	Element Description
			*	1 		Call Stack Level
			*	2 		Current program filename
			*	3 		Module or Object name
			*	4 		Module or Object Source filename
			*	5 		Line number in the object source file
			*	6 		Source line contents
			lcStackInfo = lcStackInfo + lcTab + [ * Niv: ] + Transform( laStackArray[ i,1 ], "9999" )
			lcStackInfo = lcStackInfo + [ Mét: ] + Alltrim( laStackArray[ i, 3 ] )
			lcStackInfo = lcStackInfo + [ Prog: ] + justfname( Alltrim( laStackArray[ i, 4 ] ) )
			lcStackInfo = lcStackInfo + [ Lín: ] + Alltrim( Transform( laStackArray[ i, 5 ] ) ) + " "
			lcStackInfo = lcStackInfo + Alltrim( Strtran( laStackArray[ i, 6 ], Chr( 9 ), "" ) ) + lcEnter
		Endfor			

		return lcStackInfo
	endfunc 

Enddefine
