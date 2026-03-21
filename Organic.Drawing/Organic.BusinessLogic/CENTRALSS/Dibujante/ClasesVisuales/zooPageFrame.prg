define class ZooPageframe as PageFrame  

	#IF .f.
		Local this as ZooPageframe of ZooPageframe.prg
	#ENDIF

	ErasePage = .T.
	PageCount = 2
	Themes = .f.
	lEsSeteable = .T.
	nColumna = 0
	nFila = 0
	
	lAplicaEstilo = .T.
	lSePuedeOrdenar = .t.
	lSeSuperpone = .f.

	nForeColorConFoco = 0
	nBackColorConFoco = 0
	nForeColorSinFoco = 0
	nBackColorSinFoco = 0

	oItem = null
	
	dimension aEventos( 1, 4 )
	cEstado = ""

	*-----------------------------------------------------------------------------------------
	function Init( toItem as object )
		if vartype(toItem)="C" and toItem = "NO"
			return
		endif

		dodefault()
		
		with this
			.oItem = toItem
			.Armar()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function Activate() as Void
		this.refresh()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Refresh() as Void
		local loPage as Object
		
		for each loPage in this.Pages 
			loPage.refresh()
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Armar() as Void
		for each loPage in this.Pages 
			loPage.addproperty( "cEstado", "" )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Ordenar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Actualizar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstado( tcEstado as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AplicarEstilo( toEstilos as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearLuegoDeOrdenar( toAcomodadorControles as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy
		this.oItem = null
		dodefault()
	endfunc 

enddefine
