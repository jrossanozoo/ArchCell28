Define Class Seguridad As Servicio Of Servicio.prg
#include defmodos.h

	#if .f.
		local this as Seguridad of seguridad.prg
	#endif

*!*		#define MODO_HABILITADO		1
*!*		#define MODO_DESHABILITADO	2
*!*		#define MODO_PROTEGIDO		3
*!*		#define MODO_SEGUNPERFIL	4
*!*		#define MODO_DEFAULT		5
*!*		#define MODO_PARCIAL		6

	Protected _cUsuarioLogueado
	Protected _cLongitudMaximaUsuario
	protected _curPorPerfil
	protected _curPorUsuario

	lBlquearAdminPorSeguridadCentralizada = .f.
	
	cUsuarioLogueado = ""
	cLongitudMaximaUsuario = 100
	
	cUsuarioAdministrador = "ADMIN"
	cPerfilAdministrador  = "Administrador"
	cIdPerfilAdministrador = ""
	cIdUsuarioLogueado = ""
	lEsAdministrador = .F.
	cIdUltimoUsuarioLogueado = ""
	cUltimoUsuarioLogueado = ""
	cUsuarioValidado = ""
	cIdUsuarioValidado = ""
	nEstadoDelSistema = 2
	lUsuarioOk = .f.
	cClaveEmergencia = ""	
	cUltimaOperacion = ""
	tFechaUltimaOperacion = ctot(" ") 
	llGuardaMemoria = .f.
	lnTop = 0 
	lnLeft = 0
	lRecordarUsuario = .f.
	lUtilizarBDPreferente = .f.
	cVengoDe = ""

	oCol_Accesos = null
	cCursorOperaciones = "C_OperacionesDisp"
	cSchemaSeguridad = ""
	cSchemaFunciones = ""
	cAlltrim = ""
	cVal = ""
	cDatetime = ""
	cBaseDeDatosSeleccionada = ""

	nTiempoDeExpiracionDeAcceso = 0
	
	lEsPerfilAdministrador = .f.
	_cUsuarioLogueado = ""	
	_cLongitudMaximaUsuario = 100
	lDebeVerificarBasesDeDatosCorruptasAlIniciar = .t.
	lForzarUsuarioAdministrador = .f.
	
	oEncriptadorSHA256 = null
	
* nEstadoDelSistema = 1 -> Sistema Abierto
* nEstadoDelSistema = 2 -> Sistema Cerrado

* Modos en la coleccion de operaciones:
* 1 - Habilitado
* 2 - Deshabilitado
* 3 - Protegido por password
* 4 - Segun Perfil (no se graba, ausencia de modo en usuario signigica segun perfil)
* 5 - Modo Default (se define un default que se aplica si no se setea en lugar de deshabilitado)
* 6 - Parcial (indica en un nodo que algunos de los hijos tiene permiso)

