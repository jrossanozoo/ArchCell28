define class Estilos as ZooSession of ZooSession.prg
	nIdEstilo = 0
	oColeccion = null
	oColeccionEstilos = null

	nAnchoFlechaCombo = 30
	nAnchoCheckVacio = 12

	nAnchoBordeCombo = 1
	nAnchoExtra = 3
	cPatronLongitud = ""

	nResolucionAlto = 600
	nResolucionAncho = 800

	FuenteEstilo1Nombre = .f.
	FuenteEstilo2Nombre = .f.
	FuenteEstilo1Tamanio = .f.
	FuenteEstilo2Tamanio = .f.
	
	nAltoTextBoxGenerico = 0
	
	*-----------------------------------------------------------------------------------------
	function init ( tnEstilo as Integer ) as VOID
		dodefault()
		This.ObtenerValoresRegistrosParaCache()
		this.oColeccionEstilos = _screen.zoo.crearobjeto( 'zooColeccion' )
		this.ActualizarEstilo( tnEstilo )
		
		local textBoxAux as TextBox
		textBoxAux = newobject( "zooTextBox", "zooTextBox.prg", "", "NO" )
		this.Aplicar( textBoxAux )
		this.nAltoTextBoxGenerico = textBoxAux.Height
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValoresRegistrosParaCache() as Void
		with this
			.FuenteEstilo1Nombre = goRegistry.Dibujante.FuenteEstilo1Nombre
			.FuenteEstilo2Nombre = goRegistry.Dibujante.FuenteEstilo2Nombre
			.FuenteEstilo1Tamanio = goRegistry.Dibujante.FuenteEstilo1Tamanio
			.FuenteEstilo2Tamanio = goRegistry.Dibujante.FuenteEstilo2Tamanio
		endwith
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ActualizarEstilo( tnEstilo as Integer ) as Void
		local lnNuevoEstilo as Integer 
		
		if empty( tnEstilo )
			lnNuevoEstilo = goParametros.Dibujante.Estilo
		else
			lnNuevoEstilo = tnEstilo
		endif 
				
		with this	
			if .nIdEstilo = lnNuevoEstilo
			else
				.oColeccion = .ObtenerDinEstilos( lnNuevoEstilo )
				
				.nIdEstilo = lnNuevoEstilo
				.cPatronLongitud = .oColeccion.cPatronLongitud
				
				if !empty( .oColeccion.nResolucionAlto ) and !empty( .oColeccion.nResolucionAncho )
					.nResolucionAlto = .oColeccion.nResolucionAlto
					.nResolucionAncho = .oColeccion.nResolucionAncho
				endif
			endif 
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarEstilo( tnEstilo as Integer, tnEstiloPorDefecto as Integer ) as Integer
		local lnNuevoEstilo as Integer
		
		if !empty( tnEstilo ) and vartype( tnEstilo ) = "N"
			lnNuevoEstilo = tnEstilo
		else
			lnNuevoEstilo = this.nIdEstilo
		endif
		
		return lnNuevoEstilo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDinEstilos( tnEstilo as Integer ) as Object
		local loDinEstilos as Object, lcEstilo as String
		lcEstilo = transform( tnEstilo )
		
		with this
			if .oColeccionEstilos.buscar( lcEstilo )
				loDinEstilos = .oColeccionEstilos.item[ lcEstilo ]
			else
				loDinEstilos = _screen.zoo.CrearObjeto( "Din_Estilo" + lcEstilo )
				.oColeccionEstilos.agregar( loDinEstilos, lcEstilo )
			endif
		endwith
		return loDinEstilos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Aplicar ( toControl as object ) as boolean
		local loError as Exception, loEx as Exception
		Try
			if iif( type( "toControl.lControlConEstilo" ) = "U", .t., toControl.lControlConEstilo )
				this.RecorrerControles( toControl )
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		Finally
		EndTry

		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecorrerControles ( toControl as object ) as VOID
		local loControl as object, loPage as object, loColumn as object, loError as Exception, loEx as Exception

		= amembers( aProp, toControl )

		do case
			case ascan( aProp, "PAGES" ) > 0
				for each loPage in toControl.pages
					this.Aplicar( loPage )
				endfor

				this.Configurar( toControl )

			case ascan( aProp, "COLUMNS" ) > 0
				for each loColumn in toControl.columns
					this.Aplicar( loColumn )
				endfor

				this.Configurar( toControl )

			case ascan( aProp, "CONTROLS" ) > 0
				for each loControl in toControl.controls
					this.Aplicar( loControl )
				endfor

				this.Configurar( toControl )

			otherwise
				this.Configurar( toControl )

		endcase

		if pemstatus( toControl, "AplicarEstilo", 5 )
			try
				toControl.AplicarEstilo( this )
			Catch To loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			Finally
			EndTry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Configurar ( toControl as object ) as VOID
		local lcClase as string, llHayAdministrador as boolean
		if pemstatus( toControl, "cAssembly", 5 )
			return
		endif 
		lcClase = "this.oColeccion." + toControl.class

		if type( lcClase ) = "U"
			if this.EsCampoDeUnDetalle( toControl )
				lcClase = "this.oColeccion.CampoGenericoGrilla"
			endif

			if type( lcClase ) = "U"
				lcClase = "this.oColeccion." + toControl.ParentClass

				if type( lcClase ) = "U"
					lcClase = "this.oColeccion." + toControl.baseclass
				endif
			endif
		endif


		if type( lcClase ) # "U" and iif( vartype( toControl.lAplicaEstilo ) = "U", .t., toControl.lAplicaEstilo )
			declare laPropColeccion(1,1)

			lnCantidad = amembers( laPropColeccion, &lcClase, 0, "U" )
			= amembers( laPropControl, toControl )

			for lnOrden = 1 to lnCantidad
				lcPropiedad = laPropColeccion[ lnOrden ]
				if ascan( laPropControl, lcPropiedad ) > 0
					this.SetearPropiedad( lcPropiedad, lcClase, toControl )
				endif
			endfor

			if pemstatus( toControl, "width", 5 )
				toControl.width = this.SetearAncho( toControl )
			endif
			
			if pemstatus( toControl, "height", 5 )
				toControl.height= this.SetearAlto( toControl )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearPropiedad ( tcPropiedad as string, tcClase as string, toControl as object ) as VOID
		local lnCantidad as integer, lxValor as variant

		if !pemstatus( toControl, tcPropiedad, 1 ) &&and !SYS(1269, toControl, tcPropiedad, 1 )

			lxValor = &tcClase..&tcPropiedad
			if vartype( lxValor ) = "C"
				lxValor = alltrim( lxValor )
			endif

			toControl.&tcPropiedad = lxValor
		endif

	endfunc

	*----------------------------------------------------------------------------------------- 
	function SetearAncho( toControl as object ) as VOID
		local lnAnchoControl as integer, lcCaracter as string, lnMargin as integer, ;
			lcTexto as string, lnPixels as integer, lnTexto as integer , lnAgregados, ;
			llCalcula as boolean, lcFontstyle as string

		llCalcula = .t.

		lnAnchoControl = 0
		lcCaracter = 'U'
		lcTexto = ""

		if vartype( toControl.fontname ) = "C"
			lcFontstyle = ""

			if pemstatus( toControl, "fontbold", 5 )
				lcFontstyle = lcFontstyle + iif( toControl.fontbold, "B", "" )
			endif
			if pemstatus( toControl, "fontitalic", 5 )
				lcFontstyle = lcFontstyle + iif( toControl.fontitalic, "I", "" )
			endif

			lnPixels = fontmetric( 6, toControl.fontname, toControl.fontsize, lcFontstyle )
		endif

		lnAgregados = 0

		do case
			case toControl.baseclass = "Textbox"
				lcTexto = this.ObtenerMascaraParaCalculoDeAncho( toControl )
			
				lnAnchoControl = iif( toControl.maxlength > 0, toControl.maxlength, 20 )
				llCalcula = .f.

				if empty( lcTexto )
					toControl.width = this.CalcularAnchoExacto( toControl, lnAnchoControl )
				else
					toControl.width = this.CalcularAnchoExacto( toControl, lcTexto )
				endif

				lcTexto = replicate( lcCaracter, lnAnchoControl )
				
			case toControl.baseclass = "Combobox"
				toControl.margin = 0
				lnAgregados = this.nAnchoFlechaCombo

				for lnItem = 1 to toControl.listcount
					if len( toControl.listitem[ lnItem ] ) > len( lcTexto )
						lcTexto = toControl.listitem[ lnItem ]
					endif
				endfor	

				if pemstatus( toControl, "oItem", 5 ) and !isnull( toControl.oItem )
					if len( lcTexto )  < toControl.oItem.longitud
						if upper( toControl.oItem.Dominio ) = "COMBOCLAVE"
							lcTexto = replicate( lcCaracter, toControl.oItem.AtributosClase.MuestraRelacion.longitud )
						else
							lcTexto = replicate( lcCaracter, toControl.oItem.longitud )
						endif 	
					endif
				endif

			case toControl.baseclass = "Label"

