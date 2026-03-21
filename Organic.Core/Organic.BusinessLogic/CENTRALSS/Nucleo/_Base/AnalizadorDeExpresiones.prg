define class AnalizadorDeExpresiones as BloquesEnlazados of BloquesEnlazados.prg 

	#if .f.
		local this as AnalizadorDeExpresiones of AnalizadorDeExpresiones.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Texto_ASSIGN( tcTexto as String ) as Void
		dodefault( tcTexto )
		 
		this.ReagruparBloquesEnExpresionesMinimas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReagruparBloquesEnExpresionesMinimas() as Void
		this.RecomponerBloquesSeparadosPorUnPunto()
		this.RecomponerLiterales()
		this.IdentificarLosParametrosOrganic()
		this.RecomponerOperadoresDeComparacion()
		this.RecomponerMetodosYFunciones()
		this.RecomponerExpresionesDeComparacion()
		this.ActualizarAtributosDeLaLista()
		this.CompletarGerarquiaDeBloques()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RecomponerBloquesSeparadosPorUnPunto() as Void
		local loBloque as Bloque of Bloque.prg, llEsNumero as Boolean, llEsAtributo as Boolean
		
		if this.Count > 0
			&& Los bloques que tienen un punto como HitoPrevio sin otro caracter que lo separe
			&& entonces el punto es parte del bloque y este bloque se marca como atributo o como
			&& numero según corresponda.
			for each loBloque in this foxobject
				if right( loBloque.HitoPrevio, 1 ) == "."
					loBloque.Texto = "." + loBloque.Texto
					loBloque.HitoPrevio = left( loBloque.HitoPrevio, len( loBloque.HitoPrevio ) - 1 )
					if !loBloque.EsNumero
						if !this.EsUnMetodoDeEntidad( loBloque )
							loBloque.EsAtributo = .t.
						endif
					endif
				endif 
			endfor 
			
			loBloque = this.Item(1)
			do while !isnull( loBloque ) and vartype( loBloque.BloqueSiguiente ) == "O"
				llEsNumero = loBloque.BloqueSiguiente.EsNumero
				llEsAtributo = loBloque.BloqueSiguiente.EsAtributo
				if !loBloque.EsOperador and ( llEsNumero or llEsAtributo ) and empty( loBloque.BloqueSiguiente.HitoPrevio )
					loBloque.EsNumero = llEsNumero
					loBloque.EsAtributo = llEsAtributo
					loBloque.AbsorberElBloqueSiguiente()
				else
					loBloque = loBloque.BloqueSiguiente
				endif
			enddo
		endif
		
		this.LimpiarBloquesAsimilados()
		
		loBloque = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecomponerLiterales() as Void
		local loBloque as Bloque of Bloque.prg, loBloqueCierre as Bloque of Bloque.prg,;
			  lcDelimitadoresDeApertutaParaLiterales as String, loDelimitadores as Collection, lnPos as Integer,;
			  lcDelimitadorInicial as string, lcDelimitadorEsperado as String, lcTexto as String
		
		if this.Count > 0		
			lcDelimitadoresDeApertutaParaLiterales = "['" + '"'
			lcFuncionesQueRetornanLiterales = "CHR, SPACE"
			loDelimitadores = this.TextoComoBloqueBase.ObtenerColeccionDeDelimitadores()
			
			loBloque = this.Item(1)
			do while vartype( loBloque ) == "O"
				lnPos = loBloque.ObtenerLaPosicionDeCualquieraDeLosCaracteres( lcDelimitadoresDeApertutaParaLiterales, 1, loBloque.HitoPrevio )
				if lnPos != 0 
					lcDelimitadorInicial = substr( loBloque.HitoPrevio, lnPos, 1 )
					lcDelimitadorEsperado = loDelimitadores.Item( lcDelimitadorInicial )
					loBloqueCierre = this.BuscarElBloqueQueCierraElLiteral( loBloque, lcDelimitadorEsperado )
					
					if isnull( loBloqueCierre ) 
						&& no hago nada
					else
						loBloque.EsLiteral = .t.
						loBloque.TipoDeContenido = "C"
						
						if !( loBloqueCierre = loBloque )
							do while !( loBloque.BloqueSiguiente = loBloqueCierre )
								loBloque.AbsorberElBloqueSiguiente( .t. )						
							enddo
							loBloque.AbsorberElBloqueSiguiente( .t. )
						endif
						
						lnPos = at( lcDelimitadorInicial, loBloque.HitoPrevio )
						lcTexto = substr( loBloque.HitoPrevio, lnPos ) + loBloque.Texto
						loBloque.HitoPrevio = left( loBloque.HitoPrevio, lnPos - 1 )
						
						lnPos = at( lcDelimitadorEsperado, loBloque.HitoSiguiente, occurs( lcDelimitadorEsperado, loBloque.HitoSiguiente ) )
						lcTexto = lcTexto + left( loBloque.HitoSiguiente, lnPos )
						loBloque.HitoSiguiente = substr( loBloque.HitoSiguiente, lnPos + 1 )
						
						loBloque.Texto = lcTexto	&& Para ejecutar una sola vez el ASSIGN
					endif
				else
					if loBloque.SinDefinir and ( occurs( upper( loBloque.Texto ), lcFuncionesQueRetornanLiterales ) = 1 )
						if ( left( ltrim( loBloque.HitoSiguiente ), 1 ) == "(" ) and ( vartype( loBloque.BloqueSiguiente ) == "O" ) and loBloque.BloqueSiguiente.EsNumero and ( at( ")", loBloque.BloqueSiguiente.HitoSiguiente ) > 0 )
							loBloque.AbsorberElBloqueSiguiente( .t. )
							
							lnPos = at( ")", loBloque.HitoSiguiente )
							loBloque.Texto = loBloque.Texto + left( loBloque.HitoSiguiente, lnPos )
							loBloque.HitoSiguiente = substr( loBloque.HitoSiguiente, lnPos + 1 )
							
							loBloque.EsLiteral = .t.
							loBloque.TipoDeContenido = "C"
						endif
					endif
				endif
				loBloque = loBloque.BloqueSiguiente
			enddo
		endif
		
		this.LimpiarBloquesAsimilados()
		
		loBloque = null
		loBloqueCierre = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarElBloqueQueCierraElLiteral( toBloque as Bloque of Bloque.prg, tcDelimitadorFinal as String ) as Bloque of Bloque.prg
		local loBloque as Bloque of Bloque.prg, llEsElDelimitadorCorrecto as Boolean
		
		llEsElDelimitadorCorrecto = ( vartype( toBloque ) == "O" ) and ( upper( alltrim( toBloque.Class  ) ) == "BLOQUE" )
		llEsElDelimitadorCorrecto = llEsElDelimitadorCorrecto and ( at( tcDelimitadorFinal, toBloque.HitoSiguiente ) > 0 )
		
		&& Esto es en el caso que dentro de un literal se permita las repetición del mismo como """ o '''
		&&	llEsElDelimitadorCorrecto = llEsElDelimitadorCorrecto and ( occurs( tcDelimitadorFinal, toBloque.HitoSiguiente ) = 1 or occurs( tcDelimitadorFinal, toBloque.HitoSiguiente ) = 3 )
		&&	if llEsElDelimitadorCorrecto and ( occurs( tcDelimitadorFinal, toBloque.HitoSiguiente ) = 3 )
		&&	 	llEsElDelimitadorCorrecto = ( at( tcDelimitadorFinal, toBloque.HitoSiguiente, 3 ) - at( tcDelimitadorFinal, toBloque.HitoSiguiente, 1 ) = 2 )
		&&	endif
		
		if llEsElDelimitadorCorrecto 
			loBloque = toBloque
		else
			if vartype( toBloque.BloqueSiguiente ) == "O"
				loBloque = this.BuscarElBloqueQueCierraElLiteral( toBloque.BloqueSiguiente, tcDelimitadorFinal )
			else
				loBloque = Null
			endif
		endif
		
		return loBloque
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IdentificarLosParametrosOrganic() as Void
		local loBloque as Bloque of Bloque.prg, lcTexto as String
		
		if this.Count > 0		
			loBloque = this.Item(1)
			do while vartype( loBloque ) == "O"
				if loBloque.SinDefinir or loBloque.EsAtributo
					lcTexto = upper( alltrim( loBloque.texto ) )
					if ( left( lcTexto, 22 ) == "GOSERVICIOS.PARAMETROS" ) or ( left( lcTexto, 12 ) == "GOPARAMETROS" )
						loBloque.EsParametroOrganic = .t.
					endif
				endif
				loBloque = loBloque.BloqueSiguiente
			enddo
		endif
		
		loBloque = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecomponerOperadoresDeComparacion() as Void
		local loBloque as Bloque of Bloque.prg, lcTexto as String
		
		if this.Count > 0		
			loBloque = this.Item(1)
			do while vartype( loBloque ) == "O"
				if loBloque.EsOperador and ( at( loBloque.Texto, ">=<" ) != 0 ) and ( vartype( loBloque.BloqueSiguiente ) == "O" )
					loBloque.EsComparacion = .t.
					loBloque.TipoDeContenido = "L"
					
					if loBloque.BloqueSiguiente.EsOperador and ( at( loBloque.BloqueSiguiente.Texto, ">=<" ) != 0 )  and ( vartype( loBloque.BloqueSiguiente.BloqueSiguiente ) == "O" )
						loBloque.AbsorberElBloqueSiguiente( .t. )
						loBloque.Texto = strtran( loBloque.Texto, " ", "" )
					endif
				endif
				loBloque = loBloque.BloqueSiguiente
			enddo
		endif
		
		this.LimpiarBloquesAsimilados()
		
		loBloque = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecomponerMetodosYFunciones( toListaDeBloques as BloquesEnlazados of BloquesEnlazados.prg ) as Void
		local loListaDeBloques as BloquesEnlazados of BloquesEnlazados.prg, loBloque as Bloque of Bloque.prg,;
			  loBloqueCierre as Bloque of Bloque.prg, llEsFuncion as Boolean, llEsMetodo as Boolean,;
			  lnPos as Integer, lnOcurrencia as Integer 
		
		if ( vartype( toListaDeBloques ) == "O" ) and ( upper( alltrim( toListaDeBloques.Class ) ) == "BLOQUESENLAZADOS" )
			loListaDeBloques = toListaDeBloques
		else
			loListaDeBloques = this
		endif
		
		if loListaDeBloques.Count > 0		
			loBloque = loListaDeBloques.Item(1)
			do while vartype( loBloque ) == "O"
				if loBloque.SinDefinir
					llEsFuncion = this.EsUnaFuncionFox( loBloque )
					llEsMetodo = this.EsUnMetodoDeEntidad( loBloque ) 
					
					if llEsFuncion or llEsMetodo 
						loBloque.EsFuncion = llEsFuncion
						loBloque.EsMetodo = llEsMetodo
						loBloque.TipoDeContenido = this.TipoDeDatoDevueltoPorlaFuncionFox( loBloque.Texto )
						
						loBloqueCierre = this.BuscarElBloqueQueCierraElParentesis( loBloque, "" )
						
						if !( loBloqueCierre = loBloque )
							do while !( loBloque.BloqueSiguiente = loBloqueCierre )
								loBloque.AbsorberElBloqueSiguiente( .t., .t. )						
							enddo
							loBloque.AbsorberElBloqueSiguiente( .t., .t. )
						endif
						loListaDeBloques.LimpiarBloquesAsimilados()
						
						lnOcurrencia = occurs( "(", loBloque.Texto ) - occurs( ")", loBloque.Texto )
						if lnOcurrencia < 1
							lnOcurrencia = 1
						endif
						lnPos = at( ")", loBloque.HitoSiguiente, lnOcurrencia )
						loBloque.Texto = loBloque.Texto + left( loBloque.HitoSiguiente, lnPos )
						loBloque.HitoSiguiente = substr( loBloque.HitoSiguiente, lnPos + 1 )
						
						if loBloque.SeComponeDeOtrosBloques
							loBloque.Subbloques.BorrarHitoPrevioDelPrimerBloque()
							loBloque.Subbloques.BorrarHitoSiguienteDelUltimoBloque()
							this.RecomponerMetodosYFunciones( loBloque.Subbloques )
						endif
*!*						else
*!*							if !loBloque.SeComponeDeOtrosBloques and loBloque.EsAtributo
*!*								loBloque.SinDefinir = .f.
*!*							endif
					endif
				endif
				loBloque = loBloque.BloqueSiguiente
			enddo
		endif
		
		loListaDeBloques = null
		loBloque = null
		loBloqueCierre = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsUnaFuncionFox( toBloque as Bloque of Bloque.prg ) as Boolean
		local llEsFuncion as Boolean, lcListaDeFncionesAceptadas as String
		
		if toBloque.SinDefinir
			lcListaDeFncionesAceptadas = "ALLTRIM, IIF, EMPTY, UPPER, LOWER, LTRIM, RTRIM, REPLICATE, STRTRAN, SUBSTR, DTOS, DTOC, TRANSFORM"
			
			llEsFuncion = ( ( at( upper( alltrim( strtran( toBloque.Texto, "!", "" ) ) ), lcListaDeFncionesAceptadas ) > 0 ) and ( left( alltrim( toBloque.HitoSiguiente ), 1 ) == "(" ) )
		else
			llEsFuncion = .f.	
		endif
		
		return llEsFuncion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TipoDeDatoDevueltoPorLaFuncionFox( tcExpresion as String ) as String
		local lcFuncion as String, lnPosParentesis as Integer, lcTipo as String
		
		lnPosParentesis = at( "(", tcExpresion )
		lnPosParentesis = iif( lnPosParentesis  = 0, len( tcExpresion ), lnPosParentesis )
		lcFuncion = upper( alltrim( left( tcExpresion, lnPosParentesis ) ) )
		
		do case
			case at( lcFuncion, "ALLTRIM, UPPER, LOWER, LTRIM, RTRIM, REPLICATE, STRTRAN, SUBSTR, DTOS, DTOC, TRANSFORM" ) > 0
				lcTipo = "C"
			
			case at( lcFuncion, "EMPTY" ) > 0
				lcTipo = "L"
			
			otherwise
				lcTipo = "U"
		endcase
		
		return lcTipo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsUnMetodoDeEntidad( toBloque as Bloque of Bloque.prg ) as Boolean
		local llEsMetodo as Boolean
		
		if toBloque.SinDefinir
			llEsMetodo = ( ( occurs( ".", toBloque.Texto ) > 0 ) and ( left( alltrim( toBloque.HitoSiguiente ), 1 ) == "(" ) )
		else
			llEsMetodo = .f.	
		endif
		
		return llEsMetodo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarElBloqueQueCierraElParentesis( toBloque as Bloque of Bloque.prg, tcParentesisPorCerrar as String ) as Bloque of Bloque.prg
		local loBloque as Bloque of Bloque.prg, llParentesisDeApertura as String,;
			  lnPosicion as Integer, lcParentesisEncontrado as String
		
		if vartype( tcParentesisPorCerrar ) == "C" and ( tcParentesisPorCerrar == replicate( "(", len( tcParentesisPorCerrar ) ) );
			and ( vartype( toBloque ) == "O" ) and ( upper( alltrim( toBloque.Class  ) ) == "BLOQUE" )
			
			llParentesisDeApertura = tcParentesisPorCerrar 
			lnPosicion = toBloque.ObtenerLaPosicionDeCualquieraDeLosCaracteres( "()", 1, toBloque.HitoSiguiente )
			
			if lnPosicion != 0
				lcParentesisEncontrado = substr( toBloque.HitoSiguiente, lnPosicion, 1 )
				
				if lcParentesisEncontrado == "("
					llParentesisDeApertura = llParentesisDeApertura + lcParentesisEncontrado 
				else
					llParentesisDeApertura = left( llParentesisDeApertura, len( llParentesisDeApertura ) - occurs( ")", toBloque.HitoSiguiente ) )
				endif
			else
				lcParentesisEncontrado = ""
			endif
			
			if ( lcParentesisEncontrado == ")" ) and ( len( llParentesisDeApertura ) = 0 )
				loBloque = toBloque
			else
				if vartype( toBloque.BloqueSiguiente ) == "O"
					loBloque = this.BuscarElBloqueQueCierraElParentesis( toBloque.BloqueSiguiente, llParentesisDeApertura )
				else
					loBloque = Null
				endif
			endif
		else
			loBloque = Null
		endif
				
		return loBloque
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecomponerExpresionesDeComparacion( toListaDeBloques as BloquesEnlazados of BloquesEnlazados.prg ) as Void
		local loListaDeBloques as BloquesEnlazados of BloquesEnlazados.prg, loBloque as Bloque of Bloque.prg,;
			  loBloqueComparacion as Bloque of Bloque.prg
		
		if ( vartype( toListaDeBloques ) == "O" ) and ( upper( alltrim( toListaDeBloques.Class ) ) == "BLOQUESENLAZADOS" )
			loListaDeBloques = toListaDeBloques
		else
			loListaDeBloques = this
		endif
		
		if loListaDeBloques.Count > 0		
			loBloque = loListaDeBloques.Item(1)
			do while vartype( loBloque ) == "O"
				if loBloque.SeComponeDeOtrosBloques
					this.RecomponerExpresionesDeComparacion( loBloque.Subbloques )
				else
					if loBloque.EsComparacion and ( vartype( loBloque.BloquePrevio ) == "O" ) and ( vartype( loBloque.BloqueSiguiente ) == "O" )
						loBloqueComparacion = loListaDeBloques.InsertarUnNuevoBloqueVacioPrevioAlReferido( loBloque.BloquePrevio )
						loBloqueComparacion.EsComparacion = .t.
						loBloqueComparacion.TipoDeContenido = "L"
						
						loBloque.EsOperador = .t.
						
						loBloqueComparacion.AbsorberElBloqueSiguiente( .t., .t. )	&& Termino de la Izquierda ( loBloque.BloquePrevio )
						loBloqueComparacion.AbsorberElBloqueSiguiente( .t., .t. )	&& Operador de comparación ( loBloque )
						loBloqueComparacion.AbsorberElBloqueSiguiente( .t., .t. )	&& Termino de la Derecha ( loBloque.BloqueSiguiente )
						
						loBloque = loBloqueComparacion
						loBloqueComparacion = null
					endif
				endif
				
				loBloque = loBloque.BloqueSiguiente
			enddo
		endif
		
		loListaDeBloques.LimpiarBloquesAsimilados()
		
		loBloque = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CompletarGerarquiaDeBloques() as Void
		local loBloquePpal as Bloque of Bloque.prg, loBloque as Bloque of Bloque.prg
		
		if ( this.Count > 1 )
			&& Se completa la estructura de arbol de tal forma que el primer bloque ( nodo del arbol )
			&& represente la expresion en si misma y de este bloque ( nodo raiz ) ramifican los distintos 
			&& subbloques ( nodos ).
			
			loBloquePpal = newobject( "Bloque", "Bloque.prg", "", this.Texto )
			loBloquePpal.ListaPadre = this
			loBloquePpal.EsExpresion = .t.
			loBloquePpal.SeComponeDeOtrosBloques = .t.
			loBloquePpal.Subbloques = newobject( "BloquesEnlazados", "BloquesEnlazados.prg", "", "", loBloquePpal )
			
			for each loBloque in this foxobject
				loBloque.ListaPadre = loBloquePpal.Subbloques
				loBloquePpal.Subbloques.AgregarBloqueComoSiguiente( loBloque )
			endfor
			
			this.VaciarLaListaDeBloques( .t. )
			this.AgregarBloqueComoSiguiente( loBloquePpal )
		endif 
	endfunc 
enddefine