*goRegistry.nucleo.seguridad.estadoDelSistema
*Cerrado = "_20g0sdwj1"
*Abierto = "_20g0sh7mj"

	oColAccesosUsuario = null
	cUsuarioOtorgaPermiso = ''
	lPermisoAListadoDenegado = .f. && consumido en LanzadorScriptOrganic.dll
	
	*-----------------------------------------------------------------------------------------
	function cSchemaSeguridad_access() as Void
		return iif( vartype( goDatos ) == 'O', goDatos.ObtenerSchemaSeguridad(), "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cSchemaFunciones_access() as Void
		return iif( vartype( goDatos ) == 'O', goDatos.ObtenerSchemaFunciones(), "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cAlltrim_access() as Void
		return iif( vartype( goDatos ) == 'O', goDatos.ObtenerFuncion( "Alltrim" ), "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cVal_access() as Void
		return iif( vartype( goDatos ) == 'O', goDatos.ObtenerFuncion( "Val" ), "" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cDatetime_access() as Void
		return iif( vartype( goDatos ) == 'O', goDatos.ObtenerFuncion( "Datetime" ), "" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColAccesosUsuario_Access() as Void
		if !this.ldestroy and ( !vartype( this.oColAccesosUsuario ) = 'O' or isnull( this.oColAccesosUsuario ) )
			this.oColAccesosUsuario = _screen.zoo.crearobjeto( "ZooColeccion" )
		endif
		return this.oColAccesosUsuario
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Init() As Void
		DoDefault()
		With This
			._cUsuarioLogueado = ""
			._cLongitudMaximaUsuario = 100
			.lRecordarUsuario = goParametros.Nucleo.Seguridad.RecordarUsuario
			.lUtilizarBDPreferente = goParametros.Nucleo.Seguridad.UtilizarBaseDeDatosPreferente
			.nEstadoDelSistema = .ObtenerEstadoInicialDeSeguridad()
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarColeccionDeOperaciones() as Void
		local lcXmlOper as String, loCol

		this.oCol_Accesos = _screen.zoo.crearobjeto( "ZooColeccion" )

		*** Aca se le pasa el datasession para que no queden referencias cruzadas con la coleccion y los items.
		*** No se encontro una solución mas coherente.
		
		goServicios.Estructura.ObtenerColeccionOperaciones( this.Datasessionid, ,this.oCol_Accesos )

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function cUsuarioLogueado_Access() As String
		Return This._cUsuarioLogueado
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cLongitudMaximaUsuario_Access() As Int
		Return This._cLongitudMaximaUsuario
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function cLongitudMaximaUsuario_Assign( txValue )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function cUsuarioLogueado_Assign( txValue )
		Local lcAlias As String, lcSql As String , lcXml As String
		this.nTiempoDeExpiracionDeAcceso = goRegistry.Nucleo.Seguridad.TiempoDeExpiracionDeAcceso
		
		This._cUsuarioLogueado = Alltrim( Upper( txValue ) )

		this.lEsPerfilAdministrador = .f.
		if empty( txValue )
			this.cIdUsuarioLogueado = ""
		else
			lcAlias = "Cur_" + Sys( 2015 )
			lcSql = " select Id " + ;
					" From " + this.cSchemaSeguridad + "Usuarios " + ;
					" Where " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192(" + ;
								this.cAlltrim + "( XX2 )))) = '" +  golibrerias.EscapeCaracteresSqlServer( This._cUsuarioLogueado ) + "' "
						
			goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad, lcAlias, this.datasessionId )
			
			with this as Seguridad of seguridad.prg
				.cIdUsuarioLogueado = &lcAlias..Id
				.lEsPerfilAdministrador = this.EsPerfilAdministrador( .cIdUsuarioLogueado )
				.cIdUltimoUsuarioLogueado = .cIdUsuarioLogueado
				.cUltimoUsuarioLogueado = ._cUsuarioLogueado
			endwith
			use in select( lcAlias )

			if _Screen.Zoo.App.lSeccion9 or goServicios.Ejecucion.TieneScriptCargado()
				this.CrearColeccionHabilitaMenu()
			endif
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LogIn( tcPantalla as String ) As boolean
		Local llRetorno As Boolean, lcOldSetCursor As String, llEsAdmin as Boolean, ;
			lcSucursalAnterior as String, llUsarPreferente as Boolean, loError as zooexception OF zooexception.prg, lcBaseDeDatosAVerificar as String, ;
				llEsSalidaDeAppSinHaberseLogueado as Boolean, loVerificadorDeBasesDeDatos as Object

		private lcUsuario as String

		llUsarPreferente = .f.
		llEsAdmin = this.lEsAdministrador	
		this.lEsAdministrador = .f.
		lcUsuario = ""
		_Screen.Zoo.App.lSinSucursalActiva = .F.
		lcOldSetCursor = Set( "CURSOR" )
		Set Cursor On
		try
			this.DarFocoALaAplicacion()

			lcSucursalAnterior = alltrim( upper( _screen.zoo.app.cSucursalActiva ) )

			if this.lRecordarUsuario
				if this.lUtilizarBDPreferente and !empty( goParametros.Nucleo.OrigenDeDatosPreferente ) 
					if _screen.zoo.app.VerificarExistenciaBase( goParametros.Nucleo.OrigenDeDatosPreferente )
						llUsarPreferente = .t.
						if empty( this.ValidarVersionBD( goParametros.Nucleo.OrigenDeDatosPreferente ) )
							_Screen.Zoo.App.cSucursalActiva = alltrim( goParametros.Nucleo.OrigenDeDatosPreferente )
							lcUsuario = alltrim( This.ObtenerUltimoUsuarioLogueadoParaLogin() )
						else
							llRetorno = .f.
							This.cUsuarioLogueado = ""
							lcUsuario = ""
						endif
					endif
				endif

				if vartype( goDatosDeStartupDeLaApp ) == "O" 
					goDatosDeStartupDeLaApp.Registrar( 2 )
				endif				

				if !llUsarPreferente or empty( lcUsuario )
					lcUsuario = this.PedirLogueo( "", tcPantalla )
					if vartype( goDatosDeStartupDeLaApp ) == "O" and vartype( tcPantalla ) = "L"
						goDatosDeStartupDeLaApp.lLogueoInteractivo = .t.
					endif
				else
					if vartype( goDatosDeStartupDeLaApp ) == "O" 
						goDatosDeStartupDeLaApp.Registrar( 3 )
					endif
					This.cUsuarioLogueado = lcUsuario
				endif	

			else
				if vartype( goDatosDeStartupDeLaApp ) == "O"
					goDatosDeStartupDeLaApp.Registrar( 2 )
				endif					
				lcUsuario = this.PedirLogueo( this.cUsuarioLogueado, tcPantalla )			

			endif
			if vartype( goDatosDeStartupDeLaApp ) == "O" and vartype( tcPantalla ) = "L"
				goDatosDeStartupDeLaApp.Registrar( 3 )
			endif				
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			Set Cursor &lcOldSetCursor
		endtry

		lcBaseDeDatosAVerificar = evl( this.cBaseDeDatosSeleccionada, _screen.Zoo.App.cSucursalActiva )
		llEsSalidaDeAppSinHaberseLogueado = empty( lcBaseDeDatosAVerificar )

		if !llEsSalidaDeAppSinHaberseLogueado and ;
			goServicios.MonitorSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBaseDeDatosDeNegocio( goServicios.Librerias.ObtenerNombreSucursal( upper( alltrim( lcBaseDeDatosAVerificar ) ) ) )

			llRetorno = !Empty( lcUsuario )

			if llRetorno and this.lDebeVerificarBasesDeDatosCorruptasAlIniciar and !_screen.zoo.app.lEsEntornoCloud
				loVerificadorDeBasesDeDatos = _screen.Zoo.CrearObjetoPorProducto( "VerificadorDeBasesDeDatosCorruptas", "VerificadorDeBasesDeDatosCorruptas.prg" )
				llRetorno = loVerificadorDeBasesDeDatos.Ejecutar( goServicios.Librerias.ObtenerNombreSucursal( upper( alltrim( lcBaseDeDatosAVerificar ) ) ), .t. )
			endif

			If llRetorno 
				if !empty( This.cUsuarioLogueado)
					this.RegenerarTxtUsuarios( This.cUsuarioLogueado )
				endif			
				
 				if !empty(tcPantalla) and upper( tcPantalla ) = "CAMBIARDB"
					this.lEsAdministrador = llEsAdmin
				else
					this.lEsAdministrador = this.EsPerfilAdministrador( this.cIdUsuarioLogueado )			
				endif
			endif
		else
			llRetorno = .f.
			This.cUsuarioLogueado = ""
			lcUsuario = ""
		endif	

		if llRetorno
			this.InformarSiEsBDDemo()	
		endif
	
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Logout( tcUsuario As String ) As Void
		This._cUsuarioLogueado = ""
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function PedirClave( tcId as String, tlNoPedirClave as Boolean, tcUsuariorAutorizante as String ) As Boolean
		Local loPedirClave As Object,lcIdUsuario As String, llRetorno as Boolean
		llRetorno = .t.
		This.cVengoDe = This.ArmarCaptionVengoDe( tcId )
		if tlNoPedirClave 
			lcIdUsuario = this.cUsuarioLogueado
		else
			loPedirClave = _Screen.zoo.CrearObjeto( "PedirClave" )
			lcIdUsuario = loPedirClave.PedirClave()
			this.cUsuarioOtorgaPermiso = this.cUsuariovalidado
		endif
		If Empty( lcIdUsuario )
			llRetorno = .f.
			This.AgregarInformacion( "Pedido de clave fallido." )
		else
			do case
				case lcIdUsuario = "CANCEL"
					llRetorno = .f.
					This.AgregarInformacion( "Cancelado." )
				otherwise
					llRetorno =	This.VerificarAccesoUsuario( tcId, lcIdUsuario )
					if llRetorno and type("tcUsuariorAutorizante") = "C"
						tcUsuariorAutorizante = this.cUsuariovalidado
					endif
			endcase
		Endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarCaptionVengoDe( tcId as String ) as String
		local lcRetorno as String, lcItem as String, lcDescripcion as String, lcVengoDe as String, lcRama as String, laRama as Variant, lnColInd as Integer

		dimension laRama[1]

		lcRama = alltrim( this.oCol_Accesos[ tcId ].Rama ) + '.' + alltrim( tcId )
		ALines( laRama, lcRama, 1, "." )

		lcRetorno = space(0)

		for lnColInd =  1 to alen( laRama )
			lcId = laRama[ lnColInd ]
			
			if this.oCol_Accesos.Buscar( lcId )
				lcItem = alltrim( this.oCol_Accesos[ lcId ].Item )
				lcDescripcion = alltrim( this.oCol_Accesos[ lcId ].Descripcion )

				do Case
					case !empty( lcItem ) and ;
						!empty( lcDescripcion )
						
						lcVengoDe = lcItem + ' > ' + lcDescripcion
					case !empty( lcItem ) 
						lcVengoDe = lcItem 
					case !empty( lcDescripcion )		
						lcVengoDe = lcDescripcion
					otherwise
						lcVengoDe = space(0)	
				endcase 

				lcRetorno = lcRetorno + ' > ' + lcVengoDe
			endif 	
		next i 	  

		lcRetorno = alltrim( substr(  lcRetorno, 3, len( lcRetorno ) ) )

		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObteneryAgregarAccesosPorPerfil( tcCondicionAdicional as String ) as Void
		local lcSQL as String, lcXml as String, lcCursor as String
		
		lcCursor = sys( 2015 )
		if empty( this._curPorPerfil )
			text to lcSQL textmerge noshow pretext 15 
					select 	po.idPer, po.idOpe, << this.cSchemaFunciones >>.DesencriptarModo( po.idPer, po.idOpe, po.Modo ) Modo 
					from 	<< this.cSchemaSeguridad >>perfilesusuarios pu inner join << this.cSchemaSeguridad >>perfilesoperaciones po on 
							<< this.cAlltrim >>(upper( po.Idper )) = << this.cAlltrim >>(upper( << this.cSchemaFunciones >>.DesencriptarPerfilUsuario( pu.idper, pu.idUsu, 0 )))
					where 	<< this.cSchemaFunciones >>.DesencriptarPerfilUsuario( pu.idPer, pu.IdUsu, 1 ) = '<<This.cIdUsuarioLogueado>>'
							<< tcCondicionAdicional >>
			endtext 
						
			goDatos.EjecutarSentencias( lcSql, "perfilesoperaciones.dbf, perfilesusuarios.dbf" ;
				, _Screen.Zoo.App.cRutaTablasSeguridad, lcCursor, this.DataSessionId )
		else
			tcCondicionAdicional = "1 = 1 " + strtran(tcCondicionAdicional,"funciones.")
			lcCursor2 = this._curPorPerfil
			select * from &lcCursor2 where &tcCondicionAdicional into cursor &lcCursor readwrite
		endif

		update &lcCursor set Modo = MODO_HABILITADO where Modo = MODO_PARCIAL	
		
		this.HabilitarAcceso( lcCursor )
		
		use in select( lcCursor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LlenarCursorPorPerfil() as Void
		local lcSQL as String, lcXml as String, lcCursor as String
		
			this._curPorPerfil = sys( 2015 )
			text to lcSQL textmerge noshow pretext 15 
					select 	po.idPer, po.idOpe, << this.cSchemaFunciones >>.DesencriptarModo( po.idPer, po.idOpe, po.Modo ) Modo 
					from 	<< this.cSchemaSeguridad >>perfilesusuarios pu inner join << this.cSchemaSeguridad >>perfilesoperaciones po on 
							<< this.cAlltrim >>(upper( po.Idper )) = << this.cAlltrim >>(upper( << this.cSchemaFunciones >>.DesencriptarPerfilUsuario( pu.idper, pu.idUsu, 0 )))
					where 	<< this.cSchemaFunciones >>.DesencriptarPerfilUsuario( pu.idPer, pu.IdUsu, 1 ) = '<<This.cIdUsuarioLogueado>>'
			endtext 
						
			goDatos.EjecutarSentencias( lcSql, "perfilesoperaciones.dbf, perfilesusuarios.dbf" ;
				, _Screen.Zoo.App.cRutaTablasSeguridad, this._curPorPerfil, this.DataSessionId )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarCursorPorPerfil() as Void
		use in select (this._curPorPerfil)
		this._curPorPerfil = ""
	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObteneryAgregarAccesosPorUsuario( tcCondicionAdicional as String ) as Void
		local lcSQL as String, lcXml as String, lcCursor as String
		
		lcCursor = sys( 2015 )
		if empty( this._curPorUsuario )
			text to lcSQL textmerge noshow pretext 15
				select 	uo.IdUsu, uo.idOpe, << this.cSchemaFunciones >>.DesencriptarModo( uo.idUsu, uo.idOpe, uo.Modo ) Modo
				from 	<< this.cSchemaSeguridad >>usuariosoperaciones uo inner join << this.cSchemaSeguridad >>usuarios u on << this.cAlltrim >>( uo.idUsu ) = << this.cAlltrim >>( u.id )
				where 	uo.idusu = '<<This.cIdUsuarioLogueado>>' << tcCondicionAdicional >>
			endtext 
			goDatos.EjecutarSentencias( lcSql, "usuariosOperaciones.dbf, usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
				, lcCursor, this.DataSessionId )
		else
			tcCondicionAdicional = "1 = 1 " + strtran(tcCondicionAdicional,"funciones.")
			lcCursor2 = this._curPorUsuario
			select * from &lcCursor2 where &tcCondicionAdicional into cursor &lcCursor readwrite
		endif
		
		update &lcCursor set Modo = MODO_HABILITADO where Modo = MODO_PARCIAL		
		
		this.HabilitarAcceso( lcCursor, .t. )
		
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LlenarCursorPorUsuario() as Void
		local lcSQL as String, lcXml as String, lcCursor as String
		
			this._curPorUsuario = sys( 2015 )
			text to lcSQL textmerge noshow pretext 15
				select 	uo.IdUsu, uo.idOpe, << this.cSchemaFunciones >>.DesencriptarModo( uo.idUsu, uo.idOpe, uo.Modo ) Modo
				from 	<< this.cSchemaSeguridad >>usuariosoperaciones uo inner join << this.cSchemaSeguridad >>usuarios u on << this.cAlltrim >>( uo.idUsu ) = << this.cAlltrim >>( u.id )
				where 	uo.idusu = '<<This.cIdUsuarioLogueado>>'
			endtext 
		goDatos.EjecutarSentencias( lcSql, "usuariosOperaciones.dbf, usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, this._curPorUsuario, this.DataSessionId )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarCursorPorUsuario() as Void
		use in select (this._curPorPerfil)
		this._curPorPerfil = ""
	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAccesos( tcCondicionAdicional as String ) as Void
		if vartype( tcCondicionAdicional ) != "C"
			tcCondicionAdicional = ""
		endif
		this.ObteneryAgregarAccesosPorPerfil( tcCondicionAdicional )
		this.ObteneryAgregarAccesosPorUsuario( tcCondicionAdicional )
		this.HabilitarOperacionesReservadas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarOperacionesReservadas() as Void
		local loItem as ItemAcceso of din_estructuraAdn.prg
		loItem = this.ObtenerItemSegundClave( "ME_1001" )
		if !isnull( loItem ) and inlist( upper( alltrim( loItem.iTem ) ), "SISTEMA", "ARCHIVO" )
			loItem.Modo = MODO_HABILITADO && 1
		else
			loItem = this.ObtenerItemSegundClave( "ME_1" )	
			if !isnull( loItem ) and inlist( upper( alltrim( loItem.iTem ) ), "SISTEMA", "ARCHIVO" )
				loItem.Modo = MODO_HABILITADO && 1
			endif
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemSegundClave( tcClave as String ) as ItemAcceso of din_estructuraAdn.prg
		local loItem as ItemAcceso of din_estructuraAdn.prg
		loItem = null
		if this.oCol_Accesos.Buscar( tcClave )
			loItem = this.oCol_Accesos.item[tcClave]
		endif
		return loItem
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function CrearColeccionHabilitaMenu() As Void
		local loItem as Custom, lcUsuarioLogin as String

		lcUsuarioLogin = upper( Alltrim( This._cUsuarioLogueado ) )

		if this.oColAccesosUsuario.Buscar( lcUsuarioLogin )
			this.oCol_Accesos= this.oColAccesosUsuario.Item[ lcUsuarioLogin ]
		else
			this.CargarColeccionDeOperaciones()
			If this.ElUsuarioDebeValidarSeguridad() and _screen.zoo.UsaCapaDePresentacion()
				this.ObtenerAccesos( "and (left(upper(IdOpe),3) = 'ME_' or left(upper(IdOpe),3) = 'IT_' or IdOpe like '%_VERLP_N%')" )
				this.ActualizarMenuesDeshabilitadosEnColeccionAccesos()
			endif
			if !empty( lcUsuarioLogin )
				this.oColAccesosUsuario.Agregar( this.oCol_Accesos, lcUsuarioLogin )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarMenuesDeshabilitadosEnColeccionAccesos() as Void
		local loItem as Object
		for each loItem in this.oCol_Accesos foxObject
			if inlist( upper( left( loItem.Id, 3 ) ), "ME_", "IT_" ) and empty( loItem.dtUltimoAcceso )
				loItem.dtUltimoAcceso = golibrerias.ObtenerFechaHora()
				loItem.Modo = MODO_DESHABILITADO && 2
			endif
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HabilitarAcceso( tcAlias as string, tlAccesoUsuario as Boolean ) as Void
		local lnModo as Integer, lcIdOperacion as String, lcCampoId as String, lcCursorOrdenado as String

		select ( tcAlias )
	
		lcCursorOrdenado = sys(2015)
		
		select *,this.oCol_Accesos.GetKey( alltrim( IdOpe ) ) as orden from &tcAlias. into cursor &lcCursorOrdenado. order by orden asc, modo desc readwrite
	
		select ( lcCursorOrdenado )

		scan
			try	
				lcIdOperacion = alltrim( &lcCursorOrdenado..IdOpe )
				lnModo = &lcCursorOrdenado..Modo
				
				if this.oCol_Accesos.GetKey( lcIdOperacion ) > 0
					this.oCol_Accesos[ lcIdOperacion ].dtUltimoAcceso = golibrerias.ObtenerFechaHora()
					if tlAccesoUsuario
						this.oCol_Accesos[ lcIdOperacion ].Modo = lnModo
					else
						lnModo = &lcCursorOrdenado..Modo && ModoPerfil
						this.oCol_Accesos[ lcIdOperacion ].ModoPerfil = lnModo
						if this.TieneAccesoRecursivo( this.oCol_Accesos[ lcIdOperacion ].ItemPadre )
							do case
								case this.oCol_Accesos[ lcIdOperacion ].Modo = 0
									if lnModo = MODO_PROTEGIDO && 3
										this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DEFAULT && 4
									else
										this.oCol_Accesos[ lcIdOperacion ].Modo = lnModo
									endif
								case lnModo = MODO_HABILITADO and this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DEFAULT
									this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_PROTEGIDO
								case lnModo = MODO_HABILITADO and this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DESHABILITADO
									this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_HABILITADO		
								case lnModo = MODO_PROTEGIDO and this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_HABILITADO
									this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_PROTEGIDO
								case lnModo = MODO_PROTEGIDO and this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DESHABILITADO
									this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DEFAULT
								case lnModo = MODO_DESHABILITADO and this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_HABILITADO
									this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DESHABILITADO
							endcase
						else
							this.oCol_Accesos[ lcIdOperacion ].Modo = MODO_DESHABILITADO && 2
						endif						
					endif
				endif
			catch
			endtry
		endscan
		
		use in select(lcCursorOrdenado)
		
		select ( tcAlias )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteCampoEnTabla( tcAlias as string, tcCampo as String ) as Void
		local lnPos as Integer llRetorno as Boolean 
		
		llRetorno = .T.
		
		afields( laArray, tcAlias )
		lnPos = ascan( laArray, upper( alltrim( tcCampo ) ) )

		if lnPos = 0
			llRetorno = .F.
		endif 
		
		return llRetorno	

	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function TieneAccesoRecursivo( tcId as String ) as Boolean
		local llRetorno as Boolean, lnPosPunto as Integer, lcIdPadre as String
		
		if empty( tcId ) 
			llRetorno = .t.
		else
			with this.oCol_Accesos[ tcId ]
				this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
				if .Modo = MODO_DESHABILITADO && 2
					llRetorno = .f.
				else
					if empty( .ItemPadre )
						llRetorno = ( .Modo != MODO_DESHABILITADO ) && 2 )
					else
						llRetorno = this.TieneAccesoRecursivo( .ItemPadre )
					endif
				endif
			endwith
		endif
				
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitaAccesoMenu( tcId as String ) as boolean
		local llRetorno as Boolean, lcId as String
		
		llRetorno = .t.
		if this.ElUsuarioDebeValidarSeguridad()

			lcId = this.ObtenerDependenciaDeSeguridad( tcId )
			if this.oCol_Accesos.Buscar( lcId )
				with this.oCol_Accesos[ lcId ]
					this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
					if this.oCol_Accesos[ lcId ].Modo = MODO_DESHABILITADO && 2
						llRetorno = .f.
					endif
				endwith
			endif
		endif		
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDependenciaDeSeguridad( tcId as String ) as String
		local lcId as String, lnPosicionDeGuion as Integer, lcRetorno as String

		lcRetorno = alltrim( tcId )
		lnPosicionDeGuion = Rat( "_", lcRetorno ) 
		if lnPosicionDeGuion > 0
			lcId = substr( lcRetorno, lnPosicionDeGuion + 1 )
			if inlist( lcId, "PRIMERO", "SIGUIENTE", "ULTIMO", "ANTERIOR" )
				lcRetorno = left( lcRetorno, lnPosicionDeGuion ) + "BUSCAR"
			endif
		endif
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarAccesoUsuario( tcId as String, tcIdUsuario As String ) As Boolean
		Local lcSql As String, lcXml As String, lnModo as Integer, lcAlias as String ,llRetorno as Boolean
		llRetorno = .t.
		If This.EsPerfilAdministrador( tcIdUsuario )
			this.cIdUltimoUsuarioLogueado = tcIdUsuario
		Else
			if alltrim( upper( this.cIdUsuarioLogueado ) ) == alltrim( upper( tcIdUsuario ) )
				if this.oCol_Accesos.Buscar( tcId )
					if this.oCol_Accesos[ tcId ].Modo = MODO_DESHABILITADO or this.oCol_Accesos[ tcId ].Modo = MODO_DEFAULT or (this.oCol_Accesos[ tcId ].Modo = MODO_PROTEGIDO and this._cUsuarioLogueado = this.cUsuarioOtorgaPermiso)
						llRetorno = .f.
						This.AgregarInformacion( "El usuario no tiene permitido el acceso" )
					endif
				else
					llRetorno = .f.
					This.AgregarInformacion( "Operación inexistente." )
				endif
			else
				lcSql = "select " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( idPer, idUsu, 0 ) as idPer " + ;
							"from " + this.cSchemaSeguridad + "perfilesUsuarios " + ;
							"where " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( idPer, idUsu, 1 ) = '" + alltrim( upper( tcIdUsuario ) ) + "'"
				
				goDatos.EjecutarSentencias( lcSql, "perfilesUsuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad, ;
					"c_PerfilesUsuario", this.DataSessionId )
				
				** Busca los permisos en las excepciones de usuario
				lnModo = 0
				lcSql = "select idUsu, idOpe, " + this.cSchemaFunciones + ".DesencriptarModo( idUsu, idOpe, Modo ) as Modo " + ;
						"from " + this.cSchemaSeguridad + "usuariosOperaciones " + ;
						"where " + this.cAlltrim + "( upper( idUsu ) ) = '" + alltrim( upper( tcIdUsuario ) ) + "' and " + ;
								this.cAlltrim + "( upper( idOpe ) ) = '" + alltrim( upper( tcId ) ) + "'" 
				
				goDatos.EjecutarSentencias( lcSql, "usuariosOperaciones.dbf",  _Screen.Zoo.App.cRutaTablasSeguridad ;
					, "c_UsuariosOperaciones", this.DataSessionId )
				
				if reccount( "c_UsuariosOperaciones" ) > 0
					lnModo = c_UsuariosOperaciones.Modo
				endif
	
				** Busca los permisos en los perfiles del usuario
				if lnModo = 0 or lnModo = MODO_PROTEGIDO && 3
					select c_PerfilesUsuario
					scan while lnModo != MODO_HABILITADO && 1
						lcSql = "select idPer, idOpe, " + this.cSchemaFunciones + ".DesencriptarModo( idPer, idOpe, Modo ) as Modo " + ;
									"from " + this.cSchemaSeguridad + "perfilesOperaciones " + ;
									"where " + this.cAlltrim + "( upper( idPer ) ) = '" + alltrim( upper( c_PerfilesUsuario.idPer ) ) + "' and " + ;
											this.cAlltrim + "( upper( idOpe ) ) = '" + alltrim( upper( tcId ) ) + "' and " + ;
											this.cSchemaFunciones + ".DesencriptarModo( idPer, idOpe, modo ) = "+alltrim(str(MODO_HABILITADO)) && 1"
											
						goDatos.EjecutarSentencias( lcSql, "perfilesOperaciones.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
							, "c_PerfilesOperaciones", this.DataSessionId )
						
						if reccount( "c_PerfilesOperaciones" ) > 0
							lnModo = MODO_HABILITADO && 1
						endif
					endscan
				endif
								
				*********************
				&& Chequeo Luego que se consulte las tablas de seguridad
				if lnModo=0 and this.oCol_ACCESOS[ tcid ].Modo = MODO_HABILITADO && 1 && Habilitado por defecto
					lnModo = MODO_HABILITADO && 1
				endif
				*********************
				
				if lnModo != MODO_HABILITADO && 1
					llRetorno = .f.
					This.AgregarInformacion( "El usuario no tiene permitido el acceso" )
				endif
				
				use in select( "c_PerfilesUsuario" )
				use in select( "c_PerfilesOperaciones" )
				use in select( "c_UsuariosOperaciones" )				
			endif
		Endif

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarPerfilUsuario( tcIdPerfil as String, tcIdUsuario as String ) as Boolean
		local lcSql as string, lcXml as String
	
		lcSql = "Select 1 as cantidad " + ;
					"from " + this.cSchemaSeguridad + "PerfilesUsuarios " + ;
					"where " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( idPer, idUsu, 0 ) = '" + ;
						alltrim( Upper( tcIdPerfil ) ) + "' and " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( idPer, idUsu, 1 ) = '" + ;
						alltrim( Upper( tcIdUsuario ) ) + "'"
		
		goDatos.EjecutarSentencias( lcSql, "PerfilesUsuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, "c_PerfilesUsuarios", this.DataSessionId )

		If c_PerfilesUsuarios.cantidad = 0
			llRetorno = .f.
		else
			llRetorno = .t.
		Endif
		
		use in select( "c_PerfilesUsuarios" )
	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function VerificarExistenciaUsuario( tcUsuario as String ) As String
		Local lcSql As String, lcXml As String, lcRetorno as String

		lcSql = "Select id, 1 as cantidad " + ;
					"from " + this.cSchemaSeguridad + "usuarios " + ;
					"where " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ) ) ) ) = '" + golibrerias.EscapeCaracteresSqlServer( tcUsuario ) + "'"

		godatos.EjecutarSentencias( lcSql, "usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, "c_Usuarios", this.DataSessionId )

		If c_usuarios.cantidad = 0
			lcRetorno = ""
		Else
			lcRetorno = c_usuarios.id
		Endif

		Use In select( "c_Usuarios" )

		return lcRetorno
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function VerificarExistenciaPerfilAdm() As Boolean
		Local lcSql As String, lcXml As String, llRetorno as Boolean

	&& Verificar existencia de Perfil ADMINISTRADORES
		lcSql = "Select id, 1 as cantidad " + ;
					"from " + this.cSchemaSeguridad + "Perfiles " + ; 
					"where " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX1 ) ) ) ) " + ;
							" = '" + alltrim( Upper( This.cPerfilAdministrador ) ) + "'"

		godatos.EjecutarSentencias( lcSql, "perfiles.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, "c_Perfiles", this.DataSessionId )

		If c_Perfiles.cantidad = 0
			llRetorno = .f.
		Else
			llRetorno = .t.
		Endif
		
		use in select( "c_Perfiles" )

		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LanzarPantalla( tcPantalla As String, tlSinConfirmaciones as Boolean ) As Void
		local lnResultado as integer		
		Do Case
			
			Case Upper( tcPantalla ) = "LOGOUT"
				if empty( this.cIdUsuarioLogueado )
					goMensajes.enviar("Ningún usuario ha iniciado sesión.",0,3)
				else
					if tlSinConfirmaciones
						lnResultado = 6
 					else
 						lnResultado = goMensajes.enviar("¿Confirma que desea cerrar la sesión?",4,1,1)
 					endif
					
					if lnResultado = 6 
						if this.cerrarVentanas()
							this.cVengoDe="" 
							This.ContinuarConLogOut( tcPantalla, .t. )
						endif						
					endif
					
					goServicios.Terminal.Logout()
				endif

			case upper( tcPantalla ) = "CAMBIARDB"		
				if this.cerrarVentanas()
					This.ContinuarConLogOut( tcPantalla )
				endif		
			Otherwise
				Local lcEstilo As String, lcFormulario As String
				lcEstilo = "Windows"
				lcFormulario = tcPantalla + "_" + lcEstilo
				Set Deleted On
				goFormularios.mostrarscx(lcFormulario, .t.)
		Endcase

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ContinuarConLogOut( tcPantalla as String, tlLogOut as Boolean ) as Void
		local lcSucursalAnterior as String

		with _screen.zoo.app
			goParametros.Nucleo.Seguridad.RecordarUsuario = .f.
			this.lRecordarUsuario = goParametros.Nucleo.Seguridad.RecordarUsuario
			.SetearEstadoMenuPrincipal( .F. ) 
			
			if tlLogOut
				if this.oColAccesosUsuario.Buscar( this.cUsuarioLogueado )
					this.oColAccesosUsuario.Remove( this.cUsuarioLogueado )
				endif
				goServicios.PoolDeObjetos.Liberar()
				goServicios.RegistroDeActividad.Detener()
				goServicios.SaltosDeCampoYValoresSugeridos.Detener()
				goServicios.Ejecucion.CerrarInstanciasDeAplicacion( .T. )
				This.OcultarFormPrincipal()
			endif

			lcSucursalAnterior = _screen.zoo.app.cSucursalActiva
			llLoginOK = this.Login( tcPantalla )
			
			_screen.zoo.app.cSucursalActiva = this.cBaseDeDatosSeleccionada 
			.SetearEstadoMenuPrincipal( .T. )
			If llLoginOK
				if tlLogout
					.IniciarMenuPrincipal()
					This.RestaurarFormPrincipal()
					goServicios.Ejecucion.IniciarNuevaInstanciaDeAplicacion()
				else
					.ActualizarBarraDeEstado()
				endif
				local loCreadorAccesoDirectos as Object
				goMensajes.EnviarSinEspera( "Configurando listados..." )
				loCreadorAccesoDirectos = _screen.zoo.crearobjeto( "CreadorAccesosDirectosListados" ) 
				loCreadorAccesoDirectos.Crear()
				goMensajes.EnviarSinEspera( )
			else
				if tlLogOut
					.Salir()
				endif 
			Endif
		endwith  
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function OcultarFormPrincipal() as Void

		with _screen.zoo.app.oformprincipal
			This.llGuardaMemoria = .lGuardaMemoria
			This.lnTop = .top
			This.lnLeft = .left
			.lGuardaMemoria = .F.
			.top = -32768
			.left = -32768

		endwith		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function RestaurarFormPrincipal() as Void

		with _screen.zoo.app.oformprincipal
			.top = This.lnTop
			.left = This.lnLeft


			.lGuardaMemoria = This.llGuardaMemoria
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function EsAdministrador( tcIdUsuario As String ) As Boolean
		Local llRetorno As Boolean, lcSql As String, lcAlias As String, lcXml As String
		llRetorno = .F.
		lcSql = " select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Usuario" ) + ;
			" From " + this.cSchemaSeguridad + "Usuarios " + ;
			" Where " + this.cAlltrim + "( upper( Id ) ) = '" +  Alltrim( Upper( tcIdUsuario ) ) + "'"

		lcAlias = "Cur_" + Sys( 2015 )
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )
		
		llRetorno = ( Alltrim( Upper( &lcAlias..Usuario ) ) == Alltrim( Upper( This.cUsuarioAdministrador ) ) )
		use in select( lcAlias )

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function PedirAccesoMenu( tcId as String, tlNoPedirClave as Boolean, tcUsuariorAutorizante as String ) As Boolean
		Local llRetorno as Boolean, lcItemPadre as string
		llRetorno = .t.
		if this.ElUsuarioDebeValidarSeguridad()
			tcId = alltrim( tcId )
			if this.oCol_Accesos.Buscar( tcId )
				loAcceso = this.oCol_Accesos[ tcId ]
				if this.VerificarAccesoItemPadre( tcId )
					with this.oCol_Accesos[ tcId ]
						this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
						lnModo = .Modo	
					endwith
				else
					lnModo = MODO_DESHABILITADO && 2
				endif
				llRetorno = this.DeterminarAcceso( tcId, lnModo, tlNoPedirClave, @tcUsuariorAutorizante )

			endif
		endif
		
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function HabilitarParaModificar( tcId as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		
		if this.oCol_Accesos.Buscar( tcId )
			with this.oCol_Accesos[ tcId ]
				llRetorno = inList( .Modo, MODO_PROTEGIDO, MODO_DEFAULT ) && 3 , 4 )
			endwith
		endif	

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DeterminarAcceso( tcId as String, tnModo as Integer, tlNoPedirClave as Boolean, tcUsuariorAutorizante as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		do case
			case inlist( tnModo , 0, MODO_DESHABILITADO ) && 2 ) && Deshabilitado
				llRetorno = .f.
				This.AgregarInformacion( "El usuario no tiene permitido el acceso." )

			case inlist( tnModo, MODO_PROTEGIDO, MODO_DEFAULT ) && 3, 4 ) && Protegido por password
				llRetorno = This.PedirClave( tcId, tlNoPedirClave, @tcUsuariorAutorizante )
		endcase

		if llRetorno and !tcId = 'TICKETFACTURA_REIMPRIMIRTICKET'
			this.LoguearAccesosMenu( tcId )
		endif	
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	 Function PedirAccesoEntidad( tcEntidad As String, tcMetodo As String, tlSinPantalla As Boolean, tcDescripcionEntidad as String, tcUsuariorAutorizante as String ) As boolean
		local llRetorno as Boolean
		llRetorno = .t.
		if empty( tlSinPantalla )
			tlSinPantalla = !_screen.zoo.UsaCapaDePresentacion()
		endif
		
		if empty( tcDescripcionEntidad )
			tcDescripcionEntidad = space(0)
		endif 	

		This.LimpiarInformacion()
		if this.PedirAccesoMenu( alltrim( upper( tcEntidad ) ) + "_" + alltrim( upper( tcMetodo ) ), tlSinPantalla, @tcUsuariorAutorizante )
		else
			llRetorno = .f.
		endif

		if llRetorno and this.SeDebeLoguear()
			this.LoguearAccesosEntidad( tcEntidad, tcMetodo, tcDescripcionEntidad )
 		endif
 	
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AlternarModoDeSeguridad() As Void
		if This.nEstadoDelSistema <> 1
			Local loPedirClave As Object, lcIdUsuario As String
			
			loPedirClave = _Screen.zoo.CrearObjeto( "PedirClave" )
			lcIdUsuario = loPedirClave.PedirClave()

			if empty( lcIdUsuario ) 			
					goMensajes.Advertir( "No se pudo cambiar el estado del sistema. Seguridad " + ;
						Iif( This.nEstadoDelSistema = 1, "desactivada.", "activada."), 0, 0, "Información del Sistema" )			
			else				
				if lcIdUsuario = "CANCEL"
				else			
					If This.EsPerfilAdministrador( lcIdUsuario )
						goMensajes.EnviarSinEspera( "Desactivando seguridad del sistema." )
						This.AbrirSistema()

						_Screen.zoo.App.IniciarMenuPrincipal()
						
						goMensajes.EnviarSinEspera()

					Else
						goMensajes.Advertir("No se pudo cambiar el estado del sistema. Seguridad " + ;
							Iif( This.nEstadoDelSistema = 1, "desactivada.", "activada."), 0, 0, "Información del Sistema" )
					endif
				endif	
			endif
		else
			If This.nEstadoDelSistema = 1
				goMensajes.EnviarSinEspera( "Activando seguridad del sistema." )
				This.CerrarSistema()
				_Screen.zoo.App.IniciarMenuPrincipal()		
				goMensajes.EnviarSinEspera()
			endif
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarSistema() as Void
		local lcSql as String

		This.nEstadoDelSistema = 2
		goRegistry.nucleo.seguridad.estadoDelSistema = "_20g0sdwj1"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirSistema() as Void
		local lcSql as String
		
		This.nEstadoDelSistema = 1
		goRegistry.nucleo.seguridad.estadoDelSistema = "_20g0sh7mj"
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoInicialDeSeguridad() As Integer
		local lnEstadoInicial as Integer, llSistemaAbierto as Boolean
		
		llSistemaAbierto = this.ElSistemaEstaAbierto()
		lnEstadoInicial = 2

		if goParametros.Nucleo.Seguridad.ActivarLaSeguridadAlSalir and llSistemaAbierto
			this.CerrarSistema()
		else
			if llSistemaAbierto
				lnEstadoInicial = 1
			endif
		endif

		Return lnEstadoInicial
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ElSistemaEstaAbierto() as Boolean
		local llRetorno as Boolean, lcEstadoRegistry as String, lcEstadoReporte as String
		
		lcEstadoRegistry = alltrim( goRegistry.nucleo.seguridad.estadoDelSistema )

		llRetorno = ( lcEstadoRegistry = "_20g0sh7mj" )  && Sistema Abierto
		
		use in select( "c_Reporte" )
		
		return llRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoDeSeguridad() As Void

		Local lcEstado As String
		lcEstado = Iif( This.nEstadoDelSistema = 1, "ABIERTO", "CERRADO" )

		Return lcEstado

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EsPerfilAdministrador( tcIdUsuario ) As Boolean
		Local llRetorno As Boolean, lcIdPerfilAdministrador as string
		
		llRetorno = .f.
		
		if !empty( tcIdUsuario )
			lcSql = " select " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( idPer, 0 ) idPer from " + this.cSchemaSeguridad + "PerfilesUsuarios where " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( idUsu, 1 ) = '" + tcIdUsuario + "'"
			goDatos.EjecutarSentencias( lcSql, "PerfilesUsuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
				, "c_PerfilesUsuarios", this.DataSessionId )

			lcSql = " select id from " + this.cSchemaSeguridad + "Perfiles where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX1 ) ) ) = '" + upper( this.cPerfilAdministrador ) + "'"
			goDatos.EjecutarSentencias( lcSql, "Perfiles.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
				, "c_Perfiles", this.DataSessionId )

			lcIdPerfilAdministrador = c_Perfiles.id
			select c_PerfilesUsuarios
			locate for idPer = lcIdPerfilAdministrador
			if found()
				llRetorno = .t.
			else
				llRetorno = this.EsAdministrador( tcIdUsuario )
			endif
			
			use in select( "c_PerfilesUsuarios" )
			use in select( "c_Perfiles" )
		endif
		
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TienePerfil( tcUsuario As String ) as Boolean
		local lcSql As String, lcXml As String, llTienePerfil As Boolean, lcAlias As String, lcIdUsuario As String, lcAlias2 As String
		
		
		lcAlias = "Cur_" + Sys( 2015 )
		lcAlias2 = "Cur_" + Sys( 2015 )

		lcSql = "Select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "*clavedesencriptada" ) + ;
			" From " + this.cSchemaSeguridad + "Usuarios Where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ) ) ) = '" + golibrerias.EscapeCaracteresSqlServer( alltrim( upper( tcUsuario) ) ) + "'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		lcIdUsuario = alltrim( upper( &lcAlias..Id ) )

		lcSql = "Select 1 from " + this.cSchemaSeguridad + "PerfilesUsuarios  a inner join " + this.cSchemaSeguridad + ;
				"Perfiles b on " + this.cAlltrim + "( upper( b.Id ) ) = " + this.cSchemaFunciones + ;
				".DesencriptarPerfilUsuario( a.idPer, a.idUsu, 0 ) Where " + ;
				this.cAlltrim + "( " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( a.IdUsu, 1 )) = '" + lcIdUsuario + "'"

		goDatos.EjecutarSentencias( lcSql, "PerfilesUsuarios.dbf,Perfiles.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias2, this.DataSessionId )

		llTienePerfil = ( reccount( lcAlias2 ) > 0 )
		
		Use In Select( lcAlias )
		Use In Select( lcAlias2 )

		return llTienePerfil
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPerfiles( tcUsuario As String ) as Object
		local lcSql As String, lcXml As String, llTienePerfil As Boolean, lcAlias As String, lcIdUsuario As String, lcAlias2 As String
		
		loColPerfiles = null
		lcAlias = "Cur_" + Sys( 2015 )
		lcAlias2 = "Cur_" + Sys( 2015 )

		lcSql = "Select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "*clavedesencriptada" ) + ;
			" From " + this.cSchemaSeguridad + "Usuarios Where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ) ) ) = '" + golibrerias.EscapeCaracteresSqlServer( alltrim( upper( tcUsuario) ) ) + "'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		lcIdUsuario = alltrim( upper( &lcAlias..Id ) )

		lcSql = "Select " + goLibrerias.obtenercamposseguridadperfiles( "*clavedesencriptada" ) + " from " +  ;
				this.cSchemaSeguridad + "PerfilesUsuarios  a inner join " + this.cSchemaSeguridad + ;
				"Perfiles b on " + this.cAlltrim + "( upper( b.Id ) ) = " + this.cSchemaFunciones + ;
				".DesencriptarPerfilUsuario( a.idPer, a.idUsu, 0 ) Where " + ;
				this.cAlltrim + "( " + this.cSchemaFunciones + ".ExtraerPerfilUsuario( a.IdUsu, 1 )) = '" + lcIdUsuario + "'"

		goDatos.EjecutarSentencias( lcSql, "PerfilesUsuarios.dbf,Perfiles.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias2, this.DataSessionId )

		if reccount( lcAlias2 ) > 0 
			loColPerfiles = _screen.zoo.crearobjeto( "zoocoleccion" )
			scan
				loColPerfiles.add( alltrim( &lcAlias2..Nombre ) )
			endscan
		endif
		
		Use In Select( lcAlias )
		Use In Select( lcAlias2 )

		return loColPerfiles
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function cerrarVentanas() as Boolean 
		local llReturn as Boolean 
		llReturn = .T.
		
		if pemstatus(_screen.zoo.app, "oFormPrincipal", 5) ;
		 and ( vartype( _screen.zoo.app.oformprincipal ) = 'O' )

			llReturn = _screen.zoo.app.oformprincipal.CerrarSubFormularios( .t. )
			
		endif 
		
		return llReturn 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RegenerarTxtUsuarios( tcUsuarioLogueado ) as Void
		
		local lcUsuarios as String, lnUsuarios as Integer, lnUsuariosTxt as Integer, lcNuevosUsuarios as String, ;
			i as Integer, lnNuevosUsuarios as Integer, lcUsuario as String	
		local lcSql as String	
		lcSql = "Select " + golibrerias.ObtenerCamposSeguridadUsuarios( "*clavedesencriptada" ) + " From Seguridad.Usuarios Order By Usuario"
		goServicios.Datos.EjecutarSentencias( lcSQL, "usuarios",, "Seguridad",set("Datasession" ) )

		lcNuevosUsuarios = goLibrerias.Encriptar192( alltrim( tcUsuarioLogueado ) ) + chr(13) + chr(10)
		if file( addbs( _screen.zoo.cRutaInicial ) + "Usuarios.txt" )
			lcUsuarios = filetostr( _screen.zoo.cRutaInicial + "Usuarios.txt" )

			lnUsuarios = alines( Usuarios, lcUsuarios, chr(13) + chr(10) )
			lnUsuariosTxt = goParametros.Nucleo.Seguridad.NumeroDeUsuariosMostradosEnLogin
			
			lnNuevosUsuarios = 1
			for i = 1 to lnUsuarios
				lcUsuario = upper( alltrim( transform( goLibrerias.Desencriptar192( Usuarios[ i ] ) ) ) )
				select Seguridad
				locate for upper( alltrim( usuario ) ) == lcUsuario
				if found()
					if alltrim( upper( lcUsuario ) ) != alltrim( upper( tcUsuarioLogueado ) ) and ;
						 	lnNuevosUsuarios < lnUsuariosTxt
						lcNuevosUsuarios = lcNuevosUsuarios +  goLibrerias.Encriptar192( alltrim( lcUsuario ) )  + chr(13) + chr(10)
						lnNuevosUsuarios = lnNuevosUsuarios + 1					
					endif	
				endif
			endfor			
		endif		
		strtofile( lcNuevosUsuarios, addbs( _screen.zoo.cRutaInicial ) + "Usuarios.txt" )		
		use in select( "Seguridad" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoUsuarioLogueado() as String
		local lcRetorno as String 

		lcRetorno = this.cUltimoUsuarioLogueado
		if vartype( lcRetorno ) != "C"
			lcRetorno  = transform( lcRetorno  )
		endif

		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function LoguearAccesosMenu( tcId as String ) as Void

		local lcRutaMenu as String, lcEntidad as String, lcMetodo as String, lcNodoPadre as String, lcNodoHijo  as String,;
		lcEstado as String, lcSerie as String, lcNombrePC  as String, lcUsuarioPC  as String, lcTipo  as String, lcSql as String, lcRama as String,;
	    lnCantRama as Integer, lcXml as String, lcRutaMenu as String, x as Integer, lnCantReg as Integer, ltTime as string, loItem as Object, i as Integer

		loItem = this.oCol_Accesos[ tcId ]
		lcRama = alltrim( loItem.Rama )
		tcNodoPadre = this.oCol_Accesos[ alltrim( loItem.ItemPadre ) ].Item
		tcNodoHijo = alltrim( loItem.Item )
		lcRutaMenu = ""
		for i = getwordcount( lcRama, "." ) to 1 step -1
			if this.oCol_Accesos.GetKey( alltrim( getwordnum( lcRama, i, "." ))) > 0
				loItem = this.oCol_Accesos[ alltrim( getwordnum( lcRama, i, "." )) ]
				
				if i = 1
					lcRutaMenu = alltrim( this.oCol_Accesos[ alltrim( getwordnum( lcRama, i, "." )) ].Item )
				else
					lcRutaMenu = " - " + alltrim( this.oCol_Accesos[ alltrim( getwordnum( lcRama, i, "." )) ].Item )
				endif
			endif
		endfor
		
		lcRutaMenu = lcRutaMenu + " - " + tcNodoHijo
		lcEntidad = ""
		lcMetodo = ""
		lcNodoPadre = alltrim( strtran( tcNodoPadre, "\<", "" ) )
		lcNodoHijo = alltrim( strtran( tcNodoHijo, "\<", "" ) )	
		lcEstado = Iif( This.nEstadoDelSistema = 1, "ABIERTO", "CERRADO")
		lcSerie = _screen.zoo.App.cSerie
		lcNombrePC = alltrim( goServicios.Librerias.ObtenerNombrePuesto() )
		lcUsuarioPC = alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() )
		lcTipo = "MENU"
		ltTime = time()

		This.LoguearAccesos( lcTipo, lcMetodo, lcNodoPadre, lcNodoHijo )

		lcSql = This.ArmarSenteciaInsert( lcTipo, lcEntidad, lcMetodo, lcEstado, lcSerie, lcNodoPadre, lcNodoHijo, lcNombrePC, lcUsuarioPC, ltTime )

		goDatos.EjecutarSentencias( lcSql, "LogueoAccesos.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )

		this.cUltimaOperacion = lcRutaMenu
		
		this.tFechaUltimaOperacion = golibrerias.ObtenerFechaHora()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LoguearAccesos( tcTipo as string, tcMetodo as String, tcNodoPadre as String, tcNodoHijo as String, tcDescripcionEntidad as String ) as Void

		local lcStringLog as String  

		lcStringLog = space( 0 )
		
		If empty( tcDescripcionEntidad )
			tcDescripcionEntidad = space( 0 )
		endif 
			
		lcStringLog = ' SEGURIDAD, '

		if alltrim( upper( tcTipo ) ) == 'MENU'
			lcStringLog = lcStringLog + alltrim( proper( tcTipo ) ) + ' -> '
			lcStringLog = lcStringLog + iif( empty( tcNodoPadre ), '...', alltrim( proper( tcNodoPadre ) ) ) + ' -> '			
			lcStringLog = lcStringLog + iif( empty( tcNodoHijo ), '...', alltrim( proper( tcNodoHijo ) ) ) 		
		else
			if 'Reimprimir ticket de cambio -> ' $ tcDescripcionEntidad  
				lcStringLog = lcStringLog + tcDescripcionEntidad 
			else
				lcStringLog = lcStringLog + iif( empty( tcDescripcionEntidad ), '...', alltrim( proper( tcDescripcionEntidad ) ) ) + ' -> '
				lcStringLog = lcStringLog + iif( empty( tcMetodo ), '...', alltrim( proper( tcMetodo ) ) ) 
			endif
		endif 
		
		if right( alltrim( lcStringLog ), 3 ) == '...' 
			lcStringLog = substr( lcStringLog, 1, len(lcStringLog) - 7 )
		endif  	

		this.loguear( lcStringLog )	
		this.FinalizarLogueo()	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarSenteciaInsert( tcTipo as string, tcEntidad as String, tcMetodo as String, tcEstado as String, tcSerie as String,;
								  tcNodoPadre as String, tcNodoHijo as String, tcNombrePC as String, tcUsuarioPC as String, ttTime as String ) as string
	
		local lcAccion as String, lcSql as String, lcTabla as String, lcDate as String
	
		lcSql = space(0)

		if goDatos.EsSqlServer()
			lcTabla = 'Seguridad.LogueoAccesos'
			lcDate = "'" + dtos( date() ) + "'" 
			
			tcUsuarioPC = goServicios.Librerias.EscapeCaracteresSQLServer( tcUsuarioPC )
			tcNombrePC = goServicios.Librerias.EscapeCaracteresSQLServer( tcNombrePC )
		
		else
			lcTabla = 'LogueoAccesos'
			lcDate = "{" + dtoc( date() ) +"}"
		endif 

		lcSql = "Insert into " + lcTabla + " ( entidad,accion,tipo,usuario,basedatos,fecha,hora,estado,serie,nodopadre,nodohijo,nombrepc,usuariopc ) " + ;
				" values ('" + tcEntidad + "','" + 	tcMetodo + "','" + tcTipo + "','" + goServicios.Librerias.EscapeCaracteresSQLServer( this.cUsuarioLogueado ) + ;
				"','" + alltrim( _screen.zoo.App.cSucursalActiva )+ "'," + lcDate + ",'" + ttTime + "','" + tcEstado + "','" + tcSerie + ;
				"','" + tcNodoPadre + "','" + tcNodoHijo + "','" + tcNombrePC + "','" + tcUsuarioPC +  "')"

		return lcSql 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LoguearAccesosEntidad( tcEntidad As String, tcMetodo As String, tcDescripcionEntidad as String ) as Void

		local lcEstado as String, lcSerie as String, lcEntidad as String, lcMetodo as String, lcNodoPadre as String, lcNodoHijo as String, ;
			lcNombrePC as String, lcUsuarioPC as String, lcTipo as String, ltTime as string

		lcEntidad = alltrim( tcEntidad )
		lcMetodo = alltrim( tcMetodo )
		lcNodoPadre = ""
		lcNodoHijo = ""
		lcEstado = Iif( This.nEstadoDelSistema = 1, "ABIERTO", "CERRADO")
		lcSerie = _screen.zoo.App.cSerie
		lcNombrePC = alltrim( goServicios.Librerias.ObtenerNombrePuesto() )
		lcUsuarioPC = alltrim( goServicios.Librerias.ObtenerNombreUsuarioSO() )
		lcTipo = "ENTIDAD"
		ltTime = time()

		This.LoguearAccesos( lcTipo, lcMetodo, lcNodoPadre, lcNodoHijo, tcDescripcionEntidad )

		lcSql = This.ArmarSenteciaInsert( lcTipo, lcEntidad, lcMetodo, lcEstado, lcSerie, lcNodoPadre, lcNodoHijo, lcNombrePC, lcUsuarioPC, ltTime )

		goDatos.EjecutarSentencias( lcSql, "LogueoAccesos.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )

		this.cUltimaOperacion = proper( alltrim( lcEntidad ) ) + " - " + proper( alltrim( lcMetodo ) )
		this.tFechaUltimaOperacion = golibrerias.ObtenerFechaHora()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarUsuarioYClave( tcUsuario as String, tcClave as String, tlValidaClave as Boolean ) As Boolean
		Local lcAlias As String, lcSql As String, lcXml as String, lcClave as String, lcClaveDesencriptada as String,;
				llRetorno as Boolean, lcTiempoDeEspera as String, lcUsuarios as string, lcUsu as string
		llRetorno = .t.
		lcSql = ""
		lcClaveDesencriptada = ""
		lcAlias = "Cur_" + Sys( 2015 )
		If Empty( tcUsuario )
			llRetorno = .f.
			This.AgregarInformacion( "Falta ingresar usuario." )
		else
			lcSql = " select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Id, Usuario, UsuarioAd, Clavedesencriptada, bloqueado, fechabloq, BloqAdm" ) + ;
				" From " + this.cSchemaSeguridad + "Usuarios " + ;
				" Where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ) ) ) = '" +  golibrerias.EscapeCaracteresSqlServer( alltrim( Upper( tcUsuario ) ) ) + "' "

			goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
				, lcAlias, this.DataSessionId )

			If Reccount( lcAlias ) = 0
				llRetorno = .f.
				This.AgregarInformacion( "Usuario inexistente." )
			else

				if ( this.lBlquearAdminPorSeguridadCentralizada and tcUsuario == this.cUsuarioAdministrador )
					loMainUsers = this.ObtenerMainUsersDeZnube()
					if ( loMainUsers.Count > 0 )
						llRetorno = .f.
						
						lcUsuarios = ""
						
						for each lcUsu in loMainUsers foxobject
							lcUsuarios = lcUsuarios + chr(13) + chr(10) + alltrim( lcUsu )
						endfor

						This.AgregarInformacion( "No se puede utilizar el usuario " + this.cUsuarioAdministrador + " si está usando la seguridad centralizada. " + ;
								"Para loguearse como administrador debe utilizar alguno de los siguientes usuarios." + chr(13) + chr(10) + ;
								lcUsuarios )	
					endif
				endif

				if llRetorno
					if &lcAlias..BloqAdm
						llRetorno = .f.
						This.AgregarInformacion( "Usuario bloqueado por Administrador." )	
					else	
						if &lcAlias..Bloqueado

							if this.DesbloqueoAutomatico( tcUsuario, tcClave )
							else
								llRetorno = .f.
								lcTiempoDeEspera  = this.ObtenerTiempoDesbloqueo( &lcAlias..Id )
								This.AgregarInformacion( "Usuario bloqueado temporalmente. Espere" + lcTiempoDeEspera + " para reintentar el ingreso." )								
							endif	
						endif					
					endif	
				endif
			endif
		endif

		this.lUsuarioOk = .f.
		if llRetorno
			llRetorno = This.ValidarClave( tlValidaClave, tcClave, tcUsuario, lcAlias ) 
		endif 

		if llRetorno
			this.cUsuarioValidado = tcUsuario
			this.cIdUsuarioValidado = &lcAlias..id
			
			this.ActualizarCantidadBloqueos( &lcAlias..id, 0 ) 
			
		else
			this.cUsuarioValidado = ""
			this.cIdUsuarioValidado = ""
		endif	
	
		use in select( lcAlias )		
		
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oEncriptadorSHA256_Access() as Void
		if !this.ldestroy and ( !vartype( this.oEncriptadorSHA256 ) = 'O' or isnull( this.oEncriptadorSHA256 ) )
			this.oEncriptadorSHA256 = _screen.dotnetbridge.crearobjeto("ZooLogicSA.Core.EncriptadorSHA256")
		endif
		return this.oEncriptadorSHA256
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarUsuarioYClaveHasheada( tcUsuario as String, tcClaveHasheada as String, tcSecret as String, tcAlternativa as String, tlRequerirDobleHash as Boolean ) as Void
		local lcClaveSHA256 as String, lcPassAlmacenado as String, llCoincidenciaDeHash as Boolean
		
		lcPassAlmacenado = this.ObtenerPass( tcUsuario )
		
		llCoincidenciaDeHash = .f.

		llCoincidenciaDeHash = this.TestearClaveHasheadaMismoCase( tcClaveHasheada, lcPassAlmacenado, tcSecret, tcAlternativa, tlRequerirDobleHash  )
		
		if this.EsUsuarioNoCreadoEnOrganic( tcUsuario ) && solo el de zNube puede estar almacenado en mixed case
			if !llCoincidenciaDeHash
				llCoincidenciaDeHash = this.TestearClaveHasheadaUpperCase( tcClaveHasheada, lcPassAlmacenado, tcSecret, tcAlternativa, tlRequerirDobleHash  )
			endif
		endif

		if !llCoincidenciaDeHash
			llCoincidenciaDeHash = this.TestearClaveHasheadaLowerCase( tcClaveHasheada, lcPassAlmacenado, tcSecret, tcAlternativa, tlRequerirDobleHash  )
		endif
				
		return llCoincidenciaDeHash and this.ValidarUsuarioYClave( tcUsuario, lcPassAlmacenado, .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TestearClaveHasheadaMismoCase( tcHashOrigen as String, tcPassAlmacenado as String, tcSecret as String, tcAlternativa as String, tlForzarDoble as Boolean ) as Void
		local llCoincidenciaDeHash as Boolean

		lcPassHasheado = this.oEncriptadorSHA256.Encriptar( tcPassAlmacenado, tcSecret )
		
		llCoincidenciaDeHash = tcHashOrigen == lcPassHasheado 
		
		if tlForzarDoble or !llCoincidenciaDeHash and !empty( tcAlternativa )
			llCoincidenciaDeHash = tcHashOrigen == this.oEncriptadorSHA256.Encriptar( lcPassHasheado, tcAlternativa )
		endif
		
		return llCoincidenciaDeHash 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TestearClaveHasheadaUpperCase( tcHashOrigen as String, tcPassAlmacenado as String, tcSecret as String, tcAlternativa as String, tlForzarDoble as Boolean ) as Void
		local llCoincidenciaDeHash as Boolean

		lcPassHasheado = this.oEncriptadorSHA256.Encriptar( upper( tcPassAlmacenado ), tcSecret )

		llCoincidenciaDeHash = tcHashOrigen == lcPassHasheado 
		
		if tlForzarDoble or !llCoincidenciaDeHash and !empty( tcAlternativa )
			llCoincidenciaDeHash = tcHashOrigen == this.oEncriptadorSHA256.Encriptar( lcPassHasheado, tcAlternativa )
		endif
		
		return llCoincidenciaDeHash 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function TestearClaveHasheadaLowerCase( tcHashOrigen as String, tcPassAlmacenado as String, tcSecret as String, tcAlternativa as String, tlForzarDoble as Boolean ) as Void
		local llCoincidenciaDeHash as Boolean

		lcPassHasheado = this.oEncriptadorSHA256.Encriptar( lower( tcPassAlmacenado ), tcSecret )

		llCoincidenciaDeHash = tcHashOrigen == lcPassHasheado 
		
		if tlForzarDoble or !llCoincidenciaDeHash and !empty( tcAlternativa )
			llCoincidenciaDeHash = tcHashOrigen == this.oEncriptadorSHA256.Encriptar( lcPassHasheado , tcAlternativa )
		endif
		
		return llCoincidenciaDeHash 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EsUsuarioNoCreadoEnOrganic( tcUsuario as String ) as Boolean
		return "@" $ tcUsuario  && caso zNube
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPass( tcUsuario as String ) as String
		local lcCursorBasesDeDatos as Stgring, lcSql as String, lcPass as String
		
		lcCursorBasesDeDatos = sys( 2015 )

		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Usuario, Clavedesencriptada" ) + ;
						" From " + this.cSchemaSeguridad + "Usuarios " + ;
						"Where " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cSchemaFunciones + ".Alltrim( XX2 ) ) = '" +  golibrerias.EscapeCaracteresSqlServer( alltrim( Upper( tcUsuario ) ) ) + "' "

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad, lcCursorBasesDeDatos, this.DataSessionId )

		select ( lcCursorBasesDeDatos )
		lcPass = rtrim( substr( &lcCursorBasesDeDatos..clave, len(rtrim(&lcCursorBasesDeDatos..usuario))+1 ) )
		use in select( lcCursorBasesDeDatos  )
		
		return lcPass

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMainUsersDeZnube() as Void
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcCursorBasesDeDatos as String, lcSql As String
		
		lcCursorBasesDeDatos = sys( 2015 )

		loRetorno = _screen.zoo.crearobjeto( "zooColeccion", "zoocoleccion.prg" )
		
		lcSql = "SELECT " + this.cSchemaFunciones + ".Desencriptar192(u.[XX2]) as usuario FROM " + this.cSchemaSeguridad + "USUARIOS u " + ;
					  "inner join " + this.cSchemaSeguridad + "PERFILESUSUARIOS pu on " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( pu.idper, pu.idUsu, 1 ) = u.id " + ;
					  "inner join " + this.cSchemaSeguridad + "PERFILESOPERACIONES po on " + this.cSchemaFunciones + ".DesencriptarPerfilUsuario( pu.idper, pu.idUsu, 0 ) = po.idper " + ;
					  "inner join " + this.cSchemaSeguridad + "PERFILES p on po.idper = p.id and " + this.cSchemaFunciones + ".Desencriptar192(p.[XX1]) = '" + UPPER( this.cPerfilAdministrador ) + "' " + ;
					  "where " + this.cSchemaFunciones + ".Desencriptar192(u.[XX9]) = 1 " + ;
					  "group by " + this.cSchemaFunciones + ".Desencriptar192(u.[XX2])"

		goDatos.EjecutarSentencias( lcSql, "usuarios.dbf,perfilesusuarios.dbf,perfilesoperaciones.dbf,perfiles.dbf", ;
					 _Screen.Zoo.App.cRutaTablasSeguridad, lcCursorBasesDeDatos, this.DataSessionId )

		select ( lcCursorBasesDeDatos )
		scan
			loRetorno.Agregar( &lcCursorBasesDeDatos..usuario )
		endscan
		use in select( lcCursorBasesDeDatos  )

		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarClave( tlValidaClave as Boolean, tcClave as String, tcUsuario as String, tcAlias as String ) as Boolean
		local llRetorno as Boolean, lcClave as String, llTieneUsuarioAD as Boolean, lcUsuarioAd as String
		llRetorno = .t.
		llTieneUsuarioAD = .F.
		this.lUsuarioOk = .t.
		lcUsuarioAd = alltrim( transform( &tcAlias..UsuarioAD ) )
		if tlValidaClave
			if empty( tcClave )
				llRetorno = .f.
				This.AgregarInformacion( "Falta ingresar clave." )
			else
				if empty( this.cClaveEmergencia ) and empty( lcUsuarioAd )
					lcClave = upper( alltrim( tcUsuario ) + alltrim( tcClave ) )
					If upper( alltrim( &tcAlias..Clave ) ) == lcClave
					else
						This.AgregarInformacion( "Credenciales inválidas." )					
						llRetorno = .f.
					endif				
				else
					if !empty( lcUsuarioAd )
						llTieneUsuarioAD = .T.
					endif
					this.cClaveEmergencia = ""
				endif
			endif
		else
			if !empty( lcUsuarioAd )
				llTieneUsuarioAD = .T.
			endif
		endif 	
		if llTieneUsuarioAD
			llRetorno = This.ValidacionesContraActiveDirectory( lcUsuarioAd, tlValidaClave, tcClave )	
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTiempoDesbloqueo( tcIdUsuario as String ) as string
		local lcRetorno as String, ldFechaDeBloqueo as Datetime, lnMinutosDebloqueo  as Integer
		lnMinutosDebloqueo = this.ObtenerMinutosDesbloqueo( tcIdUsuario )
		ldFechaDeBloqueo = this.ObtenerFechaDelBloqueo( tcIdUsuario )
		lcRetorno = this.TiempoRestante( golibrerias.ObtenerFechaHora(), ldFechaDeBloqueo + lnMinutosDebloqueo )
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TiempoRestante( ttTiempoActual as Datetime, ttTiempoFinal as Datetime ) as Void 
	      local lnDiferencia as Integer, lnDia as Integer, lnHor as Integer, lnMin as Integer, ;
	            lnSeg as Integer, lcRetorno as String, lcTiempo as String
	            
	      lcRetorno = ""
	      lnDiferencia = ttTiempoFinal - ttTiempoActual
	      if lnDiferencia > 0 
	            *** Segundos ***
	            lnSeg = lnDiferencia % 60
	            lnDiferencia = int( val( transform( lnDiferencia / 60 )) )
	            
	            *** Minutos ***
				lnMin = lnDiferencia % 60 
	            lnDiferencia = int( val( transform( lnDiferencia / 60 ) ) )
	            
	            *** Horas ***
	            lnHor = lnDiferencia %24 
	            
	            *** Dias ***
	            lnDia = int( val( transform( lnDiferencia / 24 ) ) )

	            if lnDia > 0
	            	lcTiempo = iif( transform( lnDia )= "1", " día", " días" )	            
	                lcRetorno = ALLTRIM(STR(lnDia)) + lcTiempo
	            endif
	            if lnHor > 0
	            	lcTiempo = iif( transform( lnHor)= "1", " hora", " horas" )
	                lcRetorno = lcRetorno + " " + TRANSFORM(lnHor, "@Z 99")+ lcTiempo
	            endif
	            lnMin = iif( transform( lnMin ) = "60", 0, lnMin )
	            if lnMin > 0
	            	lcTiempo = iif( transform( lnMin)= "1", " minuto", " minutos" )
	                lcRetorno = lcRetorno + " "  + TRANSFORM(lnMin, "@Z 99") + lcTiempo
	            endif
	            lnSeg = iif( transform( lnseg ) = "60", 0, lnSeg )
	            if lnSeg > 0
	            	lcTiempo = iif( transform( lnSeg)= "1", " segundo", " segundos" )
		            lcRetorno = lcRetorno + " " + TRANSFORM( lnSeg, "@Z 99") + lcTiempo
	            endif
	      else
	            lcRetorno = "0 segundos"
	      endif
      
	      return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMinutosDesbloqueo( tcIdUsuario as String ) as integer	
		local lnCantidadBloq as Integer, lnFactor as Integer
		lnCantidadBloq = this.ObtenerCantidadDeBloqueos( tcIdUsuario )
		lnFactor = goRegistry.Nucleo.Seguridad.FactorMultiplicacionTiempoBloqueoAutomatico
		lnxxxx = ( goRegistry.nucleo.Seguridad.TiempodeBloqueo * iif( lnCantidadBloq > 1, ( lnCantidadBloq - 1 ) * lnFactor , 1 ) * 60 )
		return lnxxxx
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFechaDelBloqueo( tcIdUsuario as String ) as datetime
		local ldFechaBloqueo as datetime, lcSql as String, lcXml as String, lcAlias as String
		lnIntentos = 0
		lcAlias = sys(2015)

		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "FechaBloq" ) + " from " + this.cSchemaSeguridad + "usuarios " +;
				"where id = '" + alltrim( tcIdUsuario ) +"'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		ldFechaBloqueo = &lcAlias..FechaBloq
		
		use in select (lcAlias)		
		return ldFechaBloqueo
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function DesbloqueoAutomatico( tcUsuario, tcClave ) as Boolean
	
		local lcSql as String, lcAlias as String, llRetorno as Boolean, lnCantBloq as Integer, lnFactor as Number, ;
		lnTiempoDesbloqueo as Number
		
		llRetorno = .f.
		lcAlias = "Cur_" + Sys( 2015 )
		lcSql = " select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Id,Usuario, bloqueado, fechabloq, bloqAdm, CantBloq" ) + ;
			" From " + this.cSchemaSeguridad + "Usuarios " + ;
			" Where " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ) ) ) ) = '" +  golibrerias.EscapeCaracteresSqlServer( alltrim( Upper( tcUsuario ) ) ) + "' "

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		lcIdUsuario = this.ObtenerIDUsuario( tcUsuario )
		lnTiempoDesbloqueo = &lcAlias..FechaBloq + this.ObtenerMinutosDesbloqueo( lcIdUsuario )

		If Reccount( lcAlias ) > 0
			if !&lcAlias..BloQAdm 
				if lnTiempoDesbloqueo < golibrerias.ObtenerFechaHora()
					this.DesbloquearUsuario( lcIdUsuario )
					llRetorno = .t.
				endif
			endif	
		endif

		if !llRetorno and this.EsPerfilAdministrador( lcIdUsuario )

			lcClaveRetorno = goFormularios.ObtenerClaveBlanqueoAdmin( this.ObtenerSerie() )

			if lcClaveRetorno == upper( alltrim( tcClave ) )
				this.DesbloquearUsuario( lcIdUsuario )
				this.cClaveEmergencia = alltrim( tcUsuario ) 
				this.BlanquearClave( lcIdUsuario )
				goMensajes.Enviar( "Usuario desbloqueado. Recuerde cambiar su contraseña luego de su próxima " + ;
					"entrada al sistema.", 0, 3 )
				llRetorno = .t.				
			endif	
		endif		
		
		use in select( lcAlias )
		return llRetorno 
		
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ObtenerSerie() as String

		return ""
		
	endfunc 	
	
	*-----------------------------------------------------------------------------------------	
	function GrabarModificacionClave( tcIdUsuario as String , tcClaveOld as String , tcClave as String ) as Void
		local lcSql as String, loex As Exception, llRetorno as Boolean
		
		llRetorno = This.ValidarCambioClave( tcClaveOld, tcClave )
		
		if This.ValidarCambioClave( tcClaveOld, tcClave )
			lcSql = "Update " + this.cSchemaSeguridad + "usuarios set XX3 = " + this.cSchemaFunciones + ".Encriptar192( '" + alltrim( tcClave ) + "') where id = '"+ alltrim( tcIdUsuario ) +"' "
			
			goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
		Else
			loEx = _screen.zoo.crearobjeto( "ZooException" )
			with loEx
				.grabar()
				.oInformacion = this.ObtenerInformacion()
				.Throw()
			endwith
		endif
		
		return .t.

	endfunc 

	*-----------------------------------------------------------------------------------------
	function BloquearUsuario( tcIdUsuario as String ) as Void
	
		local lcFechaBloqueo as Character
		
		if !This.EstaBloqueado( tcIdUsuario )
			set century on
			lcFechaBloqueo = ttoc(golibrerias.ObtenerFechaHora())
			lcSql = "Update " + this.cSchemaSeguridad + "usuarios set XX4 = " + this.cSchemaFunciones + ".Encriptar192( '.t.' ) , XX6 = " + ;
				this.cSchemaFunciones + ".Encriptar192( '" + lcFechaBloqueo + "'), XX7 = " + ;
				this.cSchemaFunciones + ".Encriptar192( str(" + this.cVal + "( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX7 ))) + 1 )) where id = '" + ;
				alltrim( tcIdUsuario ) +"' "

			goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
			
			this.PersistirIntentosDeLogueoFallidos( tcIdUsuario , 0 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesbloquearUsuario( tcIdUsuario as String ) as Void
		local lcFechaBloqueo as Character
		
		set century on

		lcFechaBloqueo = ttoc( iif( goServicios.Datos.EsSqlServer(), evaluate( goRegistry.Nucleo.FechaEnBlancoParaSqlServer ), {} ))
		lcSql = "Update " + this.cSchemaSeguridad + "usuarios set XX4 = " + this.cSchemaFunciones + ".Encriptar192( '.F.' ), XX5 = " + this.cSchemaFunciones + ".Encriptar192( '0' )" + ;
			", XX6 = " + this.cSchemaFunciones + ".Encriptar192( '" + lcFechaBloqueo + "') where Id = '" + alltrim( tcIdUsuario ) + "' "
		
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarIntentosDeLogueoFallidos( tcIdUsuario as String ) as Integer
		local lnIntentos as Integer, lcSql as String, lcXml as String, lcAlias as String

		lnIntentos = this.ObtenerIntentosDeLogueo( tcIdUsuario )  
		if !this.establoqueado( tcIdUsuario ) 
			lnIntentos = lnIntentos + 1	
			this.PersistirIntentosDeLogueoFallidos( tcIdUsuario, lnIntentos ) 
		endif
		return lnIntentos
		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PersistirIntentosDeLogueoFallidos( tcIdUsuario as String, tnIntentos ) as void
		local lcSQL as String
		
		lcSql = "Update " + this.cSchemaSeguridad + "usuarios set XX5 = " + this.cSchemaFunciones + ".Encriptar192( '" + alltrim( str( tnIntentos )) + ;
				"' ) where id = '" + alltrim( tcIdUsuario ) + "'"
				
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIntentosDeLogueo( tcIdUsuario as String ) as Integer
		local lnIntentos as Integer, lcSql as String, lcXml as String, lcAlias as String
		lnIntentos = 0
		lcAlias = sys(2015)

		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "intentosf" ) + " from " + this.cSchemaSeguridad + "usuarios " +;
				"where id = '" + alltrim( tcIdUsuario ) +"'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		lnIntentos = &lcAlias..intentosf 
		
		use in select (lcAlias)		
		return lnIntentos

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadDeBloqueos( tcIdUsuario as String ) as Integer
		local lnIntentos as Integer, lcSql as String, lcXml as String, lcAlias as String
		lnIntentos = 0
		lcAlias = sys(2015)

		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "cantbloq" ) + " from " + this.cSchemaSeguridad + "usuarios " +;
				"where id = '" + alltrim( tcIdUsuario ) +"'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		lnIntentos = &lcAlias..cantbloq
		
		use in select (lcAlias)		
		return lnIntentos

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCantidadBloqueos( tcIdUsuario as String, tnIntentos as Integer )  as Void
	local lcSQL as String
		
		lcSql = "Update " + this.cSchemaSeguridad + "usuarios set XX5 = " + this.cSchemaFunciones + ".Encriptar192( '" + alltrim( str( tnIntentos )) + ;
				"' ), XX7 = " + this.cSchemaFunciones + ".Encriptar192( '" + alltrim( str( tnIntentos )) + "' ) where id = '" + alltrim( tcIdUsuario ) + "'"
				
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ObtenerIntentosDeLogueoFallidos( tcIdUsuario as String ) as Integer
		return this.ObtenerIntentosDeLogueo( tcIdUsuario )
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ObtenerIDUsuario( tcUsuario as String ) as String
		local lcUsuario as String, lcSql as String, lcXml as String, lcAlias as String
		
		lcAlias = sys(2015)
		lcSql = "select Id from " + this.cSchemaSeguridad + "usuarios where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim +;
				"( XX2 ))) = '" + golibrerias.EscapeCaracteresSqlServer( alltrim(upper( tcUsuario ) ) ) + "'"
				
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		if reccount( lcAlias ) > 0
			lcUsuario = alltrim(&lcAlias..ID)
		else
			lcUsuario = ""
		endif		
		
		use in select (lcAlias)
		
		return 	lcUsuario
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function ObtenerUsuarioDesdeEmail( tcEmail as String ) as String
		local lcUsuario as String, lcPass as String, lcSql as String, lcXml as String, lcAlias as String
		
		lcAlias = sys(2015)
		lcSql = "select upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim + "( XX2 ))) as Usuario " +; 
				"from " + this.cSchemaSeguridad + "usuarios where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim +;
				"( XX12 ))) = '" + golibrerias.EscapeCaracteresSqlServer( alltrim( upper( tcEmail ) ) ) + "'"
				
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		if reccount( lcAlias ) > 0
			lcUsuario = alltrim(&lcAlias..Usuario)
		else
			lcUsuario = ""
		endif		
		use in select (lcAlias)
		
		lcPass = this.ObtenerPass( lcUsuario )
		
		return '{ "Usuario": "' + upper( lcUsuario ) + '", "Pass": "' + lcPass + '" }'
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function EstaBloqueado( tcIdUsuario as String ) as Boolean
	
		local llBloqueado as Boolean, lcSql as String, lcXml as String, lcAlias as String
		llBloqueado = .t.
		
		lcAlias = sys(2015)
		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Bloqueado" ) + ;
			" from " + this.cSchemaSeguridad + "usuarios where upper( id ) = '" + ;
				alltrim(upper( tcIdUsuario ) ) + "'"
		
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		if reccount( lcAlias ) > 0
			llBloqueado = &lcAlias..bloqueado
		endif
		
		use in select (lcAlias)
		
		return llBloqueado
		
	endfunc 

	*-----------------------------------------------------------------------------------------		
	function BlanquearClave( tcIdUsuario ) as Void
		local lcSql as String, lcXml as String, lcAlias as String, lcUsuario as 
		
		lcAlias = sys( 2015 )
		lcSql = "select " + goLibrerias.ObtenerCamposSeguridadUsuarios( "Usuario") + " from " + this.cSchemaSeguridad + ;
				"usuarios where upper( id ) = '" + alltrim(upper( tcIdUsuario ) ) + "'"

		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
			, lcAlias, this.DataSessionId )

		if reccount( lcAlias ) > 0
			lcUsuario = (&lcAlias..Usuario)			
			lcSql = "Update " + this.cSchemaSeguridad + "Usuarios set XX3 = " +;
					this.cSchemaFunciones + ".Encriptar192( '" + alltrim(upper( lcUsuario )) + left(alltrim(upper( lcUsuario )), 20 ) + "' )" + ;
					" where upper( id ) = '" + alltrim(upper( tcIdUsuario ) ) + "'"
					
			goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
		endif	
		
		use in select( lcAlias )	

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCambioClave( tcClaveOld as String, tcClaveNew as String ) As Boolean
		Local llRetorno as Boolean
	
		llRetorno = .t.
		if upper( alltrim( tcClaveOld ) ) == upper( alltrim( tcClaveNew ) )
			llRetorno = .f.
			This.AgregarInformacion( "La nueva clave ingresada debe ser diferente a la clave actual." )
		endif
		
		return llRetorno
		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function Destroy()
		use in select( this.cCursorOperaciones )
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarBaseDeDatos( tcUsuario as String, tcBaseDeDatos as String ) as Void
		local lcCursor as String, lcDB as String, lcXml as String, lcIdDB as String, ;
			lcNombreDB as String, lcUsuario as String, loError as zooexception OF zooexception.prg
		
		try
			lcCursor = sys(2015)
			lcDB = alltrim( upper( iif( empty( tcBaseDeDatos ), _screen.zoo.app.cSucursalActiva, tcBaseDeDatos )))
			
			
			lcSql = "Select 1 from " + this.cSchemaSeguridad + "basededatos where " + this.cSchemaFunciones + ;
					".DesEncriptar192( " + this.cAlltrim + "( NombreDB )) = '" + alltrim( lcDB ) + "'"
			
			goDatos.EjecutarSentencias( lcSql, "BaseDeDatos.dbf", _Screen.Zoo.App.cRutaTablasSeguridad ;
				, lcCursor, this.DataSessionId )

			select &lcCursor
			
			if reccount() = 0
				lcSql = "insert into " + this.cSchemaSeguridad + "basededatos ( idDB, NombreDB, Usuario, fecha ) values( " + ;
					this.cSchemaFunciones + ".Encriptar192( '" + alltrim( "DB_" + alltrim( lcDB )) + "' )," + ;
					this.cSchemaFunciones + ".Encriptar192( '" + alltrim( lcDB ) + "' ), " + ;
					this.cSchemaFunciones + ".Encriptar192( '" + alltrim( golibrerias.EscapeCaracteresSqlServer( tcUsuario ) ) + "' ), " + this.cDatetime + "())"
					
				goDatos.EjecutarSentencias( lcSql, "BaseDeDatos.dbf", _Screen.Zoo.App.cRutaTablasSeguridad )
				this.ActualizarNodoBaseDeDatos()
			endif
		catch to loError
			throw loError
		finally
			use in select( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarNodoBaseDeDatos() as Void
		local lcAlias as String, lcSql as string, lcAlias2 as String

		lcAlias = "Cur_" + Sys( 2015 )
		lcAlias2 = "Cur2_" + Sys( 2015 )
		lcSql = " Select po.Idope, po.Idper, po.Modo, p.xx1, ( " + ;
					this.cSchemaFunciones + ".DesEncriptar192(" + this.cAlltrim + "( po.Modo ) ) ) as clave " + ;
				" From " + this.cSchemaSeguridad + "PerfilesOperaciones po " + ;
				" Left Join " + this.cSchemaSeguridad + "Perfiles p " + ;
						" On po.Idper = p.id " + ;
				" Where " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192(" + ;
							this.cAlltrim + "( p.xx1 )))) != 'ADMINISTRADOR' " + ;
							" and alltrim( upper( po.Idope ) ) == 'DB1' " + ;
							" and + right( " + this.cAlltrim + "( upper( " + this.cSchemaFunciones + ".DesEncriptar192(" + ;
							this.cAlltrim + "( po.Modo ) ) ) ), 1 ) == '1' "
					
		goDatos.EjecutarSentencias( lcSql, "Perfiles , PerfilesOperaciones", _Screen.Zoo.App.cRutaTablasSeguridad, lcAlias, this.datasessionId )
		select( lcAlias )
		scan
			lcSql = "Update " + this.cSchemaSeguridad + "PerfilesOperaciones set modo = " +;
					this.cSchemaFunciones + ".Encriptar192( left( '" + alltrim( clave ) + "', len( '" + alltrim( clave ) + "' ) - 1 ) + '6' ) "	+ ;
					" Where Idope = '" + IdOpe + "' and Idper = '" + IdPer + "'"
			goDatos.EjecutarSentencias( lcSql, "PerfilesOperaciones", _Screen.Zoo.App.cRutaTablasSeguridad )
		endscan
		use in select( lcAlias )
 	endfunc 

	*-----------------------------------------------------------------------------------------
	Function PedirAccesoTransferencia( tcTransferencia As String ) As boolean 
		local llRetorno as Boolean 

		llRetorno = .T.

		if !this.PedirAccesoMenu( alltrim( upper( tcTransferencia ) ) )
			llRetorno = .F.		
		endif

		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DibujarItemEnArbol( tcId as String ) as boolean
		local llRetorno as Boolean, lnId as Integer
		
		llRetorno = .t.
		
		If this.ElUsuarioDebeValidarSeguridad()
			tcId = alltrim( tcId )
			if this.oCol_Accesos.Buscar( tcId )
				with this.oCol_Accesos[ tcId ]
					if this.VerificarAccesoItemPadre( tcID )
						this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
					else
						.Modo = MODO_DESHABILITADO && 2
					endif
					if inlist( .Modo, 0, MODO_DESHABILITADO ) && 2 )
						llRetorno = .F.
					endif
				endwith
			else
				llRetorno = .F.
			endif
		endif		
		
		return llRetorno
	endfunc  	

	*-----------------------------------------------------------------------------------------
	Function PedirAccesoListado( tcListado As String ) As boolean 
		local llRetorno as Boolean, loError as Exception

		this.lPermisoAListadoDenegado = .F.

		llRetorno = .T.
		try
			if !this.PedirAccesoMenu( alltrim( upper( tcListado ) ) )
				llRetorno = .F.		
				this.lPermisoAListadoDenegado = .T.
			endif
		catch to loError
			if vartype( this.oCol_Accesos ) == "O"
				throw loError
			else
				&& Error controlado para cuando no existe la collección de seguridad.
				llRetorno = .f.
				This.AgregarInformacion( "La colección de seguridad no esta instanciada, vuelva a iniciar el sistema." )
			endif
		endtry

		Return llRetorno
	endfunc	

	*-----------------------------------------------------------------------------------------
    protected function VerificarVencimientoDeAcceso( tdtUltimoAcceso as Datetime, tcId as String ) as VOID
        local dtActual as Datetime, lnDiferencia as Integer
       
        dtActual = goLibrerias.ObtenerFechaHora()
        lnDiferencia = dtActual - tdtUltimoAcceso
        if empty( tdtUltimoAcceso ) or lnDiferencia > ( this.nTiempoDeExpiracionDeAcceso * 60 )
            this.ObtenerAccesos( "and " + this.cAlltrim + "( upper( IdOpe ) ) = '" + tcId + "'" )
            && Esto es para el caso que no este guardado en la base de datos el modo por ser el mismo que el valor default
            if this.oCol_Accesos.Buscar( tcId ) and empty( this.oCol_Accesos[ tcId ].dtUltimoAcceso )
                this.oCol_Accesos[ tcId ].dtUltimoAcceso = golibrerias.ObtenerFechaHora()
            endif
        endif
    endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerModo( tcId as String ) as String
		&&&&&& OBTENER MODO SE UTILIZA COMO INTERFAZ DE SEGURIDAD para LINCE INDUMENTARIA &&&&&&&
		local lnRetorno as Integer
		
		lnRetorno = 1
		If this.ElUsuarioDebeValidarSeguridad()
			tcId = alltrim( tcId )
			if this.oCol_Accesos.Buscar( tcId )
				with this.oCol_Accesos[ tcId ]
					this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
					lnRetorno = .Modo
				endwith
			endif
		endif		
		
		return lnRetorno
		&&&&&& OBTENER MODO SE UTILIZA COMO INTERFAZ DE SEGURIDAD para LINCE INDUMENTARIA &&&&&&&		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDelSistema() as Integer
		return this.nEstadoDelSistema
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ElUsuarioDebeValidarSeguridad() as Boolean
		Local llDebeControlarSeguridad as Boolean
			
		do case
			case upper( Alltrim( This._cUsuarioLogueado ) ) == alltrim( upper( this.cUsuarioAdministrador ) )
				llDebeControlarSeguridad = .f.
			case This.nEstadoDelSistema == 1
				llDebeControlarSeguridad = .f.
			case this.lEsPerfilAdministrador
				llDebeControlarSeguridad = .f.
			case this.lForzarUsuarioAdministrador
				llDebeControlarSeguridad = .f.
			otherwise
				llDebeControlarSeguridad = .t.
		endcase
		return llDebeControlarSeguridad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PedirLogueo( tcUsuario as string, tcPantalla as String ) as string
		this.lDebeVerificarBasesDeDatosCorruptasAlIniciar = .f.
		return goFormularios.MostrarScxSegunEstilo( "frmLogin", .t., tcUsuario, tcPantalla )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DarFocoALaAplicacion( tcAplicacion as String ) as void
		goServicios.Formularios.DarFocoALaAplicacion( tcAplicacion )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerBaseQueElUsuarioLogueadoPuedeAcceder() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcCursorBasesDeDatos as String, ;
			lcBaseDeDatos as String
		
		lcCursorBasesDeDatos = sys( 2015 )
		loRetorno = _screen.zoo.crearobjeto( "zooColeccion", "zoocoleccion.prg" )
		goDatos.EjecutarSentencias( "select upper( alltrim( empcod ) ) empcod from emp where empcod != '' and empcod is not null order by empcod" ;
			, "emp.dbf", addbs( _screen.zoo.cRutaInicial ), lcCursorBasesDeDatos, this.DataSessionId )		
			
		select ( lcCursorBasesDeDatos )
		scan
			lcBaseDeDatos = alltrim( upper( &lcCursorBasesDeDatos..EMPCOD ) )
			this.AgregarBaseDeDatos( this._cUsuarioLogueado, lcBaseDeDatos )
			if this.HabilitaAccesoMenu( "DB_" + lcBaseDeDatos  )
				loRetorno.Agregar( lcBaseDeDatos, lcBaseDeDatos )
			endif
		endscan
		use in select( lcCursorBasesDeDatos  )
		return loRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerBasesQueRecibenPaquetesSinPermiso() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcCursorBases as String, ;
			lcBaseDeDatos as String
		lcCursorBases = sys( 2015 )
		loRetorno = _screen.zoo.crearobjeto( "zooColeccion", "zoocoleccion.prg" )
		goDatos.EjecutarSentencias( "select upper( alltrim( empcod ) ) empcod from emp where empcod != '' and empcod is not null order by empcod" ;
			, "emp.dbf", addbs( _screen.zoo.cRutaInicial ), lcCursorBases, this.DataSessionId )		
			
		select ( lcCursorBases )
		scan
			lcBaseDeDatos = alltrim( upper( &lcCursorBases..EMPCOD ) )
			if this.EvaluarSiLaBaseRecibePaquetesDeUsuariosSinPermisos( lcBaseDeDatos )
				loRetorno.Agregar( lcBaseDeDatos )
			endif
		endscan
		use in select ( lcCursorBases )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EvaluarSiLaBaseRecibePaquetesDeUsuariosSinPermisos( tcBaseDeDatos as String) as Boolean
		local llRetorno as Boolean, lcSql as String, lcCurValor as String, llValor as Boolean
		
		llValor = .F.
		llRetorno = .F.
		lcCurValor = sys( 2015 )
		
		try
			if goLibrerias.ExisteBaseDeDatosSqlServer( _screen.zoo.app.nombreproducto + "_" + tcBaseDeDatos )
				lcSql = "Select valor from [" + _Screen.Zoo.App.NombreProducto + "_" + tcBaseDeDatos + "].[PARAMETROS].[SUCURSAL] Where IDUnico = '14BB7F97A12B5814C751A62215528438417101'"
				goServicios.Datos.EjecutarSql( lcSql, lcCurValor, this.DataSessionId ) 
				select ( lcCurValor )
				llValor = alltrim( &lcCurValor..Valor )
				if &llValor
					llRetorno = .T.
				endif
			endif
		catch
			llRetorno = .F.
		finally
			use in select ( lcCurValor )
		endtry
		return llRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiarBaseDeDatos( tcBaseDeDatos as String ) as Void
		local lcBaseDeDatos as String, llResultadoChequeos as Boolean, lcBaseDeDatosPrevia as String, loVerificadorDeBasesDeDatos  as Object
		
		lcBaseDeDatos = upper( alltrim( tcBaseDeDatos ) )
		lcBaseDeDatosPrevia = _screen.zoo.app.cSucursalActiva
		if upper( alltrim( _screen.zoo.app.cSucursalActiva ) ) != lcBaseDeDatos and this.CerrarVentanas()
			goServicios.RealTime.ProcesarBuffers( "Cambio de Base de Datos" )
			if this.PedirAccesoMenu( "DB_" + lcBaseDeDatos )
				goServicios.PoolDeObjetos.Liberar()
				goServicios.RegistroDeActividad.Detener()
				goServicios.SaltosDeCampoYValoresSugeridos.Detener()
				goServicios.Ejecucion.CerrarInstanciasDeAplicacion( .T. )
				goMensajes.EnviarSinEspera( "Realizando el cambio de base de datos a " + lcBaseDeDatos )
				if goServicios.MonitorSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBaseDeDatosDeNegocio( goServicios.Librerias.ObtenerNombreSucursal( upper( alltrim( lcBaseDeDatos ) ) ) )
					loVerificadorDeBasesDeDatos = _screen.Zoo.CrearObjetoPorProducto( "VerificadorDeBasesDeDatosCorruptas", "VerificadorDeBasesDeDatosCorruptas.prg" )
					if _screen.zoo.app.lEsEntornoCloud or loVerificadorDeBasesDeDatos.Ejecutar( upper( alltrim( lcBaseDeDatos ) ), .f. )
						_screen.zoo.app.cSucursalActiva =  lcBaseDeDatos
						this.InformarSiEsBDDemo()
						_screen.zoo.app.tUltimoControl = 0
						llResultadoChequeos = _screen.zoo.app.ValidarVersionDemo()
						_screen.zoo.app.ReiniciarServicios()
						this.RefrescarMenuYBarraDelFormularioPrincipal()
						goServicios.Ejecucion.IniciarNuevaInstanciaDeAplicacion()
						_Screen.Zoo.App.EjecutarMigradorDeParametros()
					endif
				endif
				goMensajes.EnviarSinEspera()
			else
				goMensajes.Advertir( this.ObtenerInformacion() )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarVersionBD( tcBaseDeDatos as String ) as String
		local loResultadoValidacionVersion as Object, lcBaseDeDatos as Object, lcVersion as String

		if empty( tcBaseDeDatos )
			lcBaseDeDatos = _Screen.Zoo.App.cSucursalActiva
		else
			lcBaseDeDatos = tcBaseDeDatos
		endif

		loResultadoValidacionVersion = goServicios.MonitorSaludBasesDeDatos.ValidarVersion( goServicios.Librerias.ObtenerNombreSucursal( upper( alltrim( lcBaseDeDatos ) ) ) )
		
		if loResultadoValidacionVersion.VersionValida or empty( loResultadoValidacionVersion.VersionAplicacion )
			lcVersion = ""
		else
			lcVersion = loResultadoValidacionVersion.VersionBaseDeDatos
		endif
		
		return lcVersion
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarMenuYBarraDelFormularioPrincipal() as Void
		_screen.zoo.app.IniciarMenuPrincipal()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaDatosUsuarioOrganic() as Void
		return addbs( _screen.zoo.app.cRutaAppDataLocal ) + "usuario.ini"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAntiguaRutaDatosUsuarioOrganic() as Void
		return addbs( _screen.zoo.cRutaInicial ) + "aplicacion.ini"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoUsuarioLogueadoParaLogin() as String
		local lcRetorno as String, lnI as Integer, lcUsuario as String, lcUsuarioPC as String, lcRutaDatosUsuarioOrganic as String
		
		lcRutaDatosUsuarioOrganic = this.ObtenerRutaDatosUsuarioOrganic()
		
		if !file( lcRutaDatosUsuarioOrganic )
			lcRutaDatosUsuarioOrganic = this.ObtenerAntiguaRutaDatosUsuarioOrganic()
		endif

		lcRetorno = goLibrerias.DesEncriptar192( goLibrerias.obtenerdatosdeini( lcRutaDatosUsuarioOrganic, "SEGURIDAD", "UltimoUsuarioLogueado" ) )
		if vartype( lcRetorno ) != "C"
			lcRetorno = transform( lcRetorno )
		endif
		for lnI = 0 to 31
			lcRetorno = strtran( lcRetorno, chr(lnI), "" )
		endfor
		llHash = goLibrerias.CompararHash( lcRetorno, goLibrerias.obtenerdatosdeini( lcRutaDatosUsuarioOrganic , "SEGURIDAD", "CodigoVerificador" ) )
		if !llHash
			lcRetorno = ""
		ENDIF
		
		lcUsuario = getwordnum( lcRetorno, 1, "#" )
		lcUsuarioPC = getwordnum( lcRetorno, 3, "#" )
		lcRetorno = iif( empty( this.ObtenerIdUsuario( alltrim( lcUsuario ) ) ), "", lcUsuario )

		if empty( lcRetorno ) or ( !empty( lcUsuarioPC ) and lcUsuarioPC <> this.ObtenerNombreUsuarioPC() )
			this.lRecordarUsuario = .f.
			goParametros.Nucleo.Seguridad.RecordarUsuario = .f.			
			lcRetorno = ""
		else
			if empty( lcUsuarioPC )
				this.SetearUltimoUsuarioLogueadoParaLogin( lcUsuario )
			endif
		endif		
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearUltimoUsuarioLogueadoParaLogin( tcUsuario as String ) as VOID
		local lcCadena as String, lcUsuarioPC as String
		
		lcUsuarioPC = this.ObtenerNombreUsuarioPC()

		lcCadena = alltrim( tcUsuario ) + "#" + alltrim( _screen.zoo.App.cSerie ) + "#" + lcUsuarioPC
		goLibrerias.EscribirDatosDeIni( this.ObtenerRutaDatosUsuarioOrganic(), "SEGURIDAD", "UltimoUsuarioLogueado", goLibrerias.Encriptar192( lcCadena ) )
		goLibrerias.EscribirDatosDeIni( this.ObtenerRutaDatosUsuarioOrganic(), "SEGURIDAD", "CodigoVerificador", goLibrerias.Hashear( lcCadena ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreUsuarioPC() as String
		return goServicios.Librerias.ObtenerNombreUsuarioSO()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombrePC() as String
		return goServicios.Librerias.ObtenerNombrePuesto()
	endfunc

	*-----------------------------------------------------------------------------------------
	function InformarSiEsBDDemo() as Void
		local lcBaseSeleccionada as String

		if empty(_screen.zoo.app.cSucursalActiva)
			lcBaseSeleccionada = this.cbasededatosseleccionada
		else
			lcBaseSeleccionada = _screen.zoo.app.cSucursalActiva
		endif
		
		if upper( alltrim( lcBaseSeleccionada ) ) == "DEMO" and !this.VerificarSiEsIyD() and !goServicios.Ejecucion.TieneScriptCargado()
		
			this.InformarBaseDemo()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarSiEsIyD() as Boolean
		local llRetorno as Boolean

		llRetorno = EsIyD()		

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InformarBaseDemo() as Void
		goMensajes.Advertir( "Atención!! No se recomienda utilizar la base de datos DEMO con información de negocio, ya que la misma esta pensada sólo para fines ilustrativos del sistema." )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarAccesoItemPadre( tcId as String ) as boolean
		local llRetorno as Boolean, lcItemPadre as string, lnModoPadre as Integer
		
		lcItemPadre = this.oCol_Accesos[ tcid ].ItemPadre	

		if !empty( lcItemPadre )
			with this.oCol_Accesos[ lcItemPadre ]
				this.VerificarVencimientoDeAcceso( .dtUltimoAcceso, .Id )
				lnModoPadre = .Modo
				if .Modo != MODO_DESHABILITADO && 2
					llRetorno = .T.
				endif
			endwith
		else
			llRetorno = .T.
		endif		

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionesContraActiveDirectory( tcUsuarioAd as String, tlValidaClave as Boolean, tcClave as String ) as Boolean
		local lcDominioAd as String, lcUsuarioAd as String, lcAux as String, llUsuarioVencido as Boolean
		local llRetorno as Boolean, lcClave as String, loActiveDir as Object
		llRetorno = .T.
		lcClave = rtrim( tcClave )
		lcAux = alltrim( transform( tcUsuarioAd ) )
		if "/" $ lcAux && Tiene barra separadora de dominio/usuario
			lcDominioAd = substr( lcAux, 1, rat( "/", lcAux, 1 ) -1 )
			lcUsuarioAd = alltrim( substr( lcAux, rat( "/", lcAux, 1 ) +1, len( alltrim( lcAux ) ) ) )
		else
			lcDominioAd = ""
			lcUsuarioAd = alltrim( lcAux )
		endif
		loActiveDir = goLibrerias.oColaboradorActiveDir

		loActiveDir.SetearDominio( lcDominioAd )
		if !empty( loActiveDir.MensajeError )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif
		
		if llRetorno and !loActiveDir.ExisteUsuarioEnAD( lcUsuarioAd )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif
		
		if llRetorno and loActiveDir.UsuarioVencido( lcUsuarioAd )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif

		if llRetorno and loActiveDir.PasswordVencida( lcUsuarioAd )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif
		
		if llRetorno and loActiveDir.CuentaDeshabilitada( lcUsuarioAd )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif
		
		if llRetorno and tlValidaClave and !loActiveDir.CredencialesValidas( lcUsuarioAd, lcClave )
			llRetorno = .F.
			This.AgregarInformacion( loActiveDir.MensajeError )
		endif
		return llRetorno		
	endfunc

	*-----------------------------------------------------------------------------------------	
	function ObtenerUsuarioActiveDir( tcUsuario as String ) as String
	
		local lcUsuarioAd as String, lcSql as String, lcXml as String, lcAlias as String
		
		lcAlias = sys(2015)

		lcSql = "select funciones.DesEncriptar192( funciones.Alltrim( XX11 ) ) as UsuarioAd from " + this.cSchemaSeguridad + "usuarios where upper( " + this.cSchemaFunciones + ".DesEncriptar192( " + this.cAlltrim +;
				"( XX2 ))) = '" + golibrerias.EscapeCaracteresSqlServer( alltrim(upper( tcUsuario ) ) ) + "'"
				
		goDatos.EjecutarSentencias( lcSql, "Usuarios.dbf", _Screen.Zoo.App.cRutaTablasSeguridad, lcAlias, this.DataSessionId )

		if reccount( lcAlias ) > 0
			lcUsuarioAd = alltrim( transform( &lcAlias..UsuarioAd ) )
		else
			lcUsuarioAd = ""
		endif		
		
		use in select ( lcAlias )
		
		return 	lcUsuarioAd
	endfunc

	*-----------------------------------------------------------------------------------------
	function UsuarioTieneConfiguradoUsuarioActiveDir() as Boolean
		local llRetorno as Boolean, lcUsuarioAD as String
		llRetorno = .F.
		lcUsuarioAD =  this.ObtenerUsuarioActiveDir( this.cUsuarioLogueado )
		llRetorno = !empty( lcUsuarioAD )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PermitirAcceso( toAcceso as Object, tlNoPedirClave as Boolean ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		do case
			case inlist( toAcceso.Modo , 0, MODO_DESHABILITADO ) && 2 ) && Deshabilitado
				llRetorno = .f.
				This.AgregarInformacion( "El usuario no tiene permitido el acceso." )
			case inlist( toAcceso.Modo, MODO_PROTEGIDO, MODO_DEFAULT ) or (toAcceso.Modo # MODO_HABILITADO and toAcceso.ModoPerfil = MODO_PROTEGIDO )&& Protegido por password
				llRetorno = This.SolicitarClave( toAcceso , tlNoPedirClave )
		endcase

		if llRetorno and !toAcceso.Id = 'TICKETFACTURA_REIMPRIMIRTICKET'
			this.LoguearAccesosMenu( toAcceso.Id )
		endif	
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function SolicitarClave( toAcceso as Object, tlNoPedirClave as Boolean ) As Boolean
		Local loPedirClave As Object,lcIdUsuario As String, llRetorno as Boolean
		llRetorno = .t.
		This.cVengoDe = This.ArmarCaptionVengoDe( toAcceso.Id )

		if tlNoPedirClave 
			lcIdUsuario = this.cUsuarioLogueado
		else
			loPedirClave = _Screen.zoo.CrearObjeto( "PedirClave" )
			lcIdUsuario = loPedirClave.PedirClave()
			if this._cUsuarioLogueado = this.cUsuariovalidado and toAcceso.Modo # MODO_HABILITADO && 1
				cIdUsuario = ""
			else
				this.cUsuarioOtorgaPermiso = this.cUsuariovalidado 
			endif
		endif
		
		If Empty( lcIdUsuario )
			llRetorno = .f.
			This.AgregarInformacion( "Pedido de clave fallido." )
		else
			if lcIdUsuario = "CANCEL"
				llRetorno = .f.
				This.AgregarInformacion( "Cancelado." )
			else
				llRetorno =	This.VerificarAccesoUsuario( toAcceso.Id, lcIdUsuario )
			endif
		Endif
		Return llRetorno
	Endfunc

enddefine