*** Aca siemre hace el upper y solo es necesario si se usa la funcionalida de tomar foco y hacer upper del texto

				toControl.autosize = .f.
				lcTexto = alltrim( upper( toControl.caption ) )
				toControl.width = this.CalcularAnchoExacto( toControl, lcTexto )
				lCalcula = .f.
				
			case inlist( toControl.baseclass, "Checkbox", "Optiongroup" )
				toControl.autosize = .f.
				lcTexto = alltrim( upper( toControl.caption ))
				lnAgregados = this.nAnchoCheckVacio + ( txtwidth( " ", toControl.fontname, toControl.fontsize ) * lnPixels )
				
			case toControl.baseclass = "Image"

			case toControl.baseclass = "Form"
				llCalcula = .f.

			case toControl.baseclass = "Editbox"
				do case
					case toControl.maxlength > 0
						lnAnchoControl = toControl.maxlength

					otherwise
						if pemstatus( toControl, "oItem", 5 ) and !isnull( toControl.oItem )
							lnAnchoControl = toControl.oItem.longitud
						else
							lnAnchoControl = 1
						endif
				endcase
				lnAgregados = sysmetric( 5 )
				lcTexto = replicate( lcCaracter, lnAnchoControl )

			case toControl.baseclass = "Commandbutton"
				toControl.autosize = .f.
				lcTexto = alltrim( toControl.caption )
				lnAgregados  = txtwidth( left( lcCaracter, 2 ), toControl.fontname, toControl.fontsize ) * lnPixels

			case toControl.baseclass = "Pageframe" or toControl.baseclass = "Page"

			case toControl.baseclass = "Line"

			case toControl.baseclass = "Column"
				lnAgregados = toControl.width

			case toControl.baseclass = "Grid"
				lnAgregados = 700

			case toControl.baseclass = "Shape"

			otherwise
				lnAnchoControl = 20
				if vartype( toControl.fontname ) = "C" and !empty( alltrim( toControl.fontname ) )
					toControl.width = txtwidth( replicate( lcCaracter, lnAnchoControl ), toControl.fontname, toControl.fontsize ) * ;
						lnPixels && + ( 2 * lnMargin) + Iif( toControl.BorderStyle = 0, 1, 5 )
				endif
		endcase

		if llCalcula
			if vartype( toControl.fontname ) = "C" and !empty( alltrim( toControl.fontname ) )
				toControl.width = txtwidth( lcTexto, toControl.fontname, toControl.fontsize) * lnPixels + lnAgregados
			endif
		endif

		return toControl.width
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function 	ObtenerMascaraParaCalculoDeAncho( toControl as Object ) as String
		local lcRetorno as String
		
		if ( pemstatus( toControl, "cMascaraParaGenerar", 5 ) and !empty( toControl.cMascaraParaGenerar ) )
			lcRetorno = alltrim( toControl.cMascaraParaGenerar )
		else
			if ( pemstatus( toControl, "cMascara", 5 ) and !empty( toControl.cMascara ) )
				lcRetorno = alltrim( toControl.cMascara )
			else
				lcRetorno = alltrim( toControl.InputMask )
			endif
		endif
		lcRetorno = strtran( strtran( lcRetorno, "A", "W" ), "X", "W" )
		
		return lcRetorno 
	endfunc 


	*-----------------------------------------------------------------------------------------
	function CalcularAnchoExacto( toControl as Object, txValor as Variant ) as Integer
		local lnRetorno as Integer

		lnRetorno = 0
		if vartype( txValor ) = "N"
			if inlist( this.ObtenerTipoDatoControl( toControl ), "N" , "A", "I" )
				lnRetorno = this.CalcularAnchoExactoNumerico( txValor, toControl )
			else
				lnRetorno = this.CalcularAnchoExactoPalabraPatron( txValor, toControl )
			endif
		else
			lnRetorno = this.CalcularAnchoExactoTexto( txValor, toControl )
		endif

		lnRetorno = lnRetorno + this.ObtenerAdicionalParaElAncho( toControl, txValor )

		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoDatoControl( toControl as object) as string
		local lcRetorno as String
		
		lcRetorno = " "
		if pemstatus( toControl, "cTipoDato", 5 ) 
			lcRetorno= toControl.cTipoDato
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAdicionalParaElAncho( toControl as Object, txValor as Variant ) as Void
		local lnAnchoExtra as Integer
							
		lnAnchoExtra = this.nAnchoExtra

		if vartype( txValor ) = "N"
		else
			if this.nIdEstilo = 2
				if inlist( this.ObtenerTipoDatoControl( toControl ),"N" , "A", "I" )
					lnAnchoExtra = lnAnchoExtra + 2							
				else
					if this.TieneAlineacionALaDerecha( toControl )
						lnAnchoExtra  = lnAnchoExtra + 2
					endif
				endif
			endif
		endif
		
		return lnAnchoExtra
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TieneAlineacionALaDerecha( toControl as object) as bool
		local llRetorno as Boolean
		
		llRetorno = .f.
		if pemstatus( toControl, "Alignment", 5 )
			llRetorno = ( toControl.Alignment = 1 )
				
			if llRetorno and pemstatus( toControl, "lDetalle", 5 )
				llRetorno = !toControl.lDetalle 
			endif
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EsCampoDeUnDetalle( toControl as object) as bool
		return left( upper( toControl.Class ), 5 ) == "CAMPO" and type( "toControl.lDetalle" ) = "L" and toControl.lDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFuenteControl( toControl as Object ) as string
		local lcRetorno as String
		
		if type( "toControl.Font" ) = "O"
			lcRetorno = toControl.Font.Name
		else
			lcRetorno = toControl.FontName
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNegritaControl( toControl as Object ) as string
		local lcRetorno as String
		
		if type( "toControl.Font" ) = "O"
			lcRetorno = toControl.Font.Bold
		else
			lcRetorno = toControl.FontBold
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItalicaControl( toControl as Object ) as string
		local lcRetorno as String
		
		if type( "toControl.Font" ) = "O"
			lcRetorno = toControl.Font.Italic
		else
			lcRetorno = toControl.FontItalic
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTamanioFuenteControl( toControl as Object ) as integer
		local lnRetorno as integer
		
		if type( "toControl.Font" ) = "O"
			lnRetorno = Ceiling( Val( Transform( toControl.Font.Size, "@0" ) ) )
		else
			lnRetorno = toControl.FontSize
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularAnchoExactoTexto( tcTexto as string, toControl as object ) as Integer
		local lcFuenteAnt as string, lnFuenteAnt as integer, lnRetorno as Integer, lcPalabraPatron as String ,;
			loError as Exception, loEx as Exception, lcFuente as String, lnTamanio as integer, llNegrita as Boolean, llItalica as Boolean, ;
			llItalicaAnt as Boolean, llNegritaAnt as Boolean 
							
		lcFuente = this.ObtenerFuenteControl( toControl )
		lnTamanio = this.ObtenerTamanioFuenteControl( toControl )
		llNegrita = this.ObtenerNegritaControl( toControl )
		llItalica = this.ObtenerItalicaControl( toControl )
		
		with _screen
			lcFuenteAnt = .FontName
			lnFuenteAnt = .FontSize
			llItalicaAnt = .FontItalic
			llNegritaAnt = .FontBold
			
			try
				.FontName = lcFuente 
				.FontSize = lnTamanio 
				.FontItalic = llItalica 
				.FontBold = llNegrita 

				lnRetorno = .TextWidth( tcTexto )
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			finally
				.FontName = lcFuenteAnt
				.FontSize = lnFuenteAnt
				.FontItalic = llItalicaAnt
				.FontBold = llNegritaAnt 
			endtry	
		endwith
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularAnchoExactoNumerico( tnCaracteres as integer, toControl as object ) as Integer
		local lcFuenteAnt as string, lnFuenteAnt as integer, lnRetorno as Integer, lcPalabraPatron as String ,;
			loError as Exception, loEx as Exception, lcFuente as String, lnTamanio as integer, llNegrita as Boolean, llItalica as Boolean, ;
			llItalicaAnt as Boolean, llNegritaAnt as Boolean 
							
		lcFuente = this.ObtenerFuenteControl( toControl )
		lnTamanio = this.ObtenerTamanioFuenteControl( toControl )
		llNegrita = this.ObtenerNegritaControl( toControl )
		llItalica = this.ObtenerItalicaControl( toControl )

		with _screen
			lcFuenteAnt = .FontName
			lnFuenteAnt = .FontSize
			llItalicaAnt = .FontItalic
			llNegritaAnt = .FontBold

			try
				.FontName = lcFuente 
				.FontSize = lnTamanio 
				.FontItalic = llItalica 
				.FontBold = llNegrita 

				lnRetorno = .TextWidth( replicate( "9", tnCaracteres ) )
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			finally
				.FontName = lcFuenteAnt
				.FontSize = lnFuenteAnt
				.FontItalic = llItalicaAnt
				.FontBold = llNegritaAnt 
			endtry	
		endwith
		return lnRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function CalcularAnchoExactoPalabraPatron( tnCaracteres as integer, toControl as object ) as Integer
		local lcFuenteAnt as string, lnFuenteAnt as integer, lnRetorno as Integer, lcPalabraPatron as String ,;
			loError as Exception, loEx as Exception, lcFuente as String, lnTamanio as integer, llNegrita as Boolean, llItalica as Boolean, ;
			llItalicaAnt as Boolean, llNegritaAnt as Boolean 
							
		lcFuente = this.ObtenerFuenteControl( toControl )
		lnTamanio = this.ObtenerTamanioFuenteControl( toControl )
		llNegrita = this.ObtenerNegritaControl( toControl )
		llItalica = this.ObtenerItalicaControl( toControl )

		with _screen
			lcFuenteAnt = .FontName
			lnFuenteAnt = .FontSize
			llItalicaAnt = .FontItalic
			llNegritaAnt = .FontBold

			try
				.FontName = lcFuente 
				.FontSize = lnTamanio 
				.FontItalic = llItalica 
				.FontBold = llNegrita 

				lcPalabraPatron = replicate( this.cPatronLongitud , ceiling( tnCaracteres / len( this.cPatronLongitud ) ) )
				lnRetorno = .TextWidth( left( lcPalabraPatron, tnCaracteres ) )
			catch to loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			finally
				.FontName = lcFuenteAnt
				.FontSize = lnFuenteAnt
				.FontItalic = llItalicaAnt
				.FontBold = llNegritaAnt 
			endtry
		endwith
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAlto( toControl as object ) as VOID
		local lnAgregado as integer

		if inlist( toControl.baseclass, "Textbox", "Listbox", "Editbox", "Grid", "Form" )
			if inlist( toControl.baseclass, "Editbox" )
				toControl.height = 0 &&jbarrionuevo # 18/03/08 15:15:36 Aca actúa el IntegralHeight autocalculando el Height

				toControl.height = toControl.height * toControl.nRenglones + ;
					iif ( toControl.nRenglones = 2 and This.ObtenerEstilo() == 2, ( toControl.height / 2 ) + 3, 0 )
			endif

			if inlist( toControl.baseclass, "Listbox" )
				lnAgregado = fontmetric( 4, toControl.Fontname, toControl.Fontsize )
				toControl.height = this.CalcularAltoEnPixeles( toControl.Fontname, toControl.Fontsize )
				toControl.height = ( toControl.height + lnAgregado ) * toControl.nRenglones + 2
			endif
		else
			if toControl.baseclass = "Checkbox" and !this.EsCampoDeUnDetalle( toControl )
				toControl.Height = this.nAltoTextBoxGenerico
			else
				if vartype( toControl.fontname ) = "C" and !empty( alltrim( toControl.fontname ) )
					toControl.height = this.CalcularAltoEnPixeles( toControl.fontname, toControl.fontsize )
				endif

				if inlist( toControl.baseclass, "Combobox" ) and toControl.borderstyle = 1
					toControl.height = toControl.height + ( 2 * this.nAnchoBordeCombo )
				endif
			endif
		endif

		return toControl.height
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorPropiedad( tcControl as string, tcPropiedad as string ) as variant
		local lxRetorno as variant, loError as Exception, loEx as Exception

		tcControl = alltrim( tcControl )
		tcPropiedad = alltrim( tcPropiedad )

		try
			lxRetorno = this.oColeccion.&tcControl..&tcPropiedad
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		Finally
		EndTry

		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstilo() as integer
		return this.nIdEstilo
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularAnchoEnPixeles( tnCantidadCaracteres as integer, tcFontName as string, tnFontSize as integer, tlFontBold as boolean, tlFontItalic as boolean ) as integer
		local lnRetorno as integer, lnPixels as integer, lcFontName as string, ;
			lnFontSize as integer, tcTexto as string

		if pcount() < 5
			lcFontName = this.ObtenerValorPropiedad( "Label", "FontName" )
			lnFontSize = this.ObtenerValorPropiedad( "Label", "FontSize" )

			llFontBold = this.ObtenerValorPropiedad( "Label", "FontBold" )
			llFontItalic = this.ObtenerValorPropiedad( "Label", "FontItalic" )
		else
			lcFontName = tcFontName
			lnFontSize = tnFontSize

			llFontBold = tlFontBold
			llFontItalic = tlFontItalic
		endif

		lcTexto = replicate( "U", tnCantidadCaracteres )

		lnRetorno = 0

		lcFontstyle = ""
		lcFontstyle = lcFontstyle + iif( llFontBold, "B", "" )
		lcFontstyle = lcFontstyle + iif( llFontItalic, "I", "" )

		if empty(lcFontstyle)
			lcFontstyle = "N"
		endif

		lnPixels = fontmetric( 6, lcFontName, lnFontSize, lcFontstyle )

		lnRetorno = txtwidth( lcTexto, lcFontName, lnFontSize) * lnPixels

		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularAltoEnPixeles( tcFontName as string, tnFontSize as integer ) as integer
		return fontmetric( 1, tcFontName, tnFontSize )
	endfunc

	*----------------------------------------------------------------------------------------- 
	function TraducirSacandoEnter( tcTexto As String ) as String
		local lcTexto As String, lcChar As String, lcTextoAux As String, lnCantidadPalabras as Integer, i as Integer, ;
			lcPalabra as String
		lcChar = chr( 10 )
		lcTexto = tcTexto
		lcTexto = strtran( lcTexto, chr( 13 ) , lcChar )
		if Occurs( lcChar, lcTexto ) > 0
			lnCantidadPalabras = getwordcount( lcTexto, lcChar )
			do Case
				case lnCantidadPalabras = 0 && Muchos enters sin ningun otro caracter
					lcTexto = ""
				otherwise
					lcTextoAux = ""
					for i = 1 to lnCantidadPalabras - 1
						lcPalabra = getwordnum( lcTexto, i , lcChar )
						lcPalabra = rtrim( lcPalabra )
						if right( lcPalabra, 1 ) = "."
							lcPalabra = lcPalabra + " "
						else
							lcPalabra = lcPalabra + ". "
						endif
						lcTextoAux = lcTextoAux + lcPalabra
					endfor
					lcTexto = lcTextoAux + getwordnum( lcTexto, lnCantidadPalabras, lcChar )
			EndCase		
		EndIf
		return strtran( lcTexto	, lcChar, "" )
	endfunc 

	*----------------------------------------------------------------------------------------- 
	function ObtenerNombreDeFuente( tnEstilo as Integer ) as string
		local lcFuente as String, lnEstilo as Integer

		if this.ValidarEstilo( tnEstilo ) = 1
			lcFuente = This.FuenteEstilo1Nombre
		else
			lcFuente = This.FuenteEstilo2Nombre
		endif
		
		return alltrim( lcFuente )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTamanioDeFuente( tnEstilo as Integer ) as string
		local lnFuente as String
		
		if this.ValidarEstilo( tnEstilo ) = 1
			lnFuente = This.FuenteEstilo1Tamanio
		else
			lnFuente = This.FuenteEstilo2Tamanio
		endif
		
		return lnFuente
	endfunc 
enddefine