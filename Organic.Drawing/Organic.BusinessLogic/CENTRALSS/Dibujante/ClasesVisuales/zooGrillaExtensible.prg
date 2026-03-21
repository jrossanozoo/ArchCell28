Define Class zooGrillaExtensible As zooContenedor Of zooContenedor.prg

	#If .F.
		Local This As zooGrillaExtensible Of zooGrillaExtensible.prg
	#Endif

	#INCLUDE constantesDibujante.h

	protected nAltoOriginal as Integer
	protected nCantidadDeFilasARetroceder as Integer
	lMostrar = .f.
	
	nCantidadColumnas = 0
	nCantidadFilas = 0
	nAnchoColumnaSecundaria = 9

	nAnchoBarraDesplazamiento = sysmetric( 5 ) + 1

	nCantidadItemsVisibles = 0
	nCantidadMaximaItemsVisibles = 0
	nAltoOriginal = 0
	nCantidadDeFilasARetroceder = 0
	
	nRegistroInicioPantalla = 1

	nEspacioColumnas = 1
	nEspacioFilas = 1
	
	nFilaActiva = 0

	oCampoAnterior = null
	
	nCantidadEnterVacios = 0
	nOffsetSalida = 1

	***********************
	nAltoCabecera	= 40
	nAltoFila		= 30
	nAltoPie		= 40
	nAltoFormulario = 0
	***********************

	lYaReajustoPorSuperposicion = .f.

	Dimension aGrilla(1)

	cScroleo = ""
	lMalLostFocus = .F.

	*-----------------------------------------------------------------------------------------
	function init( toItem as object )
		if type( "toItem" ) = "O"
			this.nAltoFormulario = goEstilos.nResolucionAlto
		else
			this.NewObject( "oSinfoco", "textboxSinFoco" )
			this.NewObject( "oToolTip", "TooltipNumeroDeFila" )
		endif

		dodefault( toItem )
	endfunc

	*-----------------------------------------------------------------------------------------
	function nCantidadMaximaItemsVisibles_Access() as Integer
		if empty( this.nCantidadMaximaItemsVisibles )
			this.nCantidadMaximaItemsVisibles = this.nCantidadItemsVisibles
		endif
		
		return this.nCantidadMaximaItemsVisibles
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function nAltoOriginal_Access() as Integer
		if empty( this.nAltoOriginal )
			this.nAltoOriginal = this.Height
		endif
		
		return this.nAltoOriginal
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreCelda( tnFila as Integer, tnColumna as Integer )
		return "Campo_" + alltrim( str( tnColumna ) ) + "_" + alltrim( str( tnFila ) )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCelda( tnFila as Integer, tnColumna as Integer )
		local loRetorno as object, lcCelda as string
		
		loRetorno = null
		lcCelda = this.ObtenerNombreCelda( tnFila, tnColumna )
		if type( "this." + lcCelda ) = "O"
			loRetorno = evaluate( "this." + lcCelda )
		endif
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularNumerodeFilaDelDetalle( tnFilaVisible as Integer )
		return tnFilaVisible + ( this.nRegistroInicioPantalla - 1 ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularNumerodeFilaDeLaGrilla( tnFilaDetalle as Integer )
		return tnFilaDetalle - ( this.nRegistroInicioPantalla - 1 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SacarfocoDeLaGrilla() as boolean
		local llRetorno as boolean
		
		llRetorno = .f.
		thisform.oKontroler.lSacandoFocoDeGrilla = .t.
		if thisform.visible
			this.oSinfoco.SetFocus()
			if thisform.ActiveControl = this.oSinFoco
				this.LostFocus()
				
				if thisform.ActiveControl = this.oSinFoco
					llRetorno = .t.
					this.oCampoAnterior = this.oSinFoco
				endif
			endif
		endif
		thisform.oKontroler.lSacandoFocoDeGrilla = .f.
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Armar() As Void

		DoDefault()

		With This
			if vartype(.oItem ) = "O"

				.SetearCantidadDeItemsVisibles()
				
				if vartype( .oItem.AtributosClase ) = "O"
					.LlenarGrilla()
				endif

				.ArmarBarras()
			endif
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearControl( toItem as Object ) as Void
		
		dodefault( toItem )

		if pemstatus( toItem, "CantidadItems", 5 )
			this.nCantidadFilas = toItem.CantidadItems
		endif

		if empty( this.nCantidadFilas )
			this.nCantidadFilas = goControles.ObtenerCantidadDeItemsDeDetallePorDefecto()

			if empty( this.nCantidadFilas )
				goServicios.Errores.LevantarExcepcion( "No se pudo setear la cantidad de items máxima del detalle " + alltrim( toItem.Atributo ) )
			endif		
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearCantidadDeItemsVisibles() as Void
		local lnAlto AS Integer,lnPorcentaje As Integer, lcNombreDeFuente as String, lnTamanioDeFuente as Number

		with this
			lnPorcentaje = .oItem.PorcentajeVisualDetalle

			if empty( lnPorcentaje )
				lnPorcentaje = goControles.ObtenerPorcentajeVisualDeDetallePorDefecto()
			endif
					
			if inlist( upper( alltrim( _screen.zoo.app.cProyecto ) ), "COLORYTALLE", "DIBUJANTE", "NIKE" )		
				lcNombreDeFuente =  goEstilos.ObtenerNombreDeFuente( goEstilos.nIdEstilo )
				lnTamanioDeFuente = goEstilos.ObtenerTamanioDeFuente( goEstilos.nIdEstilo )
				.nAltofila = goEstilos.CalcularAltoEnPixeles( lcNombreDeFuente, lnTamanioDeFuente ) * 1.3043
			endif

			if empty( lnPorcentaje )
				goServicios.Errores.LevantarExcepcion( "No se pudo setear la cantidad de items visibles del detalle " + alltrim( this.oItem.Atributo ) )
			endif
						
			lnAlto = .nAltoFormulario * ( lnPorcentaje / 100 )
			lnAlto = lnAlto - .nAltoCabecera
			lnAlto = lnAlto - .nAltoPie
			lnAlto = lnAlto / .nAltoFila
			.nCantidadItemsVisibles = int( lnAlto )
			If .nCantidadItemsVisibles < 1
				.nCantidadItemsVisibles = 1
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarBarras() as Void
		with this
			.AgregarBarraDesplazamiento()
			with .oBarraDeDesplazamiento
				with .oBarra
					.Visible = .T.
					.Orientation = 0
					.Width = this.nAnchoBarraDesplazamiento
				endwith

				.Visible = .T.
				.Width = .oBarra.Width

				.SetearBarra( 1, this.nCantidadFilas, 10, 1 )
				.SetearValor( .Min )
			endwith

			_Screen.zoo.NuevoObjeto( this, "oBarraDeEstado", "BarraEstadoGrillaExt", "", .oItem )
			with .oBarraDeEstado
				.Visible = .t.
				.nFila = this.nCantidadItemsVisibles + 1
			endwith
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarBarraDesplazamiento() as Void
		_Screen.zoo.NuevoObjeto( this, "oBarraDeDesplazamiento", "zoobarradesplazamientoContenedor", 'zoobarradesplazamientoContenedor.vcx' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDeSerializar() as string
		local lcRetorno as String, lcCursor

		lcRetorno = 			replicate( chr(9), 7) +	".AgregarBarraDesplazamiento()" + chr( 13 )
		lcRetorno = lcRetorno +	replicate( chr(9), 7) +	"with .oBarraDeDesplazamiento" + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Visible = .T." + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Width = " + transform( this.oBarraDeDesplazamiento.width ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Top = " + transform( this.oBarraDeDesplazamiento.Top ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Left = " + transform( this.oBarraDeDesplazamiento.Left ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Height = " + transform( this.oBarraDeDesplazamiento.Height ) + chr( 13 )
		lcRetorno = lcRetorno +	replicate( chr(9), 7) +	"with .oBarra" + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Orientation = " + transform( this.oBarraDeDesplazamiento.oBarra.Orientation ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Visible = .T." + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Width = " + transform( this.oBarraDeDesplazamiento.oBarra.width ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Top = " + transform( this.oBarraDeDesplazamiento.oBarra.Top ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Left = " + transform( this.oBarraDeDesplazamiento.oBarra.Left ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Height = " + transform( this.oBarraDeDesplazamiento.oBarra.Height ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Max = " + transform( this.oBarraDeDesplazamiento.Max ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Min = " + transform( this.oBarraDeDesplazamiento.Min ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".Value = " + transform( this.oBarraDeDesplazamiento.Min ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".largeChange = " + transform( this.oBarraDeDesplazamiento.oBarra.largeChange ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 8) +	".SmallChange = " + transform( this.oBarraDeDesplazamiento.oBarra.SmallChange ) + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 7) +	"endwith" + chr( 13 )
		lcRetorno = lcRetorno + replicate( chr(9), 7) +	"endwith" + chr( 13 )

		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LlenarGrilla() as Void
		local loItem as object, lni as integer, loSubGrupo as Object
		
		with this
			loSubGrupo = .oItem.AtributosClase.Grupo0.SubGrupo0
			for lni = 1 to loSubGrupo.count
				loItem = loSubGrupo.item[ lni ]
				
				.NuevaColumna( loItem )
			endfor

			if .nCantidadColumnas > 0
				for lni = 1 to .nCantidadItemsVisibles
					.NuevaFila( lni )
				endfor
			endif

			.LlenarColeccionDeControlesOrdenados()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function NuevaColumna( toItem as Object ) As Void
		Local loColumna As Object, loEncabezado As object

		With this
			toItem.Detalle = .lDetalle
			
			loColumna = .AgregarDatosColumna( toItem )

			if .DebeUnirEncabezado( .nCantidadColumnas - 1 )
				loEncabezado = null
			else
				loEncabezado = .CrearEncabezado( .nCantidadColumnas )
			endif

			loColumna.oEncabezado = loEncabezado
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarDatosColumna( toItem as object ) as object
		Local loColumna As Object, lcTitulo as String, lcTituloCorto as String 

		with this
			.nCantidadColumnas = .nCantidadColumnas + 1

			Dimension This.aGrilla( .nCantidadColumnas )

			loColumna = CreateObject( "ItemColumnaGrilla" )

			with loColumna
				.lExtensible = toItem.MuestraRelacion and inlist( upper( toItem.TipoDato ), "C", "G" )
				.nOffset = iif( toItem.MuestraRelacion, 2, 0 )
				.lSePuedeSuperponer = !inlist( upper( alltrim( toItem.Atributo ) ), "CANTIDAD", "PRECIO" )
				.cTitulo =  alltrim( toItem.Etiqueta )
				.cTituloCorto = alltrim( toItem.EtiquetaCorta )
				.cAtributo = alltrim( toItem.Atributo )
				.oItem = toItem 
			endwith

			.aGrilla[ .nCantidadColumnas ] = loColumna
		endwith
		
		return loColumna
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearEncabezado( tnColumna as integer ) as object
		local loEncabezado as Object, loColumnas as object, lcEncabezado as string

		with this
			loColumna = .aGrilla[ tnColumna ]

			lcEncabezado = alltrim( this.Name ) + "_Enc" + Alltrim( Str( tnColumna ) )
			_Screen.zoo.NuevoObjeto( this, lcEncabezado, "EncabezadoGrillaExt", "", loColumna.oItem )
			loEncabezado = .&lcEncabezado
			
			loEncabezado.Visible = .T.
			loEncabezado.nColumna = tnColumna 
			loEncabezado.nFila = 0
			loEncabezado.SetearEncabezado( iif( empty( loColumna.cTituloCorto ), loColumna.cTitulo, loColumna.cTituloCorto ), loColumna.cTituloCorto )

			If .nCantidadColumnas = 1
				loEncabezado.nTipoDeOrdenIzquierdo = NO_ACOMODAR
			Endif

		endwith
		
		return loEncabezado
	endfunc

	*-----------------------------------------------------------------------------------------
	protected Function NuevaFila( tnFila as Integer ) As Void
		Local lni As Integer

		With This
			For lni = 1 To .nCantidadColumnas
				.NuevoCampo( lni, tnFila  )
			Endfor
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected Function NuevoCampo( tnColumna As Integer, tnFila As Integer ) As Void
		Local lcCampo As String, loColumna As Object, loItem As Object, lcClase as string, loError as exception, loEx as Exception, loCampo as object

		With This

			loColumna = .aGrilla[ tnColumna ]
			loItem = loColumna.oItem
			
			lcCampo = .ObtenerNombreCelda( tnFila, tnColumna )

			If loColumna.lExtensible 
				_Screen.zoo.NuevoObjeto( this, lcCampo, "CampoExtGrillaExt", "", loItem )
			else
				lcClase = "Campo" + alltrim( loItem.Dominio )
				_Screen.zoo.NuevoObjeto( this, lcCampo, lcClase, "", loItem )
			endif
			
			loCampo = .&lcCampo
			loCampo.nColumna = tnColumna - 1
			loCampo.nFila = tnFila
 
			If tnFila = 1
				loColumna.oPrimerCampo = loCampo
			Endif

			loCampo.Visible = .T.

		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		this.EliminarReferencias()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarReferencias() as Void 
		local i as integer, loColumna as object

		with this
			.oCampoAnterior = null
			
			for i = 1 to alen( .aGrilla )
				loColumna = .aGrilla[ i ]
				
				if vartype( loColumna ) = "O"
					if pemstatus( loColumna, "oEncabezado", 5 )
						if vartype( loColumna.oEncabezado ) = "O"
							if pemstatus(loColumna.oEncabezado, "release" ,5 ) 
								loColumna.oEncabezado.release()
							endif
							if vartype(.aGrilla[ i ].oPrimerCampo) = "O"
								loColumna.oPrimerCampo.destroy()
							endif
							if vartype(loColumna.oItem) = "O"
								loColumna.oItem.destroy() 
							endif
						endif

						loColumna.oEncabezado = null
						loColumna.oPrimerCampo = null
						loColumna.oItem= null
					endif

					loColumna.release()
				endif

				.aGrilla[ i ] = null
			endfor

			if pemstatus( this, "oBarraDeDesplazamiento", 5 )
				.RemoveObject( "oBarraDeDesplazamiento" )
			endif
			if pemstatus( this, "oBarraDeEstado", 5 )
				.RemoveObject( "oBarraDeEstado" )
			endif

		endwith
	endfunc 

***********************************************************************************
***********************************************************************************
***********************************************************************************
***********************************************************************************

***********************************************************************************
**** FUNCIONES QUE SE EJECUTAN DESDE EL OBSERVADOR
	*-----------------------------------------------------------------------------------------
	function DespuesDeSetearEstado( tcEstado as String ) as Void
		dodefault( tcEstado ) 

		with this
			.CambiarTamaniosFilas()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstado( tcEstado as String ) as Void

		this.SetearTextoBarraDeEstado( tcEstado )

		if tcEstado = "EDICION"
			this.nFilaActiva = thisform.oKontroler.ObtenerNumeroItemActivo( this.cAtributo )
		else
			this.oBarraDeDesplazamiento.SetearValor( this.oBarraDeDesplazamiento.Min )
			this.nRegistroInicioPantalla = 1
			this.nFilaActiva = 0
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearTextoBarraDeEstado( tcEstado as String ) as void
		if inlist( tcEstado,  "NULO", "NUEVO" )
			this.oBarraDeEstado.SetearTituloEtiqueta( "" )
		endif
	endfunc 

***********************************************************************************
**** FUNCIONES agrandan y achican los campso extensibles
	*-----------------------------------------------------------------------------------------
	function CambiarTamaniosFilas() as Void

		local i as Integer, lcCampo as String, loCampo as object

		with this
			for i = 1 to .nCantidadItemsVisibles
				loCampo = this.ObtenerCelda( i, 1 )
				if !isnull( loCampo )
					.CalcularAncho( loCampo )
					.CambiarColorDeFondoFila( i )
				endif
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function CalcularAncho(toControl As Object, tnFila As Integer) As Void
		************************************************************************************
		*
		*	1) Recorrer la linea
		*	2) Verificar si el item es expandible
		*	3) en caso afirmativo:
		*		Verificar que el siguiente este vacio o se haya alcanzado el ancho maximo
		*		i)	Si esta Vacio
		*			Sumamos los anchos
		*			Volver a 3)
		*		ii) Sino seteamos el ancho y pasamos al siguiente item
		*	4) Volver a 1)
		*
		************************************************************************************
		Local llSePuedeSuperponer As Boolean, i As Integer, loCampo As Object, loTitulo As Object ;
			, j As Integer, llExtensible As Boolean, lnAncho As Integer, lnAnchoTexto As Integer ;
			, lnPixels As Integer, loCampoSiguiente As Object, loTituloSiguiente As Object ;
			, llSiguienteExtensible  as boolean

		If pcount() < 1 Or Vartype(toControl) # "O"
			toControl = Null
		Endif

		If pcount() < 2
			tnFila = 0
		Endif

		If Vartype(toControl) = "O"
			tnFila = toControl.nFila
		Endif

		If tnFila = 0
			Return
		Endif

		i = 1
		Do While i <= This.nCantidadColumnas
			loCampo = this.ObtenerCelda( tnFila, i )
			
			llExtensible = This.aGrilla[ i ].lExtensible
			lnOffset = This.aGrilla[ i ].nOffset

			j = 1

			If llExtensible

				loCampo.Height = loCampo.nAltoMinimo
				lnAncho = loCampo.nAnchoMinimo

				loCampo.zorder(0)

				lnPixels = Fontmetric( 6, loCampo.FontName, loCampo.FontSize )
				
				if empty( Len( Alltrim( loCampo.Value ) ) )
					lnAnchoTexto = 0
				else
					lnAnchoTexto = Txtwidth( Replicate( "W", Len( Alltrim( loCampo.Value ) ) + lnOffset ), ;
						loCampo.FontName, loCampo.FontSize ) * lnPixels
				endif

				If lnAnchoTexto > lnAncho

					Do While j <= This.nCantidadColumnas - i
						loCampoSiguiente = this.ObtenerCelda( tnFila, j + i )

						llSePuedeSuperponer = This.aGrilla[ j + i ].lSePuedeSuperponer
						llSiguienteExtensible = This.aGrilla[ j + i ].lExtensible

						If !Empty( loCampoSiguiente.Value ) Or iif( vartype(toControl) = "O", toControl = loCampoSiguiente, .f. ) Or ;
								!llSePuedeSuperponer Or lnAncho > lnAnchoTexto

							Exit
						Endif

						lnAncho = lnAncho + iif( llSiguienteExtensible, loCampoSiguiente.nAnchoMinimo, loCampoSiguiente.width )

						j = j + 1
					Enddo

				Endif

				If loCampo.Width # lnAncho
					loCampo.Width = lnAncho
				Endif
			Endif

			i = i + j
		Enddo

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerAnchoLimite( tnColumna As Integer ) As Integer
		Local lnRetorno As Integer, i As Integer

		lnRetorno = 0

		i = tnColumna + 1

		Do While i <= This.nCantidadColumnas And Empty( lnRetorno )

			If This.aGrilla[ i ].lSePuedeSuperponer
			else
				lnRetorno = This.aGrilla[ i ].nLeft
			Endif
			i = i + 1
		Enddo

		If Empty( lnRetorno )
			lnRetorno = This.Width
		Endif

		Return lnRetorno
	Endfunc

