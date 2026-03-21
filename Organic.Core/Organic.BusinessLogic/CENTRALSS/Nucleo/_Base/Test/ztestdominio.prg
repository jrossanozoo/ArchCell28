**********************************************************************
Define Class zTestDominio as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestDominio of zTestDominio.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc

	*-----------------------------------------------------------------------------------------
	Function ztestValidarMail
		local loDominio as Dominio of Dominio.prg, llRetorno as Boolean
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )

		with loDominio 
			llRetorno = .ValidarDominio_Mail( "DelPotro@AsDelTenis.com" )
			This.asserttrue( "La validación debería haber sido correcta. 1" , llRetorno )
			
			llRetorno = .ValidarDominio_Mail( "DelPotroAsDelTenis.com" )
			This.asserttrue( "La validación debería fallado. 2" , !llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelP+tro@AsDelTenis.com" )
			This.asserttrue( "La validación debería haber sido correcta. 3" , llRetorno )
			
			llRetorno = .ValidarDominio_Mail( "DelP+tro@AsDelTen+s.com" )
			This.asserttrue( "La validación debería fallado. 4" , !llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelPotro@As-Del-Tenis.com" )
			This.asserttrue( "La validación debería haber sido correcta. 5" , llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com" )
			This.asserttrue( "La validación debería haber sido correcta. 6" , llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelP+tro@As-Del-Ten+s.com" )
			This.asserttrue( "La validación debería fallado. 7" , !llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com, DelPotro@AsDelTenis.com " )
			This.asserttrue( "La validación debería haber sido correcta. 8" , llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com; DelP+tro@As-Del-Ten+s.com" )
			This.asserttrue( "La validación debería haber fallado. 9" , !llRetorno )

			llRetorno = .ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com  DelPotro@AsDelTenis.com  ; DelPotro@As-Del-Tenis.com , Del_Potro@AsDelTenis.com " )
			This.asserttrue( "La validación debería haber sido correcta. 10" , llRetorno )
						
			.Release()
		endwith

	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestValidarMailExistenciaMensajesDeError
		local loDominio as Dominio of Dominio.prg, llRetorno as Boolean, loInformacion as zooinformacion of zooInformacion.prg
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		loInformacion = loDominio.ObtenerInformacion()

		with loDominio 
			.ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com; DelP+tro@" )
			llRetorno = lodominio.Hayinformacion()
			This.asserttrue( "Debería haber mostrado errores." , llRetorno )
			this.assertequals( "No se agregó la información del error.", "Formato de Email inválido para: DelP+tro@", loInformacion.Item[ 1 ].cMensaje )			
			.Release()
		endwith
		
	Endfunc 
			
	*-----------------------------------------------------------------------------------------
	Function ztestValidarMailMailValidoSinMensajesDeError
		local loDominio as Dominio of Dominio.prg, llRetorno as Boolean, loInformacion as zooinformacion of zooInformacion.prg
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		loInformacion = loDominio.ObtenerInformacion()

		with loDominio 
			.ValidarDominio_Mail( "DelPotro@AsDel-Tenis.com; DelPotro@AsDelTenis.com" )
			llRetorno = lodominio.Hayinformacion()
			This.asserttrue( "No debería haber mostrado errores." , !llRetorno )
			this.asserttrue( "Se agregó información del error cuando no lo hay.", loInformacion.count = 0 )			
			.Release()
		endwith
		
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestValidarMailConUnAtributo
		local loDominio as Dominio of Dominio.prg, llRetorno as Boolean, loInformacion as zooinformacion of zooInformacion.prg
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		loInformacion = loDominio.ObtenerInformacion()

		with loDominio 
			.ValidarDominio_MailAtributo( "DelPotro@AsDel-Tenis.com; .Cliente.Mail" )
			llRetorno = lodominio.Hayinformacion()
			This.asserttrue( "No debería haber mostrado errores." , !llRetorno )
			this.asserttrue( "Se agregó información del error cuando no lo hay.", loInformacion.count = 0 )			
			.Release()
		endwith
		
	Endfunc 

	*---------------------------------
 	function zTestValidarFechas
		local loEntidad As entidad OF entidad.prg

		loEntidad = _screen.zoo.instanciarentidad( "Rusia" )

		with loEntidad		
			.oValidacionDominios = newobject( "dominio1" )
			Try
				.codigo = "1"
				.Eliminar()
			Catch 
			endtry 
			
			.Nuevo()
			.Codigo = "1"
			.Fecha = date()
			
			this.asserttrue( "No entro al ValidarRangoDeFechas del dominio", .oValidacionDominios.lPasoValidarRangoDeFecha )
			
			.Release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarFechaMenorAlaPermitidaEnSql
		local loDominio as dominios of dominios.prg
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		
		this.asserttrue( "La Fecha no puede ser menor.", !loDominio.ValidarDominio_fecha( date( 1752, 12, 31 ) ) )
		this.asserttrue( "La Fecha debe poder ser mayor.", loDominio.ValidarDominio_fecha( date( 1753, 1, 1 ) ) )
		
		loDominio.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
 	function zTestValidarDominioNumericoNoNegativo
		local loEntidad As Object, loError as Exception

		loEntidad = _screen.zoo.instanciarentidad( "Rusia" )
	
		with loEntidad		
			Try
				.codigo = "1"
				.Eliminar()
			Catch 
			endtry 
			
			.Nuevo()
			.Codigo = "1"

			try
				.Habitantes = -22
			catch to loError
				this.assertEquals ( "No deberia haber dejado cargar la cantidad de habitantes en negativo.", ;
					upper( alltrim( "El valor no puede ser negativo." ) ), alltrim( Upper( loError.UserValue.oInformacion.Item( 1 ).cMensaje ) ) )
				loError = null
			endtry

			.Release()
		endwith
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSinObjetos	 
		local llRetorno as Boolean, loDominio as Dominios of Dominios.prg
		private goParametros

		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		goParametros = newobject( "Din_parametros_mock" )

		with loDominio

			llRetorno = loDominio.ValidarDominio_fechaComprobante( date() )
			this.asserttrue( "Fallo Validacion fechas. Sin proyecto.", llRetorno )

			goParametros.AgregarModulo()
			llRetorno = loDominio.ValidarDominio_fechaComprobante( date() )			
			this.asserttrue( "Fallo Validacion fechas. Sin Nodo Fechas.", llRetorno )

			goParametros.AgregarNodo()
			llRetorno = loDominio.ValidarDominio_fechaComprobante( date() )
			this.asserttrue( "Fallo Validacion fechas. Sin DesdeMes.", llRetorno )

			goParametros.AgregarPropiedadDesdeMes()
			llRetorno = loDominio.ValidarDominio_fechaComprobante( date() )
			this.asserttrue( "Fallo Validacion fechas. Sin HastaMes.", llRetorno )

			goParametros.AgregarPropiedadHastaMes()
			llRetorno = loDominio.ValidarDominio_fechaComprobante( date() )
			this.asserttrue( "Fallo Validacion fechas. Sin HastaMes.", llRetorno )

			llRetorno = loDominio.ValidarDominio_fechaComprobante( {} )
			this.asserttrue( "Fallo Validacion fechas. Sin Fecha.", llRetorno )

			.Release()
		endwith
		
		release goParametros

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarMesAnio
		local loDominio as Dominio of Dominio.prg, llRetorno as Boolean, loInformacion as zooinformacion of zooInformacion.prg
		
		loDominio = _screen.zoo.crearobjeto( "Dominios" )
		loInformacion = loDominio.ObtenerInformacion()

		with loDominio 
			llRetorno = .ValidarDominio_MesAnio( "" )
			This.asserttrue( "La validacion deberia haber sido correcta por valor en blanco." , llRetorno )
			
			llRetorno = .ValidarDominio_MesAnio( " 110" )
			This.asserttrue( "La validacion deberia haber sido correcta (Enero del 10)." , llRetorno )
			
			llRetorno = .ValidarDominio_MesAnio( "021" )
			This.asserttrue( "La validacion deberia haber sido correcta (Febrero del 01)." , llRetorno )
			
			llRetorno = .ValidarDominio_MesAnio( "0309" )
			This.asserttrue( "La validacion deberia haber sido correcta (Marzo del 09)." , llRetorno )
			
			llRetorno = .ValidarDominio_MesAnio( "1310" )
			This.asserttrue( "La validacion deberia haber fallado (?? del 10)." , !llRetorno )
			this.assertequals( "No se agregó la información del error.", "Mes/Año inválido.", loInformacion.Item[ 1 ].cMensaje )
			
			llRetorno = .ValidarDominio_MesAnio( "-110" )
			This.asserttrue( "La validacion deberia haber fallado (-? del 10)." , !llRetorno )
			this.assertequals( "No se agregó la información del error.", "Mes/Año inválido.", loInformacion.Item[ 2 ].cMensaje )

			.Release()
		endwith

	Endfunc

EndDefine

*-----------------------------------------------------------------------------------------


define class Din_parametros_mock as Custom

nucleo = null
	*-----------------------------------------------------------------------------------------
	function AgregarModulo() as Void
		This.nucleo = newobject( "custom" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarNodo() as Void
		This.nucleo.addproperty( "Fechas", null )
		This.nucleo.fechas = newobject( "Custom" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadDesdeMes() as Void
		This.nucleo.fechas.addproperty( "DesdeMes", null )
		This.nucleo.fechas.DesdeMes = 1
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadHastaMes() as Void
		This.nucleo.fechas.addproperty( "HastaMes", null )
		This.nucleo.fechas.HastaMes = 12
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadDesdeFecha() as Void
		This.nucleo.fechas.addproperty( "DesdeFecha", null )
		This.nucleo.fechas.DesdeFecha = date()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadHastaFecha() as Void
		This.nucleo.fechas.addproperty( "HastaFecha", null )
		This.nucleo.fechas.HastaFecha = date()
	endfunc 

enddefine




define class Dominio1 as Dominios of Dominios.prg
	lPasoValidarRangoDeFecha = .f.
	
	*-----------------------------------------------------------------------------------------
	function ValidarRangoDeFechas( tdFecha as Date ) as Boolean
	
		this.lPasoValidarRangoDeFecha = .t.
		return .t.
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarDominio_Mail( tcMail as string ) as Boolean
		return .t.
	endfunc 

enddefine 