**********************************************************************
Define Class ztestkontrolerhserviciocontrol as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestkontrolerhserviciocontrol of ztestkontrolerhserviciocontrol.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestValorSugeridoAlModificar
		local loHserviciocontrol as Object, lcEntidad As String ,;
		loFrmCli as Object

		private goServicios
		goServicios = _Screen.Zoo.CrearObjeto( 'ServiciosAplicacion' )
		goServicios.Seguridad = newobject( "seguridad_mock" )
				
		This.AgregarMocks( "HServicioControl,LegajoOps" )
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Modificar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Cargamanual', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Obtenernombre', "HSERVICIOCONTROL" )
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Enlazar', .T., "[Verificadopor.EventoObtenerLogueo],[inyectarLogueo]" )
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Enlazar', .T., "[Verificadopor.EventoObtenerInformacion],[inyectarInformacion]" )	
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Obtenerdescripcion', "HSERVICIOCONTROL" )		
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Validardominio_fechacalendario', .T., "ctod( ' / / ' )" ) 			
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Validardominio_fechacalendario', .T., "ctod( '"+ dtoc(date()) + "' )" )
		_screen.mocks.AgregarSeteoMetodo( 'hserviciocontrol', 'Obtenernombreoriginal', "HSERVICIOCONTROL" )
		
		loFrmCli = newobject( "frmTest" )

		goServicios.Seguridad.cUsuarioLogueado = "USUARIO1"

		loFrmCli.oEntidad.Numero = 888  
		loFrmCli.oEntidad.verificadopor.Codigo = ''
		loFrmCli.oEntidad.fechaVerificacion = ctod( "" )
		loFrmCli.oKontroler.Modificar()

		This.assertequals( "El atributo verificadopor no tiene asignado un valor cuando estaba vacio y se quizo modificar." ;
							, "USUARIO1", alltrim( loFrmCli.oEntidad.verificadopor.Codigo ) )

		This.assertequals( "El atributo fechaVerificacion no tiene asignado un valor cuando estaba vacio y se quizo modificar." , ;
					goLibrerias.ObtenerFecha(), loFrmCli.oEntidad.fechaVerificacion )
					
		loFrmCli.Release()
		goServicios.Release()
	endfunc 

EndDefine


define class FrmTest as Form 
	oEntidad = Null
	*-----------------------------------------------------------------------------------------
	function init
		dodefault()
		this.oEntidad = _screen.zoo.instanciarentidad( 'Hserviciocontrol' )
		ThisForm.newobject( "oKontroler", "KontrolerHserviciocontrol", "KontrolerHserviciocontrol.prg"  )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function release
		This.oKontroler.Release
		This.oEntidad.Release
		This.oEntidad = NUll
		dodefault()
		
	endfunc 
	
enddefine



define class seguridad_mock as seguridad of seguridad.prg

	*-----------------------------------------------------------------------------------------
	function cUsuarioLogueado_Assign( txValue )
		with this
			._cUsuarioLogueado = Alltrim( Upper( txValue ) )			
			.cIdUsuarioLogueado = 1
			.cIdUltimoUsuarioLogueado = .cIdUsuarioLogueado
			.cUltimoUsuarioLogueado = ._cUsuarioLogueado
			.cUsuarioLogueado = ._cUsuarioLogueado
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	 Function PedirAccesoEntidad( tcEntidad As String, tcMetodo As String, tlSinPantalla As Boolean, tcDescripcionEntidad as String, tcUsuariorAutorizante as String ) As boolean
		local llRetorno as Boolean
		llRetorno = .t.
	
		Return llRetorno
	endfunc
enddefine