*****************************************************************************************
	*-----------------------------------------------------------------------------------------
	Function CambiarColorDeFondoFila( tnFilaActiva as Integer ) As Void

		local j as integer, loCampo as object

		With This
	
			if between( tnFilaActiva, 1, .nCantidadItemsVisibles )

				for j = 1 to .nCantidadColumnas

					loCampo = this.ObtenerCelda( tnFilaActiva, j )
					
					this.CambiarColorDeFondo( loCampo )

				endfor

			endif
			
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarItemGrilla( tnNroItem as Integer ) as Void
		local lnFilaActiva as Integer
		lnFilaActiva = tnNroItem - ( this.nRegistroInicioPantalla - 1 )
		this.ActualizarFilaGrilla( lnFilaActiva )
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Actualiza una fila cualquiera de la grilla
	Function ActualizarFilaGrilla( tnFila as Integer )

		local j as integer, loCampo as object, loError, loEx

		if pcount() < 2
			tlPlano = .f.
		endif
		try
			With This
				if between( tnFila, 1, .nCantidadItemsVisibles )
					for j = 1 to .nCantidadColumnas
						loCampo = this.ObtenerCelda( tnFila, j )
						loCampo.Actualizar()
						if pemstatus( loCampo, "xValorAnterior", 5 )
							loCampo.xValorAnterior = loCampo.Value
						endif
					endfor
				endif
			Endwith
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
			endwith
			goMensajes.Enviar( loEx )
		endtry
	Endfunc

	*-----------------------------------------------------------------------------------------
	* refreazca la fila activa
	Function RefrescarFilaActiva() As Void

		local j as integer, loCampo as object, lnFilaActiva as integer

		With This
			lnFilaActiva = .nFilaActiva - ( .nRegistroInicioPantalla - 1 )

			if between( lnFilaActiva  , 1, .nCantidadItemsVisibles )
				for j = 1 to .nCantidadColumnas
					loCampo = this.ObtenerCelda( lnFilaActiva, j )
					.SetearDescripcion( loCampo )
					loCampo.Actualizar()
				endfor
		
				.CalcularAncho( null, lnfilaActiva )
			endif
			
			if type( "this.CampoLecturaCB" ) = "O" and .CampoLecturaCB.visible
				.CampoLecturaCB.zorder( 0 )
			endif

			.oBarraDeEstado.refresh()

		Endwith
	Endfunc

    *-----------------------------------------------------------------------------------------
    * refrezca la columna seleccionada
	Function RefrescarColumna( tcAtributo ) As Void
		local j as integer, loCampo as object, i as integer, llEncontro as boolean, ;
			loColumna as Object

		With This
			llEncontro = .f.
			j = 1
			do while j <= .nCantidadColumnas and !llEncontro
				loColumna = .aGrilla[ j ]
				if upper( alltrim( tcAtributo ) ) = upper( alltrim( loColumna.cAtributo ) )
					llEncontro = .t.
				endif
				j = j + 1
			enddo
			
			if llEncontro
				for i = 1 to .nCantidadItemsVisibles
					loCampo = this.ObtenerCelda( i, j - 1 )
					.SetearDescripcion( loCampo )
					loCampo.Actualizar()
				endfor
			endif

			if type( "this.CampoLecturaCB" ) = "O" and .CampoLecturaCB.visible
				.CampoLecturaCB.zorder( 0 )
			endif

			.oBarraDeEstado.refresh()
		Endwith
	Endfunc

    *-----------------------------------------------------------------------------------------
    * refresca toda la grilla
	Function RefrescarGrilla() As Void
		local j as integer, loCampo as object, i as integer, llOriginalVacio as Boolean
		With This
			for i = 1 to .nCantidadItemsVisibles
				for j = 1 to .nCantidadColumnas
					loCampo = this.ObtenerCelda( i, j )
					if j = 1 and loCampo.lesObligatorio 
						llOriginalVacio = empty( loCampo.value )
						.SetearDescripcion( loCampo )
						loCampo.Actualizar()
						if llOriginalVacio and empty(loCampo.value)	
							exit
						endif 
					else
						.SetearDescripcion( loCampo )
						loCampo.Actualizar()
					endif
				endfor
			endfor

			if type( "this.CampoLecturaCB" ) = "O" and .CampoLecturaCB.visible
				.CampoLecturaCB.zorder( 0 )
			endif

			if type( "this.oBarraDeEstado" )= "O" and .oBarraDeEstado.visible
				.oBarraDeEstado.refresh()
			endif
		Endwith
	Endfunc

