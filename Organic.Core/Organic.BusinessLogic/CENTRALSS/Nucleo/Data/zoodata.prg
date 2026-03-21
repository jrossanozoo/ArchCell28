Define Class ZooData As ZooSession Of ZooSession.prg

	#IF .f.
		Local this as ZooData of ZooData.prg
	#ENDIF

	Datasession = 1
	
	cAgregaRuta = ""
	cRutaTablas = ""

	*-----------------------------------------------------------------------------------------
	function cRutaTablas_Access() as Void
		if !this.lDestroy
			if empty( _screen.zoo.app.cSucursalActiva )
				this.cRutaTablas = ""
			else
				this.cRutaTablas = _screen.zoo.app.ObtenerRutaSucursal( _screen.zoo.app.cSucursalActiva )
			endif
		endif
				
		return this.cRutaTablas 
	endfunc 

	*--------------------------------------------------------------------
	function AbreTabla ( tcTabla as string, tcAlias as string ,	tnArea as number, tcRuta as string ) as Boolean
		local	lcTemp, lcRutaTabla, llRetorno, lcRutaCompleta, llAbrir, lcMensaje, loError as Exception, ;
				lcTablaSinRuta as String, lcTabla as String, lcDbfAbierta as String, lcTablaAChequear as String 

		llRetorno = .t.

		lcTablaSinRuta = strtran(upper(justfname( tcTabla )),".DBF","")
		lcTabla = upper(alltrim(tcTabla))

		if empty( justpath( lcTabla ))
			if empty( tcRuta )
				lcRutaCompleta = addbs( this.cRutaTablas ) + this.cAgregaRuta
			else
				lcRutaCompleta = addbs( tcRuta )
			endif
			
			if file( lcRutaCompleta + forceext( lcTablaSinRuta, "DBF" ) )
				lcTabla = lcRutaCompleta + forceext( lcTablaSinRuta, "DBF" )
			endif	
		else
			lcTabla = forceext( lcTabla, "DBF" )
		endif
		
		llAbrir = .t.
		lcTablaAChequear = ''
		if !empty( tcAlias )
			lcTablaAChequear = tcAlias
		else
			lcTablaAChequear = lcTablaSinRuta
		endif
			
		if used( lcTablaAChequear )
			lcDbfAbierta = upper(dbf(lcTablaAChequear))

			if lcDbfAbierta = lcTabla
				select( lcTablaAChequear )
				llAbrir = .f.
			else
				llAbrir = this.Cierratabla( lcTablaAChequear )
			endif
		endif
		
		if llAbrir
			Try
				do case
					case used( lcTablaSinRuta ) and !empty( tcAlias ) and !empty( tnArea )
						use ( lcTabla ) alias ( tcAlias ) in ( tnArea ) again
					case used( lcTablaSinRuta ) and !empty( tcAlias ) and empty( tnArea )
						use ( lcTabla ) alias ( tcAlias ) in 0 again
					case !empty( tcAlias ) and !empty( tnArea )
						use ( lcTabla ) alias ( tcAlias ) in ( tnArea ) again
					case !empty( tcAlias )
						use ( lcTabla ) alias ( tcAlias ) in 0 again
					case !empty(tnArea)
						use ( lcTabla ) in ( tnArea ) again
					case !used( lcTablaSinRuta ) and empty( tcAlias ) and empty( tnArea )
						use ( lcTabla ) in 0 again
					case used( lcTablaSinRuta ) and empty( tcAlias ) and empty( tnArea )
						select ( lcTablaSinRuta )
					otherwise
						llRetorno = .f.
				endcase
				if llRetorno
					if !empty( tcAlias )
						select ( tcAlias )
					else
						select ( lcTablaSinRuta )
					endif
				endif
			Catch To loError
				llRetorno = .f.
			EndTry
		endif
		return llRetorno
	endfunc

	*--------------------------------------------------------------------
	Function CierraTabla ( tcTabla As String , tlLocked as Boolean ) as Boolean 
		local llRetorno  As Boolean, loError as Exception, lcTabla As String, lcExtend as String

		llRetorno = .t.
		Try 
			lcTabla = justfname( tcTabla )
			lcExtend = justext( tcTabla )
			if !empty( lcExtend )
				lcExtend = "." + lcExtend	
				lcTabla = strtran( lcTabla, lcExtend, "" )
			endif
			if tlLocked and IsfLocked( lcTabla )
				llRetorno = .F.
			else
				Use In select( lcTabla )
			Endif
		Catch To loError
			llRetorno = .f.		
		EndTry
		Return llRetorno 
	Endfunc

	*--------------------------------------------------------------------
	function ArmarCursor( tcTabla as string ) as Boolean

		local lcNombreCursor as string, llRetorno as Boolean, lcMensaje as String 
		local loError as Exception

		llRetorno = .t.

		try
			lcNombreCursor = "c_" + alltrim(tcTabla)
			if this.AbreTabla ( tcTabla )
				select * from ( tcTabla ) into cursor ( lcNombreCursor )
			else
				llRetorno = .F.
			EndIf
		Catch To loError
			llRetorno = .f.
		finally
			try 
				this.CierraTabla ( tcTabla )
			catch to loError
				llRetorno = .F.
			EndTry					
		EndTry

		return llRetorno

	endfunc 
	
	*----------------------------------------------------------------------
	Function AbrirTablas ( tcTablas as String ) As Boolean
		local llRetorno  As Boolean , loError as Exception 
		Local lnTotalTablas As Integer , lnTablaActual As Integer
		
		llRetorno = .t.

		try 
			lnTotalTablas = getwordcount( tcTablas, "," )
			For lnTablaActual = 1 to lnTotalTablas 
				llRetorno = llRetorno .And. this.AbreTabla ( alltrim( getwordnum( tcTablas, lnTablaActual, "," ) ) ) 
				if !llRetorno
					lnTablaActual = lnTotalTablas 
				Endif	
			endfor
		catch to loError
			llRetorno = .f.
		endtry
		return llRetorno				
	EndFunc
	*----------------------------------------------------------------------	
	Function CerrarTablas ( tcTablas ) 
		local llRetorno  As Boolean , loError as Exception, lnTotalTablas As Integer , lnTablaActual As Integer
		
		llRetorno = .t.

		try 
			lnTotalTablas = getwordcount( tcTablas, "," )
			For lnTablaActual = 1 to lnTotalTablas 
				llRetorno = llRetorno .And. this.CierraTabla ( alltrim( getwordnum( tcTablas, lnTablaActual, "," ) ) ) 
				if !llRetorno
					lnTablaActual = lnTotalTablas 
				Endif	
			endfor
		catch to loError
			llRetorno = .f.
		endtry
		return llRetorno				
	EndFunc		

Enddefine
