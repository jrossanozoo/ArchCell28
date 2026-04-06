**********************************************************************
DEFINE CLASS zTestComponenteComunicacion as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestComponenteComunicacion OF zTestComponenteComunicacion.PRG
	#ENDIF
	

	*-----------------------------------------------------------------------------------------
	function zTestGrabar
		local loComponente as Object, loColeccion as zoocoleccion OF zoocoleccion.prg

		loComponente = newobject( "Mock_componentecomunicacion" )
		with loComponente
			.Grabar()
			loColeccion = .lPasoPorObtenerSentenciasUpdateGrupo = .F.
			This.asserttrue( "Debio pasar por 'ObtenerSentenciasUpdateGrupo'.", .lPasoPorObtenerSentenciasUpdateGrupo )
		endwith
		loComponente = null

	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function zTestClientePerteneceAlGrupo
		local loEntidad as entidad OF entidad.prg
		
		This.agregarmocks( "ZLCLIENTES,USOV2" )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		loEntidad = _screen.zoo.instanciarentidad( "GRUPOCOMUNICACION" )
		with loEntidad
			.Nuevo()
			.Descrip = "Con Cliente 03"
			.Usos_Pk = "01"
			*-- Prueba Exepciones
			with .GrupoClientes
				.LimpiarItem()
				.oItem.codcli_PK = "01"
				.oItem.Nombre = "01"
				.Actualizar()

				.LimpiarItem()
				.oItem.codcli_PK = "02"
				.oItem.Nombre = "02"
				.Actualizar()

				.LimpiarItem()
				.oItem.codcli_PK = "03"
				.oItem.Nombre = "03"
				.Actualizar()

			endwith
			.Grabar()		

			loComponente = newobject( "Mock_componentecomunicacion" )
			loComponente.cCliente = "04"
			llResultado = loComponente.Mock_ClientePerteneceAlGrupo( .Codigo )
			This.asserttrue( "No deberia encontrar el cliente en el Grupo.", !llResultado )
			
			loComponente.cCliente = "03"
			llResultado = loComponente.Mock_ClientePerteneceAlGrupo( .Codigo )
			This.asserttrue( "Deberia encontrar el cliente en el Grupo(1).", llResultado )

			loComponente.cCliente = "02"
			llResultado = loComponente.Mock_ClientePerteneceAlGrupo( .Codigo )
			This.asserttrue( "Deberia encontrar el cliente en el Grupo(2).", llResultado )

			loComponente.cCliente = "01"
			llResultado = loComponente.Mock_ClientePerteneceAlGrupo( .Codigo )
			This.asserttrue( "Deberia encontrar el cliente en el Grupo(3).", llResultado )

			.Release()	
		endwith
				
	endfunc 
	
ENDDEFINE

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_componentecomunicacion as componentecomunicacion of componentecomunicacion.prg
	lPasoPorObtenerSentenciasUpdateGrupo = .F.

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdateGrupo() as zoocoleccion OF zoocoleccion.prg
		This.lPasoPorObtenerSentenciasUpdateGrupo = .T.
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function Mock_ClientePerteneceAlGrupo( tnCodigoGrupo as Integer ) as Boolean
		return This.ClientePerteneceAlGrupo( tnCodigoGrupo )
	endfunc 

enddefine