***********************************************************************************
**** FUNCIONES QUE SE EJECUTAN DESDE el acomodador
	*-----------------------------------------------------------------------------------------
	* Esto se ejecuta mientras esta ordenando
	Function ReordenarInternamente() As Void
		DoDefault()

		With This
			
			.AjustarEncabezadoSegunCampo()
			.SacarEspaciosVacios()
			
			with .oBarraDeDesplazamiento
				.Height = this.Height
				.Left = this.Width - this.MargenDer()
				.Top = 0
				.ZOrder(0)
			endwith

			with .oBarraDeEstado
				.Top = this.Height - .Height - this.MargenInf()
				.Width = this.Width - ( .Left + this.MargenDer() )
				.ZOrder(0)
				.OrdenarTotales()
			endwith
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function SacarEspaciosVacios() as Void
		local loCampo as object, lnancho as integer
		with this
			loCampo = This.aGrilla( .nCantidadColumnas )

			* Cuando se arregle el acomodador para que no deje un pixel entre el ultimo campo y
			* la barra de scroll, hay que sacar el this.nEspacioColumnas
			lnAncho = loCampo.nLeft + loCampo.nWidth + this.MargenDer() + this.nEspacioColumnas

			if lnAncho < .width
				.width = lnancho
			endif
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Luego de ordenar la grilla reacomodamos las columnas en caso de que no entren y otros ajustes visuales
	function SetearLuegoDeOrdenar( toAcomodadorControles as object ) as Void
		with this
			if .VerificicarReajusteDeColumnas()
				.ReajustarColumnas( toAcomodadorControles )
			endif

			.CentrarSiEsNecesario()
			.VerificarEtiquetas()
			.AlinearEncabezados()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificicarReajusteDeColumnas() as boolean
		local llRetorno as boolean, lnColumna as integer, loColumna as object, lnLimite as integer, lnAnchoPrimerDescripcion as integer
		llRetorno = .f.
		lnAnchoPrimerDescripcion = 0
		
		
		*** Se reajusta si hay superposicion de columnas 
		*** o si el primer detalle de una clave primaria es mas angosta que los otros detalles de las otras claves primarias
		with this
			if .lYaReajustoPorSuperposicion
			else
				.lYaReajustoPorSuperposicion = .t.
				
				lnLimite = 0
				For lnColumna = 1 To .nCantidadColumnas
					loColumna = .aGrilla[ lnColumna ]

					if right( upper( alltrim( loColumna.cAtributo ) ), 7 ) == "DETALLE"
						if empty( lnAnchoPrimerDescripcion )
							lnAnchoPrimerDescripcion = loColumna.oPrimerCampo.Width
						else
							if lnAnchoPrimerDescripcion < loColumna.oPrimerCampo.Width
								llRetorno = .t.
								exit
							endif
						endif
					endif

					lnLimite = iif( lnColumna < .nCantidadColumnas, .aGrilla[ lnColumna + 1 ].oPrimerCampo.Left, .width )
					if loColumna.oPrimerCampo.Left + loColumna.oPrimerCampo.Width >= lnLimite
						llRetorno = .t.
						exit
					endif
				endfor
			endif
		endwith
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	* Reajuste de columnas, se achican las extensibles, si esto no basta, se achican todas a un mismo tamaño, si esto no sirve lanza excepcion
	protected function ReajustarColumnas( toAcomodadorControles as object ) as void
		local loRetorno as object
		
		with this

			loRetorno = .ObtenerAnchoReajustado()
			if loRetorno.ancho > 0
				.AjustarTamaniosPorSuperposicion( loRetorno )
			endif
			
			.ReajustarUltimaColumnaPorSuperposicion()
			
			toAcomodadorControles.AcomodarControl( this, this.top, this.width )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarEtiquetas() as VOID
		local lnColumna as integer, loColumna as object, loEncabezado as object, lnAncho as integer

		with this
			For lnColumna = 1 to .nCantidadColumnas
				loColumna = .aGrilla[ lnColumna ]

				if !isnull( loColumna.oEncabezado ) and !empty( loColumna.cTitulo )
					loColumna.oEncabezado.SetearEncabezado( loColumna.cTitulo, loColumna.cTituloCorto )
				endif
			endfor
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoReajustado() as object
		local loRetorno as object

		with this
			loRetorno = CreateObject( "DatosColumnaParaAcomodar" )
			with loRetorno
				.AnchoReal = this.ObtenerAnchoReal()
				.AnchoColumnaNoDeseado = int( loRetorno.AnchoReal / this.nCantidadColumnas )
			endwith
			
			.ObtenerAnchoReajustandoSoloExtensibles( loRetorno )
			
			if loRetorno.Ancho <= 0
				.ObtenerAnchoReajustandoCamposGrandes( loRetorno )
				loRetorno.CamposGrandes = .t.
				
				if loRetorno.Ancho <= 0
					loRetorno.Ancho = loRetorno.AnchoColumnaNoDeseado
					loRetorno.Todos = .t.
				endif
			endif

			if loRetorno.Ancho <= 0
				goServicios.Errores.Levantarexcepcion( "No es posible visualizar todas las columnas del detalle " + alltrim( .cAtributo ) )
			endif
		endwith
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoReajustandoSoloExtensibles( toObjeto as Object ) as Void
		local lnColumna as integer, loColumna as object, lnCantExtensibles as integer, lnAncho as integer, lnAnchoNoExtensibles as integer

		with this
			lnCantExtensibles = 0
			lnAnchoNoExtensibles = 0
			lnAncho = 0
			
			For lnColumna = 1 To .nCantidadColumnas
				loColumna = .aGrilla[ lnColumna ]
				if loColumna.lExtensible
					lnCantExtensibles = lnCantExtensibles + 1
				else
					lnAnchoNoExtensibles = lnAnchoNoExtensibles + .ObtenerAnchoColumna( lnColumna )
				endif
			endfor
			
			if lnCantExtensibles > 0
				lnAncho = int( ( toObjeto.AnchoReal - lnAnchoNoExtensibles ) / lnCantExtensibles )
			endif
			
			toObjeto.Ancho = lnAncho			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoReajustandoCamposGrandes( toObjeto as Object ) as Void
		local lnColumna as integer, loColumna as object, lnAnchoTotalColumnasMasChicas  as integer, lnAncho as integer, lnAux as integer, ;
			lnAnchoNoDeseado as integer, lnCantidadColumnasMasChicas as integer, loColumnas as object, llSeguir as boolean

		with this
			lnAncho = 0
			lnAnchoNoDeseado = toObjeto.AnchoColumnaNoDeseado

			llSeguir = .t.
			do while llSeguir
				lnAnchoTotalColumnasMasChicas = 0
				lnCantidadColumnasMasChicas = 0

				For lnColumna = 1 To .nCantidadColumnas
					loColumna = .aGrilla[ lnColumna ]
					lnAux = .ObtenerAnchoColumna( lnColumna )

					if lnAux < lnAnchoNoDeseado and !loColumna.lExtensible
						lnAnchoTotalColumnasMasChicas = lnAnchoTotalColumnasMasChicas + lnAux
						lnCantidadColumnasMasChicas = lnCantidadColumnasMasChicas + 1
					endif
				endfor
				
				lnAnchoNoDeseado = int ( ( toObjeto.AnchoReal - lnAnchoTotalColumnasMasChicas ) / ( .nCantidadColumnas - lnCantidadColumnasMasChicas ) )
				
				if lnAnchoTotalColumnasMasChicas == 0 or lnAnchoNoDeseado == lnAncho 
					llSeguir = .f.
				endif

				lnAncho = lnAnchoNoDeseado
			enddo
						
			toObjeto.Ancho = lnAncho
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoColumna( tnId as Integer ) as integer
		local loColumna as Object
		loColumna = this.aGrilla[ tnId ]
		
		return loColumna.oPrimerCampo.width + iif( isnull( loColumna.oEncabezado ), 1, 0 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AjustarTamaniosPorSuperposicion( toDatos as DatosColumnaParaAcomodar of zooGrillaExtensible.prg ) as Void

		local lnColumna as integer, loColumna as object, lcCampo as String, j as integer, ;
			loEncabezado as object, lnAnchoreal as integer, loCampo as object

		with this

			For lnColumna = .nCantidadColumnas to 1 step -1
				loColumna = .aGrilla[ lnColumna ]

				if ( loColumna.lExtensible or ( .ObtenerAnchoColumna( lnColumna ) > toDatos.Ancho and toDatos.CamposGrandes ) or toDatos.Todos )
					if isnull( loColumna.oEncabezado )
					else
						if .DebeUnirEncabezado( lnColumna )
							loColumna.oEncabezado.Width = toDatos.Ancho + .aGrilla[ lnColumna + 1 ].oPrimerCampo.Width + .nEspacioColumnas
						else
							loColumna.oEncabezado.Width = toDatos.Ancho
						endif
					endif
				
					*** Actualizo el tamaño de toda la fila
					for  j = 1 to .nCantidadItemsVisibles
						loCampo = this.ObtenerCelda( j, lnColumna ) 
						loCampo.Width = toDatos.Ancho
						loCampo.EsAjustable = .f.	&&Esto es para que el acomodador no reajuste el campo
					endfor
				endif
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReajustarUltimaColumnaPorSuperposicion() as boolean
		local lnColumna as integer, loColumna as object, lnAncho as integer, lndiferencia as Integer, ;
			lnAnchoReal as integer, llRetorno as boolean, lcCampo as string, lnFila as integer, loCampo as object
		
		with this
			llRetorno = .f.
			lnAncho = 0
			lnAnchoReal = .ObtenerAnchoReal()
			lnAncho = .ObtenerAnchoSumandoColumnas()
			lndiferencia = lnAnchoReal - lnAncho 
			if lndiferencia # 0
				llRetorno = .t.
				loColumna = .aGrilla[ .nCantidadColumnas ]
				if isnull( loColumna.oEncabezado )
					.aGrilla[ .nCantidadColumnas - 1 ].oEncabezado.Width = .aGrilla[ .nCantidadColumnas - 1 ].oEncabezado.Width + lndiferencia
				else
					loColumna.oEncabezado.Width = loColumna.oEncabezado.Width + lndiferencia
				endif

				For lnFila = 1 To .nCantidadItemsVisibles
					loCampo = this.ObtenerCelda( lnFila, .nCantidadColumnas )
					loCampo.Width = loCampo.Width + lndiferencia
				endfor
			endif
		endwith

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoReal() as integer
		local lnRetorno as integer
		with this
			lnRetorno = .Width - ( .nEspacioColumnas * ( .nCantidadColumnas + 1 ) ) - .MargenDer() - .BorderWidth
		endwith
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAnchoSumandoColumnas() as integer
		local lnRetorno as integer, lnColumna as integer

		with this
			lnRetorno = 0
			For lnColumna = 1 To .nCantidadColumnas
				loColumna = .aGrilla[ lnColumna ]
				lnRetorno = loColumna.oPrimerCampo.Width + lnRetorno 
*				lnRetorno = .ObtenerAnchoColumna( lnColumna ) + lnRetorno 
			endfor
		endwith
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CentrarSiEsNecesario() as Void
		with this
			if .width < .parent.width
				.left = ( .Parent.width / 2 ) - ( .width / 2 )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AjustarEncabezadoSegunCampo() as Void

		Local i As Integer, loColumna As Object

		With This

			For i = 1 To .nCantidadColumnas
				loColumna = .aGrilla[ i ]

				.aGrilla[ i ].nLeft = loColumna.oPrimerCampo.Left

				if isnull( loColumna.oEncabezado )
					.aGrilla[ i ].nWidth = loColumna.oPrimerCampo.Width				
				else

					if loColumna.oPrimerCampo.Width > loColumna.oEncabezado.Width
						loColumna.oEncabezado.Width = loColumna.oPrimerCampo.Width
					endif

					if .DebeUnirEncabezado( i )
						loColumna.oEncabezado.Width = .aGrilla[ i ].oPrimerCampo.Width + ;
											.aGrilla[ i + 1 ].oPrimerCampo.Width + .nEspacioColumnas
					endif
					.aGrilla[ i ].nWidth = loColumna.oEncabezado.Width
					loColumna.oEncabezado.Left = loColumna.oPrimerCampo.Left
				endif
			endfor	
			
		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function DebeUnirEncabezado( tnColumna as Integer ) as boolean
		return between( tnColumna, 1, this.nCantidadColumnas - 1 ) and ;
				!empty( this.aGrilla[ tnColumna ].oItem.ClaveForanea ) and ;
				( upper( right( alltrim( this.aGrilla[ tnColumna + 1 ].cAtributo ), 7 ) ) = "DETALLE" )
	endfunc
		
	*-----------------------------------------------------------------------------------------	
	protected function AlinearEncabezados() as Void
		Local i As Integer, loColumna As Object

		With This

			For i = 1 To .nCantidadColumnas
				loColumna = .aGrilla[ i ]
				if isnull( loColumna.oEncabezado )
				else
					if ( inlist( loColumna.oItem.tipodato , "N", "D" ) or upper( alltrim( loColumna.oItem.Dominio ) ) == "HORA" ) and empty( loColumna.oItem.claveforanea )
						loColumna.oEncabezado.AlinearTexto( "D" )
					else
						loColumna.oEncabezado.AlinearTexto( "I" )
					endif
				endif
			endfor	
			
		endwith	

	endfunc 

***********************************************************************************
**** FUNCIONES QUE SE EJECUTAN DESDE ESTILOS
	*-----------------------------------------------------------------------------------------
	function AplicarEstilo( toEstilo as estilos of estilos.prg ) as Void
		local lnColumna as Integer, loColumna as Object , llPrimerDetalle as boolean			
		dodefault( toEstilo )
		
		llPrimerDetalle = .t.

		*** Setea el ancho de todas las descrpciones de claves primarias, empezando de la izquierda, a partir de la segunda
		*** La primer descripcion (por lo general es la de articulo) no se pone fija, asi el acomodador la ajusta al
		*** tamaño maximo posible
		
		with this
			For lnColumna = 1 To .nCantidadColumnas
				loColumna = .aGrilla[ lnColumna ]

				if right( upper( alltrim( loColumna.cAtributo ) ), 7 ) == "DETALLE"
					if llPrimerDetalle
					else
						.SetearAnchoColumnaSecundaria( lnColumna, toEstilo )
					endif
					llPrimerDetalle = .f.
				endif
							
				.SetearAnchoCampoConAnchoEncabezado( lnColumna )
			Endfor

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function SetearAnchoColumnaSecundaria( tnColumna as object, toEstilo as estilos of estilos.prg  ) As Void
		local lnAncho as Integer, j as Integer, lcCampo as String, loCampo as object
		
		with this
			lnAncho = toEstilo.calcularanchoenpixeles( .nAnchoColumnaSecundaria )

			if type( "this.aGrilla[ tnColumna ].oEncabezado" ) = "O"
				.aGrilla[ tnColumna ].oEncabezado.Width = lnAncho
			endif
			
			for  j = 1 to .nCantidadItemsVisibles
				loCampo = this.ObtenerCelda( j, tnColumna ) 
				loCampo.Width = lnAncho
				loCampo.EsAjustable = .f.	&&Esto es para que el acomodador no reajuste el campo. Solo ajusta el primer detalle
			endfor
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected Function SetearAnchoCampoConAnchoEncabezado( tnColumna as object ) As Void
		local j as Integer, lcCampo as String, loColumna  as Object, loCampo as object

		with this
			loColumna = .aGrilla[ tnColumna ]
			
			*** si la columna tiene cabecera asociada y si la cabecera es mas grande que la columna, entonces se ajusta la columna
			
			if !isnull( loColumna.oEncabezado ) and loColumna.oPrimerCampo.Width < loColumna.oEncabezado.Width
				if tnColumna < .nCantidadColumnas and isnull( .aGrilla[ tnColumna + 1 ].oEncabezado )
				else
					for  j = 1 to .nCantidadItemsVisibles
*						lcCampo = ".Campo_" + alltrim( transform( tnColumna ) ) + "_" + alltrim( transform( j ) ) 
*						&lcCampo..Width = loColumna.oEncabezado.Width
						loCampo = this.ObtenerCelda( j, tnColumna ) 
						loCampo.Width = loColumna.oEncabezado.Width
					endfor
				endif
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function MargenDer() As Integer
		Local lnRetorno As Integer

		lnRetorno = This.nAnchoBarraDesplazamiento

		Return lnRetorno
	Endfunc


***********************************************************************************
**** FUNCIONES DE SCROLL
	*-----------------------------------------------------------------------------------------
	function MoverArriba( tnCant as Integer ) as boolean
		local i as Integer, j as Integer, llVisible as Boolean, lnTopSiguiente as Integer ;
			,lnTopAuxiliar as integer, loCampo as object, llRetorno as boolean
		
		llRetorno = .f.

		if vartype( tnCant ) # "N"
			tnCant = 1
		endif
		with this
			if tnCant > 0
				if .nRegistroInicioPantalla > tnCant
					.nRegistroInicioPantalla = .nRegistroInicioPantalla - tnCant
					for i = 1 to .nCantidadItemsVisibles
						.ActualizarFilaGrilla( i )
						.CalcularAncho( null, i )
						.CambiarColorDeFondoFila( i )
					endfor
					thisform.oKontroler.DespuesDeMover()
					llRetorno = .t.
				endif
			endif
		endwith
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFilasAEscrolearArriba( tnCant as Integer ) as integer
		with this
			if .nRegistroInicioPantalla - tnCant < 1
				tnCant = .nFilaActiva - 1
			endif
		endwith
		return tnCant
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MoverAbajo( tnCant as Integer ) as integer
		local i as Integer, j as Integer, llVisible as Boolean, lnTopAnterior as Integer ;
			,lnTopAuxiliar as integer, lnFilaActual as integer, lnRegistroFinPantalla as integer ;
			, loCampo as object, llRetorno as boolean

		llRetorno = .f.

		if vartype( tnCant ) # "N"
			tnCant = 1
		endif
		
		with this
			if tnCant > 0
				if .nCantidadFilas > tnCant + .nFilaActiva - 1 and ( .nRegistroInicioPantalla + .nCantidadItemsVisibles <= .nCantidadFilas )
					.nRegistroInicioPantalla = .nRegistroInicioPantalla + tnCant 
					for i = 1 to .nCantidadItemsVisibles
						.ActualizarFilaGrilla( i )
						.CalcularAncho( null, i )
						.CambiarColorDeFondoFila( i )
					endfor
					thisform.oKontroler.DespuesDeMover()
					llRetorno = .t.
				endif
			endif
		endwith

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFilasAEscrolearAbajo( tnCant as Integer ) as integer
		with this
			if .nFilaActiva + tnCant > .nCantidadFilas
				tnCant = .nCantidadFilas - .nFilaActiva
			endif
		endwith
		return tnCant
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LostFocus() as Void

		local lnFilaActivaAnt as Integer, loError as Exception

		with this
			.CalcularAncho( This.oCampoAnterior )
			if .nFilaActiva > 0 and (type( "thisform.okontroler.cAccion" ) = "U" or ;
				(type( "thisform.okontroler.cAccion" ) != "U" and  upper(alltrim( thisform.okontroler.cAccion ) ) != "ESCAPAR"))
				try
					if thisform.oKontroler.ActualizarDetalle( .cAtributo, .nFilaActiva )
					
						lnFilaActivaAnt = .nFilaActiva - ( this.nRegistroInicioPantalla - 1 )
						.nFilaActiva = 0
						.ActualizarFilaGrilla( lnFilaActivaAnt ) &&, .t. )
				
						.oBarraDeEstado.SetearTituloEtiqueta( "" )
						.nCantidadEnterVacios = 0
					else
						This.lMalLostFocus = .T.
						if vartype( .oCampoAnterior ) = "O"
							.oCampoAnterior.setfocus()
						else
							this.setfocus()
						endif
					endif
				catch to loError 
					This.lMalLostFocus = .T.
				endtry
			endif
		endwith
	
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiarDeFila( tnFilaNueva as integer ) as boolean
		local llValidacion as boolean, lnFilaActivaAnt as integer, i as integer

		with this
			llValidacion = .t.

			lnFilaActivaAnt = .nFilaActiva - ( .nRegistroInicioPantalla - 1 )
			if between( lnFilaActivaAnt , 1, .nCantidadItemsVisibles )
			else
				lnFilaActivaAnt = 0
			endif

			if tnFilaNueva + .nRegistroInicioPantalla - 1 > .nCantidadFilas
				llValidacion = .f.
			else

				if vartype( .oEntidad ) = "O" and lnFilaActivaAnt  # tnFilaNueva
					if lnFilaActivaAnt > 0
						.CalcularAncho( "", lnFilaActivaAnt )
					endif

					if .nFilaActiva > 0
						llValidacion = thisform.oKontroler.ActualizarDetalle( .cAtributo, .nFilaActiva )
					endif

					if llValidacion
						thisform.oKontroler.SetearItemActivo( .cAtributo, tnFilaNueva + ( .nRegistroInicioPantalla - 1 ) )

						.nFilaActiva = tnFilaNueva + ( .nRegistroInicioPantalla - 1 )

						if lnFilaActivaAnt > 0
							.ActualizarFilaGrilla( lnFilaActivaAnt )
						endif
						.ActualizarFilaGrilla( tnFilaNueva )

						.SetearEstadoFilaActiva()
					endif
				endif
			endif
		endwith
		
		return llValidacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoFilaActiva() as void
		local lcEtiqueta as String, lcAgrupados As String
		with this
			.oBarraDeDesplazamiento.SetearValor( .nFilaActiva )
			lcEtiqueta = "Fila: " + alltrim(str( .nFilaActiva ) )
			lcAgrupados = This.ObtenerLineasFaltantesImpresion()
			lcEtiqueta = lcEtiqueta + iif( empty( lcAgrupados ), "", "    " ) + alltrim( lcAgrupados )	
			.oBarraDeEstado.SetearTituloEtiqueta( lcEtiqueta )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLineasFaltantesImpresion() as String

		local lcRetorno as String, lcTipoDetalle as String, lnDisponibles as Integer, loDetalle as Object
		lcTipoDetalle = this.cAtributo
		lcRetorno = ""
		if vartype( this.oEntidad ) = "O"
			loDetalle = this.oEntidad.&lcTipoDetalle
			if loDetalle.nTipoDeValidacionSegunDisenoImpresion > 0
				lnDisponibles = loDetalle.nLimiteSegunDisenoImpresion  - loDetalle.nCantidadDeItemsCargados
				lcRetorno = "Disponibles para impresión: " + transform( lnDisponibles )
			EndIf
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SePuedeHacerFoco( toCampo as object ) as boolean
		local llRetorno as boolean, lnFil as Integer, lnCol as Integer, lnFilAct as integer, lcDet as string

		lnFil = toCampo.nFila + ( this.nRegistroInicioPantalla - 1 )
		lnCol = toCampo.nColumna
		lnFilAct = this.nFilaActiva
		lcDet = this.cAtributo
		llRetorno = .t.
		if toCampo.SePuedeHabilitar()
			with thisform.oKontroler
				if toCampo.nFila <= this.nCantidadFilas
					if this.ObtenerPrimerColumnaAccesible( toCampo.nFila, lnCol + 1 ) - 1 < lnCol
						if lnFil = lnFilAct or .CantidadDeItems( lcDet ) >= lnFil
							lnFil = iif( lnFil = lnFilAct, 0, lnFil )
							llRetorno = .ValidarExistenciaCamposFijos( lcDet, lnFil ) and ;
											.CondiciondeFoco( lcDet, lnFil, lnCol ) and !This.TieneSaltoDeCampoDefinidoPorElUsuario( lnCol )
						else
							llRetorno = .f.
						endif
					else
						if lnFil = lnFilAct or .CantidadDeItems( lcDet ) >= lnFil
							lnFil = iif( lnFil = lnFilAct, 0, lnFil )
							llRetorno = .VerificarCondicionDeFocoPrimeraColumnaAccesible( lcDet, lnFil )
						Endif
					endif
				else
					llRetorno = .f.
				endif
			endwith
		else
			llRetorno = .f.
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneSaltoDeCampoDefinidoPorElUsuario( tnColumna as Integer ) as Boolean
		local llRetorno as Boolean, loCampo as Object
		loCampo = this.aGrilla[ tnColumna + 1 ]
		llRetorno = goServicios.SaltosDeCampoyValoresSugeridos.DebeSaltarElCampo( This.oEntidad.ObtenerNombre() ,  this.cAtributo, loCampo.cAtributo )

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrimerColumnaAccesibleEnRango( tnFila as Integer, tnDesde as integer, tnHasta ) as integer
		local lnRetorno as Integer, lnI as integer, loCampo as object

		lnRetorno = tnDesde 
		
		with this
			for lnI = tnDesde to tnHasta 
				loCampo = this.ObtenerCelda( tnFila, lnI )

				if loCampo.enabled and this.SePuedeHacerFoco( loCampo )
					lnRetorno = lnI
					exit
				endif
			endfor
		endwith
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrimerColumnaAccesible( tnFilaVisible as Integer, tnColumnaActual as integer ) as integer
		local lnRetorno as Integer, lni as integer, loCampo as object

		lnRetorno = 1
		
		with this
			for lni = 1 to .nCantidadColumnas
				if !empty( tnColumnaActual ) and lni >= tnColumnaActual
					lnRetorno = tnColumnaActual
					exit
				endif
				
