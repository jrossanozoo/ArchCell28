Define Class colorytalle_ColaboradorProduccion as ColaboradorProduccion of ColaboradorProduccion.prg

	#If .F.
		Local This As colorytalle_ColaboradorProduccion As colorytalle_ColaboradorProduccion.prg
	#Endif

	oInsumo = null
	oPaletaDeColores = null
	oCurvaDeTalles = Null
	oColor = Null
	oTalle = Null
	oLiquiAux = null

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oInsumo.Release()
		this.oPaletaDeColores.Release()
		this.oCurvaDeTalles.Release()
		this.oLiquiAux.Release()
		this.oColor = Null
		this.oTalle = Null
		dodefault()
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oInsumo_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oInsumo ) = 'O' or isnull( this.oInsumo )
				this.oInsumo = _Screen.zoo.InstanciarEntidad( 'Insumo' )
			endif
		endif
		return this.oInsumo
	endfunc


	*--------------------------------------------------------------------------------------------------------
	function oLiquiAux_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oLiquiAux ) = 'O' or isnull( this.oLiquiAux )
				this.oLiquiAux = _Screen.zoo.InstanciarEntidad( 'LiquidacionDeTaller' )
			endif
		endif
		return this.oLiquiAux 
	endfunc
	

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

	*--------------------------------------------------------------------------------------------------------
	function oColor_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oColor ) = 'O' or isnull( this.oColor )
				this.oColor = _Screen.zoo.InstanciarEntidad( 'Color' )
			endif
		endif
		return this.oColor
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oTalle_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oTalle ) = 'O' or isnull( this.oTalle )
				this.oTalle = _Screen.zoo.InstanciarEntidad( 'Talle' )
			endif
		endif
		return this.oTalle
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeArticuloDeInsumo( tcCodigo as String ) as String
		local lcRetorno as String
		lcRetorno = ""
		try
			this.oInsumo.Codigo = alltrim(tcCodigo)
			lcRetorno = alltrim( this.oInsumo.Articulo_PK )
		catch
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColores( toCurvaDeProduccion as String ) as String
		local lcColores as String, lcPaletaDeColores as String
		lcPaletaDeColores = toCurvaDeProduccion.PaletaDeColores_Pk
		if empty( lcPaletaDeColores )
			lcPaletaDeColores = toCurvaDeProduccion.PaletaDeColores_Pk
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
	function ObtenerTalles( toCurvaDeProduccion as String ) as String
		local lcTalles as String, lcCurvaDeTalles as String

		lcCurvaDeTalles = toCurvaDeProduccion.CurvaDeTalles_Pk
		if empty( lcCurvaDeTalles )
			lcCurvaDeTalles = toCurvaDeProduccion.CurvaDeTalles_Pk
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
	function ValidarColorSegunCurvaEnItem() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if This.oEntidad.CargaManual() and llRetorno and !empty(txVal) and !empty(this.oEntidad.PaletaDeColores_PK)
			if this.oEntidad.oColaborador.ColorValido( this.oEntidad.PaletaDeColores_PK, txVal)
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion( "Color invalido para la paleta seleccionada" )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTalleSegunCurvaEnItem() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if This.oEntidad.CargaManual() and llRetorno and !empty(txVal) and !empty(this.oEntidad.PaletaDeColores_PK)
			if !this.oEntidad.oColaborador.ColorValido( this.oEntidad.CurvaDeTalles_PK, txVal)
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion( "Talle invalido para la curva seleccionada" )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ColorValido( tcPaleta as String, tcColor as String ) as Boolean
		local llRetorno as Boolean, loPaleta as Object, loItem As Object
		if empty(tcPaleta)
			llRetorno = .t.
		else
			llRetorno = .F.
			loPaleta =  this.ObtenerPaletaDeColores( tcPaleta )
			try
				for each loItem in loPaleta foxobject
					if ( alltrim(loItem.Color_Pk) == alltrim(tcColor))
						llRetorno = .t.
						exit
					endif
				endfor 
			catch
			endtry
			loPaleta.release()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TalleValido( tcCurva as String, tcTalle as String ) as Boolean
		local llRetorno as Boolean, loCurva as Object, loItem As Object
		if empty(tcCurva)
			llRetorno = .t.
		else
			llRetorno = .F.
			try
				loCurva = this.ObtenerCurvaDeTalles(tcCurva)
				for each loItem in loCurva foxobject
					if ( alltrim(loItem.Talle_Pk) == alltrim(tcTalle))
						llRetorno = .t.
						exit
					endif
				endfor 
			catch
			endtry
			loCurva.release()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CurvaDeProduccionValida( tcCurva as String, tcColor as String, tcTalle as String) as Boolean
		local llRetorno as Boolean, loCurva as Object, loItem As Object
		if empty(tcCurva)
			llRetorno = .t.
		else
			llRetorno = .F.
			loCurva =  this.ObtenerCurvaDeProduccion( tcCurva )
			try
				for each loItem in loCurva foxobject
					if ( alltrim(loItem.Color_Pk) == alltrim(tcColor) and alltrim(loItem.Talle_Pk) == alltrim(tcTalle))
						llRetorno = .t.
						exit
					endif
				endfor 
			catch
			endtry
			loCurva.release()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerCurvaDeProduccion( tcCurvaDeProduccion As String ) As Collection
		Local loRetorno As Collection, loCurva As Object, loItem As Object, loElemento as Object
		loRetorno = _Screen.zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
	
		Try
			loCurva = _Screen.zoo.InstanciarEntidad( "CurvaDeProduccion" )
			loCurva.Codigo = tcCurvaDeProduccion
			For Each loItem In loCurva.Detalle FoxObject
				loElemento = _Screen.zoo.CrearObjeto( "ItemCurvaXML", "colorytalle_ColaboradorProduccion.prg")
				loElemento.CodColor = loItem.Color_Pk
				loElemento.CodTalle = loItem.Talle_Pk
				loElemento.Cantidad = loItem.Cantidad
				loRetorno.Agregar(loElemento)
				if !empty(loItem.Color_Pk)
					loRetorno.lDetalleConVariantePrincipal = .t.
				endif
				if !empty(loItem.Talle_Pk)
					loRetorno.lDetalleConVarianteSecundaria = .t.
				endif
				loElemento = Null
			Endfor
		Catch
		Finally
			loCurva.Release()
		Endtry
		Return loRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPaletaDeColores( tcPaleta as String ) as Collection
		local loRetorno as Collection, loPaleta as Object, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		try
			loPaleta = _Screen.Zoo.InstanciarEntidad( "PaletaDeColores" )
			loPaleta.Codigo = tcPaleta
			for each loItem in loPaleta.Colores foxobject
				loRetorno.Agregar(loItem)
			endfor 
		catch
		finally
			loPaleta.release()
		endtry
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCurvaDeTalles( tcCurva as String ) as Collection
		local loRetorno as Collection, loCurva as Object, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		try
			loCurva = _Screen.Zoo.InstanciarEntidad( "CurvaDeTalles" )
			loCurva.Codigo = tcCurva
			for each loItem in loCurva.Talles foxobject
				loRetorno.Agregar(loItem)
			endfor 
		catch
		finally
			loCurva.release()
		endtry
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComodinEnVariantePrincipal( tcVariante as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if type('tcVariante') = "C" and !empty(tcVariante)
			try
				this.oColor.Codigo = tcVariante
				llRetorno = this.oColor.EsComodinEnProduccion
			catch
			endtry
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsComodinEnVarianteSecundaria( tcVariante as String ) as Void
		local llRetorno as Boolean
		llRetorno = .f.
		if type('tcVariante') = "C" and !empty(tcVariante)
			try
				this.oTalle.Codigo = tcVariante
				llRetorno = this.oTalle.EsComodinEnProduccion
			catch
			endtry
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacionDeCombinacionesFueraDeCurva( toInformacion as ZooInformacion of zooInformacion.prg, tcCurva as String, toDetalle as detalle OF detalle.prg, tcVariantePrincipal as String, tcVarianteSecundaria as String) as Collection
		local loRetorno as zooInformacion of zooInformacion.prg, loComb as Object, llEsComodinPrincipal as Boolean, llEsComodinSecundario as Boolean && , loCurva as Object
		loRetorno = iif(vartype(toInformacion) = 'O' and lower(toInformacion.class)='zooinformacion',toInformacion,_Screen.zoo.crearobjeto( "zooInformacion" ))
		if this.esDetalleDeProduccionConCurva(toDetalle)
			tcCurva = alltrim(tcCurva)
			tcVariantePrincipal = alltrim(tcVariantePrincipal)
			tcVarianteSecundaria = alltrim(tcVarianteSecundaria)
			llEsComodinPrincipal = this.EsComodinEnVariantePrincipal(tcVariantePrincipal)
			llEsComodinSecundario = this.EsComodinEnVarianteSecundaria(tcVarianteSecundaria)

			try
				this.oCurvaDeProduccion = this.ObtenerCurvaDeProduccion(tcCurva)
				For Each loComb in toDetalle FOXOBJECT
					do case
					case !llEsComodinPrincipal and !llEsComodinSecundario
						if !empty(loComb.&tcVariantePrincipal) and !empty(loComb.&tcVarianteSecundaria) and ;
									!this.oCurvaDeProduccion.ExisteCombinacion( loComb.&tcVariantePrincipal, loComb.&tcVarianteSecundaria )
							loRetorno.AgregarInformacion( 'La combinacion '+alltrim(loComb.&tcVariantePrincipal)+"-"+alltrim(loComb.&tcVarianteSecundaria)+" no forma parte de la curva de produccion ") && +tcCurva )
						endif
					case lEsComodinPrincipal and llEsComodinSecundario
						if !this.oCurvaDeProduccion.lDetalleConVariantePrincipal or !this.oCurvaDeProduccion.lDetalleConVarianteSecundaria
							loRetorno.AgregarInformacion( 'Debe existir una combinacion especifica en la curva si usa comodines.')
						else
							if !empty(loComb.&tcVariantePrincipal) and !empty(loComb.&tcVarianteSecundaria) and ;
										!this.oCurvaDeProduccion.ExisteCombinacion( loComb.&tcVariantePrincipal, loComb.&tcVarianteSecundaria )
								loRetorno.AgregarInformacion( 'La combinacion '+alltrim(loComb.&tcVariantePrincipal)+"-"+alltrim(loComb.&tcVarianteSecundaria)+" no forma parte de la curva de produccion ") && +tcCurva )
							endif
						endif
					case llEsComodinPrincipal and !llEsComodinSecundario
						if this.oCurvaDeProduccion.lDetalleConVariantePrincipal
							loRetorno.AgregarInformacion( 'Debe existir un color especifico en la curva si usa comodin.')
						else
							if !empty(loComb.&tcVariantePrincipal) and !empty(loComb.&tcVarianteSecundaria) and ;
										!this.oCurvaDeProduccion.ExisteCombinacion( loComb.&tcVariantePrincipal, loComb.&tcVarianteSecundaria )
								loRetorno.AgregarInformacion( 'La combinacion '+alltrim(loComb.&tcVariantePrincipal)+"-"+alltrim(loComb.&tcVarianteSecundaria)+" no forma parte de la curva de produccion ") && +tcCurva )
							endif
						endif
					case !llEsComodinPrincipal and llEsComodinSecundario
						if this.oCurvaDeProduccion.lDetalleConVarianteSecundario
							loRetorno.AgregarInformacion( 'Debe existir un un talle especifico en la curva si usa comodin.')
						else
							if !empty(loComb.&tcVariantePrincipal) and !empty(loComb.&tcVarianteSecundaria) and ;
										!this.oCurvaDeProduccion.ExisteCombinacion( loComb.&tcVariantePrincipal, loComb.&tcVarianteSecundaria )
								loRetorno.AgregarInformacion( 'La combinacion '+alltrim(loComb.&tcVariantePrincipal)+"-"+alltrim(loComb.&tcVarianteSecundaria)+" no forma parte de la curva de produccion ") && +tcCurva )
							endif
						endif
					endcase
				endfor
			catch
			endtry
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerModeloDeProduccion( tcModelo as String ) as Object
		local loRetorno as Object, loModelo as Object, loItem as Object, loElement as Object, lcXML as String, lcTabla as String, lcSentencia as String, loError as Object &&, loDetalle as Collection
		loRetorno = newObject("ModeloProduccionPlano", "colorytalle_ColaboradorProduccion.prg")

		if vartype( 'tcModelo' ) = 'C' and !empty( tcModelo )
			try
				lcTabla = 'modeloprod'
				lcSentencia = "select * from " + lcTabla + " where codigo = '" + alltrim(tcModelo) + "'"
				lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

				if reccount('lc_modeloprod') > 0
					loRetorno.Codigo = alltrim(lc_modeloprod.codigo)
					loRetorno.ProductoFinal_PK = alltrim(lc_modeloprod.producto)
					loRetorno.CurvaDeProduccion_PK = alltrim(lc_modeloprod.curvaprod)
					this.CargarProcesosEnModelo( loRetorno, tcModelo )
					this.CargarInsumosEnModelo( loRetorno, tcModelo )
					this.CargarSalidasEnModelo( loRetorno, tcModelo )
					this.CargarMaquinariaEnModelo( loRetorno, tcModelo )
				endif
			catch to loError
			endtry
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInsumosDeCurvaDeProduccion( toModelo as Object, tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Collection
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object, loCurva as zoocoleccion OF zoocoleccion.prg, loVariante as Object
		loRetorno = _Screen.Zoo.Crearobjeto("zooColeccion", "zooColeccion.prg")
		
		for each loItem in toModelo.ModeloProcesos FOXOBJECT
			loCurva = this.ObtenerInsumosDeCurvaDeProduccionEnProceso(toModelo, loItem.Proceso_PK, tcVariantePrincipal, tcVarianteSecundaria)
			for each loVariante in loCurva FOXOBJECT
				loRetorno.add(loVariante)
			next
		endfor
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerInsumosDeCurvaDeProduccionEnProceso( toModelo as Object, tcProceso as String, tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Collection
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object, loCurva as Object, llVarPrincEsp as Boolean, llVarSecEsp as Boolean, llVarPrincCom as Boolean, llVarSecCom as Boolean

		loRetorno = _Screen.Zoo.Crearobjeto("zooColeccion", "zooColeccion.prg")

		for each loItem in toModelo.ModeloInsumos FOXOBJECT
			if loItem.Proceso_PK = tcProceso
		
				llVarPrincEsp = .f.
				llVarSecEsp = .f.
				llVarPrincCom = .f.
				llVarSecCom = .f.
		
				if !empty(tcVariantePrincipal) and loItem.ColorM_PK = tcVariantePrincipal
					llVarPrincEsp = .t.
				endif
				if !empty(tcVarianteSecundaria) and loItem.TalleM_PK = tcVarianteSecundaria
					llVarSecEsp = .t.
				endif
				if this.EsComodinEnVariantePrincipal(loItem.ColorM_PK)
					llVarPrincCom = .T.
				endif
				if this.EsComodinEnVarianteSecundaria(loItem.TalleM_PK)
					llVarSecCom = .T.
				endif
				
				do case
					case llVarPrincEsp and llVarSecEsp
						if loItem.ColorM_PK = tcVariantePrincipal and loItem.TalleM_PK = tcVarianteSecundaria
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = loItem.Colorm_PK
							loCurva.Tallem_PK = loItem.Tallem_PK
							loCurva.Insumo_PK = loItem.Insumo_PK 
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif
					case !empty(tcVariantePrincipal) and llVarPrincCom and !empty(tcVarianteSecundaria) and llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
					case !empty(tcVariantePrincipal) and llVarPrincCom and empty(tcVarianteSecundaria) and !llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
							
					case empty(tcVariantePrincipal) and !llVarPrincCom and !empty(tcVarianteSecundaria) and llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
							
					case !empty(tcVariantePrincipal) and !llVarPrincCom and llVarSecCom  && curva tiene color y puede o no tener talle, modelo tiene color específico, pero talle comodín
						if ( loItem.ColorM_PK = tcVariantePrincipal ) 
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif												

					case llVarPrincCom and !empty(tcVarianteSecundaria) and !llVarSecCom && curva puede tener o no color y tiene talle, modelo tiene talle específico pero color comodín										
						if ( loItem.TalleM_PK = tcVarianteSecundaria )
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif						


					case ( !llVarPrincCom and !llVarSecCom ) and ( empty(tcVariantePrincipal) or empty(tcVarianteSecundaria) ) && TENGO O COLOR O TALLE, PERO NO LOS 2
							if ( !empty(tcVariantePrincipal) and loItem.ColorM_PK = tcVariantePrincipal ) OR ( !empty(tcVarianteSecundaria) and loItem.TalleM_PK = tcVarianteSecundaria )
								loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
								loCurva.Proceso_PK = loItem.Proceso_PK
								loCurva.Colorm_PK = loItem.Colorm_PK
								loCurva.Tallem_PK = loItem.Tallem_PK
								loCurva.Insumo_PK = loItem.Insumo_PK
								loCurva.Color_PK = loItem.Color_PK
								loCurva.Talle_PK = loItem.Talle_PK
								loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
								loCurva.Cantidad = loItem.Cantidad
								loRetorno.Add(loCurva)				
							endif 																				

					case ( llVarPrincCom and llVarSecCom ) and ( empty(tcVariantePrincipal) or empty(tcVarianteSecundaria) ) && TENGO O COLOR O TALLE en la curva, PERO NO LOS 2 y en modelo comodín en ambos
							loCurva = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Insumo_PK = loItem.Insumo_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.UnidadDeMedida_PK = loItem.UnidadDeMedida_PK 
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)				
				endcase
			endif
		endfor
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSalidasDeCurvaDeProduccion( toModelo as Object, tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Collection
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object, loCurva as zoocoleccion OF zoocoleccion.prg, loVariante as Object
		loRetorno = _Screen.Zoo.Crearobjeto("zooColeccion", "zooColeccion.prg")

		for each loItem in toModelo.ModeloProcesos FOXOBJECT
			loCurva = this.ObtenerSalidasDeCurvaDeProduccionEnProceso(toModelo, loItem.Proceso_PK, tcVariantePrincipal, tcVarianteSecundaria)
			for each loVariante in loCurva FOXOBJECT
				loRetorno.add(loVariante)
			next
		endfor
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSalidasDeCurvaDeProduccionEnProceso( toModelo as Object, tcProceso as String, tcVariantePrincipal as String, tcVarianteSecundaria as String ) as Collection
		local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as Object, loCurva as Object, llVarPrincEsp as Boolean, llVarSecEsp as Boolean, llVarPrincCom as Boolean, llVarSecCom as Boolean
		llVarPrincEsp = .f.
		llVarSecEsp = .f.
		llVarPrincCom = .f.
		llVarSecCom = .f.
		loRetorno = _Screen.Zoo.Crearobjeto("zooColeccion", "zooColeccion.prg")
	
		for each loItem in toModelo.ModeloSalidas FOXOBJECT
			if loItem.Proceso_PK = tcProceso
			
				llVarPrincEsp = .f.
				llVarSecEsp = .f.
				llVarPrincCom = .f.
				llVarSecCom = .f.
		
				if !empty(tcVariantePrincipal) and loItem.ColorM_PK = tcVariantePrincipal
					llVarPrincEsp = .t.
				endif
				if !empty(tcVarianteSecundaria) and loItem.TalleM_PK = tcVarianteSecundaria
					llVarSecEsp = .t.
				endif
				if this.EsComodinEnVariantePrincipal(loItem.ColorM_PK)
					llVarPrincCom = .T.
				endif
				if this.EsComodinEnVarianteSecundaria(loItem.TalleM_PK)
					llVarSecCom = .T.
				endif
			
				do case
					case llVarPrincEsp and llVarSecEsp
						if loItem.ColorM_PK = tcVariantePrincipal and loItem.TalleM_PK = tcVarianteSecundaria
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = loItem.Colorm_PK
							loCurva.Tallem_PK = loItem.Tallem_PK
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK 
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif
					case !empty(tcVariantePrincipal) and llVarPrincCom and !empty(tcVarianteSecundaria) and llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
					case !empty(tcVariantePrincipal) and llVarPrincCom and empty(tcVarianteSecundaria) and !llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
					case empty(tcVariantePrincipal) and !llVarPrincCom and !empty(tcVarianteSecundaria) and llVarSecCom
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)

					case !empty(tcVariantePrincipal) and !llVarPrincCom and llVarSecCom  && curva tiene color y puede o no tener talle, modelo tiene color específico, pero talle comodín					
						if ( loItem.ColorM_PK = tcVariantePrincipal ) 
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif												

					case llVarPrincCom and !empty(tcVarianteSecundaria) and !llVarSecCom && curva puede tener o no color y tiene talle, modelo tiene talle específico pero color comodín										
					
						if ( loItem.TalleM_PK = tcVarianteSecundaria )
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)
						endif						

					case ( !llVarPrincCom and !llVarSecCom ) and ( empty(tcVariantePrincipal) or empty(tcVarianteSecundaria) ) && TENGO O COLOR O TALLE, PERO NO LOS 2
							if ( !empty(tcVariantePrincipal) and loItem.ColorM_PK = tcVariantePrincipal ) OR ( !empty(tcVarianteSecundaria) and loItem.TalleM_PK = tcVarianteSecundaria )
								loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
								loCurva.Proceso_PK = loItem.Proceso_PK
								loCurva.Colorm_PK = loItem.Colorm_PK
								loCurva.Tallem_PK = loItem.Tallem_PK
								loCurva.Semielaborado_PK = loItem.Semielaborado_PK
								loCurva.Color_PK = loItem.Color_PK
								loCurva.Talle_PK = loItem.Talle_PK
								loCurva.Cantidad = loItem.Cantidad
								loRetorno.Add(loCurva)
							endif
							
					case ( llVarPrincCom and llVarSecCom ) and ( empty(tcVariantePrincipal) or empty(tcVarianteSecundaria) ) && TENGO O COLOR O TALLE en la curva, PERO NO LOS 2 y en modelo comodín en ambos
							loCurva = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
							loCurva.Proceso_PK = loItem.Proceso_PK
							loCurva.Colorm_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Colorm_PK),tcVariantePrincipal,loItem.Colorm_PK)
							loCurva.Tallem_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Tallem_PK),tcVarianteSecundaria,loItem.Tallem_PK)
							loCurva.Semielaborado_PK = loItem.Semielaborado_PK
							loCurva.Color_PK = iif(this.EsComodinEnVariantePrincipal(loItem.Color_PK),tcVariantePrincipal,loItem.Color_PK)
							loCurva.Talle_PK = iif(this.EsComodinEnVarianteSecundaria(loItem.Talle_PK),tcVarianteSecundaria,loItem.Talle_PK)
							loCurva.Cantidad = loItem.Cantidad
							loRetorno.Add(loCurva)									

				endcase
			endif
		endfor
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarProcesosEnModelo( toModelo as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'modproc'
		lcSentencia = "select * from " + lcTabla + " where CodModProc = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
		if reccount('lc_modproc') > 0
			select lc_modproc
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemProcesos","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_modproc.CodModProc
				loItem.Proceso_PK = lc_modproc.codigo
				loItem.Orden = lc_modproc.Orden
				loItem.Taller_PK = lc_modproc.Taller
				loItem.Cantidaddesalida = lc_modproc.Cantidad
				toModelo.ModeloProcesos.Add(loItem)
				loItem = null
			endscan
			use in lc_modproc
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarInsumosEnModelo( toModelo as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'modins'
		lcSentencia = "select * from " + lcTabla + " where CodModIns = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
		if reccount('lc_modins') > 0
			select lc_modins
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemInsumos","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_modins.CodModIns
				loItem.Proceso_PK = lc_modins.Proceso
				loItem.Colorm_PK = lc_modins.cColor
				loItem.Tallem_PK = lc_modins.cTalle
				loItem.Insumo_PK = lc_modins.Insumo
				loItem.Color_PK = lc_modins.iColor
				loItem.Talle_PK = lc_modins.iTalle
				loItem.UnidadDeMedida_PK = lc_modins.UniMed
				loItem.Cantidad = lc_modins.Cantidad
				toModelo.ModeloInsumos.Add(loItem)
				loItem = null
			endscan
			use in lc_modins
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarSalidasEnModelo( toModelo as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'modsal'
		lcSentencia = "select * from " + lcTabla + " where CodModSal = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
		if reccount('lc_modsal') > 0
			select lc_modsal
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemSalidas","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_modsal.CodModSal
				loItem.Proceso_PK = lc_modsal.Proceso
				loItem.Colorm_PK = lc_modsal.cColor
				loItem.Tallem_PK = lc_modsal.cTalle
				loItem.Semielaborado_PK = lc_modsal.Semielab
				loItem.Color_PK = lc_modsal.iColor
				loItem.Talle_PK = lc_modsal.iTalle
				loItem.Cantidad = lc_modsal.Cantidad
				toModelo.ModeloSalidas.Add(loItem)
				loItem = null
			endscan
			use in lc_modsal
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarMaquinariaEnModelo( toModelo as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'modmaq'
		lcSentencia = "select * from " + lcTabla + " where CodModMaq = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
		if reccount('lc_modmaq') > 0
			select lc_modmaq
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemMaquinas","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_modmaq.CodModMaq
				loItem.Proceso_PK = lc_modmaq.Proceso
				loItem.Maquina_PK = lc_modmaq.Maquina
				toModelo.ModeloMaquinas.Add(loItem)
				loItem = null
			endscan
			use in lc_modmaq
		endif
		use in lc_modeloprod
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTallerParaLiquidacion( tcTaller as String, tcProceso as String, toInformacion as Collection ) as Boolean
		local llRetorno as Boolean, lcSentencia as String, loError as Exception, llEspecifico
		llRetorno = .t.
		if type('toInformacion') # 'O' or lower(toInformacion.BaseClass) # 'zoocoleccion'or lower(toInformacion.BaseClass) # 'collection'
			toInformacion = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		endif
		
		lcSentencia = "Select t.codigo, t.PROVEEDOR, t.INSUMOS as tinsumos, t.DESCARTES as tdescartes, "
		lcSentencia = lcSentencia + "d.PROCESO, d.INSUMOS pInsumos, d.DESCARTES pDescartes "
		lcSentencia = lcSentencia + " from zoologic.taller t left join zoologic.tallerproc d on t.codigo = d.CODPROC"
		lcSentencia = lcSentencia + " left join zoologic.procproduc p on d.proceso = p.codigo "
		lcSentencia = lcSentencia + " where t.codigo = '" + tcTaller + "'"
		
		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curTaller", this.DataSessionId )
		if used("curTaller")
			select curTaller
			if reccount("curTaller") = 0
				llRetorno =  .f.
				toInformacion.Add( 'No existe el taller' )
			else
				go top in curTaller
				if empty(curTaller.Proveedor)
					llRetorno = .f.
					toInformacion.Add( 'El taller debe tener un proveedor asignado para liquidar una gestión de producción' )
				endif
				llEspecifico = .f.
				if !empty(tcProceso)
					locate for proceso = tcProceso
					if found("curTaller")
						if curTaller.pinsumos # 0 or curTaller.pDescartes # 0
							llEspecifico = .f.
							if curTaller.pinsumos = 2 and curTaller.pDescartes = 2
								llRetorno = .f.
								toInformacion.Add( 'El proceso tiene establecido que no incluya ni insumos ni descartes' )
							endif
						endif
					endif
				endif
				if !llEspecifico
					if curTaller.tInsumos = 2 and curTaller.tDescartes = 2
						llRetorno = .f.
						toInformacion.Add( 'El taller tiene establecido que no incluya ni insumos ni descartes' )
					endif
				endif
			endif
		else
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeInlcuirInsumosEnLiquidacion( tcTaller as String, tcProceso as String ) as Boolean
		local llRetorno as Boolean, lcSentencia as String, loError as Exception, llEspecifico
		llRetorno = .t.
		
		lcSentencia = "Select t.codigo, t.PROVEEDOR, t.INSUMOS as tinsumos, t.DESCARTES as tdescartes, "
		lcSentencia = lcSentencia + "d.PROCESO, d.INSUMOS pInsumos, d.DESCARTES pDescartes "
		lcSentencia = lcSentencia + " from zoologic.taller t left join zoologic.tallerproc d on t.codigo = d.CODPROC"
		lcSentencia = lcSentencia + " left join zoologic.procproduc p on d.proceso = p.codigo "
		lcSentencia = lcSentencia + " where t.codigo = '" + tcTaller + "'"
		
		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curTaller", this.DataSessionId )
		if used("curTaller")
			select curTaller
			if reccount("curTaller") = 0
				llRetorno =  .f.
			else
				go top in curTaller
				if empty(curTaller.Proveedor)
					llRetorno = .f.
				endif
				llEspecifico = .f.
				if !empty(tcProceso)
					locate for proceso = tcProceso
					if found("curTaller")
						if curTaller.pinsumos # 0
							llEspecifico = .f.
							if curTaller.pinsumos = 2
								llRetorno = .f.
							endif
						endif
					endif
				endif
				if !llEspecifico
					if curTaller.tInsumos = 2
						llRetorno = .f.
					endif
				endif
			endif
		else
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeInlcuirDescartesEnLiquidacion( tcTaller as String, tcProceso as String ) as Boolean
		local llRetorno as Boolean, lcSentencia as String, loError as Exception, llEspecifico
		llRetorno = .t.
		
		lcSentencia = "Select t.codigo, t.PROVEEDOR, t.INSUMOS as tinsumos, t.DESCARTES as tdescartes, "
		lcSentencia = lcSentencia + "d.PROCESO, d.INSUMOS pInsumos, d.DESCARTES pDescartes "
		lcSentencia = lcSentencia + " from zoologic.taller t left join zoologic.tallerproc d on t.codigo = d.CODPROC"
		lcSentencia = lcSentencia + " left join zoologic.procproduc p on d.proceso = p.codigo "
		lcSentencia = lcSentencia + " where t.codigo = '" + tcTaller + "'"
		
		goServicios.Datos.EjecutarSentencias( lcSentencia, "", "", "curTaller", this.DataSessionId )
		if used("curTaller")
			select curTaller
			if reccount("curTaller") = 0
				llRetorno =  .f.
			else
				go top in curTaller
				if empty(curTaller.Proveedor)
					llRetorno = .f.
				endif
				llEspecifico = .f.
				if !empty(tcProceso)
					locate for proceso = tcProceso
					if found("curTaller")
						if curTaller.pDescartes # 0
							llEspecifico = .f.
							if curTaller.pDescartes = 2
								llRetorno = .f.
							endif
						endif
					endif
				endif
				if !llEspecifico
					if curTaller.tDescartes = 2
						llRetorno = .f.
					endif
				endif
			endif
		else
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerGestionDeProduccion( tcGestion as String ) as Object
		local loRetorno as Object, loModelo as Object, loItem as Object, loElement as Object, lcXML as String, lcTabla as String, lcSentencia as String, loError as Object, lcBase as String
		loRetorno = newObject("GestionProduccionPlano", "colorytalle_ColaboradorProduccion.prg")

		if vartype( 'tcGestion' ) = 'C' and !empty( tcGestion )
			try
				lcTabla = 'gestionprod'
				lcGestion = "'"+alltrim(tcGestion)+"'"

				lcTextMerge = set("Textmerge")
				set textmerge on

				text to lcSentencia noshow
					select Gestion.*, Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes 
					 from Zoologic.<<lcTabla>> Gestion Left Join 
					 Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo 
					 where Gestion.codigo = <<lcGestion>>
				endtext
				set textmerge &lcTextMerge

				lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))
				if reccount('lc_gestionprod') > 0
					loRetorno.Codigo = alltrim(lc_gestionprod.codigo)
					loRetorno.OrdenDeProduccion_PK = alltrim(lc_gestionprod.ordendepro)
					loRetorno.Proceso_PK = alltrim(lc_gestionprod.proceso)
					loRetorno.Taller_PK = alltrim(lc_gestionprod.taller)
					loRetorno.Proveedor_PK = alltrim(lc_gestionprod.proveedor)
					loRetorno.InsumoEnLiquidacion = lc_gestionprod.Insumos
					loRetorno.DescarteEnLiquidacion = lc_gestionprod.Descartes
					loRetorno.ListaDeCosto_PK = lc_gestionprod.ListaCosto

				endif
			catch to loError
			endtry
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCurvaEnGestion( toGestion as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'gespcurv'
		lcTextMerge = set("Textmerge")
		set textmerge on
		text to lcSentencia noshow
			select Gestion.GesProdCur, Gestion.mArtDF, Gestion.Insumo, Gestion.CantProd, 
				Gestion.cColor, Gestion.cTalle, Gestion.,codColor Gestion.codTalle, Gestion.CantDesc, 
				Select Funciones.ObtenerCostoDeInsumoPonderado('<<lcLista>>','<<lcInsumo>>','<<>>','<<>>','<<>>','<<>>','<<>>') as costo, 

		lcRetorno = "Select Funciones.ObtenerCostoDeInsumoPonderado('"
		lcRetorno = lcRetorno + lcLista + "','"
		lcRetorno = lcRetorno + lcInsumo + "','"
		lcRetorno = lcRetorno + tcProceso + "','"
		lcRetorno = lcRetorno + lcTaller + "','"
		lcRetorno = lcRetorno + lcColor + "','"
		lcRetorno = lcRetorno + lcTalle + "',"
		lcRetorno = lcRetorno + lcCantidad + ") as cdirecto"
				Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes 
				from Zoologic.<<lcTabla>> Gestion Left Join 
				Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo 
				where Gestion.codigo = <<lcGestion>>
		endtext
		set textmerge &lcTextMerge
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

		if reccount('lc_gespcurv') > 0
			select lc_gespcurv
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemGestionCurva","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_gespcurv.GesProdCur
				loItem.Articulo_PK = lc_gespcurv.mArtDF
				loItem.Colorm_PK = lc_gespcurv.cColor
				loItem.Tallem_PK = lc_gespcurv.cTalle
				loItem.Insumo_PK = lc_gespcurv.Insumo
				loItem.Color_PK = lc_gespcurv.codColor
				loItem.Talle_PK = lc_gespcurv.codTalle
				loItem.Cantproducida = lc_gespcurv.CantProd
				loItem.Cantdescarte = lc_gespcurv.CantDesc
				toGestion.GestionCurva.Add(loItem)
				loItem = null
			endscan
			use in lc_gespcurv
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDescartesEnGestion( toGestion as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'gespdesc'
		lcSentencia = "select * from " + "Zoologic." + lcTabla + " where gesProdDes = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

		if reccount('lc_gespdesc') > 0
			select lc_gespdesc
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemGestionDescartes","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_gespdesc.gesProdDes
				loItem.Articulo_PK = lc_gespdesc.mArtDF
				loItem.Colorm_PK = lc_gespdesc.cColor
				loItem.Tallem_PK = lc_gespdesc.cTalle
				loItem.Insumo_PK = lc_gespdesc.Insumo
				loItem.Color_PK = lc_gespdesc.codColor
				loItem.Talle_PK = lc_gespdesc.codTalle
				loItem.Cantdescarte = lc_gespdesc.CantDesc
				toGestion.GestionDescartes.Add(loItem)
				loItem = null
			endscan
			use in lc_gespdesc
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarInsumosProductosEnGestion( toGestion as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'gespins'
		lcSentencia = "select * from "+ "Zoologic." + lcTabla + " where GesProdIns = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

		if reccount('lc_gespins') > 0
			select lc_gespins
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemGestionInsumos","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_gespins.GesProdIns
				loItem.Articulo_PK = lc_gespins.mArtDF
				loItem.Colorm_PK = lc_gespins.cColor
				loItem.Tallem_PK = lc_gespins.cTalle
				loItem.Insumo_PK = lc_gespins.Insumo
				loItem.Color_PK = lc_gespins.codColor
				loItem.Talle_PK = lc_gespins.codTalle
				loItem.Cantidad = lc_gespins.Cantidad
				toGestion.GestionInsumos.Add(loItem)
				loItem = null
			endscan
			use in lc_gespins
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarInsumosDescartesEnGestion( toGestion as Object, tcCodigo as String ) as Void
		local lcTabla as String, lcSentencia as String, lcXML as String
		lcTabla = 'gespind'
		lcSentencia = "select * from "+ "Zoologic." + lcTabla + " where GesProdInd = '" + alltrim(tcCodigo) + "'"
		lcXML = goServicios.Datos.Ejecutarsentencias(lcSentencia,lcTabla,,'lc_'+lcTabla,set('datasession'))

		if reccount('lc_gespind') > 0
			select lc_gespind
			scan
				loItem = _Screen.Zoo.CrearObjeto("ItemGestionInsumosDescartes","colorytalle_ColaboradorProduccion.prg")
				loItem.Codigo = lc_gespcurv.GesProdInd
				loItem.Articulo_PK = lc_gespind.mArtDF
				loItem.Colorm_PK = lc_gespind.cColor
				loItem.Tallem_PK = lc_gespind.cTalle
				loItem.Insumo_PK = lc_gespind.Insumo
				loItem.Color_PK = lc_gespind.codColor
				loItem.Talle_PK = lc_gespind.codTalle
				loItem.Cantidad = lc_gespind.Cantidad
				toGestion.GestionInsumosDescartes.Add(loItem)
				loItem = null
			endscan
			use in lc_gespind
		endif
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------*
*------------------------------ Definición de clases -------------------------------------*
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------
define class ModeloProduccionPlano as Session

	cNombre = 'MODELODEPRODUCCION'
	Codigo = []
	ModeloSalidas = null
	ModeloMaquinas = null
	ModeloInsumos = null
	Descripcion = []
	ProductoFinal_PK = []
	ProductoFinal = null
	Familia_PK = []
	Familia = null
	Material_PK = []
	Material = null
	Grupo_PK = []
	Grupo = null
	CurvaDeProduccion_PK = []
	CurvaDeProduccion = null
	ModeloProcesos = null

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.ModeloProcesos = newObject("zooColeccion", "zooColeccion.prg")
		this.ModeloInsumos = newObject("zooColeccion", "zooColeccion.prg")
		this.ModeloSalidas = newObject("zooColeccion", "zooColeccion.prg")
		this.ModeloMaquinas = newObject("zooColeccion", "zooColeccion.prg")
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
Define Class ItemCurvaXML as Custom
	CodColor = ''
	CodTalle = ""
	Cantidad = 0
EndDefine

*-----------------------------------------------------------------------------------------
define class ItemProcesos as custom

	Codigo = []
	Nroitem = 0
	Proceso_PK = []
	Procesodetalle = []
	Orden = 0
	Taller_PK = []
	Cantidaddesalida = 0

enddefine

*-----------------------------------------------------------------------------------------
define class ItemInsumos as custom

	Codigo = []
	Nroitem = 0
	Proceso_PK = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Insumo_PK = []
	Insumodetalle = []
	Comportamientoinsumo = 0
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Unidaddemedida_PK = []
	Cantidad = 0
	NroItem = 0

enddefine

*-----------------------------------------------------------------------------------------
define class ItemSalidas as custom

	Codigo = []
	Nroitem = 0
	Proceso_PK = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Semielaborado_PK = []
	Semielaboradodetalle = []
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Cantidad = 0
	NroItem = 0

enddefine

*-----------------------------------------------------------------------------------------
define class ItemMaquinas as custom

	Codigo = []
	Nroitem = 0
	Proceso_PK = []
	Maquina_PK = []
	Maquinadetalle = []
	Tipomaquinaria = 0
	Unidaddetiempo = 0
	Tiempo = 0
	Desperdicio = 0
	NroItem = 0

enddefine

*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------
define class GestionProduccionPlano as Session

	cNombre = 'GESTIONDEPRODUCCION'
	Codigo = []
	GestionCurva = null
	GestionDescartes = null
	GestionInsumos = null
	GestionInsumosDescartes = null
	Descripcion = []
	cAtributoPK = 'Codigo'
	Fecha = ctod( '  /  /    ' )
	Modelo_PK = []
	Modelo = null
	OrdenDeProduccion_PK = []
	OrdenDeProduccion = null
	Numero = 0
	NumeroDeOrden = 0
	Proceso_PK = []
	Proceso = null
	Taller_PK = []
	Taller = null
	InventarioOrigen_PK = []
	InventarioOrigen = null
	InventarioDestino_PK = []
	InventarioDestino = null
	Proveedor_PK = []
	Proveedor = null
	ListaDeCosto_PK = ''
	InsumoEnLiquidacion = ''
	DescarteEnLiquidacion = ''

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.GestionCurva = newObject("zooColeccion", "zooColeccion.prg")
		this.GestionDescartes = newObject("zooColeccion", "zooColeccion.prg")
		this.GestionInsumos = newObject("zooColeccion", "zooColeccion.prg")
		this.GestionInsumosDescartes = newObject("zooColeccion", "zooColeccion.prg")
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class ItemGestionCurva as custom

	Codigo = []
	Comportamiento = 0
	Nroitem = 0
	Articulo_PK = []
	Articulodetalle = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Insumo_PK = []
	Insumodetalle = []
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Partida = []
	Cantproducida = 0
	Cantdescarte = 0
	NroItem = 0
	Costo = 0
	Monto = 0
	Concepto = ''

enddefine

*-----------------------------------------------------------------------------------------
define class ItemGestionDescartes as custom

	Codigo = []
	Comportamiento = 0
	Nroitem = 0
	Articulo_PK = []
	Articulodetalle = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Insumo_PK = []
	Insumodetalle = []
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Partida = []
	Motdescarte_PK = []
	Motdescartedetalle = []
	Inventariodest_PK = []
	Inventariodestdetalle = []
	Cantdescarte = 0
	NroItem = 0
	Costo = 0
	Monto = 0
	Concepto = ''

enddefine

*-----------------------------------------------------------------------------------------
define class ItemGestionInsumos as custom

	Codigo = []
	Cantporunidad = 0
	Comportamiento = 0
	Nroitem = 0
	Articulo_PK = []
	Articulodetalle = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Insumo_PK = []
	Insumodetalle = []
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Partida = []
	Cantidad = 0
	NroItem = 0
	Costo = 0
	Monto = 0
	Concepto = ''

enddefine

*-----------------------------------------------------------------------------------------
define class ItemGestionInsumosDescartes as custom

	Codigo = []
	Comportamiento = 0
	Nroitem = 0
	Articulo_PK = []
	Articulodetalle = []
	Colorm_PK = []
	Colormdetalle = []
	Tallem_PK = []
	Tallemdetalle = []
	Insumo_PK = []
	Insumodetalle = []
	Color_PK = []
	Colordetalle = []
	Talle_PK = []
	Talledetalle = []
	Partida = []
	Cantidad = 0
	NroItem = 0
	Costo = 0
	Monto = 0
	Concepto = ''

enddefine

