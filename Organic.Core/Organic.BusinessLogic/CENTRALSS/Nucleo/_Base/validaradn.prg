Define Class ValidarADN As ValidarBase of ValidarBase.prg

	#INCLUDE AccesoADatos.h
	#IF .f.
		Local this as ValidarADN of ValidarADN.prg
	#ENDIF

	cRutaInicial	= ""
	cRutaADN		= ""
	oAccesoDatos	=  Null
	oLibrerias		= Null
	oValidarAdnComponenteSenias = null
	oValidarAdnComponenteTarjetaDeCredito= null
	oValidarAdnCapitalizacionEtiquetas = null
	oValidarAdnConLaConfiguracionBasica = null
	oValidarAdnConSeguridadComercial = null
	oValidarAdnCopiaDeDetalles = null
	oValidarAdnListadosOrganic = null
	oValidarAdnEntidadesConEdicionParcial = null
	
	DataSession		= 1
	protected oPalabrasReservadas
	oPalabrasReservadas = null
	cDeleted = ""
	cPrefijoAuditoria = "ADT_"
	cProyectoActivo = space(0)

	cDiccionarioAdicional = ""
	cMenuAltasItemsCompleto = ""
	cEntidadAdicional = ""
	cListados = ""
	cListCampos = ""
	cNodosListados = ""
	oFunc = null
	oZoo = null
	
	*-----------------------------------------------------------------------------------------
	Function Init( tcRuta ) As VOID
		
		With This
			If Empty( tcRuta )
				.cRutaInicial = Alltrim( _screen.Zoo.cRutaInicial )
			Else
				.cRutaInicial = Alltrim( tcRuta )
			endif
			
			.cRutaADN = Addbs( .cRutaInicial ) + "ADN\dbc\"
			.oAccesoDatos = Newobject( "AccesoDatos", "AccesoDatos.prg" )
			.oLibrerias = this.Crearobjeto( "Librerias" )
			.cDeleted = set( "Deleted" )

			set deleted on
			dodefault( tcRuta  )

			.cProyectoActivo = This.ObtenerProyectoActivo()	
			.oValidarAdnComponenteSenias = this.crearobjeto( "ValidarAdnComponenteSenias", "", this )
			.oValidarAdnComponenteTarjetaDeCredito = this.crearobjeto( "ValidarAdnComponenteTarjetaDeCredito", "", this )
			.oValidarAdnCapitalizacionEtiquetas = this.crearobjeto( "ValidarAdnCapitalizacionEtiquetas", "", this )
			.oValidarAdnConLaConfiguracionBasica = this.CrearObjeto( "ValidarAdnConLaConfiguracionBasica", "", this )
			.oValidarAdnConSeguridadComercial = this.CrearObjeto( "ValidarAdnConSeguridadComercial", "", this )
			.oValidarAdnCopiaDeDetalles = this.CrearObjeto( "ValidarAdnCopiaDeDetalles", "", this )			
			.oValidarAdnListadosOrganic = this.CrearObjeto( "ValidarAdnListadosOrganic", "", this )			
			.oValidarAdnEntidadesConEdicionParcial = this.crearobjeto( "ValidarAdnEntidadesConEdicionParcial", "", this )

			.oFunc = newobject( "funcionalidades", "funcionalidades.prg" )
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function oZoo_Access() as Object
		if vartype( this.oZoo ) != "O"
			this.oZoo = newobject( "zoo", "zoo.PRG" )
		endif
		return this.oZoo
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function CrearADNAdicional() as variant
		local loError as Exception , loGeneradorDeAdnAdicional as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg

        this.InformarProceso( "Creando ADN adicional" )
		with this
			try
				.CrearCursor( "diccionario" )
				.CrearCursor( "entidad" )
				.CrearCursor( "Listados" )
				.CrearCursor( "ListCampos" )
				.CrearCursor( "menualtasitems" )
				.CrearCursor( "TransferenciasAgrupadas" )
				.CrearCursor( "TransferenciasAgrupadasItems" )
				.CrearCursor( "TransferenciasFiltros" )
				.CrearCursor( "ExportacionesFiltros" )
				.CrearCursor( "nodoslistados" )
				.CrearCursor( "SeteosListadosGenericos" )
				.CrearCursor( "AtributosGenericos" )
				.CrearCursor( "MenualtasDefault" )
				.CrearCursor( "RelaComprobantes" )
				.CrearCursor( "Comprobantes" )
				.CrearCursor( "RelaComponente" )
				.CrearCursor( "SeguridadEntidades" )
				
				.CrearCursor( "MenuPrincipal" )
				.CrearCursor( "MenuPrincipalItems" )
				.CrearCursor( "Dominio" )
				loGeneradorDeAdnAdicional = this.crearobjeto( "GeneradorDeAdnAdicional" )
				bindevent( loGeneradorDeAdnAdicional, "Informar", this, "InformarProceso" )
				loGeneradorDeAdnAdicional.cSchemaDefault = ESQUEMAPORDEFECTO

				loGeneradorDeAdnAdicional.cProyectoActivo = this.cProyectoActivo
				loGeneradorDeAdnAdicional.cRutaZoo = addbs( this.crutaInicial ) + "..\"
				loGeneradorDeAdnAdicional.Procesar()
				
				
				.cDiccionarioAdicional = sys( 2015 )
				.cEntidadAdicional = sys( 2015 )
				.cMenuAltasItemsCompleto = sys( 2015 )				
				.cListados = sys( 2015 )
				.cListCampos = sys( 2015 )
				.cNodosListados = sys( 2015 )
				
				select * from c_diccionario into cursor ( .cDiccionarioAdicional )
				select * from c_entidad into cursor ( .cEntidadAdicional )
				select * from c_MenuAltasItems into cursor ( .cMenuAltasItemsCompleto )

				select * from c_Listados into cursor ( .cListados )
				select * from c_ListCampos into cursor ( .cListCampos )
				select * from c_NodosListados into cursor ( .cNodosListados )

			catch to loError
				throw loError 
			finally
				use in select( "c_diccionario" )
				use in select( "c_entidad" )
				use in select( "c_Listados" )
				use in select( "c_ListCampos" )
				use in select( "c_menualtasitems" )
				use in select( "c_TransferenciasAgrupadas" )
				use in select( "c_TransferenciasAgrupadasItems" )
				use in select( "c_TransferenciasFiltros" )
				use in select( "c_ExportacionesFiltros" )
				use in select( "c_nodoslistados" )
				use in select( "c_SeteosListadosGenericos" )
				use in select( "c_AtributosGenericos" )
				use in select( "c_MenualtasDefault" )
				use in select( "c_RelaComprobantes" )
				use in select( "c_Comprobantes" )
				use in select( "c_RelaComponente" )
				use in select( "c_SeguridadEntidades" )
				use in select( "c_MenuPrincipal" )
				use in select( "c_MenuPrincipalItems" )	
				use in select( "c_Dominio" )					
				
				if vartype( loGeneradorDeAdnAdicional ) = "O" and !isnull( loGeneradorDeAdnAdicional )
					loGeneradorDeAdnAdicional.release()
				endif
				loGeneradorDeAdnAdicional = null
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerProyectoActivo() as string 
	
		local lcRutaInicial as String,  lnInicioProyecto as Integer, lcProyecto as String  

		lcRutaInicial = addbs( This.cRutaInicial )
		lnInicioProyecto = rat( "\" , lcRutaInicial, 2 )
		lcProyecto = upper( alltrim( substr( lcRutaInicial, lnInicioProyecto + 1, rat( "\" , lcRutaInicial ) - 1 - lnInicioProyecto ) ) )			

		return lcProyecto

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCursorDePalabrasReservadas() as Void
	
		create cursor c_PalabrasReservadas ( Palabra C ( 254 ) )
			
		insert into C_PalabrasReservadas values ("-")
		insert into C_PalabrasReservadas values ("!")
		insert into C_PalabrasReservadas values ("!=")
		insert into C_PalabrasReservadas values ("#")
		insert into C_PalabrasReservadas values ("$")
		insert into C_PalabrasReservadas values ("%")
		insert into C_PalabrasReservadas values ('("')
		insert into C_PalabrasReservadas values ('")')
		insert into C_PalabrasReservadas values ("*")
		insert into C_PalabrasReservadas values ("**")
		insert into C_PalabrasReservadas values (",")
		insert into C_PalabrasReservadas values (".")
		insert into C_PalabrasReservadas values (".AND.")
		insert into C_PalabrasReservadas values (".F.")
		insert into C_PalabrasReservadas values (".N.")
		insert into C_PalabrasReservadas values (".NOT.")
		insert into C_PalabrasReservadas values (".NULL.")
		insert into C_PalabrasReservadas values (".OR.")
		insert into C_PalabrasReservadas values (".T.")
		insert into C_PalabrasReservadas values (".Y.")
		insert into C_PalabrasReservadas values ("/")
		insert into C_PalabrasReservadas values ("/R")
		insert into C_PalabrasReservadas values (":")
		insert into C_PalabrasReservadas values ("::")
		insert into C_PalabrasReservadas values (";")
		insert into C_PalabrasReservadas values ("?")
		insert into C_PalabrasReservadas values ("??")
		insert into C_PalabrasReservadas values ("???")
		insert into C_PalabrasReservadas values ("@")
		insert into C_PalabrasReservadas values ("[")
		insert into C_PalabrasReservadas values ("]")
		insert into C_PalabrasReservadas values ("^")
		insert into C_PalabrasReservadas values ("+")
		insert into C_PalabrasReservadas values ("<")
		insert into C_PalabrasReservadas values ("<??>")
		insert into C_PalabrasReservadas values ("<=")
		insert into C_PalabrasReservadas values ("<>")
		insert into C_PalabrasReservadas values ("=")
		insert into C_PalabrasReservadas values ("=")
		insert into C_PalabrasReservadas values ("==")
		insert into C_PalabrasReservadas values ("=>")
		insert into C_PalabrasReservadas values (">")
		insert into C_PalabrasReservadas values ("->")
		insert into C_PalabrasReservadas values (">=")
		insert into C_PalabrasReservadas values ("#")
		insert into C_PalabrasReservadas values ("#DEFINE")
		insert into C_PalabrasReservadas values ("#ELIF")
		insert into C_PalabrasReservadas values ("#ELSE")
		insert into C_PalabrasReservadas values ("#ENDIF")
		insert into C_PalabrasReservadas values ("#IF")
		insert into C_PalabrasReservadas values ("#ITSEXPRESSION")
		insert into C_PalabrasReservadas values ("#READCLAUSES")
		insert into C_PalabrasReservadas values ("#REGION")
		insert into C_PalabrasReservadas values ("#SECTION")
		insert into C_PalabrasReservadas values ("#UNDEF")
		insert into C_PalabrasReservadas values ("#WNAME")
		insert into C_PalabrasReservadas values ("_ALIGNMENT")
		insert into C_PalabrasReservadas values ("_ASCIICOLS")
		insert into C_PalabrasReservadas values ("_ASCIIROWS")
		insert into C_PalabrasReservadas values ("_ASSIST")
		insert into C_PalabrasReservadas values ("_BEAUTIFY")
		insert into C_PalabrasReservadas values ("_BOX")
		insert into C_PalabrasReservadas values ("_BROWSER")
		insert into C_PalabrasReservadas values ("_BUILDER")
		insert into C_PalabrasReservadas values ("_CALCMEM")
		insert into C_PalabrasReservadas values ("_CALCVALUE")
		insert into C_PalabrasReservadas values ("_CLIPTEXT")
		insert into C_PalabrasReservadas values ("_CODESENSE")
		insert into C_PalabrasReservadas values ("_CONVERTER")
		insert into C_PalabrasReservadas values ("_COVERAGE")
		insert into C_PalabrasReservadas values ("_CUROBJ")
		insert into C_PalabrasReservadas values ("_DATETIMEFORMAT")
		insert into C_PalabrasReservadas values ("_DBLCLICK")
		insert into C_PalabrasReservadas values ("_DIARYDATE")
		insert into C_PalabrasReservadas values ("_DOS")
		insert into C_PalabrasReservadas values ("_FONTCLASS")
		insert into C_PalabrasReservadas values ("_FOXBASECLASS")
		insert into C_PalabrasReservadas values ("_FOXCODE")
		insert into C_PalabrasReservadas values ("_FOXDOC")
		insert into C_PalabrasReservadas values ("_FOXDRAGDROP")
		insert into C_PalabrasReservadas values ("_FOXDROPTARGET")
		insert into C_PalabrasReservadas values ("_FOXREF")
		insert into C_PalabrasReservadas values ("_FOXGRAPH")
		insert into C_PalabrasReservadas values ("_FOXTASK")
		insert into C_PalabrasReservadas values ("_GALLERY")
		insert into C_PalabrasReservadas values ("_GENGRAPH")
		insert into C_PalabrasReservadas values ("_GENHTML")
		insert into C_PalabrasReservadas values ("_GENMENU")
		insert into C_PalabrasReservadas values ("_GENPD")
		insert into C_PalabrasReservadas values ("_GENSCRN")
		insert into C_PalabrasReservadas values ("_GENXTAB")
		insert into C_PalabrasReservadas values ("_GETEXPR")
		insert into C_PalabrasReservadas values ("_HELPWEBDEVONLY")
		insert into C_PalabrasReservadas values ("_HELPWEBDIRECTORY")
		insert into C_PalabrasReservadas values ("_HELPWEBFILLER1")
		insert into C_PalabrasReservadas values ("_HELPWEBFILLER2")
		insert into C_PalabrasReservadas values ("_HELPWEBMSDNONLINE")
		insert into C_PalabrasReservadas values ("_HELPWEBMSFTHOMEPAGE")
		insert into C_PalabrasReservadas values ("_HELPWEBSEARCH")
		insert into C_PalabrasReservadas values ("_HELPWEBTUTORIAL")
		insert into C_PalabrasReservadas values ("_HELPWEBVFPFAQ")
		insert into C_PalabrasReservadas values ("_HELPWEBVFPFREESTUFF")
		insert into C_PalabrasReservadas values ("_HELPWEBVFPHOMEPAGE")
		insert into C_PalabrasReservadas values ("_HELPWEBVFPONLINESUPPORT")
		insert into C_PalabrasReservadas values ("_HELPWEBVFPSENDFEEDBACK")
		insert into C_PalabrasReservadas values ("_HELPWEBVSPRODNEWS")
		insert into C_PalabrasReservadas values ("_INCLUDE")
		insert into C_PalabrasReservadas values ("_INCSEEK")
		insert into C_PalabrasReservadas values ("_INDENT")
		insert into C_PalabrasReservadas values ("_LMARGIN")
		insert into C_PalabrasReservadas values ("_MAC")
		insert into C_PalabrasReservadas values ("_MBR_APPND")
		insert into C_PalabrasReservadas values ("_MBR_CPART")
		insert into C_PalabrasReservadas values ("_MBR_DELET")
		insert into C_PalabrasReservadas values ("_MBR_FONT")
		insert into C_PalabrasReservadas values ("_MBR_GOTO")
		insert into C_PalabrasReservadas values ("_MBR_GRID")
		insert into C_PalabrasReservadas values ("_MBR_LINK")
		insert into C_PalabrasReservadas values ("_MBR_MODE")
		insert into C_PalabrasReservadas values ("_MBR_MVFLD")
		insert into C_PalabrasReservadas values ("_MBR_MVPRT")
		insert into C_PalabrasReservadas values ("_MBR_SEEK")
		insert into C_PalabrasReservadas values ("_MBR_SP100")
		insert into C_PalabrasReservadas values ("_MBR_SP200")
		insert into C_PalabrasReservadas values ("_MBR_SZFLD")
		insert into C_PalabrasReservadas values ("_MBROWSE")
		insert into C_PalabrasReservadas values ("_MDA_APPND")
		insert into C_PalabrasReservadas values ("_MDA_AVG")
		insert into C_PalabrasReservadas values ("_MDA_BROW")
		insert into C_PalabrasReservadas values ("_MDA_CALC")
		insert into C_PalabrasReservadas values ("_MDA_COPY")
		insert into C_PalabrasReservadas values ("_MDA_COUNT")
		insert into C_PalabrasReservadas values ("_MDA_LABEL")
		insert into C_PalabrasReservadas values ("_MDA_PACK")
		insert into C_PalabrasReservadas values ("_MDA_REPRT")
		insert into C_PalabrasReservadas values ("_MDA_RINDX")
		insert into C_PalabrasReservadas values ("_MDA_SETUP")
		insert into C_PalabrasReservadas values ("_MDA_SORT")
		insert into C_PalabrasReservadas values ("_MDA_SP100")
		insert into C_PalabrasReservadas values ("_MDA_SP200")
		insert into C_PalabrasReservadas values ("_MDA_SP300")
		insert into C_PalabrasReservadas values ("_MDA_SUM")
		insert into C_PalabrasReservadas values ("_MDA_TOTAL")
		insert into C_PalabrasReservadas values ("_MDATA")
		insert into C_PalabrasReservadas values ("_MDIARY")
		insert into C_PalabrasReservadas values ("_MED_BEAUT")
		insert into C_PalabrasReservadas values ("_MED_BLDEX")
		insert into C_PalabrasReservadas values ("_MED_CLEAR")
		insert into C_PalabrasReservadas values ("_MED_COPY")
		insert into C_PalabrasReservadas values ("_MED_CUT")
		insert into C_PalabrasReservadas values ("_MED_CVTST")
		insert into C_PalabrasReservadas values ("_MED_EXBLK")
		insert into C_PalabrasReservadas values ("_MED_FIND")
		insert into C_PalabrasReservadas values ("_MED_FINDA")
		insert into C_PalabrasReservadas values ("_MED_GOTO")
		insert into C_PalabrasReservadas values ("_MED_INSOB")
		insert into C_PalabrasReservadas values ("_MED_LINK")
		insert into C_PalabrasReservadas values ("_MED_OBJ")
		insert into C_PalabrasReservadas values ("_MED_PASTE")
		insert into C_PalabrasReservadas values ("_MED_PREF")
		insert into C_PalabrasReservadas values ("_MED_PSTLK")
		insert into C_PalabrasReservadas values ("_MED_REDO")
		insert into C_PalabrasReservadas values ("_MED_REPL")
		insert into C_PalabrasReservadas values ("_MED_REPLA")
		insert into C_PalabrasReservadas values ("_MED_SLCTA")
		insert into C_PalabrasReservadas values ("_MED_SP100")
		insert into C_PalabrasReservadas values ("_MED_SP200")
		insert into C_PalabrasReservadas values ("_MED_SP300")
		insert into C_PalabrasReservadas values ("_MED_SP400")
		insert into C_PalabrasReservadas values ("_MED_SP500")
		insert into C_PalabrasReservadas values ("_MED_SP600")
		insert into C_PalabrasReservadas values ("_MED_UNDO")
		insert into C_PalabrasReservadas values ("_MEDIT")
		insert into C_PalabrasReservadas values ("_MEMBERDATA")
		insert into C_PalabrasReservadas values ("_MENUDESIGNER")
		insert into C_PalabrasReservadas values ("_MFI_CLALL")
		insert into C_PalabrasReservadas values ("_MFI_CLOSE")
		insert into C_PalabrasReservadas values ("_MFI_EXPORT")
		insert into C_PalabrasReservadas values ("_MFI_IMPORT")
		insert into C_PalabrasReservadas values ("_MFI_NEW")
		insert into C_PalabrasReservadas values ("_MFI_OPEN")
		insert into C_PalabrasReservadas values ("_MFI_PGSET")
		insert into C_PalabrasReservadas values ("_MFI_PREVU")
		insert into C_PalabrasReservadas values ("_MFI_PRINT")
		insert into C_PalabrasReservadas values ("_MFI_PRINTONECOPY")
		insert into C_PalabrasReservadas values ("_MFI_QUIT")
		insert into C_PalabrasReservadas values ("_MFI_REVRT")
		insert into C_PalabrasReservadas values ("_MFI_SAVAS")
		insert into C_PalabrasReservadas values ("_MFI_SAVE")
		insert into C_PalabrasReservadas values ("_MFI_SAVEASHTML")
		insert into C_PalabrasReservadas values ("_MFI_SEND")
		insert into C_PalabrasReservadas values ("_MFI_SETUP")
		insert into C_PalabrasReservadas values ("_MFI_SP100")
		insert into C_PalabrasReservadas values ("_MFI_SP200")
		insert into C_PalabrasReservadas values ("_MFI_SP300")
		insert into C_PalabrasReservadas values ("_MFI_SP400")
		insert into C_PalabrasReservadas values ("_MFI_SYSPRINT")
		insert into C_PalabrasReservadas values ("_MFILE")
		insert into C_PalabrasReservadas values ("_MFILER")
		insert into C_PalabrasReservadas values ("_MFIRST")
		insert into C_PalabrasReservadas values ("_MLABEL")
		insert into C_PalabrasReservadas values ("_MLAST")
		insert into C_PalabrasReservadas values ("_MLINE")
		insert into C_PalabrasReservadas values ("_MMACRO")
		insert into C_PalabrasReservadas values ("_MMB_DELET")
		insert into C_PalabrasReservadas values ("_MMB_GENER")
		insert into C_PalabrasReservadas values ("_MMB_GOPTS")
		insert into C_PalabrasReservadas values ("_MMB_INSBR")
		insert into C_PalabrasReservadas values ("_MMB_INSRT")
		insert into C_PalabrasReservadas values ("_MMB_MOPTS")
		insert into C_PalabrasReservadas values ("_MMB_PREVU")
		insert into C_PalabrasReservadas values ("_MMB_QUICK")
		insert into C_PalabrasReservadas values ("_MMB_SP100")
		insert into C_PalabrasReservadas values ("_MMB_SP200")
		insert into C_PalabrasReservadas values ("_MMB_SP300")
		insert into C_PalabrasReservadas values ("_MMBLDR")
		insert into C_PalabrasReservadas values ("_MOUSEEVENTS")
		insert into C_PalabrasReservadas values ("_MOUSEEVENTSNODBL")
		insert into C_PalabrasReservadas values ("_MPR_BEAUT")
		insert into C_PalabrasReservadas values ("_MPR_CANCL")
		insert into C_PalabrasReservadas values ("_MPR_COMPL")
		insert into C_PalabrasReservadas values ("_MPR_DO")
		insert into C_PalabrasReservadas values ("_MPR_DOCUM")
		insert into C_PalabrasReservadas values ("_MPR_FORMWZ")
		insert into C_PalabrasReservadas values ("_MPR_GENER")
		insert into C_PalabrasReservadas values ("_MPR_GRAPH")
		insert into C_PalabrasReservadas values ("_MPR_RESUM")
		insert into C_PalabrasReservadas values ("_MPR_SP100")
		insert into C_PalabrasReservadas values ("_MPR_SP200")
		insert into C_PalabrasReservadas values ("_MPR_SP300")
		insert into C_PalabrasReservadas values ("_MPR_SUSPEND")
		insert into C_PalabrasReservadas values ("_MPROG")
		insert into C_PalabrasReservadas values ("_MPROJ")
		insert into C_PalabrasReservadas values ("_MRC_APPND")
		insert into C_PalabrasReservadas values ("_MRC_CHNGE")
		insert into C_PalabrasReservadas values ("_MRC_CONT")
		insert into C_PalabrasReservadas values ("_MRC_DELET")
		insert into C_PalabrasReservadas values ("_MRC_GOTO")
		insert into C_PalabrasReservadas values ("_MRC_LOCAT")
		insert into C_PalabrasReservadas values ("_MRC_RECAL")
		insert into C_PalabrasReservadas values ("_MRC_REPL")
		insert into C_PalabrasReservadas values ("_MRC_SEEK")
		insert into C_PalabrasReservadas values ("_MRC_SP100")
		insert into C_PalabrasReservadas values ("_MRC_SP200")
		insert into C_PalabrasReservadas values ("_MRECORD")
		insert into C_PalabrasReservadas values ("_MREPORT")
		insert into C_PalabrasReservadas values ("_MRQBE")
		insert into C_PalabrasReservadas values ("_MSCREEN")
		insert into C_PalabrasReservadas values ("_MSM_DATA")
		insert into C_PalabrasReservadas values ("_MSM_EDIT")
		insert into C_PalabrasReservadas values ("_MSM_FILE")
		insert into C_PalabrasReservadas values ("_MSM_FORMAT")
		insert into C_PalabrasReservadas values ("_MSM_PROG")
		insert into C_PalabrasReservadas values ("_MSM_RECRD")
		insert into C_PalabrasReservadas values ("_MSM_SYSTM")
		insert into C_PalabrasReservadas values ("_MSM_TEXT")
		insert into C_PalabrasReservadas values ("_MSM_TOOLS")
		insert into C_PalabrasReservadas values ("_MSM_VIEW")
		insert into C_PalabrasReservadas values ("_MSM_WINDO")
		insert into C_PalabrasReservadas values ("_MST_ABOUT")
		insert into C_PalabrasReservadas values ("_MST_ASCII")
		insert into C_PalabrasReservadas values ("_MST_CALCU")
		insert into C_PalabrasReservadas values ("_MST_CAPTR")
		insert into C_PalabrasReservadas values ("_MST_DBASE")
		insert into C_PalabrasReservadas values ("_MST_DIARY")
		insert into C_PalabrasReservadas values ("_MST_DOCUM")
		insert into C_PalabrasReservadas values ("_MST_FILER")
		insert into C_PalabrasReservadas values ("_MST_HELP")
		insert into C_PalabrasReservadas values ("_MST_HPHOW")
		insert into C_PalabrasReservadas values ("_MST_HPSCH")
		insert into C_PalabrasReservadas values ("_MST_MACRO")
		insert into C_PalabrasReservadas values ("_MST_MSDNC")
		insert into C_PalabrasReservadas values ("_MST_MSDNI")
		insert into C_PalabrasReservadas values ("_MST_MSDNS")
		insert into C_PalabrasReservadas values ("_MST_OFFICE")
		insert into C_PalabrasReservadas values ("_MST_PUZZL")
		insert into C_PalabrasReservadas values ("_MST_SAMP")
		insert into C_PalabrasReservadas values ("_MST_SP100")
		insert into C_PalabrasReservadas values ("_MST_SP200")
		insert into C_PalabrasReservadas values ("_MST_SP300")
		insert into C_PalabrasReservadas values ("_MST_SPECL")
		insert into C_PalabrasReservadas values ("_MST_TECHS")
		insert into C_PalabrasReservadas values ("_MSYSMENU")
		insert into C_PalabrasReservadas values ("_MSYSTEM")
		insert into C_PalabrasReservadas values ("_MTABLE")
		insert into C_PalabrasReservadas values ("_MTB_APPND")
		insert into C_PalabrasReservadas values ("_MTB_CPART")
		insert into C_PalabrasReservadas values ("_MTB_DELET")
		insert into C_PalabrasReservadas values ("_MTB_DELRC")
		insert into C_PalabrasReservadas values ("_MTB_GOTO")
		insert into C_PalabrasReservadas values ("_MTB_LINK")
		insert into C_PalabrasReservadas values ("_MTB_MVFLD")
		insert into C_PalabrasReservadas values ("_MTB_MVPRT")
		insert into C_PalabrasReservadas values ("_MTB_PROPS")
		insert into C_PalabrasReservadas values ("_MTB_RECAL")
		insert into C_PalabrasReservadas values ("_MTB_SP100")
		insert into C_PalabrasReservadas values ("_MTB_SP200")
		insert into C_PalabrasReservadas values ("_MTB_SP300")
		insert into C_PalabrasReservadas values ("_MTB_SP400")
		insert into C_PalabrasReservadas values ("_MTB_SZFLD")
		insert into C_PalabrasReservadas values ("_MTI_CALLSTACK")
		insert into C_PalabrasReservadas values ("_MTI_DBGOUT")
		insert into C_PalabrasReservadas values ("_MTI_LOCALS")
		insert into C_PalabrasReservadas values ("_MTI_RUNACTIVEDOC")
		insert into C_PalabrasReservadas values ("_MTI_TRACE")
		insert into C_PalabrasReservadas values ("_MTI_WATCH")
		insert into C_PalabrasReservadas values ("_MTL_BROWSER")
		insert into C_PalabrasReservadas values ("_MTL_COVERAGE")
		insert into C_PalabrasReservadas values ("_MTL_DEBUGGER")
		insert into C_PalabrasReservadas values ("_MTL_GALLERY")
		insert into C_PalabrasReservadas values ("_MTL_MACRO")
		insert into C_PalabrasReservadas values ("_MTL_OPTNS")
		insert into C_PalabrasReservadas values ("_MTL_SP100")
		insert into C_PalabrasReservadas values ("_MTL_SP200")
		insert into C_PalabrasReservadas values ("_MTL_SP300")
		insert into C_PalabrasReservadas values ("_MTL_SP400")
		insert into C_PalabrasReservadas values ("_MTL_SPELL")
		insert into C_PalabrasReservadas values ("_MTL_WZRDS")
		insert into C_PalabrasReservadas values ("_MTOOLS")
		insert into C_PalabrasReservadas values ("_MVI_TOOLB")
		insert into C_PalabrasReservadas values ("_MVIEW")
		insert into C_PalabrasReservadas values ("_MWI_ARRAN")
		insert into C_PalabrasReservadas values ("_MWI_CLEAR")
		insert into C_PalabrasReservadas values ("_MWI_CMD")
		insert into C_PalabrasReservadas values ("_MWI_COLOR")
		insert into C_PalabrasReservadas values ("_MWI_DEBUG")
		insert into C_PalabrasReservadas values ("_MWI_HIDE")
		insert into C_PalabrasReservadas values ("_MWI_HIDEA")
		insert into C_PalabrasReservadas values ("_MWI_MIN")
		insert into C_PalabrasReservadas values ("_MWI_MOVE")
		insert into C_PalabrasReservadas values ("_MWI_ROTAT")
		insert into C_PalabrasReservadas values ("_MWI_SHOWA")
		insert into C_PalabrasReservadas values ("_MWI_SIZE")
		insert into C_PalabrasReservadas values ("_MWI_SP100")
		insert into C_PalabrasReservadas values ("_MWI_SP200")
		insert into C_PalabrasReservadas values ("_MWI_TOOLB")
		insert into C_PalabrasReservadas values ("_MWI_TRACE")
		insert into C_PalabrasReservadas values ("_MWI_VIEW")
		insert into C_PalabrasReservadas values ("_MWI_ZOOM")
		insert into C_PalabrasReservadas values ("_MWINDOW")
		insert into C_PalabrasReservadas values ("_MWIZARDS")
		insert into C_PalabrasReservadas values ("_MWZ_ALL")
		insert into C_PalabrasReservadas values ("_MWZ_APPLIC")
		insert into C_PalabrasReservadas values ("_MWZ_APPLICATION")
		insert into C_PalabrasReservadas values ("_MWZ_DATABASE")
		insert into C_PalabrasReservadas values ("_MWZ_FORM")
		insert into C_PalabrasReservadas values ("_MWZ_FOXDOC")
		insert into C_PalabrasReservadas values ("_MWZ_IMPORT")
		insert into C_PalabrasReservadas values ("_MWZ_LABEL")
		insert into C_PalabrasReservadas values ("_MWZ_MAIL")
		insert into C_PalabrasReservadas values ("_MWZ_PIVOT")
		insert into C_PalabrasReservadas values ("_MWZ_QUERY")
		insert into C_PalabrasReservadas values ("_MWZ_REPRT")
		insert into C_PalabrasReservadas values ("_MWZ_SETUP")
		insert into C_PalabrasReservadas values ("_MWZ_TABLE")
		insert into C_PalabrasReservadas values ("_MWZ_UPSIZING")
		insert into C_PalabrasReservadas values ("_MWZ_WEBPUBLISHING")
		insert into C_PalabrasReservadas values ("_NETWARE")
		insert into C_PalabrasReservadas values ("_OBJECTBROWSER")
		insert into C_PalabrasReservadas values ("_OLEBASECONTROL")
		insert into C_PalabrasReservadas values ("_OLEDRAGDROP")
		insert into C_PalabrasReservadas values ("_ORACLE")
		insert into C_PalabrasReservadas values ("_PADVANCE")
		insert into C_PalabrasReservadas values ("_PAGENO")
		insert into C_PalabrasReservadas values ("_PAGETOTAL")
		insert into C_PalabrasReservadas values ("_PBPAGE")
		insert into C_PalabrasReservadas values ("_PCOLNO")
		insert into C_PalabrasReservadas values ("_PCOPIES")
		insert into C_PalabrasReservadas values ("_PDPARMS")
		insert into C_PalabrasReservadas values ("_PDRIVER")
		insert into C_PalabrasReservadas values ("_PDSETUP")
		insert into C_PalabrasReservadas values ("_PECODE")
		insert into C_PalabrasReservadas values ("_PEJECT")
		insert into C_PalabrasReservadas values ("_PEPAGE")
		insert into C_PalabrasReservadas values ("_PFORM")
		insert into C_PalabrasReservadas values ("_PLENGTH")
		insert into C_PalabrasReservadas values ("_PLINENO")
		insert into C_PalabrasReservadas values ("_PLOFFSET")
		insert into C_PalabrasReservadas values ("_PPITCH")
		insert into C_PalabrasReservadas values ("_PQUALITY")
		insert into C_PalabrasReservadas values ("_PRETEXT")
		insert into C_PalabrasReservadas values ("_PSCODE")
		insert into C_PalabrasReservadas values ("_PSPACING")
		insert into C_PalabrasReservadas values ("_PWAIT")
		insert into C_PalabrasReservadas values ("_RECTCLASS")
		insert into C_PalabrasReservadas values ("_RMARGIN")
		insert into C_PalabrasReservadas values ("_REPORTBUILDER")
		insert into C_PalabrasReservadas values ("_REPORTPREVIEW")
		insert into C_PalabrasReservadas values ("_REPORTOUTPUT")
		insert into C_PalabrasReservadas values ("_RUNACTIVEDOC")
		insert into C_PalabrasReservadas values ("_SAMPLES")
		insert into C_PalabrasReservadas values ("_SCCTEXT")
		insert into C_PalabrasReservadas values ("_SCREEN")
		insert into C_PalabrasReservadas values ("_SHELL")
		insert into C_PalabrasReservadas values ("_SPELLCHK")
		insert into C_PalabrasReservadas values ("_SQLSERVER")
		insert into C_PalabrasReservadas values ("_STARTUP")
		insert into C_PalabrasReservadas values ("_TABS")
		insert into C_PalabrasReservadas values ("_TALLY")
		insert into C_PalabrasReservadas values ("_TASKLIST")
		insert into C_PalabrasReservadas values ("_TEXT")
		insert into C_PalabrasReservadas values ("_THROTTLE")
		insert into C_PalabrasReservadas values ("_TOOLTIPTIMEOUT")
		insert into C_PalabrasReservadas values ("_TRANSPORT")
		insert into C_PalabrasReservadas values ("_TRIGGERLEVEL")
		insert into C_PalabrasReservadas values ("_UNIX")
		insert into C_PalabrasReservadas values ("_VFP")
		insert into C_PalabrasReservadas values ("_VIEWPORT")
		insert into C_PalabrasReservadas values ("_VSBUILD")
		insert into C_PalabrasReservadas values ("_WEBDEVONLY")
		insert into C_PalabrasReservadas values ("_WEBMENU")
		insert into C_PalabrasReservadas values ("_WEBMSFTHOMEPAGE")
		insert into C_PalabrasReservadas values ("_WEBVFPHOMEPAGE")
		insert into C_PalabrasReservadas values ("_WEBVFPONLINESUPPORT")
		insert into C_PalabrasReservadas values ("_WINDOWS")
		insert into C_PalabrasReservadas values ("_WIZARD")
		insert into C_PalabrasReservadas values ("_WRAP")
		insert into C_PalabrasReservadas values ("A")
		insert into C_PalabrasReservadas values ("ABS")
		insert into C_PalabrasReservadas values ("ACCELERATE")
		insert into C_PalabrasReservadas values ("ACCEPT")
		insert into C_PalabrasReservadas values ("ACCESS")
		insert into C_PalabrasReservadas values ("ACLASS")
		insert into C_PalabrasReservadas values ("ACOPY")
		insert into C_PalabrasReservadas values ("ACOS")
		insert into C_PalabrasReservadas values ("ACTIVATE")
		insert into C_PalabrasReservadas values ("ACTIVATECELL")
		insert into C_PalabrasReservadas values ("ACTIVECOLUMN")
		insert into C_PalabrasReservadas values ("ACTIVECONTROL")
		insert into C_PalabrasReservadas values ("ACTIVEDOC")
		insert into C_PalabrasReservadas values ("ACTIVEFORM")
		insert into C_PalabrasReservadas values ("ACTIVEOBJECTID")
		insert into C_PalabrasReservadas values ("ACTIVEPAGE")
		insert into C_PalabrasReservadas values ("ACTIVEROW")
		insert into C_PalabrasReservadas values ("ADATABASES")
		insert into C_PalabrasReservadas values ("ADBOBJECTS")
		insert into C_PalabrasReservadas values ("ADD")
		insert into C_PalabrasReservadas values ("ADDBS")
		insert into C_PalabrasReservadas values ("ADDCOLUMN")
		insert into C_PalabrasReservadas values ("ADDITEM")
		insert into C_PalabrasReservadas values ("ADDITIVE")
		insert into C_PalabrasReservadas values ("ADDLISTITEM")
		insert into C_PalabrasReservadas values ("ADDOBJECT")
		insert into C_PalabrasReservadas values ("ADDPROPERTY")
		insert into C_PalabrasReservadas values ("ADDRELATIONTOENV")
		insert into C_PalabrasReservadas values ("ADDTABLETOENV")
		insert into C_PalabrasReservadas values ("ADDTABLESCHEMA")
		insert into C_PalabrasReservadas values ("ADOCKSTATE")
		insert into C_PalabrasReservadas values ("ADOCODEPAGE")
		insert into C_PalabrasReservadas values ("ADEL")
		insert into C_PalabrasReservadas values ("ADIR")
		insert into C_PalabrasReservadas values ("ADLLS")
		insert into C_PalabrasReservadas values ("ADMIN")
		insert into C_PalabrasReservadas values ("ADOCKSTATE")
		insert into C_PalabrasReservadas values ("ADJUSTOBJECTSIZE")
		insert into C_PalabrasReservadas values ("AELEMENT")
		insert into C_PalabrasReservadas values ("AERROR")
		insert into C_PalabrasReservadas values ("AEVENTS")
		insert into C_PalabrasReservadas values ("AFIELDS")
		insert into C_PalabrasReservadas values ("AFONT")
		insert into C_PalabrasReservadas values ("AFTER")
		insert into C_PalabrasReservadas values ("AFTERBAND")
		insert into C_PalabrasReservadas values ("AFTERBUILD")
		insert into C_PalabrasReservadas values ("AFTERCLOSETABLES")
		insert into C_PalabrasReservadas values ("AFTERCURSORATTACH")
		insert into C_PalabrasReservadas values ("AFTERCURSORCLOSE")
		insert into C_PalabrasReservadas values ("AFTERCURSORDETACH")
		insert into C_PalabrasReservadas values ("AFTERCURSORFILL")
		insert into C_PalabrasReservadas values ("AFTERCURSORREFRESH")
		insert into C_PalabrasReservadas values ("AFTERCURSORUPDATE")
		insert into C_PalabrasReservadas values ("AFTERDELETE")
		insert into C_PalabrasReservadas values ("AFTERDOCK")
		insert into C_PalabrasReservadas values ("AFTERINSERT")
		insert into C_PalabrasReservadas values ("AFTERRECORDREFRESH")
		insert into C_PalabrasReservadas values ("AFTERREPORT")
		insert into C_PalabrasReservadas values ("AFTERROWCOLCHANGE")
		insert into C_PalabrasReservadas values ("AFTERUPDATE")
		insert into C_PalabrasReservadas values ("AGAIN")
		insert into C_PalabrasReservadas values ("AGETCLASS")
		insert into C_PalabrasReservadas values ("AGETFILEVERSION")
		insert into C_PalabrasReservadas values ("AINDENT")
		insert into C_PalabrasReservadas values ("AINS")
		insert into C_PalabrasReservadas values ("AINSTANCE")
		insert into C_PalabrasReservadas values ("ALANGUAGE")
		insert into C_PalabrasReservadas values ("ALEN")
		insert into C_PalabrasReservadas values ("ALIAS")
		insert into C_PalabrasReservadas values ("ALIGN")
		insert into C_PalabrasReservadas values ("ALIGNMENT")
		insert into C_PalabrasReservadas values ("ALIGNRIGHT")
		insert into C_PalabrasReservadas values ("ALINES")
		insert into C_PalabrasReservadas values ("ALL")
		insert into C_PalabrasReservadas values ("ALLOWADDNEW")
		insert into C_PalabrasReservadas values ("ALLOWAUTOCOLUMNFIT")
		insert into C_PalabrasReservadas values ("ALLOWCELLSELECTION")
		insert into C_PalabrasReservadas values ("ALLOWDELETE")
		insert into C_PalabrasReservadas values ("ALLOWEXTERNAL")
		insert into C_PalabrasReservadas values ("ALLOWHEADERSIZING")
		insert into C_PalabrasReservadas values ("ALLOWINSERT")
		insert into C_PalabrasReservadas values ("ALLOWMODALMESSAGES")
		insert into C_PalabrasReservadas values ("ALLOWOUTPUT")
		insert into C_PalabrasReservadas values ("ALLOWRESIZE")
		insert into C_PalabrasReservadas values ("ALLOWROWSIZING")
		insert into C_PalabrasReservadas values ("ALLOWTABS")
		insert into C_PalabrasReservadas values ("ALLOWTABS+")
		insert into C_PalabrasReservadas values ("ALLOWUPDATE")
		insert into C_PalabrasReservadas values ("ALLTRIM")
		insert into C_PalabrasReservadas values ("ALT")
		insert into C_PalabrasReservadas values ("ALTER")
		insert into C_PalabrasReservadas values ("ALTERNATE")
		insert into C_PalabrasReservadas values ("ALWAYSONBOTTOM")
		insert into C_PalabrasReservadas values ("ALWAYSONTOP")
		insert into C_PalabrasReservadas values ("AMEMBERS")
		insert into C_PalabrasReservadas values ("AMOUSEOBJ")
		insert into C_PalabrasReservadas values ("ANCHOR")
		insert into C_PalabrasReservadas values ("AND")
		insert into C_PalabrasReservadas values ("ANETRESOURCES")
		insert into C_PalabrasReservadas values ("ANSI")
		insert into C_PalabrasReservadas values ("ANSITOOEM")
		insert into C_PalabrasReservadas values ("ANY")
		insert into C_PalabrasReservadas values ("APLABOUT")
		insert into C_PalabrasReservadas values ("APP")
		insert into C_PalabrasReservadas values ("APPEND")
		insert into C_PalabrasReservadas values ("APPLICATION")
		insert into C_PalabrasReservadas values ("APPLYDIFFGRAM")
		insert into C_PalabrasReservadas values ("APRINTERS")
		insert into C_PalabrasReservadas values ("APROCINFO")
		insert into C_PalabrasReservadas values ("ARRAY")
		insert into C_PalabrasReservadas values ("AS")
		insert into C_PalabrasReservadas values ("ASC")
		insert into C_PalabrasReservadas values ("ASCAN")
		insert into C_PalabrasReservadas values ("ASCENDING")
		insert into C_PalabrasReservadas values ("ASCII")
		insert into C_PalabrasReservadas values ("ASELOBJ")
		insert into C_PalabrasReservadas values ("ASESSIONS")
		insert into C_PalabrasReservadas values ("ASIN")
		insert into C_PalabrasReservadas values ("ASORT")
		insert into C_PalabrasReservadas values ("ASQLHANDLES")
		insert into C_PalabrasReservadas values ("ASSERT")
		insert into C_PalabrasReservadas values ("ASSERTS")
		insert into C_PalabrasReservadas values ("ASSIST")
		insert into C_PalabrasReservadas values ("ASTACKINFO")
		insert into C_PalabrasReservadas values ("ASUBSCRIPT")
		insert into C_PalabrasReservadas values ("ASYNCHRONOUS")
		insert into C_PalabrasReservadas values ("AT")
		insert into C_PalabrasReservadas values ("AT_C")
		insert into C_PalabrasReservadas values ("ATAGINFO")
		insert into C_PalabrasReservadas values ("ATAN")
		insert into C_PalabrasReservadas values ("ATC")
		insert into C_PalabrasReservadas values ("ATCC")
		insert into C_PalabrasReservadas values ("ATCLINE")
		insert into C_PalabrasReservadas values ("ATGETCOLORS")
		insert into C_PalabrasReservadas values ("ATLINE")
		insert into C_PalabrasReservadas values ("ATLISTCOLORS")
		insert into C_PalabrasReservadas values ("ATN2")
		insert into C_PalabrasReservadas values ("ATTACH")
		insert into C_PalabrasReservadas values ("ATTRIBUTES")
		insert into C_PalabrasReservadas values ("AUSED")
		insert into C_PalabrasReservadas values ("AUTOACTIVATE")
		insert into C_PalabrasReservadas values ("AUTOCENTER")
		insert into C_PalabrasReservadas values ("AUTOCLOSETABLES")
		insert into C_PalabrasReservadas values ("AUTOCOMPLETE")
		insert into C_PalabrasReservadas values ("AUTOCOMPSOURCE")
		insert into C_PalabrasReservadas values ("AUTOCOMPTABLE")
		insert into C_PalabrasReservadas values ("AUTOFIT")
		insert into C_PalabrasReservadas values ("AUTOFORM")
		insert into C_PalabrasReservadas values ("AUTOHIDESCROLLBAR")
		insert into C_PalabrasReservadas values ("AUTOINC")
		insert into C_PalabrasReservadas values ("AUTOINCERROR")
		insert into C_PalabrasReservadas values ("AUTOMATIC")
		insert into C_PalabrasReservadas values ("AUTOOPEN")
		insert into C_PalabrasReservadas values ("AUTOOPENTABLES")
		insert into C_PalabrasReservadas values ("AUTORELEASE")
		insert into C_PalabrasReservadas values ("AUTOREPORT")
		insert into C_PalabrasReservadas values ("AUTOSAVE")
		insert into C_PalabrasReservadas values ("AUTOSIZE")
		insert into C_PalabrasReservadas values ("AUTOVERBMENU")
		insert into C_PalabrasReservadas values ("AUTOYIELD")
		insert into C_PalabrasReservadas values ("AVAILNUM")
		insert into C_PalabrasReservadas values ("AVCXCLASSES")
		insert into C_PalabrasReservadas values ("AVERAGE")
		insert into C_PalabrasReservadas values ("AVG")
		insert into C_PalabrasReservadas values ("B")
		insert into C_PalabrasReservadas values ("BACKCOLOR")
		insert into C_PalabrasReservadas values ("BACKSTYLE")
		insert into C_PalabrasReservadas values ("BACKSTYLE")
		insert into C_PalabrasReservadas values ("BAR")
		insert into C_PalabrasReservadas values ("BARCOUNT")
		insert into C_PalabrasReservadas values ("BARPROMPT")
		insert into C_PalabrasReservadas values ("BASECLASS")
		insert into C_PalabrasReservadas values ("BATCHMODE")
		insert into C_PalabrasReservadas values ("BATCHUPDATECOUNT")
		insert into C_PalabrasReservadas values ("BEFORE")
		insert into C_PalabrasReservadas values ("BEFOREBAND")
		insert into C_PalabrasReservadas values ("BEFOREBUILD")
		insert into C_PalabrasReservadas values ("BEFORECURSORATTACH")
		insert into C_PalabrasReservadas values ("BEFORECURSORCLOSE")
		insert into C_PalabrasReservadas values ("BEFORECURSORDETACH")
		insert into C_PalabrasReservadas values ("BEFORECURSORFILL")
		insert into C_PalabrasReservadas values ("BEFORECURSORREFRESH")
		insert into C_PalabrasReservadas values ("BEFORECURSORUPDATE")
		insert into C_PalabrasReservadas values ("BEFOREDELETE")
		insert into C_PalabrasReservadas values ("BEFOREDOCK")
		insert into C_PalabrasReservadas values ("BEFOREINSERT")
		insert into C_PalabrasReservadas values ("BEFOREOPENTABLES")
		insert into C_PalabrasReservadas values ("BEFORERECORDREFRESH")
		insert into C_PalabrasReservadas values ("BEFOREREPORT")
		insert into C_PalabrasReservadas values ("BEFOREROWCOLCHANGE")
		insert into C_PalabrasReservadas values ("BEFOREUPDATE")
		insert into C_PalabrasReservadas values ("BEGIN")
		insert into C_PalabrasReservadas values ("BELL")
		insert into C_PalabrasReservadas values ("BELLSOUND")
		insert into C_PalabrasReservadas values ("BETWEEN")
		insert into C_PalabrasReservadas values ("BINDCONTROLS")
		insert into C_PalabrasReservadas values ("BINDEVENT")
		insert into C_PalabrasReservadas values ("BINTOC")
		insert into C_PalabrasReservadas values ("BITAND")
		insert into C_PalabrasReservadas values ("BITCLEAR")
		insert into C_PalabrasReservadas values ("BITLSHIFT")
		insert into C_PalabrasReservadas values ("BITMAP")
		insert into C_PalabrasReservadas values ("BITNOT")
		insert into C_PalabrasReservadas values ("BITOR")
		insert into C_PalabrasReservadas values ("BITRSHIFT")
		insert into C_PalabrasReservadas values ("BITSET")
		insert into C_PalabrasReservadas values ("BITTEST")
		insert into C_PalabrasReservadas values ("BITXOR")
		insert into C_PalabrasReservadas values ("BLANK")
		insert into C_PalabrasReservadas values ("BLINK")
		insert into C_PalabrasReservadas values ("BLOB")
		insert into C_PalabrasReservadas values ("BLOCKSIZE")
		insert into C_PalabrasReservadas values ("BOF")
		insert into C_PalabrasReservadas values ("BORDER")
		insert into C_PalabrasReservadas values ("BORDERCOLOR")
		insert into C_PalabrasReservadas values ("BORDERSTYLE")
		insert into C_PalabrasReservadas values ("BORDERWIDTH")
		insert into C_PalabrasReservadas values ("BOTTOM")
		insert into C_PalabrasReservadas values ("BOUND")
		insert into C_PalabrasReservadas values ("BOUNDCOLUMN")
		insert into C_PalabrasReservadas values ("BOUNDTO")
		insert into C_PalabrasReservadas values ("BOX")
		insert into C_PalabrasReservadas values ("BROWSE")
		insert into C_PalabrasReservadas values ("BROWSEALIGNMENT")
		insert into C_PalabrasReservadas values ("BROWSECELLMARG")
		insert into C_PalabrasReservadas values ("BROWSEDESTWIDTH")
		insert into C_PalabrasReservadas values ("BROWSEIMECONTROL")
		insert into C_PalabrasReservadas values ("BROWSEREFRESH")
		insert into C_PalabrasReservadas values ("BRSTATUS")
		insert into C_PalabrasReservadas values ("BUCKET")
		insert into C_PalabrasReservadas values ("BUFFERING")
		insert into C_PalabrasReservadas values ("BUFFERMODE")
		insert into C_PalabrasReservadas values ("BUFFERMODEOVERRIDE")
		insert into C_PalabrasReservadas values ("BUFFERS")
		insert into C_PalabrasReservadas values ("BUILD")
		insert into C_PalabrasReservadas values ("BUILDERLOCK")
		insert into C_PalabrasReservadas values ("BUTTONCOUNT")
		insert into C_PalabrasReservadas values ("BUTTONINDEX")
		insert into C_PalabrasReservadas values ("BUTTONS")
		insert into C_PalabrasReservadas values ("BUTTONSBOF")
		insert into C_PalabrasReservadas values ("BY")
		insert into C_PalabrasReservadas values ("C")
		insert into C_PalabrasReservadas values ("CALCULATE")
		insert into C_PalabrasReservadas values ("CALL")
		insert into C_PalabrasReservadas values ("CANACCELERATE")
		insert into C_PalabrasReservadas values ("CANCEL")
		insert into C_PalabrasReservadas values ("CANCELREPORT")
		insert into C_PalabrasReservadas values ("CANDIDATE")
		insert into C_PalabrasReservadas values ("CANGETFOCUS")
		insert into C_PalabrasReservadas values ("CANLOSEFOCUS")
		insert into C_PalabrasReservadas values ("CAPSLOCK")
		insert into C_PalabrasReservadas values ("CAPTION")
		insert into C_PalabrasReservadas values ("CARRY")
		insert into C_PalabrasReservadas values ("CASCADE")
		insert into C_PalabrasReservadas values ("CASE")
		insert into C_PalabrasReservadas values ("CAST")
		insert into C_PalabrasReservadas values ("CATALOG")
		insert into C_PalabrasReservadas values ("CATCH")
		insert into C_PalabrasReservadas values ("CD")
		insert into C_PalabrasReservadas values ("CDOW")
		insert into C_PalabrasReservadas values ("CDX")
		insert into C_PalabrasReservadas values ("CEILING")
		insert into C_PalabrasReservadas values ("CENTER")
		insert into C_PalabrasReservadas values ("CENTERED")
		insert into C_PalabrasReservadas values ("CENTRAL")
		insert into C_PalabrasReservadas values ("CENTURY")
		insert into C_PalabrasReservadas values ("CGA")
		insert into C_PalabrasReservadas values ("CHANGE")
		insert into C_PalabrasReservadas values ("CHANGESTOCURSOR")
		insert into C_PalabrasReservadas values ("CHAR")
		insert into C_PalabrasReservadas values ("CHARACTER")
		insert into C_PalabrasReservadas values ("CHDIR")
		insert into C_PalabrasReservadas values ("CHECK")
		insert into C_PalabrasReservadas values ("CHECKBOX")
		insert into C_PalabrasReservadas values ("CHILDALIAS")
		insert into C_PalabrasReservadas values ("CHILDORDER")
		insert into C_PalabrasReservadas values ("CHILDORDER")
		insert into C_PalabrasReservadas values ("CHILDTABLE")
		insert into C_PalabrasReservadas values ("CHR")
		insert into C_PalabrasReservadas values ("CHRSAW")
		insert into C_PalabrasReservadas values ("CHRTRAN")
		insert into C_PalabrasReservadas values ("CHRTRANC")
		insert into C_PalabrasReservadas values ("CIRCLE")
		insert into C_PalabrasReservadas values ("CLASS")
		insert into C_PalabrasReservadas values ("CLASS")
		insert into C_PalabrasReservadas values ("CLASSLIB")
		insert into C_PalabrasReservadas values ("CLASSLIBRARY")
		insert into C_PalabrasReservadas values ("CLEAR")
		insert into C_PalabrasReservadas values ("CLEARDATA")
		insert into C_PalabrasReservadas values ("CLEARRESULTSET")
		insert into C_PalabrasReservadas values ("CLEARSTATUS")
		insert into C_PalabrasReservadas values ("CLICK")
		insert into C_PalabrasReservadas values ("CLIPCONTROLS")
		insert into C_PalabrasReservadas values ("CLIPRECT")
		insert into C_PalabrasReservadas values ("CLOCK")
		insert into C_PalabrasReservadas values ("CLONEOBJECT")
		insert into C_PalabrasReservadas values ("CLOSABLE")
		insert into C_PalabrasReservadas values ("CLOSE")
		insert into C_PalabrasReservadas values ("CLOSEEDITOR")
		insert into C_PalabrasReservadas values ("CLOSETABLES")
		insert into C_PalabrasReservadas values ("CLS")
		insert into C_PalabrasReservadas values ("CMONTH")
		insert into C_PalabrasReservadas values ("CNT")
		insert into C_PalabrasReservadas values ("CNTBAR")
		insert into C_PalabrasReservadas values ("CNTPAD")
		insert into C_PalabrasReservadas values ("CODEPAGE")
		insert into C_PalabrasReservadas values ("COL")
		insert into C_PalabrasReservadas values ("COLLATE")
		insert into C_PalabrasReservadas values ("COLLECTION")
		insert into C_PalabrasReservadas values ("COLOR")
		insert into C_PalabrasReservadas values ("COLORSCHEME")
		insert into C_PalabrasReservadas values ("COLORSOURCE")
		insert into C_PalabrasReservadas values ("COLUMN")
		insert into C_PalabrasReservadas values ("COLUMNCOUNT")
		insert into C_PalabrasReservadas values ("COLUMNHEADERS")
		insert into C_PalabrasReservadas values ("COLUMNLINES")
		insert into C_PalabrasReservadas values ("COLUMNORDER")
		insert into C_PalabrasReservadas values ("COLUMNS")
		insert into C_PalabrasReservadas values ("COLUMNWIDTHS")
		insert into C_PalabrasReservadas values ("COM1")
		insert into C_PalabrasReservadas values ("COM2")
		insert into C_PalabrasReservadas values ("COMARRAY")
		insert into C_PalabrasReservadas values ("COMBOBOX")
		insert into C_PalabrasReservadas values ("COMCLASSINFO")
		insert into C_PalabrasReservadas values ("COMMAND")
		insert into C_PalabrasReservadas values ("COMMANDBUTTON")
		insert into C_PalabrasReservadas values ("COMMANDCLAUSES")
		insert into C_PalabrasReservadas values ("COMMANDGROUP")
		insert into C_PalabrasReservadas values ("COMMANDTARGETEXEC")
		insert into C_PalabrasReservadas values ("COMMANDTARGETQUERY")
		insert into C_PalabrasReservadas values ("COMMENT")
		insert into C_PalabrasReservadas values ("COMPACT")
		insert into C_PalabrasReservadas values ("COMPAREMEMO")
		insert into C_PalabrasReservadas values ("COMPATIBLE")
		insert into C_PalabrasReservadas values ("COMPILE")
		insert into C_PalabrasReservadas values ("COMPLETED")
		insert into C_PalabrasReservadas values ("COMPOBJ")
		insert into C_PalabrasReservadas values ("COMPRESS")
		insert into C_PalabrasReservadas values ("COMPUTE")
		insert into C_PalabrasReservadas values ("COMRETURNERROR")
		insert into C_PalabrasReservadas values ("CONCAT")
		insert into C_PalabrasReservadas values ("CONFIRM")
		insert into C_PalabrasReservadas values ("CONFLICTCHECKCMD")
		insert into C_PalabrasReservadas values ("CONFLICTCHECKTYPE")
		insert into C_PalabrasReservadas values ("CONNECTBUSY")
		insert into C_PalabrasReservadas values ("CONNECTHANDLE")
		insert into C_PalabrasReservadas values ("CONNECTION")
		insert into C_PalabrasReservadas values ("CONNECTIONS")
		insert into C_PalabrasReservadas values ("CONNECTNAME")
		insert into C_PalabrasReservadas values ("CONNECTSTRING")
		insert into C_PalabrasReservadas values ("CONNECTTIMEOUT")
		insert into C_PalabrasReservadas values ("CONNSTRING")
		insert into C_PalabrasReservadas values ("CONSOLE")
		insert into C_PalabrasReservadas values ("CONTAINER")
		insert into C_PalabrasReservadas values ("CONTAINERRELEASE")
		insert into C_PalabrasReservadas values ("CONTAINERRELEASETYPE")
		insert into C_PalabrasReservadas values ("CONTINUE")
		insert into C_PalabrasReservadas values ("CONTINUOUSSCROLL")
		insert into C_PalabrasReservadas values ("CONTROL")
		insert into C_PalabrasReservadas values ("CONTROLBOX")
		insert into C_PalabrasReservadas values ("CONTROLCOUNT")
		insert into C_PalabrasReservadas values ("CONTROLINDEX")
		insert into C_PalabrasReservadas values ("CONTROLS")
		insert into C_PalabrasReservadas values ("CONTROLSOURCE")
		insert into C_PalabrasReservadas values ("CONVERSIONFUNC")
		insert into C_PalabrasReservadas values ("COPIES")
		insert into C_PalabrasReservadas values ("COPY")
		insert into C_PalabrasReservadas values ("COS")
		insert into C_PalabrasReservadas values ("COT")
		insert into C_PalabrasReservadas values ("COUNT")
		insert into C_PalabrasReservadas values ("COVERAGE")
		insert into C_PalabrasReservadas values ("CPCOMPILE")
		insert into C_PalabrasReservadas values ("CPCONVERT")
		insert into C_PalabrasReservadas values ("CPCURRENT")
		insert into C_PalabrasReservadas values ("CPDBF")
		insert into C_PalabrasReservadas values ("CPDIALOG")
		insert into C_PalabrasReservadas values ("CPNOTRANS")
		insert into C_PalabrasReservadas values ("CREATE")
		insert into C_PalabrasReservadas values ("CREATEBINARY")
		insert into C_PalabrasReservadas values ("CREATEOBJECT")
		insert into C_PalabrasReservadas values ("CREATEOBJECTEX")
		insert into C_PalabrasReservadas values ("CREATEOFFLINE")
		insert into C_PalabrasReservadas values ("CRSBUFFERING")
		insert into C_PalabrasReservadas values ("CRSFETCHMEMO")
		insert into C_PalabrasReservadas values ("CRSFETCHSIZE")
		insert into C_PalabrasReservadas values ("CRSMAXROWS")
		insert into C_PalabrasReservadas values ("CRSMETHODUSED")
		insert into C_PalabrasReservadas values ("CRSNUMBATCH")
		insert into C_PalabrasReservadas values ("CRSSHARECONNECTION")
		insert into C_PalabrasReservadas values ("CRSUSEMEMOSIZE")
		insert into C_PalabrasReservadas values ("CRSWHERECLAUSE")
		insert into C_PalabrasReservadas values ("CSV")
		insert into C_PalabrasReservadas values ("CTOBIN")
		insert into C_PalabrasReservadas values ("CTOBIN")
		insert into C_PalabrasReservadas values ("CTOD")
		insert into C_PalabrasReservadas values ("CTOT")
		insert into C_PalabrasReservadas values ("CURDATE")
		insert into C_PalabrasReservadas values ("CURDIR")
		insert into C_PalabrasReservadas values ("CURRENCY")
		insert into C_PalabrasReservadas values ("CURRENTCONTROL")
		insert into C_PalabrasReservadas values ("CURRENTDATASESSION")
		insert into C_PalabrasReservadas values ("CURRENTPASS")
		insert into C_PalabrasReservadas values ("CURRENTX")
		insert into C_PalabrasReservadas values ("CURRENTY")
		insert into C_PalabrasReservadas values ("CURRENTY")
		insert into C_PalabrasReservadas values ("CURRLEFT")
		insert into C_PalabrasReservadas values ("CURRSYMBOL")
		insert into C_PalabrasReservadas values ("CURSOR")
		insert into C_PalabrasReservadas values ("CURSORADAPTER")
		insert into C_PalabrasReservadas values ("CURSORATTACH")
		insert into C_PalabrasReservadas values ("CURSORDETACH")
		insert into C_PalabrasReservadas values ("CURSORFILL")
		insert into C_PalabrasReservadas values ("CURSORGETPROP")
		insert into C_PalabrasReservadas values ("CURSORREFRESH")
		insert into C_PalabrasReservadas values ("CURSORSCHEMA")
		insert into C_PalabrasReservadas values ("CURSORSETPROP")
		insert into C_PalabrasReservadas values ("CURSORSOURCE")
		insert into C_PalabrasReservadas values ("CURSORSTATUS")
		insert into C_PalabrasReservadas values ("CURSORTORS")
		insert into C_PalabrasReservadas values ("CURSORTOXML")
		insert into C_PalabrasReservadas values ("CURTIME")
		insert into C_PalabrasReservadas values ("CURVAL")
		insert into C_PalabrasReservadas values ("CURVATURE")
		insert into C_PalabrasReservadas values ("CUSTOM")
		insert into C_PalabrasReservadas values ("CYCLE")
		insert into C_PalabrasReservadas values ("D")
		insert into C_PalabrasReservadas values ("DATABASE")
		insert into C_PalabrasReservadas values ("DATABASES")
		insert into C_PalabrasReservadas values ("DATAENVIRONMENT")
		insert into C_PalabrasReservadas values ("DATAOBJECT")
		insert into C_PalabrasReservadas values ("DATASESSION")
		insert into C_PalabrasReservadas values ("DATASESSIONID")
		insert into C_PalabrasReservadas values ("DATASOURCE")
		insert into C_PalabrasReservadas values ("DATASOURCEOBJ")
		insert into C_PalabrasReservadas values ("DATASOURCETYPE")
		insert into C_PalabrasReservadas values ("DATATOCLIP")
		insert into C_PalabrasReservadas values ("DATATYPE")
		insert into C_PalabrasReservadas values ("DATE")
		insert into C_PalabrasReservadas values ("DATEFORMAT")
		insert into C_PalabrasReservadas values ("DATEMARK")
		insert into C_PalabrasReservadas values ("DATETIME")
		insert into C_PalabrasReservadas values ("DAY")
		insert into C_PalabrasReservadas values ("DAYNAME")
		insert into C_PalabrasReservadas values ("DAYOFMONTH")
		insert into C_PalabrasReservadas values ("DAYOFWEEK")
		insert into C_PalabrasReservadas values ("DAYOFYEAR")
		insert into C_PalabrasReservadas values ("DB_BUFLOCKROW")
		insert into C_PalabrasReservadas values ("DB_BUFLOCKTABLE")
		insert into C_PalabrasReservadas values ("DB_BUFOFF")
		insert into C_PalabrasReservadas values ("DB_BUFOPTROW")
		insert into C_PalabrasReservadas values ("DB_BUFOPTTABLE")
		insert into C_PalabrasReservadas values ("DB_COMPLETTE")
		insert into C_PalabrasReservadas values ("DB_DELETEINSERT")
		insert into C_PalabrasReservadas values ("DB_KEYANDMODIFIED")
		insert into C_PalabrasReservadas values ("DB_KEYANDTIMESTAMP")
		insert into C_PalabrasReservadas values ("DB_KEYANDUPDATABLE")
		insert into C_PalabrasReservadas values ("DB_LOCALSQL")
		insert into C_PalabrasReservadas values ("DB_NOPROMPT")
		insert into C_PalabrasReservadas values ("DB_PROMPT")
		insert into C_PalabrasReservadas values ("DB_REMOTESQL")
		insert into C_PalabrasReservadas values ("DB_TRANSAUTO")
		insert into C_PalabrasReservadas values ("DB_TRANSMANUAL")
		insert into C_PalabrasReservadas values ("DB_TRANSNONE")
		insert into C_PalabrasReservadas values ("DB_UPDATE")
		insert into C_PalabrasReservadas values ("DB4")
		insert into C_PalabrasReservadas values ("DB4")
		insert into C_PalabrasReservadas values ("DBALIAS")
		insert into C_PalabrasReservadas values ("DBC")
		insert into C_PalabrasReservadas values ("DBC_Activate")
		insert into C_PalabrasReservadas values ("DBC_AfterAddRelation")
		insert into C_PalabrasReservadas values ("DBC_AfterAddTable")
		insert into C_PalabrasReservadas values ("DBC_AfterAppendProc")
		insert into C_PalabrasReservadas values ("DBC_AfterCloseTable")
		insert into C_PalabrasReservadas values ("DBC_AfterCopyProc")
		insert into C_PalabrasReservadas values ("DBC_AfterCreateConnection")
		insert into C_PalabrasReservadas values ("DBC_AfterCreateOffline")
		insert into C_PalabrasReservadas values ("DBC_AfterCreateTable")
		insert into C_PalabrasReservadas values ("DBC_AfterCreateView")
		insert into C_PalabrasReservadas values ("DBC_AfterDBGetProp")
		insert into C_PalabrasReservadas values ("DBC_AfterDBSetProp")
		insert into C_PalabrasReservadas values ("DBC_AfterDeleteConnection")
		insert into C_PalabrasReservadas values ("DBC_AfterDropOffline")
		insert into C_PalabrasReservadas values ("DBC_AfterDropRelation ")
		insert into C_PalabrasReservadas values ("DBC_AfterDropTable")
		insert into C_PalabrasReservadas values ("DBC_AfterDropView")
		insert into C_PalabrasReservadas values ("DBC_AfterModifyConnection")
		insert into C_PalabrasReservadas values ("DBC_AfterModifyProc")
		insert into C_PalabrasReservadas values ("DBC_AfterModifyTable")
		insert into C_PalabrasReservadas values ("DBC_AfterModifyView")
		insert into C_PalabrasReservadas values ("DBC_AfterOpenTable")
		insert into C_PalabrasReservadas values ("DBC_AfterRemoveTable")
		insert into C_PalabrasReservadas values ("DBC_AfterRenameConnection")
		insert into C_PalabrasReservadas values ("DBC_AfterRenameTable")
		insert into C_PalabrasReservadas values ("DBC_AfterRenameView")
		insert into C_PalabrasReservadas values ("DBC_AfterValidateData")
		insert into C_PalabrasReservadas values ("DBC_BeforeAddRelation")
		insert into C_PalabrasReservadas values ("DBC_BeforeAddTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeAppendProc")
		insert into C_PalabrasReservadas values ("DBC_BeforeCloseTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeCopyProc")
		insert into C_PalabrasReservadas values ("DBC_BeforeCreateConnection")
		insert into C_PalabrasReservadas values ("DBC_BeforeCreateOffline")
		insert into C_PalabrasReservadas values ("DBC_BeforeCreateTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeCreateView")
		insert into C_PalabrasReservadas values ("DBC_BeforeDBGetProp")
		insert into C_PalabrasReservadas values ("DBC_BeforeDBSetProp")
		insert into C_PalabrasReservadas values ("DBC_BeforeDeleteConnection")
		insert into C_PalabrasReservadas values ("DBC_BeforeDropOffline")
		insert into C_PalabrasReservadas values ("DBC_BeforeDropRelation")
		insert into C_PalabrasReservadas values ("DBC_BeforeDropTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeDropView")
		insert into C_PalabrasReservadas values ("DBC_BeforeModifyConnection")
		insert into C_PalabrasReservadas values ("DBC_BeforeModifyProc")
		insert into C_PalabrasReservadas values ("DBC_BeforeModifyTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeModifyView")
		insert into C_PalabrasReservadas values ("DBC_BeforeOpenTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeRemoveTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeRenameConnection")
		insert into C_PalabrasReservadas values ("DBC_BeforeRenameTable")
		insert into C_PalabrasReservadas values ("DBC_BeforeRenameView")
		insert into C_PalabrasReservadas values ("DBC_BeforeValidateData")
		insert into C_PalabrasReservadas values ("DBC_CloseData")
		insert into C_PalabrasReservadas values ("DBC_Deactivate")
		insert into C_PalabrasReservadas values ("DBC_ModifyData")
		insert into C_PalabrasReservadas values ("DBC_OpenData")
		insert into C_PalabrasReservadas values ("DBC_PackData")
		insert into C_PalabrasReservadas values ("DBF")
		insert into C_PalabrasReservadas values ("DBFDBLCLICK")
		insert into C_PalabrasReservadas values ("DBGETPROP")
		insert into C_PalabrasReservadas values ("DBLCLICK")
		insert into C_PalabrasReservadas values ("DBMEMO3")
		insert into C_PalabrasReservadas values ("DBSETPROP")
		insert into C_PalabrasReservadas values ("DBTRAP")
		insert into C_PalabrasReservadas values ("DBUSED")
		insert into C_PalabrasReservadas values ("DDEABORTTRANS")
		insert into C_PalabrasReservadas values ("DDEADVISE")
		insert into C_PalabrasReservadas values ("DDEENABLED")
		insert into C_PalabrasReservadas values ("DDEEXECUTE")
		insert into C_PalabrasReservadas values ("DDEINITIATE")
		insert into C_PalabrasReservadas values ("DDELASTERROR")
		insert into C_PalabrasReservadas values ("DDEPOKE")
		insert into C_PalabrasReservadas values ("DDEREQUEST")
		insert into C_PalabrasReservadas values ("DDESETOPTION")
		insert into C_PalabrasReservadas values ("DDESETSERVICE")
		insert into C_PalabrasReservadas values ("DDESETTOPIC")
		insert into C_PalabrasReservadas values ("DDETERMINATE")
		insert into C_PalabrasReservadas values ("DEACTIVATE")
		insert into C_PalabrasReservadas values ("DEACTIVATE")
		insert into C_PalabrasReservadas values ("DEBUG")
		insert into C_PalabrasReservadas values ("DEBUGGER")
		insert into C_PalabrasReservadas values ("DEBUGOUT")
		insert into C_PalabrasReservadas values ("DECIMALS")
		insert into C_PalabrasReservadas values ("DECLARE")
		insert into C_PalabrasReservadas values ("DECLAREXMLPREFIX")
		insert into C_PalabrasReservadas values ("DECLASS")
		insert into C_PalabrasReservadas values ("DECLASSLIBRARY")
		insert into C_PalabrasReservadas values ("DEFAULT")
		insert into C_PalabrasReservadas values ("DEFAULTEXT")
		insert into C_PalabrasReservadas values ("DEFAULTFILEPATH")
		insert into C_PalabrasReservadas values ("DEFAULTSOURCE")
		insert into C_PalabrasReservadas values ("DEFAULTVALUE")
		insert into C_PalabrasReservadas values ("DEFBUTTON")
		insert into C_PalabrasReservadas values ("DEFBUTTONORIG")
		insert into C_PalabrasReservadas values ("DEFHEIGHT")
		insert into C_PalabrasReservadas values ("DEFINE")
		insert into C_PalabrasReservadas values ("DEFINEWINDOWS")
		insert into C_PalabrasReservadas values ("DEFLEFT")
		insert into C_PalabrasReservadas values ("DEFOLELCID")
		insert into C_PalabrasReservadas values ("DEFTOP")
		insert into C_PalabrasReservadas values ("DEFWIDTH")
		insert into C_PalabrasReservadas values ("DEGREES")
		insert into C_PalabrasReservadas values ("DELAYBIND")
		insert into C_PalabrasReservadas values ("DELAYEDMEMOFETCH")
		insert into C_PalabrasReservadas values ("DELETE")
		insert into C_PalabrasReservadas values ("DELETECMD")
		insert into C_PalabrasReservadas values ("DELETECMDDATASOURCE")
		insert into C_PalabrasReservadas values ("DELETECMDDATASOURCETYPE")
		insert into C_PalabrasReservadas values ("DELETECOLUMN")
		insert into C_PalabrasReservadas values ("DELETED")
		insert into C_PalabrasReservadas values ("DELETEMARK")
		insert into C_PalabrasReservadas values ("DELETETABLES")
		insert into C_PalabrasReservadas values ("DELETETRIGGER")
		insert into C_PalabrasReservadas values ("DELIMITED")
		insert into C_PalabrasReservadas values ("DELIMITERS")
		insert into C_PalabrasReservadas values ("DESC")
		insert into C_PalabrasReservadas values ("DESCENDING")
		insert into C_PalabrasReservadas values ("DESCRIPTION")
		insert into C_PalabrasReservadas values ("DESIGN")
		insert into C_PalabrasReservadas values ("DESKTOP")
		insert into C_PalabrasReservadas values ("DESTROY")
		insert into C_PalabrasReservadas values ("DETAILS")
		insert into C_PalabrasReservadas values ("DEVELOPMENT")
		insert into C_PalabrasReservadas values ("DEVICE")
		insert into C_PalabrasReservadas values ("DIF")
		insert into C_PalabrasReservadas values ("DIFFERENCE")
		insert into C_PalabrasReservadas values ("DIMENSION")
		insert into C_PalabrasReservadas values ("DIR")
		insert into C_PalabrasReservadas values ("DIRECTORY")
		insert into C_PalabrasReservadas values ("DISABLED")
		insert into C_PalabrasReservadas values ("DISABLEDBACKCOLOR")
		insert into C_PalabrasReservadas values ("DISABLEDBYEOF")
		insert into C_PalabrasReservadas values ("DISABLEDFORECOLOR")
		insert into C_PalabrasReservadas values ("DISABLEDITEMBACKCOLOR")
		insert into C_PalabrasReservadas values ("DISABLEDITEMFORECOLOR")
		insert into C_PalabrasReservadas values ("DISABLEDPICTURE")
		insert into C_PalabrasReservadas values ("DISABLEENCODE")
		insert into C_PalabrasReservadas values ("DISCONNECTED")
		insert into C_PalabrasReservadas values ("DISKSPACE")
		insert into C_PalabrasReservadas values ("DISPLAY")
		insert into C_PalabrasReservadas values ("DISPLAYCOUNT")
		insert into C_PalabrasReservadas values ("DISPLAYORIENTATION")
		insert into C_PalabrasReservadas values ("DISPLAYPATH")
		insert into C_PalabrasReservadas values ("DISPLAYVALUE")
		insert into C_PalabrasReservadas values ("DISPLAYVALUEDIRTY")
		insert into C_PalabrasReservadas values ("DISPLOGIN")
		insert into C_PalabrasReservadas values ("DISPPAGEHEIGHT")
		insert into C_PalabrasReservadas values ("DISPPAGEWIDTH")
		insert into C_PalabrasReservadas values ("DISPWARNINGS")
		insert into C_PalabrasReservadas values ("DISTINCT")
		insert into C_PalabrasReservadas values ("DLL")
		insert into C_PalabrasReservadas values ("DLLS")
		insert into C_PalabrasReservadas values ("DMY")
		insert into C_PalabrasReservadas values ("DO")
		insert into C_PalabrasReservadas values ("DOC")
		insert into C_PalabrasReservadas values ("DOCK")
		insert into C_PalabrasReservadas values ("DOCKABLE")
		insert into C_PalabrasReservadas values ("DOCKED")
		insert into C_PalabrasReservadas values ("DOCKPOSITION")
		insert into C_PalabrasReservadas values ("DOCMD")
		insert into C_PalabrasReservadas values ("DOCREATE")
		insert into C_PalabrasReservadas values ("DOCUMENTFILE")
		insert into C_PalabrasReservadas values ("DODEFAULT")
		insert into C_PalabrasReservadas values ("DOEVENTS")
		insert into C_PalabrasReservadas values ("DOHISTORY")
		insert into C_PalabrasReservadas values ("DOMESSAGE")
		insert into C_PalabrasReservadas values ("DOS")
		insert into C_PalabrasReservadas values ("DOSCROLL")
		insert into C_PalabrasReservadas values ("DOSMEM")
		insert into C_PalabrasReservadas values ("DOSTATUS")
		insert into C_PalabrasReservadas values ("DOUBLE")
		insert into C_PalabrasReservadas values ("DOVERB")
		insert into C_PalabrasReservadas values ("DOW")
		insert into C_PalabrasReservadas values ("DOWN")
		insert into C_PalabrasReservadas values ("DOWNCLICK")
		insert into C_PalabrasReservadas values ("DOWNPICTURE")
		insert into C_PalabrasReservadas values ("DRAG")
		insert into C_PalabrasReservadas values ("DRAGDROP")
		insert into C_PalabrasReservadas values ("DRAGICON")
		insert into C_PalabrasReservadas values ("DRAGMODE")
		insert into C_PalabrasReservadas values ("DRAGOVER")
		insert into C_PalabrasReservadas values ("DRAGSTATE")
		insert into C_PalabrasReservadas values ("DRAW")
		insert into C_PalabrasReservadas values ("DRAW")
		insert into C_PalabrasReservadas values ("DRAWMODE")
		insert into C_PalabrasReservadas values ("DRAWSTYLE")
		insert into C_PalabrasReservadas values ("DRAWWIDTH")
		insert into C_PalabrasReservadas values ("DRIVER")
		insert into C_PalabrasReservadas values ("DRIVETYPE")
		insert into C_PalabrasReservadas values ("DROP")
		insert into C_PalabrasReservadas values ("DROPDOWN")
		insert into C_PalabrasReservadas values ("DROPOFFLINE")
		insert into C_PalabrasReservadas values ("DTOC")
		insert into C_PalabrasReservadas values ("DTOR")
		insert into C_PalabrasReservadas values ("DTOS")
		insert into C_PalabrasReservadas values ("DTOT")
		insert into C_PalabrasReservadas values ("DUPLEX")
		insert into C_PalabrasReservadas values ("DYNAMICALIGNMENT")
		insert into C_PalabrasReservadas values ("DYNAMICBACKCOLOR")
		insert into C_PalabrasReservadas values ("DYNAMICCURRENTCONTROL")
		insert into C_PalabrasReservadas values ("DYNAMICFONTBOLD")
		insert into C_PalabrasReservadas values ("DYNAMICFONTITALIC")
		insert into C_PalabrasReservadas values ("DYNAMICFONTNAME")
		insert into C_PalabrasReservadas values ("DYNAMICFONTOUTLINE")
		insert into C_PalabrasReservadas values ("DYNAMICFONTSHADOW")
		insert into C_PalabrasReservadas values ("DYNAMICFONTSIZE")
		insert into C_PalabrasReservadas values ("DYNAMICFONTSTRIKETHRU")
		insert into C_PalabrasReservadas values ("DYNAMICFONTUNDERLINE")
		insert into C_PalabrasReservadas values ("DYNAMICFORECOLOR")
		insert into C_PalabrasReservadas values ("DYNAMICINPUTMASK")
		insert into C_PalabrasReservadas values ("DYNAMICLINEHEIGHT")
		insert into C_PalabrasReservadas values ("E")
		insert into C_PalabrasReservadas values ("EACH")
		insert into C_PalabrasReservadas values ("ECHO")
		insert into C_PalabrasReservadas values ("EDIT")
		insert into C_PalabrasReservadas values ("EDITBOX")
		insert into C_PalabrasReservadas values ("EDITFLAGS")
		insert into C_PalabrasReservadas values ("EDITOROPTIONS")
		insert into C_PalabrasReservadas values ("EDITSOURCE")
		insert into C_PalabrasReservadas values ("EDITWORK")
		insert into C_PalabrasReservadas values ("EGA25")
		insert into C_PalabrasReservadas values ("EGA43")
		insert into C_PalabrasReservadas values ("EJECT")
		insert into C_PalabrasReservadas values ("ELIF")
		insert into C_PalabrasReservadas values ("ELSE")
		insert into C_PalabrasReservadas values ("EMPTY")
		insert into C_PalabrasReservadas values ("EMS")
		insert into C_PalabrasReservadas values ("EMS64")
		insert into C_PalabrasReservadas values ("ENABLED")
		insert into C_PalabrasReservadas values ("ENABLEDBYREADLOCK")
		insert into C_PalabrasReservadas values ("ENABLEHYPERLINKS")
		insert into C_PalabrasReservadas values ("ENCRYPT")
		insert into C_PalabrasReservadas values ("ENCRYPTION")
		insert into C_PalabrasReservadas values ("END")
		insert into C_PalabrasReservadas values ("ENDCASE")
		insert into C_PalabrasReservadas values ("ENDDEFINE")
		insert into C_PalabrasReservadas values ("ENDDO")
		insert into C_PalabrasReservadas values ("ENDFOR")
		insert into C_PalabrasReservadas values ("ENDFUNC")
		insert into C_PalabrasReservadas values ("ENDIF")
		insert into C_PalabrasReservadas values ("ENDPRINTJOB")
		insert into C_PalabrasReservadas values ("ENDPROC")
		insert into C_PalabrasReservadas values ("ENDSCAN")
		insert into C_PalabrasReservadas values ("ENDTEXT")
		insert into C_PalabrasReservadas values ("ENDTRY")
		insert into C_PalabrasReservadas values ("ENDWITH")
		insert into C_PalabrasReservadas values ("ENGINEBEHAVIOR")
		insert into C_PalabrasReservadas values ("ENTERFOCUS")
		insert into C_PalabrasReservadas values ("ENVIRONMENT")
		insert into C_PalabrasReservadas values ("ENVLEVEL")
		insert into C_PalabrasReservadas values ("EOF")
		insert into C_PalabrasReservadas values ("ERASE")
		insert into C_PalabrasReservadas values ("ERASEPAGE")
		insert into C_PalabrasReservadas values ("ERROR")
		insert into C_PalabrasReservadas values ("ERRORMESSAGE")
		insert into C_PalabrasReservadas values ("ERRORNO")
		insert into C_PalabrasReservadas values ("ESCAPE")
		insert into C_PalabrasReservadas values ("EVALUATE")
		insert into C_PalabrasReservadas values ("EVALUATECONTENTS")
		insert into C_PalabrasReservadas values ("EVENTHANDLER")
		insert into C_PalabrasReservadas values ("EVENTLIST")
		insert into C_PalabrasReservadas values ("EVENTS")
		insert into C_PalabrasReservadas values ("EVENTTRACKING")
		insert into C_PalabrasReservadas values ("EVL")
		insert into C_PalabrasReservadas values ("EXACT")
		insert into C_PalabrasReservadas values ("EXCEPT")
		insert into C_PalabrasReservadas values ("EXCEPTION")
		insert into C_PalabrasReservadas values ("EXCLUSIVE")
		insert into C_PalabrasReservadas values ("EXE")
		insert into C_PalabrasReservadas values ("EXECSCRIPT")
		insert into C_PalabrasReservadas values ("EXISTS")
		insert into C_PalabrasReservadas values ("EXIT")
		insert into C_PalabrasReservadas values ("EXITFOCUS")
		insert into C_PalabrasReservadas values ("EXP")
		insert into C_PalabrasReservadas values ("EXPORT")
		insert into C_PalabrasReservadas values ("EXPRESSION")
		insert into C_PalabrasReservadas values ("EXTENDED")
		insert into C_PalabrasReservadas values ("EXTERNAL")
		insert into C_PalabrasReservadas values ("F")
		insert into C_PalabrasReservadas values ("F11F12")
		insert into C_PalabrasReservadas values ("FCHSIZE")
		insert into C_PalabrasReservadas values ("FCLOSE")
		insert into C_PalabrasReservadas values ("FCOUNT")
		insert into C_PalabrasReservadas values ("FCREATE")
		insert into C_PalabrasReservadas values ("FDATE")
		insert into C_PalabrasReservadas values ("FDOW")
		insert into C_PalabrasReservadas values ("FEOF")
		insert into C_PalabrasReservadas values ("FERROR")
		insert into C_PalabrasReservadas values ("FETCH")
		insert into C_PalabrasReservadas values ("FETCHMEMO")
		insert into C_PalabrasReservadas values ("FETCHMEMOCMDLIST")
		insert into C_PalabrasReservadas values ("FETCHMEMODATASOURCE")
		insert into C_PalabrasReservadas values ("FETCHMEMODATASOURCETYPE")
		insert into C_PalabrasReservadas values ("FETCHSIZE")
		insert into C_PalabrasReservadas values ("FFLUSH")
		insert into C_PalabrasReservadas values ("FGETS")
		insert into C_PalabrasReservadas values ("FIELD")
		insert into C_PalabrasReservadas values ("FIELDS")
		insert into C_PalabrasReservadas values ("FIELDSF")
		insert into C_PalabrasReservadas values ("FILE")
		insert into C_PalabrasReservadas values ("FILER")
		insert into C_PalabrasReservadas values ("FILES")
		insert into C_PalabrasReservadas values ("FILETOSTR")
		insert into C_PalabrasReservadas values ("FILL")
		insert into C_PalabrasReservadas values ("FILLCOLOR")
		insert into C_PalabrasReservadas values ("FILLSTYLE")
		insert into C_PalabrasReservadas values ("FILTER")
		insert into C_PalabrasReservadas values ("FINALLY")
		insert into C_PalabrasReservadas values ("FIND")
		insert into C_PalabrasReservadas values ("FIRSTELEMENT")
		insert into C_PalabrasReservadas values ("FIRSTNESTEDTABLE")
		insert into C_PalabrasReservadas values ("FIXED")
		insert into C_PalabrasReservadas values ("FKLABEL")
		insert into C_PalabrasReservadas values ("FKMAX")
		insert into C_PalabrasReservadas values ("FLAGS")
		insert into C_PalabrasReservadas values ("FLDCOUNT")
		insert into C_PalabrasReservadas values ("FLDLIST")
		insert into C_PalabrasReservadas values ("FLOAT")
		insert into C_PalabrasReservadas values ("FLOCK")
		insert into C_PalabrasReservadas values ("FLOOR")
		insert into C_PalabrasReservadas values ("FLUSH")
		insert into C_PalabrasReservadas values ("FOLDCONST")
		insert into C_PalabrasReservadas values ("FONT")
		insert into C_PalabrasReservadas values ("FONTBOLD")
		insert into C_PalabrasReservadas values ("FONTCHARSET")
		insert into C_PalabrasReservadas values ("FONTCLASS")
		insert into C_PalabrasReservadas values ("FONTCONDENSE")
		insert into C_PalabrasReservadas values ("FONTEXTEND")
		insert into C_PalabrasReservadas values ("FONTITALIC")
		insert into C_PalabrasReservadas values ("FONTMETRIC")
		insert into C_PalabrasReservadas values ("FONTMETRIC")
		insert into C_PalabrasReservadas values ("FONTNAME")
		insert into C_PalabrasReservadas values ("FONTOUTLINE")
		insert into C_PalabrasReservadas values ("FONTSHADOW")
		insert into C_PalabrasReservadas values ("FONTSIZE")
		insert into C_PalabrasReservadas values ("FONTSTRIKETHRU")
		insert into C_PalabrasReservadas values ("FONTUNDERLINE")
		insert into C_PalabrasReservadas values ("FOOTER")
		insert into C_PalabrasReservadas values ("FOPEN")
		insert into C_PalabrasReservadas values ("FOR")
		insert into C_PalabrasReservadas values ("FORCE")
		insert into C_PalabrasReservadas values ("FORCECLOSETAG")
		insert into C_PalabrasReservadas values ("FORCEEXT")
		insert into C_PalabrasReservadas values ("FORCEFOCUS")
		insert into C_PalabrasReservadas values ("FORCEPATH")
		insert into C_PalabrasReservadas values ("FORECOLOR")
		insert into C_PalabrasReservadas values ("FOREIGN")
		insert into C_PalabrasReservadas values ("FORM")
		insert into C_PalabrasReservadas values ("FORMAT")
		insert into C_PalabrasReservadas values ("FORMATCHANGE")
		insert into C_PalabrasReservadas values ("FORMATTEDOUTPUT")
		insert into C_PalabrasReservadas values ("FORMCOUNT")
		insert into C_PalabrasReservadas values ("FORMINDEX")
		insert into C_PalabrasReservadas values ("FORMPAGECOUNT")
		insert into C_PalabrasReservadas values ("FORMPAGEINDEX")
		insert into C_PalabrasReservadas values ("FORMS")
		insert into C_PalabrasReservadas values ("FORMSCLASS")
		insert into C_PalabrasReservadas values ("FORMSET")
		insert into C_PalabrasReservadas values ("FORMSETCLASS")
		insert into C_PalabrasReservadas values ("FORMSETLIB")
		insert into C_PalabrasReservadas values ("FORMSLIB")
		insert into C_PalabrasReservadas values ("FOUND")
		insert into C_PalabrasReservadas values ("FOX2X")
		insert into C_PalabrasReservadas values ("FOXCODE")
		insert into C_PalabrasReservadas values ("FOXDOC")
		insert into C_PalabrasReservadas values ("FOXFONT")
		insert into C_PalabrasReservadas values ("FOXGEN")
		insert into C_PalabrasReservadas values ("FOXGRAPH")
		insert into C_PalabrasReservadas values ("FOXOBJECT")
		insert into C_PalabrasReservadas values ("FOXPLUS")
		insert into C_PalabrasReservadas values ("FOXPRO")
		insert into C_PalabrasReservadas values ("FOXTASK")
		insert into C_PalabrasReservadas values ("FOXVIEW")
		insert into C_PalabrasReservadas values ("FPUTS")
		insert into C_PalabrasReservadas values ("FRACTIONDIGITS")
		insert into C_PalabrasReservadas values ("FREAD")
		insert into C_PalabrasReservadas values ("FREE")
		insert into C_PalabrasReservadas values ("FREEZE")
		insert into C_PalabrasReservadas values ("FRENCH")
		insert into C_PalabrasReservadas values ("FROM")
		insert into C_PalabrasReservadas values ("FRXDATASESSION")
		insert into C_PalabrasReservadas values ("FSEEK")
		insert into C_PalabrasReservadas values ("FSIZE")
		insert into C_PalabrasReservadas values ("FTIME")
		insert into C_PalabrasReservadas values ("FULL")
		insert into C_PalabrasReservadas values ("FULLNAME")
		insert into C_PalabrasReservadas values ("FULLPATH")
		insert into C_PalabrasReservadas values ("FUNCTION")
		insert into C_PalabrasReservadas values ("FV")
		insert into C_PalabrasReservadas values ("FW2")
		insert into C_PalabrasReservadas values ("FWEEK")
		insert into C_PalabrasReservadas values ("FWRITE")
		insert into C_PalabrasReservadas values ("G")
		insert into C_PalabrasReservadas values ("GATHER")
		insert into C_PalabrasReservadas values ("GDIPLUSGRAPHICS")
		insert into C_PalabrasReservadas values ("GENERAL")
		insert into C_PalabrasReservadas values ("GERMAN")
		insert into C_PalabrasReservadas values ("GET")
		insert into C_PalabrasReservadas values ("GETAUTOINCVALUE")
		insert into C_PalabrasReservadas values ("GETBAR")
		insert into C_PalabrasReservadas values ("GETCOLOR")
		insert into C_PalabrasReservadas values ("GETCP")
		insert into C_PalabrasReservadas values ("GETCURSORADAPTER")
		insert into C_PalabrasReservadas values ("GETDATA")
		insert into C_PalabrasReservadas values ("GETDIR")
		insert into C_PalabrasReservadas values ("GETDOCKSTATE")
		insert into C_PalabrasReservadas values ("GETENV")
		insert into C_PalabrasReservadas values ("GETEXPR")
		insert into C_PalabrasReservadas values ("GETFILE")
		insert into C_PalabrasReservadas values ("GETFLDSTATE")
		insert into C_PalabrasReservadas values ("GETFONT")
		insert into C_PalabrasReservadas values ("GETFORMAT")
		insert into C_PalabrasReservadas values ("GETHOST")
		insert into C_PalabrasReservadas values ("GETINTERFACE")
		insert into C_PalabrasReservadas values ("GETKEY")
		insert into C_PalabrasReservadas values ("GETNEXTMODIFIED")
		insert into C_PalabrasReservadas values ("GETOBJECT")
		insert into C_PalabrasReservadas values ("GETPAD")
		insert into C_PalabrasReservadas values ("GETPAGEHEIGHT")
		insert into C_PalabrasReservadas values ("GETPAGEWIDTH")
		insert into C_PalabrasReservadas values ("GETPEM")
		insert into C_PalabrasReservadas values ("GETPICT")
		insert into C_PalabrasReservadas values ("GETPRINTER")
		insert into C_PalabrasReservadas values ("GETRESULTSET")
		insert into C_PalabrasReservadas values ("GETS")
		insert into C_PalabrasReservadas values ("GETWORDCOUNT")
		insert into C_PalabrasReservadas values ("GETWORDNUM")
		insert into C_PalabrasReservadas values ("GLOBAL")
		insert into C_PalabrasReservadas values ("GO")
		insert into C_PalabrasReservadas values ("GOBACK")
		insert into C_PalabrasReservadas values ("GOFIRST")
		insert into C_PalabrasReservadas values ("GOFORWARD")
		insert into C_PalabrasReservadas values ("GOLAST")
		insert into C_PalabrasReservadas values ("GOMONTH")
		insert into C_PalabrasReservadas values ("GOTFOCUS")
		insert into C_PalabrasReservadas values ("GOTO")
		insert into C_PalabrasReservadas values ("GRAPH")
		insert into C_PalabrasReservadas values ("GRID")
		insert into C_PalabrasReservadas values ("GRIDHITTEST")
		insert into C_PalabrasReservadas values ("GRIDHORZ")
		insert into C_PalabrasReservadas values ("GRIDLINECOLOR")
		insert into C_PalabrasReservadas values ("GRIDLINES")
		insert into C_PalabrasReservadas values ("GRIDLINEWIDTH")
		insert into C_PalabrasReservadas values ("GRIDSHOW")
		insert into C_PalabrasReservadas values ("GRIDSHOWPOS")
		insert into C_PalabrasReservadas values ("GRIDSNAP")
		insert into C_PalabrasReservadas values ("GRIDVERT")
		insert into C_PalabrasReservadas values ("GROUP")
		insert into C_PalabrasReservadas values ("GROW")
		insert into C_PalabrasReservadas values ("H")
		insert into C_PalabrasReservadas values ("HALFHEIGHT")
		insert into C_PalabrasReservadas values ("HALFHEIGHTCAPTION")
		insert into C_PalabrasReservadas values ("HASCLIP")
		insert into C_PalabrasReservadas values ("HAVING")
		insert into C_PalabrasReservadas values ("HEADER")
		insert into C_PalabrasReservadas values ("HEADERCLASS")
		insert into C_PalabrasReservadas values ("HEADERCLASSLIBRARY")
		insert into C_PalabrasReservadas values ("HEADERGAP")
		insert into C_PalabrasReservadas values ("HEADERHEIGHT")
		insert into C_PalabrasReservadas values ("HEADING")
		insert into C_PalabrasReservadas values ("HEADINGS")
		insert into C_PalabrasReservadas values ("HEIGHT")
		insert into C_PalabrasReservadas values ("HELP")
		insert into C_PalabrasReservadas values ("HELPCONTEXTID")
		insert into C_PalabrasReservadas values ("HELPFILTER")
		insert into C_PalabrasReservadas values ("HELPON")
		insert into C_PalabrasReservadas values ("HELPTO")
		insert into C_PalabrasReservadas values ("HIDDEN")
		insert into C_PalabrasReservadas values ("HIDE")
		insert into C_PalabrasReservadas values ("HIDEAPPOBJ")
		insert into C_PalabrasReservadas values ("HIDEDOC")
		insert into C_PalabrasReservadas values ("HIDESELECTION")
		insert into C_PalabrasReservadas values ("HIGHLIGHT")
		insert into C_PalabrasReservadas values ("HIGHLIGHTBACKCOLOR")
		insert into C_PalabrasReservadas values ("HIGHLIGHTFORECOLOR")
		insert into C_PalabrasReservadas values ("HIGHLIGHTSTYLE")
		insert into C_PalabrasReservadas values ("HIGHLIGHTROW")
		insert into C_PalabrasReservadas values ("HISTORY")
		insert into C_PalabrasReservadas values ("HMEMORY")
		insert into C_PalabrasReservadas values ("HOME")
		insert into C_PalabrasReservadas values ("HOSTNAME")
		insert into C_PalabrasReservadas values ("HOTKEY")
		insert into C_PalabrasReservadas values ("HOUR")
		insert into C_PalabrasReservadas values ("HOURS")
		insert into C_PalabrasReservadas values ("HPROJ")
		insert into C_PalabrasReservadas values ("HSCROLLSMALLCHANGE")
		insert into C_PalabrasReservadas values ("HWND")
		insert into C_PalabrasReservadas values ("HYPERLINK")
		insert into C_PalabrasReservadas values ("I")
		insert into C_PalabrasReservadas values ("IBLOCK")
		insert into C_PalabrasReservadas values ("ICASE")
		insert into C_PalabrasReservadas values ("ICON")
		insert into C_PalabrasReservadas values ("ID")
		insert into C_PalabrasReservadas values ("IDHISTORY")
		insert into C_PalabrasReservadas values ("IDLETIMEOUT")
		insert into C_PalabrasReservadas values ("IDXCOLLATE")
		insert into C_PalabrasReservadas values ("IF")
		insert into C_PalabrasReservadas values ("IFDEF")
		insert into C_PalabrasReservadas values ("IFNDEF")
		insert into C_PalabrasReservadas values ("IGNOREINSERT")
		insert into C_PalabrasReservadas values ("IIF")
		insert into C_PalabrasReservadas values ("IMAGE")
		insert into C_PalabrasReservadas values ("IMEMODE")
		insert into C_PalabrasReservadas values ("IMESTATUS")
		insert into C_PalabrasReservadas values ("IMPORT")
		insert into C_PalabrasReservadas values ("IN")
		insert into C_PalabrasReservadas values ("INCLUDE")
		insert into C_PalabrasReservadas values ("INCLUDEPAGEINOUTPUT")
		insert into C_PalabrasReservadas values ("INCREMENT")
		insert into C_PalabrasReservadas values ("INCREMENTALSEARCH")
		insert into C_PalabrasReservadas values ("INDBC")
		insert into C_PalabrasReservadas values ("INDEX")
		insert into C_PalabrasReservadas values ("INDEXES")
		insert into C_PalabrasReservadas values ("INDEXSEEK")
		insert into C_PalabrasReservadas values ("INDEXTOITEMID")
		insert into C_PalabrasReservadas values ("INFORMATION")
		insert into C_PalabrasReservadas values ("INIT")
		insert into C_PalabrasReservadas values ("INITIALSELECTEDALIAS")
		insert into C_PalabrasReservadas values ("INKEY")
		insert into C_PalabrasReservadas values ("INLIST")
		insert into C_PalabrasReservadas values ("INNER")
		insert into C_PalabrasReservadas values ("INPUT")
		insert into C_PalabrasReservadas values ("INPUTMASK")
		insert into C_PalabrasReservadas values ("INRESIZE")
		insert into C_PalabrasReservadas values ("INSERT")
		insert into C_PalabrasReservadas values ("INSERTCMD")
		insert into C_PalabrasReservadas values ("INSERTCMDDATASOURCE")
		insert into C_PalabrasReservadas values ("INSERTCMDDATASOURCETYPE")
		insert into C_PalabrasReservadas values ("INSERTCMDREFRESHCMD")
		insert into C_PalabrasReservadas values ("INSERTCMDREFRESHFIELDLIST")
		insert into C_PalabrasReservadas values ("INSERTCMDREFRESHKEYFIELDLIST")
		insert into C_PalabrasReservadas values ("INSERTTRIGGER")
		insert into C_PalabrasReservadas values ("INSMODE")
		insert into C_PalabrasReservadas values ("INSTRUCT")
		insert into C_PalabrasReservadas values ("INT")
		insert into C_PalabrasReservadas values ("INTEGER")
		insert into C_PalabrasReservadas values ("INTEGRALHEIGHT")
		insert into C_PalabrasReservadas values ("INTENSITY")
		insert into C_PalabrasReservadas values ("INTERACTIVECHANGE")
		insert into C_PalabrasReservadas values ("INTERSECT")
		insert into C_PalabrasReservadas values ("INTERVAL")
		insert into C_PalabrasReservadas values ("INTO")
		insert into C_PalabrasReservadas values ("IS")
		insert into C_PalabrasReservadas values ("ISALPHA")
		insert into C_PalabrasReservadas values ("ISATTRIBUTE")
		insert into C_PalabrasReservadas values ("ISBASE64")
		insert into C_PalabrasReservadas values ("ISBINARY")
		insert into C_PalabrasReservadas values ("ISBLANK")
		insert into C_PalabrasReservadas values ("ISCOLOR")
		insert into C_PalabrasReservadas values ("ISDIFFGRAM")
		insert into C_PalabrasReservadas values ("ISDIGIT")
		insert into C_PalabrasReservadas values ("ISEXCLUSIVE")
		insert into C_PalabrasReservadas values ("ISFLOCKED")
		insert into C_PalabrasReservadas values ("ISHOSTED")
		insert into C_PalabrasReservadas values ("ISLEADBYTE")
		insert into C_PalabrasReservadas values ("ISLOADED")
		insert into C_PalabrasReservadas values ("ISLOWER")
		insert into C_PalabrasReservadas values ("ISMEMOFETCHED")
		insert into C_PalabrasReservadas values ("ISMOUSE")
		insert into C_PalabrasReservadas values ("ISNULL")
		insert into C_PalabrasReservadas values ("ISOMETRIC")
		insert into C_PalabrasReservadas values ("ISPEN")
		insert into C_PalabrasReservadas values ("ISREADONLY")
		insert into C_PalabrasReservadas values ("ISRLOCKED")
		insert into C_PalabrasReservadas values ("ISTRANSACTABLE")
		insert into C_PalabrasReservadas values ("ISUPPER")
		insert into C_PalabrasReservadas values ("ITALIAN")
		insert into C_PalabrasReservadas values ("ITEM")
		insert into C_PalabrasReservadas values ("ITEMBACKCOLOR")
		insert into C_PalabrasReservadas values ("ITEMDATA")
		insert into C_PalabrasReservadas values ("ITEMFORECOLOR")
		insert into C_PalabrasReservadas values ("ITEMIDDATA")
		insert into C_PalabrasReservadas values ("ITEMIDTOINDEX")
		insert into C_PalabrasReservadas values ("ITEMTIPS")
		insert into C_PalabrasReservadas values ("IXMLDOMELEMENT")
		insert into C_PalabrasReservadas values ("J")
		insert into C_PalabrasReservadas values ("JAPAN")
		insert into C_PalabrasReservadas values ("JOIN")
		insert into C_PalabrasReservadas values ("JUSTDRIVE")
		insert into C_PalabrasReservadas values ("JUSTEXT")
		insert into C_PalabrasReservadas values ("JUSTFNAME")
		insert into C_PalabrasReservadas values ("JUSTPATH")
		insert into C_PalabrasReservadas values ("JUSTREADLOCKED")
		insert into C_PalabrasReservadas values ("JUSTSTEM")
		insert into C_PalabrasReservadas values ("KEY")
		insert into C_PalabrasReservadas values ("KEYBOARD")
		insert into C_PalabrasReservadas values ("KEYBOARDHIGHVALUE")
		insert into C_PalabrasReservadas values ("KEYBOARDLOWVALUE")
		insert into C_PalabrasReservadas values ("KEYCOLUMNS")
		insert into C_PalabrasReservadas values ("KEYCOMP")
		insert into C_PalabrasReservadas values ("KEYFIELD")
		insert into C_PalabrasReservadas values ("KEYFIELDLIST")
		insert into C_PalabrasReservadas values ("KEYMATCH")
		insert into C_PalabrasReservadas values ("KEYPRESS")
		insert into C_PalabrasReservadas values ("KEYPREVIEW")
		insert into C_PalabrasReservadas values ("KEYSET")
		insert into C_PalabrasReservadas values ("KEYSORT")
		insert into C_PalabrasReservadas values ("LABEL")
		insert into C_PalabrasReservadas values ("LANGUAGEOPTIONS")
		insert into C_PalabrasReservadas values ("LAST")
		insert into C_PalabrasReservadas values ("LASTKEY")
		insert into C_PalabrasReservadas values ("LASTPROJECT")
		insert into C_PalabrasReservadas values ("LCASE")
		insert into C_PalabrasReservadas values ("LDCHECK")
		insert into C_PalabrasReservadas values ("LEDIT")
		insert into C_PalabrasReservadas values ("LEFT")
		insert into C_PalabrasReservadas values ("LEFTC")
		insert into C_PalabrasReservadas values ("LEFTCOLUMN")
		insert into C_PalabrasReservadas values ("LEN")
		insert into C_PalabrasReservadas values ("LENC")
		insert into C_PalabrasReservadas values ("LENGTH")
		insert into C_PalabrasReservadas values ("LEVEL")
		insert into C_PalabrasReservadas values ("LIBRARY")
		insert into C_PalabrasReservadas values ("LIKE")
		insert into C_PalabrasReservadas values ("LIKEC")
		insert into C_PalabrasReservadas values ("LINE")
		insert into C_PalabrasReservadas values ("LINECONTENTS")
		insert into C_PalabrasReservadas values ("LINENO")
		insert into C_PalabrasReservadas values ("LINESLANT")
		insert into C_PalabrasReservadas values ("LINKED")
		insert into C_PalabrasReservadas values ("LINKMASTER")
		insert into C_PalabrasReservadas values ("LIST")
		insert into C_PalabrasReservadas values ("LISTBOX")
		insert into C_PalabrasReservadas values ("LISTCOUNT")
		insert into C_PalabrasReservadas values ("LISTENERTYPE")
		insert into C_PalabrasReservadas values ("LISTINDEX")
		insert into C_PalabrasReservadas values ("LISTITEM")
		insert into C_PalabrasReservadas values ("LISTITEMID")
		insert into C_PalabrasReservadas values ("LOAD")
		insert into C_PalabrasReservadas values ("LOADPICTURE")
		insert into C_PalabrasReservadas values ("LOADREPORT")
		insert into C_PalabrasReservadas values ("LOADXML")
		insert into C_PalabrasReservadas values ("LOCAL")
		insert into C_PalabrasReservadas values ("LOCFILE")
		insert into C_PalabrasReservadas values ("LOCK")
		insert into C_PalabrasReservadas values ("LOCKCOLUMNS")
		insert into C_PalabrasReservadas values ("LOCKCOLUMNSLEFT")
		insert into C_PalabrasReservadas values ("LOCKDATASOURCE")
		insert into C_PalabrasReservadas values ("LOCKSCREEN")
		insert into C_PalabrasReservadas values ("LOG")
		insert into C_PalabrasReservadas values ("LOG10")
		insert into C_PalabrasReservadas values ("LOGERRORS")
		insert into C_PalabrasReservadas values ("LOGOUT")
		insert into C_PalabrasReservadas values ("LONG")
		insert into C_PalabrasReservadas values ("LOOKUP")
		insert into C_PalabrasReservadas values ("LOOP")
		insert into C_PalabrasReservadas values ("LOSTFOCUS")
		insert into C_PalabrasReservadas values ("LOWER")
		insert into C_PalabrasReservadas values ("LPARAMETER")
		insert into C_PalabrasReservadas values ("LPARAMETERS")
		insert into C_PalabrasReservadas values ("LPARTITION")
		insert into C_PalabrasReservadas values ("LTRIM")
		insert into C_PalabrasReservadas values ("LTRJUSTIFY")
		insert into C_PalabrasReservadas values ("LUPDATE")
		insert into C_PalabrasReservadas values ("M")
		insert into C_PalabrasReservadas values ("MAC")
		insert into C_PalabrasReservadas values ("MACDESKTOP")
		insert into C_PalabrasReservadas values ("MACHELP")
		insert into C_PalabrasReservadas values ("MACKEY")
		insert into C_PalabrasReservadas values ("MACROS")
		insert into C_PalabrasReservadas values ("MACSCREEN")
		insert into C_PalabrasReservadas values ("MAIL")
		insert into C_PalabrasReservadas values ("MAKETRANSACTABLE")
		insert into C_PalabrasReservadas values ("MAP19_4TOCURRENCY")
		insert into C_PalabrasReservadas values ("MAPBINARY")
		insert into C_PalabrasReservadas values ("MAPVARCHAR")
		insert into C_PalabrasReservadas values ("MARGIN")
		insert into C_PalabrasReservadas values ("MARK")
		insert into C_PalabrasReservadas values ("MASTER")
		insert into C_PalabrasReservadas values ("MAX")
		insert into C_PalabrasReservadas values ("MAXBUTTON")
		insert into C_PalabrasReservadas values ("MAXHEIGHT")
		insert into C_PalabrasReservadas values ("MAXLEFT")
		insert into C_PalabrasReservadas values ("MAXLENGTH")
		insert into C_PalabrasReservadas values ("MAXMEM")
		insert into C_PalabrasReservadas values ("MAXRECORDS")
		insert into C_PalabrasReservadas values ("MAXTOP")
		insert into C_PalabrasReservadas values ("MAXWIDTH")
		insert into C_PalabrasReservadas values ("MBLOCK")
		insert into C_PalabrasReservadas values ("MCOL")
		insert into C_PalabrasReservadas values ("MD")
		insert into C_PalabrasReservadas values ("MDI")
		insert into C_PalabrasReservadas values ("MDIFORM")
		insert into C_PalabrasReservadas values ("MDOWN")
		insert into C_PalabrasReservadas values ("MDX")
		insert into C_PalabrasReservadas values ("MDY")
		insert into C_PalabrasReservadas values ("MEMBERCLASS")
		insert into C_PalabrasReservadas values ("MEMBERCLASSLIBRARY")
		insert into C_PalabrasReservadas values ("MEMLIMIT")
		insert into C_PalabrasReservadas values ("MEMLINES")
		insert into C_PalabrasReservadas values ("MEMO")
		insert into C_PalabrasReservadas values ("MEMORY")
		insert into C_PalabrasReservadas values ("MEMOS")
		insert into C_PalabrasReservadas values ("MEMOWIDTH")
		insert into C_PalabrasReservadas values ("MEMOWINDOW")
		insert into C_PalabrasReservadas values ("MEMVAR")
		insert into C_PalabrasReservadas values ("MENU")
		insert into C_PalabrasReservadas values ("MENUS")
		insert into C_PalabrasReservadas values ("MESSAGE")
		insert into C_PalabrasReservadas values ("MESSAGEBOX")
		insert into C_PalabrasReservadas values ("MESSAGES")
		insert into C_PalabrasReservadas values ("METHOD")
		insert into C_PalabrasReservadas values ("MIDDLE")
		insert into C_PalabrasReservadas values ("MIDDLECLICK")
		insert into C_PalabrasReservadas values ("MIN")
		insert into C_PalabrasReservadas values ("MINBUTTON")
		insert into C_PalabrasReservadas values ("MINHEIGHT")
		insert into C_PalabrasReservadas values ("MINIMIZE")
		insert into C_PalabrasReservadas values ("MINUS")
		insert into C_PalabrasReservadas values ("MINUTE")
		insert into C_PalabrasReservadas values ("MINWIDTH")
		insert into C_PalabrasReservadas values ("MKDIR")
		insert into C_PalabrasReservadas values ("MLINE")
		insert into C_PalabrasReservadas values ("MOD")
		insert into C_PalabrasReservadas values ("MODAL")
		insert into C_PalabrasReservadas values ("MODIFY")
		insert into C_PalabrasReservadas values ("MODULE")
		insert into C_PalabrasReservadas values ("MONO")
		insert into C_PalabrasReservadas values ("MONO43")
		insert into C_PalabrasReservadas values ("MONO43")
		insert into C_PalabrasReservadas values ("MONTH")
		insert into C_PalabrasReservadas values ("MONTHNAME")
		insert into C_PalabrasReservadas values ("MOUSE")
		insert into C_PalabrasReservadas values ("MOUSEDOWN")
		insert into C_PalabrasReservadas values ("MOUSEICON")
		insert into C_PalabrasReservadas values ("MOUSEMOVE")
		insert into C_PalabrasReservadas values ("MOUSEPOINTER")
		insert into C_PalabrasReservadas values ("MOUSEUP")
		insert into C_PalabrasReservadas values ("MOUSEWHEEL")
		insert into C_PalabrasReservadas values ("MOVABLE")
		insert into C_PalabrasReservadas values ("MOVE")
		insert into C_PalabrasReservadas values ("MOVED")
		insert into C_PalabrasReservadas values ("MOVEITEM")
		insert into C_PalabrasReservadas values ("MOVERBARS")
		insert into C_PalabrasReservadas values ("MOVERS")
		insert into C_PalabrasReservadas values ("MRKBAR")
		insert into C_PalabrasReservadas values ("MRKPAD")
		insert into C_PalabrasReservadas values ("MROW")
		insert into C_PalabrasReservadas values ("MTB_SP100")
		insert into C_PalabrasReservadas values ("MTON")
		insert into C_PalabrasReservadas values ("MULTILOCKS")
		insert into C_PalabrasReservadas values ("MULTISELECT")
		insert into C_PalabrasReservadas values ("MVARSIZ")
		insert into C_PalabrasReservadas values ("MVCOUNT")
		insert into C_PalabrasReservadas values ("MWINDOW")
		insert into C_PalabrasReservadas values ("NAME")
		insert into C_PalabrasReservadas values ("NAPTIME")
		insert into C_PalabrasReservadas values ("NATIVE")
		insert into C_PalabrasReservadas values ("NAVIGATETO")
		insert into C_PalabrasReservadas values ("NDX")
		insert into C_PalabrasReservadas values ("NEAR")
		insert into C_PalabrasReservadas values ("NEGOTIATE")
		insert into C_PalabrasReservadas values ("NEST")
		insert into C_PalabrasReservadas values ("NESTEDINTO")
		insert into C_PalabrasReservadas values ("NETWORK")
		insert into C_PalabrasReservadas values ("NEWINDEX")
		insert into C_PalabrasReservadas values ("NEWITEMID")
		insert into C_PalabrasReservadas values ("NEWOBJECT")
		insert into C_PalabrasReservadas values ("NEXT")
		insert into C_PalabrasReservadas values ("NEXTSIBLINGTABLE")
		insert into C_PalabrasReservadas values ("NEXTVALUE")
		insert into C_PalabrasReservadas values ("NOALIAS")
		insert into C_PalabrasReservadas values ("NOAPPEND")
		insert into C_PalabrasReservadas values ("NOCLEAR")
		insert into C_PalabrasReservadas values ("NOCLOSE")
		insert into C_PalabrasReservadas values ("NOCONSOLE")
		insert into C_PalabrasReservadas values ("NOCPTRANS")
		insert into C_PalabrasReservadas values ("NODATA")
		insert into C_PalabrasReservadas values ("NODATAONLOAD")
		insert into C_PalabrasReservadas values ("NODEBUG")
		insert into C_PalabrasReservadas values ("NODEFAULT")
		insert into C_PalabrasReservadas values ("NODEFINE")
		insert into C_PalabrasReservadas values ("NODELETE")
		insert into C_PalabrasReservadas values ("NODIALOG")
		insert into C_PalabrasReservadas values ("NODUP")
		insert into C_PalabrasReservadas values ("NOEDIT")
		insert into C_PalabrasReservadas values ("NOEJECT")
		insert into C_PalabrasReservadas values ("NOENVIRONMENT")
		insert into C_PalabrasReservadas values ("NOFILTER")
		insert into C_PalabrasReservadas values ("NOFLOAT")
		insert into C_PalabrasReservadas values ("NOFOLLOW")
		insert into C_PalabrasReservadas values ("NOGROW")
		insert into C_PalabrasReservadas values ("NOINIT")
		insert into C_PalabrasReservadas values ("NOLGRID")
		insert into C_PalabrasReservadas values ("NOLINK")
		insert into C_PalabrasReservadas values ("NOLOCK")
		insert into C_PalabrasReservadas values ("NOLOG")
		insert into C_PalabrasReservadas values ("NOMARGIN")
		insert into C_PalabrasReservadas values ("NOMDI")
		insert into C_PalabrasReservadas values ("NOMENU")
		insert into C_PalabrasReservadas values ("NOMINIMIZE")
		insert into C_PalabrasReservadas values ("NOMODIFY")
		insert into C_PalabrasReservadas values ("NOMOUSE")
		insert into C_PalabrasReservadas values ("NONE")
		insert into C_PalabrasReservadas values ("NOOPTIMIZE")
		insert into C_PalabrasReservadas values ("NOORGANIZE")
		insert into C_PalabrasReservadas values ("NOOVERWRITE")
		insert into C_PalabrasReservadas values ("NOPROJECTHOOK")
		insert into C_PalabrasReservadas values ("NOPROMPT")
		insert into C_PalabrasReservadas values ("NOREAD")
		insert into C_PalabrasReservadas values ("NOREFRESH")
		insert into C_PalabrasReservadas values ("NOREQUERY")
		insert into C_PalabrasReservadas values ("NORGRID")
		insert into C_PalabrasReservadas values ("NORM")
		insert into C_PalabrasReservadas values ("NORMAL")
		insert into C_PalabrasReservadas values ("NORMALIZE")
		insert into C_PalabrasReservadas values ("NOSAVE")
		insert into C_PalabrasReservadas values ("NOSHADOW")
		insert into C_PalabrasReservadas values ("NOSHOW")
		insert into C_PalabrasReservadas values ("NOSPACE")
		insert into C_PalabrasReservadas values ("NOT")
		insert into C_PalabrasReservadas values ("NOTAB")
		insert into C_PalabrasReservadas values ("NOTE")
		insert into C_PalabrasReservadas values ("NOTIFY")
		insert into C_PalabrasReservadas values ("NOTIFYCONTAINER")
		insert into C_PalabrasReservadas values ("NOUPDATE")
		insert into C_PalabrasReservadas values ("NOVALIDATE")
		insert into C_PalabrasReservadas values ("NOVERIFY")
		insert into C_PalabrasReservadas values ("NOW")
		insert into C_PalabrasReservadas values ("NOWAIT")
		insert into C_PalabrasReservadas values ("NOWINDOW")
		insert into C_PalabrasReservadas values ("NOWRAP")
		insert into C_PalabrasReservadas values ("NOZOOM")
		insert into C_PalabrasReservadas values ("NPV")
		insert into C_PalabrasReservadas values ("NTOM")
		insert into C_PalabrasReservadas values ("NULL")
		insert into C_PalabrasReservadas values ("NULLDISPLAY")
		insert into C_PalabrasReservadas values ("NULLSTRING")
		insert into C_PalabrasReservadas values ("NUMBER")
		insert into C_PalabrasReservadas values ("NUMBEROFELEMENTS")
		insert into C_PalabrasReservadas values ("NUMLOCK")
		insert into C_PalabrasReservadas values ("NVL")
		insert into C_PalabrasReservadas values ("OBJECTS")
		insert into C_PalabrasReservadas values ("OBJNUM")
		insert into C_PalabrasReservadas values ("OBJREF")
		insert into C_PalabrasReservadas values ("OBJTOCLIENT")
		insert into C_PalabrasReservadas values ("OBJVAR")
		insert into C_PalabrasReservadas values ("OCCURS")
		insert into C_PalabrasReservadas values ("ODBCHDBC")
		insert into C_PalabrasReservadas values ("ODBCHSTMT")
		insert into C_PalabrasReservadas values ("ODOMETER")
		insert into C_PalabrasReservadas values ("OEMTOANSI")
		insert into C_PalabrasReservadas values ("OF")
		insert into C_PalabrasReservadas values ("OFF")
		insert into C_PalabrasReservadas values ("OLDVAL")
		insert into C_PalabrasReservadas values ("OLEBASECONTROL")
		insert into C_PalabrasReservadas values ("OLEBOUNDCONTROL")
		insert into C_PalabrasReservadas values ("OLECLASS")
		insert into C_PalabrasReservadas values ("OLECLASSID")
		insert into C_PalabrasReservadas values ("OLECLASSIDISPOUT")
		insert into C_PalabrasReservadas values ("OLECOMPLETEDRAG")
		insert into C_PalabrasReservadas values ("OLECONTROL")
		insert into C_PalabrasReservadas values ("OLECONTROLCONTAINER")
		insert into C_PalabrasReservadas values ("OLEDRAG")
		insert into C_PalabrasReservadas values ("OLEDRAGDROP")
		insert into C_PalabrasReservadas values ("OLEDRAGMODE")
		insert into C_PalabrasReservadas values ("OLEDRAGOVER")
		insert into C_PalabrasReservadas values ("OLEDRAGPICTURE")
		insert into C_PalabrasReservadas values ("OLEDROPEFFECTS")
		insert into C_PalabrasReservadas values ("OLEDROPHASDATA")
		insert into C_PalabrasReservadas values ("OLEDROPMODE")
		insert into C_PalabrasReservadas values ("OLEDROPTEXTINSERTION")
		insert into C_PalabrasReservadas values ("OLEGIVEFEEDBACK")
		insert into C_PalabrasReservadas values ("OLEIDISPATCHINCOMING")
		insert into C_PalabrasReservadas values ("OLEIDISPATCHOUTGOING")
		insert into C_PalabrasReservadas values ("OLEIDISPINVALUE")
		insert into C_PalabrasReservadas values ("OLEIDISPOUTVALUE")
		insert into C_PalabrasReservadas values ("OLELCID")
		insert into C_PalabrasReservadas values ("OLEOBJECTS")
		insert into C_PalabrasReservadas values ("OLEPUBLIC")
		insert into C_PalabrasReservadas values ("OLEREQUESTPENDINGTIMOU")
		insert into C_PalabrasReservadas values ("OLESERVERBUSYRAISEERRO")
		insert into C_PalabrasReservadas values ("OLESERVERBUSYTIMOUT")
		insert into C_PalabrasReservadas values ("OLESETDATA")
		insert into C_PalabrasReservadas values ("OLESTARTDRAG")
		insert into C_PalabrasReservadas values ("OLETYPEALLOWED")
		insert into C_PalabrasReservadas values ("ON")
		insert into C_PalabrasReservadas values ("ONETOMANY")
		insert into C_PalabrasReservadas values ("ONLINE")
		insert into C_PalabrasReservadas values ("ONLY")
		insert into C_PalabrasReservadas values ("ONMOVEITEM")
		insert into C_PalabrasReservadas values ("ONPREVIEWCLOSE")
		insert into C_PalabrasReservadas values ("ONRESIZE")
		insert into C_PalabrasReservadas values ("OPEN")
		insert into C_PalabrasReservadas values ("OPENEDITOR")
		insert into C_PalabrasReservadas values ("OPENTABLES")
		insert into C_PalabrasReservadas values ("OPENVIEWS")
		insert into C_PalabrasReservadas values ("OPENWINDOW")
		insert into C_PalabrasReservadas values ("OPTIMIZE")
		insert into C_PalabrasReservadas values ("OPTIONBUTTON")
		insert into C_PalabrasReservadas values ("OPTIONGROUP")
		insert into C_PalabrasReservadas values ("OR")
		insert into C_PalabrasReservadas values ("ORACLE")
		insert into C_PalabrasReservadas values ("ORDER")
		insert into C_PalabrasReservadas values ("ORDERDIRECTION")
		insert into C_PalabrasReservadas values ("ORIENTATION")
		insert into C_PalabrasReservadas values ("OS")
		insert into C_PalabrasReservadas values ("OTHERWISE")
		insert into C_PalabrasReservadas values ("OUTER")
		insert into C_PalabrasReservadas values ("OUTPUT")
		insert into C_PalabrasReservadas values ("OUTPUTPAGE")
		insert into C_PalabrasReservadas values ("OUTPUTPAGECOUNT")
		insert into C_PalabrasReservadas values ("OUTPUTTYPE")
		insert into C_PalabrasReservadas values ("OUTSHOW")
		insert into C_PalabrasReservadas values ("OVERLAY")
		insert into C_PalabrasReservadas values ("OVERWRITE")
		insert into C_PalabrasReservadas values ("PACK")
		insert into C_PalabrasReservadas values ("PACKETSIZE")
		insert into C_PalabrasReservadas values ("PAD")
		insert into C_PalabrasReservadas values ("PADC")
		insert into C_PalabrasReservadas values ("PADL")
		insert into C_PalabrasReservadas values ("PADPROMPT")
		insert into C_PalabrasReservadas values ("PADR")
		insert into C_PalabrasReservadas values ("PAGE")
		insert into C_PalabrasReservadas values ("PAGECOUNT")
		insert into C_PalabrasReservadas values ("PAGEFRAME")
		insert into C_PalabrasReservadas values ("PAGEHEIGHT")
		insert into C_PalabrasReservadas values ("PAGEHEIGHT")
		insert into C_PalabrasReservadas values ("PAGENO")
		insert into C_PalabrasReservadas values ("PAGEORDER")
		insert into C_PalabrasReservadas values ("PAGES")
		insert into C_PalabrasReservadas values ("PAGETOTAL")
		insert into C_PalabrasReservadas values ("PAGEWIDTH")
		insert into C_PalabrasReservadas values ("PAINT")
		insert into C_PalabrasReservadas values ("PALETTE")
		insert into C_PalabrasReservadas values ("PANEL")
		insert into C_PalabrasReservadas values ("PANELLINK")
		insert into C_PalabrasReservadas values ("PAPERLENGTH")
		insert into C_PalabrasReservadas values ("PAPERSIZE")
		insert into C_PalabrasReservadas values ("PAPERWIDTH")
		insert into C_PalabrasReservadas values ("PARAMETERS")
		insert into C_PalabrasReservadas values ("PARENT")
		insert into C_PalabrasReservadas values ("PARENTALIAS")
		insert into C_PalabrasReservadas values ("PARENTCLASS")
		insert into C_PalabrasReservadas values ("PARENTTABLE")
		insert into C_PalabrasReservadas values ("PARTITION")
		insert into C_PalabrasReservadas values ("PASSWORD")
		insert into C_PalabrasReservadas values ("PASSWORDCHAR")
		insert into C_PalabrasReservadas values ("PATH")
		insert into C_PalabrasReservadas values ("PATTERN")
		insert into C_PalabrasReservadas values ("PAUSE")
		insert into C_PalabrasReservadas values ("PAYMENT")
		insert into C_PalabrasReservadas values ("PCOL")
		insert into C_PalabrasReservadas values ("PCOUNT")
		insert into C_PalabrasReservadas values ("PDOX")
		insert into C_PalabrasReservadas values ("PDSETUP")
		insert into C_PalabrasReservadas values ("PEMSTATUS")
		insert into C_PalabrasReservadas values ("PEN")
		insert into C_PalabrasReservadas values ("PERCENT")
		insert into C_PalabrasReservadas values ("PFS")
		insert into C_PalabrasReservadas values ("PI")
		insert into C_PalabrasReservadas values ("PICTURE")
		insert into C_PalabrasReservadas values ("PICTUREMARGIN")
		insert into C_PalabrasReservadas values ("PICTUREPOSITION")
		insert into C_PalabrasReservadas values ("PICTURESPACING")
		insert into C_PalabrasReservadas values ("PICTURESELECTIONDISPLAY")
		insert into C_PalabrasReservadas values ("PICTUREVAL")
		insert into C_PalabrasReservadas values ("PIVOT")
		insert into C_PalabrasReservadas values ("PIXELS")
		insert into C_PalabrasReservadas values ("PLAIN")
		insert into C_PalabrasReservadas values ("PLAN")
		insert into C_PalabrasReservadas values ("PLATFORM")
		insert into C_PalabrasReservadas values ("PLAY")
		insert into C_PalabrasReservadas values ("POINT")
		insert into C_PalabrasReservadas values ("POLYPOINTS")
		insert into C_PalabrasReservadas values ("POP")
		insert into C_PalabrasReservadas values ("POPUPS")
		insert into C_PalabrasReservadas values ("POWER")
		insert into C_PalabrasReservadas values ("PRECISION")
		insert into C_PalabrasReservadas values ("PREFERENCE")
		insert into C_PalabrasReservadas values ("PRESERVEWHITESPACE")
		insert into C_PalabrasReservadas values ("PRETEXT")
		insert into C_PalabrasReservadas values ("PREVIEW")
		insert into C_PalabrasReservadas values ("PREVIEWCONTAINER")
		insert into C_PalabrasReservadas values ("PRIMARY")
		insert into C_PalabrasReservadas values ("PRIMARYKEY")
		insert into C_PalabrasReservadas values ("PRINT")
		insert into C_PalabrasReservadas values ("PRINTER")
		insert into C_PalabrasReservadas values ("PRINTFORM")
		insert into C_PalabrasReservadas values ("PRINTJOB")
		insert into C_PalabrasReservadas values ("PRINTJOBNAME")
		insert into C_PalabrasReservadas values ("PRINTQUALITY")
		insert into C_PalabrasReservadas values ("PRINTSTATUS")
		insert into C_PalabrasReservadas values ("PRIVATE")
		insert into C_PalabrasReservadas values ("PRMBAR")
		insert into C_PalabrasReservadas values ("PRMPAD")
		insert into C_PalabrasReservadas values ("PROCEDURE")
		insert into C_PalabrasReservadas values ("PROCEDURES")
		insert into C_PalabrasReservadas values ("PRODUCTION")
		insert into C_PalabrasReservadas values ("PROGCACHE")
		insert into C_PalabrasReservadas values ("PROGRAM")
		insert into C_PalabrasReservadas values ("PROGRAMMATICCHANGE")
		insert into C_PalabrasReservadas values ("PROGWORK")
		insert into C_PalabrasReservadas values ("PROJECT")
		insert into C_PalabrasReservadas values ("PROJECTCLICK")
		insert into C_PalabrasReservadas values ("PROJECTHOOK")
		insert into C_PalabrasReservadas values ("PROMPT")
		insert into C_PalabrasReservadas values ("PROPER")
		insert into C_PalabrasReservadas values ("PROTECTED")
		insert into C_PalabrasReservadas values ("PROW")
		insert into C_PalabrasReservadas values ("PRTINFO")
		insert into C_PalabrasReservadas values ("PSET")
		insert into C_PalabrasReservadas values ("PSET")
		insert into C_PalabrasReservadas values ("PUBLIC")
		insert into C_PalabrasReservadas values ("PUSH")
		insert into C_PalabrasReservadas values ("PUTFILE")
		insert into C_PalabrasReservadas values ("PV")
		insert into C_PalabrasReservadas values ("QPR")
		insert into C_PalabrasReservadas values ("QUARTER")
		insert into C_PalabrasReservadas values ("QUERY")
		insert into C_PalabrasReservadas values ("QUERYADDFILE")
		insert into C_PalabrasReservadas values ("QUERYMODIFYFILE")
		insert into C_PalabrasReservadas values ("QUERYNEWFILE")
		insert into C_PalabrasReservadas values ("QUERYREMOVEFILE")
		insert into C_PalabrasReservadas values ("QUERYRUNFILE")
		insert into C_PalabrasReservadas values ("QUERYTIMEOUT")
		insert into C_PalabrasReservadas values ("QUERYUNLOAD")
		insert into C_PalabrasReservadas values ("QUERYUNLOAD")
		insert into C_PalabrasReservadas values ("QUIETMODE")
		insert into C_PalabrasReservadas values ("QUIT")
		insert into C_PalabrasReservadas values ("RADIANS")
		insert into C_PalabrasReservadas values ("RAISEEVENT")
		insert into C_PalabrasReservadas values ("RAND")
		insert into C_PalabrasReservadas values ("RANDOM")
		insert into C_PalabrasReservadas values ("RANGE")
		insert into C_PalabrasReservadas values ("RANGEHIGH")
		insert into C_PalabrasReservadas values ("RANGELOW")
		insert into C_PalabrasReservadas values ("RAT")
		insert into C_PalabrasReservadas values ("RATC")
		insert into C_PalabrasReservadas values ("RATLINE")
		insert into C_PalabrasReservadas values ("RD")
		insert into C_PalabrasReservadas values ("RDLEVEL")
		insert into C_PalabrasReservadas values ("READ")
		insert into C_PalabrasReservadas values ("READACTIVATE")
		insert into C_PalabrasReservadas values ("READBORDER")
		insert into C_PalabrasReservadas values ("READCOLORS")
		insert into C_PalabrasReservadas values ("READCYCLE")
		insert into C_PalabrasReservadas values ("READDEACTIVATE")
		insert into C_PalabrasReservadas values ("READERROR")
		insert into C_PalabrasReservadas values ("READEXPRESSION")
		insert into C_PalabrasReservadas values ("READFILLER")
		insert into C_PalabrasReservadas values ("READKEY")
		insert into C_PalabrasReservadas values ("READLOCK")
		insert into C_PalabrasReservadas values ("READMETHOD")
		insert into C_PalabrasReservadas values ("READMOUSE")
		insert into C_PalabrasReservadas values ("READONLY")
		insert into C_PalabrasReservadas values ("READSAVE")
		insert into C_PalabrasReservadas values ("READSHOW")
		insert into C_PalabrasReservadas values ("READSIZE")
		insert into C_PalabrasReservadas values ("READTIMEOUT")
		insert into C_PalabrasReservadas values ("READVALID")
		insert into C_PalabrasReservadas values ("READWHEN")
		insert into C_PalabrasReservadas values ("RECALL")
		insert into C_PalabrasReservadas values ("RECCOUNT")
		insert into C_PalabrasReservadas values ("RECENTLYUSEDFILES")
		insert into C_PalabrasReservadas values ("RECNO")
		insert into C_PalabrasReservadas values ("RECOMPILE")
		insert into C_PalabrasReservadas values ("RECORD")
		insert into C_PalabrasReservadas values ("RECORDMARK")
		insert into C_PalabrasReservadas values ("RECORDREFRESH")
		insert into C_PalabrasReservadas values ("RECORDSOURCE")
		insert into C_PalabrasReservadas values ("RECORDSOURCETYPE")
		insert into C_PalabrasReservadas values ("RECOVER")
		insert into C_PalabrasReservadas values ("RECSIZE")
		insert into C_PalabrasReservadas values ("RECT")
		insert into C_PalabrasReservadas values ("RECTCLASS")
		insert into C_PalabrasReservadas values ("RECYCLE")
		insert into C_PalabrasReservadas values ("REDIT")
		insert into C_PalabrasReservadas values ("REFERENCE")
		insert into C_PalabrasReservadas values ("REFERENCES")
		insert into C_PalabrasReservadas values ("REFRESH")
		insert into C_PalabrasReservadas values ("REFRESHALIAS")
		insert into C_PalabrasReservadas values ("REFRESHCMD")
		insert into C_PalabrasReservadas values ("REFRESHCMDDATASOURCE")
		insert into C_PalabrasReservadas values ("REFRESHCMDDATASOURCETYPE")
		insert into C_PalabrasReservadas values ("REFRESHIGNOREFIELDLIST")
		insert into C_PalabrasReservadas values ("REFRESHTIMESTAMP")
		insert into C_PalabrasReservadas values ("REINDEX")
		insert into C_PalabrasReservadas values ("RELATEDCHILD")
		insert into C_PalabrasReservadas values ("RELATEDTABLE")
		insert into C_PalabrasReservadas values ("RELATEDTAG")
		insert into C_PalabrasReservadas values ("RELATION")
		insert into C_PalabrasReservadas values ("RELATIONALEXPR")
		insert into C_PalabrasReservadas values ("RELATIVE")
		insert into C_PalabrasReservadas values ("RELATIVECOLUMN")
		insert into C_PalabrasReservadas values ("RELATIVEROW")
		insert into C_PalabrasReservadas values ("RELEASE")
		insert into C_PalabrasReservadas values ("RELEASEERASE")
		insert into C_PalabrasReservadas values ("RELEASETYPE")
		insert into C_PalabrasReservadas values ("RELEASEWINDOWS")
		insert into C_PalabrasReservadas values ("RELEASEXML")
		insert into C_PalabrasReservadas values ("REMOTE")
		insert into C_PalabrasReservadas values ("REMOVE")
		insert into C_PalabrasReservadas values ("REMOVEITEM")
		insert into C_PalabrasReservadas values ("REMOVELISTITEM")
		insert into C_PalabrasReservadas values ("REMOVEOBJECT")
		insert into C_PalabrasReservadas values ("REMOVEPROPERTY")
		insert into C_PalabrasReservadas values ("RENAME")
		insert into C_PalabrasReservadas values ("RENDER")
		insert into C_PalabrasReservadas values ("REPEAT")
		insert into C_PalabrasReservadas values ("REPLACE")
		insert into C_PalabrasReservadas values ("REPLICATE")
		insert into C_PalabrasReservadas values ("REPORT")
		insert into C_PalabrasReservadas values ("REPORTBEHAVIOR")
		insert into C_PalabrasReservadas values ("REPORTLISTENER")
		insert into C_PalabrasReservadas values ("REPROCESS")
		insert into C_PalabrasReservadas values ("REQUERY")
		insert into C_PalabrasReservadas values ("REQUESTDATA")
		insert into C_PalabrasReservadas values ("REQUIRED")
		insert into C_PalabrasReservadas values ("RESET")
		insert into C_PalabrasReservadas values ("RESETTODEFAULT")
		insert into C_PalabrasReservadas values ("RESHEIGHT")
		insert into C_PalabrasReservadas values ("RESIZABLE")
		insert into C_PalabrasReservadas values ("RESIZE")
		insert into C_PalabrasReservadas values ("RESOURCE")
		insert into C_PalabrasReservadas values ("RESOURCEON")
		insert into C_PalabrasReservadas values ("RESOURCES")
		insert into C_PalabrasReservadas values ("RESOURCETO")
		insert into C_PalabrasReservadas values ("RESPECTCURSORCP")
		insert into C_PalabrasReservadas values ("RESPECTNESTING")
		insert into C_PalabrasReservadas values ("REST")
		insert into C_PalabrasReservadas values ("RESTORE")
		insert into C_PalabrasReservadas values ("RESTRICT")
		insert into C_PalabrasReservadas values ("RESUME")
		insert into C_PalabrasReservadas values ("RESWIDTH")
		insert into C_PalabrasReservadas values ("RETRY")
		insert into C_PalabrasReservadas values ("RETURN")
		insert into C_PalabrasReservadas values ("REVERTOFFLINE")
		insert into C_PalabrasReservadas values ("RGB")
		insert into C_PalabrasReservadas values ("RGBSCHEME")
		insert into C_PalabrasReservadas values ("RIGHT")
		insert into C_PalabrasReservadas values ("RIGHTC")
		insert into C_PalabrasReservadas values ("RIGHTCLICK")
		insert into C_PalabrasReservadas values ("RIGHTTOLEFT")
		insert into C_PalabrasReservadas values ("RLOCK")
		insert into C_PalabrasReservadas values ("RMDIR")
		insert into C_PalabrasReservadas values ("ROLLBACK")
		insert into C_PalabrasReservadas values ("ROLLOVER")
		insert into C_PalabrasReservadas values ("ROTATION")
		insert into C_PalabrasReservadas values ("ROTATEFLIP")
		insert into C_PalabrasReservadas values ("ROUND")
		insert into C_PalabrasReservadas values ("ROW")
		insert into C_PalabrasReservadas values ("ROWCOLCHANGE")
		insert into C_PalabrasReservadas values ("ROWHEIGHT")
		insert into C_PalabrasReservadas values ("ROWSET")
		insert into C_PalabrasReservadas values ("ROWSOURCE")
		insert into C_PalabrasReservadas values ("ROWSOURCETYPE")
		insert into C_PalabrasReservadas values ("RPD")
		insert into C_PalabrasReservadas values ("RSTOCURSOR")
		insert into C_PalabrasReservadas values ("RTLJUSTIFY")
		insert into C_PalabrasReservadas values ("RTOD")
		insert into C_PalabrasReservadas values ("RTRIM")
		insert into C_PalabrasReservadas values ("RULEEXPRESSION")
		insert into C_PalabrasReservadas values ("RULETEXT")
		insert into C_PalabrasReservadas values ("RUN")
		insert into C_PalabrasReservadas values ("RUNTIME")
		insert into C_PalabrasReservadas values ("RVIEW")
		insert into C_PalabrasReservadas values ("SAFETY")
		insert into C_PalabrasReservadas values ("SAME")
		insert into C_PalabrasReservadas values ("SAMPLE")
		insert into C_PalabrasReservadas values ("SAVE")
		insert into C_PalabrasReservadas values ("SAVEAS")
		insert into C_PalabrasReservadas values ("SAVEASCLASS")
		insert into C_PalabrasReservadas values ("SAVEPICTURE")
		insert into C_PalabrasReservadas values ("SAY")
		insert into C_PalabrasReservadas values ("SCALE")
		insert into C_PalabrasReservadas values ("SCALEMODE")
		insert into C_PalabrasReservadas values ("SCALEUNITS")
		insert into C_PalabrasReservadas values ("SCAN")
		insert into C_PalabrasReservadas values ("SCATTER")
		insert into C_PalabrasReservadas values ("SCCDESTROY")
		insert into C_PalabrasReservadas values ("SCCINIT")
		insert into C_PalabrasReservadas values ("SCHEME")
		insert into C_PalabrasReservadas values ("SCOLS")
		insert into C_PalabrasReservadas values ("SCOREBOARD")
		insert into C_PalabrasReservadas values ("SCREEN")
		insert into C_PalabrasReservadas values ("SCREENS")
		insert into C_PalabrasReservadas values ("SCROLL")
		insert into C_PalabrasReservadas values ("SCROLLBARS")
		insert into C_PalabrasReservadas values ("SCROLLED")
		insert into C_PalabrasReservadas values ("SCROLLSCROLLBARS")
		insert into C_PalabrasReservadas values ("SDF")
		insert into C_PalabrasReservadas values ("SDIFORM")
		insert into C_PalabrasReservadas values ("SEC")
		insert into C_PalabrasReservadas values ("SECOND")
		insert into C_PalabrasReservadas values ("SECONDS")
		insert into C_PalabrasReservadas values ("SECONDS")
		insert into C_PalabrasReservadas values ("SEEK")
		insert into C_PalabrasReservadas values ("SELECT")
		insert into C_PalabrasReservadas values ("SELECTCMD")
		insert into C_PalabrasReservadas values ("SELECTED")
		insert into C_PalabrasReservadas values ("SELECTEDBACKCOLOR")
		insert into C_PalabrasReservadas values ("SELECTEDFORECOLOR")
		insert into C_PalabrasReservadas values ("SELECTEDID")
		insert into C_PalabrasReservadas values ("SELECTEDITEMBACKCOLOR")
		insert into C_PalabrasReservadas values ("SELECTEDITEMFORECOLOR")
		insert into C_PalabrasReservadas values ("SELECTION")
		insert into C_PalabrasReservadas values ("SELECTIONNAMESPACES")
		insert into C_PalabrasReservadas values ("SELECTONENTRY")
		insert into C_PalabrasReservadas values ("SELFEDIT")
		insert into C_PalabrasReservadas values ("SELLENGTH")
		insert into C_PalabrasReservadas values ("SELSTART")
		insert into C_PalabrasReservadas values ("SELTEXT")
		insert into C_PalabrasReservadas values ("SENDGDIPLUSIMAGE")
		insert into C_PalabrasReservadas values ("SENDUPDATES")
		insert into C_PalabrasReservadas values ("SEPARATOR")
		insert into C_PalabrasReservadas values ("SET")
		insert into C_PalabrasReservadas values ("SETALL")
		insert into C_PalabrasReservadas values ("SETDATA")
		insert into C_PalabrasReservadas values ("SETDEFAULT")
		insert into C_PalabrasReservadas values ("SETFLDSTATE")
		insert into C_PalabrasReservadas values ("SETFOCUS")
		insert into C_PalabrasReservadas values ("SETFORMAT")
		insert into C_PalabrasReservadas values ("SETRESULTSET")
		insert into C_PalabrasReservadas values ("SETUP")
		insert into C_PalabrasReservadas values ("SETVAR")
		insert into C_PalabrasReservadas values ("SETVIEWPORT")
		insert into C_PalabrasReservadas values ("SHADOWS")
		insert into C_PalabrasReservadas values ("SHAPE")
		insert into C_PalabrasReservadas values ("SHARECONNECTION")
		insert into C_PalabrasReservadas values ("SHARED")
		insert into C_PalabrasReservadas values ("SHEET")
		insert into C_PalabrasReservadas values ("SHELL")
		insert into C_PalabrasReservadas values ("SHIFT")
		insert into C_PalabrasReservadas values ("SHORTCUT")
		insert into C_PalabrasReservadas values ("SHOW")
		insert into C_PalabrasReservadas values ("SHOWDOC")
		insert into C_PalabrasReservadas values ("SHOWINTASKBAR")
		insert into C_PalabrasReservadas values ("SHOWOLECONTROLS")
		insert into C_PalabrasReservadas values ("SHOWOLEINSERTABLE")
		insert into C_PalabrasReservadas values ("SHOWTIPS")
		insert into C_PalabrasReservadas values ("SHOWVCXS")
		insert into C_PalabrasReservadas values ("SHOWWHATSTHIS")
		insert into C_PalabrasReservadas values ("SHOWWINDOW")
		insert into C_PalabrasReservadas values ("SHUTDOWN")
		insert into C_PalabrasReservadas values ("SIGN")
		insert into C_PalabrasReservadas values ("SIN")
		insert into C_PalabrasReservadas values ("SINGLE")
		insert into C_PalabrasReservadas values ("SIZABLE")
		insert into C_PalabrasReservadas values ("SIZE")
		insert into C_PalabrasReservadas values ("SIZE<HEIGHT>")
		insert into C_PalabrasReservadas values ("SIZE<MAXLENGTH>")
		insert into C_PalabrasReservadas values ("SIZE<WIDTH>")
		insert into C_PalabrasReservadas values ("SIZEBOX")
		insert into C_PalabrasReservadas values ("SKIP")
		insert into C_PalabrasReservadas values ("SKIPFORM")
		insert into C_PalabrasReservadas values ("SKPBAR")
		insert into C_PalabrasReservadas values ("SKPPAD")
		insert into C_PalabrasReservadas values ("SOM")
		insert into C_PalabrasReservadas values ("SOME")
		insert into C_PalabrasReservadas values ("SORT")
		insert into C_PalabrasReservadas values ("SORTED")
		insert into C_PalabrasReservadas values ("SORTWORK")
		insert into C_PalabrasReservadas values ("SOUNDEX")
		insert into C_PalabrasReservadas values ("SOURCENAME")
		insert into C_PalabrasReservadas values ("SOURCETYPE")
		insert into C_PalabrasReservadas values ("SPACE")
		insert into C_PalabrasReservadas values ("SPARSE")
		insert into C_PalabrasReservadas values ("SPECIALEFFECT")
		insert into C_PalabrasReservadas values ("SPINNER")
		insert into C_PalabrasReservadas values ("SPINNERHIGHVALUE")
		insert into C_PalabrasReservadas values ("SPINNERLOWVALUE")
		insert into C_PalabrasReservadas values ("SPLITBAR")
		insert into C_PalabrasReservadas values ("SQL")
		insert into C_PalabrasReservadas values ("SQLASYNCHRONOUS")
		insert into C_PalabrasReservadas values ("SQLBATCHMODE")
		insert into C_PalabrasReservadas values ("SQLCANCEL")
		insert into C_PalabrasReservadas values ("SQLCOLUMNS")
		insert into C_PalabrasReservadas values ("SQLCOMMIT")
		insert into C_PalabrasReservadas values ("SQLCONNECT")
		insert into C_PalabrasReservadas values ("SQLCONNECTTIMEOUT")
		insert into C_PalabrasReservadas values ("SQLDISCONNECT")
		insert into C_PalabrasReservadas values ("SQLDISPLOGIN")
		insert into C_PalabrasReservadas values ("SQLDISPWARNINGS")
		insert into C_PalabrasReservadas values ("SQLEXEC")
		insert into C_PalabrasReservadas values ("SQLGETPROP")
		insert into C_PalabrasReservadas values ("SQLIDLEDISCONNECT")
		insert into C_PalabrasReservadas values ("SQLIDLETIMEOUT")
		insert into C_PalabrasReservadas values ("SQLL")
		insert into C_PalabrasReservadas values ("SQLMORERESULTS")
		insert into C_PalabrasReservadas values ("SQLPREPARE")
		insert into C_PalabrasReservadas values ("SQLQUERYTIMEOUT")
		insert into C_PalabrasReservadas values ("SQLROLLBACK")
		insert into C_PalabrasReservadas values ("SQLSETPROP")
		insert into C_PalabrasReservadas values ("SQLSTRINGCONNECT")
		insert into C_PalabrasReservadas values ("SQLSTRINGCONNECT")
		insert into C_PalabrasReservadas values ("SQLTABLES")
		insert into C_PalabrasReservadas values ("SQLTRANSACTIONS")
		insert into C_PalabrasReservadas values ("SQLWAITTIME")
		insert into C_PalabrasReservadas values ("SQRT")
		insert into C_PalabrasReservadas values ("SROWS")
		insert into C_PalabrasReservadas values ("STACKLEVEL")
		insert into C_PalabrasReservadas values ("STANDALONE")
		insert into C_PalabrasReservadas values ("STATUS")
		insert into C_PalabrasReservadas values ("STATUSBAR")
		insert into C_PalabrasReservadas values ("STATUSBARTEXT")
		insert into C_PalabrasReservadas values ("STD")
		insert into C_PalabrasReservadas values ("STEP")
		insert into C_PalabrasReservadas values ("STICKY")
		insert into C_PalabrasReservadas values ("STORE")
		insert into C_PalabrasReservadas values ("STR")
		insert into C_PalabrasReservadas values ("STRCONV")
		insert into C_PalabrasReservadas values ("STRETCH")
		insert into C_PalabrasReservadas values ("STRICTDATE")
		insert into C_PalabrasReservadas values ("STRICTDATEENTRY")
		insert into C_PalabrasReservadas values ("STRING")
		insert into C_PalabrasReservadas values ("STRTOFILE")
		insert into C_PalabrasReservadas values ("STRTRAN")
		insert into C_PalabrasReservadas values ("STRUCTURE")
		insert into C_PalabrasReservadas values ("STUFF")
		insert into C_PalabrasReservadas values ("STUFFC")
		insert into C_PalabrasReservadas values ("STYLE")
		insert into C_PalabrasReservadas values ("SUBCLASS")
		insert into C_PalabrasReservadas values ("SUBSTR")
		insert into C_PalabrasReservadas values ("SUBSTRC")
		insert into C_PalabrasReservadas values ("SUBSTRING")
		insert into C_PalabrasReservadas values ("SUM")
		insert into C_PalabrasReservadas values ("SUMMARY")
		insert into C_PalabrasReservadas values ("SUPPORTSLISTENERTYPE")
		insert into C_PalabrasReservadas values ("SUSPEND")
		insert into C_PalabrasReservadas values ("SYLK")
		insert into C_PalabrasReservadas values ("SYS")
		insert into C_PalabrasReservadas values ("SYSFORMATS")
		insert into C_PalabrasReservadas values ("SYSMENUS")
		insert into C_PalabrasReservadas values ("SYSMETRIC")
		insert into C_PalabrasReservadas values ("SYSTEM")
		insert into C_PalabrasReservadas values ("SYSTEMREFCOUNT")
		insert into C_PalabrasReservadas values ("TAB")
		insert into C_PalabrasReservadas values ("TABFIXEDHEIGHT")
		insert into C_PalabrasReservadas values ("TABFIXEDWIDTH")
		insert into C_PalabrasReservadas values ("TABHIT")
		insert into C_PalabrasReservadas values ("TABINDEX")
		insert into C_PalabrasReservadas values ("TABLE")
		insert into C_PalabrasReservadas values ("TABLEPROMPT")
		insert into C_PalabrasReservadas values ("TABLEREFRESH")
		insert into C_PalabrasReservadas values ("TABLEREVERT")
		insert into C_PalabrasReservadas values ("TABLES")
		insert into C_PalabrasReservadas values ("TABLEUPDATE")
		insert into C_PalabrasReservadas values ("TABLEVALIDATE")
		insert into C_PalabrasReservadas values ("TABORDERING")
		insert into C_PalabrasReservadas values ("TABORIENTATION")
		insert into C_PalabrasReservadas values ("TABS")
		insert into C_PalabrasReservadas values ("TABSTOP")
		insert into C_PalabrasReservadas values ("TABSTRETCH")
		insert into C_PalabrasReservadas values ("TABSTYLE")
		insert into C_PalabrasReservadas values ("TAG")
		insert into C_PalabrasReservadas values ("TAGCOUNT")
		insert into C_PalabrasReservadas values ("TAGNO")
		insert into C_PalabrasReservadas values ("TALK")
		insert into C_PalabrasReservadas values ("TAN")
		insert into C_PalabrasReservadas values ("TARGET")
		insert into C_PalabrasReservadas values ("TASKPANE")
		insert into C_PalabrasReservadas values ("TEDIT")
		insert into C_PalabrasReservadas values ("TERMINATEREAD")
		insert into C_PalabrasReservadas values ("TEXT")
		insert into C_PalabrasReservadas values ("TEXTBOX")
		insert into C_PalabrasReservadas values ("TEXTHEIGHT")
		insert into C_PalabrasReservadas values ("TEXTMERGE")
		insert into C_PalabrasReservadas values ("TEXTWIDTH")
		insert into C_PalabrasReservadas values ("THEMES")
		insert into C_PalabrasReservadas values ("THEN")
		insert into C_PalabrasReservadas values ("THIS")
		insert into C_PalabrasReservadas values ("THISFORM")
		insert into C_PalabrasReservadas values ("THISFORMSET")
		insert into C_PalabrasReservadas values ("THROW")
		insert into C_PalabrasReservadas values ("TIME")
		insert into C_PalabrasReservadas values ("TIMEOUT")
		insert into C_PalabrasReservadas values ("TIMER")
		insert into C_PalabrasReservadas values ("TIMESTAMP")
		insert into C_PalabrasReservadas values ("TIMESTAMPDIFF")
		insert into C_PalabrasReservadas values ("TIMESTAMPFIELDLIST")
		insert into C_PalabrasReservadas values ("TITLEBAR")
		insert into C_PalabrasReservadas values ("TITLES")
		insert into C_PalabrasReservadas values ("TMPFILES")
		insert into C_PalabrasReservadas values ("TO")
		insert into C_PalabrasReservadas values ("TOCURSOR")
		insert into C_PalabrasReservadas values ("TOOLBAR")
		insert into C_PalabrasReservadas values ("TOOLBOX")
		insert into C_PalabrasReservadas values ("TOOLTIPTEXT")
		insert into C_PalabrasReservadas values ("TOP")
		insert into C_PalabrasReservadas values ("TOPIC")
		insert into C_PalabrasReservadas values ("TOPINDEX")
		insert into C_PalabrasReservadas values ("TOPITEMID")
		insert into C_PalabrasReservadas values ("TOTAL")
		insert into C_PalabrasReservadas values ("TOXML")
		insert into C_PalabrasReservadas values ("TRANSACTION")
		insert into C_PalabrasReservadas values ("TRANSACTIONS")
		insert into C_PalabrasReservadas values ("TRANSFORM")
		insert into C_PalabrasReservadas values ("TRAP")
		insert into C_PalabrasReservadas values ("TRBETWEEN")
		insert into C_PalabrasReservadas values ("TRIGGER")
		insert into C_PalabrasReservadas values ("TRIM")
		insert into C_PalabrasReservadas values ("TRUNCATE")
		insert into C_PalabrasReservadas values ("TRY")
		insert into C_PalabrasReservadas values ("TTOC")
		insert into C_PalabrasReservadas values ("TTOD")
		insert into C_PalabrasReservadas values ("TTOPTION")
		insert into C_PalabrasReservadas values ("TWOPASSPROCESS")
		insert into C_PalabrasReservadas values ("TXNLEVEL")
		insert into C_PalabrasReservadas values ("TXTWIDTH")
		insert into C_PalabrasReservadas values ("TYPE")
		insert into C_PalabrasReservadas values ("TYPEAHEAD")
		insert into C_PalabrasReservadas values ("UCASE")
		insert into C_PalabrasReservadas values ("UDFPARMS")
		insert into C_PalabrasReservadas values ("UIENABLE")
		insert into C_PalabrasReservadas values ("UNBINDEVENT")
		insert into C_PalabrasReservadas values ("UNDEFINE")
		insert into C_PalabrasReservadas values ("UNDOCK")
		insert into C_PalabrasReservadas values ("UNICODE")
		insert into C_PalabrasReservadas values ("UNION")
		insert into C_PalabrasReservadas values ("UNIQUE")
		insert into C_PalabrasReservadas values ("UNLOAD")
		insert into C_PalabrasReservadas values ("UNLOADREPORT")
		insert into C_PalabrasReservadas values ("UNLOCK")
		insert into C_PalabrasReservadas values ("UNLOCKDATASOURCE")
		insert into C_PalabrasReservadas values ("UNNEST")
		insert into C_PalabrasReservadas values ("UNPACK")
		insert into C_PalabrasReservadas values ("UP")
		insert into C_PalabrasReservadas values ("UPCLICK")
		insert into C_PalabrasReservadas values ("UPDATABLE")
		insert into C_PalabrasReservadas values ("UPDATABLEFIELDLIST")
		insert into C_PalabrasReservadas values ("UPDATE")
		insert into C_PalabrasReservadas values ("UPDATECMD")
		insert into C_PalabrasReservadas values ("UPDATECMDREFRESHCMD")
		insert into C_PalabrasReservadas values ("UPDATECMDREFRESHFIELDLIST")
		insert into C_PalabrasReservadas values ("UPDATECMDREFRESHKEYFIELDLIST")
		insert into C_PalabrasReservadas values ("UPDATECMDSOURCE")
		insert into C_PalabrasReservadas values ("UPDATECMDSOURCETYPE")
		insert into C_PalabrasReservadas values ("UPDATED")
		insert into C_PalabrasReservadas values ("UPDATEDATASOURCE")
		insert into C_PalabrasReservadas values ("UPDATEGRAM")
		insert into C_PalabrasReservadas values ("UPDATEGRAMSCHEMALOCATION")
		insert into C_PalabrasReservadas values ("UPDATENAME")
		insert into C_PalabrasReservadas values ("UPDATENAMELIST")
		insert into C_PalabrasReservadas values ("UPDATESTATUS")
		insert into C_PalabrasReservadas values ("UPDATETRIGGER")
		insert into C_PalabrasReservadas values ("UPDATETYPE")
		insert into C_PalabrasReservadas values ("UPPER")
		insert into C_PalabrasReservadas values ("UPSIZING")
		insert into C_PalabrasReservadas values ("USA")
		insert into C_PalabrasReservadas values ("USE")
		insert into C_PalabrasReservadas values ("USECODEPAGE")
		insert into C_PalabrasReservadas values ("USECURSORSCHEMA")
		insert into C_PalabrasReservadas values ("USED")
		insert into C_PalabrasReservadas values ("USEMEMOSIZE")
		insert into C_PalabrasReservadas values ("USERID")
		insert into C_PalabrasReservadas values ("USERS")
		insert into C_PalabrasReservadas values ("USERVALUE")
		insert into C_PalabrasReservadas values ("USETRANSACTIONS")
		insert into C_PalabrasReservadas values ("UTF8ENCODED")
		insert into C_PalabrasReservadas values ("VAL")
		insert into C_PalabrasReservadas values ("VALID")
		insert into C_PalabrasReservadas values ("VALIDATE")
		insert into C_PalabrasReservadas values ("VALUE")
		insert into C_PalabrasReservadas values ("VALUEDIRTY")
		insert into C_PalabrasReservadas values ("VALUES")
		insert into C_PalabrasReservadas values ("VAR")
		insert into C_PalabrasReservadas values ("VARBINARY")
		insert into C_PalabrasReservadas values ("VARCHAR")
		insert into C_PalabrasReservadas values ("VARCHARMAPPING")
		insert into C_PalabrasReservadas values ("VARREAD")
		insert into C_PalabrasReservadas values ("VARTYPE")
		insert into C_PalabrasReservadas values ("VERB")
		insert into C_PalabrasReservadas values ("VERSION")
		insert into C_PalabrasReservadas values ("VGA25")
		insert into C_PalabrasReservadas values ("VGA50")
		insert into C_PalabrasReservadas values ("VIEW")
		insert into C_PalabrasReservadas values ("VIEWPORTHEIGHT")
		insert into C_PalabrasReservadas values ("VIEWPORTLEFT")
		insert into C_PalabrasReservadas values ("VIEWPORTTOP")
		insert into C_PalabrasReservadas values ("VIEWPORTWIDTH")
		insert into C_PalabrasReservadas values ("VIEWS")
		insert into C_PalabrasReservadas values ("VISIBLE")
		insert into C_PalabrasReservadas values ("VISUALEFFECT")
		insert into C_PalabrasReservadas values ("VOLUME")
		insert into C_PalabrasReservadas values ("VSCROLLSMALLCHANGE")
		insert into C_PalabrasReservadas values ("WAIT")
		insert into C_PalabrasReservadas values ("WAITTIME")
		insert into C_PalabrasReservadas values ("WASACTIVE")
		insert into C_PalabrasReservadas values ("WASOPEN")
		insert into C_PalabrasReservadas values ("WBORDER")
		insert into C_PalabrasReservadas values ("WCHILD")
		insert into C_PalabrasReservadas values ("WCOLS")
		insert into C_PalabrasReservadas values ("WDOCKABLE")
		insert into C_PalabrasReservadas values ("WEEK")
		insert into C_PalabrasReservadas values ("WEXIST")
		insert into C_PalabrasReservadas values ("WFONT")
		insert into C_PalabrasReservadas values ("WHATSTHISBUTTON")
		insert into C_PalabrasReservadas values ("WHATSTHISHELP")
		insert into C_PalabrasReservadas values ("WHATSTHISHELPID")
		insert into C_PalabrasReservadas values ("WHATSTHISMODE")
		insert into C_PalabrasReservadas values ("WHEN")
		insert into C_PalabrasReservadas values ("WHERE")
		insert into C_PalabrasReservadas values ("WHEREWHERETYPE")
		insert into C_PalabrasReservadas values ("WHILE")
		insert into C_PalabrasReservadas values ("WIDTH")
		insert into C_PalabrasReservadas values ("WINDCMD")
		insert into C_PalabrasReservadas values ("WINDHELP")
		insert into C_PalabrasReservadas values ("WINDMEMO")
		insert into C_PalabrasReservadas values ("WINDMENU")
		insert into C_PalabrasReservadas values ("WINDMODIFY")
		insert into C_PalabrasReservadas values ("WINDOW")
		insert into C_PalabrasReservadas values ("WINDOWLIST")
		insert into C_PalabrasReservadas values ("WINDOWNTILIST")
		insert into C_PalabrasReservadas values ("WINDOWS")
		insert into C_PalabrasReservadas values ("WINDOWSTATE")
		insert into C_PalabrasReservadas values ("WINDOWTYPE")
		insert into C_PalabrasReservadas values ("WINDQUERY")
		insert into C_PalabrasReservadas values ("WINDSCREEN")
		insert into C_PalabrasReservadas values ("WINDSNIP")
		insert into C_PalabrasReservadas values ("WINDSTPROC")
		insert into C_PalabrasReservadas values ("WITH")
		insert into C_PalabrasReservadas values ("WIZARDPROMPT")
		insert into C_PalabrasReservadas values ("WK1")
		insert into C_PalabrasReservadas values ("WK3")
		insert into C_PalabrasReservadas values ("WKS")
		insert into C_PalabrasReservadas values ("WLAST")
		insert into C_PalabrasReservadas values ("WLCOL")
		insert into C_PalabrasReservadas values ("WLROW")
		insert into C_PalabrasReservadas values ("WMAXIMUM")
		insert into C_PalabrasReservadas values ("WMINIMUM")
		insert into C_PalabrasReservadas values ("WONTOP")
		insert into C_PalabrasReservadas values ("WORDWRAP")
		insert into C_PalabrasReservadas values ("WORKAREA")
		insert into C_PalabrasReservadas values ("WOUTPUT")
		insert into C_PalabrasReservadas values ("WP")
		insert into C_PalabrasReservadas values ("WPARENT")
		insert into C_PalabrasReservadas values ("WR1")
		insert into C_PalabrasReservadas values ("WRAP")
		insert into C_PalabrasReservadas values ("WRAPCHARINCDATA")
		insert into C_PalabrasReservadas values ("WRAPINCDATA")
		insert into C_PalabrasReservadas values ("WRAPMEMOINCDATA")
		insert into C_PalabrasReservadas values ("WREAD")
		insert into C_PalabrasReservadas values ("WRITEEXPRESSION")
		insert into C_PalabrasReservadas values ("WRITEMETHOD")
		insert into C_PalabrasReservadas values ("WRK")
		insert into C_PalabrasReservadas values ("WROWS")
		insert into C_PalabrasReservadas values ("WTITLE")
		insert into C_PalabrasReservadas values ("WVISIBLE")
		insert into C_PalabrasReservadas values ("XCMDFILE")
		insert into C_PalabrasReservadas values ("XL5")
		insert into C_PalabrasReservadas values ("XL8")
		insert into C_PalabrasReservadas values ("XLS")
		insert into C_PalabrasReservadas values ("XMLADAPTER")
		insert into C_PalabrasReservadas values ("XMLCONSTRAINTS")
		insert into C_PalabrasReservadas values ("XMLFIELD")
		insert into C_PalabrasReservadas values ("XMLNAME")
		insert into C_PalabrasReservadas values ("XMLNAMEISXPATH")
		insert into C_PalabrasReservadas values ("XMLNAMESPACE")
		insert into C_PalabrasReservadas values ("XMLPREFIX")
		insert into C_PalabrasReservadas values ("XMLSCHEMALOCATION")
		insert into C_PalabrasReservadas values ("XMLTABLE")
		insert into C_PalabrasReservadas values ("XMLTOCURSOR")
		insert into C_PalabrasReservadas values ("XMLTYPE")
		insert into C_PalabrasReservadas values ("XMLUPDATEGRAM")
		insert into C_PalabrasReservadas values ("XSDFRACTIONDIGITS")
		insert into C_PalabrasReservadas values ("XSDMAXLENGTH")
		insert into C_PalabrasReservadas values ("XSDTOTALDIGITS")
		insert into C_PalabrasReservadas values ("XSDTYPE")
		insert into C_PalabrasReservadas values ("YEAR")
		insert into C_PalabrasReservadas values ("YRESOLUTION")
		insert into C_PalabrasReservadas values ("Z")
		insert into C_PalabrasReservadas values ("ZAP")
		insert into C_PalabrasReservadas values ("ZOOM")
		insert into C_PalabrasReservadas values ("ZOOMBOX")
		insert into C_PalabrasReservadas values ("ZORDER")
		insert into C_PalabrasReservadas values ("ZORDERSET")			
		insert into C_PalabrasReservadas values ("LENTIDADEDITABLE")
		insert into C_PalabrasReservadas values ("BLOQUEARREGISTRO")
		insert into C_PalabrasReservadas values ("BLOQREG")
		insert into C_PalabrasReservadas values ("CAI")
		insert into C_PalabrasReservadas values ("FECHAVTOCAI")
		insert into C_PalabrasReservadas values ("VTOCAI")
		insert into C_PalabrasReservadas values ( "CODIGOBARRAAUTOIMPRESOR" )
		insert into C_PalabrasReservadas values ( "CBAUTOIMP" )
		
		select C_PalabrasReservadas 
		index on "Palabra" to "c_Reser"


	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Validar() as boolean
		local llRetorno as Boolean, lcCurso as string
		llRetorno = .t.
		
		try
		
			With This as ValidarAdn of ValidarAdn.prg
				.CrearADNAdicional()

				.LimpiarInformacion()
				.oInformacionIndividual.Limpiar()
				
				.InformarProceso( "ValidarUnicidadDeEntidades" )
				.ValidarUnicidadDeEntidades()			&& Chequear que no haya repetidos en Tabla Entidades
				.AgregarInformacionGeneral( "Falló Validar Unicidad de Entidades" )
				
				.InformarProceso( "ValidarClavePrimariaEnEntidad" )
				.ValidarClavePrimariaEnEntidad() 		&& Chequear que exista al menos una clave primaria por entidad
				.AgregarInformacionGeneral( "Falló Validar Clave Primaria en Entidad" )
				
				.InformarProceso( "ValidarAtributosNoRepetidos" )
				.ValidarAtributosNoRepetidos() 			&& Chequear que no existan atributos repetidos para una entidad
				.AgregarInformacionGeneral( "Falló Validar Atributos No Repetidos" )
				
				.InformarProceso( "ValidarTipodatoLongitudDecimalesEtiqueta" )
				.ValidarTipodatoLongitudDecimalesEtiqueta() && Chequear que no falten tipos de dato, longitud, decimales y etiqueta
				.AgregarInformacionGeneral( "Falló Validar Tipo de Dato, Longitud, Decimales o Etiquetas" )
				
				.InformarProceso( "ValidarDominioEnDiccionario" )
				.ValidarDominioEnDiccionario()  			&& Chequear que no falten dominios en el diccionario
				.AgregarInformacionGeneral( "Falló Validar Dominio en Diccionario" )
				
				.InformarProceso( "ValidarValorSubgrupo" )
				.ValidarValorSubgrupo()  				&& Chequear que los valores del campo Subgrupo sean válidos
				.AgregarInformacionGeneral( "Falló Validar Valor en Subgrupo" )

				.InformarProceso( "ValidarTiposSubgrupo" )
				.ValidarTiposSubgrupo()  					&& Chequear que el TipoSubgrupo sea válido
				.AgregarInformacionGeneral( "Falló Validar Tipo de Subgrupo" )

				.InformarProceso( "ValidarAtributosVacios" )
				.ValidarAtributosVacios()  				&& Chequea que no existan atributos vacíos
				.AgregarInformacionGeneral( "Falló Validar Atributos Vacíos" )
				
				.InformarProceso( "ValidarAyudaEnFormularios" )
				.ValidarAyudaEnFormularios() 			&& Chequear que no falten ayuda en atributos
				.AgregarInformacionGeneral( "Falló Validar Ayuda en Formularios" )

				.InformarProceso( "ValidarDominioCodigo" )
				.ValidarDominioCodigo() 					&& Chequear los Dominios CODIGO
				.AgregarInformacionGeneral( "Falló Validar Dominio Código" )

				.InformarProceso( "ValidarComposicionDeBloques" )
				.ValidarComposicionDeBloques() 						&& Chequear los dominios con Bloques
				.AgregarInformacionGeneral( "Falló Validar Composición de Bloques" )

				.InformarProceso( "ValidarControlesEstilos" )
				.ValidarControlesEstilos() 				&& Chequear que todos los controles tengan todos los estilos
				.AgregarInformacionGeneral( "Falló Validar Controles Estilos" )

				.InformarProceso( "ValidarDescripcionesSubgrupo" )
				.ValidarDescripcionesSubgrupo()  			&& Chequear que la descripción del subgrupo sea válida
				.AgregarInformacionGeneral( "Falló Validar Descripción en Subgrupo" )

				.InformarProceso( "ValidarDescripcionesGrupo" )
				.ValidarDescripcionesGrupo() 				&& Chequear la Descripción de los Grupos
				.AgregarInformacionGeneral( "Falló Validar la Descripción de Grupos" )

				.InformarProceso( "ValidarLargoTablaMemoGenerico" )
				.ValidarLargoTablaMemoGenerico() 			&& Chequear que el largo de la tabla auxiliar no se pase del limite
				.AgregarInformacionGeneral( "Falló Validar Largo Tabla Memo" )

				.InformarProceso( "ValidarSumarizarGenerico" )		
				.ValidarSumarizarGenerico() 					&& chequea que sumarizar solo son para dominios DetallesXXX
				.AgregarInformacionGeneral( "Falló Validar Sumarizar" )

				.InformarProceso( "ValidarDescripcionEntidadGenerico" )		
				.ValidarDescripcionEntidadGenerico() 		&& chequea que las entidades tengan descripcion
				.AgregarInformacionGeneral( "Falló Validar Descripcion Entidad" )

				.InformarProceso( "ValidarCampoBusquedaGenerico" )		
				.ValidarCampoBusquedaGenerico() 				&& chequea que los campos busquedas sean primary o foreing keys
				.AgregarInformacionGeneral( "Falló Validar Campo Busqueda" )

				.InformarProceso( "ValidarAutoCompletarGenerico" )	
				.ValidarAutoCompletarGenerico() 				&& chequea que los campos autocompletar tenga un dominio autocompletar
				.AgregarInformacionGeneral( "Falló Validar AutoCompletar" )

				.InformarProceso( "ValidarDominioExistenteenDiccionario" )	
				.ValidarDominioExistenteenDiccionario() 		&& chequea que los dominios en diccionario existan en dominio
				.AgregarInformacionGeneral( "Falló Validar Existencia de Dominio" )
				
				.InformarProceso( "ValidarCampoAdmiteBusqueda" )	
				.ValidarCampoAdmiteBusqueda()
				.AgregarInformacionGeneral( "Falló Validar Campo Admite Busqueda" )
		
				.InformarProceso( "ValidarCampoBusquedaOrden" )	
				.ValidarCampoBusquedaOrden()
				.AgregarInformacionGeneral( "Falló Validar Campo Busqueda Orden" )

				.InformarProceso( "ValidarMuestraRelacion" )	
				.ValidarMuestraRelacion()
				.AgregarInformacionGeneral( "Falló Validar Campo MuestraRelacion" )
				
				.InformarProceso( "ValidarMuestraRelacion" )	
				.ValidarClavePrimariaSinMemo()
				.AgregarInformacionGeneral( "Falló Validar Clave compuesta sin campos memo" )

				.ValidarCombosTabla()
				.AgregarInformacionGeneral( "Falló Validar Combos Tabla" )

				.ValidarClavesForaneasComoEntidad()
				.AgregarInformacionGeneral( "Falló Validar Las claves foráneas como entidad" )

				.ValidarMemosEnItems()
				.AgregarInformacionGeneral( "Falló Validar la inexistencia de campos Memo en Items" )

				.ValidarPalabrasReservadas()
				.AgregarInformacionGeneral( "Falló Validar palabras reservadas" )

				.ValidarAtributosReservados()
				.AgregarInformacionGeneral( "Falló Validar atributos reservados" )

				.ValidarCamposReservados()
				.AgregarInformacionGeneral( "Falló Validar campos reservados" )

				.ValidarTablaCampo()
				.AgregarInformacionGeneral( "Falló Validar congruencia de tablas y campos de las entidades" )

				.ValidarTablaCampovsClaveForanea()
				.AgregarInformacionGeneral( "Falló Validar congruencia de tablas y campos de subentidades contra las entidades" )

				.ValidarTipoDatoDominio()
				.AgregarInformacionGeneral( "Falló Validar Tipo de datos en dominio" )

				.ValidarTipoDatoDiccionario()
				.AgregarInformacionGeneral( "Falló Validar Tipo de datos en diccionario" )
				
				.ValidarMascara()
				.AgregarInformacionGeneral( "Falló Validar Máscaras en diccionario" )
				
				.ValidarClavePrimariaCompuestaConCamposMemos()
				.AgregarInformacionGeneral( "Falló Validar Claves Primarias Compuestas con campos Memos" )

				.ValidarAtributoAjustableEnDetalle()
				.AgregarInformacionGeneral( "Falló Validar Atributos Ajustables en Detalles" )

				.ValidarCamposNoMemoEnDetalle()
				.AgregarInformacionGeneral( "Falló Validar Campos No Memo en detalles" )

				.ValidarClavesPrimariasNoMemo()
				.AgregarInformacionGeneral( "Falló Validar Claves Primarias que no sean Memo" )

				.ValidarNomenclaturaDeItems()
				.AgregarInformacionGeneral( "Falló Validar Nomenclatura de Items" )

				.ValidarCantidadDeAtributosPorBloque()
				.AgregarInformacionGeneral( "Falló Validar Cantidad de Atributos por Bloque" )

				.ValidarDetallesRepetidosEnEntidad()
				.AgregarInformacionGeneral( "Falló Validar Detalles Repetidos En Entidad" )

				.ValidarModoSimple()
				.AgregarInformacionGeneral( "Falló Validar modo simple" )
				
				.ValidarSubEntidadConUnaSolaClavePrimaria()
				.AgregarInformacionGeneral( "Falló Validar subEntidad con una sola clave primaria" )

				.ValidarAdmiteBusquedaEnAtributoDetalle()
				.AgregarInformacionGeneral( "Falló Validar Admite Busqueda para atributos que son detalle" )

				.ValidarSeguridadEnEntidades()
				.AgregarInformacionGeneral( "Falló Validar Seguridad en Entidades" )			

				.ValidarSeguridadEntidadesDefault()
				.AgregarInformacionGeneral( "Falló Validar tabla SeguridadEntidadesDefault" )	
				
				.ValidarCamposDuplicadosIdEnMenuPrincipal()
				.AgregarInformacionGeneral( "Falló Validar tabla MenuPrincipal" )	
				
				.ValidarCamposDuplicadosIdEnMenuPrincipalItems()
				.AgregarInformacionGeneral( "Falló Validar tabla MenuPrincipalItems" )	
				
				.ValidarCamposDuplicadosIdPorEntidadEnMenuAltasItems()
				.AgregarInformacionGeneral( "Falló Validar Existencia de Campo ID+Entidad único en tabla MenuAltasItems" )	
				
				.ValidarCampoEntidadVacioEnMenuAltasItems()
				.AgregarInformacionGeneral( "Falló Validar tabla MenuAltasItems" )	

				.ValidarUnicidadDeVersionDeEntidades()
				.AgregarInformacionGeneral( "Falló Validar tabla Unicidad de Version de entidades." )	
				
				.ValidarDominioImagen()
				.AgregarInformacionGeneral( "Falló Validar Dominio Imagen." )	
						
				.ValidarDetallesNormalizadosV2()
				.AgregarInformacionGeneral( "Falló Validar Detalles desnormalizados." )	

				.ValidarIntegridadNodosDeParametros()
				.AgregarInformacionGeneral( "Falló Validar Integridad de Parámetros." )	
				
				.ValidarCamposTablaDeParametros()
				.AgregarInformacionGeneral( "Falló Validar Integridad de Campos de Tabla Parámetros." )	

				.ValidarCampoIdUnicoTablaDeParametros()
				.AgregarInformacionGeneral( "Falló Validar Existencia de Campo IdUnico de Tabla Parámetros." )	

				.ValidarCampoIdUnicoTablaDeRegistros()
				.AgregarInformacionGeneral( "Falló Validar Existencia de Campo IdUnico de Tabla Registros." )	

				.ValidarCampoIdUnicoTablaDeParametrosYRegistrosEspecificos()
				.AgregarInformacionGeneral( "Falló Validar Existencia de Campo IdUnico de Tabla Parámetros y Registros Específicos." )	

				.ValidarEspacios()
				.AgregarInformacionGeneral( "Falló Validar Espacios en la Entidad." )
				
				.ValidarCampoMemoEnBusqueda()
				.AgregarInformacionGeneral( "Falló Validar Campos Memo en búsqueda en el diccionario (Campo AdmiteBusqueda)." )
				
				.ValidarRelaNumeraciones()
				.AgregarInformacionGeneral( "Falló Validar existencia y consistencia de tipo de dato numérico en el Diccionario, para entidades con numeraciones." )
				
				.ValidarClavePrimariayForaneaEnAtributosDeDetalles()
				.AgregarInformacionGeneral( "Falló Validación de Claves Primaria y Foránea en Atributos de Detalles, en la tabla Diccionario." )
						
				.ValidarCampoObligatorioEnAtributoDetalle()
				.AgregarInformacionGeneral( "Falló Validación de Campos obligatorios en Atributos Detalle." )

				.ValidarEtiquetaCorta()
				.AgregarInformacionGeneral( "Falló Validación de la Etiqueta Corta" )

				.ValidarEtiquetaParaAtributosAuditables()
				.AgregarInformacionGeneral( "Falló Validación de la Etiqueta de atributos auditables" )

				.ValidarCamposDuplicadosEnMismaTabla()
				.AgregarInformacionGeneral( "Falló Validación de campos duplicados." )

				.ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios()
				.AgregarInformacionGeneral( "Falló Validación de Datos de Atributos Foraneos con los datos de Atributos Primarios" )

				.ValidarAtributosGenericos()
				.AgregarInformacionGeneral( "Falló Validación de atributos genericos" +  chr( 10 ) + chr( 13 ) + ;
										   "Deben coincidir los valores de los campos TipoDato, Longitud, Decimales, Campo " )
										   
				.ValidarCamposClaveForanea()
				.AgregarInformacionGeneral( "Falló Validación de atributos clave foranea" +  chr( 10 ) + chr( 13 ) + ;
										   "Debe cargar la clave foranea" )

				.ValidarClaveForaneaInvalidos()
				.AgregarInformacionGeneral( "Falló Validación de clave foranea invalida" +  chr( 10 ) + chr( 13 ) + ;
										   "No se encontro la entidad que contiene la clave foranea" )

				.ValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria()
				.AgregarInformacionGeneral( "Falló Validación de Entidades con CAI, no pueden tener talonarios asociados a claves candidatas y claves primarias al mismo tiempo" )

				.ValidarClaveDeBusqueda()
				.AgregarInformacionGeneral( "Falló Validación de Dominio Clave de Busqueda" )
				
				.ValidarUnicidadEnRelaNumeraciones()
				.AgregarInformacionGeneral( "Falló Validación de Unicidad de Numeraciones" )
				
				.ValidarTablaComprobantesYCampoComportamientoEnEntidades()
				.AgregarInformacionGeneral( "Falló Validación de Identificacion de Comprobantes" )
				
				.ValidarAtributosObligatoriosEnRecepcion()
				.AgregarInformacionGeneral( "Falló Validación de Atributos Obligatorios." )

				.ValidarCampoIdentificadorDeLaTablaEntidad()
				.AgregarInformacionGeneral( "Falló Validación de Existencia y Unicidad de Identificador de Entidades." )
				
				.ValidarFiltrosParaTransferenciasAgrupadas()
				.AgregarInformacionGeneral( "Falló Validación de Filtros Para Transferencias Agrupadas." )
				
				.ValidarEntidadAtributosTransferenciaAgrupada()
				.AgregarInformacionGeneral( "Falló Validación de Atributos y Entidades Para Transferencias Agrupadas." )
				 		
				.ValidarCamposVotacion()
				.AgregarInformacionGeneral( "Falló Validación de campos para votacion." )
														
				.ValidarAtributosUnicosEnEstetica()
				.AgregarInformacionGeneral( "Falló Validación de Atributos unicos con Estetica." )	

				.ValidarTieneSeguridadMenu()
				.AgregarInformacionGeneral( "Falló Validación de campo lTieneSeguridad en Menú." )	
				
				.ValidarUsoEntidadVersionV1()
				.AgregarInformacionGeneral( "Falló Validación de Entidad, No puede cargar Entidades V1." )

				.ValidarAdnAuditoria()
				.AgregarInformacionGeneral( "Falló Validación de Auditoria. No se puede auditar una entidad que no tiene atributos que auditar." )

				.ValidarTablasAuditoria()
				.AgregarInformacionGeneral( "Falló Validación de Auditoria. No puede haber tablas con el prefijo audi_." )
				
				.ValidarCampoComportamiento()
				.AgregarInformacionGeneral( "Falló Validación de Campo Comportamiento. No puede haber nuevos comportamientos en el mismo." )

				.ValidarItemsConAuditoria()
				.AgregarInformacionGeneral( "Falló Validación de Auditoria en Items. No puede agregar auditoria a Items." )
				
				.ValidarCampoFuncionalidades()
				.AgregarInformacionGeneral( "Falló Validación de campo Funcionalidades." )

				.ValidarLongitudNombreCampo()
				.AgregarInformacionGeneral( "Falló Validación de Longitud de Campos." )			

				.ValidarCantidadDeAutoincrementales()
				.AgregarInformacionGeneral( "Falló Validación de Autoincrementales." )			
				
				.ValidarFuncionalidadAnulable()
				.AgregarInformacionGeneral( "Falló Validación de Anulables." )	
					
				.ValidarOrdenNavegacion()
				.AgregarInformacionGeneral( "Falló Validación de Orden Navegacion." )	
				
				.ValidarNombresDeCamposClavePrimaria()
				.AgregarInformacionGeneral( "Falló Validación de nombres de campo de clave primaria para entidades con campos memo." )	

				.ValidarCaracteresEspeciales()
				.AgregarInformacionGeneral( "Falló Validación de Caracteres Reservados." )
				
				.ValidarEntidadEnBuscador()
				.AgregarInformacionGeneral( "Falló Validación de existencia de entidades en Buscador." )			

				.ValidarAtributoEnBuscador()
				.AgregarInformacionGeneral( "Falló Validación de existencia de atributos en Buscador." ) 			
							
				.ValidarIdBuscadorDetalleEnBuscador()
				.AgregarInformacionGeneral( "Falló Validación de Ids en DetllaBuscador para Buscador." )
							
				.ValidarClavePrimariaVisibles()
				.AgregarInformacionGeneral( "Falló Validación de entidades con claves foraneas no visibles(PK en otra Entidad)." )
				
				.ValidarAtributoObservacion()
				.AgregarInformacionGeneral( "Falló Validación de Entidades. Existen entidades sin el atributo Observación." )
				
				.ValidarClaveForaneEnFiltrosConBuscador()
				.AgregarInformacionGeneral( "Falló Validación de Atributos. Existen atributos sin Clave foranea." )

				.ValidarAtributosObligatoriosDeCalculoDePrecios()
				.AgregarInformacionGeneral( "Falló Validación de Atributos obligatorios para la entidad 'Cálculo de precios'." )

				.ValidarTags()
				.AgregarInformacionGeneral( "Falló Validación de tags." )

				if !inlist( This.cProyectoActivo, 'NUCLEO','GENERADORES','DIBUJANTE','ADNIMPLANT','ZUPDATE','ADNMANAGER','ZL','GENESIS','LINCEORGANIC' )
					.ValidarAtributosEnEquivalencia()
					.AgregarInformacionGeneral( "Falló Validación de atributos entre las entidades STOCKCOMBINACION y EQUIVALENCIA." )
				endif 

				.ValidarFuncionalidadImportacion()
				.AgregarInformacionGeneral( "Falló Validación de funcionalidad de importaciones." )
				
				.ValidarCopiaTablasEntreSucursales()
				.AgregarInformacionGeneral( "Falló Validación de funcionalidad de copia entre sucursales." )			
				
				.ValidarFuncionalidadEntidadNoEditableYBloquearRegistro()
				.AgregarInformacionGeneral( "Falló Validación de funcionalidad de bloqueo de registros y/o entidad no editable." )			
				
				.ValidarFuncionalidadFechaCAI()
				.AgregarInformacionGeneral( "Falló Validación de funcionalidad de CAI." )

				.ValidarOrdenEnDominioDireccion()			&& Chequear que el orden del Dominio Direccion sea Calle Numero Piso Departamento
				.AgregarInformacionGeneral( "Falló al Validar el Orden de los Atributos para el Dominio Direccion" )			
				
				.ValidarDominioParaCampoGUID()
				.AgregarInformacionGeneral( "Falló al Validar el dominio en atributos GUID." )
				
				.ValidarTablas_Compartidas_Por_Items_Y_Entidades()
				.AgregarInformacionGeneral( "Falló al Validar tablas compartidas por items y Entidades" )
				
				.ValidarNombreTablasConCampo()
				.AgregarInformacionGeneral( "Falló al Validar Diccionario existen campos con el mismo nombre que las tablas.")
			
				.ValidarEsquemasTablas()
				.AgregarInformacionGeneral( "Falló al Validar Diccionario existen tablas con Distintos esquemas.")
				
				.ValidarTablasInternasContraDiccionario()
				.AgregarInformacionGeneral( "Falló al Validar Diccionario hay tablas compartidas  con la tabla tablasinternas.")
				
				.ValidarDetallesObligatorios()
				.AgregarInformacionGeneral( "Falló al Validar Diccionario con detalles obligatorios.")
				
				.ValidarEntidadesAnulables()
				.AgregarInformacionGeneral( "Falló al Validar Entidades Anulables.")
				
				.InformarProceso( "oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia" )
				.oValidarAdnComponenteSenias.ValidarAtributosParaComponenteSenia()
				.AgregarInformacionGeneral( "Falló al Validar Atributos para el Componente Senia.")

				.InformarProceso( "oValidarAdnEntidadesConEdicionParcial.Validar" )
				.oValidarAdnEntidadesConEdicionParcial.Validar()
				.AgregarInformacionGeneral( "Falló al Validar Entidades con Edición Parcial.")

				.ValidarCodigoDeBarras()
				.AgregarInformacionGeneral( "Falló al Validar Código de Barras.")										

				.ValidarMenuTransferenciaDisenoImpresion()
				.AgregarInformacionGeneral( "Falló al Validar Menu DisenoImpresion." )														
				
				.ValidarFiltroTransferenciaDisenoImpresion()				
				.AgregarInformacionGeneral( "Falló al Validar Transferencias DisenoImpresion." )														

				.ValidarFormatoDescripcionEnComprobantes()				
				.AgregarInformacionGeneral( "Falló al Validar Formato Descripción en los Comprobantes" )
				
				.ValidarTransferencias()
				.AgregarInformacionGeneral( "Falló al Validar Transferencias" )
				
				.ValidarFiltrosTransferencias()
				.AgregarInformacionGeneral( "Falló al Validar Filtros de Transferencias" )
				
				.ValidarTipoDeValorCheque()
				.AgregarInformacionGeneral( "Falló la validación de TipoDeValores (CHEQUE) No debe permitir modificar las fechas" )

				.ValidarCampoCodigoEnCabeceraYDetalle()
				.AgregarInformacionGeneral( "Falló la validación de entidades con sus detalles." )				
				
				.ControlarExistenciasDeTablasConMasDeUnaClavePrimaria()
				.AgregarInformacionGeneral( "Falló la validación de normalización de las tablas." )
				
				.ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas()
				.AgregarInformacionGeneral( "Falló Validar accesos rapidos de Menu de Altas" )	
				
				.ValidarCampoInicialConSaltoDeCampo()
				.AgregarInformacionGeneral( "Falló Validar Campo inicial con salto de campo." )	

				.ValidarSaltosDeCampoFijosYConfigurables()
				.AgregarInformacionGeneral( "Falló al validar Saltos de campo fijos con funcionalidad SALTODECAMPO." )

				.ValidarSaltosDeCampoConfigurablesYGenHabilitar()
				.AgregarInformacionGeneral( "Falló al validar habilitación dinámica con funcionalidad SALTODECAMPO." )
				
				.ValidarSaltosDeCampoConfigurablesYCAbeceraDetalle()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO entre cabecera y detalles." )
				
				.ValidarSaltosDeCampoConfigurablesYDetalleCabecera()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO entre detalles y cabecera." )
				
				.ValidarSaltosDeCampoConfigurablesYDetalleAtributoObligatorio()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO de detalles y obligatorio." )
				
				.ValidarSaltosDeCampoConfigurablesYEtiquetas()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO y etiquetas." )
				
				.ValidarSaltosDeCampoConfigurablesYAlta()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO y Alta." )
				
				.ValidarSaltosDeCampoConfigurablesYDominiosInvalidos()
				.AgregarInformacionGeneral( "Falló al validar la funcionalidad SALTODECAMPO y Dominios." )

				.ValidarExpoImpoGenericas()
				.AgregarInformacionGeneral( "Falló la validación de las exportaciones/importaciones genericas." )
	
				.ValidarFiltrosTransferenciasSegunTipo()
				.AgregarInformacionGeneral( "Falló la validación de tipos de atributos en Fitrotransferencias." )

				.InformarProceso( "ValidarTablaParametrosYRegistrosEspecificos" )
				.ValidarTablaParametrosYRegistrosEspecificos()
				.AgregarInformacionGeneral( "Falló la validación de los parametros y registros especificos." )

				********************************************************************************************************
				***** no se pudo hacer porque hay entidades que son anulables y no debe tener la opcion en el menu *****
				********************************************************************************************************
				.ValidarConsistenciaDeEntidadesAnulablesYMenu()
				.AgregarInformacionGeneral( "Falló la validación de consistencia entre funcionalidad Anulable y menú Anulable." )

				.ValidarIntegridadEntreTablasEntidadDiccionario()
				.AgregarInformacionGeneral( "Falló la validación de integridad entre tablas entidad y diccionario" )
				
				.InformarProceso( "oValidarAdnComponenteTarjetaDeCredito.ValidarAtributosParaTarjetaDeCredito" )
				.oValidarAdnComponenteTarjetaDeCredito.ValidarAtributosParaTarjetaDeCredito()
				.AgregarInformacionGeneral( "Falló al Validar Atributos para el Componente Tarjeta De Credito.")

				.ValidarEntidadCalculoDePrecios()
				.AgregarInformacionGeneral( "Falló al Validar Atributos para la Entidad 'CalculoDePrecios'.")

				.ValidarEntidadesConAuditoriaCampoFormatoDescripcionNoVacio()
				.AgregarInformacionGeneral( "Falló al Validar TAG Auditoría en la tabla Entidad.")

				.ValidarHotKeysEnElMenuPrincipal()
				.AgregarInformacionGeneral( "Falló al Validar Hot Keys en el menu principal.")

				.InformarProceso( "ValidarHotKeysEnElMenuPrincipalItems" )
				.ValidarHotKeysEnElMenuPrincipalItems()
				.AgregarInformacionGeneral( "Falló al Validar Hot Keys en el menu principal items.")
				
				.ValidarComienzaGrupoEnMenuPrincipal()
				.AgregarInformacionGeneral( "Falló al Validar CominezaGrupo en el menu principal." )
				
				.ValidarNodosParametrosCliente()
				.AgregarInformacionGeneral( "Falló la validación de NodosParametrosCliente. IdNodoPadre inexistente como IdNodo.")

				.LongitudMinimaClienteNombre()
				.AgregarInformacionGeneral( "Falló la validación de Atributo Nombre de la entidad Cliente.")

				.ValidarTagsComprobantes()
				.AgregarInformacionGeneral( "Falló la validación de Tags para comprobantes.")
				
				.InformarProceso( "oValidarAdnCapitalizacionEtiquetas.Validar" )
				.oValidarAdnCapitalizacionEtiquetas.Validar()
				.AgregarInformacionGeneral( "Falló la validación de Capitalización de Etiquetas." )

				.ValidarOrtografiaEtiquetas()
				.AgregarInformacionGeneral( "Falló la validación de Ortografía de Etiquetas y Ayuda." )

				.ValidarDigitosEnTipoDatosNumericosEnDiccionario()
				.AgregarInformacionGeneral( "Falló Validación de Dígitos en Campo TipoDatos de Diccionario." )

				.ValidarGuidComoUltimoCampoEnElBuscador()
				.AgregarInformacionGeneral( "Falló la validación de Guid como ultimo campo en el buscador.")

				.InformarProceso( "oValidarAdnConLaConfiguracionBasica.Validar" )
				.oValidarAdnConLaConfiguracionBasica.Validar()
				.AgregarInformacionGeneral( "Falló al Validar la estructura de las tablas del ADN en relación a la Configuración Basica.")
				
				.ValidarAdmiteBusquedaEnAtributoSinAsociacionDeCampo()
				.AgregarInformacionGeneral( "Falló Validar Admite Busqueda para atributos que no están asociados a un campo de una tabla" )

				.ValidarEntidadConFuncionalidadGuardarComoEnToolbar()
				.AgregarInformacionGeneral( "Falló Validar la Entidad con Funcionalidad Guardar Como en la Toolbar" )
				
				.InformarProceso( "Validando seguridad comercial" )
				.oValidarAdnConSeguridadComercial.cCursorListados = this.cListados
				.oValidarAdnConSeguridadComercial.Validar()
				.AgregarInformacionGeneral( "Falló la validación de los módulos en el ADN.")
				
				.InformarProceso( "oValidarAdnCopiaDeDetalleso.Validar" )
				.oValidarAdnCopiaDeDetalles.Validar()
				.AgregarInformacionGeneral( "Falló la validación en la copia de detalles.")
				
				.InformarProceso( "ValidarSeguridadEnMenuPrincipal" )
				.ValidarSeguridadEnMenuPrincipal()
				.AgregarInformacionGeneral( "Falló al Validar la seguridad en el menu principal" )
				
				.InformarProceso( "ValidarFuncionalidadCodigoSugerido" )
				.ValidarFuncionalidadCodigoSugerido()
				.AgregarInformacionGeneral( "Falló validación de funcionalidad <CODIGOSUGERIDO>." )
				
				.InformarProceso( "ValidarComprobantesDeCompra" )
				.ValidarComprobantesDeCompra()
				.AgregarInformacionGeneral( "Falló al validar los comprobantes de COMPRA." )

				.ValidarIndividualidadDeTagDesactivableYAnulable()
				.AgregarInformacionGeneral( "Falló al validar las individualidad de las funcionalidades ANULABLE y DESACTIVABLE." )
				
				.ValidarQueEntidadDesactivableSeaAuditable()
				.AgregarInformacionGeneral( "Falló al validar las funcionalidades DESACTIVABLE y AUDITORIA." )
				
				.ValidarQueEntidadConAuditoriaTengaModulosListado()
				.AgregarInformacionGeneral( "Falló al validar las funcionalidades AUDITORIA y MODULOSLISTADO." )
				
				.InformarProceso( "ValidarRepeticionDeOrdenesVisualesEnDiccionario" )
				.ValidarRepeticionDeOrdenesVisualesEnDiccionario()
				.AgregarInformacionGeneral( "Falló al validar Repeticion de ordenes visuales en diccionario." )

				.ValidarRepeticionDeIdsEnParametros()
				.AgregarInformacionGeneral( "Falló al validar Repeticion de IDs en parametros." )

				.ValidarFechasEnCampoValorSugerido()
				.AgregarInformacionGeneral( "Falló al validar el valor sugerido de la entidad, debe obtener la fecha los servicios de Organic." )
				
				.ValidarHorasEnCampoValorSugerido()
				.AgregarInformacionGeneral( "Falló al validar el valor sugerido de la entidad, debe obtener la hora los servicios de Organic." )
								
				.ValidarQueUnItemDelMenuTengaBienCargadaLaReferenciaALaEntidadQueVaAVisualizar()
				.AgregarInformacionGeneral( "Falló al validar el valor sugerido de la entidad, debe obtener la hora los servicios de Organic." )

				.ValidarTagPromocionesPrincipal()
				.AgregarInformacionGeneral( "Falló al validar tag PromocionesPrincipal." )

				.ValidarTagPromociones()
				.AgregarInformacionGeneral( "Falló al validar tag Promociones." )

				.ValidarConsistenciaAtributosPromociones()
				.AgregarInformacionGeneral( "Falló al validar Consistencia Atributos Promociones." )

				.ValidarTagSoportaPrePantalla()
				.AgregarInformacionGeneral( "Falló al validar tag SoportaPrePantalla." )
				
				.ValidarLongitudClienteOrigenEnValeDeCambio()
				.AgregarInformacionGeneral( "Falló al validar el Cliente de Origen en VALEDECAMBIO." )
				
				.InformarProceso( "ValidarLongitudClienteDestinoEnValeDeCambio" )
				.ValidarLongitudClienteDestinoEnValeDeCambio()
				.AgregarInformacionGeneral( "Falló al validar el Cliente de Destino en VALEDECAMBIO." )

				.ValidarClavePrimariaEnITems()
				.AgregarInformacionGeneral( "Falló al validar ClavePrimariaEnItems." )

				.ValidarNombredeItems()
				.AgregarInformacionGeneral( "Falló al validar Nombre de Items." )
				
				.ValidarVisibilidadMuestraRelacion()
				.AgregarInformacionGeneral( "Falló al validar VisibilidadMuestraRelacion." )

				.ValidarIndice_SqlServer_SoloUnCluster()
				.AgregarInformacionGeneral( "Falló al validar indices cluster para SQL Server." )
				
				.ValidarIndice_SqlServer_IndicesDuplicados()
				.AgregarInformacionGeneral( "Falló al validar unicidad en nombre de indices para SQL Server." )
				
				.ValidarConsistenciaClavesCandidatas()
				.AgregarInformacionGeneral( "Falló al validar la consistencia de las claves candidatas." )
				
				.ValidarExistenciaEtiquetaEntidadesItem()
				.AgregarInformacionGeneral( "Falló al validar la existencia de la Etiqueta en las entidades Items." )
				
				.InformarProceso( "ValidarAdnMuestraRelacionYAtributoForaneoEnDetalles" )
				.ValidarAdnMuestraRelacionYAtributoForaneoEnDetalles()
				.AgregarInformacionGeneral( "Falló al validar la consistencia entre MUESTRARELACION y ATRIBUTOFORANEO en atributos de detalles (MUESTRARELACION se utliza para llenar valor en la grilla visual, ATRIBUTOFORANEO en item de entidad )." )
				
				*.InformarProceso( "ValidarFuncionalidadControlarFechaHoraEnRecepcion" )
				*.ValidarFuncionalidadControlarFechaHoraEnRecepcion()
				*.AgregarInformacionGeneral( "Falló Validación de Control de Fecha y Hora en Recepción." )	

				.InformarProceso( "oValidarAdnListadosOrganic.Validar" )
				this.bindearevento( .oValidarAdnListadosOrganic, "AgregarInformacionGeneralEvento", this, "AgregarInformacionGeneral" )
				.oValidarAdnListadosOrganic.Validar()
			
				.InformarProceso( "ValidarUnicidadDeEtiquetasEnCadaEntidad" )
				.ValidarUnicidadDeEtiquetasEnCadaEntidad()
				.AgregarInformacionGeneral( "Falló Validación de Control de Unicidad de las Etiquetas en cada Entidad." )	

				.InformarProceso( "ValidarUnicidadDeEtiquetaCortaEnCadaEntidad" )
				.ValidarUnicidadDeEtiquetaCortaEnCadaEntidad()
				.AgregarInformacionGeneral( "Falló Validación de Control de Unicidad de EtiquetaCorta en cada Entidad." )	

				.InformarProceso( "ValidarUnicidadDeEtiquetaAutodescriptivaEnCasaEntidad" )
				.ValidarUnicidadDeEtiquetaAutodescriptivaEnCasaEntidad()
				.AgregarInformacionGeneral( "Falló Validación de Control de Unicidad de EtiquetaAutodescriptiva en cada Entidad." )	
				
				.ValidarTagCopiaDesdeTxt()
				.AgregarInformacionGeneral( "Falló al validar tag CopiaDesdeTxt." )
				
				.InformarProceso( "ValidarIdDeConsultasNoCambien" )
				.ValidarIdDeConsultasNoCambien()
				.AgregarInformacionGeneral( "Falló al validar cambios en los ID de los buscadores (consultas)." )	
				
				.InformarProceso( "ValidarAtributosKitsYParticipantes" )
				.ValidarAtributosKitsYParticipantes()
				.AgregarInformacionGeneral( "Falló al validar atributos de kits." )	
							
				.InformarProceso( "ValidarItemKitsVsItemArticulosVentas" )
				.ValidarItemKitsVsItemArticulosVentas()
				.AgregarInformacionGeneral( "Falló al validar atributos de kits vs atributos de item articulos ventas." )				
				
				.InformarProceso( "ValidarVersionMinimaDeRecepcion" )
				.ValidarVersionMinimaDeRecepcion()		&& Chequear que se implemente un método si se agrega una versión mínima de recepción
				.AgregarInformacionGeneral( "Falló Validar VersionMinimaDeRecepcion de Entidades" )
				
				.InformarProceso( "ValidarTagListarConParaConsultasListados" )
				.ValidarTagListarConParaConsultasListados()
				.AgregarInformacionGeneral( "Falló Validación del tag <LISTARCON:>. No coinciden las estructuras de las tablas que se quiere unir." )

				.InformarProceso( "ValidarEntidadesRealTime" )
				.ValidarEntidadesRealTime()
				.AgregarInformacionGeneral( "Falló Validación del tag <REALTIME>" )
				
				.InformarProceso( "ValidarTag3DecimalesVirtualParaConsultasListados" )
				.ValidarTag3DecimalesVirtualParaConsultasListados()
				.AgregarInformacionGeneral( "Falló Validación del tag <3DECIMALESVIRTUAL> de la tabla LISTCAMPOS. El campo virtual a considerar no es numérico y no tiene decimales." )
				
					
			Endwith

			if This.HayInformacion()
				llRetorno = .f.
			endif
		finally
			this.CerrarAdnAdicional()
		endtry
	
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarEntidadesRealTime() as Void

		if inlist( This.cProyectoActivo, "COLORYTALLE" )
			
			&& Listado de entidades virtuales que no guardan info en las tablas
			select entidad, count(atributo) as atributos from diccionario where lower(atributo)<>"codigo" group by entidad into cursor temp1RealTime readwrite
			select entidad, count(atributo) as atributos from diccionario where lower(atributo)<>"codigo" and empty(tabla) group by entidad into cursor temp2RealTime readwrite
			select distinct upper(p.entidad) as entidad, "virtual"+space(73) as mensaje from temp1RealTime as p;
				left join temp2RealTime as v on p.entidad==v.entidad;
				where p.atributos=v.atributos;
				into cursor EntExcluidas readwrite
			
			&& Excluir entidades que comparten tablas con otra entidad pero que solo son de consulta no tienen la accion de ELIMINAR
			insert into EntExcluidas (entidad, mensaje) values ("STOCKARTICULOS", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("CLIENTERECOMENDANTE", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("CONDICIONDEPAGOENCOMPROBANTE", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("DIRECCIONENTREGAENCOMPROBANTE", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("EMAILENCOMPROBANTE", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("VENDEDORENCOMPROBANTE", "de consulta sin accion eliminar")
			insert into EntExcluidas (entidad, mensaje) values ("CAI", "de consulta sin accion eliminar")
			index on entidad	tag entidad
			
			&& Para saber con el paso del tiempo si el ADN ingresa una entidad nueva que comparte tabla un otra entidad existente
			&& Para que se tenga en cuenta de generar el trigger particular para la tabla que contempla cada caso de entidad
			&& GeneradorDinamicoTriggersRegistrodeBaja.prg

			&& tablas y cantidad de entidades que contienen
			create cursor CantEntidadesPorTabla (tabla C(80), cantidad N(3))
			insert into CantEntidadesPorTabla (tabla, cantidad) values ("ART",2)
			insert into CantEntidadesPorTabla (tabla, cantidad) values ("CLI",2)
			insert into CantEntidadesPorTabla (tabla, cantidad) values ("COMPRET",4) && tiene trigger particular
			insert into CantEntidadesPorTabla (tabla, cantidad) values ("COMPROBANTEV",30) && tiene trigger particular
			insert into CantEntidadesPorTabla (tabla, cantidad) values ("NUMERACIONES",2)
			
			select distinct upper(e.entidad) as entidad, upper(d.tabla) as tabla from entidad as e; 
				left join diccionario as d on upper(e.entidad)=upper(d.entidad);
				where left(upper(e.entidad),4)<>"ITEM" and !empty(d.tabla) and left(dominio,7)<>"DETALLE" and upper(d.atributo) <> "CODIGO"; 
				order by d.tabla,e.entidad;
				into cursor entitabl readwrite
			select tabla, count(*) as cantidad from entitabl group by tabla into cursor entitabl readwrite
			select e.tabla, t.cantidad as antes, e.cantidad as ahora from entitabl as e;
				left join CantEntidadesPorTabla as t on e.tabla=t.tabla;
			  where e.cantidad>1 and e.cantidad<>nvl(t.cantidad,0) into cursor entitabl readwrite
			select entitabl
			scan
				this.oInformacionIndividual.AgregarInformacion( "La tabla " + alltrim( tabla ) + " cambio la cantidad de entidades que la comparten antes: "+transform(antes)+" ahora: " + transform(ahora) + "deben estar contempladas las nuevas entidades en el trigger de realtime de dicha tabla" )
			endscan
			
			select distinct entidad from entidad where "<REALTIME>" $ funcionalidades into cursor EntRealTime readwrite
			scan
				if seek(entidad,"EntExcluidas","entidad")
					this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( entidad ) + " es " + alltrim( EntExcluidas.mensaje ) + ", no puede tener el TAG <REALTIME>" )
				endif
			endscan

			use in select( "temp1RealTime" )
			use in select( "temp2RealTime" )
			use in select( "EntExcluidas" )
			use in select( "CantEntidadesPorTabla" )
			use in select( "entitabl" )
			use in select( "EntRealTime" )

		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarAdnAdicional() as Void
		this.InformarProceso( "Cerrando tablas de ADN adicional" )
		this.CerrarCursor( this.cDiccionarioAdicional )
		this.CerrarCursor( this.cEntidadAdicional )
		this.CerrarCursor( this.cMenuAltasItemsCompleto )
		
		this.CerrarCursor( this.cListados )
		this.CerrarCursor( this.cListcampos )
		this.CerrarCursor( this.cNodosListados )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CerrarCursor( tcCursor ) as Void
		try
			if used( tcCursor )
				use in &tcCursor
			endif
		catch
		endtry
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function ValidarIntegridadEntreTablasEntidadDiccionario()as void
		local lcCursor as String 
		lcCursor = sys( 2015 )
		select distinct entidad from diccionario where upper( alltrim( entidad ) ) not in ( select upper( alltrim( entidad ) ) from entidad ) into cursor &lcCursor
		select(lcCursor)
		scan 
			this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..entidad ) + " se encuentra en la tabla diccionario pero no en entidad." )
		endscan
		
		select distinct entidad from entidad where upper( alltrim( entidad ) ) not in ( select upper( alltrim( entidad ) ) from diccionario ) into cursor &lcCursor
		select(lcCursor)
		scan 
			this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..entidad ) + " se encuentra en la tabla entidad pero no en diccionario." )
		endscan
		
		use in select( lcCursor )
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosObligatoriosEnRecepcion() as VOID

		select Entidad, atributo from diccionario where MantenerEnRecepcion and obligatorio into cursor c_AtributosObligatorios
		
		select c_AtributosObligatorios
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " +  alltrim( upper( c_AtributosObligatorios.Atributo ) ) + " de la entidad " + ;
								alltrim( upper( c_AtributosObligatorios.Entidad ) ) + " no puede ser obligatorio si se mantiene en la recepcion." )
		endscan
	
		use in select("c_AtributosObligatorios")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTablaComprobantesYCampoComportamientoEnEntidades() as VOID
	
		select Entidad ;
			from Entidad ;
			where !("X" $ Comportamiento) and ;
				alltrim(upper( Entidad )) in ( select alltrim( upper( Comprobantes.descripcion ) ) from comprobantes );
			into cursor c_TestEntidadesComprobantes

		select c_TestEntidadesComprobantes
		scan
			This.oInformacionIndividual.AgregarInformacion( "El Comprobante " +  alltrim( upper( c_TestEntidadesComprobantes.Entidad ) ) + " no esta correctamente seteado." )
		endscan
		
		use in select("c_TestEntidadesComprobantes")
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarSeguridadEntidadesDefault() as VOID

		select operacion from seguridadentidadesdefault where empty(descripcionoperacion) into cursor c_SeguridadEntidadesDefault
		
		if _tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Hay descripciones de operaciones vacías. Operación: " + ;
											Alltrim( c_SeguridadEntidadesDefault.operacion ) )
   			Endscan
		Endif		
		
		use in select( "c_SeguridadEntidadesDefault" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarUnicidadDeEntidades() as VOID
		
		Select entidad,Count(entidad) As Cantidad ;
			from entidad ;
			group By entidad ;
			having cantidad > 1 ;
			into Cursor Cur_Cantidad

		If _Tally > 0
			select Cur_Cantidad
			scan
				This.oInformacionIndividual.AgregarInformacion( "Hay entidades repetidas. Entidad: " + Alltrim( Cur_Cantidad.Entidad ) + ;
											", " +  Transform( Cur_Cantidad.Cantidad ) + " repeticiones." )
			Endscan
		endif
		
		Use In select( "Cur_Cantidad" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarClavePrimariaEnEntidad() As Object

		Select entidad ;
			From entidad ;
			where Upper( entidad ) Not In ( select Distinct Upper( entidad ) from diccionario 	where claveprimaria ) ;
			Group By entidad ;
			into Cursor Cur_ClavePrimaria

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Falta determinar la clave primaria " + ;
											"para la entidad " + Cur_ClavePrimaria.Entidad )
			Endscan
		endif

		select entidad, count(*) as cn ;
			from diccionario ;
			where clavePrimaria ;
			group by entidad ;
			having cn > 1 into cursor "Cur_ClavePrimaria"
		select ( "Cur_ClavePrimaria" )
		scan all
			This.oInformacionIndividual.AgregarInformacion( "Hay mas de una clave primaria en " + Cur_ClavePrimaria.Entidad )
		endscan
				
		Use In select( "Cur_ClavePrimaria" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarAtributosNoRepetidos() As VOID

		Local lcEntidad As String
		
		Select Distinct entidad From Entidad Into Cursor cur_Entidad
		select upper(Entidad) as Entidad, upper(atributo) as atributo from  diccionario into cursor cCurDiccionario
		
		Select cur_Entidad
		Scan
			lcEntidad = Alltrim( Entidad )

			Select atributo, Count(atributo) As Cantidad;
				from cCurDiccionario ;
				where alltrim(Upper( entidad )) == alltrim(Upper( lcEntidad )) ;
				group By atributo ;
				order By atributo ;
				having cantidad > 1 ;
				into Cursor Cur_Atributo

			If _Tally > 0
				Local lcAtributos As String, lcAtributo As String
				Store "" To lcAtributos
				release laAtributos
				Copy To Array laAtributos Fields Cur_Atributo.Atributo ALL
				For Each lcAtributo In laAtributos
					lcAtributos = lcAtributos + Alltrim( lcAtributo ) + ", "
				Endfor
				lcAtributos = Left( lcAtributos, Len( lcAtributos ) - 2 )
				This.oInformacionIndividual.AgregarInformacion( "Hay atributos repetidos en la entidad " + lcEntidad +;
											". Atributos: " + lcAtributos + "." )
			Endif
			Use In select( "Cur_Atributo" )
			
		Endscan

		use in select( "cCurDiccionario" ) 
		Use In select( "cur_Entidad" )

	Endfunc


	*-----------------------------------------------------------------------------------------
	Function ValidarTipodatoLongitudDecimalesEtiqueta() As VOID

		Select	di.entidad, di.atributo, di.tipodato, di.longitud, ;
			di.decimales, di.etiqueta, di.dominio, Do.tipodato As TipoDatoDom, ;
			do.etiqueta As EtiquetaDom, Do.longitud As LongitudDom, ;
			do.decimales As DecimalesDom ;
			from diccionario di inner Join dominio Do;
			on Alltrim( Upper( Do.dominio ) ) == Alltrim( Upper( di.dominio ) ) ;
			where 	!do.detalle and ( ;
				( Empty( di.tipodato )	And Empty( Do.tipodato ) )					Or ;
				( Di.tipodato != "M" and di.longitud  = 0 And Do.longitud   = 0 ) 	Or ;
				( ( ( !empty( di.tipodato ) and  di.tipodato != "N" ) 	Or ;
					( !empty( do.tipodato ) and  Do.tipodato != "N" ) ) And ;
					( di.decimales > 0 or Do.decimales > 0 ) ) ) ;
			into Cursor Cur_Datos

		If _Tally > 0
			select Cur_Datos
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Faltan datos ( Tipo de dato / Longitud / Decimales ) para el atributo " + ;
											Alltrim( Cur_Datos.Atributo ) + " de la entidad " + Alltrim( Cur_Datos.Entidad ) )
			Endscan
		endif
		
		Use In select( "Cur_Datos" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDominioEnDiccionario() As VOID

		Select entidad,atributo,dominio ;
			from diccionario ;
			where Empty(dominio) ;
			into Cursor cur_Dominio

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Falta completar Comportamiento para el atributo " + ;
											Alltrim( cur_Dominio.Atributo ) + " de la entidad " + Alltrim(cur_Dominio.Entidad ) )
			Endscan
		Endif

		Use In select( "cur_Dominio" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarValorSubgrupo() As VOID

		Select entidad,atributo,tiposubgrupo ;
			from diccionario ;
			where !Between( tiposubgrupo, 1, 3 ) and alta;
			into Cursor Cur_TipoSubgrupo

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Tipo de subgrupo inválido" + ;
											" en el atributo " + Alltrim(Cur_TipoSubgrupo.Atributo) + ;
											" de la entidad " + Alltrim(Cur_TipoSubgrupo.Entidad))
			Endscan
		Endif

		Use In select( "Cur_TipoSubgrupo" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarTiposSubgrupo() As VOID

		Select grupo,subgrupo,Count( Distinct tiposubgrupo ) As Cantidad, Entidad ;
			from diccionario ;
			where alta ;
			group By Entidad,grupo,subgrupo ;
			having cantidad > 1 ;
			into Cursor Cur_Descripcion

		If _Tally > 0
			scan
				This.oInformacionIndividual.AgregarInformacion( "Los atributos de la entidad " + alltrim( proper( Entidad ) ) + ;
											" pertenecientes al SubGrupo " + transform( subgrupo ) + " del Grupo " + ;
											transform( grupo ) + " deben tener el mismo Tipo de Subgrupo." )
			endscan
		endif
		
		Use In select( "Cur_Descripcion" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarAtributosVacios() As VOID

		Local lcEntidad As String

		Select atributo, entidad ;
			from diccionario ;
			where Empty( atributo ) ;
			into Cursor Cur_Atributos

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "Existen atributos vacíos en las siguientes entidades: " + ;
										This.ObtenerEntidadesConProblemas( "Cur_Atributos" ) + "." )
		Endif

		Use In select( "Cur_Atributos" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarAtributosSinDominio() As VOID

		Select atributo, dominio, entidad ;
			from diccionario ;
			where !Empty( atributo ) ;
			and Empty( dominio ) ;
			into Cursor Cur_Atributos

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "Existen atributos sin Dominio las siguientes entidades: " + ;
										This.ObtenerEntidadesConProblemas( "Cur_Atributos" ) + "." )
		Endif

		Use In select( "Cur_Atributos" )
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarAyudaEnFormularios() As VOID

		Select Di.entidad, Di.atributo, Di.alta, Di.ayuda ;
			from diccionario Di, dominio Do;
			where Alltrim( Upper( Di.Dominio ) ) == Alltrim( Upper( Do.Dominio ) ) And ;
				!Do.Detalle And ;
				Di.alta And ;
				Empty( Di.ayuda ) ;
			into Cursor Cur_Atributos

		If _Tally > 0
			select Cur_Atributos
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Falta la ayuda en el atributo " + Alltrim(Cur_Atributos.Atributo) + ;
											" (visible), de la entidad " + Alltrim(Cur_Atributos.Entidad))
			Endscan

		Endif

		Use In select( "Cur_Atributos" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDominioCodigo() As VOID

		Select entidad, atributo, dominio, claveprimaria, claveforanea ;
			from diccionario ;
			where Upper( alltrim( dominio ) ) == "CODIGO" And ;
				( !claveprimaria and empty( claveforanea ) or claveprimaria and !empty( claveforanea ) );
			into Cursor Cur_Dominio

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + Alltrim( Cur_Dominio.Atributo ) + ;
											" de la entidad " + Alltrim( Cur_Dominio.Entidad ) + " tiene comportamiento CODIGO " + ;
											" y no esta definido como Clave Primaria o como SubEntidad" )
			Endscan
		endif
		
		*-- Validacion de busqueda
		Select entidad, atributo, dominio, claveprimaria, claveforanea ;
			from diccionario ;
			where upper( alltrim( TipoDato ) ) == "N" and ;
					Alta and ;
					upper( alltrim( Dominio ) ) == "CODIGO" and ;
					ClavePrimaria and ;
					BusquedaOrdenamiento;
			into Cursor Cur_Dominio

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Para que el atributo " + upper( Alltrim( Cur_Dominio.Atributo ) ) + ;
											" de la entidad " + upper( Alltrim( Cur_Dominio.Entidad ) ) + " tenga comportamiento CODIGO y busqueda, " + ;
											"el tipo de dato del mismo no debe ser numerico." )

			Endscan
		endif
		
		
		Use In select( "Cur_Dominio" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function validarImagenConRutaDinamica() As VOID

		Select entidad, atributo, dominio, admitebusqueda ;
			from diccionario ;
			where Upper( alltrim( dominio ) ) == "IMAGENCONRUTADINAMICA" and empty( admitebusqueda  ) ;
			into Cursor Cur_Dominio

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + Alltrim( Cur_Dominio.Atributo ) + ;
											" de la entidad " + Alltrim( Cur_Dominio.Entidad ) + " tiene dominio IMAGENCONRUTADINAMICA" + ;
											" y no tiene cargado el campo Admite Busqueda" )
			Endscan
		endif
		
		Use In select( "Cur_Dominio" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDominioImagen() As VOID
		if !inlist( This.cProyectoActivo, "DIBUJANTE" )
			Select entidad, atributo, dominio, admitebusqueda ;
				from diccionario ;
				where Upper( alltrim( dominio ) ) == "IMAGEN" ;
				into Cursor Cur_Dominio
			If _Tally > 0
				Scan
					This.oInformacionIndividual.AgregarInformacion( "El atributo " + Alltrim( Cur_Dominio.Atributo ) + ;
												" de la entidad " + Alltrim( Cur_Dominio.Entidad ) + " tiene dominio IMAGEN" + ;
												" y este fue reemplazado por IMAGENCONRUTADINAMICA." )
				Endscan
			endif
			Use In select( "Cur_Dominio" )
		ENDIF
		this.validarImagenConRutaDinamica()
	Endfunc
	*-----------------------------------------------------------------------------------------
	Function ValidarComposicionDeBloques() As VOID

		Select	di.entidad, di.dominio , di.grupo, Count(  di.subgrupo ) As Cantidad ;
			from diccionario di inner Join dominio Do on Upper( alltrim( di.dominio ) ) == Upper( alltrim( Do.dominio ) ) ;
			where Do.esBloque and di.alta ;
			group By di.entidad, di.dominio, di.grupo, di.subgrupo ;
			into Cursor c_duplicados
		
		select entidad, dominio, count( dist cantidad ) as canti ;
			from c_duplicados ;
			group by entidad, dominio ;
			having canti > 1 ;
			into cursor Cur_Bloques

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "El Comportamiento " + Alltrim( Cur_Bloques.Dominio ) + ;
											" genera conflictos en la entidad " + Alltrim( Cur_Bloques.Entidad ) + "." )
			Endscan

		Endif

		Use In select( "c_duplicados" )
		Use In select( "Cur_Bloques" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	*-- VPAREDES: Dividir en otras validaciones internas
	function ValidarCantidadDeAtributosPorBloque() as VOID
	
		Local lcEntidad As String, lnCantidadAtributos as Integer
		lnCantidadAtributos = 0

		select entidad,Grupo, SubGrupo, count( atributo ) as cantidad, dominio.dominio ;
			from diccionario inner join dominio ;
			on upper( diccionario.dominio )   = upper( dominio.dominio);
			where dominio.esbloque ;
			group by entidad,Grupo, SubGrupo,dominio.dominio ;
			order by entidad,Grupo, SubGrupo,dominio.dominio ;
			into cursor c_bloques
		
		If _Tally > 0
			scan
				do case
					case alltrim( upper( dominio ) ) == "CLAVECANDIDATA"
						lnCantidadAtributos = 0
						if cantidad <= lnCantidadAtributos
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " )
						endif
						
					case alltrim( upper( dominio ) ) == "CODIGOCLIENTECOMPROBANTE"			
						lnCantidadAtributos = 2
						if cantidad != lnCantidadAtributos 						
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + ;
														" Grupo " + transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + ;
														" tiene el dominio " + Alltrim(c_bloques.dominio) + " con " + ;
														alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						Endif	

					case alltrim( upper( dominio ) ) == "DESCUENTO"			
						lnCantidadAtributos = 2
						if cantidad = lnCantidadAtributos 						
						else
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						endif

					case alltrim( upper( dominio ) ) == "DIRECCION"			
						lnCantidadAtributos = 4
						if cantidad = lnCantidadAtributos 						
						else
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						Endif							
						
					case alltrim( upper( dominio ) ) == "NUMEROCOMPROBANTE"			
						lnCantidadAtributos = 3
						if cantidad = lnCantidadAtributos
						else				
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						Endif							

					case alltrim( upper( dominio ) ) == "NUMEROINTERNO"
						lnCantidadAtributos = 2
						if cantidad = lnCantidadAtributos
						else				
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						Endif							

					case alltrim( upper( dominio ) ) == "NUMEROCOMPROBANTESINSUGERIR"			
						lnCantidadAtributos = 3
						if cantidad = lnCantidadAtributos 						
						else
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						Endif							
						
					case alltrim( upper( dominio ) ) == "TIPOIVA"			
						lnCantidadAtributos = 2
						if cantidad = lnCantidadAtributos 						
						else
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
														" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						endif
						
					case alltrim( upper( dominio ) ) == "COMPROBANTEEDICION"
						lnCantidadAtributos = 4
						if cantidad = lnCantidadAtributos
						else
							This.oInformacionIndividual.AgregarInformacion( "La entidad " + Alltrim(c_bloques.entidad) + " Grupo " + ;
														transform( Grupo ) + " SubGrupo " + transform( SubGrupo ) + " tiene el dominio " + ;
														Alltrim(c_bloques.dominio) + " con " + alltrim( str( cantidad ) ) + " atributos. " + ;
													" Corresponden " + alltrim( str( lnCantidadAtributos ) ) + "." )
						endif
						
				endcase	
			Endscan
		Endif

		Use In select( "c_bloques" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionGrupo( tcEntidad As String, tcDescripcion As String, tnGrupo As Integer ) as VOID
		Local laAtributos

		If Vartype( tcEntidad ) # "C" Or Vartype( tcDescripcion ) # "C" Or Vartype( tnGrupo ) # "N"
			Assert .F. Message "Cantidad o tipo de parámetros inválidos"
		Endif

		Dimension laAtributos[ 1 ]

		tcDescripcion = Alltrim( Upper( tcDescripcion ) )
		tcEntidad = Alltrim( Upper( tcEntidad ) )

		Select DescripcionGrupo From Diccionario ;
			where !( Alltrim( Upper( Diccionario.DescripcionGrupo ) ) == tcDescripcion ) And ;
			alltrim( Upper( Diccionario.Entidad ) ) == tcEntidad And ;
			Grupo == tnGrupo And ;
			Alta ;
			into Array laAtributos &&Se debe negar el == para que el distinto sea EXACTO (# No tiene en cuenta el SET EXACT)

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "El grupo " + Alltrim( Str( tnGrupo ) ) + ;
										" debe poseer la descripción: " + Alltrim( laAtributos[ 1 ] ) + ".")
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionSubGrupo( tcEntidad As String, tcDescripcion As String, tnGrupo As Integer, tnSubGrupo As Integer ) as VOID
		Local laAtributos
		Dimension laAtributos[ 1 ]
		
		If Vartype( tcEntidad ) # "C" Or Vartype( tcDescripcion ) # "C" Or Vartype( tnGrupo ) # "N" Or ;
				vartype( tnSubGrupo ) # "N"

			Assert .F. Message "Cantidad o tipo de parámetros inválidos"
		Endif

		tcDescripcion = Alltrim( Upper( tcDescripcion ) )
		tcEntidad = Alltrim( Upper( tcEntidad ) )

		Select DescripcionSubGrupo From Diccionario ;
			where !( Alltrim( Upper( Diccionario.DescripcionSubGrupo ) ) == tcDescripcion ) And ;
			alltrim( Upper( Diccionario.Entidad ) ) == tcEntidad And ;
			Diccionario.Grupo == tnGrupo And ;
			Diccionario.SubGrupo == tnSubGrupo And ;
			Alta ;
			into Array laAtributos

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "El subgrupo " + Alltrim( Str( tnSubGrupo ) ) + ;
										" (perteneciente al Grupo " + Alltrim( Str( tnGrupo ) ) + ") " + ;
										" debe poseer la descripción: " + Alltrim( laAtributos[ 1 ] ) + ".")
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarTipoSubGrupo( tcEntidad As String, tnGrupo As Integer, tnSubGrupo As Integer, tnTipoSubGrupo As Integer, taDescripcionTipo ) As VOID

		Local laAtributos, lcTipoBuscado As String, lnTipoObtenido As Integer

		External Array taDescripcionTipo
		If Vartype( tcEntidad ) # "C" Or Vartype( tnGrupo ) # "N" Or Vartype( tnSubGrupo ) # "N" Or ;
				vartype( tnTipoSubGrupo ) # "N" Or Vartype( taDescripcionTipo ) # "C" Or ;
				alen( taDescripcionTipo ) < 3

			Assert .F. Message "Cantidad o tipo de parámetros inválidos"
		Endif

		Dimension laAtributos[ 1 ]
		lcTipoObtenido = ""
		tcEntidad = Alltrim( Upper( tcEntidad ) )
		
		Select TipoSubGrupo From Diccionario ;
			where Diccionario.TipoSubGrupo # tnTipoSubGrupo And ;
			alltrim( Upper( Diccionario.Entidad ) ) == tcEntidad And ;
			Diccionario.Grupo == tnGrupo And ;
			Diccionario.SubGrupo == tnSubGrupo And ;
			Alta ;
			into Array laAtributos

		If _Tally > 0
			lnTipoObtenido = laAtributos[ 1 ]
			If Between( lnTipoObtenido, 1, Alen( taDescripcionTipo ) )
				lcTipoObtenido = taDescripcionTipo[ lnTipoObtenido ]
			Endif
			If Empty( lcTipoObtenido )
				This.oInformacionIndividual.AgregarInformacion( "El subgrupo " + Alltrim( Str( tnSubGrupo ) ) + ;
											" (perteneciente al Grupo " + Alltrim( Str( tnGrupo ) ) + ") " + ;
											" debe poseer el tipo: " + Alltrim( Str( lnTipoObtenido ) ) + ".")
			Else
				This.oInformacionIndividual.AgregarInformacion( "El subgrupo " + Alltrim( Str( tnSubGrupo ) ) + ;
											" (perteneciente al Grupo " + Alltrim( Str( tnGrupo ) ) + ") " + ;
											" debe poseer el tipo: " + Alltrim( lcTipoObtenido ) + ".")
			Endif
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarTituloMenuNoRepetido( tcNivelMenu As String, tcTitulo As String, tlCabecera As Boolean ) as VOID
		Local laMenues
		Dimension laMenues[1]
		
		If tlCabecera
			Select cNivelMenu ;
				from Menu ;
				where Upper( Alltrim( cTitulo ) ) = Upper( Alltrim( tcTitulo ) ) And ;
				len( Alltrim( cNivelMenu ) ) = 1 ;
				into Array laMenues
		Else
			Select cNivelMenu ;
				from Menu ;
				where Upper( Alltrim( cNivelMenu ) )== Upper( Alltrim( tcNivelMenu ) ) And ;
				upper( Alltrim( cTitulo ) ) = Upper( Alltrim( tcTitulo ) );
				into Array laMenues
		Endif

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "El título " + Proper( Alltrim( tcTitulo ) ) + " ya existe." )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarSeguridadEnEntidades() As VOID
		local lcNombreCursor as String 
		lcNombreCursor = sys( 2015 )
			
		select operacion ;
			from seguridadentidades ;
			where occurs( " ", alltrim( operacion ) ) > 0 ;
			into cursor ( lcNombreCursor )

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "Existen Nombres de Operaciones no permitidos en la tabla SeguridadEntidades.dbf" )
		endif
		
		Use In Select( lcNombreCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarTitulosMenuNoRepetidos_Hijos() As VOID

		Local lcCabecera As String, lcTitulo As String

		Select Distinct cNivelMenu, cTitulo From Menu Where Len( Alltrim( cNivelMenu ) ) = 1 Into Cursor c_Cabeceras

		Select c_Cabeceras
		Scan
			lcCabecera = Alltrim( cNivelMenu )
			lcTitulo = Alltrim( cTitulo )

			Select cTitulo, Count( cTitulo ) As Cantidad;
				from Menu ;
				where Left( Upper( Alltrim( cNivelMenu ) ), 1 ) = Upper( lcCabecera ) And ;
				len( Alltrim( cNivelMenu ) ) > 1 ;
				group By cTitulo ;
				order By cTitulo ;
				having cantidad > 1 ;
				into Cursor c_Opciones

			If _Tally > 0
				This.oInformacionIndividual.AgregarInformacion( "Existen opciones de menú repetida para la cabecera " + lcTitulo )
			Endif
			Use In Select( "c_Opciones" )
		Endscan

		Use In Select( "c_Cabeceras" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarTitulosMenuNoRepetidos_Cabecera() As VOID

		Local lcCabecera As String

		Select cTitulo, Count( cTitulo ) As Cantidad;
			from Menu ;
			where Len( Alltrim( cNivelMenu ) ) = 1 ;
			group By cTitulo ;
			order By cTitulo ;
			having cantidad > 1 ;
			into Cursor c_Opciones

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "Existen cabeceras con el título repetido." )
		Endif

		Use In Select( "c_Opciones" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarAccesoDirectos( tcAcceso As String ) As VOID
		Local laMenues

		Dimension laMenues[1]
		Select cAcceRapido ;
			from Menu ;
			where Upper( Alltrim( cAcceRapido ) ) == Upper( Alltrim( tcAcceso ) ) ;
			into Array laMenues

		If _Tally > 0
			This.oInformacionIndividual.AgregarInformacion( "El Acceso " + Proper( Alltrim( tcAcceso ) ) + " ya existe." )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarAccesosDirectos() As VOID
		Local lnAccesos As Integer, laMenues
		Dimension laMenues[1]
		
		Select cAccRapido ;
			From Menu ;
			Where !Empty( cAccRapido ) ;
			Into Array laMenues
			
		lnAccesos = _Tally
		Select Distinct cAccRapido From Menu Where !Empty( cAccRapido ) Into Array laMenues

		If _Tally = lnAccesos
		else
			This.oInformacionIndividual.AgregarInformacion( "Existen accesos rápidos repetidos." )
		Endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarControlesEstilos() As VOID
		Local lnAccesos As Integer, laMenues

		Select Controles.Descripcion As Control , Estilos.Descripcion As Estilo ;
			from Controles, Estilos ;
			where Str( Controles.Id ) + Str( Estilos.Id ) Not In ;
			( Select Str( IdControl ) + Str( IdEstilo ) From Propiedades ) ;
			into Cursor cNoExisten nofilter

		Select cNoExisten
		Scan All
			This.oInformacionIndividual.AgregarInformacion( "No Existe el Estilo " + Alltrim( cNoExisten.Estilo ) + ;
										" para el control " + Alltrim( cNoExisten.Control ) )
		Endscan
		
		use in select( "c_ControlesEstilos" )
		use in select( "cNoExisten" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionesGrupo() As VOID
		local lcTextoProblema As String, lcTextoAtributos As String

		lcTextoProblema		= ""
		lcTextoAtributos	= ""

		Select Distinct Entidad, Grupo, DescripcionGrupo ;
			from Diccionario where alta;
			into Cursor cVer1 nofilter

		Select Entidad, Grupo, Count( * ) As Cant ;
			from cVer1 ;
			into Cursor cVer2 nofilter ;
			group By Entidad, Grupo ;
			having Cant > 1 ;
			order By 1, 2

		Select d.Entidad,  d.Grupo, d.Atributo ;
			from Diccionario d inner Join cVer2 c ;
			on	d.Entidad	= c.Entidad And ;
			d.Grupo		= c.Grupo ;
			into Cursor cVer3 nofilter ;
			order By 1, 2, 3

		If Reccount( "cVer3" ) > 0
			Select cVer2
			Scan All
				lcTextoProblema =	"Para la entidad " + Alltrim( cVer2.Entidad ) + ;
									" los atributos del grupo " + Transform( cVer2.Grupo ) + ;
									" difieren en sus descripciones. " &&+ chr( 13 )
				lcTextoAtributos = 	"Atributos: "
				
				Select cVer3
				Scan All For Entidad = cVer2.Entidad And Grupo = cVer2.Grupo
					lcTextoAtributos = lcTextoAtributos + " " + Alltrim( cVer3.Atributo ) + ","
					Select cVer3
				endscan
				
				lcTextoAtributos = Substr( lcTextoAtributos, 1, Len( lcTextoAtributos ) - 1 ) + "."
				This.oInformacionIndividual.AgregarInformacion( lcTextoProblema + lcTextoAtributos )
			Endscan
		Endif

		use in select( "cVer1" )
		use in select( "cVer2" )
		use in select( "cVer3" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionesSubGrupo() As VOID
		local lcTextoProblema As String, lcTextoAtributos As String

		lcTextoProblema		= ""
		lcTextoAtributos	= ""

		Select Distinct Entidad, Grupo, SubGrupo, DescripcionSubGrupo ;
			from Diccionario where alta;
			into Cursor cVer1 nofilter

		Select Entidad, Grupo, SubGrupo, Count( * ) As Cant ;
			from cVer1 ;
			into Cursor cVer2 nofilter ;
			group By Entidad, Grupo, SubGrupo ;
			having Cant > 1 ;
			order By 1, 2, 3

		Select d.Entidad,  d.Grupo, d.Subgrupo, d.Atributo ;
			from Diccionario d inner Join cVer2 c ;
			on	d.Entidad	= c.Entidad And ;
			d.Grupo		= c.Grupo And ;
			d.SubGrupo	= c.SubGrupo ;
			into Cursor cVer3 nofilter ;
			order By 1, 2, 3, 4

		If Reccount( "cVer3" ) > 0
			Select cVer2
			Scan All
				lcTextoProblema =	"Para la entidad " + Alltrim( cVer2.Entidad ) + ;
									" los atributos del grupo " + Transform( cVer2.Grupo ) + " SubGrupo " + Transform( cVer2.Subgrupo ) + ;
									" difieren en sus descripciones. " &&+ chr( 13 )
				lcTextoAtributos = 	"Atributos: "

				Select cVer3
				Scan All For Entidad = cVer2.Entidad And Grupo = cVer2.Grupo And SubGrupo = cVer2.SubGrupo
					lcTextoAtributos = lcTextoAtributos + " " + Alltrim( cVer3.Atributo ) + ","
					Select cVer3
				Endscan

				lcTextoAtributos = Substr( lcTextoAtributos, 1, Len( lcTextoAtributos ) - 1 ) + "."
				This.oInformacionIndividual.AgregarInformacion( lcTextoProblema + lcTextoAtributos )
			Endscan
		Endif

		use in select( "cVer1" )
		use in select( "cVer2" )
		use in select( "cVer3" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarLargoTablaMemo( tcTabla As String, tcAtributo As String, tcEntidad as String ) As VOID
		Local lnEstructuraTablas As Integer, lnParametros As Integer

		If Empty( tcTabla ) Or Empty( tcAtributo ) or Empty( tcEntidad )
		Else
			lnEstructuraTablas	= Len( EstructuraTablas.Tabla )
			lnParametros		= Len( Alltrim( tcTabla ) + Alltrim( tcAtributo ) )

			If lnEstructuraTablas < lnParametros
				This.oInformacionIndividual.AgregarInformacion(	"La cantidad de caracteres del nombre de la tabla más" + ;
											" el nombre del atributo no puede ser mayor a " + Transform( lnEstructuraTablas ) + ;
											" ( Actual = " + Transform( lnParametros ) + " ) para la Entidad " + alltrim( tcEntidad ) )
			Endif
		Endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarLargoTablaMemoGenerico() as VOID
		Select Entidad, Atributo, Tabla ;
			from Diccionario ;
			where	Alltrim( TipoDato ) == "M" ;
			into Cursor cVer nofilter

		Select cVer
		Scan
			this.ValidarLargoTablaMemo( cVer.Tabla, cVer.Atributo, cVer.Entidad )
		endscan
		
		use in select( "cVer" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarSumarizar( tcTipoDato As String ) as VOID
		If Alltrim( tcTipoDato ) == "N"
		Else
			This.oInformacionIndividual.AgregarInformacion( "Para que el atributo sea sumarizable el tipo de dato debe ser Numérico" )
		Endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarSumarizarGenerico() As VOID

		Select d1.Entidad, d1.Atributo, d1.TipoDato, d1.Dominio, d1.Sumarizar, d2.TipoDato as TipoDatoSum ;
			from Diccionario d1 ;
			left join diccionario d2 on upper( alltrim( d1.sumarizar ) ) = upper( alltrim( d2.atributo ) )and d1.entidad = d2.entidad ;
			where !Empty( d1.Sumarizar ) ;		
			into Cursor cVer nofilter

		Select cVer
		Scan All
			with This.oInformacionIndividual
				This.ValidarSumarizar( cVer.TipoDatoSum )
				If .Count > 0
					.AgregarInformacion( "Error al validar sumarizar para entidad " + Alltrim( cVer.Entidad ) + ;
										" Atributo " + Alltrim( cVer.Atributo ) + " Atributo a sumarizar " + Alltrim( cVer.Sumarizar ) )
				Endif
				If isnull( TipoDatoSum )
					.AgregarInformacion( "Error al validar sumarizar para entidad " + Alltrim( cVer.Entidad ) + ;
										" Atributo " + Alltrim( cVer.Atributo ) + ". No existe el atributo Sumarizado " + cVer.Sumarizar )
				endif
			endwith			
		Endscan

		use in select( "cVer" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionEntidad( tcDescripcion ) As VOID
		If Empty( tcDescripcion )
			This.oInformacionIndividual.AgregarInformacion( "Debe ingresar una descpripción de Entidad" )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarEntidad( tcEntidad ) As VOID
			

		If Empty( tcEntidad )
			This.oInformacionIndividual.AgregarInformacion( "No se puede dejar el nombre de la entidad en blanco." )
		Else
			If " " $ Alltrim( tcEntidad )
				This.oInformacionIndividual.AgregarInformacion( "El nombre de la Entidad no puede contener espacios" )
			endif

			If This.oLibrerias.ValidarCaracteres( tcEntidad, .T., This.ObtenerCaracteresValidosNombreEntidad() )
			Else
				This.oInformacionIndividual.AgregarInformacion( "Caracteres invalidos en el nombre de la entidad" )
			endif
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCaracteresValidosNombreEntidad( tcEntidad as String ) as Boolean
		return This.oLibrerias.ObtenerLetrasValidas( .T. ) + "-. /"
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarDescripcionEntidadGenerico() As VOID

		Select Entidad, Descripcion ;
			from Entidad ;
			where	Empty( Descripcion ) ;
			into Cursor cVer nofilter

		Select cVer
		Scan
			This.ValidarDescripcionEntidad( cVer.Descripcion )
			with This.oInformacionIndividual
				If .Count > 0
					.AgregarInformacion( "Error al validar Descripcion Entidad para entidad " + Alltrim( cVer.Entidad ) )
				Endif
			endwith
		Endscan

		use in select( "cVer" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarCampoBusquedaGenerico() As Void

		Select Entidad, Atributo, ClavePrimaria, ClaveForanea ;
			from Diccionario ;
			where BusquedaOrdenamiento ;
			into Cursor cVer nofilter

		Select cVer
		Scan
			if ClavePrimaria Or !Empty( ClaveForanea )
			else
				This.oInformacionIndividual.AgregarInformacion( "Error al validar Campo Busqueda para entidad " + Alltrim( cVer.Entidad ) + ;
											" Atributo "  + Alltrim( cVer.Atributo ) + ".El Atributo debe ser clave primaria o foranea"  )
			endif
		endscan
		
		use in select( "cVer" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarAutoCompletar( tcDominio As String ) As VOID

		Select dominio ;
			from Dominio ;
			where	Alltrim( Upper( Dominio ) ) == Alltrim( Upper( tcDominio ) ) And ;
			AutoCompletar ;
			into Cursor cVer NoFilter

		If _Tally = 0
			This.oInformacionIndividual.AgregarInformacion(	"Error al validar AutoCompletar" )
		Endif

		use in select( "cVer" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarAutoCompletarGenerico() As VOID
		local lContErrores as Integer
		 
		lContErrores = 0
		
		Select Entidad, Atributo, Dominio ;
			from Diccionario ;
			where AutoCompletar ;
			into Cursor cVer1 NoFilter

		Select cVer1
		scan
			This.ValidarAutoCompletar( cVer1.Dominio )
			with This.oInformacionIndividual
				If .Count > lContErrores
						.AgregarInformacion( "Error al validar AutoCompletar para entidad " + Alltrim( cVer1.Entidad ) + ;
											" Atributo "  + Alltrim(cVer1.Atributo ) )
					lContErrores = .Count
				endif
			endwith
		Endscan

		use in select( "cVer1" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarDominioExistenteEnDiccionario() As VOID

		Select Entidad, Atributo, Dominio ;
			from Diccionario ;
			where !empty( dominio) and ;
			Upper( Dominio ) Not In ( Select Upper( Dominio ) From Dominio ) ;
			into Cursor cVer NoFilter

		Select cVer
		Scan
			This.oInformacionIndividual.AgregarInformacion(	"El Dominio " + Alltrim( cVer.Dominio ) + " para entidad " + ;
										Alltrim( cVer.Entidad ) + " Atributo "  + Alltrim(cVer.Atributo ) + " no esta definido." )
		Endscan

		use in select( "cVer" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCampoBusquedaOrden() as VOID

		select distinct upper( entidad ) Entidad ;
			from diccionario ;
			where	upper( entidad )  not in ( select upper( entidad ) from diccionario where claveprimaria and busquedaordenamiento ) .And. ;
					upper( entidad ) In ( Select upper( Entidad ) from Entidad where Tipo = "E" ) ;
			order by entidad ;
			into cursor cver
	
		select cver
		scan 		
			This.oInformacionIndividual.AgregarInformacion(	"La entidad " + Alltrim( cVer.entidad ) + ;
										" no tiene ningún campo habilitado para búsqueda" )
		endscan

		use in select( "cVer" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarCampoAdmiteBusqueda() as Void
		local lcEntidad as String

		select upper( ENTIDAD ) AS Entidad, admitebusqueda from diccionario ;
		where upper( alltrim( entidad ) ) in ( SELECT upper( alltrim( ENTIDAD ) ) from entidad where formulario and alltrim( upper( Tipo ) ) = "E" ) ;
		order by entidad into cursor cver
	
		select cver
		select distinct entidad from cver into cursor EntiARecorre
		
		select EntiARecorre
		scan
			lcEntidad = alltrim( upper( EntiARecorre.Entidad ))
			select count( entidad ) as cantidad from cver where alltrim( upper( Entidad )) == lcEntidad into cursor Cantidad1
			select count( entidad ) as cantidad from cver where alltrim( upper( Entidad )) == lcEntidad and admitebusqueda < 1 into cursor Cantidad2
			
			if Cantidad1.Cantidad == Cantidad2.Cantidad
				This.oInformacionIndividual.AgregarInformacion(	"La entidad " + lcEntidad + ;
										" no tiene ningún campo con AdmiteBusqueda" )			
			endif
			
		endscan
		use in select( "Cantidad1" )
		use in select( "Cantidad2" )
		use in select( "EntiARecorre" )
		use in select( "cVer" )
	endfunc 
	
		*-----------------------------------------------------------------------------------------
	function ValidarTipoDeValorCheque() as VOID

		select fechaEntrega, fecharecibe from TipoDeValores where codigo = 4 into cursor cVer
		if cVer.fechaEntrega or cVer.fechaRecibe
			This.oInformacionIndividual.AgregarInformacion(	"El tipo de valor CHEQUE debe tener habilitado (.F.) el salto de campo en FechaEntrega y FechaRecibe" )
		endif
		use in select( "cVer" )
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------	
	Function AbrirTablas() As Void
		this.InformarProceso( "Abriendo tablas de ADN físico" )
		With This
			.oAccesoDatos.AbrirTabla( "Diccionario",		.F., .cRutaADN, "Diccionario",		.T. )
			.oAccesoDatos.AbrirTabla( "Entidad",			.F., .cRutaADN, "Entidad",			.T. )
			.oAccesoDatos.AbrirTabla( "Dominio",			.F., .cRutaADN, "Dominio",			.T. )
			.oAccesoDatos.AbrirTabla( "Comprobantes",		.F., .cRutaADN, "Comprobantes",		.T. )
			.oAccesoDatos.AbrirTabla( "Menu",				.F., .cRutaADN, "Menu",				.T. )
			.oAccesoDatos.AbrirTabla( "Controles",			.F., .cRutaADN, "Controles",		.T. )
			.oAccesoDatos.AbrirTabla( "Estilos",			.F., .cRutaADN, "Estilos",			.T. )
			.oAccesoDatos.AbrirTabla( "Propiedades",	 	.F., .cRutaADN, "Propiedades",		.T. )
			.oAccesoDatos.AbrirTabla( "EstructuraTablas",   .F., .cRutaADN, "EstructuraTablas",	.T. )
			.oAccesoDatos.AbrirTabla( "SeguridadEntidades", .F., .cRutaADN, "SeguridadEntidades",.T. )
			.oAccesoDatos.AbrirTabla( "SeguridadEntidadesDefault", .F., .cRutaADN, "SeguridadEntidadesDefault",.T. )
			.oAccesoDatos.AbrirTabla( "MenuAltasItems", 	.F., .cRutaADN, "MenuAltasItems",	.T. )
			.oAccesoDatos.AbrirTabla( "MenuAltasDefault", 	.F., .cRutaADN, "MenuAltasDefault",	.T. )
			.oAccesoDatos.AbrirTabla( "Parametros", 		.F., .cRutaADN, "Parametros",		.T. )
			.oAccesoDatos.AbrirTabla( "Registro", 		.F., .cRutaADN, "Registro",		.T. )
			.oAccesoDatos.AbrirTabla( "JerarquiaParametros",.F., .cRutaADN, "JerarquiaParametros",	.T. )
			.oAccesoDatos.AbrirTabla( "RelaNumeraciones",.F., .cRutaADN, "RelaNumeraciones",	.T. )
			.oAccesoDatos.AbrirTabla( "AtributosGenericos",.F., .cRutaADN, "AtributosGenericos",	.T. )
			.oAccesoDatos.AbrirTabla( "Menuprincipal",.F., .cRutaADN, "Menuprincipal",	.T. )
			.oAccesoDatos.AbrirTabla( "MenuprincipalItems",.F., .cRutaADN, "MenuprincipalItems",	.T. )			
			.oAccesoDatos.AbrirTabla( "Buscador",           .F., .cRutaADN, "Buscador", .T. )			
			.oAccesoDatos.AbrirTabla( "BuscadorDetalle",    .F., .cRutaADN, "BuscadorDetalle",	.T. )									
			.oAccesoDatos.AbrirTabla( "AtributosGenericos",    .F., .cRutaADN, "AtributosGenericos",	.T. )		
			.oAccesoDatos.AbrirTabla( "transferenciasfiltros",    .F., .cRutaADN, "transferenciasfiltros",	.T. )					
			.oAccesoDatos.AbrirTabla( "transferenciasagrupadasitems",    .F., .cRutaADN, "transferenciasagrupadasitems",	.T. )								
			.oAccesoDatos.AbrirTabla( "transferenciasagrupadas",    .F., .cRutaADN, "transferenciasagrupadas",	.T. )								
			.oAccesoDatos.AbrirTabla( "listcampos",    .F., .cRutaADN, "listcampos",	.T. )
			.oAccesoDatos.AbrirTabla( "Listados",    .F., .cRutaADN, "Listados",	.T. )
			.oAccesoDatos.AbrirTabla( "Transferencias",    .F., .cRutaADN, "Transferencias",	.T. )
			.oAccesoDatos.AbrirTabla( "RelaComponente",    .F., .cRutaADN, "RelaComponente",	.T. )
			.oAccesoDatos.AbrirTabla( "Componente",    .F., .cRutaADN, "Componente",	.T. )
			.oAccesoDatos.AbrirTabla( "NodosParametrosCliente",    .F., .cRutaADN, "NodosParametrosCliente",	.T. )
			.oAccesoDatos.AbrirTabla( "TablasInternas",    .F., .cRutaADN, "TablasInternas",	.T. )
			.oAccesoDatos.AbrirTabla( "TipoDeValores",    .F., .cRutaADN, "TipoDeValores",	.T. )			
			.oAccesoDatos.AbrirTabla( "parametrosyregistrosespecificos",    .F., .cRutaADN, "parametrosyregistrosespecificos",	.T. )			
			.oAccesoDatos.AbrirTabla( "indice_sqlserver",    .F., .cRutaADN, "indice_sqlserver",	.T. )
			.oAccesoDatos.AbrirTabla( "SeteosListadosGenericos",    .F., .cRutaADN, "SeteosListadosGenericos",	.T. )

			.oAccesoDatos.AbrirTabla( "Proyectos",    .F., this.cRutaInicial + "..\taspein\data\", "Proyectos",	.T. )		
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function CrearCursor( tcTabla as String ) as Void
		local lcTabla as String, lcAlias as String, llAbrir as boolean
		
		lcTabla = alltrim( tcTabla )
		lcAlias = "c_" + lcTabla

		use in select( lcAlias )
		
		llAbrir = !used( lcTabla )
		if llAbrir 
			.oAccesoDatos.AbrirTabla( lcTabla, .F., .cRutaADN, lcTabla, .T. )
		endif

		select * from ( lcTabla ) ;
			into cursor ( lcAlias ) readwrite
		
		if llAbrir 
			This.oAccesoDatos.CerrarTabla( lcTabla )
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function CerrarTablas() As Void
		local lcListaDeTablas as String 
		
		this.CerrarAdnAdicional()
		this.InformarProceso( "Cerrando tablas de ADN físico" )
		lcListaDeTablas = "Diccionario,Entidad,Dominio,Comprobantes,Menu,Controles,Estilos,Propiedades,EstructuraTablas," + ;
					"SeguridadEntidades,SeguridadEntidadesDefault,MenuPrincipal,MenuPrincipalItems,MenuAltasItems,MenuAltasDefault,Parametros,Registro," + ;
					"JerarquiaParametros,RelaNumeraciones,AtributosGenericos,RelaTriggers,Buscador, BuscadorDetalle, tipodevalores, " + ;
					"ParametrosYRegistrosEspecificos, proyectos, indice_sqlserver, seteoslistadosgenericos"
		This.oAccesoDatos.CerrarTabla( lcListaDeTablas )
		
		lcListaDeTablas = "TransferenciasAgrupadas,TransferenciasAgrupadasItems,TransferenciasFiltros,ListCampos,Listados,Transferencias," +;
					"RelaComponente,Componente,NodosParametrosCliente,TablasInternas"
		This.oAccesoDatos.CerrarTabla( lcListaDeTablas )
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Destroy() As VOID
		this.oAccesoDatos	= Null
		this.oLibrerias		= Null
		This.oInformacionIndividual = null
		this.oValidarAdnComponenteSenias = null
		this.oValidarAdnComponenteTarjetaDeCredito = null
		this.oValidarAdnCapitalizacionEtiquetas = null
		this.oValidarAdnConLaConfiguracionBasica = null		
		this.oValidarAdnConSeguridadComercial = null
		this.oValidarAdnCopiaDeDetalles = null
		this.oValidarAdnEntidadesConEdicionParcial = null
		this.CerrarAdnAdicional()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerEntidadesConProblemas( tcCursor ) As String
		Local lcEntidades As String, lcEntidad As String
		lcEntidades = ""

		Select Distinct Entidad From &tcCursor Into Cursor Cur_Entidades

		Select Cur_Entidades
		Scan
			lcEntidades = lcEntidades + Alltrim( Cur_Entidades.Entidad ) + ", "
		Endscan
		Use In select ( "Cur_Entidades" )
		lcEntidades = Left( lcEntidades, Len( lcEntidades ) - 2 )
		
		Return lcEntidades
	Endfunc

	*-----------------------------------------------------------------------------------------
	*-- VPAREDES: Se puede dividir en otros metodos
	function ValidarMuestraRelacion() as VOID
		Local lnRecCount as Integer, i as Integer

		select proper( diccionario.Entidad ) as entidad, count( * ) as canti ;
				from Diccionario, Entidad ;
				group by 1 ;
				where alltrim( upper( entidad.Tipo ) ) == "E" and ;
					   entidad.formulario = .T. and ;	
					  alltrim( lower( Diccionario.Entidad ) ) == alltrim( lower( Entidad.Entidad ) ) ;
			into cursor c_CRegistros

		select proper( Entidad ) as entidad, count( * ) as canti ;
				from Diccionario ;
				where MuestraRelacion ;
				group by 1 ;
			into cursor c_MRelacionTrue

		select proper( Entidad ) as entidad, count( * ) as canti ;
				from Diccionario ;
				where !MuestraRelacion ;
				group by 1 ;
			into cursor c_MRelacionFalse

		select c_MRelacionTrue.entidad, c_Cregistros.canti - c_MRelacionTrue.canti as diferencia ;
				from c_MRelacionTrue, c_Cregistros ;
				where c_MRelacionTrue.entidad = c_Cregistros.entidad ;
				having diferencia = 0 ;
			into cursor c_final

		with This.oInformacionIndividual
			if _tally > 0
				scan
					if diferencia = 0
						.AgregarInformacion( "La entidad " + alltrim( entidad ) + " tiene más de un atributo marcado como MuestraRelacion" )					
					else
						.AgregarInformacion( "La entidad " + alltrim( entidad ) + " no tiene ningún atributo marcado como MuestraRelacion" )
					endif
				endscan
			endif

			select c_MRelacionFalse.entidad, c_Cregistros.canti - c_MRelacionFalse.canti as diferencia ;
					from c_MRelacionFalse, c_Cregistros ;
					where c_MRelacionFalse.entidad = c_Cregistros.entidad ;
					having diferencia # 1 ;
				into cursor c_final

			if _tally > 0
				scan
					if diferencia = 0
						.AgregarInformacion( "La entidad " + alltrim( entidad ) + " no tiene ningún atributo marcado como MuestraRelacion" )
					else
						.AgregarInformacion( "La entidad " + alltrim( entidad ) + " tiene más de un atributo marcado como MuestraRelacion" )
					endif
				endscan
			endif
			
			select proper( diccionario.entidad ) as entidad, diccionario.atributo, Dominio.Detalle, Dominio.EsBloque ;
					from Diccionario, Dominio ;
					where Diccionario.MuestraRelacion and ( Dominio.Detalle or Dominio.EsBloque ) and ;
						  alltrim( lower( Diccionario.Dominio ) ) == alltrim( lower( Dominio.Dominio ) ) ;
				into cursor c_NoDetalle

			if _tally > 0
				scan 
					if Detalle
						.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + " de la entidad " + alltrim( lower( entidad ) ) + ;
													  " esta marcado como MuestraRelacion y es un detalle" )
					endif
					if EsBloque
						.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + " de la entidad " + alltrim( lower( entidad ) ) + ;
													  " esta marcado como MuestraRelacion y es un bloque" )
					endif
				endscan
			endif
			
			select proper( entidad ) as entidad, atributo ;
					from Diccionario ;
					where MuestraRelacion and !empty( claveForanea ) ;
				into cursor c_ClaveForanea
			
			if _tally > 0
				scan 
					.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + " de la entidad " + alltrim( lower( entidad ) ) + ;
												  " esta marcado como MuestraRelacion y tiene clave foránea" )
				endscan
			endif
		endwith
		
		use in select( "c_ClaveForanea" )
		use in select( "c_NoDetalle" )
		use in select( "c_CRegistros" )
		use in select( "c_MRelacionTrue" )
		use in select( "c_MRelacionFalse" )
		use in select( "c_final" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarClavePrimariaSinMemo() as VOID
	
		select proper( diccionario.entidad ) as entidad, diccionario.atributo, count( * ) as cantidad ;
				from diccionario, entidad ;
				where diccionario.claveprimaria and entidad.tipo = "E" and ;
					  alltrim( lower( diccionario.entidad ) ) == alltrim( lower( entidad.entidad ) ) ;
				group by diccionario.entidad ;
				having cantidad > 1 ;
			into cursor c_ClavePrimaria

		select proper( diccionario.entidad ) as entidad, diccionario.atributo ;
				from Diccionario ;
				where alltrim( upper( tipoDato ) )== "M" and ;
					  alltrim( proper( Diccionario.entidad ) ) in ( ;
					  		select alltrim( entidad ) from c_ClavePrimaria ) ;
			into cursor c_CamposMemo

		if _tally > 0
			scan 
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
											" de la entidad " + alltrim( lower( entidad ) ) + ;
											" es de tipo Memo pero la entidad tiene clave compuesta" )
			endscan
		endif
		
		use in select( "c_CamposMemo" )
		use in select( "c_ClavePrimaria" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCombosTabla() as VOID
	
		select entidad, atributo ;
				from diccionario ;
				where alltrim( lower( dominio ) ) == "combotabla" and ;
					  empty( ClaveForanea ) ;
			into cursor c_ComboTabla
			
		if _tally > 0
			scan 
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
											" de la entidad " + alltrim( lower( entidad ) ) + ;
											" tiene comportamiento ComboTabla y no es clave foránea" )
			endscan
		endif

		use in select( "c_ComboTabla" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarClavesForaneasComoEntidad() as VOID

		select distinct diccionario.entidad, diccionario.atributo, diccionario.claveforanea, entidad.entidad as EntEntidad;
				from diccionario;
				left outer join entidad on upper( alltrim( diccionario.claveforanea ) ) == upper( alltrim( entidad.entidad ) ) ;
				where not empty( diccionario.claveforanea );
				having  isnull( EntEntidad );
				into cursor c_ClavesForaneas
		
		if _tally > 0
			scan
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
											" de la entidad " + alltrim( lower( entidad ) ) + ;
											" tiene la clave foránea " + alltrim( lower( ClaveForanea ) ) + ;
											" y esta no existe como entidad." )
			endscan
		endif

		use in select( "c_ClavesForaneas" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarMemosEnItems() as VOID
		
		select diccionario.entidad, diccionario.atributo ;
				from diccionario, entidad ;
				where alltrim( lower( diccionario.entidad ) ) == alltrim( lower( entidad.entidad ) ) and ;
					  alltrim( upper( entidad.Tipo ) ) == "I" and ;
					  alltrim( upper( Diccionario.TipoDato ) ) == "M" ;
					  and !empty( diccionario.Tabla ) and !empty( diccionario.Campo ) and empty( diccionario.SaltoCampo ) ;
			into cursor c_MemosEnItems
		
		if _tally > 0
			scan
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
											" del Item " + alltrim( lower( entidad ) ) + ;
											" tiene tipo de dato Memo." )
			endscan
		endif

		use in select( "c_MemosEnItems" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarPalabrasReservadas() as VOID
		Local lcItem as String, lcWhere as String,  lcSQL as String

		this.CargarCursorDePalabrasReservadas()
		
		select distinct campo, entidad, atributo ;
		from diccionario ;
		where upper(campo) in (select c_PalabrasReservadas.palabra from c_PalabrasReservadas) ;
			and iif(upper(alltrim(this.cProyectoActivo)) == "ZL" and upper(alltrim(campo)) == "PLAN", upper(alltrim(entidad)) not in ("INFREGISTROMANTENIMIENTO", "SERIEV2" ), .t.) ;
		into cursor c_campos
	
		select c_campos
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
										" del Item " + alltrim( lower( entidad ) ) + ;
										" tiene como nombre de campo la palabra "+ alltrim( lower( campo ) ) + "." )
		endscan
		
		use in select ( "c_campos" )
		use in select ( "c_PalabrasReservadas" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAtributosReservados() as VOID

		this.CargarCursorDeAtributosReservados()

		select distinct entidad, atributo from diccionario ;
			where upper(atributo) in ;
			(select atributo ;
			from c_AtributosReservados ) ;
			into cursor c_AtributosAux
			
		select c_AtributosAux
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
										" del Item " + alltrim( lower( entidad ) ) + "." )
		endscan
		
		use in select ( "c_AtributosAux" )
		use in select ( "c_AtributosReservados" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCursorDeAtributosReservados() as Void
	
		create cursor c_AtributosReservados ( Atributo C (254))
	
		insert into c_AtributosReservados values ("GUID")
		insert into c_AtributosReservados values ("CNOMBRE")
		insert into c_AtributosReservados values ("LEDICION")
		insert into c_AtributosReservados values ("LNUEVO")
		insert into c_AtributosReservados values ("LLIMPIANDO")
		insert into c_AtributosReservados values ("LCARGANDO")
		insert into c_AtributosReservados values ("LELIMINAR")
		insert into c_AtributosReservados values ("CATRIBUTOPK")
		insert into c_AtributosReservados values ("LPERMITEMINUSCULASPK")
		insert into c_AtributosReservados values ("LTRANSFERENCIA")
		insert into c_AtributosReservados values ("CCONTEXTO")
		insert into c_AtributosReservados values ("OVALIDACIONDOMINIOS")
		insert into c_AtributosReservados values ("OAD")
		insert into c_AtributosReservados values ("ONUMERACIONES")
		insert into c_AtributosReservados values ("CATRIBUTOAAUDITAR")
		insert into c_AtributosReservados values ("OATRIBUTOSCC")
		insert into c_AtributosReservados values ("CDESCRIPCION")		
		insert into c_AtributosReservados values ("OCOMPCAJA")
		insert into c_AtributosReservados values ("TIMESTAMP")
			
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	function ValidarCamposReservados() as VOID

		this.CargarCursorDeCamposReservados()
		select distinct entidad, atributo, campo from diccionario ;
			where upper(campo) in ;
			(select campo  ;
			from c_CamposReservados ) ;
			into cursor c_CamposAux
			
		select c_CamposAux	
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
										" de la entidad " + alltrim( lower( entidad ) ) + "." )
		endscan
		
		use in select ( "c_CamposAux" )
		use in select ( "c_CamposReservados" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarCursorDeCamposReservados() as Void
		create cursor c_CamposReservados ( campo C (254))
		insert into c_CamposReservados values ("GUID")
		insert into c_CamposReservados values ("TIMESTAMP")
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCamposClaveForanea() as VOID

		select entidad, atributo, campo, dominio ;
			from diccionario ;
			where "CODIGO" $ upper( dominio ) and ;
				upper( dominio ) not in ( "CODIGOCLIENTECOMPROBANTE","CODIGOPOSTAL","CODIGOPERCEPCION","COMBOENTIDADESCODIGOSUGERIDO", "CODIGOQR" ) and ;
				!claveprimaria and ;
				empty( claveforanea ) ;
			into cursor c_CamposCFAux
			
		select c_CamposCFAux
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
										" de la entidad " + alltrim( lower( entidad ) ) + " no es clave primaria y tiene un dominio CODIGO, por lo que debe tener una clave foranea." )
		endscan

		use in select ("c_CamposCFAux")
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarClaveForaneaInvalidos() as VOID

		select entidad, atributo, campo, claveforanea ;
			from diccionario ;
			where !empty( claveforanea ) and ;
				upper(alltrim(claveforanea)) not in ( select upper(alltrim(entidad)) from entidad ) ;
			into cursor c_CamposCFAux
				
		select c_CamposCFAux
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( lower( atributo ) ) + ;
										" de la entidad " + alltrim( lower( entidad ) ) + " con Clave Foranea " + claveforanea + "."  )
		endscan

		use in select ("c_CamposCFAux")
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTablaCampo() as VOID
		local lcMensaje As String
		lcMensaje = ""		
		
		select distinct padr( alltrim( upper( Tabla ) ), len( Tabla ) ) as Tabla, ;
						padr( alltrim( upper( Campo ) ), len( Campo ) )as Campo, ;
						padr( alltrim( upper( TipoDato ) ), len( TipoDato ) ) as TipoDato ;
			from diccionario ;
			where !empty( tabla ) ;
			into cursor c_TablaCampo nofilter
				
		select Tabla, Campo, count( * ) as cant ;
			from c_TablaCampo ;
			group by Tabla, Campo ;
			having cant > 1 ;
			into cursor c_erroneos 

		select c_Erroneos
		scan
			select Entidad, Atributo,TipoDato ;
				from Diccionario ;
				where	alltrim( upper( Tabla ) ) == alltrim( c_Erroneos.Tabla ) and ;
						alltrim( upper( Campo ) ) == alltrim( c_Erroneos.Campo ) ;
				into cursor C_Mostrar NoFilter

			This.oInformacionIndividual.AgregarInformacion( "Diferencia de tipo de datos en la " + ;
										"Tabla: " + alltrim( c_Erroneos.Tabla ) + " - " + ;
										"Campo: " + alltrim( c_Erroneos.Campo ) + " - " + ;
										"entre las siguientes entidades: " )

			select c_Mostrar
			scan
				lcMensaje = "- Entidad: " + alltrim( c_Mostrar.Entidad ) + " - " + ;
							"Atributo: " + alltrim( c_Mostrar.Atributo ) + " - " + ;
							"Tipo: " + alltrim( c_mostrar.TipoDato ) + "."

				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			EndScan					
			
		endscan

		use in select( "c_Mostrar" )
		use in select( "c_erroneos" )
		use in select( "c_TablaCampo" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTablaCampovsClaveForanea() as VOID
		local lcMensaje As String
		lcMensaje = ""

		select 	d.Entidad, d.Atributo, d.TipoDato, d.Longitud, d.Decimales , ;
				dd.Entidad as SubEnt, dd.Atributo as SubAtr, dd.TipoDato as SubTipo, ;
				dd.Longitud as SubLong, dd.Decimales as SubDec ;
			from diccionario d inner join Diccionario dd on	padr( alltrim( upper( d.Entidad ) ), ;
				len( d.Entidad ) ) == padr( alltrim( upper( dd.ClaveForanea ) ), len( dd.Entidad ) ) ;
			where d.ClavePrimaria and ;
				!empty( dd.ClaveForanea ) and ;
				( padr( alltrim( upper( d.TipoDato ) ), len( d.TipoDato ) ) != padr( alltrim( upper( dd.TipoDato ) ), len( dd.TipoDato ) ) or ;
				d.Longitud != dd.Longitud or ;
				d.Decimales != dd.Decimales );
			into cursor c_Erroneos nofilter
		
		if _tally > 0
			select c_Erroneos
			scan all for !( c_Erroneos->TipoDato = "A" .and. c_Erroneos->SubTipo = "N" )
				lcMensaje = "Entidad: " + alltrim( c_Erroneos.SubEnt )  + " - " + ;
							"Atributo: " + alltrim( c_Erroneos.SubAtr ) + " - " + ;
							"Tipo: " + alltrim( c_Erroneos.SubTipo ) + " - " + ;
							"Long: " + transform( c_Erroneos.SubLong ) + " - " + ;
							"Dec: " + transform( c_Erroneos.SubDec ) + " - " + ;
							"SubEntidad: " + alltrim( c_Erroneos.Entidad ) + " - " + ;
							"Atributo: " + alltrim( c_Erroneos.Atributo ) + " - " + ;
							"Tipo: " + alltrim( c_Erroneos.TipoDato ) + " - " + ;
							"Long: " + transform( c_Erroneos.Longitud ) + " - " + ;
							"Dec: " + transform( c_Erroneos.Decimales )
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			EndScan					
		endif
		
		use in select( "c_Erroneos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTipoDatoDominio() as VOID
		select Dominio
		scan for !Detalle
			this.ValidarTipoDatosLongitudesYDecimales( "Dominio" )
		endscan
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarMascara() as VOID 

		select entidad, atributo, longitud, decimales, tipodato, dominio, mascara ;
			from diccionario ; 
			where tipodato == "N" and ;
				alltrim( upper( dominio ) ) not like "NUMEROCOMPROBANTE%" and ;
				alltrim( upper( dominio ) ) not like "NUMEROINTERNO%" and ;
				( len(alltrim(strtran( mascara, ",", "" ))) > occurs( '9',mascara ) + occurs( '#',mascara ) + occurs( '%', mascara ) + max( 1, occurs( '.',mascara ) ) and ;
				right( alltrim( mascara ), 1 ) != '.' or ;
				occurs( '%',mascara ) > 1) or;
				( longitud < len(alltrim(strtran( mascara, ",", "" ))) and  alltrim( upper( dominio ) ) == "NUMERICO" and decimales > 0 ) ;
			into cursor c_mascara

		if _tally > 0
			select c_mascara
			scan
				This.oInformacionIndividual.AgregarInformacion( "Error en la máscara de la entidad " + alltrim(c_mascara.entidad) + ;
										   " Atributo: " + alltrim( c_mascara.atributo ) + " - " + ;
			  							   "TipoDato: " + alltrim( c_mascara.TipoDato ) + " - " + ;
			  							   "Longitud: " + alltrim( transform( c_mascara.Longitud ) ) + " - " + ;
			  							   "Decimales: " + alltrim( transform( c_mascara.Decimales ) ) + " - " + ;
			  							   "Dominio: " + alltrim( c_mascara.Dominio ) + " - " + ;
										   "Máscara: " + alltrim( c_mascara.mascara) )
			EndScan
		endif
		use in select( "c_mascara" )

		select entidad,atributo,mascara ;
			from diccionario ; 
			where Dominio like "CODIGOSOLONUMEROS%" ;
			and !empty( mascara );
			into cursor c_mascara

		if _tally > 0
			select c_mascara
			scan
				This.oInformacionIndividual.AgregarInformacion( "Error en la máscara de la entidad " + alltrim(c_mascara.entidad) + ;
											" Atributo: " + alltrim( c_mascara.atributo ) + " - " + ;
											"Dominio: CODIGOSOLONUMEROS - " + ;
											"Máscara: " + alltrim( c_mascara.mascara) )
			EndScan					
		endif

		use in select( "c_mascara" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarLargoDeCampoVersusMascara() as VOID 
	
		select entidad,atributo,longitud,mascara ;
			from diccionario ; 
			where ! empty(mascara) and ;
				  len( alltrim( strtran( mascara, ",", "" ) ) ) > longitud ;
			into cursor c_mascara
			
		if _tally > 0
			select c_mascara
			scan
				This.oInformacionIndividual.AgregarInformacion( "Longitud de máscara mayor a longitud de campo en entidad " + alltrim(c_mascara.entidad) + ;
											" Atributo: " + alltrim( c_mascara.atributo ) + " - " + ;
											"Longitud: " + alltrim( str(c_mascara.longitud ) ) + " - " + ;
											"Máscara: " + alltrim( c_mascara.mascara) )
			EndScan					
		endif
		
		use in select( "c_mascara" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributoAjustableEnDetalle() as VOID 
	
		select diccionario.entidad, diccionario.atributo, entidad.tipo, diccionario.ajustable ;
			from diccionario ;
				inner join entidad on upper(alltrim(diccionario.entidad)) = upper(alltrim(entidad.entidad)) ;
			where upper(alltrim(entidad.tipo)) = "I" and !diccionario.ajustable and diccionario.alta ;
			into cursor c_Ajustables
			
		if _tally > 0
			select c_Ajustables
			scan
				This.oInformacionIndividual.AgregarInformacion( "Atributo no ajustable en detalle " + alltrim(c_Ajustables.entidad) + ;
											" Atributo: " + alltrim( c_Ajustables.atributo ) )
			EndScan					
		endif
		
		use in select( "c_Ajustables" )
	endfunc 	

	*-----------------------------------------------------------------------------------------	
	function ValidarCamposNoMemoEnDetalle() as VOID
		
		select diccionario.entidad,atributo, entidad.tipo, diccionario.tipodato ;
			from diccionario ;
				inner join entidad on upper(alltrim(diccionario.entidad)) = upper(alltrim(entidad.entidad)) ;
			where upper(alltrim(entidad.tipo)) = "I" and diccionario.tipodato = "M" ;
				and !empty( diccionario.Tabla ) and !empty( diccionario.Campo )  and empty( diccionario.SaltoCampo ) ;
			into cursor c_Memos
			
		if _tally > 0
			select c_Memos
			scan
				This.oInformacionIndividual.AgregarInformacion( "Atributo de tipo memo en detalle " + alltrim(c_Memos.entidad) + ;
											" Atributo: " + alltrim( c_Memos.atributo ) )
			EndScan					
		endif
		
		use in select( "c_Memos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarClavesPrimariasNoMemo() as VOID 

		select entidad, atributo, tipodato ;
			from diccionario ;
			where claveprimaria and tipodato = "M" ;
			into cursor c_Memos
			
		if _tally > 0
			select c_Memos		
			scan
				This.oInformacionIndividual.AgregarInformacion( "Atributo de tipo memo como clave primaria " + alltrim(c_Memos.entidad) + ;
											" Atributo: " + alltrim( c_Memos.atributo ) )	
			EndScan					
		endif
		
		use in select( "c_Memos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ValidarDetallesRepetidosEnEntidad() as VOID 
	
		select entidad,atributo, dominio, count(dominio) as cantidad ;
			from diccionario ;
			where upper( left( DOMINIO, 7) ) = "DETALLE" ;
				 group by entidad,dominio ;
				 order by entidad,dominio ;
				 having cantidad > 1 ;
			into cursor c_DetRep
			
		if _tally > 0		
			select c_DetRep
			scan
				This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim(c_DetRep.entidad) + ;
											" tiene repetido el detalle: " + alltrim( c_DetRep.dominio ) )	
			EndScan					
		endif
		
		use in select( "c_DetRep" )
	Endfunc 
	
	*----------------------------------------------------------------------------------------	
	function ValidarNomenclaturaDeItems() as VOID 
	
		select diccionario.entidad,atributo ;
			from diccionario ;
				inner join entidad on alltrim(upper(diccionario.entidad)) = alltrim(upper(entidad.entidad)) ;
			where entidad.tipo = "I" order by diccionario.entidad,atributo ;
			into cursor c_items
			
		select distinc diccionario.entidad,atributo,strtran(upper(atributo),"DETALLE","") as NombreAtributo;
			from diccionario ;
				inner join entidad on alltrim(upper(diccionario.entidad)) = alltrim(upper(ENTIDAD.entidad)) ;
			where entidad.tipo = "I" and upper(right(alltrim(atributo),7)) = "DETALLE" ;
			into cursor c_detalle 
		
		select c_detalle.entidad as EntidadDetalle, c_detalle.atributo as AtributoDetalle, ;
			c_detalle.nombreatributo, c_items.atributo as EntidadItems ;
			from c_detalle ;
				left join c_items on alltrim(upper(c_detalle.nombreatributo)) == alltrim(upper(c_items.atributo)) and ;
					  			 alltrim(upper(c_detalle.entidad)) == alltrim(upper(c_items.entidad)) ;
			where IsNull(c_items.Entidad) ;
			into cursor c_Errores	
			
		if _tally > 0
			select c_Errores
			scan
				This.oInformacionIndividual.AgregarInformacion( "Atributo de tipo memo como clave primaria " + alltrim(c_Errores.entidadDetalle) + ;
								" Atributo: " + alltrim( c_Errores.atributoDetalle ) )
			EndScan					
		endif
		
		use in select( "c_Errores" )
		use in select( "c_items" )
		use in select( "c_detalle" )				
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarClavePrimariaCompuestaConCamposMemos() as VOID 
		
		select entidad,count(claveprimaria) as CantidadClavePrimaria ;
			from diccionario ;
			where claveprimaria and entidad in (select entidad from diccionario where tipodato = "M" group by entidad) ;
				group by entidad ;
				having CantidadClavePrimaria > 1 ;
			into cursor c_Memos		
	
		if _tally > 0
			select c_Memos
			scan
				This.oInformacionIndividual.AgregarInformacion( "Entidad " + alltrim(c_Memos.entidad) + " con campos memos " + ;
											" y " + alltrim( str(c_Memos.CantidadClavePrimaria ) ) + " Claves Primarias" )
			EndScan					
		endif
		
		use in select( "c_Memos" )
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function ValidarTipoDatoDiccionario() as VOID 
		
		select d.Entidad, d.atributo, d.TipoDato, d.Longitud, d.Decimales, d.Dominio ;
				from Diccionario d;
					inner join Dominio dd on ( ;
						alltrim( lower( d.Dominio ) ) == alltrim( lower( dd.Dominio ) ) ) ;
				where !dd.Detalle ;
			into cursor c_NoDetalles

		select c_NoDetalles
		scan 
			this.ValidarTipoDatosLongitudesYDecimales( "Entidad" )
		endscan
		
		use in select( "c_NoDetalles" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoDatosLongitudesYDecimales( tcCampo as String ) as VOID
		Local lcCampo as String
		lcCampo = alltrim( tcCampo ) + ": "
		
		with This.oInformacionIndividual
			if !empty( TipoDato ) and !inlist( upper( alltrim( TipoDato ) ), "C", "N", "D", "L", "M", "A", "G" )
				lcMensaje = "Tipo de datos inválido: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + "." )
			endif
			if TipoDato = "C" and Longitud != 0 and !between( Longitud, 1, 254 ) 
				lcMensaje = "Longitud inválida: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "C" and Decimales != 0
				lcMensaje = "Decimales inválido (este tipo de datos no lleva decimales): "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Decimales " + transform( Decimales ) )
			endif
			if TipoDato = "N" and Longitud != 0 and !between( Longitud, 1, 20 ) 
				lcMensaje = "Longitud inválida: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "N" and Decimales != 0 and !between( Decimales, 0, Longitud - 1 )
				lcMensaje = "Decimales inválido: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + ;
												" Longitud " + transform( Longitud ) + " Decimales " + transform( Decimales ) )
			endif
			if TipoDato = "D" and ( Longitud != 8 and Longitud != 10 )
				lcMensaje = "Longitud inválida: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "D" and Decimales != 0
				lcMensaje = "Decimales inválido (este tipo de datos no lleva decimales): "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Decimales " + transform( Decimales ) )
			endif
			if TipoDato = "L" and Longitud != 1
	
				lcMensaje = "Longitud inválida: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "L"  and decimales != 0
				lcMensaje = "Decimales inválido (este tipo de datos no lleva decimales): "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "M" and Longitud != 0
				lcMensaje = "Longitud inválida: "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "M" and Decimales != 0
				lcMensaje = "Decimales inválido (este tipo de datos no lleva decimales): "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif
			if TipoDato = "G" and ( Longitud != 38 or Decimales != 0 )
				lcMensaje = "Longitud inválida (este tipo de datos debe ser longitud 38 y decimales 0): "
				.AgregarInformacion( lcMensaje + lcCampo + alltrim( &tcCampo ) + " Tipo " + alltrim( TipoDato ) + " Longitud " + transform( Longitud ) )
			endif

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarModoSimple() as VOID
		*** H: 2005, validar que al menos haya un campo por entidad que no esté solo en modo simple
		Local lcCursor as String 
		lcCursor = sys( 2015 )
		
		select d.Entidad, d.atributo ;
				from Diccionario d ;
				where ( claveprimaria and modo_avanzado ) or ( muestrarelacion and modo_avanzado ) ;
				into cursor &lcCursor

		select( lcCursor )
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + " de la entidad " + ;
										upper( alltrim( &lcCursor..Entidad ) ) + " esta en MODO_AVANZADO y es CLAVEPRIMARIA o MUESTRARELACION" )
		endscan
		
		use in select( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarSubEntidadConUnaSolaClavePrimaria() as VOID
		local lcCursor as String, lcCurso2 as String 
		
		lcCursor = sys( 2015 )
		lcCursor2 = sys( 2015 )
		
		select distinct claveforanea ;
			from diccionario ;
			where !empty(claveforanea) order by claveforanea into cursor &lcCursor
		 
		 
		select entidad, count( claveprimaria ) as Cantidad ;
			from diccionario ;
			where claveprimaria and entidad in (select distinct claveforanea from diccionario where !empty( claveforanea ) and atc( "ITEM",claveforanea ) = 0) ;
			group by entidad ;
			having cantidad > 1;
			order by entidad ;
			into cursor ( lcCursor )
		 
		 if reccount( lcCursor ) > 0
		 	select d.entidad, d.atributo;
				from diccionario d inner join ( lcCursor ) as cur on upper( cur.entidad ) = upper( d.claveforanea );
				into cursor ( lcCursor2 )
			
			select ( lcCursor2 )
			scan 
				This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor2..atributo ) ) + ;
											" de la entidad " + upper( alltrim( &lcCursor2..Entidad ) ) + ;
											" esta relacionado a una subEntidad con mas de una clave primaria" )
			endscan
			use in select ( lcCursor2 )
			
		 endif	

		 use in select( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarAdmiteBusquedaEnAtributoDetalle() as VOID

		local lcCursor As String
		lcCursor = sys( 2015 )
		
		select dic.Entidad, Dic.Atributo ;
				from Diccionario Dic ;
					inner join Entidad Ent on alltrim( upper( Dic.Entidad ) ) == alltrim( upper( Ent.Entidad ) ) ;
					inner join Dominio Dom on alltrim( upper( Dic.Dominio ) ) == alltrim( upper( Dom.Dominio ) ) ;
				where Dom.Detalle and Dic.AdmiteBusqueda > 0 ;
				Into Cursor &lcCursor
		
		select ( lcCursor )
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + ;
										" de la entidad " + upper( alltrim( &lcCursor..Entidad ) ) + " no puede admitir busqueda" )
		endscan

		use in select ( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAdmiteBusquedaEnAtributoSinAsociacionDeCampo() as VOID

		local lcCursor As String
		lcCursor = sys( 2015 )
		
		select dic.Entidad, Dic.Atributo ;
				from Diccionario Dic ;
				where LEN( ALLTRIM( Dic.Campo ) ) = 0 AND LEN( ALLTRIM( Dic.Tabla ) ) = 0 and Dic.AdmiteBusqueda > 0 ;
					AND LEN( ALLTRIM( Dic.AtributoForaneo ) ) = 0 ;
				Into Cursor &lcCursor
		
		select ( lcCursor )
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + ;
										" de la entidad " + upper( alltrim( &lcCursor..Entidad ) ) + " no puede admitir búsqueda," + ;
										" por no estar asociado a un campo de una tabla" )
		endscan

		use in select ( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoEntidadVacioEnMenuAltasItems() as VOID
		local lcCursor as String
		lcCursor = sys( 2015 )

		select id, Entidad ;
			from MenuAltasItems ;
			where empty( Entidad ) ;
			into cursor &lcCursor

		select ( lcCursor )
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El registro con Id " + alltrim( str( &lcCursor..id ) ) + " tiene el campo Entidad vacío." )
		endscan

		use in select ( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarQueNoEsteRepetidoElAccesoRapidoEnElMenuAltas() as VOID
		local lcCursor as string, lcCursorMI as String, lcCursorMD as String
		lcCursor = sys( 2015 )
		lcCursorMI = sys( 2015 )
		lcCursorMD = sys( 2015 )
		with this
			select padr( upper( Entidad ), 254, " " ) as entidad, ;
					padr( upper( strtran( AccesoRapido, " ", "" ) ), 254, " " ) as AccesoRapido, ;
					padr( upper( Codigo ), 254, " " ) as Codigo ;
				from ( this.cMenuAltasItemsCompleto ) ;
				where !empty( AccesoRapido ) ;
				into cursor ( lcCursorMI )

			select padr( upper( strtran( AccesoRapido, " ", "" ) ), 254, " " ) as AccesoRapido, ;
					padr( upper( Codigo ), 254, " " ) as Codigo ;
				from MenualtasDefault ;
				where !empty( AccesoRapido ) ;
				into cursor ( lcCursorMD )
				
			****************************
			select Entidad, AccesoRapido, count( * ) as cant ;
				from ( lcCursorMI ) ;
				group by Entidad, AccesoRapido having cant > 1 ;
				into cursor ( lcCursor )

			select ( lcCursor )
			scan 
				This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( Entidad ) + " tiene repetido el acceso rapido " + ;
																													alltrim( AccesoRapido ) + " en el menú." )
			endscan

			*****************************
			select AccesoRapido, count( * ) as cant ;
				from ( lcCursorMD ) ;
				group by AccesoRapido having cant > 1 ;
				into cursor ( lcCursor )

			select ( lcCursor )
			scan 
				This.oInformacionIndividual.AgregarInformacion( "Las opciones por default del menu de altas tiene repetido el acceso rapido " + ;
																													alltrim( AccesoRapido ) + " en el menú." )
			endscan

			select AccesoRapido, Codigo ;
				from ( lcCursorMD ) ;
				into cursor ( lcCursorMD )

			*****************************
			select ( lcCursorMI )
			scan
				select * from ( lcCursorMD ) md ;
						where alltrim( md.AccesoRapido ) == alltrim( &lcCursorMI..AccesoRapido ) and ;
								alltrim( md.Codigo ) != alltrim( &lcCursorMI..Codigo ) ;
					into cursor ( lcCursor )
				if _tally > 0
					This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursorMI..Entidad ) + " tiene repetido el acceso rapido " + ;
																												alltrim( &lcCursorMI..AccesoRapido ) + " en el menú default." )
				endif

				select ( lcCursorMI )
			endscan
			
			use in select ( lcCursor )
			use in select ( lcCursorMI )
			use in select ( lcCursorMD )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadDeVersionDeEntidades() as VOID
		local lcCursor as String
		lcCursor = sys( 2015 )

		with This.oInformacionIndividual
			select dic.entidad , dic.claveforanea ;
				from diccionario dic ;
					inner join entidad ent1 on upper( alltrim( dic.entidad ) ) == upper( alltrim( ent1.entidad ) ) ;
					inner join entidad ent2 on upper( alltrim( dic.claveforanea ) ) == upper( alltrim( ent2.entidad ) ) ;
				where !empty( claveforanea ) and ent1.version # ent2.version ;
				into cursor ( lcCursor ) 

			select ( lcCursor )
			scan 
				.AgregarInformacion( "Incompatiblidad de versiones entre la entidad " + alltrim( &lcCursor..entidad ) + ;
									" y su sub-entidad " + alltrim( &lcCursor..claveforanea )  +   "." )
			endscan


			select dic.entidad , dic.atributo ;
				from diccionario dic ;
					inner join entidad ent1 on upper( alltrim( dic.entidad ) ) == upper( alltrim( ent1.entidad ) ) ;
					inner join entidad ent2 on strtran( upper( alltrim( dic.dominio ) ) , "DETALLE" ) == upper( alltrim( ent2.entidad ) )  and ent2.tipo = "I" ;
				where at( "DETALLE", upper( alltrim( dic.atributo ) ) ) > 0 and ent1.version # ent2.version ;
				into cursor ( lcCursor ) 

			select ( lcCursor )
			scan
				.AgregarInformacion( "Incompatiblidad de versiones entre la entidad " + alltrim( &lcCursor..entidad ) + ;
									" y su detalle " + alltrim( &lcCursor..atributo ) + "." )
			endscan


			select dic.entidad , dic.claveforanea ;
				from diccionario dic ;
					inner join entidad ent1 on upper( alltrim( dic.entidad ) ) == upper( alltrim( ent1.entidad ) ) ;
					inner join entidad ent2 on upper( alltrim( dic.claveforanea ) ) == upper( alltrim( ent2.entidad ) ) and ent2.tipo = "I";
				where at( "ITEM",  upper( alltrim( dic.entidad ) ) ) > 0 and !empty( dic.claveforanea ) and ent1.version # ent2.version ;
				into cursor ( lcCursor ) 

			select ( lcCursor )
			scan 
				.AgregarInformacion( "Incompatiblidad de versiones entre el detalle " + alltrim( &lcCursor..entidad ) + ;
									" y su sub-entidad " + alltrim( &lcCursor..claveforanea )  +   "." )
			endscan
		endwith
		
		use in select ( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------	
	protected function ValidarDetallesNormalizadosV2() as VOID
		local loError as Exception, loEx as Exception

		Try
			select distinct dic.entidad, dic.atributo, dic.tabla ;
					from diccionario dic ;
				left join dominio dom on alltrim( upper( dic.dominio ) ) == alltrim( upper( dom.dominio ) ) ;
				left join entidad ent on alltrim( upper( ent.entidad ) ) == alltrim( upper( dic.entidad ) ) ;
					where dom.detalle and ent.version = 2;
					into cursor c_Detalles

			select distinct dic.entidad, dic.atributo, dic.tabla ;
					from diccionario dic ;
				left join entidad ent on alltrim( upper( ent.entidad ) ) == alltrim( upper( dic.entidad ) ) ;
				where dic.ClavePrimaria and ent.version = 2;
					into cursor c_ClavesEntidades

			select dic.Entidad, dic.Atributo ;
					from c_detalles dic ;
				left join c_clavesEntidades ent on alltrim( upper( ent.entidad ) ) == alltrim( upper( dic.entidad ) ) ;
					where alltrim( upper( ent.tabla ) ) == alltrim( upper( dic.tabla ) ) ;
					into cursor c_EntidadesMal
			
			if reccount( "c_EntidadesMal" ) > 0
				scan 
					This.oInformacionIndividual.AgregarInformacion( "La entidad: " + alltrim( proper( c_EntidadesMal.entidad ) ) + ;
						", no tiene normalizado el atributo detalle: " + alltrim( proper( c_EntidadesMal.atributo ) ) + "." )
				endscan
			endif
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		Finally
			use in select( "c_Detalles" )
			use in select( "c_ClavesEntidades" )
			use in select( "c_EntidadesMal" )
		endtry 
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarIntegridadNodosDeParametros() as VOID

		select id, idNodo, Parametro ;
			from parametros ;
			where idNodo not in ( select Nodo from JerarquiaParametros ) ;
			into cursor c_ValidacionParametros

		scan 
			This.oInformacionIndividual.AgregarInformacion( 'El parámetro "' + alltrim( c_ValidacionParametros.parametro ) + ;
				'" esta asociado al nodo "' + transform( c_ValidacionParametros.idNodo ) + '" inexistente.' )
		endscan

		use in select( "c_ValidacionParametros" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposTablaDeParametros() as VOID

		select Parametro, ParamInt, ParamUsu ;
			from parametros ;
			where empty( ParamInt ) or empty( ParamUsu ) ;
			into cursor c_ValidacionParametros

		scan 
			This.oInformacionIndividual.AgregarInformacion( 'El parámetro "' + alltrim( c_ValidacionParametros.parametro ) + ;
				'" no tiene completo los campos "ParamInt" o "ParamUsu"' )
		endscan

		use in select( "c_ValidacionParametros" )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ValidarCampoIdUnicoTablaDeParametros() as VOID

		select Parametro, IdUnico ;
			from Parametros ;
			where empty( IdUnico ) ;
			into cursor c_ValidacionIdUnicoParametros

		scan 
			This.oInformacionIndividual.AgregarInformacion( 'El parámetro "' + alltrim( c_ValidacionIdUnicoParametros.parametro ) + ;
				'" no tiene completo el campo "IdUnico"' )
		endscan

		select IdUnico, count( IdUnico ) as Cantidad ;
			from Parametros ;
				where !empty( IdUnico ) ;
				group by IdUnico ;
				having Cantidad > 1 ;
			into cursor c_ValidacionUnicidadIdUnicoParametros
		scan
			This.oInformacionIndividual.AgregarInformacion( 'El campo "IdUnico" tiene repetido el valor ' + alltrim( c_ValidacionUnicidadIdUnicoParametros.IdUnico ) + ;
											" en la tabla Parametros.")
		endscan
		
		use in select( "c_ValidacionIdUnicoParametros" )
		use in select( "c_ValidacionUnicidadIdUnicoParametros" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoIdUnicoTablaDeRegistros() as VOID
		select Parametro, IdUnico ;
			from Registro ;
			where empty( IdUnico ) ;
			into cursor c_ValidacionIdUnicoRegistro

		scan 
			This.oInformacionIndividual.AgregarInformacion( 'El registro "' + alltrim( c_ValidacionIdUnicoRegistro.parametro ) + ;
				'" no tiene completo el campo "IdUnico"' )
		endscan

		select IdUnico, count( IdUnico ) as Cantidad ;
			from Registro ;
				where !empty( IdUnico ) ;
				group by IdUnico ;
				having Cantidad > 1 ;
			into cursor c_ValidacionUnicidadIdUnicoRegistro
		scan
			This.oInformacionIndividual.AgregarInformacion( 'El campo "IdUnico" tiene repetido el valor ' + alltrim( c_ValidacionUnicidadIdUnicoRegistro.IdUnico ) + ;
											" en la tabla Registro.")
		endscan
		
		use in select( "c_ValidacionIdUnicoRegistro" )
		use in select( "c_ValidacionUnicidadIdUnicoRegistro" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoIdUnicoTablaDeParametrosYRegistrosEspecificos() as VOID
		select Paramusu, IdUnico ;
			from ParametrosyRegistrosEspecificos ;
			where empty( IdUnico ) ;
			into cursor c_ValidacionIdUnicoParametros

		scan 
			This.oInformacionIndividual.AgregarInformacion( 'El parámetro o registro específico "' + alltrim( c_ValidacionIdUnicoParametros.Paramusu ) + ;
				'" no tiene completo el campo "IdUnico"' )
		endscan

		select IdUnico, count( IdUnico ) as Cantidad ;
			from ParametrosyRegistrosEspecificos ;
				where !empty( IdUnico ) ;
				group by IdUnico ;
				having Cantidad > 1 ;
			into cursor c_ValidacionUnicidadIdUnicoParametros
		scan
			This.oInformacionIndividual.AgregarInformacion( 'El campo "IdUnico" tiene repetido el valor ' + alltrim( c_ValidacionUnicidadIdUnicoParametros.IdUnico ) + ;
											" en la tabla ParametrosyRegistrosEspecificos.")
		endscan
		
		use in select( "c_ValidacionIdUnicoParametros" )
		use in select( "c_ValidacionUnicidadIdUnicoParametros" )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function Release() as Void
	
		local lcDeleted as String
		lcDeleted = this.cDeleted
		set deleted &lcDeleted
		dodefault()

	endfunc
	

	*-----------------------------------------------------------------------------------------
	function ValidarEspacios() as VOID

		select entidad from entidad where " "$ alltrim(entidad) into cursor C_EntidadConEspacios
		scan
			This.oInformacionIndividual.AgregarInformacion( "La Tabla Entidad tiene espacios en blanco en la Entidad " + C_EntidadConEspacios.Entidad + "." )
		endscan

		select entidad ;
			from diccionario ;
			where " " $ alltrim( Entidad ) or ;
				" " $ alltrim( Campo ) or ;
				" " $ alltrim( Atributo ) or ;
				" " $ alltrim( Tabla ) ;
			into cursor C_Diccionario

		scan
			This.oInformacionIndividual.AgregarInformacion( "La Entidad '" + C_Diccionario.entidad + ;
				"' tiene espacios en alguna de las siguientes columnas: Entidad, Campo, Atributo ó Tabla (Tabla Diccionario)." )
		endscan

		use in select( "C_EntidadConEspacios" )
		use in select( "C_Diccionario" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCamposObligatoriosEnDetalle() as VOID

		select distinc entidad from diccionario where "item" $ lower( Entidad ) into cursor C_Items
		select distinc entidad from diccionario where "item" $ lower( Entidad ) and obligatorio = .t. into cursor C_Obligatorios
		select entidad from c_items where entidad not in ( select entidad from C_obligatorios ) into cursor C_Diferencias
		
		scan
			This.oInformacionIndividual.AgregarInformacion( "El item " + alltrim(C_Diferencias.entidad) + ;
							" no tiene ningún atributo obligatorio (Tabla Diccionario)." )
		endscan
		
		use in select( "C_Items")
		use in select( "C_Obligatorios" )
		use in select( "C_Diferencias" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ValidarCampoMemoEnBusqueda() as VOID
		
		select entidad, atributo from diccionario where AdmiteBusqueda > 0 and tipodato = 'M' into cursor C_MemosEnBusqueda
		
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( C_MemosEnBusqueda.atributo ) + " de la entidad "  + ;
				alltrim( C_MemosEnBusqueda.entidad ) + " tiene campos Memo para la búsqueda (Tabla Diccionario)." )
		endscan
	
		use in select( "C_MemosEnBusqueda" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ValidarRelaNumeraciones() as VOID
		local lcMensaje as String
		
		select entidad, atributo from RelaNumeraciones into cursor C_RelaNum
		
		scan
			select diccionario
			locate for alltrim( upper( entidad ) ) == alltrim( upper( C_RelaNum.entidad ) ) and ;
				alltrim( upper( atributo ) ) == alltrim( upper( C_RelaNum.atributo ) )
			
			if found()
				if diccionario.tipodato != "N" and !inlist( alltrim( upper( diccionario.entidad ) ), "CRITERIOSVALORES", "CATEGORIASECOMMERCE", "ETIQUETASECOMMERCE" )
					This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( upper( C_RelaNum.atributo ) )  + " de la entidad "  + ;
							alltrim( C_RelaNum.entidad ) + " debería ser numérico (Tabla Diccionario)." )
				endif
			else
				lcMensaje = 'Entidad "' + alltrim( upper( C_RelaNum.entidad ) ) + '" - Atributo "' + alltrim( upper( C_RelaNum.atributo ) ) + ;
					'"  de RelaNumeraciones no existen en el Diccionario'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif 

			select C_RelaNum		
		endscan
		
		use in select( "C_RelaNum" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarClavePrimariayForaneaEnAtributosDeDetalles() as VOID
		
		select Diccionario.entidad, Diccionario.atributo, Diccionario.clavePrimaria, Diccionario.claveForanea ;
			from Diccionario ;
			inner join Entidad on ;
				alltrim( upper( Entidad.Entidad ) ) == alltrim( upper( Diccionario.Entidad ) ) and ;
				alltrim(upper(Entidad.tipo)) == "I" ;
			where diccionario.clavePrimaria = .t. and ;
				!empty( diccionario.claveForanea ) ;
			into cursor C_Detalles 
			
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( C_Detalles.atributo ) + " de la entidad "  + ;
						alltrim( C_Detalles.entidad ) + " tiene clave Primaria y Foránea simultaneamente (Tabla Diccionario)." )
		endscan

		use in select( "C_Detalles" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCampoObligatorioEnAtributoDetalle() as VOID
	
		select entidad, atributo ;
			from diccionario dic, dominio dom ;
			where obligatorio and upper( dic.dominio ) == upper( dom.Dominio ) and dom.detalle;
			into cursor c_DetallesObligatorios
		
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + proper( alltrim( c_DetallesObligatorios.atributo ) ) + " de la entidad "  + ;
						proper( alltrim( c_DetallesObligatorios.entidad ) ) + " no puede ser obligatorio." )
		endscan
		
		use in select( "c_detallesObligatorios" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarOrdenReglaDeNegocio() as VOID
	
		select entidad, atributo ;
			from diccionario dic ;
			where OrdenReglaNegocio < 0 ;
			into cursor c_OrdenReglaDeNegocio
		
		scan 
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + proper( alltrim( c_OrdenReglaDeNegocio.atributo ) ) + " de la entidad "  + ;
						proper( alltrim( c_OrdenReglaDeNegocio.entidad ) ) + " debe tener el Orden Regla de negocio mayor o igual a cero." )
		endscan

		use in select( "c_OrdenReglaDeNegocio" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ValidarEtiquetaCorta() As VOID

		Select entidad, atributo ;
			from diccionario ;
			where empty( etiquetacorta ) and alta and !"DETALLE"$upper(alltrim(dominio));
			into Cursor Cur_etiqueta

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion("El atributo " + Alltrim( Cur_etiqueta.Atributo ) + ;
					" de la entidad " + Alltrim( Cur_etiqueta.Entidad ) + " no tiene cargado la etiqueta corta" )
			Endscan
		Endif
		Use In select( "Cur_etiqueta" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarEtiquetaParaAtributosAuditables() as Void

		select d.Entidad, d.Atributo ;
			from ( this.cDiccionarioAdicional ) as d ;
			inner join ( this.cEntidadAdicional ) as e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where this.oFunc.TieneFuncionalidad( "AUDITORIA" , e.Funcionalidades ) and ;
			(empty( d.etiqueta ) or alltrim(d.etiqueta) == '.') and d.auditoria and !"DETALLE"$upper(alltrim(d.dominio)) ;
			into Cursor Cur_etiqueta
			
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion("El atributo " + Alltrim( Cur_etiqueta.Atributo ) + ;
					" que es auditable, no tiene cargado la etiqueta (Entidad:" + Alltrim( Cur_etiqueta.Entidad ) + ")"  )
			Endscan
		Endif
		Use In select( "Cur_etiqueta" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarCamposDuplicadosEnMismaTabla() as VOID
		local lcCampoAnterior as String, lcTablaAnterior as String 

		lcCampoAnterior = ""
		lcTablaAnterior = ""
		Select a.tabla, a.campo, a.tipodato, a.longitud, b.tipodato, b.longitud ;
			from diccionario a ;
				inner join diccionario b;
					on upper( rtrim( a.campo ) ) = upper( rtrim( b.campo ) ) and upper( rtrim( a.tabla ) ) = upper( rtrim( b.tabla ) ) ;
			where ( a.tipodato # b.tipodato or a.longitud # b.longitud ) ;
				and !( empty( a.campo ) or empty( a.tabla ) ) ;
			into Cursor Cur_Cantidad
		
		select distinct * from Cur_Cantidad order by Tabla, Campo into cursor Cur_Cantidad readwrite

		If reccount( "Cur_Cantidad" ) > 0
			scan
				if lcCampoAnterior != upper( alltrim( Cur_Cantidad.campo ) ) and lcTablaAnterior != upper( alltrim( Cur_Cantidad.tabla ) )
					This.oInformacionIndividual.AgregarInformacion( "Se encontraron campos duplicados para la misma tabla, " + ;
							"con diferente tipo de datos y/o longitud:" + chr( 10 ) + ; 
							"Tabla: " + alltrim( Cur_Cantidad.tabla ) + chr( 10 ) + ; 
							"Campo: " + alltrim( Cur_Cantidad.campo ) + chr( 10 ) + ; 
							"Tipo de dato 1: " + alltrim( Cur_Cantidad.tipodato_a ) + chr( 10 ) + ; 
							"Tipo de dato 2: " + alltrim( Cur_Cantidad.tipodato_b ) + chr( 10 ) + ; 
							"Longitud 1: " + alltrim( str( Cur_Cantidad.longitud_a ) ) + chr( 10 ) + ; 
							"Longitud 2: " + alltrim( str( Cur_Cantidad.longitud_b ) ) + chr( 10 ) )
					lcCampoAnterior = upper( alltrim( Cur_Cantidad.campo ) )
					lcTablaAnterior = upper( alltrim( Cur_Cantidad.tabla ) )
				endif
			Endscan
		endif

		Use In select( "Cur_Cantidad" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosGenericos() as Void

		Select a.entidad, a.Atributo, a.tipodato, a.longitud, a.decimales, a.campo,;
				b.Atributo, b.tipodato, b.longitud, b.decimales, b.campo ;
			from diccionario a ;
				inner join AtributosGenericos b	on alltrim( upper( a.Atributo ) ) == alltrim( upper( b.Atributo ) ) ;
				inner join Entidad e on alltrim( upper( a.entidad ) ) == alltrim( upper( e.entidad ) ) ;				
			where ( a.tipodato # b.tipodato or a.longitud # b.longitud  or a.decimales # b.decimales or a.campo # b.campo ) and ;
					atc( "E", b.Tipo ) > 0 and e.Tipo = "E" ;
		union( ;
			Select a.entidad, a.Atributo, a.tipodato, a.longitud, a.decimales, a.campo,;
					b.Atributo, b.tipodato, b.longitud, b.decimales, b.campo ;
				from diccionario a ;
					inner join AtributosGenericos b	on alltrim( upper( a.Atributo ) ) == alltrim( upper( b.Atributo ) ) ;
					inner join Entidad e on alltrim( upper( a.entidad ) ) == alltrim( upper( e.entidad ) ) ;				
				where ( a.tipodato # b.tipodato or a.longitud # b.longitud  or a.decimales # b.decimales or a.campo # b.campo ) and ;
						atc( "I", b.Tipo ) > 0 and e.Tipo = "I" ;
			) ;
		into Cursor Cur_Diferencias

		If _Tally > 0
			local lcEnter as String
			lcEnter = chr( 13 ) + chr( 10 )
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Entidad:" + alltrim( Cur_Diferencias.entidad ) + ;
						"Campo(D): " + alltrim( Cur_Diferencias.campo_a ) + lcEnter + ;
						"Campo(A): " + alltrim( Cur_Diferencias.campo_b ) + lcEnter + ;
						"Tipo de dato(D): " + alltrim( Cur_Diferencias.tipodato_a ) + lcEnter + ;
						"Tipo de dato(A): " + alltrim( Cur_Diferencias.tipodato_b ) + lcEnter + ;
						"Decimales(D): " + transform( Cur_Diferencias.decimales_a ) + lcEnter + ;
						"Decimales(A): " + transform( Cur_Diferencias.decimales_b ) + lcEnter + ;
						"Longitud(D): " + transform( Cur_Diferencias.longitud_a  ) + lcEnter + ;
						"Longitud(A): " + transform( Cur_Diferencias.longitud_b  ) )

			Endscan
		Endif
		Use In select( "Cur_Diferencias" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDatosDeAtributosForaneosVsDatosDeAtributosPrimarios() as VOID
		Local lcMensaje As String

		select 	upper( dic1.entidad ) as Entidad, ;
				upper( dic1.atributo ) as Atributo, ;
				alltrim( upper( dic1.tipodato ) ) as tipodato, ;
				dic1.longitud, ;
				dic1.decimales, ;
				dic3.entidad as entidad_primaria, ;
					dic3.atributo as atributo_primario ;
					from diccionario as dic1 ;
					left join diccionario as dic2 on upper( getwordnum( dic1.atributoforaneo , OCCURS( ".", dic1.atributoforaneo  ), "." ) ) = upper( dic2.atributo ) and dic1.entidad = dic2.entidad ;
					left join diccionario as dic3 on dic2.claveforanea = dic3.entidad and upper( dic3.atributo ) = upper( getwordnum( dic1.atributoforaneo , OCCURS( ".", dic1.atributoforaneo  )+1, "." ) );
					where !empty( alltrim( dic1.atributoforaneo ) ) and empty( alltrim( dic1.claveforanea ) ) ;
				into cursor c_Verificar1

		select c_verificar1.* ;
			from c_verificar1 where c_verificar1.entidad_primaria not in ( select upper( entidad.entidad ) from entidad ) ;
			into cursor c_NoSonEntidad

		select c_verificar1.* ;
			from c_verificar1 where c_verificar1.entidad_primaria in ( select upper( entidad.entidad ) from entidad ) ;
		union all ;
		select c_NoSonEntidad.Entidad, c_NoSonEntidad.Atributo, c_NoSonEntidad.TipoDato, c_NoSonEntidad.Longitud, c_NoSonEntidad.Decimales, upper( diccionario.claveforanea ) as Entidad_Primaria, c_NoSonEntidad.Atributo_primario ;
			from c_NoSonEntidad inner join diccionario on upper( c_NoSonEntidad.entidad ) = upper( diccionario.entidad ) and upper( c_NoSonEntidad.entidad_primaria ) = upper( diccionario.atributo ) ;
		union all ;
		select upper( entidad ) as Entidad, upper( atributo ) as Atributo, alltrim( upper( tipodato ) ) as tipodato, longitud, decimales, ;
				upper( left( alltrim( atributo ), len( alltrim( atributo ) ) - 7 ) ) as entidad_primaria, ;
				'DESCRIPCION' as atributo_primario ;
			from diccionario ;
				where upper( left( alltrim ( entidad ), 4 ) ) == 'ITEM' and ;
					upper( right( alltrim ( atributo ), 7 ) ) == 'DETALLE' and ;
					empty( alltrim( atributoforaneo ) ) and empty( alltrim( claveforanea ) ) ;
			into cursor c_Verificar
		
		select c_Verificar.*, alltrim( upper( diccionario.tipodato ) ) as tipodato_primario, diccionario.longitud as longitud_primaria, diccionario.decimales as decimales_primarios ;
			from c_Verificar left join diccionario ;
			on alltrim(upper(entidad_primaria)) == alltrim(upper(diccionario.entidad)) and alltrim(upper(atributo_primario)) == alltrim(upper(diccionario.atributo)) ;
			where c_Verificar.tipodato # diccionario.tipodato or c_Verificar.longitud # diccionario.longitud or c_Verificar.decimales # diccionario.decimales ;
			into cursor c_Final

		if _tally > 0
			lcMensaje = ""
			scan all
				lcMensaje = 'Error en los datos de la Entidad "' + alltrim( upper( C_final.Entidad ) ) + '", Atributo "' + alltrim( upper( C_final.Atributo ) ) + '" - ' + ;
							'El TIPO(' + alltrim( C_final.TipoDato ) + '), LONGITUD(' + transform( C_final.Longitud ) + ') o DECIMALES(' + transform( C_final.Decimales ) + '); ' + ;
							'No coninciden con los de la entidad primaria "' + alltrim( upper( C_final.Entidad_primaria ) ) + '", atributo "' + alltrim( upper( C_final.Atributo_primario ) ) + '" - ' + ;
							'TIPO(' + alltrim( C_final.TipoDato_primario ) + '), LONGITUD(' + transform( C_final.Longitud_primaria ) + ') y DECIMALES(' + transform( C_final.Decimales_primarios ) + ')'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				select C_final
			EndScan					
		endif

		use in select( "C_final" )	
		use in select( "C_Verificar" )
		use in select( "C_Verificar1" )
		use in select( "C_NoSonEntidad" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ValidarUnicidadEnRelaNumeraciones() as VOID
		local lcMensaje As String

		select upper( Entidad ) as NomEntidad, upper( Atributo ) as NomAtributo, servicio, count( * ) as cantidad from RelaNumeraciones ;
			group by NomEntidad, NomAtributo, servicio having cantidad > 1 ;
			into cursor c_Final

		if _tally > 0
			lcMensaje = ""
			
			select c_Final
			scan
				lcMensaje = 'Entidad "' + alltrim( C_final.NomEntidad ) + '" - Atributo "' + alltrim( C_final.NomAtributo ) + '" ya fueron cargados en RelaNumeraciones'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				
				select C_final
			EndScan					
		endif

		use in select( "C_final" )	
	endfunc 	
	*-----------------------------------------------------------------------------------------
	function ValidarEntidadCAINoPuedeTenerNumeracionesLaClaveCandidataYLaClavePrimaria() as VOID
		local lcMensaje As String

		select distinct r.Entidad, count(*) as cantidad from RelaNumeraciones r ;
			inner join diccionario d on upper( alltrim( r.Entidad ) ) == upper( alltrim( d.Entidad ) ) and ;
				 upper( alltrim( r.Atributo ) ) == upper( alltrim( d.Atributo ) ) and ;
				 ( d.ClavePrimaria or !empty( d.ClaveCandidata ) ) ;
			inner join entidad e on upper( alltrim( r.Entidad ) ) == upper( alltrim( e.Entidad ) ) and "<CAI>" $ upper( e.Funcionalidades );
			group by r.Entidad having cantidad > 1 ;
			into cursor c_Final

		if _tally > 0
			lcMensaje = ""
			
			select c_Final
			scan 
				lcMensaje = 'Le entidad ' + alltrim( upper( C_final.Entidad ) ) + ' tiene asociado un talonario a la clave primaria y a la clave candidata'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				
				select C_final
			EndScan					
		endif

		use in select( "C_final" )	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoIdentificadorDeLaTablaEntidad() as VOID
		local lcMensaje As String, lcEntidades as string

		select distinct Entidad as NomEntidad from Entidad ;
				where upper( alltrim( Tipo ) ) == "E" and empty( Identificador ) ;
			into cursor c_Final

		if _tally > 0
			lcMensaje = ""
			
			select c_Final
			scan
				lcMensaje = 'La Entidad "' + alltrim( C_final.NomEntidad ) + '" no tiene cargado el campo "Identificador"'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				select C_final
			EndScan					
		endif
		use in select( "C_final" )	
		
		select Identificador as NomIdentificador, count( Identificador ) as Cant from Entidad ;
				where upper( alltrim( Tipo ) ) == "E" and !empty( Identificador ) ;
				group by NomIdentificador having Cant > 1 ;
			into cursor c_Final

		if _tally > 0
			lcMensaje = ""
			
			select c_Final
			scan
				lcEntidades = ""
				select distinct Entidad from Entidad ;
					where upper( alltrim( Identificador ) ) == upper( alltrim( c_Final.NomIdentificador ) ) ;
					into cursor c_Aux
				scan
					lcEntidades = lcEntidades + "," + upper( alltrim( c_Aux.Entidad ) )
				endscan
				lcEntidades = substr( lcEntidades, 2 )
				
				lcMensaje = 'El Identificador "' + alltrim( C_final.NomIdentificador ) + '" está cargado en las entidades "' + lcEntidades + '" y debe ser único'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )

				select C_final
			EndScan					
		endif

		use in select( "C_final" )	
		use in select( "c_Aux" )	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFiltrosParaTransferenciasAgrupadas() as VOID
		local lcEntidad as String, lcAtributo as String 
		

		*-- Validar transferenciasfiltros
		select transferenciasfiltros
		scan
			
			lcEntidad = upper( alltrim( transferenciasfiltros.Entidad ) ) 
			lcAtributo = upper( alltrim( transferenciasfiltros.Atributo ) ) 
			
			*-- Verifico que exista la Entidad
			if This.ExisteEntidadParaFiltros( lcEntidad )
			else
				lcMensaje = 'No Existe la Entidad ' + lcEntidad + ' Indicada en los Filtros de Transferencia Agrupada.'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
			
			if This.ExisteAtributoParaFiltros( lcEntidad, lcAtributo )
			else
				lcMensaje = 'No Existe el Atributo ' + lcAtributo + ' de la Entidad ' + lcEntidad + ;
																' Indicado en los Filtros de Transferencia Agrupada.'
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
		
		endscan	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarEntidadAtributosTransferenciaAgrupada() as VOID
		local lcMensaje As String, lcEntidad as String, lcAtributo as String, lcNombreTransferenciaAgrupada as String ,;
		 llOk as boolean, lcCursor as string

		lcCursor = "c_" + sys( 2015 )

		select transferenciasagrupadas
		scan
			lcNombreTransferenciaAgrupada = upper( alltrim( transferenciasagrupadas.descripcion ) ) 
			lnIdTransferenciaAgrupada = transferenciasagrupadas.id
			
			*-- Validar transferenciasagrupadasitems
			select transferenciasagrupadasitems
			scan for transferenciasagrupadasitems.id = lnIdTransferenciaAgrupada
				lcEntidad = upper( alltrim( transferenciasagrupadasitems.Entidad ) )

				llOk = This.ExisteEntidad( lcEntidad )
				if llOk
				else
					select codigo from transferencias where upper( alltrim( codigo ) ) == upper( alltrim( lcEntidad ) ) into cursor &lcCursor
					llOk = _tally > 0
					use in select( lcCursor )
				endif
				
				if llOk
				else
					lcMensaje = 'No Existe la Entidad/Transferencia adicional ' + alltrim( lcEntidad ) + ' Indicada en la Transferencia Agrupada ' + lcNombreTransferenciaAgrupada
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endscan
		endscan	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteEntidad( tcEntidad as String ) as Boolean
		local lcNombreCursor as string, llExistenDatos as Boolean
		
		lcNombreCursor = "c_" + sys( 2015 )

		select Descripcion from entidad where upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) into cursor &lcNombreCursor
		if _tally > 0
			llExistenDatos = .t.
		endif
		use in select( lcNombreCursor )

		return llExistenDatos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteEntidadParaFiltros( tcEntidad as String ) as Boolean
		local llExistenDatos as Boolean
		llExistenDatos = .t.
		if !this.ExisteEntidad( tcEntidad )
			select Descrip from transferencias where upper( alltrim( codigo ) ) == upper( alltrim( tcEntidad ) ) into array laArray
			if _tally = 0
				llExistenDatos = .f.
			endif
		endif
		return llExistenDatos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributo( tcEntidad as String, tcAtributo as String ) as Boolean
		local lcNombreCursor as string, llExistenDatos as Boolean
		
		llExistenDatos = .F.
		lcNombreCursor = "c_" + sys( 2015 )

		select Entidad from diccionario where upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) )and ;
							upper( alltrim( Atributo ) ) == upper( alltrim( tcAtributo ) ) into cursor &lcNombreCursor

		if _tally > 0
			llExistenDatos = .t.
		else
			select * from AtributosGenericos where upper( alltrim( Atributo ) ) == upper( alltrim( tcAtributo ) ) into cursor &lcNombreCursor
			if _Tally > 0
				llExistenDatos = .t.
			Endif	
		endif
		use in select( lcNombreCursor )

		return llExistenDatos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributoParaFiltros( tcEntidad as String, tcAtributo as String ) as Boolean
		local llExistenDatos as Boolean
		llExistenDatos = .T.
		if ! this.ExisteAtributo( tcEntidad, tcAtributo )
			select t.entidad ;
			 from transferencias t ;
			  inner join diccionario d on upper( alltrim( t.entidad ) ) = upper( alltrim( d.entidad ) ) ;
			 where upper( alltrim( t.codigo ) ) == upper( alltrim( tcEntidad ) ) ;
			   and upper( alltrim( d.atributo ) ) == upper( alltrim( tcAtributo ) ) ;
			 into array laArray
			if _tally = 0
				llExistenDatos = .f.
			endif
		endif
		return llExistenDatos
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function validarCamposVotacion() as VOID
		local lcCursor as String 
		
		lcCursor = sys( 2015 )

		select d.entidad, d.atributo, rela.componente ;
			from diccionario d ;
				left join relacomponente rela on upper( alltrim( d.entidad ) ) = upper( alltrim( rela.entidad ) ) ;
			 where d.validacomp ;
			 having isnull( rela.componente ) ;
			 into cursor &lcCursor
		
		select(lcCursor)
		
		scan 
			This.oInformacionIndividual.AgregarInformacion( "Error en la entidad '" + alltrim( entidad ) + "' atributo '" + alltrim( atributo ) + ;
					"'.Tiene diccionario.validaComp y no tiene componente relacionado." )
		endscan 
				
		use in select( lcCursor )	
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosUnicosEnEstetica() as VOID
		local lcCursor as String
		lcCursor = sys( 2015 )
		select atributo, entidad, estetica, count(*) as Cantidad ;
				from diccionario ;
				group by entidad, estetica ;
				having Cantidad = 1 ;
				where !empty(estetica) ;
				into cursor &lcCursor
			
		select ( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El Atributo " + upper( alltrim( &lcCursor..atributo ) ) + " de la entidad " + ;
						upper( alltrim( &lcCursor..entidad ) ) + " no puede ser el unico atributo en el grupo estetica (" + ;
						alltrim( &lcCursor..estetica ) + ")." ) 
		
		endscan			

		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCamposDuplicadosIdEnMenuPrincipal() as VOID
		Local lcCursor as String 

		lcCursor = sys( 2015 )

		select id as pk, count(*) as cantidad ;
			from menuprincipal ;
			group by pk ;
			having cantidad > 1;
			into Cursor ( lcCursor )

		select ( lcCursor )
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Se encontraron campos repetidos en la tabla MenuPrincipal: " + ;
						 chr( 10 ) + chr( 13 ) + "Id: " + alltrim( str( &lcCursor..pk ) ) + " - Cantidad: " + alltrim( str( &lcCursor..cantidad ) ) + "." )
			Endscan
		Endif
		Use In ( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCamposDuplicadosIdEnMenuPrincipalItems() as VOID
	
		Local lcCursor as String 
		lcCursor = sys( 2015 )

		select id as pk, count(*) as cantidad ;
			from menuprincipalitems ;
			group by pk ;
			having cantidad > 1;
			into Cursor ( lcCursor )

		select ( lcCursor )
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Se encontraron campos repetidos en la tabla MenuPrincipalItems: " + ;
						 chr( 10 ) + chr( 13 ) + "Id: " + alltrim( str( &lcCursor..pk ) ) + " - Cantidad: " + alltrim( str( &lcCursor..cantidad ) ) + "." )
			Endscan
		Endif
		Use In ( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCamposDuplicadosIdPorEntidadEnMenuAltasItems() as VOID
	
		Local lcCursor as String 
		lcCursor = sys( 2015 )

		select id as pk, entidad, count(*) as cantidad ;
			from menualtasitems ;
			group by pk, entidad ;
			having cantidad > 1;
			into Cursor ( lcCursor )

		select ( lcCursor )
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Se encontraron campos repetidos para una misma entidad en la tabla MenuAltasItems: " ;
						 + chr( 10 ) + chr( 13 ) ;
						 + "Id: " + alltrim( str( &lcCursor..pk ) ) ;
						 + "  Entidad: " + alltrim( &lcCursor..entidad ) ;
						 + " - Cantidad: " + alltrim( str( &lcCursor..cantidad ) ) + "." )
			Endscan
		Endif
		Use In ( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------

	Function ValidarTieneSeguridadMenu() as VOID
		select a.id as idpral, a.lTieneSeguridad as SegPral, a.Etiqueta as EtiquetaPral, a.orden as ordenPadre, b.id as idItem, ;
			b.lTieneSeguridad  as SegItem, b.Etiqueta  as EtiquetaItem ;
		from menuprincipal a ;
			right join menuprincipalitems b on a.id = b.idPadre ;
		into cursor c_ValidarTieneSeguridadMenu_CURSOR readwrite

		***** Se agrega esta excepcion para el primer menu de la aplicacion. Esto es para que el menu sistema pueda tener seguridad y no obligue
		***** a todos sus hijos a tenerla.
		select top 1 id from menuprincipal ;
			where alltrim(upper(strtran( etiqueta, '\<', ''))) == 'SISTEMA' ;
			order by orden into cursor c_PrimerElemento readwrite
			
		select c_ValidarTieneSeguridadMenu_CURSOR

		scan for (( c_ValidarTieneSeguridadMenu_CURSOR.SegPral and !c_ValidarTieneSeguridadMenu_CURSOR.SegItem ) or ;
				( !c_ValidarTieneSeguridadMenu_CURSOR.SegPral and c_ValidarTieneSeguridadMenu_CURSOR.SegItem )) and c_PrimerElemento.id != c_ValidarTieneSeguridadMenu_CURSOR.idPral 
		
			This.oInformacionIndividual.AgregarInformacion( "No concuerda la configuración de seguridad del menú. Item: (Id:" + trans( iditem ) + ") " + ;
					alltrim( strtran( EtiquetaItem, "\<", "" ) ) + " Tiene seguridad: " + iif( SegItem , "SI", "NO" ) + " - Padre: (Id:" +;
				 trans( idpral ) + ") " + alltrim( strtran( EtiquetaPral, "\<", "" ) ) + " Tiene seguridad: "+iif( SegPral , "SI", "NO" ) )
				 
		endscan

		use in select( "c_ValidarTieneSeguridadMenu_CURSOR" )
		use in select( "c_PrimerElemento" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarUsoEntidadVersionV1() as Void

		local lcCursor as String
		lcCursor = sys( 2015 )
		
		select Entidad ;
			from entidad ;
			where version = 1 ;
			into cursor &lcCursor

		select ( lcCursor )
		scan 
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Entidad ) + " es V1." )
		endscan

		use in select( lcCursor )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAdnAuditoria() as VOID
		local lcCursor as String, lcTablaEntidad as String, lcCursor2 as String, llTengoAuditoria as Boolean, ;
			lcDiccionarioAdicional as String
		llTengoAuditoria = .F.
		lcCursor = sys( 2015 )
		lcCursor2 = sys( 2015 )
		lcDiccionarioAdicional = this.cDiccionarioAdicional

		select entidad
		scan for this.oFunc.TieneFuncionalidad("AUDITORIA" , Funcionalidades )
			llTengoAuditoria = .T.
			select * from &lcDiccionarioAdicional d ;
				where alltrim( upper( d.entidad ) ) == alltrim( upper( entidad.entidad ) ) and d.auditoria ;
				into cursor &lcCursor 
				
			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( Entidad.Entidad ) + " no tiene atributos que auditar" )
			else
				select ( lcCursor )
				locate for claveprimaria
				if found()
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + alltrim( Entidad.Entidad ) + " - no se puede auditar la clave primaria" )
				endif
				
				select ( lcCursor )
				locate for !empty( clavecandidata )
				if found()
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + alltrim( Entidad.Entidad ) + " - no se puede auditar la clave candidata" )
				endif
				
				select ( lcCursor )
				locate for empty( tabla ) or empty( campo )
				if found()
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + alltrim( Entidad.Entidad ) + " - no se puede auditar atributos  virtuales" )
				endif
				
				select &lcDiccionarioAdicional
				locate for alltrim( upper( &lcDiccionarioAdicional..entidad ) ) == alltrim( upper( entidad.entidad ) ) and claveprimaria
				lcTablaEntidad = &lcDiccionarioAdicional..tabla
				
				select ( lcCursor )
				locate for !empty( atributoForaneo ) and upper( alltrim( tabla ) ) # upper( alltrim( lcTablaEntidad ) )
				if found()
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + alltrim( Entidad.Entidad ) + ;
																	" - no se pueden auditar campos foraneos que graban en otras tablas" )
				endif
				
				select ( lcCursor )
				locate for tipodato = "M"
				if found()
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + alltrim( Entidad.Entidad ) + " - no se puede auditar atributos del tipo Memo" )
				endif
							
			endif 			
			use in select( lcCursor )
			select entidad
		endscan
		
		select distinct tabla, campo from &lcDiccionarioAdicional where auditoria into cursor &lcCursor2
		select tabla , count( * ) as cn from &lcCursor2 group by tabla having cn > 200 into cursor &lcCursor2
		select ( lcCursor2 )
		scan all
			This.oInformacionIndividual.AgregarInformacion( "Tabla: " + alltrim( &lcCursor2..tabla ) + " - no se puede auditar mas de 200 atributos" )
		endscan
		use in select( lcCursor2 )
		
		if llTengoAuditoria

			select transferenciasagrupadas
			locate for upper( alltrim ( descripcion ) ) = "AUDITORIAS"
			if !found()
				This.oInformacionIndividual.AgregarInformacion( "Falta el nodo de auditorias en TransferenciasAgrupadas" )
			endif
		
		endif
		
						
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ValidarTablasAuditoria() as VOID
		select distinct entidad, tabla from diccionario where upper( left( tabla, len( this.cPrefijoAuditoria ) ) ) = this.cPrefijoAuditoria into cursor c_TablaAudi
		select c_TablaAudi
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " +  alltrim( upper( c_TablaAudi.Entidad ) ) + " tiene una tabla con prefijo '" + upper( this.cPrefijoAuditoria ) + "' reservado para auditoria" )
		endscan
		use in select( "c_TablaAudi" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCampoComportamiento() as VOID
		local lcLetra as String 
		
		select Entidad
		scan for !empty( comportamiento )
			for i = 1 to len( alltrim( Comportamiento ) )
				lcLetra = substr( upper( Comportamiento ), i, 1 )
				
				if inlist( lcLetra , "T" , "B", "C", "W", "X", "G", "D" )
				else
					This.oInformacionIndividual.AgregarInformacion( "La entidad " +  alltrim( upper( Entidad ) ) + ;
							" tiene un valor incorrecto en campo Comportamiento(" + ;
							alltrim( upper( lcLetra ) ) + ")" )
				endif
			endfor
		endscan

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarItemsConAuditoria() as VOID
		local lcCursor as String
		lcCursor = "c" + sys( 2015 )
		
		select Entidad ;
				from Entidad ;
				where this.oFunc.TieneFuncionalidad("AUDITORIA" , Funcionalidades ) and upper( alltrim( Tipo ) ) == "I" ;
				into cursor &lcCursor
				
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El Detalle " +  alltrim( upper( Entidad ) ) + ;
										" no puede ser Auditado." )
			
		endscan
		use in select ( lcCursor )
		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ValidarCampoFuncionalidades() as VOID

		local lcCursor as String, i as Integer
		lcCursor = "c" + sys( 2015 )

		select Entidad, Funcionalidades ;
			from entidad ;
			where !empty( Funcionalidades ) ;
			into cursor &lcCursor

		select( lcCursor )
		scan
			lcCampoFuncionalidad = alltrim( evaluate( lcCursor + "." + "Funcionalidades" ) )
			if at( " ", lcCampoFuncionalidad ) > 0
				This.oInformacionIndividual.AgregarInformacion( "El campo Funcionalidad de la " +  alltrim( upper( Entidad ) ) + " no puede contener espacios." )
			endif
			
			lcCampoFuncionalidad = chrtran( lcCampoFuncionalidad, "<>", ",," )
			for i = 1 to getwordcount( lcCampoFuncionalidad, "," )
				if len( getwordnum( lcCampoFuncionalidad, i, "," ) ) != 0
					lcTag = getwordnum( lcCampoFuncionalidad, i, "," )
					if at( ":", lcTag ) > 0
						lcTag = left( lcTag, at( ":", lcTag ) - 1 )
					endif

					if	!inlist( lcTag, "AUDITORIA", "ANULABLE", "NOEXPO", "LINCE", "NOIMPO", "HABILITARIMPOINSEGURA", "PICKING", "ENTIDADNOEDITABLE", "RELAENTIDAD", "INTERVINIENTE" , "CANCOMPRA" ) and ;
						!inlist( lcTag, "BLOQUEARREGISTRO", "CAI", "TRANSMODOSEGUROCEN", "TRANSMODOSEGURODB", "PAIS", "GUARDARCOMO", "EXPOGENERICA", "IMPOGENERICA", "MIPYME" ) and  ;
						!inlist( lcTag, "NOLOGUEAR" ,"MODULOSLISTADO", "SINTOOLBAR", "VENTAS", "COMPRAS", "FISCAL", "CONVALORES", "CF", "INFOADICIONAL", "ACTUALIZAEMAILCLIENTE", "MIPYMEORIGINAL" ) and ;
						!inlist( lcTag, "CE", "CODIGOSUGERIDO", "TRANSFERALTAS", "COMPR_CAJA", "DESACTIVABLE", "NOLISTAGENERICO", "PROMO", "PROMO_PRINCIPAL", "NOSALTODECAMPO", "LISTARTODOSSUSATRIBUTOS", "EXCLUIRFILTROS", "FRMMODAL" ) and ;
						!inlist( lcTag, "BAJALOGICA", "FORZARLISTARGENERICO", "RECEPCIONBULK", "INSERTCONTINUO", "IMPOSEGURACONCORTE", "PUBLICA", "VALIDACENTRALIZADOR", "CONTROLARFECHAHORAENRECEPCION", "EDICIONPARCIAL" ) and;
						!inlist( lcTag, "VALORCIERRE", "COMPLETADESDEVENTAS", "NORECEPCIONABLE" , "IMPOBULKCONVALIDACIONES", "DESCUENTOAUTOMATICO", "NOREST", "BUSCAENALTAS", "SINATRIBUTOSFW", "FILTROESPECIFICO", "AGRUPACOMPROBANTES" ) and;
						!inlist( lcTag, "PAQRECURSIVO", "LISTARMODIFICACION", "OCULTARNODOEXPO", "WEBHOOK", "PERSONALIZA", "FORZARREST", "LISTARCON", "REALTIME" )

						This.oInformacionIndividual.AgregarInformacion( "La etiqueta " + getwordnum( lcCampoFuncionalidad, i, "," ) + " del campo Funcionalidad de la entidad " +  alltrim( upper( Entidad ) ) + " no es correcto." )
					endif
				endif
			endfor
			
		endscan
		use in select ( lcCursor )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarEntidadConFuncionalidadGuardarComoEnToolbar() as VOID

		local lcCursorEntidad as String, lcCursorMenuAltasItems as String, lcCursor as String, i as Integer

		lcCursor = "c_" + sys( 2015 )
		lcCursorEntidad = "ce_" + sys( 2015 )
		lcCursorMenuAltasItems = "cmai_" + sys( 2015 )

		select Entidad as Entidad_e;
			from entidad ;
			where "GUARDARCOMO" $ upper( alltrim( Funcionalidades ) ) ;
			into cursor &lcCursorEntidad
		select Entidad as Entidad_mai, Codigo, toolbar ;
			from Menualtasitems ;
			where "GUARDARCOMO" $ upper( alltrim( Codigo ) ) ;
			into cursor &lcCursorMenuAltasItems

		select * from &lcCursorEntidad e ;
			left join &lcCursorMenuAltasItems m ;
				on alltrim( upper( e.entidad_e ) ) = alltrim( upper( m.entidad_mai ) ) ;
			into cursor &lcCursor
				
		select( lcCursor )
		scan
			if isnull( Entidad_mai )
				if  This.cProyectoActivo = 'ZL' and inlist( alltrim( upper( Entidad_e ) ), 'OPORTUNIDAD', 'OPORTUNIDADSLR')
				else
					This.oInformacionIndividual.AgregarInformacion( "La Entidad " +  alltrim( upper( Entidad_e ) ) + ", con funcionalidad Guardar Como, debería tener su registro en la tabla Menualtasitems." )
				endif 	
			else
				if !Toolbar
					This.oInformacionIndividual.AgregarInformacion( "El campo Toolbar de la tabla Menualtasitems, para la Entidad " +  alltrim( upper( Entidad_e ) ) + " con funcionalidad Guardar Como, debería estar en T para ser visible." )
				Endif
			endif						
		endscan

		use in select ( lcCursor )

		select * from &lcCursorEntidad e ;
			right join &lcCursorMenuAltasItems m ;
				on alltrim( upper( e.entidad_e ) ) = alltrim( upper( m.entidad_mai ) ) ;
			into cursor &lcCursor
				
		select( lcCursor )
		scan
			if isnull( Entidad_e )
				This.oInformacionIndividual.AgregarInformacion( "La Entidad " +  alltrim( upper( Entidad_mai ) ) + " no tiene el tag GUARDARCOMO en el campo funcionalidades de la tabla Entidad." )
			endif						
		endscan

		use in select ( lcCursor )
		use in select ( lcCursorEntidad )
		use in select ( lcCursorMenuAltasItems )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarLongitudNombreCampo() as VOID
		local llErrores As boolean 
	
		llErrores = .F.
		
		select Entidad, Tabla, Campo, len( alltrim( Campo ) ) as Longitud ;
			from diccionario ;
			where !empty( tabla );
		into cursor c_LongitudCampo 

		select c_LongitudCampo 
		scan for Longitud > 10
			This.oInformacionIndividual.AgregarInformacion( "Error en la longitud del nombre de un campo: " + ;
										"Entidad: " + alltrim( c_LongitudCampo.Entidad ) + " - " + ;			
										"Tabla: " + alltrim( c_LongitudCampo.Tabla ) + " - " + ;
										"Campo: " + alltrim( c_LongitudCampo.Campo ) + " - " + ;
										"Longitud: " + transform( c_LongitudCampo.Longitud ) )
			llErrores  =.T.							
		endscan


		if llErrores
			This.oInformacionIndividual.AgregarInformacion( "La longitud del nombre del campo no debe exceder los 10 caracteres." + chr(10) + chr(13) )
		endif 	

		use in select( "c_LongitudCampo" )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidadDeAutoincrementales() as Void
		local lcRutaInicial as String, lcProyecto as String, lcCantidadIncrementales as Integer , ;
				lcCantidadIncrementalesActual as Integer, llControlar as Boolean
		
		lcRutaInicial = addbs( This.cRutaInicial )
		lnInicioProyecto = rat( "\" , lcRutaInicial, 2 )
		lcProyecto = This.cProyectoActivo
		llControlar = .T.
		select * from diccionario where tipodato = 'A' into cursor c_cantidadAutoincrementales
		lcCantidadIncrementales = _tally
		lcCantidadIncrementalesActual = 0
* El valor de lcCantidadIncrementalesActual no se pueden incremental, solo decremental. 
* HAY QUE HACER DESAPARECER LOS AUTOINCREMENTALES
		do case
			case lcProyecto = 'NUCLEO'
				lcCantidadIncrementalesActual = 0
				
			case lcProyecto = 'DIBUJANTE'
				lcCantidadIncrementalesActual = 0
				
			case lcProyecto = 'GENERADORES'
				lcCantidadIncrementalesActual = 2
				
			case lcProyecto = 'FELINO'
				lcCantidadIncrementalesActual = 9

			case lcProyecto = 'TELAS'
				lcCantidadIncrementalesActual = 3
				
			case lcProyecto = 'LINCEORGANIC'
				lcCantidadIncrementalesActual = 0

			case lcProyecto = 'ADNIMPLANT'
				lcCantidadIncrementalesActual = 0

			case lcProyecto = 'ZUPDATE'
				lcCantidadIncrementalesActual = 0

			otherwise
				llControlar = .F.

		endcase
		if llControlar
			if lcCantidadIncrementales = lcCantidadIncrementalesActual
			else
				This.oInformacionIndividual.AgregarInformacion( "Vario la cantidad de campos autoincrementales. Existen :" +;
						 transform( lcCantidadIncrementalesActual ) + " Ahora hay :" + transform( lcCantidadIncrementales ) )
			endif
		endif
		use in select( "c_cantidadAutoincrementales" )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarLongitudCamposAutoIncrementales() as Void
		local llErrores As boolean 

		llErrores = .F.
		
		select d.Entidad, Atributo, TipoDato, Longitud, Decimales, ClavePrimaria, Tipo ;
			from diccionario d ;
				inner join entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( tabla ) and TipoDato = "A" ;
		into cursor c_CamposAutoInc
		select c_CamposAutoInc
		scan all
		
			do case
				case Longitud # 9 or !empty( Decimales )
					This.oInformacionIndividual.AgregarInformacion( "Error en la longitud de campo autoincremental." + ;
						"Entidad: " + alltrim( c_CamposAutoInc.Entidad ) + " - " + ;
						"Atributo: " + alltrim( c_CamposAutoInc.Atributo ) )
					llErrores  = .T.
				
				case ClavePrimaria and upper( Tipo ) = "E"
					llErrores = This.ValidarLongitudCamposAutoincrementalesEnClaveForanea( c_CamposAutoInc.Entidad ) or llErrores
					llErrores = This.ValidarLongitudCamposAutoincrementalesEnItems( c_CamposAutoInc.Entidad ) or llErrores

				case ClavePrimaria and upper( Tipo ) = "I"
					This.oInformacionIndividual.AgregarInformacion( "El atributo no puede ser autoincremental." + ;
						"Entidad: " + alltrim( c_CamposAutoInc.Entidad ) + " - " + ;
						"Atributo: " + alltrim( c_CamposAutoInc.Atributo ) )
					llErrores  = .T.

			endcase

			
		endscan


		if llErrores
			This.oInformacionIndividual.AgregarInformacion( "La longitud debe ser igual a 9 y decimales igual a 0." + chr(10) + chr(13) )
		endif 	

		use in select( "c_CamposAutoInc" )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function 	ValidarLongitudCamposAutoincrementalesEnClaveForanea( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		select Entidad, Atributo ;
			from diccionario ;
			where upper( alltrim( ClaveForanea ) ) == upper( alltrim( tcEntidad ) ) and ( Longitud # 9 or !empty( Decimales ) ) ;
			into cursor c_ErroresClaveForanea
		
		select c_ErroresClaveForanea
		scan all
			This.oInformacionIndividual.AgregarInformacion( "Error en la longitud de campo en la subentidad." + ;
			"Entidad: " + alltrim( c_ErroresClaveForanea.Entidad ) + " - " + ;
			"Atributo: " + alltrim( c_ErroresClaveForanea.Atributo ) )
			llRetorno  = .T.
		endscan
		use in select( "c_ErroresClaveForanea" )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function 	ValidarLongitudCamposAutoincrementalesEnItems( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		select Entidad, Atributo ;
			from diccionario di ;
				inner join dominio do on upper( alltrim( di.dominio ) ) == upper( alltrim( do.dominio ) ) ;
			where upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and do.Detalle and ;
				( di.TipoDato # "N" or di.Longitud # 9 or !empty( di.Decimales ) ) ;
			into cursor c_ErroresItems
		
		select c_ErroresItems
		scan all
			This.oInformacionIndividual.AgregarInformacion( "Error en la Longitud/TipoDato del item." + ;
			"Entidad: " + alltrim( c_ErroresItems.Entidad ) + " - " + ;
			"Atributo: " + alltrim( c_ErroresItems.Atributo ) )
			llRetorno  = .T.
		endscan
		use in select( "c_ErroresItems" )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadAnulable() as Void
						
		local lcCursor as String
		lcCursor = sys( 2015 )
		
		select * from entidad where funcionalidades like "%<ANULABLE>%" into cursor &lcCursor
		
		select( lcCursor )
		scan all
			select diccionario
			locate for upper( alltrim( entidad ) ) = upper( alltrim( &lcCursor..entidad ) ) and upper( alltrim( atributo ) ) == "ANULADO" and tipodato = "L"
			if !found()
				This.oInformacionIndividual.AgregarInformacion( "La entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene funcionalidad anulable y no tiene el atributo 'ANULADO'" )
			endif
		endscan
		use in select( lcCursor )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarOrdenNavegacion() as Void
		local lcCursor as string
		lcCursor = sys( 2015 )
		select entidad, ordennavegacion, count(*) as cn from diccionario where !empty( ordennavegacion ) group by entidad, ordennavegacion ;
		 having cn > 1 into cursor &lcCursor
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene repetido el orden de navegación" )
		endscan

		select entidad, atributo from diccionario where !empty( ordennavegacion ) and upper( alltrim( tipodato ) ) = "M" into cursor &lcCursor
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + " de la entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene orden de navegación en un campo memo" )
		endscan

		select di.entidad, di.atributo from diccionario di inner join dominio do on alltrim( upper( di.dominio ) ) == alltrim( upper( do.dominio )) ;
		 where !empty( di.ordennavegacion ) and do.detalle into cursor &lcCursor
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + " de la entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene orden de navegación y es un detalle" )
		endscan

		select d.entidad, d.atributo from diccionario d inner join entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad )) ;
		 where !empty( d.ordennavegacion ) and upper( alltrim( e.tipo ) ) != "E" into cursor &lcCursor
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo " + upper( alltrim( &lcCursor..atributo ) ) + " del item " + upper( alltrim( &lcCursor..entidad ) ) + " tiene orden de navegación" )
		endscan

		* Entidades que tienen GUID y no tienen definido un orden de navegacion	ni clave candidata
		* Se omite la validación para aquellas entidades que no tienen toolbar, dado que no se navega
		select distinc d.entidad ;
			from diccionario d inner join entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where e.tipo = "E" and e.Formulario and !("<SINTOOLBAR>" $ e.Funcionalidades) and ;
				e.entidad in ( select entidad from diccionario where TipoDato = "G" and ClavePrimaria ) and ;
				e.entidad not in ( select entidad from diccionario where !empty( OrdenNavegacion ) ) and ;
				e.entidad not in ( select entidad from diccionario where !empty( Clavecandidata ) ) ;
		order by d.entidad ;
		into cursor &lcCursor

		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene GUID y no tiene cargado un orden de navegación." )
		endscan

		* Entidades que tienen GUID y este es el orden de navegación		
		select distinct d.entidad ;
			from diccionario d ;
			where TipoDato = "G" and !empty( ordenNavegacion ) ;
		order by d.entidad ;
		into cursor &lcCursor
		
		select( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + upper( alltrim( &lcCursor..entidad ) ) + " tiene asignado orden de navegación en el atributo de tipo GUID." )
		endscan
		use in select( lcCursor )

	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarNombresDeCamposClavePrimaria() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		
		select upper( alltrim( d.entidad ) ) as entidad, d.atributo, d.campo, e.Descripcion from diccionario d;
			left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) );
				where clavePrimaria and inlist( lower( campo ), "orden", "texto", "id_memo" ) and upper( e.Tipo ) == "E" and ;
					upper( alltrim( d.entidad ) ) in (;
						select upper( alltrim( d.entidad ) ) as entidad from diccionario d;
							where ( upper( TipoDato ) == "M" ) ) ;
				order by d.entidad ;
			into cursor &lcCursor
		
		if reccount() > 0
			scan all
				This.oInformacionIndividual.AgregarInformacion( "El atributo '" + proper( alltrim( &lcCursor..Atributo ) ) + ;
					"' de la entidad '" + proper( alltrim( &lcCursor..Descripcion ) ) + ;
					"' no puede tener como nombre de campo '" + proper( alltrim( &lcCursor..Campo ) ) + ;
					"' y ser clave primaria." )
			endscan
		endif
		
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCaracteresEspeciales() as Void
		local lcTabla as String, lcCursor as String, lcTexto as String, llCerrarTabla as Boolean
		local array laTablas(1),laCampo(1)

		lcRutaMetadata = addbs( This.cRutaADN ) + "*.dbf"
		adir( laTablas, lcRutaMetadata )

		for lnCont = 1 to alen( laTablas, 1 )
			lcTabla = forceext( transform( laTablas[ lnCont, 1 ] ) , "" )
			if inlist( upper( alltrim( lcTabla ) ), "REGISTRO", "PARAMETROS", "NODOSREGISTROCLIENTE", "JERARQUIAREGISTROS", "JERARQUIAPARAMETROS" )
			else
				llCerrarTabla = .F.
				if used( "c_" + lcTabla )
					lcTabla = "c_" + lcTabla
				else
					if used( lcTabla )
					else
						use (addbs(This.cRutaADN) + lcTabla) shared in 0 again
						llCerrarTabla = .T.
					endif
				endif
				
				select &lcTabla
				afields( laCampo, lcTabla )       
				scan
					for lnContCampos = 1 to alen( laCampo, 1 )
						if laCampo[ lnContCampos, 2 ] == "C"
							lcCampo = laCampo[ lnContCampos, 1 ]
							if '[' $ evaluate( lcCampo ) or ']' $ evaluate( lcCampo )
								lcTexto = "Tabla " + lcTabla  + ", Registro: " + transform( recno() ) + ;
										", Campo: " + lcCampo + ". Contiene cacacteres invalidos '[]'"
								This.oInformacionIndividual.AgregarInformacion( lcTexto )
							endif                                       
						endif
					endfor
				endscan
				
				if llCerrarTabla
					use in select( lcTabla )
				endif
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadEnIds() as Void
		local lcTabla as String

		lcTabla = "VERSIONESMETADATA"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
			
		lcTabla = "TRANSFERENCIASAGRUPADAS"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "TABLAS"
		if This.ContieneIDsRepetidos( lcTabla, "LD" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

		lcTabla = "OPERACIONESMETADATA"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

		lcTabla = "LISTSEC"
		if This.ContieneIDsRepetidos( lcTabla, "LISSECCOD" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "LISTCAMPOS"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "LISTADOS"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "INDICE"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

		lcTabla = "INDICE_SQLSERVER"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "GUIADEMETADATA"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "FUNCIONALIDADES"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
		lcTabla = "FILTROADICIONAL"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

		lcTabla = "ESTILOS"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

*!*			lcTabla = "DICCIONARIO"
*!*			if This.ContieneIDsRepetidos( lcTabla, "ID" )
*!*				This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
*!*			endif

		lcTabla = "CONTROLES"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif

		lcTabla = "COMPROBANTES"
		if This.ContieneIDsRepetidos( lcTabla, "ID" )
			This.oInformacionIndividual.AgregarInformacion( "La tabla " + lcTabla + " contiene IDs repetidos." )
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ContieneIDsRepetidos( tcTabla as String, tcCampo as String ) as Boolean
		local lcCursor as String, llRetorno as Boolean, llCerrarTabla as Boolean
		
		llRetorno = .F.
		lcCursor = "c_" + sys( 2015 )

		try
			llCerrarTabla = .F.
			if used( tcTabla )
			else
				use &tcTabla shared in 0 noupdate
				llCerrarTabla = .T.
			endif
			select &tcCampo, count( &tcCampo ) as Cantidad from &tcTabla having cantidad > 1 group by &tcCampo order by Cantidad desc into cursor &lcCursor
			if _tally > 0
				llRetorno = .T.
			Endif		
		catch to loError
			throw loError
		Finally
			if llCerrarTabla
				use in select( tcTabla )
			endif
 			use in select( lcCursor )
		EndTry
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarRelaTriggers() as Void
		local lcCursor as String, lcMensaje as String, loError as zooexception OF zooexception.prg ;
				lcString as String, lnCant as Integer, lcEntidad as String, lcAtributo as String ;
				lcEntidadOrigen as String, lcEntidadDestino as String

		lcCursor = sys( 2015 )
		try
			*-- 
			select accion ;
				from relatriggers ;
				where !empty( accion ) ;
				group by accion ;
				Into Cursor &lcCursor
					
			select ( lcCursor )
			scan
				if This.ValorAccionCorrecto( accion )
				else
					lcMensaje = "El valor '" + alltrim( accion ) + "' en el campo accion es incorrecto."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endscan

			*--
			select entidad_origen, atributo_origen ;
				from relatriggers ;
				group by entidad_origen, atributo_origen ;
				Into Cursor &lcCursor
	
			select x.entidad_origen, x.atributo_origen, d.Entidad, d.Atributo from &lcCursor x;
				left join diccionario d on upper( alltrim( x.entidad_origen ) ) == upper( alltrim( d.Entidad ) ) and ;
				upper( alltrim( x.atributo_origen ) ) == upper( alltrim( d.Atributo ) ) ;
				into cursor &lcCursor
				
			select ( lcCursor )
			scan for isnull( Entidad ) or isnull( Atributo )
					lcMensaje = This.ArmarMensajeParaEntidadAtributo( &lcCursor..entidad_origen, &lcCursor..atributo_origen, "origen" )
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan

			*--			
			select entidad_destino, atributo_destino ;
				from relatriggers ;
				group by entidad_destino, atributo_destino ;
				Into Cursor &lcCursor
				
			select x.entidad_destino, x.atributo_destino, d.Entidad, d.Atributo from &lcCursor x;
				left join diccionario d on upper( alltrim( x.entidad_destino ) ) == upper( alltrim( d.Entidad ) ) and ;
				upper( alltrim( x.atributo_destino ) ) == upper( alltrim( d.Atributo ) ) ;
				into cursor &lcCursor
				
			select ( lcCursor )
			scan for isnull( Entidad ) or isnull( Atributo )
				lcMensaje = This.ArmarMensajeParaEntidadAtributo( &lcCursor..entidad_destino, &lcCursor..atributo_destino, "destino" )
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan

			*--			
			select relacion, count( * ) as cant, entidad_origen, entidad_destino ;
				from relatriggers ;
				where relacion > 0 ;
				having cant > 1 ;
				group by entidad_origen, entidad_destino, relacion ;
				into cursor &lcCursor

			select ( lcCursor )
			scan
				lcMensaje = "El orden de búsqueda para la Entidad Origen (" + alltrim( entidad_origen ) + ;
							") Entidad Destino (" + alltrim( entidad_destino ) + ") se encuentra repetido."
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan
			
			*-- 
			select rt.entidad_origen, x.Cant ;
					from relatriggers rt left join ;
					( select entidad_origen, count( entidad_origen ) as Cant from relatriggers where relacion = 0 group by entidad_origen ) x ;
					on upper( alltrim( rt.entidad_origen ) ) == upper( alltrim( x.entidad_origen ) ) ;
					where rt.relacion > 0 ;
					group by rt.entidad_origen ;
					into cursor &lcCursor
			select ( lcCursor )
			scan for isnull( Cant )
				lcMensaje = "No especifico acciones a efectuar en la entidad origen '" + alltrim( entidad_origen ) + "'."
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan
							
			*-- 
			select rt.entidad_origen, x.Cant ;
					from relatriggers rt left join ;
					( select entidad_origen, count( entidad_origen ) as Cant from relatriggers where relacion > 0 group by entidad_origen ) x ;
					on upper( alltrim( rt.entidad_origen ) ) == upper( alltrim( x.entidad_origen ) ) ;
					where rt.relacion = 0 ;
					group by rt.entidad_origen ;
					into cursor &lcCursor
			select ( lcCursor )
			scan for isnull( Cant )
				lcMensaje = "No especifico relaciones en la entidad origen '" + alltrim( entidad_origen ) + "'."
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan

			*-- 
			select R.entidad_origen, R.atributo_origen, R.entidad_destino, R.atributo_destino, ;
				D1.tipodato as tdato_origen, D1.longitud as long_origen, ;
				D2.tipodato as tdato_destino, D2.longitud as long_destino ;
			from relatriggers R ;
				left join diccionario D1 on upper( alltrim( R.entidad_origen ) ) = upper( alltrim( D1.entidad ) ) and ;
					upper( alltrim( R.atributo_origen ) ) = upper( alltrim( D1.atributo ) ) ;
				left join diccionario D2 on upper( alltrim( R.entidad_destino ) ) = upper( alltrim( D2.entidad ) ) and ;
					upper( alltrim( R.atributo_destino ) ) = upper( alltrim( D2.atributo ) ) ;
			where R.relacion > 0 ;
			into cursor &lcCursor

			select ( lcCursor )
			scan
				if upper( alltrim( tdato_origen ) ) = upper( alltrim( tdato_destino ) ) and long_origen = long_destino
				else
					lcMensaje = "El tipo de datos/longitud de origen '" + alltrim( entidad_origen ) + "." + alltrim( atributo_origen ) + "'" + ;
								" difiere en diccionario del destino '" + alltrim( entidad_destino ) + "." + alltrim( atributo_destino ) + "'."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endscan

			*--
			select Entidad_Origen, Entidad_Destino, expresion ;
				from relatriggers ;
				where !empty( expresion ) ;
				into cursor &lcCursor

			select ( lcCursor )
			scan
				lcEntidadOrigen = upper( alltrim( &lcCursor..Entidad_Origen ) )
				lcEntidadDestino = upper( alltrim( &lcCursor..Entidad_Destino ) )
				lcString = upper( alltrim( &lcCursor..Expresion ) ) + ' '
				lnCant = occurs( "#", lcString )

				for i = 1 to lnCant
					lcString = upper( substr( lcString, at( "#", lcString ) + 1 ) )
					lcEntidad = upper( substr( lcString, 1, at( ".", lcString ) - 1 ) )
					lcAtributo = upper( substr( lcString,  at( ".", lcString ) + 1, at( " ", lcString ) - at( ".", lcString ) ) )

					if upper( alltrim( lcEntidadOrigen ) ) = upper( alltrim( lcEntidad ) ) or ;
							upper( alltrim( lcEntidadDestino ) ) = upper( alltrim( lcEntidad ) )
					else
						lcMensaje = "La Entidad '" + alltrim( lcEntidad ) + "' de la Expresion no tiene una relación en RelaTriggers."
						This.oInformacionIndividual.AgregarInformacion( lcMensaje )
					endif

					select diccionario
					locate for upper( alltrim( entidad ) ) = upper( alltrim( lcEntidad ) ) and ;
							upper( alltrim( atributo ) ) = upper( alltrim( lcAtributo ) )
					if found()
					else
						lcMensaje = "El Atributo '" + alltrim( lcAtributo ) + "' de la Expresion no existe en Diccionario para la Entidad ENTIDADDESTINO."
						This.oInformacionIndividual.AgregarInformacion( lcMensaje )
					endif
				EndFor
			endscan

		catch to loError
			throw loError
		Finally	
			use in select( lcCursor )
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIdBuscadorDetalleEnBuscador() as Void
		local lcCursor as String, lcMensaje as String

		lcCursor = sys( 2015 )

		select id_buscador ;
				from BuscadorDetalle ;
				where id_buscador not in ( select id from Buscador );
				Into Cursor &lcCursor
				
		select ( lcCursor )
		scan
			lcMensaje = "El identificador( ID_BUSCADOR ) " + transform( ID_BUSCADOR ) + " No está definido en la tabla Buscador."

			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		

		select Buscador
		scan
			select id_buscador from buscadorDetalle where id_Buscador = Buscador.id into cursor "c_existeAtributos"
			
			if _tally = 0
				lcMensaje = "El Buscador " + transform( Buscador.id ) + " no tiene detalle cargado."  
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
			use in select( "c_existeAtributos" )
			select Buscador
		endscan		

		use in select( lcCursor )
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarEntidadEnBuscador() as Void
		local lcCursor as String, lcMensaje as String
		
		lcCursor = sys( 2015 )

		select upper( b.entidad ) ent_bus, upper( e.entidad ) ent_ent ;
			from BUSCADORDETALLE b left join entidad e;
			on alltrim( upper( b.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( b.entidad ) ;
			having isnull( ent_ent ) ;
			Into Cursor &lcCursor
			
		select ( lcCursor )

		scan 
			lcMensaje = "La entidad " + alltrim( ent_bus ) + " no se encuentra en la tabla ENTIDAD."
			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan		

		use in select( lcCursor )
			
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAtributoEnBuscador() as Void
		local lcCursor as String, lcMensaje as String
		
		lcCursor = sys( 2015 )

		select upper( b.atributo ) bus_atri, upper( d.atributo ) as dic_atri ,;
			upper( b.entidad ) as bus_ent ;
			from BUSCADORDETALLE b ;
			left join diccionario d;
			on alltrim( upper( b.atributo ) ) == alltrim( upper( d.atributo ) ) and  ;
		 	alltrim( upper( b.entidad ) ) == alltrim( upper( d.entidad ) ) ;
	 		where !empty( b.entidad ) ;
			having isnull( dic_atri ) ;
			Into Cursor &lcCursor

		select ( lcCursor )
		scan 
			select( "Atributosgenericos" )
			locate for alltrim( upper( &lcCursor..bus_atri ) )  == alltrim( upper( atributosgenericos.atributo ) ) 
			select( lcCursor )
		
			if found( "Atributosgenericos" )
			else
				lcMensaje = "El atributo " + alltrim( bus_atri ) + " no existe para la entidad " + alltrim( bus_ent ) + "."
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif 
				
		endscan		

		use in select( lcCursor )
			
	endfunc


	*-----------------------------------------------------------------------------------------
	protected function ArmarMensajeParaEntidadAtributo( tcEntidad as String, tcAtributo as String, tcOrigenDestino as String ) as String
		local lcMensaje as String
		lcMensaje = "La entidad/atributo " + alltrim( tcOrigenDestino ) + " de la tabla RelaTriggers (" + alltrim( tcEntidad ) + ;
			"." + alltrim( tcAtributo ) + ") no existe en Diccionario."

		return lcMensaje
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function ValorAccionCorrecto( lcAccion as String ) as Boolean
		local llReturn as Boolean
		llReturn = .f.
		if inlist( upper( alltrim( lcAccion ) ), "INSERTAR", "ACTUALIZAR", "ELIMINAR" )
			llReturn  = .t.
		endif
		return llReturn
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ValidarClavePrimariaVisibles() as Void

		Try

			select Entidad, Atributo, claveforanea from diccionario ;
					where  "item" $ lower(entidad) and ;
							!empty( claveforanea) and alta ;
					into cursor c_CursorClavePrimaria

			select dic.Entidad, dic.Atributo, Pk.Entidad as EntidadOrigen , pk.atributo as atributoorigen from diccionario dic ,c_CursorClavePrimaria Pk ;
					where alltrim( lower( Dic.entidad ) ) == alltrim( lower( Pk.ClaveForanea ) ) and ;
					 Dic.claveprimaria and !Dic.alta ;
					into cursor c_CursorFKnoVisibles

			select c_CursorFKnoVisibles
			scan
				select entidad, dominio, alta ;
					from Diccionario ;
					where lower( alltrim( dominio ) ) = 'detalle' + lower( alltrim(  c_CursorFKnoVisibles.EntidadOrigen )) and Alta ;
					into cursor c_final
				
				if _Tally > 0
					lcMensaje = "El atributo '" + upper( alltrim( c_CursorFKnoVisibles.Atributo ) ) + ;
								"' de la entidad '" + upper( alltrim( c_CursorFKnoVisibles.Entidad ) ) + ;
								"' debe ser visible ya que es clave foranea visible en la entidad '" + upper( alltrim( c_CursorFKnoVisibles.EntidadOrigen ) )  + "'."
							
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif			
				use in select( "c_final" )
			endscan
			
		catch to loError
			throw loError
		finally
			use in select( "c_CursorClavePrimaria" )
			use in select( "c_CursorFKnoVisibles" )
		EndTry		
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributoObservacion() as VOID
		local lcRutaInicial as string, lnInicioProyecto as string, lcProyecto as string, lcMensaje as string

		lcRutaInicial = addbs( This.cRutaInicial )
		lnInicioProyecto = rat( "\" , lcRutaInicial, 2 )
		lcProyecto = This.cProyectoActivo
		lcMensaje = ""		

		if This.VerificarSiValidaAtributoObservacion( lcProyecto )

			This.CrearListaEntidadesAExceptuarValidacionAtributoObservacion( "c_EntidadesAExceptuarValidarAtributoObservacion" )

			select Ent.Entidad ;
				from Entidad Ent ;
				where upper( Ent.Tipo ) == "E" ;
					and Ent.Formulario ;
					and !deleted() ;
					and upper( Ent.Entidad ) not in ;
						( Select upper( Entidad ) ;
							from c_EntidadesAExceptuarValidarAtributoObservacion ;
							where upper( alltrim( Proyecto ) ) == lcProyecto ) ;
				into cursor c_EntidadesAValidar

			select ( "c_EntidadesAValidar" )
			scan 
				select ( "Diccionario" )

				locate for upper( alltrim( Diccionario.Entidad ) ) == upper( alltrim( c_EntidadesAValidar.Entidad ) ) ;
					and left( alltrim( Diccionario.Dominio), 11 ) == "OBSERVACION"
				
				if !found( "Diccionario" )
					lcMensaje = "La entidad " + upper( alltrim( c_EntidadesAValidar.Entidad ) ) + ;
						" no posee un atributo OBSERVACION."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endscan
			
			use in select( "c_EntidadesAExceptuarValidarAtributoObservacion" )
			use in select( "c_EntidadesAValidar" )

		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDetalleBuscador() as Void
	
		select buscador
		scan
			select * from buscadorDetalle where id_Buscador = Buscador.id into cursor "c_cursorDetalle"
			
			if _Tally = 0
				This.oInformacionIndividual.AgregarInformacion( "No se encuentra detalle para el buscador " + transform( Buscador.id ) )
			endif
			
			select * from "c_cursorDetalle" where empty( Atributo ) into cursor "c_BuscadorVacio" 
			if _Tally > 0
				This.oInformacionIndividual.AgregarInformacion( "El buscador " + transform( Buscador.id ) + ;
					" tiene vacio " + transform( _tally ) + " atributo/s." )
			endif

			select "Buscador"
		endscan
		
		use in select( "c_cursorDetalle" )
		use in select( "c_BuscadorVacio" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarSiValidaAtributoObservacion( tcProyecto as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.

		create cursor c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre C( 20 ) )

		*!* Agregar en este cursor los proyectos en los que se debe ignorar esta validación.
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "DIBUJANTE" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "NUCLEO" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "MENU" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "DLLS" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "GENERADORES" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "LINCE" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ZOTROS" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "TASPEIN" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "AUTOBUILD" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ZDK" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "LINCE 6.8X" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ZOOLOGIC" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "REINDEXADOR" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "CUBOS" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "TALLER" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "LANCELOT" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ADNIMPLANT" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ADNMANAGER" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "MASTER HELP" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "GENESIS" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ZUPDATE" )
		
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "ZL" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "LINCEORGANIC" )
		insert into c_ProyectosAExceptuarValidarAtributoObservacion ( Nombre ) values ( "NIKE" )
		
		*-----------------------------------------------------------------------------------------

		select Nombre ;
			from c_ProyectosAExceptuarValidarAtributoObservacion ;
			where upper( alltrim( Nombre ) ) == upper( alltrim( tcProyecto ) ) ;
			into cursor c_ProyectoAValidar

		llRetorno = ( _tally = 0 )

		use in select( "c_ProyectosAExceptuarValidarAtributoObservacion" )
		use in select( "c_ProyectoAValidar" )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function CrearListaEntidadesAExceptuarValidacionAtributoObservacion( tcCursor as String ) as VOID

		select space( 20 ) as Proyecto, Entidad ;
			from Entidad ;
			where .f. ;
			into cursor &tcCursor readwrite

		*!* Agregar en este cursor las entidades en las que se debe ignorar esta validación.

		insert into &tcCursor ( Proyecto, Entidad ) values ( "TELAS", "BUZON" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "TELAS", "AJUSTEDESTOCK" )

		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "BUZON" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "AJUSTEDESTOCK" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "DATOSADICIONALESCOMPROBANTESA" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "DATOSADICIONALESSIRE" )		
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "DATOSADICIONALESSIPRIB" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "ARTICULOINCISODATOSADICIONALESSIPRIB" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "FELINO", "TIPODECOMPROBANTEDECOMPRA" )

		insert into &tcCursor ( Proyecto, Entidad ) values ( "COMERCIOS", "BUZON" )
		
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "BUZON" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "AJUSTEDESTOCK" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "DATOSADICIONALESCOMPROBANTESA" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "DATOSADICIONALESSIRE" )		
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "DATOSADICIONALESSIPRIB" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "ARTICULOINCISODATOSADICIONALESSIPRIB" )
		insert into &tcCursor ( Proyecto, Entidad ) values ( "COLORYTALLE", "TIPODECOMPROBANTEDECOMPRA" )

		insert into &tcCursor ( Proyecto, Entidad ) values ( "NIKE", "DATOSADICIONALESCOMPROBANTESA" )
		
	endfunc

      *-----------------------------------------------------------------------------------------
      function ValidarAtributosEnEquivalencia() as VOID
      
            local llExisteStockComb as Boolean, llExisteEquivalencias as Boolean, lcAtributo as String, lnCantAtribSC as Integer,;
             lnCantAtribEq as Integer, lcTipo as string, lnLongitud as integer, lnDecimal as integer, lcSelectStockComb as String 
      
            llExisteStockComb = .T.
            llExisteEquivalencias = .T.
            lnCantAtribEq = 0       
            lnCantAtribSC = 0
            lcAtributo = space(0)
            lcTipo         = space(0)
            lnLongitud = 0
            lnDecimal  = 0          
            lcSelectStockComb = space(0)             
            
            select ( "Diccionario" )

            locate for upper( alltrim( Diccionario.Entidad ) ) == 'STOCKCOMBINACION'
      
            if !found( "Diccionario" )
                  lcMensaje = "La entidad STOCKCOMBINACION no existe."
                  This.oInformacionIndividual.AgregarInformacion( lcMensaje )
                  llExisteStockComb = .F.
            endif

            select ( "Diccionario" )

            locate for upper( alltrim( Diccionario.Entidad ) ) == 'EQUIVALENCIA'
      
            if !found( "Diccionario" )
                  lcMensaje = "La entidad EQUIVALENCIA no existe."
                  This.oInformacionIndividual.AgregarInformacion( lcMensaje )
                  llExisteEquivalencias = .F.
            endif
            
           

            if llExisteStockComb ;
                  and llExisteEquivalencias

                  lcSelectStockComb = "select dic.entidad, dic.atributo, dic.tipodato, dic.longitud, dic.decimales, dic.clavecandidata "
		          lcSelectStockComb = lcSelectStockComb + "from diccionario dic "
		          lcSelectStockComb = lcSelectStockComb + "where alltrim( lower( dic.entidad ) ) == 'stockcombinacion' "
                  
                  if This.cProyectoActivo == 'TELAS'	
		                lcSelectStockComb = lcSelectStockComb + "and dic.clavecandidata = 1 "
		          Else      
				        lcSelectStockComb = lcSelectStockComb + "and not empty( dic.clavecandidata) "
	              endif     
	              
	              lcSelectStockComb = lcSelectStockComb + "into cursor c_CursorAtributosStockComb "
	              
	              &lcSelectStockComb
                  
                  select dic.entidad, dic.atributo, dic.tipodato, dic.longitud, dic.decimales, dic.clavecandidata;
                  from diccionario dic;
                  where alltrim( lower( dic.entidad ) ) == 'equivalencia';
                  into cursor c_CursorAtributosEquivalencias
                  
                  select c_CursorAtributosStockComb
                  count to lnCantAtribSC
                  
                  select c_CursorAtributosEquivalencias
                  count to lnCantAtribEq
                  
                  if lnCantAtribSC <= lnCantAtribEq
                        select c_CursorAtributosStockComb
                        scan
                             if upper( alltrim( c_CursorAtributosStockComb.atributo ) ) <> 'UPC'
                                   lcAtributo  		= c_CursorAtributosStockComb.atributo
                                   lcTipo           = c_CursorAtributosStockComb.tipodato
                                   lnLongitud  		= c_CursorAtributosStockComb.longitud
                                   lnDecimal   		= c_CursorAtributosStockComb.decimales
                                   lnClaveCandidata	= c_CursorAtributosStockComb.clavecandidata
                                   
                                   select c_CursorAtributosEquivalencias
                                   locate for upper( alltrim( c_CursorAtributosEquivalencias.atributo ) ) == upper( alltrim( lcAtributo ) )
                                   
                                   if found()
                                         if upper( alltrim( lcTipo ) ) == upper( alltrim( c_CursorAtributosEquivalencias.tipodato ) )
                                         else
                                               lcMensaje = "El tipo de dato del atributo " + upper( alltrim( lcAtributo ) ) + " no es el correcto en la entidad EQUIVALENCIA."
                                               This.oInformacionIndividual.AgregarInformacion( lcMensaje )      
                                         endif       
                                         if lnLongitud = c_CursorAtributosEquivalencias.longitud
                                         else
                                               lcMensaje = "La longitud del atributo " + upper( alltrim( lcAtributo ) ) + " no es la correcta en la entidad EQUIVALENCIA."
                                               This.oInformacionIndividual.AgregarInformacion( lcMensaje )      
                                         endif                                          
                                         if lnDecimal = c_CursorAtributosEquivalencias.decimales
                                         else
                                               lcMensaje = "Los decimales del atributo " + upper( alltrim( lcAtributo ) ) + " no son los correctos en la entidad EQUIVALENCIA."
                                               This.oInformacionIndividual.AgregarInformacion( lcMensaje )      
                                         endif    
                                   else
                                         lcMensaje = "El atributo " + upper( alltrim( lcAtributo ) ) + " no existe en la entidad EQUIVALENCIA."
                                         This.oInformacionIndividual.AgregarInformacion( lcMensaje ) 
                                   endif 
                             endif       
                        endscan
                  else
                        lcMensaje = "La cantidad de atributos coincidentes entre las entidades STOCKCOMBINACION (" + alltrim( transform( lnCantAtribSC ) ) + ") y EQUIVALENCIA (" + alltrim( transform( lnCantAtribEq ) ) + ") no es la correcta."
                        This.oInformacionIndividual.AgregarInformacion( lcMensaje )            
                  endif       
            endif       
            
            use in select( "c_CursorAtributosStockComb" )
            use in select( "c_CursorAtributosEquivalencias" )          

      endfunc

	*-----------------------------------------------------------------------------------------
	function DevolverInformacion() as object
		
		return This.oInformacion
	endfunc 
      
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosObligatoriosDeCalculoDePrecios() as Void
	
		local lcCurAtrCorrectos as String, lcCurAtrHer as String, lcAtributo as String, llClaveCandidata as Boolean
		
		lcCurAtrCorrectos = sys( 2015 )
		lcCurAtrHer = sys( 2015 )
		llClaveCandidata = 0
		
		select * from diccionario ;
				where alltrim( upper( entidad ) ) == "PRECIODEARTICULO" and ClaveCandidata > 0 and upper(TipoDato) != "L"; 
				order by clavecandidata ;
			union select * from diccionario ;
				where alltrim( upper( entidad ) ) == "ARTICULO" and !empty( claveforanea )  and alltrim( upper( ClaveForanea ) ) != "CURVADETALLES" and alltrim( upper( ClaveForanea ) ) != "PALETADECOLORES"  ;
			into cursor &lcCurAtrCorrectos 
		
		select * from diccionario ;
			where alltrim( upper( entidad ) ) == "CALCULODEPRECIOS" ;
			into cursor &lcCurAtrHer
		
		if reccount( lcCurAtrCorrectos ) > 0 and reccount( lcCurAtrHer ) > 0
			select &lcCurAtrCorrectos
			scan 
				lcAtributo = upper( alltrim( &lcCurAtrCorrectos..Atributo ) )
				
				
				if upper( alltrim( lcAtributo ) ) != "LISTADEPRECIO" and !empty( lcAtributo ) 
					llClaveCandidata = &lcCurAtrCorrectos..ClaveCandidata
					if llClaveCandidata > 0
						lcAtributo = "F_" + upper( alltrim( &lcCurAtrCorrectos..Atributo ) ) + "_DESDE"
						this.ValidarAtributosDeCalculoDePrecios( lcCurAtrCorrectos, lcCurAtrHer, lcAtributo )
						lcAtributo = "F_" + upper( alltrim( &lcCurAtrCorrectos..Atributo ) ) + "_HASTA"
						this.ValidarAtributosDeCalculoDePrecios( lcCurAtrCorrectos, lcCurAtrHer, lcAtributo )
					else
						lcAtributo = "F_" + upper( alltrim( &lcCurAtrCorrectos..Entidad ) ) + "_" + upper( alltrim( &lcCurAtrCorrectos..Atributo ) ) + "_DESDE"
						this.ValidarAtributosDeCalculoDePrecios( lcCurAtrCorrectos, lcCurAtrHer, lcAtributo )
						lcAtributo = "F_" + upper( alltrim( &lcCurAtrCorrectos..Entidad ) ) + "_" + upper( alltrim( &lcCurAtrCorrectos..Atributo ) ) + "_HASTA"
						this.ValidarAtributosDeCalculoDePrecios( lcCurAtrCorrectos, lcCurAtrHer, lcAtributo )
					endif	
				endif	
			endscan

		endif

		use in select( lcCurAtrCorrectos )
		use in select( lcCurAtrHer )
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	protected function ValidarAtributosDeCalculoDePrecios( tcCurAtrCorrectos as string, tcCurAtrHer as String, tcAtributo as String ) as Void
		local lcDominio as String, lcDominioCorrecto as String, lcValorSugerido as String
		
		lcValorSugerido = ""
		
		select &tcCurAtrHer
		locate for upper( alltrim( tcAtributo ) ) == upper( alltrim( &tcCurAtrHer..Atributo ) )
		if found()
			if evaluate( tcCurAtrCorrectos + ".Longitud" ) != evaluate( tcCurAtrHer + ".Longitud" )
				this.oInformacionIndividual.AgregarInformacion( ;
	            	"La longitud del atributo '" + proper( tcAtributo ) + ;
	            	"' de la entidad 'Cálculo de precios' debe ser de " + transform( &tcCurAtrCorrectos..Longitud ) + "." )
			endif
			
			if !evaluate( tcCurAtrHer + ".Alta" )
				this.oInformacionIndividual.AgregarInformacion( ;
					"El atributo '" + proper( tcAtributo ) + ;
	            	"' de la entidad 'Cálculo de precios' debe ser visible." )
			endif

			if upper( alltrim( evaluate( tcCurAtrCorrectos + ".TipoDato" ) ) ) != upper( alltrim( evaluate( tcCurAtrHer + ".TipoDato" ) ) )
				this.oInformacionIndividual.AgregarInformacion( ;
	            	"El tipo de dato del atributo '" + proper( tcAtributo ) + ;
	            	"' de la entidad 'Cálculo de precios' debe ser 'C'." )
			endif

			lcDominio = upper( alltrim( evaluate( tcCurAtrHer + ".Dominio" ) ) )
			lcDominioCorrecto = ""
			do case
				case upper( alltrim( evaluate( tcCurAtrCorrectos + ".TipoDato" ) ) ) = "D" 
					if lcDominio != "ETIQUETAFECHADESDEHASTA"
						lcDominioCorrecto = "'EtiquetaFechaDesdeHasta'"
					endif
				case upper( alltrim( evaluate( tcCurAtrCorrectos + ".TipoDato" ) ) ) = "C" 
					if lcDominio != "ETIQUETACARACTERDESDEHASTABUSC" and lcDominio != "ETIQUETACARACTERDESDEHASTA"
						lcDominioCorrecto = "'EtiquetaCaracterDesdeHastaBusc'"
					endif
				case upper( alltrim( evaluate( tcCurAtrCorrectos + ".TipoDato" ) ) ) = "N" 
					if lcDominio != "ETIQUETANUMERICODESDEHASTA"
						lcDominioCorrecto = "'EtiquetaNumericoDesdeHasta'"
					endif
				case upper( alltrim( evaluate( tcCurAtrCorrectos + ".TipoDato" ) ) ) = "L" 
					if lcDominio != "ETIQUETACARACTERDESDEHASTA"
						lcDominioCorrecto = "'EtiquetaCaracterDesdeHasta'"
					endif
				otherwise
					lcDominioCorrecto = "'EtiquetaCaracterDesdeHastaBusc'"
			endcase
			if !empty( lcDominioCorrecto )
				this.oInformacionIndividual.AgregarInformacion( ;
					"El dominio del atributo '" + proper( tcAtributo ) + ;
	            	"' de la entidad 'Cálculo de precios' debe ser " + lcDominioCorrecto + "." )
			endif

			if "REPL" $ upper (evaluate( tcCurAtrHer + ".ValorSugerido" ) )
				lcValorSugerido = alltrim( evaluate( tcCurAtrHer + ".ValorSugerido" ) )
				lcValorSugerido = strtran(lcValorSugerido , "=" ,"" )
			else
				lcValorSugerido = tcCurAtrHer + ".ValorSugerido" 
			endif

			if (right( tcAtributo, 5 ) == "HASTA" and evaluate( tcCurAtrCorrectos + ".TipoDato" ) = "C" ) ;
					and ( evaluate( tcCurAtrCorrectos + ".Longitud" ) != len( alltrim( evaluate( lcValorSugerido ) ) ) ;
					or replicate( "Z", evaluate( tcCurAtrCorrectos + ".Longitud" ) ) != alltrim( evaluate( lcValorSugerido ) ) )

				this.oInformacionIndividual.AgregarInformacion( ;
	            	"El valor sugerido del atributo '" + proper( tcAtributo ) + ;
	            	"' de la entidad 'Cálculo de precios' debe ser '" ;
	            	+ replicate( "Z", evaluate( tcCurAtrCorrectos + ".Longitud" ) ) + "'." ) 	
			endif

		else
            This.oInformacionIndividual.AgregarInformacion( ;
            	"La entidad 'Cálculo de precios' debe poseer el atributo '" + proper( tcAtributo ) + "'.")
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadImportacion() as Void
		local lcMensaje as String, lcCursor as String
		
		lcCursor = sys( 2015 )
		select distinct a.Entidad, e.funcionalidades ;
			from diccionario a	inner join entidad e on alltrim( upper( a.Entidad )) == alltrim( upper( e.Entidad )) ;
								inner join dominio d on alltrim( upper( a.dominio )) == alltrim( upper( d.dominio )) ;
			where 	d.Detalle ;
					and "<HABILITARIMPOINSEGURA>" $ alltrim( upper( e.funcionalidades )) ;
			into cursor ( lcCursor )
		
		scan
			lcMensaje = "La entidad " + alltrim( &lcCursor..Entidad ) + " no se puede importar sin validaciones debido a que tiene atributos de tipo detalle."
			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		
		select * from Entidad e ;
			where 	"<HABILITARIMPOINSEGURA>" $ alltrim( upper( e.funcionalidades )) and "<NOIMPO>" $ alltrim( upper( e.funcionalidades )) ;
			into cursor ( lcCursor )
		
		scan
			lcMensaje = "La entidad " + alltrim( &lcCursor..Entidad ) + " no debe tener la funcionalidad <NOIMPO> para poder tener la funcionalidad de IMPORTACIONES SIN VALIDACIONES."
			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		
		use in select ( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadFechaCAI() as Void
		local lnCantidad as Integer
		select Entidad
		scan all for "<CAI>" $ alltrim( upper( funcionalidades ))
			select Diccionario
			count to lnCantidad for alltrim( upper( Entidad )) == alltrim( upper( Entidad.Entidad )) and "<FECHACAI>" $ alltrim( upper( Tags ))
			if lnCantidad != 1
				This.oInformacionIndividual.AgregarInformacion( "Debe haber solamente un atributo con tag FECHACAI en la entidad " + alltrim( proper( Entidad.entidad ) ) )
			endif
			select Entidad
		endscan
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTags() as Void
		local lcCursor as String, lcTag as String
		local array laTags[1]
		
		lcCursor = sys( 2015 )
		select entidad, atributo, tabla, campo, sumarizar, admitebusqueda, tags, alta, claveforanea from diccionario where !empty(tags) order by entidad, tags into cursor &lcCursor

		scan
			this.ValidarPrimerTag( lcCursor )

			alines( laTags, &lcCursor..tags, 1, ";" )
			for each lcTag in laTags
				this.ValidarTag_CaracterDeInicio( lcCursor, lcTag )
				this.ValidarTag_CaracterDeFin( lcCursor, lcTag )
				this.ValidarTagPermitidos( lcCursor, lcTag, "diccionario")
				this.ValidarTagCondicionSumarizar( lcCursor, lcTag )
				this.ValidarTagOrdenEnBuscador( lcCursor, lcTag )
				this.ValidarTagDetalleEnBuscador( lcCursor, lcTag )
				this.ValidarTagAdmiteBusquedaSubEntidad( lcCursor, lcTag )
			endfor
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTag_CaracterDeInicio( tcCursor as String, tcTag as String ) as Void
		if left( tcTag, 1 ) != "<"
			this.oInformacionIndividual.AgregarInformacion( ;
				"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
				"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
				"' esta mal ingresado; debe comenzar con el signo <." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTag_CaracterDeFin( tcCursor as String, tcTag as String ) as Void
		if right( tcTag, 1 ) != ">"
			this.oInformacionIndividual.AgregarInformacion( ;
				"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
				"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
				"' esta mal ingresado; debe finalizar con el signo >." )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
function ValidarTagPermitidos( tcCursor as String, tcTag as String, tcAdn as String ) as Void
		local lcTag as String
		lcTag = lower( tcTag )
		lcTag = strtran( lcTag, "<", "" )
		lcTag = strtran( lcTag, ">", "" )
		
		do case 
		
			case upper( tcAdn ) == 'DICCIONARIO'
				if "combinacion" $ lctag
					lcTag = substr( lcTag, 1, 11 )
				endif
				if "ordenaralcargar" $ lctag
					lctag = substr( lcTag, 1, 15 )
				endif	
				if "condicionsumarizar" $ lctag
					lcTag = substr( lcTag, 1, 18 )
				endif

				if "sugeridoanulacion" $ lctag
					lcTag = substr( lcTag, 1, 17 )
				endif

				if at( ":", lcTag ) > 0
					lcTag = substr( lcTag, 1, at( ":", lcTag ) - 1 )
				endif

				if !( inlist( lcTag, "combinacion", "nocopiar", "fechacai", "obligatorio", "condicionsumarizar", "desdesugerido", "hastasugerido", ;
								   "filtroconceronovacio", "novacios", "atributoanulacion", "sugeridoanulacion", "ordenbuscador", "ordenaralcargar", ;
								   "saltodecampo", "nosaltodecampo", "nolistagenerico","listartodossusatributos", "excluirfiltros", "pp", "copiadetalle", "nomantenerenrecepcion", "forzarlistargenerico", "norecepcionarenupdate", ;
								   "respetarparametrocasesensitive", "soportaprepantalla") ;
								   or inlist( lcTag, "filtrogtin", "ignorar_pk", "excluirdelbuscador", "incluirenbuscador", "noindexa",;
								    "noimpogenerico", "noexpogenerico", "multiplica", "detalleenbuscador", "edicionparcial",;
								     "noaplicarmascaraenlistados", "mantenimientocuit", "extensible", "copiadesdetxt", "forzarrest", "actualizaemailcliente",;
								     "conparticipantes", "novalidakit", "forzarfiltropaquete", "admitebusquedasubentidad" ) ;
					)

					this.oInformacionIndividual.AgregarInformacion( ;
						"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
						"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
						"' esta mal ingresado; '" + proper( tcTag ) + "' no es un tag válido." )
				endif
				
			case upper( tcAdn ) == 'LISTCAMPOS'

				if at( ":", lcTag ) > 0
					 lcTag = substr( lcTag, 1, at( ":", lcTag ) - 1)
				endif
				
				if !inlist( lcTag, "desdesugerido", "hastasugerido", "filtroconceronovacio", "novacios", "atributosubtotal", ;
							"noperzonalizacampo", "noperzonalizafiltro", "enterosinseparadordemiles", "3decimalesvirtual" )
							
					this.oInformacionIndividual.AgregarInformacion( ;
						"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
						"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
						"' esta mal ingresado; '" + proper( tcTag ) + "' no es un tag válido." )
				endif
			
		endcase
	endfunc
	*-----------------------------------------------------------------------------------------
	function ValidarPrimerTag( tcCursor as String ) as Void
		local lctags as String
		lctags = &tcCursor..Tags
		if "combinacion" $ lower( lctags ) 
			if lower( left( lctags, 12 ) ) != "<combinacion"
				this.oInformacionIndividual.AgregarInformacion( ;
					"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
					"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
					"' esta mal ingresado; Combinacion99 debe ser el primer tag." )
			endif
			if !between( val( substr( lctags, 13, 2 ) ), 1, 99 )
				this.oInformacionIndividual.AgregarInformacion( ;
					"El tag del atributo '" + proper( alltrim( &tcCursor..Atributo ) ) + ;
					"' de la entidad '" + proper( alltrim( &tcCursor..Entidad ) ) + ;
					"' esta mal ingresado; El tag Combinacion debe estar seguido " + ;
					"de dos dígitos que indican el orden (01->99)." )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTagCondicionSumarizar( tcCursor as String, tcTag as String ) as Void
		local lcMensaje as String, lcSumarizar as String, lcTag as String

		if occurs( "<CONDICIONSUMARIZAR", upper( tcTag ) ) > 0
			lcTag = chrtran( tcTag, "<>", "" )

			lcSumarizar = &tcCursor..Sumarizar
			if empty( lcSumarizar )
				lcMensaje = "Entidad: [" + proper( alltrim( &tcCursor..Entidad ) ) + "] Atributo: [" + proper( alltrim( &tcCursor..Atributo ) ) + "] - Tiene especificado el tag <CONDICIONSUMARIZAR> para un atributo que no se sumariza."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif

			if occurs( "CONDICIONSUMARIZAR", upper( lcTag ) ) > 1
				lcMensaje = "Entidad: [" + proper( alltrim( &tcCursor..Entidad ) ) + "] Atributo: [" + proper( alltrim( &tcCursor..Atributo ) ) + "] - Tiene especificado más de un tag <CONDICIONSUMARIZAR>."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			else
				if occurs( ":", lcTag ) > 1
					lcMensaje = "Entidad: [" + proper( alltrim( &tcCursor..Entidad ) ) + "] Atributo: [" + proper( alltrim( &tcCursor..Atributo ) ) + "] - El tag <CONDICIONSUMARIZAR> no puede poseer más de un carácter [:]."
					this.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endif

			if empty( getwordnum( lcTag, 2, ":" ) )
				lcMensaje = "Entidad: [" + proper( alltrim( &tcCursor..Entidad ) ) + "] Atributo: [" + proper( alltrim( &tcCursor..Atributo ) ) + "] - No se especificó la condición a evaluar para el tag <CONDICIONSUMARIZAR>."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif

		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCopiaTablasEntreSucursales() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		
		select d.entidad, d.atributo;
		from diccionario d inner join entidad e on alltrim( upper( d.entidad )) == alltrim( upper( e.entidad ));
		where "NOCOPIAR" $ alltrim( upper( d.tags )) and !( "W" $ alltrim( upper( e.comportamiento )));
		into cursor &lcCursor
		
		select ( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo: " + alltrim( &lcCursor..atributo ) + " de la entidad: " + alltrim( &lcCursor..entidad ) + " tiene el tag NOCOPIAR pero no tiene comportamiento 'W'" )
		endscan
		
		
		select e.entidad;
		from entidad e where "W" $ alltrim( upper( e.comportamiento )) and not ( empty( ubicacionDB ) or alltrim( upper( ubicacionDB )) == "SUCURSAL" );
		into cursor &lcCursor
		
		select ( lcCursor )
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad: " + alltrim( &lcCursor..entidad ) + " tiene comportamiento 'W' y no es de sucursal." )
		endscan
		
		use in select( lcCursor )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadEntidadNoEditableYBloquearRegistro() as Void
		local lcMensaje as String, lcCursor as String, lcEntidad as String
		
		lcCursor = sys( 2015 )

		select distinct e.Entidad, e.funcionalidades as funcionalidades ;
			from entidad e ;
			where ( "<ENTIDADNOEDITABLE>" $ funcionalidades or "<BLOQUEARREGISTRO>" $ funcionalidades );
				and ( ( !"<NOIMPO>" $ funcionalidades and !( "<HABILITARIMPOINSEGURA>" $ funcionalidades ) ) or "<ANULABLE>" $ funcionalidades );
			into cursor ( lcCursor )
		
		scan
			lcEntidad = upper( alltrim( &lcCursor..Entidad ) )
			if inlist( lcEntidad , "IMPUESTO","ITEMESCALA", "REGIMENIMPOSITIVO","TIPOIMPUESTO","NOMENCLADORARBA","JURISDICCION","ESTADOSDEINTERACCION","ARTICULO" )
			else
				lcMensaje = "La entidad " + alltrim( &lcCursor..Entidad ) + " no puede tener la funcionalidades <ENTIDADNOEDITABLE> y/o <BLOQUEARREGISTRO> si" + ;
							", además, no contiene la funcionalidad <NOIMPO> y/o contiene las funcionalidades <ANULABLE>."
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
		endscan
		
		use in select ( lcCursor )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	Function ValidarOrdenEnDominioDireccion() As VOID
		Local lcEntidad As String

		Select Distinct entidad From Entidad Into Cursor cur_Entidad

		Select cur_Entidad
		Scan
			lcEntidad = Alltrim( Entidad )

			Select atributo, orden;
				from diccionario ;
				where Upper( Dominio ) == "DIRECCION" and Upper( entidad ) == Upper( lcEntidad ) ;
				order By Orden ;
				into Cursor Cur_Direccion

			select Cur_Direccion
			scan 
				do case
					case recno() = 1 and upper( atributo ) # "CALLE"
						This.oInformacionIndividual.AgregarInformacion( ;
							"Entidad " + lcEntidad + ". El primer atributo tiene que ser CALLE. " )
							*+ ;
							*"El orden para el dominio DIRECCION tiene que ser: CALLE, NUMERO, PISO, DEPARTAMENTO" )

*					case recno() = 2 and ( upper( atributo ) # "NUMERO" and upper( atributo ) # "NRO" )
					case recno() = 2 and upper( atributo ) # "NUMERO"
						This.oInformacionIndividual.AgregarInformacion( ;
							"Entidad " + lcEntidad + ". El segundo atributo tiene que ser NUMERO. " )
							*+ ;
							*"El orden para el dominio DIRECCION tiene que ser: CALLE, NUMERO, PISO, DEPARTAMENTO" )
							
					case recno() = 3 and upper( atributo ) # "PISO"
						This.oInformacionIndividual.AgregarInformacion( ;
							"Entidad " + lcEntidad + ". El tercer atributo tiene que ser PISO. " ) 
							*+ ;
							*"El orden para el dominio DIRECCION tiene que ser: CALLE, NUMERO, PISO, DEPARTAMENTO" )
					
*					case recno() = 4 and ( upper( atributo ) # "DEPARTAMENTO" and upper( atributo ) # "DTO" )
					case recno() = 4 and upper( atributo ) # "DEPARTAMENTO"
						This.oInformacionIndividual.AgregarInformacion( ;
							"Entidad " + lcEntidad + ". El cuarto atributo tiene que ser DEPARTAMENTO. " )
							*+ ;
							*"El orden para el dominio DIRECCION tiene que ser: CALLE, NUMERO, PISO, DEPARTAMENTO" )
					
				endcase
			endscan

	
			Use In select( "Cur_Direccion" )
		Endscan

		Use In select( "cur_Entidad" )
		
		if This.oInformacionIndividual.Count > 0
			This.oInformacionIndividual.AgregarInformacion( "El orden para el dominio DIRECCION tiene que ser: CALLE, NUMERO, PISO, DEPARTAMENTO" )
		endif

	Endfunc	

	*-----------------------------------------------------------------------------------------
	function ValidarDominioParaCampoGUID() as Void
		local lcCursor as String
		
		lcCursor = "c_" + sys( 2015 )
		try
			select Entidad, Atributo, Dominio from diccionario where upper( alltrim( TipoDato ) ) == "G" into cursor &lcCursor		
			select &lcCursor
			scan for upper( alltrim( Dominio ) ) == "CODIGONUMERICO"
			
				This.oInformacionIndividual.AgregarInformacion( "El Atributo '" + upper( alltrim( &lcCursor..Atributo ) ) + ;
						"' de la entidad '" + upper( alltrim( &lcCursor..Entidad ) ) + ;
						"' es tipo GUID y no puede tener el dominio '" + upper( alltrim( &lcCursor..Dominio ) ) + "'." )
			endscan
			
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTablas_Compartidas_Por_Items_Y_Entidades() as Void
		local lcCursorEntidades as String, lcCursorDeProblemas as String 
		lcCursorEntidades = "c_" + sys( 2015 )
		lcCursorDeProblemas = "c_" + sys( 2015 )
		if !inlist( This.cProyectoActivo, 'ZL', 'LINCEORGANIC' )
			try
				select upper( d.Entidad ) as Entidad, upper( d.Tabla ) as Tabla, upper( d.Campo ) as Campo ;
				from Diccionario d ;
				inner join Entidad e on upper( alltrim( d.Entidad ) ) == upper( alltrim( e.Entidad ) ) ;
				where upper( e.Tipo )  = "E" and d.ClavePrimaria ;
					into cursor &lcCursorEntidades

				select upper( c.Entidad ) as Entidad, upper( c.Campo ) as CampoPk, upper( d.Tabla ) as Tabla, upper( d.Entidad ) as Item  ;
				from Diccionario d	;
				inner join Entidad e on upper( alltrim( d.Entidad ) ) == upper( alltrim( e.Entidad ) ) ;
				inner join &lcCursorEntidades c on upper( alltrim( d.Tabla ) ) == upper( alltrim( c.Tabla ) ) ;
				where upper( e.Tipo ) = "I" and d.ClavePrimaria and !empty( d.Tabla )  ;
					into cursor &lcCursorDeProblemas

				select * from &lcCursorDeProblemas cp ;
				where upper( cp.CampoPk ) not in ( ;
						selec upper( d.campo ) ;
						from diccionario d ;
						where upper( d.entidad ) == cp.Item and upper( d.Tabla ) == cp.Tabla and upper( d.TipoDato ) == "G" and !empty( d.ValorSugerido )  ) ;
					into cursor &lcCursorDeProblemas

				select &lcCursorDeProblemas
				scan all
					lcMensaje = "La entidad '" + upper( alltrim( &lcCursorDeProblemas..Entidad ) ) + ;
							"' no debe compartir la tabla '" + alltrim( upper( &lcCursorDeProblemas..Tabla ) ) + ;
							"' con el Item " + upper( alltrim( &lcCursorDeProblemas..Item ) )  + ", salvo que el item " + upper( alltrim( &lcCursorDeProblemas..Item ) )  + " autocomplete por medio de un valor sugerido el campo " + ;
							" que corresponde a la clave primaria de la entidad '" + upper( alltrim( &lcCursorDeProblemas..Entidad ) ) + "'."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
					select &lcCursorDeProblemas
				endscan
			catch to loError
				throw loError
			finally
				use in select( lcCursorEntidades )
				use in select( lcCursorDeProblemas )
			endtry
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTransferencias() as Void
		local lcCursor as String 
		lcCursor = sys(2015)

		select distinct tr.entidad ;
			from transferencias tr ;
			where upper(tr.entidad) not in ( select upper( e.entidad ) from entidad e where upper( tipo ) = "E" );
			into cursor &lcCursor
		
		select(lcCursor)
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..entidad ) + " está en transferencias y no existe como entidad" )
		endscan
		
		
		**************************
		select * from transferencias where empty( entidad ) or empty( codigo ) or empty( descrip ) into cursor &lcCursor
		select(lcCursor)
		scan
			This.oInformacionIndividual.AgregarInformacion( "Faltan campos obligatorios en la tabla transferencias" )
		endscan
		
		**************************
		select distinct tr.codigo ;
			from transferencias tr ;
			where upper(tr.codigo) in ( select upper( e.entidad ) from entidad e where upper( tipo ) = "E" );
			into cursor &lcCursor
		
		select(lcCursor)
		scan
			This.oInformacionIndividual.AgregarInformacion( "El código de transferencia " + alltrim( &lcCursor..codigo ) + " es inválido ya que existe como entidad" )
		endscan

		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarFiltrosTransferencias() as Void
		local lcCursor as String 
		lcCursor = sys(2015)

		select distinct tr.entidad ;
			from transferencias tr ;
			where upper( tr.entidad ) not in ( select upper( tf.entidad ) from TransferenciasFiltros tf );
			into cursor &lcCursor
		
		select(lcCursor)
		scan
			This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..entidad ) + " está en transferencias pero no tiene cargado filtros" )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCoherencia_De_SubEntidades() as Void
		
		select d.Entidad, e.UbicacionDB as UbiEntidad, d.Atributo, d.ClaveForanea, e1.UbicacionDB as UbiCF ;
			from Diccionario d	inner join Entidad e	on upper( alltrim( d.Entidad ) ) == upper( alltrim( e.Entidad ) ) ;
								inner join Entidad e1	on upper( alltrim( d.ClaveForanea ) ) == upper( alltrim( e1.Entidad ) ) ;
			into cursor cVer ;
			where !empty( d.ClaveForanea ) ;
			having upper( UbiEntidad ) != upper( UbiCF ) and alltrim( upper( UbiCF ) ) != "ORGANIZACION"

		select cVer
		scan all
			This.oInformacionIndividual.AgregarInformacion( "El Atributo " + proper( alltrim( cVer.Atributo ) ) + " de la entidad " + proper( alltrim( cVer.Entidad ) ) + ;
				" tiene como clave foranea una entidad cuya Ubicación no es " + proper( alltrim( cVer.UbiEntidad ) ) + iif( upper( alltrim( cVer.UbiEntidad ) ) == "ORGANIZACION" , "", " o de Organización" ) )
			select cVer
		endscan
		if reccount( "cver" ) > 0
			This.oInformacionIndividual.AgregarInformacion( "Falló validar coherencia de ubicacion de base de datos de subentidades" )
		EndIf
		use in cVer
	endfunc
	
*!*		*-----------------------------------------------------------------------------------------
*!*		function ValidarAuditoriaEnCampoLogico() as Void
*!*			local lcCursorTmp as String, lcMensaje as String, lcDiccionarioAdicional as String
*!*			lcCursorTmp = sys( 2015 )
*!*			
*!*			lcDiccionarioAdicional = this.cDiccionarioAdicional
*!*			
*!*			select d.TipoDato, d.Atributo, d.Entidad ;
*!*				from &lcDiccionarioAdicional d ;
*!*				where alltrim( upper( d.TipoDato )) = "L" and;
*!*					d.Auditoria = .t.;
*!*				into cursor ( lcCursorTmp )

*!*			select ( lcCursorTmp )
*!*			scan
*!*				lcMensaje =  "El atributo lógico '" +  upper( alltrim( &lcCursorTmp..Atributo ) ) + "' de la Entidad '"+;
*!*					upper( alltrim( &lcCursorTmp..Entidad ) ) + "' no debe tener auditoria."
*!*				This.oInformacionIndividual.AgregarInformacion( lcMensaje  )
*!*			endscan

*!*			use in select( lcCursorTmp )
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarNombreTablasConCampo() As VOID
	
		select * from diccionario ;
		where ( lower( alltrim( tabla )) == lower( alltrim( campo)) ) and !empty( tabla ) ;
		into cursor C_CampoIgualATabla

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "El nombre del campo es igual a la tabla ( Entidad: "+ ;
								alltrim( C_CampoIgualATabla.entidad ) + " Atributo: " + alltrim( C_CampoIgualATabla.atributo ) + ")")
						
			Endscan
		Endif

		Use In select( "C_CampoIgualATabla" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarEsquemasTablas() As VOID
	
		select distinct tabla, esquema from diccionario into cursor c_TablasEsquemas where !empty( tabla ) and !empty( campo )
		select count(*) cantidad, tabla from c_TablasEsquemas group by tabla having cantidad > 1 into cursor c_EsquemasTabla

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "La tabla [" +  alltrim( c_EsquemasTabla.tabla ) + "] en el diccionario tiene asignado más de un Esquema." )
			Endscan
		Endif
	
		select distinct tabla, esquema from tablasInternas into cursor c_TablasEsquemas
		select count(*) cantidad, tabla from c_TablasEsquemas group by tabla having cantidad > 1 into cursor c_EsquemasTabla

		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "La tabla [" +  alltrim( c_EsquemasTabla.tabla ) + "] en tablasinternas tiene asignado más de un Esquema." )
			Endscan
		Endif

		Use In select( "c_TablasEsquemas" )
		Use In select( "c_EsquemasTabla" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarTablasInternasContraDiccionario() as Void
		
		select distinct d.tabla from diccionario as d where d.tabla in ( select tabla from tablasinternas ) into cursor c_Tabla
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "La tabla [" +  alltrim( c_Tabla.tabla ) + "] en diccionario existe en tablasinternas." )
			Endscan
		Endif

		use in select( "c_Tabla" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarDetallesObligatorios() as Void
		local lcCursor as String, loError as zooexception OF zooexception.prg, lcMensaje as String
		
		Try
			lcCursor = "cur_" + sys( 2015 )
			select Atributo as Atributo , entidad from diccionario ;
						where substr( dominio, 1, 7 ) == "DETALLE" and ;
						"<OBLIGATORIO>" $ Tags and ;
						empty( etiqueta );
					into cursor &lcCursor
					
			
			select &lcCursor
			scan
				lcMensaje = "El detalle '" + upper( alltrim( &lcCursor..Atributo ) ) + "' de la entidad '" + ;
							upper( alltrim( &lcCursor..Entidad ) ) + "' debe tener cargada la etiqueta cuando se espeficica que es obligatorio."
							
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan	
			
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry

	endfunc 


	*-----------------------------------------------------------------------------------------
	function ValidarEntidadesAnulables() as Void

		local lcCursor as String, loError as zooexception OF zooexception.prg, lcMensaje as String
		
		Try
			lcCursor = "cur_" + sys( 2015 )
			
			select r.entidad ;
			 from relacomponente r ;
			 where upper(alltrim( r.componente )) == "STOCK" and !( upper( alltrim( r.entidad ) ) == 'ITEMMSTOCKAPROD' ) ;
			 into cursor cur_RelaComponente
			
			select e2.entidad from entidad e ;
				inner join cur_RelaComponente r on alltrim( upper( e.entidad ) ) == alltrim( upper( r.entidad )) ;
				inner join diccionario d on "DETALLE" + alltrim( upper( e.entidad ) ) == alltrim( upper( d.dominio ));
				inner join entidad e2 on alltrim( upper( d.entidad ) ) == alltrim( upper( e2.entidad )) ;
			where e.tipo = "I" and not("<ANULABLE>" $ e2.funcionalidades);
			union ;
			select e.entidad from entidad e ;
				inner join cur_RelaComponente r on alltrim( upper( e.entidad ) ) == alltrim( upper( r.entidad )) ;
			where e.tipo = "E" and not("<ANULABLE>" $ e.funcionalidades);			
			into cursor &lcCursor
			
			select &lcCursor
			scan
				lcMensaje = "La entidad " + upper( alltrim( &lcCursor..Entidad ) ) + " tiene componente STOCK y deberia ser ANULABLE"
				This.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan	
			
		catch to loError
			throw loError
		finally
			use in select( "cur_RelaComponente" )
			use in select( lcCursor )
		endtry

	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCodigoDeBarras() as Void

		local lcCursor as String, loError as zooexception OF zooexception.prg, lcMensaje as String, lnLongitud as integer, ;
			lnLongitudCodigoBarras as integer, lcAux as string
		
		Try
			lcCursor = "cur_" + sys( 2015 )
			
			select distinct upper( r.Atributo ) as atributo from diccionario r ;
				where upper(alltrim( r.entidad )) == "STOCKCOMBINACION" and ;
					!empty( ClaveCandidata ) ;
				into cursor cur_Combinacion
			
			select distinct upper( d.Entidad ) as entidad from diccionario d ;
					inner join entidad e on upper( alltrim( e.Tipo ) ) == "I" ;
					where alltrim( upper( d.Atributo ) ) == "CODIGODEBARRAS" ;
				into cursor cur_DiccionarioConCodBarra


			select distinct upper( d.Entidad ) as entidad, upper( d.Atributo ) as atributo, d.Longitud from diccionario d ;
					inner join entidad e on upper( alltrim( e.Tipo ) ) == "I" ;
					where ( alltrim( upper( d.Atributo ) ) == "CODIGODEBARRAS" or ;
							alltrim( upper( d.Atributo ) ) == "CANTIDAD" or ;
							alltrim( upper( d.Atributo ) ) in ( select alltrim( upper( Atributo ) ) from cur_Combinacion ) ) and ;
							alltrim( upper( d.Entidad ) ) in ( select alltrim( upper( Entidad ) ) from cur_DiccionarioConCodBarra ) ;
				into cursor cur_Diccionario

			select d.Entidad, d.Atributo, d.Longitud from cur_Diccionario d ;
					order by  d.Entidad, d.Atributo ;
				into cursor cur_Diccionario

			if _tally > 0
				lnLongitud = 0
				lnLongitudCodigoBarras = 0
				lcAux = ""

				select cur_Diccionario
				go top
				scan
					if lcAux != alltrim( upper( cur_Diccionario.Entidad ) )
						if !empty( lcAux ) and lnLongitudCodigoBarras < lnLongitud 
							lcMensaje = "La longitud del atributo CODIGODEBARRAS de la entidad " + upper( alltrim( lcAux ) ) + ;
										" es " + transform( lnLongitudCodigoBarras ) + " y debería ser mayor o igual a " + transform( lnLongitud ) + "."
										
							This.oInformacionIndividual.AgregarInformacion( lcMensaje )
						endif

						lnLongitud = 0
						lnLongitudCodigoBarras = 0
						lcAux = alltrim( upper( cur_Diccionario.Entidad ) )
					endif

					if alltrim( upper( cur_Diccionario.Atributo ) ) == "CODIGODEBARRAS"
						lnLongitudCodigoBarras = cur_Diccionario.Longitud
					else
						** Le sumo 1 por el caracter que separa y el signo de la cantidad
						lnLongitud = lnLongitud + cur_Diccionario.Longitud + 1
					endif
				endscan
			
				if !empty( lcAux ) and lnLongitudCodigoBarras < lnLongitud 
					lcMensaje = "La longitud del atributo CODIGODEBARRAS de la entidad " + upper( alltrim( lcAux ) ) + ;
								" es " + transform( lnLongitudCodigoBarras ) + " y debería ser mayor o igual a " + transform( lnLongitud ) + "."
								
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif

			endif	
			
			select upper( r.Entidad ) as entidad from diccionario r ;
				where upper(alltrim( r.Atributo ) ) == "CODIGODEBARRAS" and ( !empty( r.Tabla ) or !empty( r.Campo ) ) ;
				into cursor cur_AtributoVirtual
				
			if _tally > 0	
				select cur_AtributoVirtual
				scan
					lcMensaje = "El atributo CODIGODEBARRAS de la entidad " + upper( alltrim( cur_AtributoVirtual.Entidad ) ) + ;
								" debe ser un Atributo virtual y por eso no se permite configurarle la Tabla ni el Campo."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endscan	
			endif
					
		catch to loError
			throw loError
		finally
			use in select( "cur_Combinacion" )
			use in select( "cur_Diccionario" )
			use in select( "cur_DiccionarioConCodBarra" )
			use in select( lcCursor )
			use in select( "cur_AtributoVirtual" )			
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFiltroTransferenciaDisenoImpresion() as void
		local lnTotalRegistros As Integer

		try
			if !inlist( This.cProyectoActivo, "ADNIMPLANT", "GENERADORES" )

				select * from entidad where upper( alltrim( entidad ) ) == "DISENOIMPRESION" into cursor c_Diseno
				if _tally > 0
					select entidad, atributo ;
						from transferenciasfiltros ;
						where upper( alltrim( entidad ) ) == "DISENOIMPRESION" and upper( alltrim( atributo ) ) == "CODIGO" ;
						into cursor c_transf

					lnTotalRegistros = _tally
					
					if lnTotalRegistros = 1
					else
						This.oInformacionIndividual.AgregarInformacion( "El atributo CODIGO de la entidad DISENOIMPRESION en la tabla transferenciasfiltros no existe." )
					endIf
				endif
			endif
		catch to loError
			throw loError
		finally
			use in select( "c_Diseno" )
			use in select( "c_transf" )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarMenuTransferenciaDisenoImpresion() as void
		local lnTotalRegistros As Integer

		try
			if !inlist( This.cProyectoActivo, "ADNIMPLANT", "GENERADORES" )
				select * from entidad where upper( alltrim( entidad ) ) == "DISENOIMPRESION" into cursor c_Diseno
				if _tally > 0
					select entidad, etiqueta ;
						from menualtasitems ;
						where upper( alltrim( entidad ) ) == "DISENOIMPRESION" and upper( alltrim( etiqueta ) ) == "EMPAQUETAR DATOS" ;
						into cursor c_transfmenu

					lnTotalRegistros = _tally

					if lnTotalRegistros = 1
					else
						This.oInformacionIndividual.AgregarInformacion( "La etiqueta EMPAQUETAR DATOS de la entidad DISENOIMPRESION en la tabla menualtasitems no existe." )
					endIf
				endif
			endif
		catch to loError
			throw loError
		finally
			use in select( "c_Diseno" )
			use in select( "c_transfmenu" )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarFormatoDescripcionEnComprobantes() as Void
		local lnCantEntidades as Integer, i as Integer, loError as zooexception OF zooexception.prg
		local array laEntidades[ 1 ]

		select componente, entidad, .f. as tieneAuditoria ;
			from componente ;
			where !empty( entidad ) ;
			into cursor c_TmpEntidadesComponentes readwrite

		select c_TmpEntidadesComponentes
		scan 		
			lnCantEntidades = alines( laEntidades, c_TmpEntidadesComponentes.Entidad, 9, "," )
			for i = 1 to lnCantEntidades
				select entidad
				locate for alltrim( upper( entidad ) ) == alltrim( upper( laEntidades[ i ] ) )
				if found()
					if this.oFunc.TieneFuncionalidad( "AUDITORIA", entidad.Funcionalidades )
						replace c_TmpEntidadesComponentes.tieneAuditoria with .t.
					endif
				else
					This.oInformacionIndividual.AgregarInformacion( "No se encuentra la entidad " + laEntidades[ i ] + ". Funcion: ValidarFormatoDescripcionEnComprobantes"  )
				endif
			endfor
		endscan
		
		select rc.entidad, e.tipo, e.FormatoDescripcion ;
			from relacomponente rc inner join c_TmpEntidadesComponentes c on alltrim( upper( rc.componente ) ) == alltrim( upper( c.Componente ) ) ;
				inner join entidad e on alltrim( upper( rc.entidad ) ) == alltrim( upper( e.Entidad ) ) ;
			where c.tieneAuditoria ;
			into cursor c_TmpEntidadesAValidar

		** Valido entidades
		select c_TmpEntidadesAValidar
		scan for empty( c_TmpEntidadesAValidar.FormatoDescripcion ) and tipo = "E"
			This.oInformacionIndividual.AgregarInformacion( "La entidad '" + alltrim( upper( c_TmpEntidadesAValidar.Entidad ) ) + "' no tiene cargado el campo FORMATODESCRIPCION de la tabla ENTIDAD." )
		endscan

		** Valido items
		select distinct e.entidad ;
			from diccionario d inner join c_TmpEntidadesAValidar ev on alltrim( upper( substr( d.Dominio, 8 ) ) ) == alltrim( upper( ev.entidad ) ) ;
				inner join entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where ev.Tipo = "I" and empty( e.FormatoDescripcion ) ;
			into cursor c_TmpEntidadesAValidarConItem
			
		select c_TmpEntidadesAValidarConItem
		scan 
			This.oInformacionIndividual.AgregarInformacion( "La entidad '" + alltrim( upper( c_TmpEntidadesAValidarConItem.Entidad ) ) + "' no tiene cargado el campo FORMATODESCRIPCION de la tabla ENTIDAD." )
		endscan
		
		
		use in select( "c_TmpEntidadesComponentes" )
		use in select( "c_TmpEntidadesAValidar" )
		use in select( "c_TmpEntidadesAValidarConItem" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoCodigoEnCabeceraYDetalle() as Void
		local lnLongitudDelDetalle as Integer, lcAtributoDetalle as String
	
		select distinct upper( entidad ) as entidad ;
			from Diccionario as d;
			where !empty( d.entidad ) and upper( left(d.dominio,7 )) == "DETALLE" and upper( alltrim( d.Entidad ) ) == "ACCIONESAUTOMATICAS" ;
			order by Entidad ;
			into cursor c_TmpEntidadesConDetalle readwrite
			
		select upper( d.Entidad ) as Entidad, upper( d.Atributo ) as Atributo, d.Longitud as Longitud  from diccionario as d ;
		inner join c_TmpEntidadesConDetalle as c on upper( d.Entidad ) == upper( c.Entidad ) ;
		where d.ClavePrimaria ;
		into cursor c_AtributosClavePrimaria readwrite

		select upper( d.Entidad ) as Entidad, upper( d.Atributo ) as Atributo, d.Longitud as Longitud from diccionario as d ;
		inner join c_TmpEntidadesConDetalle as c on upper( d.Entidad ) == upper( c.Entidad ) ;
		where upper( left(d.dominio,7 )) == "DETALLE" ;
		into cursor c_AtributosDetalle readwrite
		
		select c_AtributosDetalle
		scan
			lnLongitudDelDetalle = c_AtributosDetalle.Longitud
			lcAtributoDetalle = upper( alltrim( c_AtributosDetalle.Atributo ) )
			
			select c_AtributosClavePrimaria
			locate for alltrim( upper( c_AtributosClavePrimaria.entidad ) ) == upper( alltrim( c_AtributosDetalle.Entidad ) )
			if found()
				if lnLongitudDelDetalle != c_AtributosClavePrimaria.Longitud
					This.oInformacionIndividual.AgregarInformacion( "Entidad: " + upper( alltrim( c_AtributosClavePrimaria.entidad ) ) + ;
						". La longitud del atributo " + lcAtributoDetalle + ;
						" longitud="+transform( lnLongitudDelDetalle ) + ;
						", debe ser igual a la longitud de la clave primaria de su entidad " + ;
						alltrim( c_AtributosClavePrimaria.Entidad ) + " longitud="+transform(c_AtributosClavePrimaria.Longitud)+"." )
				endif
			endif
			select c_AtributosDetalle
		endscan
		use in select( "c_TmpEntidadesConDetalle" )
		use in select( "c_AtributosClavePrimaria" )
		use in select( "c_AtributosDetalle" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ControlarExistenciasDeTablasConMasDeUnaClavePrimaria() as Void
		local lcCursor as String, loError as Exception
		
		if !inlist( This.cProyectoActivo, 'ZL', 'LINCEORGANIC' )
			lcCursor = "c_" + sys( 2015 )
			try
				select Tabla1 As Tabla, count( * ) as Cantidad ;
			      from ( ;
	                  select alltrim( upper( d.Tabla ) ) as Tabla1, alltrim( upper( d.Campo ) ) as Campo1 ;
	                        from Diccionario d ;
	                        inner join Entidad e on upper( e.Entidad ) == upper( d.Entidad ) ;
	                        where d.ClavePrimaria and !empty ( d.Tabla ) and !empty( d.Campo ) and upper( e.Tipo ) == "E";
	                        group by Tabla1, Campo1 ;
	                        order by d.Tabla ;
	        	     ) As Tablas ;
		       group by Tabla ;
	    	   having Cantidad > 1 into cursor &lcCursor
					
				select &lcCursor
				scan all
					This.oInformacionIndividual.AgregarInformacion( "La tabla '" + upper( alltrim( &lcCursor..Tabla ) ) + ;
							"' tiene mas de una clave primaria." )
				endscan
			catch to loError
				throw loError
			finally
				use in select( lcCursor )
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarConsistenciaDeEntidadesAnulablesYMenu() as Void
		local lcMensaje as String, lcCursorEntidad as String, lcCursorMenu as String, loError as Exception, lcExcluir as string 
		
		lcCursorEntidad = sys( 2015 )
		lcCursorMenu = sys( 2015 )
		lcExcluir = ",SENIA,"



		try
			select distinct e.Entidad from entidad e ;
				where ( "<ANULABLE>" $ e.funcionalidades ) and ;
					Formulario and ;
					"," + upper( alltrim( e.Entidad ) ) + "," not in ( lcExcluir ) ;
				into cursor ( lcCursorEntidad )


			select m.Entidad from menualtasitems m ;
				inner join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( m.Entidad ) ) and e.Formulario ;
				where ( "THISFORM.OKONTROLER.EJECUTAR('ANULAR')" == upper( strtran( m.comando, " ", "" ) ) ) and ;
						( "THISFORM.LDESHABILITARANULAR" == upper( alltrim( m.skipfor ) ) ) and ;
						( 37 == m.idImagen ) and ;
						( .t. == m.toolbar ) and ;
						( "ANULAR" == upper( alltrim( m.Codigo ) ) ) ;
				into cursor ( lcCursorMenu )
						
			select ( lcCursorEntidad )
			scan
				select ( lcCursorMenu )
				locate for upper( alltrim( &lcCursorMenu..Entidad ) ) == upper( alltrim( &lcCursorEntidad..Entidad ) )
				if !found()
					lcMensaje = "La entidad " + alltrim( &lcCursorEntidad..Entidad ) + " tiene funcionalidad <ANULABLE> y no tiene cargado (o está cargado de forma incorrecta) de forma el menú ANULAR."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				ENDIF

				select ( lcCursorEntidad )
			endscan

			select ( lcCursorMenu )
			scan
				select ( lcCursorEntidad )
				locate for upper( alltrim( &lcCursorMenu..Entidad ) ) == upper( alltrim( &lcCursorEntidad..Entidad ) )
				if !found()
					lcMensaje = "La entidad " + alltrim( &lcCursorMenu..Entidad ) + " tiene cargado el menú ANULAR y no tiene funcionalidad <ANULABLE>."
					This.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif

				select ( lcCursorMenu )
			endscan

		catch to loError
			throw loError
		finally
			use in select ( lcCursorMenu )
			use in select ( lcCursorEntidad )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCampoInicialConSaltoDeCampo() as Void

		select d.entidad, d.atributo from diccionario d , entidad e where d.campoInicial and d.saltoCampo and ;
		upper( alltrim( d.entidad ) ) == upper( alltrim( e.entidad ) ) and e.Formulario and upper( alltrim( e.Tipo ) ) == 'E' and ;
		d.alta ;
		into cursor c_ValidarCampoInicialConSaltoDeCampo
		
		select c_ValidarCampoInicialConSaltoDeCampo
		scan
			This.oInformacionIndividual.AgregarInformacion( "El atributo '" + alltrim( upper( c_ValidarCampoInicialConSaltoDeCampo.Atributo ) ) + ;
			"' de la entidad '" + alltrim( upper( c_ValidarCampoInicialConSaltoDeCampo.Entidad ) )  +  "' tiene cargado el campo SaltoDeCampo y CampoInicial." )

		endscan
	
		use in select( "c_ValidarCampoInicialConSaltoDeCampo" )

	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ValidarFiltrosTransferenciasSegunTipo() as Void
	
		select e.* from diccionario e, transferenciasFiltros tf where upper( alltrim( e.entidad ) ) == upper( alltrim( tf.Entidad ) ) and ;
			upper( alltrim( e.Atributo ) ) == upper( alltrim( tf.Atributo ) ) and upper( alltrim( e.TipoDato ) ) == "L" ;
				into cursor c_ValidarFiltrosTransferenciaSegunTipo

		select c_ValidarFiltrosTransferenciaSegunTipo
		scan
			This.oInformacionIndividual.AgregarInformacion( "El filtro de la transferencia Entidad " + c_ValidarFiltrosTransferenciaSegunTipo.Entidad + " atributo: " + ;
				+  c_ValidarFiltrosTransferenciaSegunTipo.Atributo + " no puede estar relacionado a un atributo de tipo logico" )
		endscan

		use in select( "c_ValidarFiltrosTransferenciaSegunTipo" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarInformacionIndividual( tcInformacion as String ) as Void
		This.oInformacionIndividual.AgregarInformacion( tcInformacion )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarExpoImpoGenericas() as Void
		select Entidad, Funcionalidades ;
		from Entidad ;
		where ( atc( "<EXPOGENERICA>", Funcionalidades  ) > 0  and atc( "<NOEXPO>", Funcionalidades ) != 0 ) ;
		into cursor c_EntidadesExpoGenericaSinExpo

		if _tally > 0
			scan
				This.oInformacionIndividual.AgregarInformacion( "La funcionalidad <EXPOGENERICA> no debe tener cargado el tag <NOEXPO> en la entidad: " + alltrim( c_EntidadesExpoGenericaSinExpo.entidad ) )
			endscan
		endif
		
		use in select( "c_EntidadesExpoGenericaSinExpo" )
		
		select Entidad, Funcionalidades ;
		from Entidad ;
		where ( atc( "<IMPOGENERICA>", Funcionalidades  ) > 0  and atc( "<NOIMPO>", Funcionalidades ) != 0 ) ;
		into cursor c_EntidadesImpoGenericaSinImpo

		if _tally > 0
			scan
				This.oInformacionIndividual.AgregarInformacion( "La funcionalidad <IMPOGENERICA> no debe tener cargado el tag <NOIMPO> en la entidad: " + alltrim( c_EntidadesImpoGenericaSinImpo.entidad ) )
			endscan
		endif

		use in select( "c_EntidadesImpoGenericaSinImpo" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTablaParametrosYRegistrosEspecificos() as Void
		local lcTipo as String, lcMensaje As String

		select * from ParametrosYRegistrosEspecificos where not idProyecto in ( select distinc id from proyectos ) into cursor c_incorrectos
		
		if _tally > 0
			scan
				lcTipo = iif( c_incorrectos.esregistro, "Registro", "Parametro" )
				lcMensaje = "La id del producto es incorrecto para la especificación del " + lcTipo + ;
					" id: " + transform( c_incorrectos.id ) + " en la tabla ParametrosYRegistrosEspecificos."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endscan
		endif
		use in select( "c_incorrectos" )
		
		select * from ParametrosYRegistrosEspecificos where id < 1 into cursor c_incorrectos
		if _tally > 0
			lcTipo = iif( c_incorrectos.esregistro, "Registro", "Parametro" )
			lcMensaje = "La id del " + lcTipo + " es incorrecto para la especificación del " + lcTipo + ;
				" en la tabla ParametrosYRegistrosEspecificos."
			this.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endif
		use in select( "c_incorrectos" )
		
		select * from ParametrosYRegistrosEspecificos where empty( PARAMUSU ) into cursor c_incorrectos
		if _tally > 0
			lcTipo = iif( c_incorrectos.esregistro, "Registro", "Parametro" )
			lcMensaje = "La especificación del " + lcTipo + ;
				" id: " + transform( c_incorrectos.id ) + " en la tabla ParametrosYRegistrosEspecificos debe tener cargado el campo PARAMUSU."
			this.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endif
				
		use in select( "c_incorrectos" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarEntidadCalculoDePrecios() as void
		local lcEntidad as String, lcAtributo as String

		lcEntidad = "CALCULODEPRECIOS"
		select atributo from Diccionario where upper( alltrim( entidad ) ) == lcEntidad into cursor c_CalculoDePrecios
		select c_CalculoDePrecios
		scan
			lcAtributo = upper( alltrim( atributo ) )
			if this.EsAtributoFiltroEnCalculoDePrecios( lcAtributo )
				if this.VerificarAtributoDePrecioDeArticulo( lcAtributo )
					this.VerificarDesdeHasta( lcAtributo )
					if this.TieneSubEntidad( lcAtributo )
						this.VerificarAtributo_SubEntidad( lcAtributo )
					endif
				Endif
			endif
		endscan
		use in select( "c_CalculoDePrecios" )
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function VerificarDesdeHasta( tcAtributo as String ) as Void
		local lcMensaje as String, lcTipo as String, lnCant as Integer, lcAtributo as String
		local array laPalabras[1]

		lnCant = alines( laPalabras, tcAtributo, 1, "_" )
		lcTipo = iif( laPalabras[lnCant] == "DESDE", "HASTA", "DESDE" )
		lcAtributo = strtran( upper( alltrim( tcAtributo ) ), laPalabras[lnCant], "" ) + lcTipo

		select diccionario
		locate for upper( alltrim( entidad ) ) == "CALCULODEPRECIOS" and upper( alltrim( atributo ) ) == lcAtributo
		if !found()
			lcMensaje = "Debe existir el atributo '" + lcAtributo + "' en la entidad 'CALCULODEPRECIOS'"
			this.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endif
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function VerificarAtributoDePrecioDeArticulo( tcAtributo as String ) as boolean
		local lcMensaje as String, lcAtributo as String, llRetorno as Boolean
		llRetorno = .T.
		lcAtributo = getwordnum( tcAtributo, 2, "_" )
		select diccionario
		locate for upper( alltrim( entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( atributo ) ) == lcAtributo
		if !found()
			select AtributosGenericos
			locate for upper( alltrim( atributo ) ) == lcAtributo and Tipo = "E"
			if !found()
				llRetorno = .F.
				lcMensaje = "El atributo '" + lcAtributo + "' debe ser un atributo de la entidad 'PRECIODEARTICULO'"
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endIf
		endif
		return llRetorno
	endfunc
	*-----------------------------------------------------------------------------------------	
	protected function VerificarAtributo_SubEntidad( tcAtributo as String ) as Boolean
		local lcMensaje as String, lcAtributo as String, lcEntidad as String, llRetorno as Boolean
		lcEntidad = getwordnum( tcAtributo, 2, "_" )
		lcAtributo = getwordnum( tcAtributo, 3, "_" )
		llRetorno = .t.

		select diccionario
		locate for upper( alltrim( entidad ) ) == lcEntidad and upper( alltrim( atributo ) ) == lcAtributo
		if !found()
			select AtributosGenericos
			locate for upper( alltrim( atributo ) ) == lcAtributo and Tipo = "E"
			if !found()
				llRetorno = .f.
				lcMensaje = "El atributo '" + lcAtributo + "' no es un atributo de la entidad '" + lcEntidad + "'"
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			EndIf	
		endif

		return llRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function EsAtributoFiltroEnCalculodePrecios( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lnCantidad as Integer, lcPalabra as String
		local array laPalabras[1]
		llRetorno = .F.		
		lnCantidad = alines( laPalabras, tcAtributo, 1, "_" )
		do case
			case lnCantidad = 3
				llRetorno = laPalabras[1] == "F" and !empty( laPalabras[2] ) and inlist( laPalabras[3], "DESDE", "HASTA" )
			case lnCantidad = 4
				llRetorno = laPalabras[1] == "F" and !empty( laPalabras[2] ) and !empty( laPalabras[3] ) and inlist( laPalabras[4], "DESDE", "HASTA" )
		endcase
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function TieneSubEntidad( tcAtributo as String ) as Boolean
		return getwordcount( tcAtributo, "_" ) = 4
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarEntidadesConAuditoriaCampoFormatoDescripcionNoVacio() as Void
		local lcMensaje as String, c_Cursor as String

		select entidad, formatodescripcion ;
			from entidad ;
			where occurs( "AUDITORIA", upper( alltrim( funcionalidades ) ) ) > 0 and empty( formatodescripcion ) ;
			into cursor c_Cursor

		select c_Cursor
		scan
			lcMensaje = "La Entidad '" + upper( alltrim( entidad ) ) + "' tiene Auditoría, debe completar el campo 'FormatoDescripcion' en la tabla 'Entidad'"
			this.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		use in select( "c_Cursor" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarHotKeysEnElMenuPrincipal() as void
		This.HotKeysEnElMenu( "MenuPrincipal" )
		This.ValidarQueTodosLosItemsDeMenuTenganHotKey( "MenuPrincipal" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarHotKeysEnElMenuPrincipalItems() as void
		This.HotKeysEnElMenu( "MenuPrincipalItems" )	
		This.ValidarQueTodosLosItemsDeMenuTenganHotKey( "MenuPrincipalItems" )
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function HotKeysEnElMenu( tcTabla as String ) as Void
		local lcLetrasUsadas as String, lcLetra as String, lcWhere as String
			  
		lcWhere = ""
		lcWhere = this.ObtenerWhereParaExcepcionesDeHotKeys()
		
		select Distinct IdPadre from &tcTabla &lcWhere into cursor c_Padres
		
		select c_Padres
		scan All
			lcLetrasUsadas = ""
			select Etiqueta from &tcTabla where "\<" $ Etiqueta and idPadre = c_Padres.IdPadre into cursor c_Ver
			select c_Ver
			scan All
				lcLetra = upper( substr( getwordnum( "2" + c_Ver.Etiqueta, 2, "\<" ) , 1, 1 ) )
				if lcLetra $ lcLetrasUsadas
					this.oInformacionIndividual.AgregarInformacion( "Letra ya usada como HotKey en " + tcTabla + " ( " + lcLetra + " ) para idPadre = " + transform( c_Padres.IdPadre ) )
				else
					lcLetrasUsadas = lcLetrasUsadas + lcLetra				
				EndIf
				select c_Ver
			EndScan
			use in select( "c_ver" )
			select c_Padres
		EndScan	
		use in select( "c_Padres" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDeProyectosYNodosQuePermitenHotKeysDuplicados( toProyectosYNodosMenuExcluidos as zoocoleccion OF zoocoleccion.prg) as void
		toProyectosYNodosMenuExcluidos.Agregar( "1006, 1009", "NIKE" )
		toProyectosYNodosMenuExcluidos.Agregar( "1006, 1009", "COLORYTALLE" )
		toProyectosYNodosMenuExcluidos.Agregar( "22", "TELAS" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProyectoActualPermiteHotKeysVacios() as Boolean
		local llRetorno as Boolean
		llRetorno = inlist( this.cProyectoActivo, "DIBUJANTE", "FELINO", "GENERADORES", "NUCLEO", "ZL")
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ValidarQueTodosLosItemsDeMenuTenganHotKey( tcTabla as String ) as Void
		local lcItemSinHotKey as String
		if !this.ProyectoActualPermiteHotKeysVacios()
			select Distinct IdPadre from &tcTabla into cursor c_Padres
			
			select c_Padres
			scan All
				select Etiqueta from &tcTabla where !( "\<" $ Etiqueta ) and idPadre = c_Padres.IdPadre into cursor c_Ver
				select c_Ver
				scan All
					lcItemSinHotKey = "El ítem de menú '" + alltrim( Etiqueta ) +;
									 "' perteneciente al nodo idPadre = " +  transform( c_Padres.IdPadre ) +;
									 " de la tabla " + tcTabla + ", no tiene HotKey asignado."
					this.oInformacionIndividual.AgregarInformacion( lcItemSinHotKey )
				EndScan
				use in select( "c_ver" )
				select c_Padres
			EndScan	
			use in select( "c_Padres" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function NodosConExcepcionesEnValidacionDeHotKeys( toProyectosYNodosMenuExcluidos as zoocoleccion OF zoocoleccion.prg ) as string
		local lcRetorno as String
		
		lcRetorno = ""
		
		if this.ProyectoActivoTieneExcepcionDeValidacionDeHotKeys( toProyectosYNodosMenuExcluidos )
			lcRetorno = toProyectosYNodosMenuExcluidos.item[ this.cProyectoActivo ]
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerWhereParaExcepcionesDeHotKeys() as string
		local lcRetorno as String, lcNodosConExcepciones as String, loProyectosYNodosMenuExcluidos as zoocoleccion OF zoocoleccion.prg
		lcRetorno = ""
		loProyectosYNodosMenuExcluidos = this.CrearObjeto( "ZooColeccion" )
		
		this.ObtenerColeccionDeProyectosYNodosQuePermitenHotKeysDuplicados( loProyectosYNodosMenuExcluidos )
		
		lcNodosConExcepciones = this.NodosConExcepcionesEnValidacionDeHotKeys( loProyectosYNodosMenuExcluidos )
	
		lcRetorno = iif( empty( lcNodosConExcepciones ), "", " Where !inlist( IdPadre, " + alltrim( lcNodosConExcepciones ) + " ) " )

		loProyectosYNodosMenuExcluidos.Release()		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProyectoActivoTieneExcepcionDeValidacionDeHotKeys( toProyectosYNodosMenuExcluidos as zoocoleccion OF zoocoleccion.prg ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.

		llRetorno = toProyectosYNodosMenuExcluidos.Buscar( this.cProyectoActivo )

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarNodosParametrosCliente() as Void
		local lcCursor as String

		lcCursor = sys( 2015 )
		
		select NombreNodo, IdNodoPadre ;
			from NodosParametrosCliente ;
			where IdNodoPadre not in ( select IdNodo from NodosParametrosCliente ) and IdNodoPadre <> 0 ;
			into cursor &lcCursor

		select( lcCursor )
		scan
			this.oInformacionIndividual.AgregarInformacion( "El Nodo '" + alltrim( &lcCursor..NombreNodo ) + "' tiene el IdNodoPadre " + alltrim( str( &lcCursor..IdNodoPadre ) ) + " que NO existe como IdNodo." )
		endscan

		use in select( lcCursor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarComienzaGrupoEnMenuPrincipal() as VOID
		Local lcCursor as String 

		lcCursor = sys( 2015 )

		select id, etiqueta ;
			from menuprincipal ;
			where ComienzaGrupo and idpadre = 0 ;
			into Cursor ( lcCursor )

		select ( lcCursor )
		If _Tally > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "La opción de menu con Id: " + transform( &lcCursor..id ) + ;
					" y Etiqueta: " + alltrim( &lcCursor..Etiqueta ) + " tiene especificado que ComienzaGrupo pero no tiene IdPadre." )
			Endscan
		Endif
		Use In ( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTagsComprobantes() as Void
		this.ValidarEntidadesMalCargadas( "VENTAS" )
		this.ValidarEntidadesMalCargadas( "COMPRAS" )
		this.ValidarEntidadesMalCargadas( "FISCAL" )
		this.ValidarEntidadesMalCargadas( "CONVALORES" )
		this.ValidarExistenciaDeTagParaComprobantes()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarExistenciaDeTagParaComprobantes() as Void
		local lcCursor as String, lcFuncionalidades as String
		
		lcCursor = sys( 2015 )
		select Entidad.entidad, Entidad.Descripcion, Entidad.funcionalidades ;
			from Entidad ;
			inner join Comprobantes on upper( alltrim( Comprobantes.Descripcion ) ) == upper( alltrim( Entidad.Entidad ) ) ;
			into cursor &lcCursor
		
		scan
			lcFuncionalidades = upper( &lcCursor..Funcionalidades )
			if !this.oFunc.TieneFuncionalidad( "VENTAS", lcFuncionalidades ) and !this.oFunc.TieneFuncionalidad( "COMPRAS", lcFuncionalidades ) and !this.oFunc.TieneFuncionalidad( "COMPR_CAJA", lcFuncionalidades )
				This.oInformacionIndividual.AgregarInformacion( ;
					"El comprobante " + alltrim( &lcCursor..Descripcion ) + ;
					" no posee el tag que indica si es de Ventas o Compras." )
				if this.oFunc.TieneFuncionalidad( "FISCAL", lcFuncionalidades )
					This.oInformacionIndividual.AgregarInformacion( ;
						"El comprobante " + alltrim( &lcCursor..Descripcion ) + ;
						" posee el tag que indica que es un comprobante fiscal " + ;
						"pero no tiene indicado si es de Ventas o Compras." )
				else
					if this.oFunc.TieneFuncionalidad( "CONVALORES", lcFuncionalidades )
						This.oInformacionIndividual.AgregarInformacion( ;
							"El comprobante " + alltrim( &lcCursor..Descripcion ) + ;
							" posee el tag que indica que es un comprobante tiene valores," + ;
							" pero no tiene indicado que es Fiscal." )
					endif
				endif
			endif
		endscan
			
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidadesMalCargadas( tcTag as String ) as Void
		local lcCursor as String, lcTag as String
		
		lcTag = upper( tcTag )
		lcCursor = sys( 2015 )
		select Entidad, Descripcion ;
			from entidad ;
			where this.oFunc.TieneFuncionalidad( lcTag, Funcionalidades ) and ;
				upper( entidad ) not in ( select upper( descripcion ) from comprobantes ) ;
			into cursor &lcCursor
		scan
			This.oInformacionIndividual.AgregarInformacion( ;
				"La entidad " + alltrim( &lcCursor..Descripcion ) + ;
				" posee el tag " + proper( lcTag ) + " pero no está en la tabla Comprobantes." )
		endscan
		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarDigitosEnTipoDatosNumericosEnDiccionario() as void
		local lcCursor as String, lcAtributo as String, lcEntidad as String
		
		if inlist( This.cProyectoActivo, "COLORYTALLE" )
			lcCursor = sys( 2015 )

			select * from diccionario where tipodato = "N" and longitud > 15 and alltrim(upper(entidad)) != alltrim(upper("itemimpuestos")) order by entidad into cursor ( lcCursor )

			scan
				lcAtributo = alltrim( &lcCursor..Atributo )
				lcEntidad  = alltrim( proper( &lcCursor..Entidad ) )
				if inlist( upper( lcAtributo ), "RECARGOMONTO1", "MONTODESCUENTO2" ) or ;
					( inlist( upper(lcAtributo), "MONTO", "PORCENTAJE", "MINIMONOIMPONIBLE", "MONTOBASE" ) and upper( lcEntidad ) = "ITEMIMPUESTOVENTAS" ) OR;
					( "PRORRATEO" $ upper( lcAtributo ) and inlist( upper( lcEntidad ), "ITEMARTICULOSVENTAS", "ITEMARTICULOSSENIADOS", "ITEMARTICULOSSENIADOSEX", "ITEMKITS" ) ) OR;
					( inlist( upper( lcEntidad ), "ITEMFILTROPERSONALIZADO", "PROPIEDADESLISTADOS" ) and inlist( upper( lcAtributo ), "VALORNUMERICOINICIAL_HASTA","VALORNUMERICOINICIAL_DESDE" ) ) OR;
					( upper( lcEntidad ) = "ITEMASIENTO" ) OR;
					( inlist( upper(lcAtributo), "CANTIDAD", "CANTIDADORIGINAL" ) and upper( lcEntidad ) == "STOCKINVENTARIO" ) OR;
					( upper( lcAtributo ) = "DIFERENCIA" and upper( lcEntidad ) == "ASIENTO" ) or ;
					( upper( lcEntidad ) = "ITEMVALORES" and inlist( upper( lcAtributo ), "RECARGOMONTOSINIMPUESTOS", "DESCUENTOMONTOSINIMPUESTOS" ))
					if longitud > 17
						This.oInformacionIndividual.AgregarInformacion( "La LONGITUD del atributo " + lcAtributo + " de la entidad " + lcEntidad +" (Diccionario) no puede ser mayor a 17." )
					endif
				else 
					This.oInformacionIndividual.AgregarInformacion( "La LONGITUD del atributo " + lcAtributo + " de la entidad " + lcEntidad +" (Diccionario) no puede ser mayor a 15." )
				endif
			endscan

			use in select( lcCursor )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarGuidComoUltimoCampoEnElBuscador() as Void
	
		select distinct entidad, atributo, AdmiteBusqueda ;
			from diccionario ;
			where TipoDato = "G" and AdmiteBusqueda > 0;
		order by entidad ;
		into cursor c_EntidadesConGuid

		select( "c_EntidadesConGuid" )
		scan
			select max( d.AdmiteBusqueda ) as AdmiteBusqueda from diccionario d where d.Entidad = c_EntidadesConGuid.Entidad into cursor c_MaxAdmiteBusqueda
			if c_MaxAdmiteBusqueda.AdmiteBusqueda != c_EntidadesConGuid.AdmiteBusqueda
				This.oInformacionIndividual.AgregarInformacion( "Los Atributos de tipo GUID deben tener AdmiteBusqueda seteado para quedar en la ultima posición del buscador ( " + alltrim( c_EntidadesConGuid.Entidad ) + " )." )
			endif
			use in select( "c_MaxAdmiteBusqueda" )
		endscan
		
		use in select( "c_EntidadesConGuid" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarOrtografiaEtiquetas() as void
		local loValidarAdnOrtografiaEtiquetas as Object, loError as Exception, loEx as Exception

		Try
			loValidarAdnOrtografiaEtiquetas = this.crearobjeto( "ValidarAdnOrtografiaEtiquetas", "", this, this.cRutaInicial )
			loValidarAdnOrtografiaEtiquetas.Validar()
		Catch To loError
		EndTry
	endfunc


	*-----------------------------------------------------------------------------------------
	function ValidarSeguridadEnMenuPrincipal() as Void
		local lcCursor as String, lcMensaje as String 
		
		lcCursor = sys( 2015 )
		select id, idpadre from menuprincipal where idpadre in ( select id from menuprincipal where ltieneseguridad ) and !ltieneseguridad into cursor &lcCursor
		
		select &lcCursor
		scan
			lcMensaje = "La configuración de seguridad del menú id " + transform( &lcCursor..Id ) + " no se corresponde con la de su padre( Id Padre: " + transform( &lcCursor..IdPadre ) + " )."
			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		
		use in select( lcCursor )
		
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadCodigoSugerido() as Void
		local lcCursor as String, lcTipo as String
		lcCursor = sys( 2015 )
		
		select * from entidad where funcionalidades like "%<CODIGOSUGERIDO>%" into cursor &lcCursor
		
		select( lcCursor )
		scan all
			lcTipo = &lcCursor..Tipo
			if ( lcTipo = "I" )
				This.oInformacionIndividual.AgregarInformacion( "Item: " + upper( alltrim( &lcCursor..entidad ) ) + ". La funcionalidad <CODIGOSUGERIDO> solo esta disponible para Entidades." )
			endif
			select diccionario
			locate for upper( alltrim( entidad ) ) = upper( alltrim( &lcCursor..entidad ) ) and claveprimaria and tipodato # "C"
			if found()
				This.oInformacionIndividual.AgregarInformacion( "Entidad: " + upper( alltrim( &lcCursor..entidad ) ) + ". La funcionalidad <CODIGOSUGERIDO> solo esta disponible para entidades cuya clave primaria sea de tipo de dato [C]." )
			endif
			locate for upper( alltrim( entidad ) ) = upper( alltrim( &lcCursor..entidad ) ) and claveprimaria and !empty( valorsugerido )
			if found()
				This.oInformacionIndividual.AgregarInformacion( "Entidad: " + upper( alltrim( &lcCursor..entidad ) ) + ". La funcionalidad <CODIGOSUGERIDO> no esta disponible para entidades a las que se les especificó un valor en el campo [ValorSugerido] de la clave primaria." )
			endif
		endscan

		use in select( lcCursor )
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTagOrdenEnBuscador( tcCursor as String, tcTag as String ) as Void
		local lcMensaje as String, lcTag as String, lcTabla as String, lcCampo as String, llAdmiteBusqueda as Boolean

		if "<ORDENBUSCADOR" $ upper( tcTag )
			lcTag = chrtran( tcTag, "<>", "" )

			lcTabla = &tcCursor..Tabla
			lcCampo = &tcCursor..Campo
			if empty( lcTabla ) or empty( lcCampo )
				lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". No es posible especificar el tag <OrdenBuscador> en un atributo virtual."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
			
			llAdmiteBusqueda = &tcCursor..AdmiteBusqueda
			if empty( llAdmiteBusqueda )
				lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". No es posible especificar el tag <OrdenBuscador> en un atributo que no admite busqueda."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif

			if empty( getwordnum( lcTag, 2, ":" ) )
				lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". Debe especificar un parámetro para el tag <OrdenBuscador>."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			else
				if !isdigit( getwordnum( lcTag, 2, ":" ) )
					lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". El parámetro del tag <OrdenBuscador> debe ser un número entero."
					this.oInformacionIndividual.AgregarInformacion( lcMensaje )
				endif
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTagDetalleEnBuscador( tcCursor as String, tcTag as String ) as Void
		local lcMensaje as String, lcTag as String, lcTabla as String, lcCampo as String, llAlta as Boolean

		if "<DETALLEENBUSCADOR>" $ upper( tcTag )
			lcTag = chrtran( tcTag, "<>", "" )

			lcTabla = &tcCursor..Tabla
			lcCampo = &tcCursor..Campo

			llAlta = &tcCursor..Alta
			if !( llAlta )
				lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". No es posible especificar el tag <DETALLEENBUSCADOR> a un Item con Alta en false."
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarTagAdmiteBusquedaSubEntidad( tcCursor as String, tcTag as String ) as Void
		local lcMensaje as String, lcTag as String, lcTabla as String, lcCampo as String, lcClaveForanea as String

		if "<ADMITEBUSQUEDASUBENTIDAD>" $ upper( tcTag )
			lcTag = chrtran( tcTag, "<>", "" )

			lcTabla = &tcCursor..Tabla
			lcCampo = &tcCursor..Campo

			lcClaveForanea = &tcCursor..ClaveForanea
			lcEntidad = &tcCursor..Entidad
			
			if empty( lcClaveForanea ) or this.EsAtributoDetalle( lcEntidad ) or empty( lcTabla ) or empty( lcCampo ) or this.TieneMasDeUnAtributoAMismaClaveForanea( alltrim(upper(lcEntidad)), alltrim(upper(lcClaveForanea)) )
				lcMensaje = "Entidad: " + alltrim( &tcCursor..Entidad ) + " - Atributo: " + alltrim( &tcCursor..Atributo ) + ". No es posible especificar el tag <ADMITEBUSQUEDASUBENTIDAD> "; 
					+ "si el campo 'Tabla', 'Campo' o 'ClaveForanea' están vacíos, si el atributo pertenece a un detalle o existe mas de un atributo con la misma 'ClaveForanea' y el campo 'Tags' contiene <ADMITEBUSQUEDASUBENTIDAD>." 
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif

		endif
	endfunc


	*-----------------------------------------------------------------------------------------
	function EsAtributoDetalle( tcEntidad as String ) as Boolean
		local lcCursor as String, llRetorno as Boolean, lcEntidad as Boolean, lcAliasOld as String
		lcCursor = "c" + sys( 2015 )
		lcAliasOld = alias()
		
		select Entidad;
			from Entidad ;
			where alltrim(upper(entidad)) == alltrim(upper(tcEntidad)) and upper( alltrim( Tipo ) ) == "I" ;
		into cursor &lcCursor
				
		select( lcCursor )
			
		if reccount(lcCursor) > 0
			llRetorno = .T.
		endif

		use in select ( lcCursor )
		select &lcAliasOld
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneMasDeUnAtributoAMismaClaveForanea( tcEntidad as String, tcClaveForanea as String ) as Boolean
		local lcCursor as String, llRetorno as Boolean, lcEntidad as Boolean, lcAliasOld as String
		lcCursor = "c" + sys( 2015 )
		lcAliasOld = alias()

		select count( CLAVEFORANEA) AS CONTADOR, claveforanea;
			from diccionario ;
			where !empty(claveforanea) and ;
			alltrim(upper(entidad)) == tcEntidad and ;
			alltrim(upper(claveforanea)) == tcClaveForanea and ;
			"<ADMITEBUSQUEDASUBENTIDAD>" $ TAGS ;
			group by CLAVEFORANEA ;
			HAVING count(claveforanea) > 1 ;
		into cursor &lcCursor

		select( lcCursor )
			
		if reccount(lcCursor) > 0
			llRetorno = .T.
		endif

		use in select ( lcCursor )
		select &lcAliasOld
		
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarComprobantesDeCompra() as Void
		if inlist( This.cProyectoActivo, "COLORYTALLE", "FELINO" )
			local loCompras as Object, loItem as Object

			loCompras =  this.CompletarColeccionCompras()
			
			for each loItem in loCompras
				this.ValidarCompras( loItem.Entidad1, loItem.Entidad2 )
			endfor
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCompras( tcEntidad1 as String, tcEntidad2 as String) as Void
		local lnRegistros1 as Integer, lnRegistros1 as Integer	

			select * from diccionario where upper( diccionario.entidad ) = upper( tcEntidad1  ) into cursor cCursor1
			lnRegistros1 = _tally
			select * from diccionario where upper( diccionario.entidad ) = upper( tcEntidad2 ) into cursor cCursor2
			lnRegistros2 = _tally
	
			if  lnRegistros1 != lnRegistros2
				this.CompararCamposFaltantes( "cCursor1", "cCursor2", tcEntidad1, tcEntidad2 )
			else
				if !this.CompararRegistros( "cCursor1", "cCursor2", lnRegistros1 )
					this.CompararCampos( "cCursor1", "cCursor2", " entidad " + tcEntidad1  + " contra " + tcEntidad2 )
				endif				
			endif

			use in select ( "cCursor1" )
			use in select ( "cCursor2" )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompararRegistros( tcCursor1 as String,  tcCursor2 as String, tnTotalRegistros as integer ) as Boolean
		local lcCursor as String, lnTotalAgrupado as Integer, llRetorno as Boolean
		lcCursor = sys(2015)
								
		select upper( atributo ), upper( campo ), upper( tipoDato ), longitud, decimales;
			from;
				&tcCursor1 union select upper( atributo ), upper( campo ), upper( tipoDato ), longitud, decimales;
			from;
				&tcCursor2 into cursor lcCursor
		
		llRetorno = ( tnTotalRegistros == _tally )
		
		use in select ( "&lcCursor" )

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompararCampos( tcCursor1 as String,  tcCursor2 as String, tcMensaje as String )
		local lcCursor as String, lcAtributo as String

		select &tcCursor1
		scan
			lcAtributo = alltrim( upper( &tcCursor1..Atributo ))
			select * from &tcCursor2 where upper( &tcCursor2..Atributo ) = lcAtributo into cursor lcCursor
			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion(	"El campo 'Atributo' es distinto. " + tcMensaje )
			endif
			use in select( "&lcCursor" )

			select * from &tcCursor2 where upper( &tcCursor2..Atributo ) = lcAtributo and;
				upper( &tcCursor2..Campo ) = upper( &tcCursor1..Campo ) into cursor lcCursor

			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion(	"El campo 'Campo' es distinto en el atributo " + lcAtributo + " " + tcMensaje )
			endif
			use in select( "&lcCursor" )

			select * from &tcCursor2 where upper( &tcCursor2..Atributo ) = lcAtributo and;
					upper( &tcCursor2..TipoDato ) =  upper( &tcCursor1..TipoDato ) into cursor lcCursor
			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion(	"El campo 'TipoDato' es distinto en el atributo " + lcAtributo + " " + tcMensaje )
			endif
			use in select( "&lcCursor" )

			select * from &tcCursor2 where upper( &tcCursor2..Atributo ) = lcAtributo and;
				&tcCursor2..Longitud = &tcCursor1..Longitud into cursor lcCursor
			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion(	"El campo 'Longitud' es distinto en el atributo " + lcAtributo + " " + tcMensaje )
			endif
			use in select( "&lcCursor" )

			select * from &tcCursor2 where upper( &tcCursor2..Atributo ) = lcAtributo and;
				&tcCursor2..decimales = &tcCursor1..decimales into cursor lcCursor
			if _tally = 0
				This.oInformacionIndividual.AgregarInformacion(	"El campo 'Decimales' es distinto en el atributo " + lcAtributo + " " + tcMensaje )
			endif
			use in select( "&lcCursor" )
			
			select &tcCursor1
		endscan
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompararCamposFaltantes( tcCursor1 as String, tcCursor2 as String, tcEntidad1 as String, tcEntidad2 as string ) as Void
		local lcCursor as string, lcEntidadFalta as String, lcEntidadCompara as string
		
		if reccount( tcCursor1 ) > reccount( tcCursor2 )
			lcEntidadFalta = tcEntidad2
			lcEntidadCompara = tcEntidad1
			select * from &tcCursor1 ;
				where atributo not in (select atributo from &tcCursor2 ) into cursor lcCursor
		else
			lcEntidadFalta = tcEntidad1
			lcEntidadCompara = tcEntidad2
			select * from &tcCursor2 ;
				where atributo not in (select atributo from &tcCursor1 ) into cursor lcCursor
		endif
		
		select lcCursor
		scan
			This.oInformacionIndividual.AgregarInformacion(	"Falta el atributo " + alltrim( atributo ) + " en la entidad " + lcEntidadFalta + " comparado con la entidad " + lcEntidadCompara )			
		endscan

		use in select( "lcCursor" )
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CompletarColeccionCompras() as object
		local loCompras as Collection, loItem as Object
		
		* Cabeceras		
		loCompras = newobject( "Collection" )
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "FACTURADECOMPRA"
		loItem.Entidad2 = "NOTADECREDITOCOMPRA"	
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "FACTURADECOMPRA"
		loItem.Entidad2 = "NOTADEDEBITOCOMPRA"		
		loCompras.Add( loItem )
		
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "NOTADECREDITOCOMPRA"
		loItem.Entidad2 = "NOTADEDEBITOCOMPRA"
		loCompras.Add( loItem )
		****
		
		* Items		
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMARTICULOSCOMPRA"
		loItem.Entidad2 = "ITEMARTICULOSNCCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMARTICULOSCOMPRA"
		loItem.Entidad2 = "ITEMARTICULOSNDCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMARTICULOSNCCOMPRA"
		loItem.Entidad2 = "ITEMARTICULOSNDCOMPRA"
		loCompras.Add( loItem )
		***
		
		* Items Valores
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMVALORESCOMPRA"
		loItem.Entidad2 = "ITEMVALORESNDCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMVALORESCOMPRA"
		loItem.Entidad2 = "ITEMVALORESNCCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMVALORESNDCOMPRA"
		loItem.Entidad2 = "ITEMVALORESNCCOMPRA"
		loCompras.Add( loItem )
		***		

		* Items impuestos
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTOSC"
		loItem.Entidad2 = "ITEMIMPUESTOSNDC"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTOSC"
		loItem.Entidad2 = "ITEMIMPUESTOSNCC"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTOSNDC"
		loItem.Entidad2 = "ITEMIMPUESTOSNCC"
		loCompras.Add( loItem )
		***

		* Items impuestos 2
		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTOCOMPRA"
		loItem.Entidad2 = "ITEMIMPUESTONCCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTOCOMPRA"
		loItem.Entidad2 = "ITEMIMPUESTONDCOMPRA"
		loCompras.Add( loItem )

		loItem = newobject( "ItemCompra", "ValidarADN.prg" )
		loItem.Entidad1 = "ITEMIMPUESTONCCOMPRA"
		loItem.Entidad2 = "ITEMIMPUESTONDCOMPRA"
		loCompras.Add( loItem )
		***
		
		return loCompras
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarIndividualidadDeTagDesactivableYAnulable() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select Descripcion from Entidad ent ;
			where this.oFunc.TieneFuncionalidad( "ANULABLE" , ent.Funcionalidades ) and ;
				  this.oFunc.TieneFuncionalidad( "DESACTIVABLE" , ent.Funcionalidades ) ;
			into cursor &lcCursor
		scan
			this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Descripcion ) + ;
				" tiene las funcionalidades ANULABLE y DESACTIVABLE pero ambas no se pueden asignar a la misma entidad." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarQueEntidadDesactivableSeaAuditable() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select Descripcion from Entidad ent ;
			where !this.oFunc.TieneFuncionalidad( "AUDITORIA" , ent.Funcionalidades ) and ;
				  this.oFunc.TieneFuncionalidad( "DESACTIVABLE" , ent.Funcionalidades ) ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Descripcion ) + ;
				" debe tener AUDITORIA para poseer la funcionalidad DESACTIVABLE." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarQueEntidadConAuditoriaTengaModulosListado() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select Descripcion from Entidad ent ;
			where !this.oFunc.TieneFuncionalidad( "MODULOSLISTADO" , ent.Funcionalidades ) and ;
				  this.oFunc.TieneFuncionalidad( "AUDITORIA" , ent.Funcionalidades ) ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Descripcion ) + ;
				" debe tener indicados los módulos mediante la funcionalidad MODULOSLISTADO: para poseer la funcionalidad AUDITORIA." )
		endscan

		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarRepeticionDeIdsEnParametros() as Void
		local lcCursor as String, lcMensaje as String, lnCantidadIds as Integer
	
		if inlist( This.cProyectoActivo, "ZL" )
			return
		Else
			lcCursor = sys( 2015 )
			
			lnCantidadIds = 0
			lcMensaje = ""
			
			select ID, count(*) as conteo from parametros group by ID having count(*) > 1 into cursor (lcCursor)
			
			if reccount() > 0
				lnCantidadIds = reccount()
				lcMensaje = "El proyecto " + alltrim( this.cProyectoActivo ) + " tiene IDs de parametros repetidos: "
				scan all
					lcMensaje = lcMensaje +  alltrim(str(ID)) 
					lcMensaje = lcMensaje + " (" + alltrim(str(conteo)) + " veces); "
				endscan 
				
				this.oInformacionIndividual.AgregarInformacion( lcMensaje )
			endif
			
			use in select( lcCursor  )
		endif
	endfunc 


	
	*-----------------------------------------------------------------------------------------
	protected function ValidarRepeticionDeOrdenesVisualesEnDiccionario() as Void
		local lcCursor as String
		if inlist( This.cProyectoActivo, "NUCLEO", "GENERADORES", "FELINO", "DIBUJANTE", "ZL" )
			return
		Else
			lcCursor = sys( 2015 )

			select count( dic.Orden ) as Cantidad, Ent.Entidad, Dic.Grupo, Dic.Subgrupo, Dic.Orden ;
				from Diccionario dic inner join Entidad ent ;
					on upper(alltrim( dic.Entidad ) ) == upper( alltrim( Ent.Entidad ) ) Where dic.Alta and ent.Formulario ;
				group by Ent.Entidad, Dic.Grupo, Dic.Subgrupo, Dic.Orden ;
				having Cantidad > 1 ;
				into cursor &lcCursor

			scan
				this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Entidad ) + ;
					" tiene ordenes repetidos para el grupo " + transform( &lcCursor..Grupo ) + " subgrupo " + transform( &lcCursor..SubGrupo ) + " Orden " + transform( &lcCursor..Orden ) )
			endscan

			select count( dic.Orden ) as Cantidad, Ent.Entidad, Dic.Grupo, Dic.Subgrupo, Dic.Orden ;
				from Diccionario dic inner join Entidad ent ;
					on upper(alltrim( dic.Entidad ) ) == upper( alltrim( Ent.Entidad ) ) ;
				Where dic.Alta and ent.Tipo = "I" ;
				group by Ent.Entidad, Dic.Grupo, Dic.Subgrupo, Dic.Orden ;
				having Cantidad > 1 ;
				into cursor &lcCursor

			scan
				this.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( &lcCursor..Entidad ) + ;
					" tiene ordenes repetidos para el grupo " + transform( &lcCursor..Grupo ) + " subgrupo " + transform( &lcCursor..SubGrupo ) + " Orden " + transform( &lcCursor..Orden ) )
			endscan
			use in select( lcCursor )
			
		Endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoFijosYConfigurables() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select Entidad, Atributo from Diccionario ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", Tags ) and saltocampo = .t. ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + " tiene establecido salto de campo fijo " + ;
				"y el tag para que el salto de campo sea configurable. Por favor, cambie uno de ambos." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYGenHabilitar() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select Entidad, Atributo from Diccionario ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", Tags ) and genhabilitar = .t. ;
				and "DETALLE" != left( upper( alltrim( dominio ) ), 7 ) ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( "El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + " tiene establecida la habilitación dinámica " + ;
				"y el tag que permite configurar el salto de campo. Por favor, cambie uno de ambos." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYCabeceraDetalle() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo ;
			from diccionario d ;
			left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
				and upper( alltrim( e.tipo ) ) == 'E' ;
				and d.dominio in ( ;
					select "DETALLE" + upper( d.entidad ) ;
						from diccionario d ;
						left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
						where !this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
							and upper( alltrim( e.tipo ) ) == 'I' ) ;
				and d.dominio not in ( ;
					select "DETALLE" + upper( d.entidad ) ;
						from diccionario d ;
						left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
						where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
							and upper( alltrim( e.tipo ) ) == 'I' ) ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" es un detalle y tiene establecido el tag que permite configurar el salto de" + ;
				" campo, pero falta establecer el mismo tag para por lo menos un atributo de ese detalle." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYDetalleCabecera() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo ;
			from diccionario d ;
			left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
			where !this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) and alta ;
				and upper( alltrim( e.tipo ) ) == 'E' ;
				and d.dominio in ( ;
					select "DETALLE" + d.entidad ;
						from diccionario d ;
						left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
						where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
							and upper( alltrim( e.tipo ) ) == 'I' ) ;
			into cursor &lcCursor

		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" es un detalle y tiene que tener el tag que permite configurar el salto de" + ;
				" campo ya que por lo menos un atributo de dicho detalle tiene el tag mencionado." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYDetalleAtributoObligatorio() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo ;
			from diccionario d ;
			left join entidad e on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
				and upper( alltrim( e.tipo ) ) == 'I' ;
				and d.obligatorio == .t. ;
			into cursor &lcCursor
		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" tiene el tag que permite configurar el salto de" + ;
				" campo y es obligatorio. Por favor, cambie uno de ambos." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYEtiquetas() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo ;
			from diccionario d ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
				and empty( d.etiqueta ) ;
			into cursor &lcCursor
		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" tiene el tag que permite configurar el salto de" + ;
				" campo pero no tiene etiqueta." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYAlta() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo ;
			from diccionario d ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
				and alta == .f.;
			into cursor &lcCursor
		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" tiene el tag que permite configurar el salto de" + ;
				" campo pero no es visible." )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaltosDeCampoConfigurablesYDominiosInvalidos() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		select d.entidad, d.atributo, d.dominio ;
			from diccionario d ;
			where this.oFunc.TieneFuncionalidad( "SALTODECAMPO", d.Tags ) ;
				and inlist( upper( alltrim( d.Dominio ) ), "NUMEROCOMPROBANTE" );
			into cursor &lcCursor
		scan
			this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" tiene el tag que permite configurar el salto de" + ;
				" campo pero no se permite para atributos con el dominio " + ;
				alltrim( &lcCursor..dominio ) + "." )
		endscan

		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarFechasEnCampoValorSugerido() as Void
		local lcCursor as String
		try
			lcCursor = this.ObtenerConsultaValorSugeridoParaValidarFechaHora( "date" )

			select &lcCursor
			scan
				this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" no esta obteniendo la fecha de manera correcta." )
			endscan
				
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarHorasEnCampoValorSugerido() as Void
		local lcCursor as String

		try
			lcCursor = this.ObtenerConsultaValorSugeridoParaValidarFechaHora( "time" )

			select &lcCursor
			scan
				this.oInformacionIndividual.AgregarInformacion( ;
				"El atributo " + alltrim( &lcCursor..atributo ) + ;
				" de la entidad " + alltrim( &lcCursor..Entidad ) + ;
				" no esta obteniendo la hora de manera correcta." )
			endscan
				
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerConsultaValorSugeridoParaValidarFechaHora( tcCondicion as String ) as Void
		local lcCursor as String
		lcCursor = "c_" + sys( 2015 )
		select entidad, atributo, valorsugerido from diccionario where lower( tcCondicion ) $ lower(valorsugerido) into cursor &lcCursor
		
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarQueUnItemDelMenuTengaBienCargadaLaReferenciaALaEntidadQueVaAVisualizar() as void
		Local lcCursor as String 

		lcCursor = sys( 2015 )
		select id from menuprincipalitems  where "formularios.mostrar(" $ lower( comando) and empty( entidad ) into Cursor ( lcCursor )

		select ( lcCursor )
		If reccount( lcCursor ) > 0
			Scan
				This.oInformacionIndividual.AgregarInformacion( "Se encontraron items del menú principal que no tienen cargada la entidad: " + ;
						 chr( 10 ) + chr( 13 ) + "Id de menú: " + transform( &lcCursor..id ) +"." )
			Endscan
		Endif
		Use In select( lcCursor )
	endfunc
	*-----------------------------------------------------------------------------------------
	function ValidarTagPromocionesPrincipal() as Void
		Local lcCursor as String, lcTexto as String
		lcTexto = ""
		lcCursor = sys( 2015 )
		select * from entidad where "<PROMO_PRINCIPAL>" $ upper(Funcionalidades) into cursor &lcCursor
		if reccount() > 1
			scan all
				lcTexto = lcTexto + iif( empty( lcTexto ), "", ", " ) + alltrim( &lcCursor..Entidad )
			Endscan
			This.oInformacionIndividual.AgregarInformacion( "No puede haber mas de una entidad con tag <PROMO_PRINCIPAL> ( " + lcTexto + " )" )
		Endif
		Use In select( lcCursor )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarTagPromociones() as Void
		Local lcCursor as String, lcTexto as String, lcCursor2 as String
		lcTexto = ""
		lcCursor = sys( 2015 )
		lcCursor2 = sys( 2015 )		
		select * from entidad where "<PROMO>" $ upper(Funcionalidades) into cursor &lcCursor
		select * from entidad where "<PROMO_PRINCIPAL>" $ upper(Funcionalidades) into cursor &lcCursor2		
		if reccount( lcCursor ) > 0
			if reccount( lcCursor2 ) = 0
				select &lcCursor
				scan all
					lcTexto = lcTexto + iif( empty( lcTexto ), "", ", " ) + alltrim( &lcCursor..Entidad )
				Endscan
				This.oInformacionIndividual.AgregarInformacion( "No puede haber tag <PROMO> sin una entidad declarada como <PROMO_PRINCIPAL> ( " + lcTexto + " )" )
			Endif
		Endif
		Use In select( lcCursor )
		Use In select( lcCursor2 )		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarConsistenciaAtributosPromociones() as Void
		Local lcCursor as String, lcTexto as String, lcCursor2 as String
		lcTexto = ""
		lcCursor = sys( 2015 )
		lcCursor2 = sys( 2015 )		
		select * from entidad where "<PROMO_PRINCIPAL>" $ upper(Funcionalidades) into cursor &lcCursor
		select Diccionario
		count to lnCantPP for alltrim( upper( Entidad ) ) == upper( alltrim( &lcCursor..Entidad ) ) and "<PP>" $ upper( tags )
		
		select Entidad
		scan all for "<PROMO>" $ upper( Funcionalidades )
			select Dic_A.Entidad ;
				from Diccionario Dic_A inner join Diccionario Dic_B ;
					on upper( Dic_A.Atributo ) == upper( Dic_B.Atributo ) ;
				where "<PP>" $ upper( Dic_B.Tags ) and upper( Dic_A.Entidad ) == upper( Entidad.Entidad ) and upper( Dic_B.Entidad ) == upper( &lcCursor..Entidad ) ;
				into cursor &lcCursor2
			if reccount( lcCursor2 ) != lnCantPP 
				lcTexto = lcTexto + iif( empty( lcTexto ), alltrim( &lcCursor..Entidad ) + ", ", ", " ) + alltrim( Entidad.Entidad )
			Endif
		EndScan
		if empty( lcTexto )
		Else
			This.oInformacionIndividual.AgregarInformacion( "Los atributos con funcionalidad <PP> de las entidades declaradas como promociones deben coincidir en todas las entidades participantes ( " + lcTexto + " )" )
		Endif
		Use In select( lcCursor )
		Use In select( lcCursor2 )		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTagSoportaPrePantalla() as Void
		Local lcCursorAtributosNoDetalle as String, lcCursorAtributosDetalle as String, llElDetalleSoportaPrePantalla as Boolean, ;
			lcEntidad as String, lcAtributo as String, llAlta as Boolean, lcClaveForanea as String, lcDominio as String
		lcCursorAtributosNoDetalle = sys( 2015 )
		lcCursorAtributosDetalle = sys( 2015 )
		llElDetalleSoportaPrePantalla = .f.

		select * from Diccionario ;
			where "<SOPORTAPREPANTALLA>" $ upper( tags ) and !( substr( Dominio, 1, 7 ) == "DETALLE" ) ;
			into cursor ( lcCursorAtributosNoDetalle )
		
		select * from Diccionario ;
			where "<SOPORTAPREPANTALLA>" $ upper( tags ) and ( substr( Dominio, 1, 7 ) == "DETALLE" ) ;
			into cursor ( lcCursorAtributosDetalle )

		select ( lcCursorAtributosNoDetalle )
		scan all
			lcEntidad = alltrim( Entidad )
			lcAtributo = alltrim( Atributo )
			llAlta = Alta
			lcClaveForanea = upper( alltrim( ClaveForanea ) )
			lcDominio = upper( alltrim( Dominio ) )
			select ( lcCursorAtributosDetalle )
			locate for upper( alltrim( Dominio ) ) == upper( alltrim( "DETALLE" + &lcCursorAtributosNoDetalle..Entidad ) )
			llElDetalleSoportaPrePantalla = found( lcCursorAtributosDetalle )
			if !( llAlta ) or !( lcClaveForanea == "ARTICULO" ) or !( lcDominio == "CONSOPORTEPREPANTALLA" ) or !llElDetalleSoportaPrePantalla
				this.oInformacionIndividual.AgregarInformacion( "Entidad: " + lcEntidad + " - Atributo: " + lcAtributo + ;
				" - Debe tener ALTA, la clave foránea debe ser ARTICULO, el dominio debe ser CONSOPORTEPREPANTALLA y pertenecer a un detalle que posea el tag CONSOPORTEPREPANTALLA" )
			endif
			select ( lcCursorAtributosNoDetalle )
		endscan
		use in select( lcCursorAtributosNoDetalle )
		use in select( lcCursorAtributosDetalle )
	endfunc
	*-----------------------------------------------------------------------------------------
	function ValidarLongitudClienteOrigenEnValeDeCambio() as VOID
		local lnLongitudCliente as Integer
	
		select Entidad, Atributo, Tabla, Longitud ;
			from diccionario ;
			where Entidad == "VALEDECAMBIO" and Atributo == "ClienteOrigen" ;
		into cursor c_ClienteOrigen
		
		if _tally > 0
		
			lnLongitudCliente = this.AcumularLongitudesCliente( "CLIENTE" ) 
			if lnLongitudCliente > 0
				lnLongitudCliente = lnLongitudCliente + 3
				if c_ClienteOrigen.Longitud < lnLongitudCliente 
				
					This.oInformacionIndividual.AgregarInformacion( "La longitud del atributo ClienteOrigen de la entidad ValeDeCambio debe ser igual o superior " + ;
								"a la suma de las longitudes de los atributos Codigo y Nombre de la Entidad Cliente, más 3 caracteres para la concatenación." )
				endif
			endif
			
			lnLongitudCliente = this.AcumularLongitudesCliente( "CLIENTECHILE" ) 
			if lnLongitudCliente > 0
				lnLongitudCliente = lnLongitudCliente + 3
				if c_ClienteOrigen.Longitud < lnLongitudCliente 
				
					This.oInformacionIndividual.AgregarInformacion( "La longitud del atributo ClienteOrigen de la entidad ValeDeCambio debe ser igual o superior " + ;
								"a la suma de las longitudes de los atributos Codigo y Nombre de la Entidad ClienteChile, más 3 caracteres para la concatenación." )
				endif
			endif
			
		endif

		use in select( "c_ClienteOrigen" )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ValidarLongitudClienteDestinoEnValeDeCambio() as VOID
		local lnLongitudCliente as Integer
	
		select Entidad, Atributo, Tabla, Longitud ;
			from diccionario ;
			where Entidad == "VALEDECAMBIO" and Atributo == "ClienteDestino" ;
		into cursor c_ClienteDestino
		
		if _tally > 0
		
			lnLongitudCliente = this.AcumularLongitudesCliente( "CLIENTE" ) 
			if lnLongitudCliente > 0
				lnLongitudCliente = lnLongitudCliente + 3
				if c_ClienteDestino.Longitud < lnLongitudCliente 
				
					This.oInformacionIndividual.AgregarInformacion( "La longitud del atributo ClienteDestino de la entidad ValeDeCambio debe ser igual o superior " + ;
								"a la suma de las longitudes de los atributos Codigo y Nombre de la Entidad Cliente, más 3 caracteres para la concatenación." )
				endif
			endif
			
			lnLongitudCliente = this.AcumularLongitudesCliente( "CLIENTECHILE" ) 
			if lnLongitudCliente > 0
				lnLongitudCliente = lnLongitudCliente + 3
				if c_ClienteDestino.Longitud < lnLongitudCliente 
				
					This.oInformacionIndividual.AgregarInformacion( "La longitud del atributo ClienteDestino de la entidad ValeDeCambio debe ser igual o superior " + ;
								"a la suma de las longitudes de los atributos Codigo y Nombre de la Entidad ClienteChile, más 3 caracteres para la concatenación." )
				endif
			endif
		endif

		use in select( "c_ClienteDestino" )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function LongitudMinimaClienteNombre( ) as Void 
		if inlist( This.cProyectoActivo, "COLORYTALLE" )
			select Entidad, Longitud ;
				from diccionario ;
				where lower(entidad) == "cliente" and inlist( Atributo, "Nombre" ) ;
			into cursor c_ClienteNombre

			select Entidad, sum( Longitud ) as Longitud ;
				from diccionario ;
				where lower(Entidad) == "cliente" and inlist( Atributo, "PrimerNombre", "SegundoNombre", "Apellido" ) ;
			into cursor c_ClienteOtros
			
			if c_ClienteNombre.Longitud < c_ClienteOtros.Longitud + 3 && ", " y " "
				this.oInformacionIndividual.AgregarInformacion( "La longitud del atributo debe ser igual o superior " + ;
							"a la suma de las longitudes de los atributos PrimerNombre, SegundoNombre y Apellido, más 3 caracteres para la concatenación. ACTUAL(";
							+ alltrim( str( c_ClienteNombre.Longitud ) ) + ") MINIMA(" + alltrim( str( c_ClienteOtros.Longitud+3 ) ) +")")
			endif 
			use in select( "c_ClienteNombre" )
			use in select( "c_ClienteOtros" )
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	function AcumularLongitudesCliente( tcEntidad as String ) as Integer
		local lnRetorno as Integer
		
		select Entidad, sum( Longitud ) as Longitud ;
			from diccionario ;
			where Entidad == alltrim( tcEntidad ) and inlist( Atributo, "Codigo", "Nombre" ) ;
		into cursor c_Cliente
		
		if _tally > 0
			lnRetorno = c_Cliente.Longitud 
		else
			lnRetorno = 0
		endif
		
		use in select( "c_Cliente" )
		return lnRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	function ValidarClavePrimariaEnITems() as Void


		select Entidad.Entidad ;
			from Entidad  ;
			where Entidad.Tipo = "I" and upper( Entidad ) not in ( Select upper( entidad ) from Diccionario where ClavePrimaria ) ;
			into cursor c_Ver
			
		scan All
			This.oInformacionIndividual.AgregarInformacion( "El Item " + alltrim( Entidad ) + " no tiene seteado un atributo claveprimaria" )
		EndScan				
		use in select( "c_Ver" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarNombredeItems() as Void

		select Entidad.Entidad ;
			from Entidad  ;
			where Entidad.Tipo = "I" and "DETALLE" $ upper( Entidad ) ;
			into cursor c_Ver
			
		scan All
			This.oInformacionIndividual.AgregarInformacion( "Los items no pueden contener 'detalle' dentro de su nombre - " + alltrim( Entidad ) )
		EndScan				
		use in select( "c_Ver" )

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarVisibilidadMuestraRelacion() as Void
		select d.Entidad, d.Atributo ;
			from Diccionario  D inner join Entidad E on alltrim( upper( d.Entidad ) ) == alltrim( upper( e.Entidad ) );
			where d.MuestraRelacion and !d.Alta and e.Tipo = "E" and e.Formulario and upper( e.Entidad ) in ( Select upper( ClaveForanea ) from Diccionario ) ;
			into cursor c_Ver
			
		scan All
			This.oInformacionIndividual.AgregarInformacion( "Los Atributos MuestraRelacion deben tener alta en true " + alltrim( Entidad ) + " - " + alltrim( Atributo ))
		EndScan				
		use in select( "c_Ver" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIndice_SqlServer_SoloUnCluster() as Void
		select tabla, escluster ;
			from indice_sqlserver ;
			where escluster ;
			group by tabla, escluster having count(*) > 1 ;
			into cursor c_clusterInvalidos

		select("c_clusterInvalidos")

		scan
			This.oInformacionIndividual.AgregarInformacion( "Se ha especificado mas de un índice cluster para la tabla " + alltrim( c_clusterInvalidos.Tabla ) + " en la tabla de ADN INDICE_SQLSERVER." )
		EndScan				
		use in select( "c_clusterInvalidos" )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIndice_SqlServer_IndicesDuplicados() as Void
		select tabla, nombre ;
			from indice_sqlserver ;
			group by tabla, nombre having count(*) > 1 ;
			into cursor c_nombresInvalidos

		select("c_nombresInvalidos")

		scan
			This.oInformacionIndividual.AgregarInformacion( "El índice " + alltrim( c_nombresInvalidos.nombre ) + " para la tabla " + alltrim( c_nombresInvalidos.Tabla ) + " se encuentra duplicado en la tabla de ADN INDICE_SQLSERVER." )
		EndScan				
		use in select( "c_nombresInvalidos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarConsistenciaClavesCandidatas() as Void
		* Todos las tablas de los comprobantes y sus campos clave candidata
		select d.tabla, d.campo, count(*) as cantidad ;
			from ( select alltrim( upper( tabla ) ) as tabla, alltrim( upper( campo ) ) as campo, alltrim( upper( entidad ) ) as entidad, clavecandidata from Diccionario ) as d ;
 					inner join comprobantes on alltrim( upper( d.entidad ) ) == alltrim( upper( comprobantes.descripcion ) ) ;
			where !empty( d.clavecandidata ) ;
			group by d.tabla, d.campo;
			into cursor c_ClavesCandidatasPorTabla
				
		* Cantidad de entidades por tabla
		select d.tabla, count(*) as cantidad ;
			from ( select distinct alltrim( upper( tabla ) ) as tabla, alltrim( upper( entidad ) ) as entidad from Diccionario where claveprimaria ) as d ;
 					inner join comprobantes on alltrim( upper( d.entidad ) ) == alltrim( upper( comprobantes.descripcion ) ) ;
			group by d.tabla ;
			into cursor c_EntidadesPorTabla				
		
		* Cada campo debe repetirse tantas veces como entidades haya
		select ccpt.tabla, ccpt.campo ;
			from c_ClavesCandidatasPorTabla ccpt inner join c_EntidadesPorTabla ept on ccpt.tabla == ept.tabla ;
			where ccpt.cantidad != ept.cantidad ;
			into cursor c_diferencias		

		select c_diferencias
		scan 		
			This.oInformacionIndividual.AgregarInformacion( "Las claves candidatas para la tabla " + alltrim( c_diferencias.tabla ) + " son inconsistentes entre las distintas entidades." )
		endscan
		
		use in select( "c_ClavesCandidatasPorTabla" )
		use in select( "c_EntidadesPorTabla" )
		use in select( "c_diferencias" )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaEtiquetaEntidadesItem() as VOID


		if inlist( This.cProyectoActivo, "COLORYTALLE" , "NIKE" )

			select e.Entidad, d.Atributo, d.Entidad as EntidadDiccionario  ;
			from Entidad e , diccionario d;
				where "DETALLE" + upper( e.entidad ) == upper( d.dominio ) ;
				and upper( e.Tipo ) == 'I' ;
					and !("<NOLISTAGENERICO>" $ upper( alltrim( e.FUNCIONALIDADES ) ) ) ;
					and empty(d.etiqueta) ;
				group by e.entidad ;
				into Cursor Cur_SinEtiquetas

			If _Tally > 0
				Scan
					This.oInformacionIndividual.AgregarInformacion( "Falta la Etiqueta del atributo " + upper( rtrim( Cur_SinEtiquetas.Atributo )) + ", de la entidad " + rtrim( Cur_SinEtiquetas.EntidadDiccionario ) + ", necesario para armar el nombre del Acceso Directo del listado genérico." )
				Endscan
			endif

			use in select( "Cur_SinEtiquetas" )
			
		endif	
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAdnMuestraRelacionYAtributoForaneoEnDetalles() as Void

		* Todos las tablas de los comprobantes y sus campos clave candidata
		select upper( alltrim(dic2.atributo)+ "."+alltrim(dic3.atributo) ) <> upper( dic1.atributoforaneo ) and !empty(dic1.atributoforaneo) as mal, ;
				dic1.entidad as dic1_entidad, ;
				dic1.atributo as dic1_atributo, ;
				dic2.claveforanea as dic2_claveforanea, ;
				dic1.atributoforaneo as dic1_atributoforaneo, ;
				dic2.atributo as dic2_atributo, ;
				dic3.atributo as dic3_atributo, ;
				dic3.entidad as dic3_entidad ;
				from diccionario as dic1 ;
				join diccionario as dic2 on strtran( upper( dic1.atributo ), "DETALLE", "" ) = upper( dic2.atributo ) and upper( dic1.entidad ) = upper( dic2.entidad ) ;
				join diccionario as dic3 on upper( dic2.claveforanea ) = upper( dic3.entidad ) ;
				where upper( left( dic1.entidad, 4) ) == "ITEM" ;
						and upper( right( alltrim( dic1.atributo ), 7 ) ) == "DETALLE" ;
						and dic1.muestrarelacion;
						and dic3.muestrarelacion;
						and upper( alltrim(dic2.atributo)+ "."+alltrim(dic3.atributo) ) <> upper( dic1.atributoforaneo );
				order by dic1.entidad;
				into cursor c_Diferencias

		select c_diferencias
		scan 		
			This.oInformacionIndividual.AgregarInformacion( "Inconsistencia en " + upper( alltrim( c_Diferencias.dic1_entidad ) )+ ": AtributoForaneo para el atributo " + alltrim( c_Diferencias.dic1_atributo ) + " deberia ser igual al nombre del atributo al que esta relacionado + atributo con muestrarelacion en la entidad primaria (ACTUAL: [" + alltrim( c_Diferencias.dic1_atributoforaneo ) + "], ESPERADO: [" + alltrim( c_Diferencias.dic2_atributo) + "." + alltrim( c_Diferencias.dic3_atributo ) + "])" )
		endscan
		
		use in select( "c_Diferencias" )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFuncionalidadControlarFechaHoraEnRecepcion() as Void
		local lcMensaje as String, lcCursor as String, lcEntidad as String
		
		lcCursor = sys( 2015 )

		select distinct e.Entidad, upper( alltrim( e.funcionalidades ) ) as funcionalidades ;
			from entidad e ;
			where ( "<CONTROLARFECHAHORAENRECEPCION>" $ funcionalidades;
				and ( "<ANULABLE>" $ funcionalidades ) );
			into cursor ( lcCursor )
		
		scan
			lcEntidad = upper( alltrim( &lcCursor..Entidad ) )
			lcMensaje = "La entidad " + alltrim( &lcCursor..Entidad ) + " no puede tener la funcionalidad <CONTROLARFECHAHORAENRECEPCION> si" + ;
						", además, contiene la funcionalidad <ANULABLE>."
			This.oInformacionIndividual.AgregarInformacion( lcMensaje )
		endscan
		
		use in select ( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadDeEtiquetasEnCadaEntidad() as VOID

		if inlist( This.cProyectoActivo, "COLORYTALLE" , "NIKE" )

			select d.Entidad, d.etiqueta, count(*) ;
			from diccionario d ;
			where !empty(d.etiqueta) ;
			and empty(d.EtiquetaAutodescriptiva) ;			
			group by d.Entidad , d.etiqueta;
			having count(*) >1 ;
			order by d.Entidad , d.etiqueta ;
			into Cursor Cur_EtiquetasRepetidas

			If _Tally > 0
				Scan
					This.oInformacionIndividual.AgregarInformacion( "La Entidad '" + alltrim( Cur_EtiquetasRepetidas.Entidad ) + "' tiene más de un atributo con la Etiqueta: '"+ upper( alltrim( Cur_EtiquetasRepetidas.Etiqueta)) +"'." )
				Endscan
			endif

			use in select( "Cur_EtiquetasRepetidas" )
			
		endif	
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadDeEtiquetaCortaEnCadaEntidad() as VOID

		if inlist( This.cProyectoActivo, "COLORYTALLE" , "NIKE" )
			select d.Entidad, d.EtiquetaCorta, count(*) ;
			from diccionario d ;
			where !empty(d.EtiquetaCorta) ;
			and empty(d.EtiquetaAutodescriptiva) ;						
			group by d.Entidad , d.EtiquetaCorta;
			having count(*) >1 ;
			order by d.Entidad , d.EtiquetaCorta ;
			into Cursor Cur_EtiquetasRepetidas

			If _Tally > 0
				Scan
					This.oInformacionIndividual.AgregarInformacion( "La Entidad '" + alltrim( Cur_EtiquetasRepetidas.Entidad ) + "' tiene más de un atributo con la EtiquetaCorta: '"+ upper( alltrim( Cur_EtiquetasRepetidas.EtiquetaCorta )) +"'." )
				Endscan
			endif

			use in select( "Cur_EtiquetasRepetidas" )
			
		endif	
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarUnicidadDeEtiquetaAutodescriptivaEnCasaEntidad() as VOID

		if inlist( This.cProyectoActivo, "COLORYTALLE" , "NIKE" )

			select d.Entidad, d.EtiquetaAutodescriptiva, count(*) ;
			from diccionario d ;
			where !empty(d.EtiquetaAutodescriptiva) ;			
			group by d.Entidad , d.EtiquetaAutodescriptiva;
			having count(*) >1 ;
			order by d.Entidad , d.EtiquetaAutodescriptiva ;
			into Cursor Cur_EtiquetasRepetidas

			If _Tally > 0
				Scan
					This.oInformacionIndividual.AgregarInformacion( "La Entidad '" + alltrim( Cur_EtiquetasRepetidas.Entidad ) + "' tiene más de un atributo con la EtiquetaAutodescriptiva: '"+ upper( alltrim( Cur_EtiquetasRepetidas.EtiquetaAutodescriptiva )) +"'." )
				Endscan
			endif

			use in select( "Cur_EtiquetasRepetidas" )
			
		endif	
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarClaveDeBusqueda() as Void
		select 0
		select distinct alltrim(upper(entidad)) as entidad1 from diccionario where alltrim(upper(dominio))=="CLAVECANDIDATA" into cursor CB_11
		select 0
		select distinct alltrim(upper(entidad)) as entidad2 from diccionario where alltrim(upper(dominio))=="CLAVEDEBUSQUEDA" into cursor CB_12
		select 0
		select * from cb_12 inner join cb_11 on cb_11.entidad1=cb_12.entidad2 into cursor CB_valida
		if reccount("CB_12")>0
			select CB_valida
			scan 		
				This.oInformacionIndividual.AgregarInformacion( "La entidad " + alltrim( entidad2 ) + " no puede tener CLAVEDEBUSQUEDA y CLAVECANDIDATA al mismo tiempo" )
			endscan
		endif
		use in select( "CB_11" )
		use in select( "CB_12" )
		use in select( "CB_valida" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InformarProceso( tcMensaje as Integer ) as Void
		local lcMensaje as String
		lcMensaje = "Validar ADN: " + tcMensaje + " (" + transform( datetime() ) + ")"
		this.Informar( lcMensaje )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Informar( tcMensaje as Integer ) as Void
		&& Bindear para obtener avances
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarClaveForaneEnFiltrosConBuscador() as Void	
		local lcCurAtrMal as String, lcAtributo as String, lcEntidad as String, llClaveCandidata as Boolean
		
		lcCurAtrMal = sys( 2015 )
		select * from diccionario ;
				where alltrim( upper( dominio ) ) == "ETIQUETACARACTERDESDEHASTABUSC" and empty( ClaveForanea ); 
			into cursor &lcCurAtrMal
		
		if reccount( lcCurAtrMal ) > 0
			select &lcCurAtrMal
			scan 
				lcAtributo = upper( alltrim( &lcCurAtrMal..Atributo ) )
				lcEntidad = upper( alltrim( &lcCurAtrMal..Entidad ) )
				this.oInformacionIndividual.AgregarInformacion( "El atributo '" + proper( lcAtributo ) + ;
		            	"' de la entidad '" + proper( lcEntidad ) + "' debe tener clave foranea." )
			endscan
		endif

		use in select( lcCurAtrMal )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTagCopiaDesdeTxt() as Void	
		Local lcCursor as String
		lcCursor = sys( 2015 )
		select entidad, count(*) as cantidad from diccionario where "COPIADESDETXT" $ upper(tags) group by entidad into cursor &lcCursor
		scan all for cantidad > 1
			This.oInformacionIndividual.AgregarInformacion( "No puede haber más de una atributo con tag <COPIADSDETXT> en la misma entidad ( " + alltrim(Entidad) + " )" )
		endscan	
		Use In select( lcCursor )		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIdDeConsultasNoCambien() as Void
		Local lcCursor as String
		lcCursor = sys( 2015 )
		if upper( alltrim( This.cProyectoActivo ) ) == "COLORYTALLE"
			select id, etiqueta, comando from menuprincipalitems where inlist( id, 2036, 2040, 2043, 9860, 9901, 10500 ) into cursor &lcCursor
			if reccount( lcCursor ) != 6
				This.oInformacionIndividual.AgregarInformacion( "Debería traer 6 buscadores (consultas). Si cambió la cantidad, revisar la seguridad implementada en LanzadorDeConsulta.prg" )
			endif
			scan
				if !( "buscador" $ lower( alltrim( comando ) ) )
					This.oInformacionIndividual.AgregarInformacion( "El Id: (" + alltrim( transform( &lcCursor..Id ) ) + ") con etiqueta: (" + alltrim( &lcCursor..Etiqueta ) + ") no tiene ningún buscador (consulta) asociado y debería tenerlo. Hay chequeos de seguridad en el prg LanzadorDeConsulta que usa ese Id." )
				endif
			endscan
			Use In select( lcCursor )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosKitsYParticipantes() as Void
		Local lcCursor as String, lcCursorFiltrados as String, lcCursorComportamiento as String, lcSentencia as String, loAtributos as Object, ;
		      lcCursorFiltradosConTag as String, lcCursorAtributoDespuesDeAsignacion  as String, lcCursorDetallesConTags as String, lcCursorFiltradosConTags as String
		      
		lcCursorDetalles = sys( 2015 )
		lcCursorFiltrados = sys( 2015 )
		lcCursorComportamiento = sys( 2015 )
		lcCursorAtributoArticulo = sys( 2015 )
		lcCursorDetallesConTag = sys( 2015 )
		lcCursorDetallesConTags = sys( 2015 )
		lcCursorFiltradosConTag = sys( 2015 )
		lcCursorFiltradosConTags = sys( 2015 )
		lcCursorFiltradosConTagEntidades = sys( 2015 )
		lcCursorAtributoDespuesDeAsignacion = sys( 2015 )

		loAtributos = this.ObtenerAtributosCombinacion()

		if loAtributos.Count > 0
			lcSentencia = "select distinct d1.dominio, d2.atributo, d2.claveforanea from diccionario d1 left join diccionario d2 on d2.entidad = substr(d1.dominio, 8, len(d1.dominio)) " + ;
	                	  "where 'DETALLE' $ upper(substr(d1.dominio, 1, 8)) and d1.alta and ("
	                	  
	    	for each lcAtributo in loAtributos
				lcAtributo = upper( lcAtributo )
				lcSentencia = lcSentencia + "( upper( d2.atributo) = '" + lcAtributo + "' and upper( d2.claveforanea ) = '" + lcAtributo + "' and d2.alta ) or "
			endfor
			lcSentencia = Substr( lcSentencia, 1, Len( lcSentencia ) - 3 )+ " ) into cursor '" + lcCursorDetalles + "'"
				
			&lcSentencia
				
			select d3.dominio, count(*) ;
			from &lcCursorDetalles d3 ;
			group by d3.dominio having count(*) = loAtributos.Count;
			into cursor &lcCursorFiltrados

			select &lcCursorFiltrados
			scan
				lcEntidad = alltrim( substr(dominio, 8, len(dominio)) )
				
				select * from diccionario d4 where upper( d4.entidad ) = upper( lcEntidad ) and upper( d4.atributo ) = "COMPORTAMIENTO" and ;
				  								   upper( d4.atributoforaneo ) = "ARTICULO.COMPORTAMIENTO" and !empty(tabla) and !empty(campo);
				  								   and upper( tipoDato ) = "N" and longitud = 1 and upper( dominio ) = "NUMERICO" ;
				  								   into cursor &lcCursorComportamiento
				select &lcCursorComportamiento
				if _tally = 0
					This.oInformacionIndividual.AgregarInformacion( "La entidad " + lcEntidad + " no tiene el atributo 'comportamiento' o no lo tiene de manera correcta (atributo foraneo debe ser 'Articulo.Comportamiento' y debe tener tabla y campo, tipo de dato N y longitud 1)")
				endif	
				   
			endscan
			
			***
			
			lcSentencia = "select distinct d1.entidad, d1.dominio, d2.atributo, d2.claveforanea from diccionario d1 left join diccionario d2 on d2.entidad = substr(d1.dominio, 8, len(d1.dominio)) " + ;
	                	  "where 'DETALLE' $ upper(substr(d1.dominio, 1, 8)) and d1.alta and '<CONPARTICIPANTES>' $ upper( d1.Tags ) and ("
	                	  
	    	for each lcAtributo in loAtributos
				lcAtributo = upper( lcAtributo )
				lcSentencia = lcSentencia + "( upper( d2.atributo) = '" + lcAtributo + "' and upper( d2.claveforanea ) = '" + lcAtributo + "' and d2.alta ) or "
			endfor
			lcSentencia = Substr( lcSentencia, 1, Len( lcSentencia ) - 3 )+ " ) into cursor '" + lcCursorDetallesConTag + "'"
				
			&lcSentencia
					
			select d4.dominio, count(*) ;
			from &lcCursorDetallesConTag d4 ;
			group by d4.dominio having count(*) = loAtributos.Count ;
			into cursor &lcCursorFiltradosConTag
			
			select &lcCursorFiltradosConTag
			scan 		
				lcEntidad = alltrim( substr(dominio, 8, len(dominio)) )
				
				select * from diccionario d4 where upper( d4.entidad ) = upper( lcEntidad ) and upper( d4.atributo ) = "IDKIT" ;
				  								   and !empty(tabla) and !empty(campo) and upper( tipoDato ) = "G" and longitud = 38 ; 
				  								   and upper( dominio ) = "CARACTER" into cursor &lcCursorComportamiento
				select &lcCursorComportamiento
				if _tally = 0
					This.oInformacionIndividual.AgregarInformacion( "La entidad " + lcEntidad + " no tiene el atributo 'idkit' o no lo tiene de manera correcta (debe tener tabla y campo, tipo de dato G, longitud 38 y dominio CARACTER)")
				endif	
			endscan
			
			***
			
			select d4.entidad, count(*) ;
			from &lcCursorDetallesConTag d4 ;
			group by d4.entidad having count(*) = loAtributos.Count ;
			into cursor &lcCursorFiltradosConTagEntidades
			
			select &lcCursorFiltradosConTagEntidades
			scan 
				lcEntidad = alltrim( entidad )

				select * from diccionario d4 where upper( d4.entidad ) = upper( lcEntidad ) and upper( d4.atributo ) = "KITSDETALLE" ;
				  								   and !empty(tabla) and !empty(campo) and upper( tipoDato ) = "G" and longitud = 38 ; 
				  								   and upper( dominio ) = "DETALLEITEMKITS" into cursor &lcCursorComportamiento
				select &lcCursorComportamiento
				if _tally = 0
					This.oInformacionIndividual.AgregarInformacion( "La entidad " + lcEntidad + " no tiene el atributo 'KitsDetalle' o no lo tiene de manera correcta (debe tener tabla y campo, tipo de dato G, longitud 38 y dominio DETALLEITEMKITS)")
				endif				
			endscan
			
			***

			lcSentencia = "select distinct d1.entidad, d1.dominio, d2.atributo, d2.claveforanea from diccionario d1 left join diccionario d2 on d2.entidad = substr(d1.dominio, 8, len(d1.dominio)) " + ;
	                	  "where 'DETALLE' $ upper(substr(d1.dominio, 1, 8)) and d1.alta and ( '<CONPARTICIPANTES>' $ upper( d1.Tags ) or '<NOVALIDAKIT>' $ upper( d1.Tags ) ) and ("
	                	  
	    	for each lcAtributo in loAtributos
				lcAtributo = upper( lcAtributo )
				lcSentencia = lcSentencia + "( upper( d2.atributo) = '" + lcAtributo + "' and upper( d2.claveforanea ) = '" + lcAtributo + "' and d2.alta ) or "
			endfor
			lcSentencia = Substr( lcSentencia, 1, Len( lcSentencia ) - 3 )+ " ) into cursor '" + lcCursorDetallesConTags + "'"
				
			&lcSentencia
					
			select d4.dominio, count(*) ;
			from &lcCursorDetallesConTags d4 ;
			group by d4.dominio having count(*) = loAtributos.Count ;
			into cursor &lcCursorFiltradosConTags
 
			select &lcCursorFiltradosConTags
			scan 
				lcEntidad = alltrim( substr(dominio, 8, len(dominio)) )

				select * from diccionario d4 where upper( d4.entidad ) = upper( lcEntidad ) and upper( d4.atributo ) = "ARTICULO" and ;
			  								       "THIS.LIMPIARCOLORYTALLE()" $ upper( d4.despuesdeasignacion );
			  								       into cursor &lcCursorAtributoDespuesDeAsignacion
			  								       
			  	select &lcCursorAtributoDespuesDeAsignacion
				if _tally = 0
					This.oInformacionIndividual.AgregarInformacion( "La entidad " + lcEntidad + " no tiene el atributo 'articulo' con despuesDeAsignacion = 'this.LimpiarColorYTalle()'")
				endif				
			endscan

			use in select( lcCursorComportamiento )
			use in select( lcCursorFiltrados )
			use in select( lcCursorFiltradosConTag )
			use in select( lcCursorFiltradosConTags )
			use in select( lcCursorFiltradosConTagEntidades )
			use in select( lcCursorDetalles )
			use in select( lcCursorDetallesConTag )
			use in select( lcCursorDetallesConTags )			
			use in select( lcCursorAtributoArticulo )
			use in select( lcCursorAtributoDespuesDeAsignacion )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosCombinacion() as Void
		local loCampos as zoocoleccion OF zoocoleccion.prg 
		loCampos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with this		
			use in select( "c_Atributo" )
			select * ;
				from diccionario ;
				where upper( alltrim( Entidad ) ) == "ITEMARTICULOSVENTAS" ;
				order by clavecandidata;
				into cursor c_Atributo
			
			select c_Atributo
			scan 
			
				select * ;
					from diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0 and !empty(claveforanea) and ;
					upper( alltrim( atributo ) ) == upper( alltrim( c_Atributo.Atributo ) ) ;
					into cursor c_AtributosStockCombinacion NoFilter
				
				if _tally > 0	
					loCampos.Agregar( alltrim( upper( c_Atributo.Atributo) ) )
				endif		
				select c_Atributo
			endscan
			use in select( "c_Atributo"  )
			use in select( "c_AtributosStockCombinacion" )		
		endwith	
		return loCampos 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarItemKitsVsItemArticulosVentas() as Void
		local lnCantidadDeCampos as Integer, i as Integer, lcCampo as String, c_ItemKits as String, c_ItemVenta as String, ;
			lcAtributo as String, lxValorItemKits as Variant, lxValorItemVenta as Variant
		
		if inlist( This.cProyectoActivo, "COLORYTALLE", "FELINO" )
			c_ItemKits = sys( 2015 )			
			select * from diccionario d where upper( alltrim( d.ENTIDAD ) ) == "ITEMKITS" ;
				into cursor &c_ItemKits
			select( c_ItemKits )
			index on upper( alltrim( atributo ) ) tag atributo
			
			
			c_ItemVenta = sys( 2015 )
			select * from diccionario d where upper( alltrim( d.ENTIDAD ) ) == "ITEMARTICULOSVENTAS" ;
				into cursor &c_ItemVenta
			select( c_ItemVenta )
			index on upper( alltrim( atributo ) ) tag atributo
			
			select( c_ItemVenta )
			lnCantidadDeCampos = AFIELDS(laCamposDiccionario)
			select( c_ItemVenta )
			scan
				lcAtributo = upper( alltrim( evaluate( c_ItemVenta + ".atributo" ) ) )
				if this.VerificarSiElCampoDebeSerComparadoEntreItemVentaYItemKits( lcAtributo )
					select( c_ItemKits )
					if seek( lcAtributo )
						FOR i = 1 TO lnCantidadDeCampos
							lcCampo = upper( alltrim( laCamposDiccionario( i, 1 ) ) )
							if this.VerificarSiElCampoDebeSerComparadoEntreItemVentaYItemKits( lcCampo, lcAtributo ) 
								select( c_ItemVenta )
								lxValorItemVenta = evaluate( c_ItemVenta + "." + lcCampo )
								select( c_ItemKits )
								lxValorItemKits = evaluate( c_ItemKits + "." + lcCampo )

								if lxValorItemVenta != lxValorItemKits
									this.AgregarInformacionIndividual( "Error en la entidad ITEMKITS, El " + lcCampo + " del atributo " + lcAtributo +  ;
										" debería tener el mismo valor que el atributo " + lcAtributo + " de ITEMARTICULOSVENTAS" )
								endif						
							endif
						ENDFOR		
					else
						this.AgregarInformacionIndividual( "Error en la entidad ITEMKITS. El atributo " + lcAtributo + " de ITEMARTICULOSVENTAS, debería estar en ITEMKITS." )
					endif
					select( c_ItemVenta )
				endif
			endscan	
			
			use in select ( c_ItemVenta )	   
			use in select ( c_ItemKits )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarVersionMinimaDeRecepcion() as Void
		
		* Esta validación está para que cuando se grega o modifica la versión mínima de recepción de una entidad
		* se agregue código para que al generar paquetes de datos, los cambios sean compatibles con versiones anteriores.
		* Por ej.: si se agrega un campo nuevo en una entidad, y se empaqueta dicha entidad, si en ese nuevo campo no 
		* se envía información, debería limpiarse la versión mínima de recepción para que pueda entrar la información 
		* en una base que no tenga ese campo nuevo.
		* Ver TransferenciaBase.prg
	
		local lcCursorModificado as String 
		
		create cursor c_CurEntidades ( Entidad C ( 40 ), version C ( 20 ) )
		this.ObtenerEntidadesConVersionMinimaDeRecepcion( "c_CurEntidades" )
				
		lcCursorModificado = sys(2015)
		select * from Entidad where !empty( versionMinimaDeRecepcion ) into cursor &lcCursorModificado
		select &lcCursorModificado
		scan
			lcVersionActual = alltrim(upper( &lcCursorModificado .versionMinimaDeRecepcion ))
			select c_CurEntidades
			locate for alltrim(upper( entidad )) = alltrim(upper( &lcCursorModificado .entidad ))
			if found()
				if alltrim(upper( version )) != lcVersionActual
					this.AgregarInformacionIndividual( "Error en la entidad " + alltrim(upper( entidad )) + ". Se modificó la versión mínima de recepción. Debe implementar o modificar el método CompatibilizarVersionMinimaDeRecepcionParaVersionesAnteriores para las transferencias." )
				endif
			else
				this.AgregarInformacionIndividual( "Error en la entidad " + alltrim(upper( &lcCursorModificado .entidad )) + ". Se agregó una versión mínima de recepción. Debe implementar el método CompatibilizarVersionMinimaDeRecepcionParaVersionesAnteriores para las transferencias." )
			endif
			select &lcCursorModificado
		endscan
		
		select &lcCursorModificado
		use
		
		select c_CurEntidades
		use
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarSiElCampoDebeSerComparadoEntreItemVentaYItemKits( tcCampo as String, tcAtributo as String  ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		do case
			case tcCampo = "ENTIDAD"
			case tcCampo = "TABLA"
			case tcCampo = "GRUPO"
			case tcCampo = "DESCRIPCIONGRUPO"
			case tcCampo = "TIPOSUBGRUPO"
			case tcCampo = "DESCRIPCIONSUBGRUPO"
			case tcCampo = "TIPOSUBGRUPO"
			case tcCampo = "TIPOSUBGRUPO"
			case tcCampo = "RESERVADO"
			case tcCampo = "DOMINIO" and upper( alltrim( tcAtributo ) ) = "ARTICULO"
			case tcCampo = "TAGS"
			case tcCampo = "VALORSUGERIDO"
			case tcCampo = "ETIQUETA"
			case tcCampo = "ALTA"
			case tcCampo = "CAMPO"
			case tcCampo = "ETIQUETAAUTODESCRIPTIVA"
			case tcCampo = "ETIQUETACORTA"
			case tcCampo = "TOOLTIP"
			case tcCampo = "AYUDA"
			case tcCAmpo = "FILTROBUSCADOR"
		otherwise 
			llRetorno = .t.
		endcase
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadesConVersionMinimaDeRecepcion( tcCursor as String ) as Void
		do case
			case this.cProyectoActivo == 'FELINO'
				insert into &tcCursor values ( "FACTURA                                 ", "06.0004.11383       ")
				insert into &tcCursor values ( "TICKETFACTURA                           ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITO                           ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITO                            ", "06.0004.11383       ")
				insert into &tcCursor values ( "TICKETNOTADECREDITO                     ", "06.0004.11383       ")
				insert into &tcCursor values ( "TICKETNOTADEDEBITO                      ", "06.0004.11383       ")
				insert into &tcCursor values ( "REMITO                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "MOVIMIENTODECAJA                        ", "06.0004.11383       ")
				insert into &tcCursor values ( "Devolucion                              ", "06.0004.11383       ")
				insert into &tcCursor values ( "CTACTE                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "PEDIDO                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "PRESUPUESTO                             ", "06.0004.11383       ")
				insert into &tcCursor values ( "FACTURAELECTRONICA                      ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICA                ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICA                 ", "06.0004.11383       ")
				insert into &tcCursor values ( "FACTURAELECTRONICAEXPORTACION           ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICAEXPORTACION     ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICAEXPORTACION      ", "06.0004.11383       ")
				insert into &tcCursor values ( "MINIMOREPOSICION                        ", "06.0003.00001       ")
				insert into &tcCursor values ( "REMITODECOMPRA                          ", "06.0004.11383       ")
				insert into &tcCursor values ( "LISTADEPRECIOSCALCULADA                 ", "07.0001.11720       ")
				insert into &tcCursor values ( "FACTURADEEXPORTACION                    ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITODEEXPORTACION              ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITODEEXPORTACION               ", "06.0004.11383       ")
				insert into &tcCursor values ( "FACTURAELECTRONICADECREDITO             ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICADECREDITO       ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICADECREDITO        ", "06.0004.11383       ")
				insert into &tcCursor values ( "FACTURAAGRUPADA                         ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOAGRUPADA                   ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOAGRUPADA                    ", "06.0004.11383       ")
			
			case this.cProyectoActivo == 'COLORYTALLE'
				insert into &tcCursor values ( "ARTICULO                                ", "11.0009.13387       ")
				insert into &tcCursor values ( "PROVEEDOR                               ", "07.0008.12019       ")
				insert into &tcCursor values ( "VALOR                                   ", "01.0010.7337        ")
				insert into &tcCursor values ( "CLIENTE                                 ", "07.0008.12019       ")
				insert into &tcCursor values ( "Factura                                 ", "10.0006.12930       ")
				insert into &tcCursor values ( "Itemvalores                             ", "05.0007.11000       ")
				insert into &tcCursor values ( "COMPROBANTEDECAJA                       ", "06.0002.00001       ")
				insert into &tcCursor values ( "Notadecredito                           ", "06.0004.11383       ")
				insert into &tcCursor values ( "Notadedebito                            ", "06.0004.11383       ")
				insert into &tcCursor values ( "Ticketfactura                           ", "10.0006.12930       ")
				insert into &tcCursor values ( "Ticketnotadecredito                     ", "06.0004.11383       ")
				insert into &tcCursor values ( "Ticketnotadedebito                      ", "06.0004.11383       ")
				insert into &tcCursor values ( "Movimientodecaja                        ", "06.0004.11383       ")
				insert into &tcCursor values ( "Ctacte                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "Modificacionprecios                     ", "06.0003.00001       ")
				insert into &tcCursor values ( "Preciodearticulo                        ", "06.0005.11402       ")
				insert into &tcCursor values ( "Itemarticulosventas                     ", "01.0012.8590        ")
				insert into &tcCursor values ( "Disenoimpresion                         ", "08.0006.12288       ")
				insert into &tcCursor values ( "TIDiferenciasDeInventarioDetalle        ", "01.0012.8590        ")
				insert into &tcCursor values ( "MercaderiaEnTransito                    ", "08.0012.12500       ")
				insert into &tcCursor values ( "REMITO                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "DEVOLUCION                              ", "06.0004.11383       ")
				insert into &tcCursor values ( "ITEMARTICULOSSENIADOS                   ", "01.0012.8590        ")
				insert into &tcCursor values ( "PEDIDO                                  ", "06.0004.11383       ")
				insert into &tcCursor values ( "PRESUPUESTO                             ", "06.0004.11383       ")
				insert into &tcCursor values ( "TRANSPORTISTA                           ", "07.0008.12019       ")
				insert into &tcCursor values ( "ITEMARTICULOSCOMPRA                     ", "01.0012.8590        ")
				insert into &tcCursor values ( "FACTURAELECTRONICA                      ", "10.0006.12930       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICA                ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICA                 ", "06.0004.11383       ")
				insert into &tcCursor values ( "CTACTECOMPRA                            ", "01.0012.8361        ")
				insert into &tcCursor values ( "ORDENDEPAGO                             ", "01.0012.9424        ")
				insert into &tcCursor values ( "ITEMARTICULOSNDCOMPRA                   ", "01.0012.8590        ")
				insert into &tcCursor values ( "ITEMARTICULOSNCCOMPRA                   ", "01.0012.8590        ")
				insert into &tcCursor values ( "CORREDOR                                ", "07.0008.12019       ")
				insert into &tcCursor values ( "FACTURAELECTRONICAEXPORTACION           ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICAEXPORTACION     ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICAEXPORTACION      ", "06.0004.11383       ")
				insert into &tcCursor values ( "MINIMOREPOSICION                        ", "06.0003.11350       ")
				insert into &tcCursor values ( "ITEMARTICULOSSENIADOSEX                 ", "01.0012.8590        ")
				insert into &tcCursor values ( "PAGO                                    ", "01.0012.9424        ")
				insert into &tcCursor values ( "LISTADEPRECIOSCALCULADA                 ", "07.0001.11720       ")
				insert into &tcCursor values ( "FACTURADEEXPORTACION                    ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITODEEXPORTACION              ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITODEEXPORTACION               ", "06.0004.11383       ")
				insert into &tcCursor values ( "CRITERIOSVALORES                        ", "06.03.11350         ")
				insert into &tcCursor values ( "REGIMENIMPOSITIVO                       ", "05.0005.10890       ")
				insert into &tcCursor values ( "CLIENTERECOMENDANTE                     ", "07.0008.12019       ")
				insert into &tcCursor values ( "IMPDIRCLI                               ", "07.0008.12019       ")
				insert into &tcCursor values ( "IMPDIRPRO                               ", "07.0008.12019       ")
				insert into &tcCursor values ( "FACTURAELECTRONICADECREDITO             ", "10.0006.12930       ")
				insert into &tcCursor values ( "NOTADECREDITOELECTRONICADECREDITO       ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOELECTRONICADECREDITO        ", "06.0004.11383       ")
				insert into &tcCursor values ( "FACTURAAGRUPADA                         ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADECREDITOAGRUPADA                   ", "06.0004.11383       ")
				insert into &tcCursor values ( "NOTADEDEBITOAGRUPADA                    ", "06.0004.11383       ")
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTagListarConParaConsultasListados() as Void
		if inlist( This.cProyectoActivo, "COLORYTALLE" )
			local loTag as Object, loItem as Object

			loTag =  this.CompletarColeccionTagLC()
			for each loItem in loTag
				this.ValidarCompras( loItem.Entidad1, loItem.Entidad2 ) && se aprovechó el método de compras para la comparación entre 2 entidades 
			endfor
		endif

	endfunc 


	*-----------------------------------------------------------------------------------------
	function ValidarTag3DecimalesVirtualParaConsultasListados() as Void
		if inlist( This.cProyectoActivo, "COLORYTALLE" )
			local lcCursor as String 
			lcCursor = sys( 2015 )
					
			select idformato, entidad, atributo, tipoDato, Decimales from listcampos where "3DECIMALESVIRTUAL" $ upper(funcionalidades) and ( tipoDato != 'N' or ( tipoDato = 'N' and decimales = 0) ) into cursor &lcCursor
			if _tally > 0
				select(lcCursor)
				scan 
					this.oInformacionIndividual.AgregarInformacion( "Error en listado " + alltrim(idformato) + ", atributo " + alltrim(upper( &lcCursor..atributo )) + " de la entidad " + alltrim(upper( &lcCursor..entidad )) + ". El tag debe utilizarse en atributos numéricos y que tengan algún decimal." )
				endscan
			endif 	
		
		endif
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function CompletarColeccionTagLC() as Object
	local lcEntidadesEnFuncionalidades as String, loCol as object, lcCursor as String, lnI as Integer

		loCol = newobject( "Collection" )
	
		Select ent.ENTIDAD, ent.Funcionalidades, dic.tabla From entidad ent ;
			left join diccionario dic on ent.entidad = dic.entidad;
				where "<LISTARCON:" $ upper( Funcionalidades ) and !deleted() and dic.claveprimaria into cursor lcCursor
		
		Scan
			lcEntidadesEnFuncionalidades = substr( funcionalidades, at( "<LISTARCON:", funcionalidades ) + 11 )
			lcEntidadesEnFuncionalidades = substr( lcEntidadesEnFuncionalidades , 1, at(">", lcEntidadesEnFuncionalidades ) - 1 ) + ";"
			for lnI = 1 to occurs( ";", lcEntidadesEnFuncionalidades )
				lcEntidad = substr( lcEntidadesEnFuncionalidades , 1, at(";", lcEntidadesEnFuncionalidades ) - 1 )
				
				loItem = newobject( "ItemCompra", "ValidarADN.prg" )
				loItem.Entidad1 = lcCursor.entidad
				loItem.Entidad2 = strtran(lcEntidad , ";","")
				loCol.Add( loItem )
				loItem = null
				lcEntidadesEnFuncionalidades = strtran( lcEntidadesEnFuncionalidades , lcEntidad + ";" ,  "" ) 
			next	
		endscan
		
		use in select( "lcCursor" )
		
		return loCol
		
	endfunc 

enddefine
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemCompra as custom
	Entidad1 = ""
	Entidad2 = ""
enddefine