*				loCampo = evaluate( "this.Campo_" + transform( lni ) + "_" + transform( tnFilaVisible ) )
				loCampo = this.ObtenerCelda( tnFilaVisible, lni )

				if loCampo.enabled and .SePuedeHacerFoco( loCampo )
					lnRetorno = lni
					exit
				endif
			endfor
		endwith
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerUltimaColumnaAccesible( tnFilaVisible as Integer, tnColumnaActual as integer ) as integer
		local lnRetorno as Integer, lni as integer, loCampo as object

		lnRetorno = this.nCantidadColumnas
		
		with this
			for lni = .nCantidadColumnas to 1 step -1
				loCampo = this.ObtenerCelda( tnFilaVisible, lni )

				if !empty( tnColumnaActual ) and  lni =< tnColumnaActual
					lnRetorno = tnColumnaActual
					exit
				endif
		
				if loCampo.enabled and .SePuedeHacerFoco( loCampo )
					lnRetorno = lni
					exit
				endif
			endfor

		endwith
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PrimerCampoFila( tnFila as Integer ) as object
		local loRetorno as Object, lcCampo as String, loCampo as object
		loRetorno = null
		loCampo = this.ObtenerCelda( tnFila, 1 )
		if !isnull( loCampo )
			loRetorno = loCampo
		endif
		
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarDatosItemActivo( toControl as Object ) as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDescripcion( toControl as Object ) as voind
		local j as integer, loCampo as object, lcAtributo as string, lxValor as variant, lcAtributoRel as String, lxValor as Variant, lxValorAnt as variant
		local llContinua as Boolean
		llContinua = .t.
		lxValorAnt =  toControl.xValorAnterior
		if !isnull( lxValorAnt ) and vartype( lxValorAnt ) = "C"
			lxValorAnt = alltrim( lxValorAnt )
		endif
 
		lxValor =  toControl.Value
		if vartype( lxValor ) = "C"
			lxValor = alltrim( lxValor )
			if left(lxvalor,1) = "$"
				llContinua = .f.
			endif 
		endif

		if toControl.lEsSubEntidad and !empty( toControl.cAtributoPadre ) and ( isnull( lxValorAnt ) or lxValorAnt != lxValor  ) and llContinua 
			With This
				loCampo = null
				j = 1
				do while j <= .nCantidadColumnas and isnull( loCampo )
					lcAtributo = upper( alltrim( toControl.cAtributoPadre ) + "Detalle" )
					if upper( alltrim( .aGrilla[ j ].cAtributo ) ) == lcAtributo
						loCampo = this.ObtenerCelda( toControl.nFila, j )
					endif
					j = j+1
				enddo
				
				if isnull( loCampo )
				else
					lcAtributoRel = alltrim( toControl.cAtributoMuestraRelacion )
					lxValor = toControl.oEntidad.&lcAtributoRel

					loCampo.SetearValorEnElAtributo( iif( vartype( lxValor ) = "C", alltrim( lxValor ), lxValor ) )
					loCampo.zorder( 0 )
					.CalcularAncho( toControl )
				endif
				
			endwith
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearColoresDeFondo( toControl as object )
		with toControl
			.nBackColorClaro = .BackColor - 3084
			.nDisabledBackColorClaro = .DisabledBackColor - 657930
			.nBackColorNormal = .BackColor
			.nDisabledBackColorNormal = .DisabledBackColor
		endwith
		
		this.CambiarColorDeFondo( toControl )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarColorDeFondo( toControl as object )
		local lnBackColor, lnDisabledBackColor

		with toControl
			If Mod( .nFila + ( this.nRegistroInicioPantalla - 1 ) , 2 ) = 0
				lnBackColor = .nBackColorClaro
				lnDisabledBackColor = .nDisabledBackColorClaro
			else
				lnBackColor = .nBackColorNormal
				lnDisabledBackColor = .nDisabledBackColorNormal
			endif

			.nBackColorSinFoco = lnBackColor
			if .BackColor != .nBackColorConFoco
				.BackColor = lnBackColor
			endif
			.DisabledBackColor = lnDisabledBackColor
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearValorAtributo( toControl as object, txValor as Variant ) as Void
		local lcAtributo

		with toControl
			if empty( .cAtributoPadre )
				lcAtributo = this.cAtributo + "_" + .cAtributo
			else
				if .lClavePrimaria
					lcAtributo = alltrim( this.cAtributo ) + "_" + alltrim( .cAtributoPadre ) + "_PK"
				else
					lcAtributo = alltrim( this.cAtributo ) + "_" + alltrim( .cAtributoPadre ) + "_" + alltrim( .cAtributo )
				endif
			endif
		endwith
		
		thisform.oKontroler.&lcAtributo = txValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorAtributo( toControl as Object ) as variant
		local loControlActivo as object, lxRetorno as variant, lnItemActivo as integer
		lxRetorno = null
		with toControl
			if vartype( .oEntidad ) = "O" and vartype( thisform.oKontroler ) = "O"
				lnItemActivo = thisform.oKontroler.ObtenerNumeroItemActivo( this.cAtributo )
				if Thisform.oKontroler.CantidadDeItems( this.cAtributo ) > 0
					if ( this.nFilaActiva # 0 and .nFila = lnItemActivo - ( this.nRegistroInicioPantalla - 1 ) ) or ;
						 ( lnItemActivo = 0 and .nFila = this.nFilaActiva - ( this.nRegistroInicioPantalla - 1 ) )

						lxRetorno = thisform.oKontroler.ObtenerValorAtributoItemActivo( this.cAtributo, toControl )
						Thisform.oKontroler.VerificarFormateosDeLaFilaActiva( this.cAtributo, toControl )
					else
						lxRetorno = thisform.oKontroler.ObtenerValorAtributoPlano( this.cAtributo, toControl, this.nRegistroInicioPantalla )
						Thisform.oKontroler.VerificarFormateosDeLaFilaPlana( this.cAtributo, toControl, this.nRegistroInicioPantalla )
					endif
				else
					if lnItemActivo = 0 and this.nFilaActiva - ( this.nRegistroInicioPantalla - 1 ) > 0 
						if .nFila = this.nFilaActiva - ( this.nRegistroInicioPantalla - 1 )
							lxRetorno = thisform.oKontroler.ObtenerValorAtributoItemActivo( this.cAtributo, toControl )
							Thisform.oKontroler.VerificarFormateosDeLaFilaActiva( this.cAtributo, toControl )						
						else
							lxRetorno = thisform.oKontroler.ObtenerValorAtributoPlano( this.cAtributo, toControl, this.nRegistroInicioPantalla )
							Thisform.oKontroler.VerificarFormateosDeLaFilaPlana( this.cAtributo, toControl, this.nRegistroInicioPantalla )
						endif
 					endif
 				endif
			endif
		endwith
	
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoControl( toControl as Object, tnRetorno as integer ) as integer
		local lnRetorno as integer, loCampo as object, lcAtributo as string, loUltimoCampo as object, ;
			lnColumnas as integer
		
		lnRetorno = tnRetorno
		
		if empty( tocontrol.cAtributoPadre )
			lcAtributo = toControl.cAtributo
		else
			lcAtributo = toControl.cAtributoPadre
		endif

		with toControl
			this.cScroleo = ""
			loCampo = this.ObtenerSiguienteCampo( toControl )
			if this.VerificarSalidaDeLaGrilla( lcatributo ) or this.nCantidadFilas < loCampo.nFila
				loUltimoCampo = this.ObtenerUltimoCampo()
				if isnull( loUltimoCampo )
				else
					lnRetorno = loUltimoCampo.TabIndex - .TabIndex + this.nOffsetSalida
				endif
			else
				if loCampo # toControl					&& si son iguales entocnes se mueve por la misma fila
					lnRetorno = loCampo.tabindex - .TabIndex
				endif
				this.ResolverScroll( toControl, loCampo, lnRetorno )
			endif
		endwith

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSiguienteCampo( toObjeto as object ) as Object
		local lcCampo as String, lnNuevaFila as integer ;
			, lnLargoTexto as string, loCampo as object, lnNuevaColumna as integer ;
			, loItem as object

	
		lnKeyCode = thisform.nKeyCode
		lnShiftAltCtrl = thisform.nShiftAltCtrl

		lnNuevaFila = this.ObtenerNuevaFila( toObjeto )

		lnNuevaColumna = 0
		loCampo = null

		if lnNuevaFila > this.nCantidadItemsVisibles or lnNuevaFila < 1
			loCampo = toObjeto
		else
			lnNuevaColumna = this.ObtenerNuevaColumna( lnNuevaFila, toObjeto )
			loCampo = this.ObtenerCelda( lnNuevaFila, lnNuevaColumna )
		endif
		
		return loCampo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNuevaFila( toObjeto as object ) as Integer
		local lnRetorno as integer, lnKeyCode as integer, lnShiftAltCtrl as integer, llCantidadEnterVacios as boolean
		lnKeyCode = thisform.nKeyCode
		lnShiftAltCtrl = thisform.nShiftAltCtrl
		llCantidadEnterVacios = .f.

		lnRetorno = toObjeto.nFila

		do case
			case lnKeyCode = 13 &&ENTER
				if thisform.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo )
				else
					if !thisform.oKontroler.lHuboCargaAutomatica
						llCantidadEnterVacios = .t.
					endif
					lnRetorno = toObjeto.nFila + 1
				endif

			case lnKeyCode = 24 &&FLECHA ABAJO
				lnRetorno = toObjeto.nFila + 1

			case lnKeyCode = 4 &&FLECHA DERECHA
				if thisform.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo )
				else
					lnRetorno = toObjeto.nFila + 1
				endif

			case lnKeyCode = 9 or lnKeyCode = 15 &&TABULACION
				if lnShiftAltCtrl = 1
					if this.ObtenerPrimerColumnaAccesible( toObjeto.nFila, toObjeto.nColumna + 1 ) - 1 = toObjeto.nColumna or ;
									!thisform.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo )
									
						lnRetorno = toObjeto.nFila - 1
					endif
				else
					if thisform.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo )
					else
						lnRetorno = toObjeto.nFila + 1
					endif
				endif

			case lnKeyCode = 5 &&FLECHA ARRIBA
				lnRetorno = toObjeto.nFila - 1

			case lnKeyCode = 19 &&FLECHA IZQUIERDA
				if this.ObtenerPrimerColumnaAccesible( toObjeto.nFila, toObjeto.nColumna + 1 ) - 1 = toObjeto.nColumna or ;
									!thisform.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo )

					lnRetorno = toObjeto.nFila - 1
				endif

