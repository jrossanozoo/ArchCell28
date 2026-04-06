define class valorSugeridoZL as ZooSession of ZooSession.prg
	
	#if .f.
		local this as valorSugeridoZL of valorSugeridoZL.prg
	#endif

	cCampo = ""
	cTabla = ""
	cFiltro = ".t."
	nTamanioCampo = 0
	cNombreCursor = ""

	*-----------------------------------------------------------------------------------------
	Function SetearPropiedades( tcTabla As String, tcCampo As String, tcFiltro As String ) As Void

		If Vartype( tcTabla ) # "C"  Or Vartype( tcCampo ) # "C" Or Inlist( Vartype( tcCampo ), "N", "O", "D", "U" )
			Assert .F. Message "Número de Parámetros incorrectos o tipo no válido"
		Endif

		This.cCampo = tcCampo
		This.cTabla = tcTabla
		This.cFiltro = Iif( Empty( tcFiltro ), ".t.", tcFiltro )
		This.cNombreCursor = "c_"+ Alltrim( This.cTabla )+ "_ValorSugerido"

	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerMinimoSerieDisponible( ) as string
		return This.ObtenerMinimo( alltrim( goParametros.zl.ComportamientoDeSeries.SerieMinimo ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerMinimoSerieDisponibleTomaInventario( ) as String
		return This.ObtenerMinimo( alltrim(  goParametros.zl.ComportamientoDeSeries.SerieMinimoTomadeInventario ) )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerMinimo( tcValorMinimo As String ) as String
		local lcMinimoDisp as String, lcCampo as string, lcMinimo as String

			&& Esto sirve si y solo si el Len( Alltrim ( tcValorMinimo ) = This.nTamanioCampo
			if	Len( Alltrim ( tcValorMinimo ) ) = This.nTamanioCampo and;
				substr( tcValorMinimo, 1, 1 ) != "0" and;
				str( val( tcValorMinimo ), This.nTamanioCampo ) = tcValorMinimo and;
				substr( tcValorMinimo, 2, 1 ) = "0" and;
				This.nTamanioCampo = 6
			else
				Return ""
			EndIf

			lcCampo = Alltrim(This.cCampo)
			goServicios.Datos.EjecutarSentencias( "Select " + lcCampo + " From " + This.cTabla, This.cTabla, '', 'c_Minimo', this.DataSessionId )

			lcMinimoDisp = ""
			lcMinimo = tcValorMinimo
			if reccount( "c_Minimo" ) > 0
				select &lcCampo as Serie ;
					from c_Minimo ;
					where &lcCampo >= tcValorMinimo ;
					into cursor cCargados nofilter ;
					order by 1
				do while !eof( "cCargados" ) and empty( lcMinimoDisp )
					if cCargados.Serie > lcMinimo
						lcMinimoDisp = lcMinimo
					else
						if substr( lcMinimo, 3, 4 ) = "9999"
							if Substr( lcMinimo, 1, 1 ) = "9" && No hay mas numeros de serie
								gomensajes.enviar( "No hay mas números de serie disponibles" )
								lcMinimo = ""
								go Bottom in cCargados
							Else
								lcMinimo = str( val( Substr( lcMinimo, 1, 1 ) ) + 1, 1 ) + "00000"
							EndIf	
						else
							lcMinimo = str( val( lcMinimo ) + 1, This.nTamanioCampo )
						EndIf
					endif
					skip in cCargados
				EndDo
				if empty( lcMinimoDisp )
					lcMinimoDisp = lcMinimo
				EndIf	
			else
				lcMinimoDisp = tcValorMinimo
			endif
			use in select( "C_minimo" )	
			use in select( "cCargados" )

			return lcMinimoDisp
	endfunc 

	*-----------------------------------------------------------------------------------------
enddefine