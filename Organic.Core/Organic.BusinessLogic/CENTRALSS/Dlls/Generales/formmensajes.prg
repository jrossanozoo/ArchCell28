define class FormMensajes as zooForm of zooForm.vcx

	Desktop = .T.
	ShowWindow = 1
	WindowType = 0
	BorderStyle = 0
	ControlBox = .F.
	MinButton = .F.
	MaxButton = .F.
	Closable = .F.
	nTotalProcesos = 0
	lTieneBarraProgreso = .T.
	
	function init( toForm as Form, tlTieneBarra as Boolean ) as void
		with this
			.titlebar = 1
			.alwaysontop = .t.
			.width     = 415
			.height    = 79
			.Centrar( toForm )
			.backcolor = toForm.backcolor
			.addobject('Label1','label')
			.lTieneBarraProgreso = tlTieneBarra
			if tlTieneBarra
				.AddObject('Progreso',"olecontrol","MSComctlLib.ProgCtrl.2")
				.addobject('LblProgreso','label')
				with .Progreso
					.visible = .T.
					.height = 15
					.Width = this.width - 24
					.Min = 0
					.left = 10
					.Scrolling = 1
					.Top = This.height - .height - 20
					.zOrder(0)
				endwith
			endif
			with .Label1
				.wordwrap  = .t.
				.width     = this.width - 20
				.height    = 71
				.left      = 12
				.top       = 15
				.fontsize  = 8
				.fontname = "Tahoma"
				.visible   = .t.
*				.Alignment = 2
			endwith
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearMensaje( tcTitulo as String, tcMensaje as String ) as Void
		local lnAncho, lnLineas

		with this
			.caption = iif(!empty(tcTitulo),tcTitulo,toForm.caption)
			.Label1.caption = tcMensaje
			if .lTieneBarraProgreso 
				.ActualizarProgreso()
			endif
		endwith
	endfunc 

		*-----------------------------------------------------------------------------------------
	function SetearMaximoProgreso( tnMaximo as Integer ) as Void
		this.Progreso.max = tnMaximo
		this.nTotalProcesos = tnMaximo
	endfunc 

		
	*-----------------------------------------------------------------------------------------
	protected function ActualizarProgreso() as Void
		with this
			if .Progreso.Value + 1 > this.Progreso.max
				.SetearMaximoProgreso( .Progreso.Value + 1 )
			endif

			.Progreso.Value = .Progreso.Value + 1 
*			.Label1.caption = .Label1.caption + " ( "+ .ObtenerPorcentaje() + " )"
			.Label1.caption = .ObtenerPorcentaje() + " - " + .Label1.caption
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProgreso() as Void
		with this
			return .Progreso.Value
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Hide
		dodefault()
		this.Progreso.Value = 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentaje() as String
		local lnRetorno as Integer
		
		lnRetorno = (this.Progreso.Value * 100) / this.nTotalProcesos
		
		return ( alltrim( str( lnRetorno )) + "%" )
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function Centrar( toForm as Form ) as Void
		local lnMitadAltoForm as Integer, lnMitadAnchoForm as Integer, lnMitadAltoThis as Integer, ;
			lnMitadAnchoThis as Integer

		lnMitadAltoForm = round( toForm.Height / 2, 0)
		lnMitadAnchoForm = round( toForm.Width / 2, 0)
		lnMitadAltoThis = round( this.Height / 2, 0)
		lnMitadAnchoThis = round( this.Width / 2, 0)
		
		this.top = toForm.Top + ( lnMitadAltoForm - lnMitadAltoThis )
		this.left = toForm.left + ( lnMitadAnchoForm - lnMitadAnchoThis )
	endfunc 

enddefine