***** esto es de la historia del PAGE DOWN
			case lnKeyCode = 18 &&RE PÁG
				if toObjeto.nFila = 1 and this.nRegistroInicioPantalla > 1
					lnRetorno = toObjeto.nFila - 1
				else
					lnRetorno = 1
				endif

			case lnKeyCode = 3	&&AV PÁG
				if toObjeto.nFila = this.nCantidadItemsVisibles
					lnRetorno = toObjeto.nFila + 1
				else
					lnRetorno = this.nCantidadItemsVisibles
				endif
		endcase

		if llCantidadEnterVacios
			this.nCantidadEnterVacios = this.nCantidadEnterVacios + 1
		else
			this.nCantidadEnterVacios = 0
		endif

		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNuevaColumna( tnNuevaFila as Integer, toObjeto as object ) as integer
		local lnRetorno as integer, lnFila as Integer
		
		with this
			lnRetorno = this.ObtenerPrimerColumnaAccesible( tnNuevaFila, 0 )
	
			if toObjeto.nFila # tnNuevaFila 

				lnFila = tnNuevaFila + ( .nRegistroInicioPantalla - 1 )
				if Thisform.oKontroler.CantidadDeItems( .cAtributo ) >= lnFila 

					if thisform.oKontroler.ValidarExistenciaCamposFijos( .cAtributo, lnFila ) and ;
							thisform.oKontroler.CondiciondeFoco( .cAtributo, lnFila, toObjeto.nColumna )
					
						lnRetorno = toObjeto.nColumna + 1
					endif
				endif

			else
				if thisform.oKontroler.ValidarExistenciaCamposFijos( .cAtributo ) and ;
								thisform.oKontroler.CondiciondeFoco( .cAtributo, 0, toObjeto.nColumna )

					lnRetorno = toObjeto.nColumna + 1
				endif

			endif
		endwith
		
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarSalidaDeLaGrilla( tcAtributo as String ) as boolean
		local llRetorno as boolean
		
		llRetorno = this.nCantidadEnterVacios = 2 or ;
			thisform.oKontroler.SalirdeLaGrilla( this.cAtributo, tcAtributo )
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoCampo() as Void
		local lnNuevaColumna as Integer, lnNuevaFila as Integer, loRetorno as object, lcCampo as string

		loRetorno = null
		with this
			lnNuevaColumna = .nCantidadColumnas
			lnNuevaFila = .nCantidadItemsVisibles

			loRetorno = this.ObtenerCelda( lnNuevaFila, lnNuevaColumna )
		endwith
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Scrolear( tnRetorno as integer, toControl as Object ) as integer
		local llscroleo as boolean, lntot
		with this

			llScroleo = this.ScrolearAux( tnRetorno, toControl )
			if llscroleo
				tnRetorno = .CalcularRetornoSegunScroleo( toControl, tnRetorno )
				if tnRetorno >= 0
					thisform.nKeyCode = 0
					thisform.nShiftAltCtrl = 0
				endif

				.SetearEstadoFilaActiva()
			else
				if mod(tocontrol.nFila,.nCantidadItemsVisibles) = 0
					if tocontrol.ncolumna = 0 
						tnRetorno = 1
					else
						tnRetorno = -1
					endif 				
				else
					tnRetorno = -1
				endif 
			endif
			this.nCantidadDeFilasARetroceder = 0

		endwith

		return tnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ScrolearAux( tnRetorno as integer, toControl as object  ) as boolean
		***** esto es de la historia del PAGE DOWN
		local llRetorno as boolean, lnTot as integer, loError as Exception, loEx as Exception, llValorAnterior as boolean
		
		with this
			llValorAnterior = thisform.lockscreen 
			thisform.lockscreen = .t.
			try
				
				if empty( this.nCantidadDeFilasARetroceder )
					lnTot = 1
					if inlist( thisform.nKeyCode, 3, 18 )
						lnTot = .nCantidadItemsVisibles
					endif
				else
					lnTot = this.nCantidadDeFilasARetroceder
				endif

				if .cScroleo = "ABAJO"
					llRetorno = .ScrolearAbajo( toControl, lnTot )
				endif

				if .cScroleo = "ARRIBA"
					llRetorno = .ScrolearArriba( toControl, lnTot )
				endif
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			finally
				thisform.lockscreen = llValorAnterior 
			endtry
		endwith

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CalcularRetornoSegunScroleo( toControl as object, tnRetorno as integer ) as integer
		local lnPrimerColumnaAccesible as Integer, lnFilaAMoverse as Integer, lnColumna as Integer, lnPrimerCol as Integer
		lnPrimerColumnaAccesible = 0
		
		if this.nCantidadDeFilasARetroceder = 0
			lnPrimerCol = this.ObtenerPrimerColumnaAccesible( toControl.nFila, toControl.nColumna + 1 )
			if inlist( thisform.nKeyCode, 5, 24, 3, 18 )
				lnColumna = this.ObtenerNuevaColumna( toControl.nFila, toControl )
			else
				lnColumna = lnPrimerCol
			endif
			tnRetorno = lnColumna - ( toControl.nColumna + 1 )

			if tnRetorno = 0 and  !toControl.When()
				tnRetorno = -1
			endif
		else
			lnFilaAMoverse = toControl.nFila - this.nCantidadDeFilasARetroceder
			if lnFilaAMoverse > this.nCantidadItemsVisibles
				lnFilaAMoverse = this.nCantidadItemsVisibles
			endif
			
			lnColumna = toControl.nColumna + 2	
			lnPrimerColumnaAccesible = this.ObtenerPrimerColumnaAccesibleEnRango( lnFilaAMoverse, lnColumna, this.nCantidadColumnas )
			tnRetorno = tnRetorno - ( this.nCantidadColumnas - lnPrimerColumnaAccesible )
		endif

		return tnRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ScrolearAbajo( toControl as Object, tnCant as integer ) as boolean
		local llRetorno as boolean, llValidacion as boolean, lni as integer

		llRetorno = .f.
		with this
			lni = .ObtenerFilasAEscrolearAbajo( tnCant )
			if lni > 0
				llValidacion = thisform.oKontroler.ActualizarDetalle( .cAtributo, .nFilaActiva )
				if llValidacion
					if .MoverAbajo( lni )
						thisform.oKontroler.SetearItemActivo( .cAtributo, .nFilaActiva + lni )
						.nFilaActiva = .nFilaActiva + lni
						.RefrescarGrilla()
						llRetorno = .t.
					endif
				endif
			endif
		endwith
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ScrolearArriba( toControl as Object, tnCant as integer ) as Void
		local llRetorno as boolean, llValidacion as boolean, lni as integer
		
		llRetorno = .f.
		with this
			lni = .ObtenerFilasAEscrolearArriba( tnCant )
			if lni > 0
				llValidacion = thisform.oKontroler.ActualizarDetalle( .cAtributo, .nFilaActiva )
				if llValidacion
					if .MoverArriba( lni )
						thisform.oKontroler.SetearItemActivo( .cAtributo, .nFilaActiva - lni )
						.nFilaActiva = .nFilaActiva - lni
						.RefrescarGrilla()
						llRetorno = .t.
					endif
				endif
			endif
		endwith
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ResolverScroll( toControl as object, toProximoControl as object, tnRetorno as integer ) as void
		local lnUltimaCol as Integer, lnPrimerCol as Integer
		
		lnUltimaCol = this.ObtenerUltimaColumnaAccesible( toControl.nFila, toControl.nColumna + 1 ) - 1
		lnPrimerCol = this.ObtenerPrimerColumnaAccesible( toControl.nFila, toControl.nColumna + 1 ) - 1

		with thisform
			this.cScroleo = ""
			
			if this.nCantidadDeFilasARetroceder > 0
				this.cScroleo = "ABAJO"
			else
				if toControl = toProximoControl	&&el procimo control al que se mueve es el mismo que el actual
					goControles.SetearColoresEnControl( toControl )
					if toControl.nFila = this.nCantidadItemsVisibles and ;	&&Esta parado en la ultima fila
						tnRetorno > 0										&&Se movio hacia adelante
						
						if .nKeyCode = 24 or ;								&&se movio para abajo
							toControl.nColumna = lnUltimaCol or ;	&&esta en la ultima columna
							( toControl.nColumna = lnPrimerCol and !.oKontroler.ValidarExistenciaCamposFijos( this.cAtributo ) )	&&esta en la primer columna y el campo fijo esta vacio

							if ( toControl.nColumna = lnUltimaCol and !empty( .nKeyCode ) ) or ;
									inlist( .nKeyCode, 13, 24, 4 ) or ( inlist( .nKeyCode, 9, 15 ) and .nShiftAltCtrl # 1 ) && ENTER, DERECHA, TAB, ETC
			
								this.cScroleo = "ABAJO"
							endif
						endif

						if .nKeyCode = 3 &&page down
							this.cScroleo = "ABAJO"
						endif
					endif
									
					if toControl.nFila = 1 and ;			&&esta parado en la primer fila
						tnRetorno < 0						&&se mueve hacia atras
						
						if .nKeyCode = 5 or toControl.nColumna = lnPrimerCol &&Movio para arriba o esta parado en la primer columna
							if inlist( .nKeyCode, 5, 19 ) or ( inlist( .nKeyCode, 9, 15 ) and .nShiftAltCtrl = 1 ) &&IZQUIERDA, ARRIBA, ETC
								this.cScroleo = "ARRIBA"
							endif
						endif

						if .nKeyCode = 18 &&page up
							this.cScroleo = "ARRIBA"
						endif
					endif
				endif
			endif
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function MostrarEtiquetaFilaInicial() as Void
		local lntop as integer, lnAltoBoton as integer

		with this.oToolTip
			if this.lMostrar
				.Caption = " Fila " + transform( this.nRegistroInicioPantalla ) + " "

				with this.oBarraDeDesplazamiento
					lnAltoBoton = 24
					lntop = ( .Max - .Min ) * .oBarra.Value / 100 * ( this.parent.Height - ( lnAltoBoton * 2 ) ) / 100 + lnAltoBoton 
				endwith
				.top = lnTop
				.Visible = .t.

				.zorder( 0 )
				.left = this.oBarraDeDesplazamiento.Left - .width - 5
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function MouseMove( nButton, nShift, nXCoord, nYCoord ) as Void
		if this.lMostrar
			if between( nXCoord, this.oBarraDeDesplazamiento.left, this.oBarraDeDesplazamiento.left + this.oBarraDeDesplazamiento.width ) and ;
					between( nYCoord, this.oBarraDeDesplazamiento.top, this.oBarraDeDesplazamiento.top + this.oBarraDeDesplazamiento.height )

				this.MostrarEtiquetaFilaInicial()
			else
				this.oToolTip.visible = .f.
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MouseLeave( nButton, nShift, nXCoord, nYCoord ) as Void
		if this.lMostrar
			this.oToolTip.visible = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MoverAUltimoCampo() as Void
		local loControl as object, lnColumna as Integer, lnFila as integer, lnCantItems as integer

		with this
			lnCantItems = Thisform.oKontroler.CantidadDeItems( .cAtributo )
			if lnCantItems >= .nCantidadItemsVisibles
				.MoverAbajo( lnCantItems - .nCantidadItemsVisibles + 1 )
				lnFila = .nCantidadItemsVisibles
			else
				if lnCantItems >= .nCantidadFilas
					lnFila = .nCantidadFilas
				Else
					lnFila = lnCantItems + 1
				EndIf	
			endif
			lnColumna = .ObtenerPrimerColumnaAccesible( lnFila, 0 )
			loControl = this.ObtenerCelda( lnFila, lnColumna )

			loControl.SetFocus()
			loControl = Null
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCampoDeFilaActivaPorAtributo( tcAtributo as String ) as Void
		return this.ObtenerCampoPorAtributo( this.nFilaActiva, tcAtributo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCampoPorAtributo( tnFila as Integer, tcAtributo as String ) as Void
		local loRetorno as object, lcCampo as string, i as Integer, lcAtributo as String
		
		lcAtributo = alltrim( lower( tcAtributo ) )
		loRetorno = null
		with this
			if tnFila <= .nCantidadItemsVisibles
				i = .nCantidadColumnas
				do while i != 0 and isnull( loRetorno )
					lcCampo = "." + this.ObtenerNombreCelda( tnFila, i  )
					
					do case
						case type( lcCampo + ".cAtributoPadre" ) = "C" ;
							and lower( alltrim( evaluate( lcCampo + ".cAtributoPadre" ) ) ) == lcAtributo
							loRetorno = &lcCampo	
						case type( lcCampo + ".cAtributo" ) = "C" ;
							and lower( alltrim( evaluate( lcCampo + ".cAtributo" ) ) ) == lcAtributo
							loRetorno = &lcCampo
					endcase	
					i = i - 1
				enddo
			endif
		endwith
		
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarCantidadDeFilas( tnNuevaCantidadDeFilas as Integer ) as Void
		local lnPixelesAAjustar as Integer, llLockScreen as Boolean, lnFilasARetroceder as Integer, ;
			lnCantidadItemVisiblesAnteriores as Integer
		lnFilasARetroceder = 0
		
		if This.nCantidadItemsVisibles # tnNuevaCantidadDeFilas
			
			if tnNuevaCantidadDeFilas > this.nCantidadMaximaItemsVisibles
				goServicios.Errores.LevantarExcepcion( "El detalle " + this.cAtributo + " no puede tener más de " + transform( this.nCantidadMaximaItemsVisibles ) + " filas visibles." )
			endif
		
			try
				llLockScreen = Thisform.Lockscreen
				Thisform.Lockscreen = .t.

				lnFilaActiva = this.nFilaActiva - ( this.nRegistroInicioPantalla - 1 )
				if lnFilaActiva > tnNuevaCantidadDeFilas
					lnFilasARetroceder = lnFilaActiva - tnNuevaCantidadDeFilas
				endif

				lnPixelesAAjustar = This.ObtenerPixelesAAjustar( tnNuevaCantidadDeFilas )
				lnCantidadItemVisiblesAnteriores = This.nCantidadItemsVisibles
				This.nCantidadItemsVisibles = tnNuevaCantidadDeFilas
				This.Height = ( this.nAltoOriginal - lnPixelesAAjustar )
				This.oBarraDeDesplazamiento.Height = This.Height
				This.oBarraDeDesplazamiento.oBarra.Height = This.Height
				This.oBarraDeDesplazamiento.oBarra.LargeChange = This.nCantidadItemsVisibles
				This.oBarraDeEstado.Top = this.ObtenerTopBarraDeEstado()
				this.OcultarMostrarCampos( 1, .t. )
				this.OcultarMostrarCampos( tnNuevaCantidadDeFilas + 1, .f. )

				do case
					case lnFilasARetroceder > 0
						this.nCantidadDeFilasARetroceder = lnFilasARetroceder
					case lnCantidadItemVisiblesAnteriores < This.nCantidadItemsVisibles
						if Thisform.oKontroler.CantidadDeItems( this.cAtributo ) > 0
							this.RefrescarGrilla()
						endif
						this.RefrescarColorDeFondoFilas()
				endcase

			finally
				Thisform.Lockscreen = llLockScreen
			endtry
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTopBarraDeEstado() as Integer
		local lnRetorno as Integer, loCampo as Object
		loCampo = this.ObtenerCelda( this.nCantidadItemsVisibles, 1 )
		lnRetorno = loCampo.Top + loCampo.Height + this.nEspacioFilas
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPixelesAAjustar( tnCantidadFilasVisibles as Integer ) as Integer
		local lnRetorno as Integer, lnAltoFila as Integer, lnDiferenciaDeFilas as Integer, loCampo as Object
		lnRetorno = 0
		loCampo = this.ObtenerCelda( 1, 1 )
		lnAltoFila = loCampo.Height + this.nEspacioFilas
		lnDiferenciaDeFilas = this.nCantidadMaximaItemsVisibles - tnCantidadFilasVisibles
		lnRetorno = ( lnAltoFila * lnDiferenciaDeFilas )
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function OcultarMostrarCampos( tnFilaInicial as integer, tlVisible as String ) as void
		local lnFila as Integer, lnColumna as Integer, loCampo as Object
		for lnFila = tnFilaInicial to this.nCantidadMaximaItemsVisibles
			for lnColumna = 1 to this.nCantidadColumnas
				loCampo = this.ObtenerCelda( lnFila, lnColumna )
				loCampo.Visible = tlVisible
			endfor
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RefrescarColorDeFondoFilas() as void
		local lnFila as Integer
		for lnFila = 1 to this.nCantidadItemsVisibles
			this.CambiarColorDeFondoFila( lnFila )
		endfor
	endfunc
	*-----------------------------------------------------------------------------------------
	function GotFocus() as Void
		local loDetalle as Object, lcDetalle as String
		lcDetalle = This.cAtributo
		loDetalle = This.oEntidad.&lcDetalle.
		if loDetalle.lVerificarLimitesEnDisenoImpresion
			This.oEntidad.EventoVerificarLimitesEnDisenoImpresion( This.cAtributo )
		Endif	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearEstadoFilaActivaDesdeEnBaseA() as Void
		this.SetearEstadoFilaActiva()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AjustarAnchoPosPrepantalla() as Void
	local i as Integer 
	with this
		for i = 1 to .nCantidadItemsVisibles
			.CalcularAncho( null, i )
		endfor
	endwith 	


	endfunc 
	
Enddefine

*-----------------------------------------------------------------------------------------
define class TextboxSinFoco as textbox

	TabStop = .f.
	nColumna = 0
	nFila = 0
	visible = .t.
	top = -100
	left = -100

	function LostFocus
		if this.parent.lMostrar	
			this.Parent.oToolTip.Visible = .f.
		endif
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
define class TooltipNumeroDeFila as label
	nColumna = 0
	nFila = 0
	visible = .f.
	BackColor = rgb( 255, 255, 128 )
	Autosize = .t.
enddefine

*-----------------------------------------------------------------------------------------
define class ItemColumnaGrilla as zooSession of zooSession.prg
	lExtensible = .f.
	nOffset = 0
	oEncabezado = null
	oPrimerCampo = null
	nLeft = 0
	nWidth = 0
	lSePuedeSuperponer = .f.
	cTitulo = ""
	cTituloCorto = ""
	cAtributo = ""
	oItem = null
enddefine

*-----------------------------------------------------------------------------------------
define class DatosColumnaParaAcomodar as custom
	Ancho = 0
	AnchoReal = 0
	AnchoColumnaNoDeseado = 0
	Todos = .f.
	CamposGrandes = .f.
enddefine