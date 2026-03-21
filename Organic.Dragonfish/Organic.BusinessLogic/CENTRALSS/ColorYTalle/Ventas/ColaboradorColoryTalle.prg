define class ColaboradorColorYTalle as ZooSession of ZooSession.Prg

	#IF .f.
		Local this as ColaboradorColorYTalle of ColaboradorColorYTalle.prg
	#ENDIF

	oPaletaDeColores = null
	oCurvaDeTalles = Null
	protected DescripcionDeArticulo
	protected DescripcionDeGrupo
	DescripcionDeArticulo = ""
	DescripcionDeGrupo = ""

	*--------------------------------------------------------------------------------------------------------
	function oPaletaDeColores_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oPaletaDeColores ) = 'O' or isnull( this.oPaletaDeColores )
				this.oPaletaDeColores = _Screen.zoo.InstanciarEntidad( 'PaletaDeColores' )
			endif
		endif
		return this.oPaletaDeColores
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oCurvaDeTalles_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oCurvaDeTalles ) = 'O' or isnull( this.oCurvaDeTalles )
				this.oCurvaDeTalles = _Screen.zoo.InstanciarEntidad( 'CurvaDeTalles' )
			endif
		endif
		return this.oCurvaDeTalles
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarColorYtallePermitiendoColoryTalleVacios( toObjeto as Object ) as Void
		local llColorOk as Boolean, llTalleOk as Boolean
		This.LimpiarInformacion()

		llColorOk = empty( toObjeto.Color_Pk ) or This.VerificarColorCorrecto( toObjeto )
		llTalleOk = empty( toObjeto.Talle_Pk ) or This.VerificarTalleCorrecto( toObjeto )
		if !llColorOk and !llTalleOk
			This.AgregarInformacion( "Los códigos de color y talle ingresados no son válidos." )
		endif
		if This.HayInformacion()
			do case
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 2
					goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 3
					this.EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( This.ObtenerInformacion() )			
			endcase
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarColorYtalle( toObjeto as Object ) as Void
		local llColorOk as Boolean, llTalleOk as Boolean, llVieneDeCodigoDeBarrasOPrePantalla as Boolean
		
		This.LimpiarInformacion()
		llColorOk = This.VerificarColorCorrecto( toObjeto )
		llTalleOk = This.VerificarTalleCorrecto( toObjeto )
		
		llVieneDeCodigoDeBarrasOPrePantalla = this.VieneDeCodigoDeBarras() or this.VieneDePrePantalla()
		
		if !llColorOk and !llTalleOk
			This.AgregarInformacion( "Los códigos de color y talle ingresados no son válidos." )
		endif
		if This.HayInformacion() 
			do case 
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 2
					if llVieneDeCodigoDeBarrasOPrePantalla 
						toObjeto.Articulo_PK = goLibrerias.ValorVacio( toObjeto.Articulo_PK )
						toObjeto.Limpiar()
					else
						if !this.VieneDeCambioDeFila()
							this.EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva()
						endif
					endif
					goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 3
					if llVieneDeCodigoDeBarrasOPrePantalla 
					else
						this.EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( This.ObtenerInformacion() )
					endif
			endcase
		Endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarColorYtalleParaVariosArt( toObjeto as Object ) as integer
		local llColorOk as Boolean, llTalleOk as Boolean, lnRetorno as Integer
		This.LimpiarInformacion()
		lnRetorno = 0
		 
		llColorOk = This.VerificarColorCorrecto( toObjeto )
		llTalleOk = This.VerificarTalleCorrecto( toObjeto )

		if This.HayInformacion() 
			do case 
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 2
					lnRetorno = 2
				case goParametros.colorytalle.ControlarElIngresoDeColoresYTallesAsociadosAPaletasYCurvas = 3
					lnRetorno = 3
			endcase
		endif
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarColorCorrecto( toObjeto as Object ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcMensajeError as String
		llRetorno = .T.
		this.CargarDescripciones(toObjeto)
		try
			if empty( toObjeto.Articulo.PaletaDeColores_Pk )
				llRetorno = This.VerificarColorCorrectoGrupo( toObjeto )
			Else
				This.oPaletaDeColores.Codigo = toObjeto.Articulo.PaletaDeColores_Pk
				if toObjeto.Articulo.PaletaDeColores.ColorValido( upper ( toObjeto.Color_Pk ) )
				else 
				    lcDescripcion = alltrim( This.oPaletaDeColores.Descripcion )
				    if !empty(lcDescripcion)
				         lcDescripcion = ' - '+ lcDescripcion
				    endif
				    This.AgregarInformacion( "Color inexistente (" + alltrim(toObjeto.Color_Pk) + ") para la paleta de colores ( " + rtrim( This.oPaletaDeColores.Codigo ) + ;
						 lcDescripcion + " ) del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "." )
					llRetorno = .F.	
				Endif
			Endif
		catch to loError
			do case
			case !empty(toObjeto.Articulo.PaletaDeColores_Pk)
				lcDescripcion = alltrim( This.oPaletaDeColores.Descripcion )
				if !empty(lcDescripcion)
				    lcDescripcion = ' - '+ lcDescripcion
				endif
				lcMensajeError =  "Color inexistente (" + alltrim(toObjeto.Color_Pk) + ") para la paleta de colores ( " + rtrim( toObjeto.Articulo.PaletaDeColores_Pk ) + ;
				lcDescripcion + " ) del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "." 
				
			case !empty(toObjeto.Articulo.grupo_PK) and !empty(toObjeto.Articulo.grupo.PaletaDeColores_Pk)
				lcMensajeError = "La paleta de colores "+alltrim(toObjeto.Articulo.grupo.PaletaDeColores_Pk)+" asignada al grupo " + ;
					alltrim(toObjeto.Articulo.grupo_PK)+" del artículo no existe." 
			other
				lcMensajeError = "Han ocurrido errores al validar la paleta de colores del articulo."
			endcase
			This.AgregarInformacion( lcMensajeError)

			llRetorno = .f.
		EndTry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarColorCorrectoGrupo( toObjeto as Object ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcMensajeCapturado as String, ;
			lcMensajeSinGrupo as String, lcMensajeSinColor as String, lcMensajeError as String
		llRetorno = .T.
		this.CargarDescripciones(toObjeto)
		try
			if empty( toObjeto.Articulo.grupo.PaletaDeColores_Pk )
			Else
				This.oPaletaDeColores.Codigo = toObjeto.Articulo.grupo.PaletaDeColores_Pk
				if toObjeto.Articulo.grupo.PaletaDeColores.ColorValido( toObjeto.Color_Pk )
				else
					do case
					case !empty( toObjeto.Articulo.grupo.PaletaDeColores_PK ) or !empty(This.oPaletaDeColores.Descripcion )
						lcDescripcion = alltrim( This.oPaletaDeColores.Descripcion )
						if !empty(lcDescripcion)
						    lcDescripcion = ' - '+ lcDescripcion
						endif
						lcMensajeError = "Color inexistente (" + alltrim(toObjeto.Color_Pk) + ") para la paleta de colores ( " + rtrim( toObjeto.Articulo.grupo.PaletaDeColores_PK ) + ;
						lcDescripcion  + " ) del grupo del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "." 
					otherwise
						lcMensajeError = "Color inexistente para la paleta de colores del grupo del artículo."
					endcase
					This.AgregarInformacion( lcMensajeError)
					llRetorno = .F.
				Endif
			Endif
		catch to loError
			lcMensajeCapturado = loError.uservalue.oInformacion.item[1].cMensaje
			lcMensajeSinGrupo = "No se puede verificar la paleta de colores porque el dato buscado " + alltrim(toObjeto.Articulo.grupo_PK) + "  de la entidad " + ;
								this.DescripcionDeGrupo + " de " + this.DescripcionDeArticulo + " no existe."
			lcMensajeSinColor = "La paleta de colores ( " + rtrim( toObjeto.Articulo.grupo.PaletaDeColores_Pk ) + " ) asignada al grupo del artículo no existe."
			lcMensajeError = iif(lcMensajeCapturado="El dato buscado "+alltrim(toObjeto.Articulo.grupo_PK) + ;
				" de la entidad GRUPOS DE ARTÍCULOS no existe.", lcMensajeSinGrupo, lcMensajeSinColor)
			This.AgregarInformacion( lcMensajeError )
			llRetorno = .F.
		EndTry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarTalleCorrecto( toObjeto as Object ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcMensajeError as String
		llRetorno = .T.
		this.CargarDescripciones(toObjeto)
		try
			if empty( toObjeto.Articulo.CurvaDeTalles_Pk )
				llRetorno = This.VerificarTalleCorrectoGrupo( toObjeto )
			else
				if This.oCurvaDeTalles.Codigo != toObjeto.Articulo.CurvaDeTalles_Pk
					This.oCurvaDeTalles.Codigo = toObjeto.Articulo.CurvaDeTalles_Pk
				endif
				if toObjeto.Articulo.CurvaDeTalles.TalleValido( upper ( toObjeto.Talle_Pk ) ) 
				else
				    lcDescripcion = alltrim( This.oCurvaDeTalles.Descripcion )
				    if !empty(lcDescripcion)
				         lcDescripcion = ' - '+ lcDescripcion
				    endif
					This.AgregarInformacion( "Talle inexistente (" + alltrim(toObjeto.Talle_Pk) + ") para la curva de talles ( " + rtrim( This.oCurvaDeTalles.Codigo ) +  ;
						 lcDescripcion + " ) del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "." )
					llRetorno = .F.
				Endif
			Endif
		catch to loError
			do case
			case !empty(toObjeto.Articulo.CurvaDeTalles_Pk)
				lcDescripcion = alltrim( This.oCurvaDeTalles.Descripcion )
				if !empty(lcDescripcion)
				   lcDescripcion = ' - '+ lcDescripcion
			    endif
				lcMensajeError =  "Talle inexistente (" + alltrim(toObjeto.Talle_Pk) + ") para la curva de talles ( " + rtrim( toObjeto.Articulo.CurvaDeTalles_Pk ) + ;
				lcDescripcion + " ) del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "."
			case !empty(toObjeto.Articulo.grupo_PK) and !empty(toObjeto.Articulo.grupo.CurvaDeTalles_Pk)
				lcMensajeError = "La curva de talles  "+alltrim(toObjeto.Articulo.grupo.CurvaDeTalles_Pk)+" asignada al grupo " + ;
					alltrim(toObjeto.Articulo.grupo_PK)+" del articulo no existe"
			other
				lcMensajeError = "Han ocurrido errores al validar la curva de talles del articulo."
			endcase
			This.AgregarInformacion( lcMensajeError )
			llRetorno = .F.
		EndTry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarTalleCorrectoGrupo( toObjeto as Object ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcMensajeCapturado as String, ;
			lcMensajeSinGrupo as String, lcMensajeSinTalle as String, lcMensajeError as String
		llRetorno = .T.
		this.CargarDescripciones(toObjeto)
		try
			if empty( toObjeto.Articulo.grupo.CurvaDeTalles_Pk )
			Else
				This.oCurvaDeTalles.Codigo = toObjeto.Articulo.grupo.CurvaDeTalles_Pk
				if toObjeto.Articulo.grupo.CurvaDeTalles.TalleValido( toObjeto.Talle_Pk )
				else
					do case
					case !empty( toObjeto.Articulo.grupo.CurvaDeTalles_PK ) or !empty(This.oCurvaDeTalles.Descripcion )
						lcDescripcion = alltrim( This.oCurvaDeTalles.Descripcion )
						if !empty(lcDescripcion)
						   lcDescripcion = ' - '+ lcDescripcion
					    endif
						lcMensajeError = "Talle inexistente (" + alltrim(toObjeto.Talle_Pk) + ") para la curva de talles ( " + rtrim( toObjeto.Articulo.grupo.CurvaDeTalles_PK ) + ;
								lcDescripcion + " ) del grupo del artículo " + alltrim( toObjeto.Articulo.Codigo ) + "."
					otherwise
						lcMensajeError = "Talle inexistente para la curva de talles del grupo del artículo." 
					endcase
					This.AgregarInformacion( lcMensajeError)
					llRetorno = .F.
				Endif
			Endif
		catch to loError
			lcMensajeCapturado = loError.uservalue.oInformacion.item[1].cMensaje
			lcMensajeSinGrupo = "No se puede verificar la curva de talles porque el dato buscado " + alltrim(toObjeto.Articulo.grupo_PK) + "  de la entidad " + ;
								this.DescripcionDeGrupo + " de " + this.DescripcionDeArticulo + " no existe."
			lcMensajeSinTalle = "La curva de talles ( " + rtrim( toObjeto.Articulo.grupo.CurvaDeTalles_PK ) + " ) asignada al grupo del artículo no existe."
			lcMensajeError = iif(lcMensajeCapturado="El dato buscado " + alltrim(toObjeto.Articulo.grupo_PK) + ;
				" de la entidad GRUPOS DE ARTÍCULOS no existe.", lcMensajeSinGrupo, lcMensajeSinTalle)
			This.AgregarInformacion( lcMensajeError )
			llRetorno = .F.
		EndTry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColores( toArticulo as String ) as String
		local lcColores as String, lcPaletaDeColores as String

		lcPaletaDeColores = toArticulo.PaletaDeColores_Pk
		if empty( lcPaletaDeColores )
			lcPaletaDeColores = toArticulo.grupo.PaletaDeColores_Pk
		endif
		lcColores = this.ObtenerColoresDePaleta( lcPaletaDeColores )

		return lcColores
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColoresDePaleta( tcPaletaDeColores as String  ) as String
		local lcRetorno as String, lnI as Integer
		lcRetorno = ""
		try
			This.oPaletaDeColores.Codigo = tcPaletaDeColores
			for lnI = 1 to This.oPaletaDeColores.Colores.Count
				lcRetorno =  lcRetorno + "'"+ ( This.oPaletaDeColores.Colores.Item[lnI].Color_Pk ) + "', "
			EndFor
			lcRetorno = substr( lcRetorno, 1, len( lcRetorno ) - 2)
		catch to loError
			lcRetorno = ""
		endtry
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTalles( toArticulo as String ) as String
		local lcTalles as String, lcCurvaDeTalles as String

		lcCurvaDeTalles = toArticulo.CurvaDeTalles_Pk
		if empty( lcCurvaDeTalles )
			lcCurvaDeTalles = toArticulo.grupo.CurvaDeTalles_Pk
		endif
		lcTalles = this.ObtenerTallesDeCurva( lcCurvaDeTalles )

		return lcTalles
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTallesDeCurva( tcCurvaDeTalles as String  ) as String
		local lcRetorno as String, lnI as Integer
		lcRetorno = ""
		try
			This.oCurvaDeTalles.Codigo = tcCurvaDeTalles
			for lnI = 1 to This.oCurvaDeTalles.Talles.Count
				lcRetorno =  lcRetorno + "'"+ ( This.oCurvaDeTalles.Talles.Item[lnI].Talle_Pk ) + "', "
			EndFor
			lcRetorno = substr( lcRetorno, 1, len( lcRetorno ) - 2)
		catch to loError
			lcRetorno = ""
		endtry
		return lcRetorno
	endfunc


	*-----------------------------------------------------------------------------------------
	protected function CargarDescripciones( toObjeto as Object )

		if empty(this.DescripcionDeArticulo)
			this.DescripcionDeArticulo = upper(alltrim(toObjeto.Articulo.ObtenerDescripcion()))
		endif
		if empty(this.DescripcionDeGrupo)
			this.DescripcionDeGrupo = upper(alltrim(toObjeto.Articulo.Grupo.ObtenerDescripcion()))
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( toInformacion as Object ) as Void
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva() as Void

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VieneDeCodigoDeBarras() as Boolean
		return this.BuscarEnHerenciaDeLlamadas( 'CAMPOLECTURACB' )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VieneDePrePantalla() as Boolean
		return this.BuscarEnHerenciaDeLlamadas( 'PROCESARPREPANTALLA' )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VieneDeCambioDeFila() as Boolean
		return this.BuscarEnHerenciaDeLlamadas( 'CAMBIARDEFILA' )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BuscarEnHerenciaDeLlamadas( lcCadenaDeBusqueda as String ) as Boolean
		local lcStringPilaDeLlamadas as String, llRetorno as Boolean

		lcStringPilaDeLlamadas = this.HerenciaDeLlamadas()
		llRetorno = upper( lcCadenaDeBusqueda ) $ lcStringPilaDeLlamadas
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function HerenciaDeLlamadas() as String
		local lcRetorno as String, lnInd as Integer, lnDesde as Integer, lnHasta as Integer
		
		lcRetorno = ''
		lnHasta = program( -2 )
		lnDesde = iif(lnHasta>12, lnHasta-12, 1)
		
		for lnInd = lnDesde to lnHasta
			lcRetorno = lcRetorno + ':' + program( lnInd ) + ' => '
		endfor
		
		return lcRetorno
	endfunc

enddefine
