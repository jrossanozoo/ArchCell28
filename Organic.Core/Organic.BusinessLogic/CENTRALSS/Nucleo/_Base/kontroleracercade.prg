#include acercade.h

define class kontrolerAcercaDe as KontrolerFormBaseEmpresa of KontrolerFormBaseEmpresa.prg

	#if .f.
		local this as kontrolerAcercaDe of kontrolerAcercaDe.prg
	#endif

	nAnchoListaModulos = 0

	*-----------------------------------------------------------------------------------------
	function init
		dodefault()
		this.Inicializar()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Inicializar() as Void
		local lcTextoAcercaDe as string

		lcTextoAcercaDe = "" 
		with thisform
			.caption = "Acerca de " + proper( alltrim( evaluate( "_screen.zoo.app.Nombre" ) ) )
			this.ActualizarDatosSerie()
			this.ActualizarDatosDeLaVersion()
			this.ActualizarDatosVerificacionEnDosPasos()
			if file( _screen.zoo.cRutaInicial + "Licencia.txt" )
				lcTextoAcercaDe = filetostr( _screen.zoo.cRutaInicial + "Licencia.txt" )
			endif
			.edtCopyright.value = lcTextoAcercaDe
			
			this.DeshabilitarActualizarModulosSiEsDemo()
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarDatosSerie() as Void
		with thisform
			.lblSerie.caption = _screen.zoo.app.cSerie
			.lblNombre.caption = _screen.zoo.app.cNombre
			.lblOrganizacion.caption = _screen.zoo.app.cOrganizacion
	
			this.CargarModulos()
			this.ActualizarSerieEnStatusbar()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarSerieEnStatusbar() as Void
		if pemstatus( thisform, "oBarraEstado",5 ) 
			thisform.oBarraEstado.RefrescarGrupos()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarModulos() as Void
		local loModulos as collection, loModulo as object, lnPuntero as Integer
		this.VaciarModulos()
		thisform.oleTreeView.ImageList = thisform.oleImageList
		thisform.oleTreeView2.ImageList = thisform.oleImageList

        loModulos = goModulos.ObtenerModulos()
		lnPuntero = 1

		for each loModulo in loModulos
			if lnPuntero = 1
				thisform.oleTreeView.Nodes.add( ,1 , transform( loModulo.nId ) + "_", loModulo.cNombre ,iif( loModulo.lHabilitado, 1, 2 ) )
				lnPuntero = 2
			else
				thisform.oleTreeView2.Nodes.add( ,1 , transform( loModulo.nId ) + "_", loModulo.cNombre ,iif( loModulo.lHabilitado, 1, 2 ) )
				lnPuntero = 1
			endif
		endfor

		if vartype( goColaboradorModulosOnLine ) == "O"
	        for each loModulo in goColaboradorModulosOnLine.oModulos
	        	if loModulo.lMostrarAcercaDe
		            if lnPuntero = 1
		                thisform.oleTreeView.Nodes.add( ,1 , transform( loModulo.nId ) + "_", loModulo.cNombre ,iif( loModulo.lHabilitado, 1, 2 ) )
		                lnPuntero = 2
		            else
		                thisform.oleTreeView2.Nodes.add( ,1 , transform( loModulo.nId ) + "_", loModulo.cNombre ,iif( loModulo.lHabilitado, 1, 2 ) )
		                lnPuntero = 1
		            endif
		        endif
	        endfor
		endif

	endfunc

    *-----------------------------------------------------------------------------------------
    protected function VaciarModulos() as Void
        thisform.oletreeview.Nodes.Clear()
        thisform.oleTreeView2.Nodes.Clear()
    endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularAnchoDeListaDeModulos() as Void
		This.nAnchoListaModulos = thisform.oleTreeView.Nodes.Count * 17
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function AcomodarTodosLosControles() as Void
		local lnEspacio as Integer

		if goModulos.esProductoModularizado()
			lnEspacio = 30
		else 
			This.OcultarControlesDeModulos()
			This.nAnchoListaModulos = 0
			lnEspacio = -30
			ThisForm.cmdCambiarSerie.Top = ThisForm.cmdCambiarSerie.Top + lnEspacio
		endif 

		This.CalcularAnchoDeListaDeModulos()
		with thisform
			.cmdCambiarSerie.left = .width - 10 - .cmdCambiarSerie.width		
			.cmdActualizarModulos.left = .width - 10 - .cmdActualizarModulos.width
			.oleTreeView.Height = This.nAnchoListaModulos  &&.oleTreeView.Height + This.nAnchoListaModulos
			.oleTreeView2.Height = This.nAnchoListaModulos && .oleTreeView2.Height + This.nAnchoListaModulos
			.shpRecuadroModulos.Height = This.nAnchoListaModulos + 2
			.shpRecuadroModulos.Width = .Width - 20
			
			.oBotonera.Top = .oBotonera.Top + This.nAnchoListaModulos + lnEspacio
			.Height = .Height + This.nAnchoListaModulos + lnEspacio
			
			.oBarraEstado.Top = .oBarraEstado.Top + This.nAnchoListaModulos + lnEspacio
			.edtCopyright.Top = .edtCopyright.Top + This.nAnchoListaModulos + lnEspacio
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function OcultarControlesDeModulos() as Void
		with thisform
			.oleTreeView.visible = .f.
			.oleTreeView2.visible = .f.
			.shpRecuadroModulos.visible = .f.
			.lblVerMas.visible = .f.
			.lblModulos.visible = .f.
			.cmdActualizarModulos.visible = .f.
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarModulos() as Void
		if goMensajes.Preguntar( "¿Confirma la actualización de módulos?", 4, 1 ) = 6
			if this.EjecutarActualizacionDeModulo()
				if goMensajes.Preguntar( "Se actualizaron los módulos del sistema. ¿Desea salir de la aplicación para que lo cambios tomen efecto?", 4 ) = 6
					This.SalirDelSistema()
				endif 
			else
				goMensajes.Advertir( "No se pudieron actualizar los módulos. Inténtelo nuevamente." )
			endif
		endif		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SalirDelSistema() as Void
		_Screen.Zoo.App.lForzarSalida = .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarActualizacionDeModulo() as Boolean
		local lnEntradas as Integer
		lnEntradas = goServicios.Formularios.PDBRMSE( "Z" )
		
		return ( lnEntradas > 0 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		_Screen.zoo.App.lSalioDeAcercaDe = .T.
		dodefault()
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function DeshabilitarActualizarModulosSiEsDemo() as Void
		if upper( alltrim( _screen.zoo.app.cSerie )) == "DEMO"
			thisform.CmdActualizarModulos.Enabled = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDatosDeLaVersion() as Void
		local lcVersion as String
		lcVersion = _screen.zoo.app.ObtenerVersion() + " (" + _screen.zoo.app.ObtenerMesAnioDeCompilacionDeLaVersionActual() + ")"
		thisform.lblDatosDeVersion.caption = lcVersion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDatosVerificacionEnDosPasos() as Void
		local lcPasswordAdministrativa as String, loCredencialesSQLServer as Object
		lcPasswordAdministrativa = _screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.Core.BasesDeDatos.InfoUsuariosServidorSql", "ObtenerPasswordAdministrativa" )
		loCredencialesSQLServer = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.BasesDeDatos.CredencialesSqlServer", "", goServicios.Datos.oManagerConexionASQL.ObtenerNombreDelServidor(), lcPasswordAdministrativa, _screen.Zoo.App.NombreProducto )
		thisform.lblCodigoDeServidor.Caption = nvl(loCredencialesSQLServer.CodigoDeServidor,"")
	endfunc

enddefine