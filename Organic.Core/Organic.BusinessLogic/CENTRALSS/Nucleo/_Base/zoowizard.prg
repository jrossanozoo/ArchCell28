DEFINE CLASS zoowizard AS ZooFormulario of ZooFormulario.prg

	#IF .f.
		Local this as zoowizard of zoowizard.prg
	#ENDIF

	Top = 54
	Left = 196
	Height = 317
	Width = 459 && 532
	ShowWindow = 1
	DoCreate = .T.
	BorderStyle = 0
	Caption = "Asistente"
	Icon = "..\..\imagenes\iconos\zooIcon.ico"
	WindowState = 0
	WindowType = 1
	Desktop = .t.
	ntotaldepasos= 4
	nPaso = 1
	Name = "zoowizard"
	nIncremento = 1
	Retorno = Null
	cEstadoFinal = ""
	AlwaysOnTop = .T.
	MaxButton = .F.
	MinButton = .F.
	oDatos = Null
	
*!* JM		ADD OBJECT shape1 AS shape WITH ;
*!* JM			Top = 0, ;
*!* JM			Left = 72, ;
*!* JM			Height = 36, ;
*!* JM			Width = 470, ;
*!* JM			BorderStyle = 0, ;
*!* JM			BorderWidth = 0, ;
*!* JM			BackColor = RGB(240,151,31), ;
*!* JM			Name = "Shape1"


	ADD OBJECT image1 AS image WITH ;
		Picture = "..\..\..\imagenes\bmps\zl-reindexador2.jpg", ;
		Stretch = 0, ;
		BorderStyle = 0, ;
		Height = 317, ;
		Width = 459, ;
		Left = 0, ;
		Top = 0, ;
		Stretch = 2, ;
		Name = "Image1"
		
	ADD OBJECT cmdanterior AS commandbutton WITH ;
		Top = 276, ;
		Left = 171,  ;
		Height = 27, ;
		Width = 87, ;
		Caption = "<< \<Anterior", ;
		Name = "CmdAnterior"


	ADD OBJECT cmdsiguiente AS commandbutton WITH ;
		Top = 276, ;
		Left = 265,  ;
		Height = 27, ;
		Width = 87, ;
		Caption = "\<Siguiente >>", ;
		Name = "CmdSiguiente"


	ADD OBJECT cmdcancelar AS commandbutton WITH ;
		Top = 276, ;
		Left = 359, ;
		Height = 27, ;
		Width = 87, ;
		Caption = "\<Cancelar", ;
		Name = "CmdCancelar"

**********************************************************************
	Function Init
		
		thisform.CmdAnterior.Enabled = .f.
		thisform.ActualizaCaption()
		this.oDatos = newobject( "AccesoDatos", "AccesoDatos.prg" )
		dodefault()
		
	EndFunc
**********************************************************************
	function Paso1() as Void

	
	endfunc
**********************************************************************
	function Paso2() as Void

			
	endfunc
**********************************************************************
	function Paso3() as Void
	
	
	endfunc
**********************************************************************
	function Paso4() as Void
	
	
	endfunc
**********************************************************************	
	function ActualizaCaption() as Void
	
		thisform.Caption = "Asistente de ... - Paso " + alltrim(str(thisform.nPaso)) ;
			+ " de " + alltrim(str(thisform.nTotaldePasos))
	
	endfunc
**********************************************************************		
	function CmdCancelar.Click() as Void
		
		thisform.CerrarAsistente()
	
	endfunc
**********************************************************************		

	function cmdAnterior.Click() as Void
		
		thisform.PasoAnterior()
	
	endfunc
**********************************************************************	

	function cmdSiguiente.Click() as Void
		
		thisform.PasoSiguiente()
	
	endfunc	
**********************************************************************		

	function CerrarAsistente() as Void
		thisform.Release()
	endfunc	
**********************************************************************			
	function PasoSiguiente() as Void
		
		local lcMetodo as String, lnPasoSiguiente as Integer
		
		thisform.nPaso = iif(thisform.nPaso < thisform.nTotaldePasos,thisform.nPaso + this.nIncremento, ;
			thisform.nPaso)
		if thisform.nPaso = thisform.nTotaldePasos
			thisform.CmdSiguiente.Caption = "Ace\<ptar"			
		endif	
		if thisform.nPaso > 1
			thisform.CmdAnterior.Enabled = .t.
		endif
			
		thisform.ActualizaCaption()

		lcMetodo = "Paso" + alltrim(str(thisform.nPaso))
		thisform.&lcMetodo
		
	endfunc
**********************************************************************			
	function PasoAnterior() as Void
		
		local lcMetodo as String, lnPasoAnterior as Integer
		
		thisform.nPaso = iif(thisform.nPaso > 1, thisform.nPaso - this.nIncremento, ;
			thisform.nPaso)

		if thisform.nPaso = 1
			thisform.CmdAnterior.Enabled = .f.
		else
			thisform.CmdAnterior.Enabled = .t.			
		endif
		if thisform.nPaso < thisform.nTotaldePasos
			thisform.CmdSiguiente.Caption = "\<Siguiente >>"
		endif
				
		thisform.ActualizaCaption()
		
		lcMetodo = "Paso" + alltrim(str(thisform.nPaso))
		thisform.&lcMetodo		
		
	endfunc

**********************************************************************			

Enddefine