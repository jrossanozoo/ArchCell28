define class ActualizarZooPercep as Zoosession of Zoosession.prg

	#if .f.
		local this as ActualizarZooPercep of ActualizarZooPercep.prg
	#endif

	cRutaVistas = ''
	cBDVistasZoologic = 'vistas de zoologic'
	oFacturacionLince = Null
	cRutaFacturacionLince = ''	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.oFacturacionLince = newobject( "FacturacionLincePercep", "FacturacionLincePercep.PRG" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function inicializar() as Void

		if empty( _Screen.Zoo.App.cRutaZoologic ) 
			goMensajes.enviar( "ATENCIÓN: No se encuentra asignada la ruta de las tablas de Zoo Logic" )
		else	
			if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
				open database addbs( _Screen.Zoo.App.cRutaZoologic ) + "zoo logic.DBC" shared
				open database addbs( _Screen.Zoo.App.cRutaZoologic ) + This.cBDVistasZoologic + ".DBC" shared
				set database to "Zoo logic"
			endif 	
		endif
		
		if empty( _Screen.Zoo.App.cRutaLince )
			goMensajes.enviar( "ATENCIÓN: No se encuentra asignada la ruta de las tablas de Lince" )
		endif
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function DevolverValorAnterior( tnTipo as Integer, tnTipoValor as Integer ) as String
        local lcRetorno as String

		lcRetorno = ""
		do case
			case tnTipo = 0
				lcRetorno = "No - "
			case tnTipo = 1
				lcRetorno = "Si - "
			case tnTipo = 2
				lcRetorno = "   - "
			Otherwise
				lcRetorno = " -"
		endcase
        
		do case
			case tnTipoValor = 1
				lcRetorno = lcRetorno + "BANSUD"
			case tnTipoValor = 2
				lcRetorno = lcRetorno + "AMEX"
			case tnTipoValor = 3
				lcRetorno = lcRetorno + "MASTER"
			case tnTipoValor = 4
				lcRetorno = lcRetorno + "VISA"
			case tnTipoValor = 5
				lcRetorno = lcRetorno + "FRANCES"
			case tnTipoValor = 6
				lcRetorno = lcRetorno + "PREPAGO"
			otherwise
				lcRetorno = lcRetorno + " "
		endcase

        return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MigrarClientes( lnCodCli as integer, tcNombre as string ) as Void
		local lcSentencia as String, loError as Exception

		if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
			if empty( lnCodCli )
				This.Loguear( "Comienzo del proceso de migracion de Clientes - " + ttoc(datetime()) + " - Proceso 1/3" )

				lcSentencia = "Select cmpCodigo, cmpNombre From ZL.Clientes"
				godatos.ejecutarSentencias( lcSentencia, "ZL.Clientes", "", 'CtesSQL', this.DataSessionId )		
			endif
			
			try
				if This.ExistenClientesAMigrar( "CtesSQL" )

					wait window "Abriendo vistas..." nowait
					this.AbrirVistas("internostodos")
					this.AbrirVistas("vatodos")
					this.AbrirVistas("tecnicostodos")
					this.AbrirVistas("estadotodos")
					this.AbrirVistas("corredortodos")
					wait clear
					
					use addbs( _screen.zoo.app.cRutaZoologic ) + "cli" in 0  shared		

					select cli
					set order to clcod in cli
				
					if empty( lnCodCli )
						select CtesSQL
						go top in CtesSQL
		
						wait window "Migrando clientes..."  nowait
						scan
						
							if !seek( alltrim( ctessql.cmpcodigo ), "cli")
								append blank in cli	
							endif				

							try
								This.ActualizarClienteLince( ctessql.cmpcodigo, ctessql.cmpnombre, 2 )
							catch to oErr 
								This.Loguear( "Se producieron errores dando de alta los clientes (codigo de cliente " + ctessql.cmpcodigo + ")" )
								THROW oErr
							endtry
						endscan
						wait clear
						This.Loguear( "Finalizo el proceso de migracion de Clientes - " + ttoc(datetime()) )
					else

						if seek( alltrim( lnCodCli  ), "cli")
						else
							append blank in cli	
						endif				

						This.ActualizarClienteLince( lnCodCli, tcNombre, 2 )
					endif
				endif
				
			catch to loError
				throw loError
			finally	
				if used("cli")
					use in select("cli")
				endif
			endtry
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarClienteLince( pcCodcli as String, pcNombre as String, tnEstado as Integer ) as Void

		replace cli.CLCOD with alltrim( pcCodcli  ),;
				cli.clnom with alltrim( pcNombre ) ,;
				cli.clestado with tnEstado in cli

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExistenClientesAMigrar( lcAlias as String ) as Void
		local llHayDatos as Boolean
		llHayDatos = .F.
		
		if used( lcAlias )
			if reccount( lcAlias ) > 0
				llHayDatos = .T.
			endif
		else
			llHayDatos = .T.
		endif
		
		return llHayDatos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MigrarRazonSocial() as Void
		local lcCBU1 as String, lcCBU2 as String, lcCBU1Ant as string, lcCBU2Ant as string,;
			  lcCUITAnt as string, lcCuit as string, llIgual as Boolean, llIgual2 as Boolean, ;
			  loError as Exception

		local lcSentencia as String
		lcSentencia = ""

		if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
		
			lcSentencia = "select * from ZL.Razonsocial"
			godatos.ejecutarSentencias( lcSentencia, "ZL.Razonsocial", "", 'RZSQL', this.DataSessionId )		
			
			try
				if used("RZSQL") and reccount("RZSQL") > 0

					use addbs( _screen.zoo.app.cRutaZoologic ) + "rz" in 0  shared

					wait window "Abriendo vistas..." nowait
					this.AbrirVistas("InternosTodos")
					this.AbrirVistas("EstadoTodos")
					this.AbrirVistas("CorredorTodos")
					wait Clear
									
					select rz
					set order to rzcod in rz

					select RZSQL
					go top in RZSQL
					
					wait window "Migrando Razones sociales..."  nowait
					scan
						
						store "" to lcCBU1, lcCBU2, lcCBU1Ant, lcCBU2Ant, lcCUITAnt, lcCuit
						store .f. to llIgual, llIgual2
							
						if seek( alltrim( RZSql.cmpCod ),"rz")
						else
							append blank in rz
							replace rz.RZCOD with RZSql.cmpCod ,;
								    rz.RZEstado	with 2 ;
							 in rz
						endif

						try
							replace rz.RZCliente	with RZSql.Cliente,;
									rz.RZVersion	with alltrim(str(RZSql.VersionSis,4,2)),;
									rz.rznom	with RZSql.descrip ;
							 in rz
										
							lcCBU1 = iif(!empty(RZSql.cbu),substr(RZSql.cbu,1,3) + "-" + substr(RZSql.cbu,4,4) + "-" + substr(RZSql.cbu,8,1),"")
							lcCBU2 = iif(!empty(RZSql.cbu),substr(RZSql.cbu,9,2) + "-" + substr(RZSql.cbu,11,3) + "-" + substr(RZSql.cbu,14,3) + "-"+substr(RZSql.cbu,17,3) + "-" + substr(RZSql.cbu,20,3),"")
							lcCuit = iif(!empty(RZSql.cuit),substr(RZSql.cuit,1,2)+ "-" + substr(RZSql.cuit,3,8)+ "-" + substr(RZSql.cuit,11,1),"")
									
							if rz.rzsitfiscal <> RZSql.sitfiscal
								This.Loguear( "Se cambio el situacion fiscal de " + alltrim( str ( rz.rzsitfiscal ) ) + " a " + alltrim( str ( RZSql.sitfiscal ) ) + " (RZ: " + alltrim( RZSql.cmpCod ) + ")" )
								replace rz.rzsitfiscal  with iif(RZSql.sitfiscal = 8, 4, RZSql.sitfiscal ) in rz
							endif

							if empty( lcCBU1 )
								llIgual = iif ( strtran( alltrim( rz.rzfcbu1 ),"-","") <> lcCBU1, .F., .T. )
							else
								llIgual = iif ( alltrim( rz.rzfcbu1 ) <> lcCBU1, .F., .T. )									
							endif

							if !llIgual
								lcCBU1Ant = iif(empty(alltrim( rz.rzfcbu1 )), "''",alltrim( rz.rzfcbu1 ))
								This.Loguear( "Se cambio el campo CBU1 de " + lcCBU1Ant + " a " + iif(empty(alltrim( lcCBU1 )),"''",alltrim( lcCBU1 )) + " (RZ: " + alltrim( RZSql.cmpCod ) + ")" )

								replace rz.rzfcbu1 with lcCBU1 in rz
							endif

							if empty( lcCBU2 )
								llIgual2 = iif ( strtran( alltrim( rz.rzfcbu2 ),"-","") <> lcCBU2, .F., .T. )
							else
								llIgual2 = iif ( alltrim( rz.rzfcbu2 ) <> lcCBU2, .F., .T. )									
							endif

							if !llIgual2
								lcCBU2Ant = iif(empty(alltrim( rz.rzfcbu2 )), "''",alltrim( rz.rzfcbu2 ))
								This.Loguear( "Se cambio el campo CBU2 de " + lcCBU2Ant + " a " + iif(empty(alltrim( lcCBU2 )),"''",alltrim( lcCBU2 )) + " (RZ: " + alltrim( RZSql.cmpCod ) + ")" )
								replace rz.rzfcbu2 with lcCBU2 in rz
							endif

							if strtran(alltrim( rz.rzcuit ),"-","") <> alltrim( RZSql.cuit )
								lcCUITAnt = iif(empty(alltrim( rz.rzcuit )), "''",alltrim( rz.rzcuit ))
								This.Loguear( "Se cambio el campo CUIT de " + lcCUITAnt + " a " + iif(empty(alltrim( lcCuit )),"''",alltrim( lcCuit )) + " (RZ: " + alltrim( RZSql.cmpCod ) + ")" )
								replace rz.rzcuit  with lcCuit in rz
							endif
							
							this.ActualizarMedioPago( alltrim( RZSql.medpago ) )
						catch to oErr 
							This.Loguear( "Se producieron errores dando de alta los clientes (codigo de razon social " + RZSql.cmpCod + ")" )
							throw oErr
						endtry
					
					endscan
					wait clear

					This.Loguear( "Finalizo el proceso de migracion de Razones Sociales - " + ttoc( datetime() ) )
				endif
			catch to loError
				throw loError
			finally	
				if used('rz')
					use in select ('rz')
				endif
				
				if used('rzSQL')
					use in select ('rzsql')
				endif
				
			endtry
		endif 			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AbrirVistas( tcVista as String ) as Void
		local lcRuta as String
		if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
			lcRuta = "'" + This.ObtenerRutaVistasZoologic( tcVista ) + "'"
			
			if !used( lcRuta )
				use &lcRuta in 0 shared
			endif
		endif 	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaVistasZoologic( tcVista as String ) as String
		local lcRuta as String
		
		if !empty( This.cBDVistasZoologic )
			lcRuta = alltrim( This.cBDVistasZoologic ) + "!" + alltrim( tcVista )
		endif
		
		return lcRuta
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Finalizar() as Void

		if empty( _screen.zoo.app.cRutaZoologic )
			* Si esta vacio es que nunca se pudo abrir nada
		else	
			if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
				This.CerrarVistasZooLogic()
				This.CerrarBaseDeDatosZooLogic()
			endif 	
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CerrarVistasZooLogic() as Void
 		local array laDatabses(1)

		if ADATABASES( laDatabses ) > 0
			if ascan( laDatabses, This.cBDVistasZoologic, 1,0,0,9 ) > 0
				set database to ( This.cBDVistasZoologic )
				close databases
			endif 
		endif 		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CerrarBaseDeDatosZooLogic() as Void
 		local array laDatabses(1)

		if ADATABASES( laDatabses ) > 0
			if ascan( laDatabses, "Zoo logic", 1,0,0,9 ) > 0
				set database to "Zoo logic"
				close databases
			endif 
		endif 			
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MigrarComAutorizaAtencionMDA() as Void

		local loerror as Exception, llEsDiferente as Boolean
		llEsDiferente = .f.

		if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
			try
				lcSentencia = "select * from ZL.ObtenerEstadosRZAReestablecer()"
				godatos.ejecutarSentencias( lcSentencia, "ObtenerEstadosRZAReestablecer", "", "RZSQL", this.DataSessionId )		
				

				if used("RZSQL") and reccount("RZSQL") > 0
				
					use addbs( _screen.zoo.app.cRutaZoologic ) + "rz" in 0  shared		

					wait window "Abriendo vistas..." nowait
					this.AbrirVistas("InternosTodos")
					this.AbrirVistas("EstadoTodos")
					this.AbrirVistas("CorredorTodos")

					select rz
					set order to rzcod in rz
					
					select RZSQL
					go top

					scan
						if seek(rzsql.razonsoc,"RZ")
							
							llEsDiferente = iif(rz.RZEstado = iif(rzsql.dacodigo,2,3),.f.,.t. )
							
							replace rz.RZEstado with iif(rzsql.dacodigo,2,3) in rz

							if llEsDiferente
								local lcMensajeLogeo as String
								lcMensaje = "Se actualizo el estado de la razon social " + alltrim( rzsql.razonsoc ) + " a " + iif(rzsql.dacodigo, "ACTIVO", "BLOQUEADO")
								This.Loguear( lcMensaje )
							endif
							
						endif								
					endscan

				endif
			catch to loerror
			
				This.Loguear( loerror.Message )
				This.Loguear( loerror.linecontents )
				This.Loguear( loerror.LineNo )
				
			finally
				if used("rzsql")
					use in select("rzsql")
				endif
				
				if used("rz")
					use in select("rz")
				endif
			endtry	
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarMedioPago( tcMedioPago as string, tcLoguear as Boolean ) as Void

		if goParametros.ZL.Altas.HabilitarActualizacionTablasZooLogic
			do case
	        	case upper( alltrim( tcMedioPago ) ) = "CC"
					if rz.rzfacsino = 0
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + ;
									"' cambió el medio de pago. Anterior: '" + alltrim( str( rz.rzfacsino ) ) + "' Actual: '0'"
							This.Loguear( lcMensaje )
						endif
						
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 0 in rz
					endif
				case upper( alltrim( tcMedioPago ) ) = "BAN"
					if rz.rzfacsino = 1 and rz.rzftipo = 1
	                else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
									alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - BANSUD'"
							This.Loguear( lcMensaje )
						endif

						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait				                               
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 1 in rz
	                         
	                endif
				case upper( alltrim( tcMedioPago ) ) = "AMEX"
					if rz.rzfacsino = 1 and rz.rzftipo = 2
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
										alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - AMEX'"
							This.Loguear( lcMensaje )
						endif
						  
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 2 in rz
					 
					endif
				case upper( alltrim( tcMedioPago ) ) = "MASTER"
					if rz.rzfacsino = 1 and rz.rzftipo = 3
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
									alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - MASTER'"
							This.Loguear( lcMensaje )
						endif
						  
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 3 in rz
					endif
				case upper( alltrim( tcMedioPago ) ) = "VISA"
					if rz.rzfacsino = 1 and rz.rzftipo = 4
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
									alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - VISA'"
							This.Loguear( lcMensaje )
						endif
						  
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 4 in rz
					endif
				case upper( alltrim( tcMedioPago ) ) = "FRA"
					if rz.rzfacsino = 1 and rz.rzftipo = 5
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
							alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - FRANCES'"
							This.Loguear( lcMensaje )
						endif
						  
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 5 in rz
					endif
				case upper( alltrim( tcMedioPago ) ) = "PRE"
					if rz.rzfacsino = 1 and rz.rzftipo = 6
					else
						if tcLoguear
							lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' cambió el medio de pago. Anterior: '" + ;
							alltrim( this.DevolverValorAnterior( rz.rzfacsino, rz.rzftipo ) ) + "' Actual: 'Si - PREPAGO'"
							This.Loguear( lcMensaje )
						endif
						  
						wait window "Actualizando " + alltrim( str( recno( "RZSql" ) ) ) + " de " + alltrim( str( reccount( "RZSql" ) ) ) nowait
						replace rz.rzfacsino with 1 in rz
						replace rz.rzftipo with 6 in rz
					endif
				otherwise
					if tcLoguear
						lcMensaje = "La razón social '" + alltrim( RZSQL.cmpcod ) + "' no se migró porque tiene un medio de pago no válido: '" + upper( alltrim( RZSQL.medpago ) ) + "'"
						This.Loguear( lcMensaje )
					endif
	       endcase
		endif  
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function LoguearActualizarMedioPago( tcMensaje as String, tlLoguear as Boolean ) as Void
		if tlLoguear
			This.Loguear( tcMensaje )
		endif
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ImpactarProcesoBancarioEnLince( tnNumero as Integer ) as Void
		local lcSentencia as String, loColeccion as Collection, loItem as Object
		
		loColeccion = newobject( "collection" )		
		lcSentencia = "Select D.RazSoc, D.nPresen from DEVBCO D inner join RECMOT R on R.ccod = D.Motivo "
		lcSentencia = lcSentencia  + "where funciones.Empty( ImpacZL ) = 1 and R.EsRechazo = 1"

		goDatos.EjecutarSentencias( lcSentencia, "DEVBCO,RECMOT", "", 'c_SinImpacto', this.DataSessionId )

		select c_SinImpacto
		scan 
			loItem = createobject( "ItemRechazo" )
			loItem.Numero = 600000000 + c_SinImpacto.nPresen
			loItem.RazonSocial = c_SinImpacto.RazSoc
			loColeccion.Add( loItem )
		endscan 
		
		this.MigrarProcesoBancarioALince( loColeccion )
		this.ActualizarPendientes( tnNumero )
				
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function AbrirVal( tcRuta as String ) as Void
		local lcRutaTabla as String, lcRutaIDX as String, loError as Exception, loEx as ZooException of ZooException.prg
		
		lcRutaTabla = addbs( alltrim( tcRuta  ) ) + iif( "\DBF" $ alltrim( upper( tcRuta  ) ), "" , addbs( "DBF" ) )
		lcRutaIDX = addbs( left( alltrim( lcRutaTabla ),len( lcRutaTabla )-4) + "IDX" )

		try
			use (lcRutaTabla + "Val") in 0 shared
		catch to loError
			loEx = _screen.zoo.crearObjeto("ZooException")
			with loEx
				.AgregarInformacion( "Error al abrir val.dbf: (" + loError.Message + ")" )
			endwith
			throw loEx
		endtry

		try
			select val 

			set index to ( lcRutaIDX + "val1" )
			set index to ( lcRutaIDX + "val2" ) additive
			set index to ( lcRutaIDX + "val3" ) additive
			set index to ( lcRutaIDX + "val4" ) additive
			set index to ( lcRutaIDX + "val5" ) additive
			set index to ( lcRutaIDX + "val6" ) additive
			set index to ( lcRutaIDX + "val7" ) additive

			set order to val4
	
		catch to loError
			loEx = _screen.zoo.crearObjeto("ZooException")
			with loEx
				.AgregarInformacion( "Error al cargar los indices: (" + loError.Message + ")" )
			endwith
			throw loEx
		endtry

	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AbrirCTB( tcRuta as String ) as Void
		local lcRutaTabla as String, lcRutaIDX as String, loError as Exception, loEx as ZooException of ZooException.prg
		
		lcRutaTabla = addbs( alltrim( tcRuta  ) ) + iif( "\DBF" $ alltrim( upper( tcRuta  ) ), "" , addbs( "DBF" ) )
		lcRutaIDX = addbs( left( alltrim( lcRutaTabla ),len( lcRutaTabla )-4) + "IDX" )

		try
			use (lcRutaTabla + "CTB") in 0 shared
		catch to loError
			loEx = _screen.zoo.crearObjeto("ZooException")
			with loEx
				.AgregarInformacion( "Error al abrir ctb.dbf: (" + loError.Message + ")" )
			endwith
			throw loEx
		endtry

		try
			select ctb 

			set index to ( lcRutaIDX + "ctb1" )
			set index to ( lcRutaIDX + "ctb2" ) additive
			set index to ( lcRutaIDX + "ctb3" ) additive
			set index to ( lcRutaIDX + "ctb4" ) additive
			set index to ( lcRutaIDX + "ctb5" ) additive
			set index to ( lcRutaIDX + "ctb6" ) additive
	
		catch to loError
			loEx = _screen.zoo.crearObjeto("ZooException")
			with loEx
				.AgregarInformacion( "Error al cargar los indices: (" + loError.Message + ")" )
			endwith
			throw loEx
		endtry

	endfunc
	*-----------------------------------------------------------------------------------------
	protected function QuitarCuponesDePresentacion( toRechazo as ItemRechazo of actualizarzoopercep.prg ) as Integer
		local lnRetorno as Integer 

		lnRetorno = 0
		try
			update val set jjbjnum = 0,;
					jjbjfch = ctod(''), ;
					jjbjcli = space(0), ;
					jjobs = alltrim( str( val( Val.jjObs ) + 1 ) ), ;
					jjcuotas = 0, ;
					jjcuotot = 0, ;
					jjdias = 0, ;
					jjTarje	= space(0), ;
					jjAcfCup = ctod(''), ;
					jjAcNum	= 0, ;
					jjAcCod	=  '', ;
					jjHabil	= 0 ;
				where Val.Jjbjnum = toRechazo.Numero ;
						and upper( alltrim( Val.Jjcli )) == upper( alltrim( toRechazo.RazonSocial ))
			lnRetorno = _tally

		catch to loError
			loEx = _screen.zoo.crearObjeto("ZooException")
			with loEx
				.AgregarInformacion( "Error al blanquear el cupon RZ: " + upper( alltrim( loRechazo.RazonSocial )) + " de la presentacion " + transform(  loRechazo.Numero )  + ": (" + loError.Message + ")" )
			endwith
			throw loEx
		endtry

		return lnRetorno 
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MigrarProcesoBancarioALince( loRechazos as Collection) as Void
		local i as Integer, lnCont as Integer, lnProcesados as Integer, lnIni as Integer, lnFin as Integer
		
		lnCont = 0
		this.AbrirVal(_Screen.Zoo.App.cRutaLince )

		this.LogueoArchivo( "Comienzo proceso de rechazos - " + TTOC(datetime()) )

		this.InformarProgresoProcesoDeRechazos("Procesando rechazos bancarios")
		
		lnIni = seconds()
		for i = 1 to loRechazos.Count

			lnProcesados = this.QuitarCuponesDePresentacion( loRechazos.Item[i] )	
			
			if lnProcesados > 0
				lnCont = lnCont + 1
			else
				this.LogueoArchivo( "No se procesaron rechazos para la RZ: " + upper( alltrim( loRechazos.Item[i].RazonSocial )) + " de la presentacion " + transform(  loRechazos.Item[i].Numero ) )
			endif
		endfor
		lnFin = seconds()

		this.InformarProgresoProcesoDeRechazos()

		if lnCont # loRechazos.Count
			this.LogueoArchivo( "No se procesaron todos los registros, cantidad " + transform( loRechazos.Count ) + " se procesaron " + transform( lnCont ) )
			this.EnviarInformacion( "No se procesaron todos los registros, cantidad " + transform( loRechazos.Count ) + " se procesaron " + transform( lnCont ) )
		else
			this.LogueoArchivo( "Todos los registros tuvieron al menos un cupon que procesar (resultado esperado)" )
		endif 

		this.LogueoArchivo( " -- Fin proceso de rechazos (" + transform(lnFin-lnIni) + " segundos) -- " )

		use in select ("Val")
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function InformarProgresoProcesoDeRechazos( tcMensaje ) as Void
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EnviarInformacion( tcMensaje ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarPendientes( tnNumero as Integer ) as Void
		local lcSentencia as String, lnNroComprob as Integer, lcTabla as String	

		lcTabla = "DEVBCO"
		lcSentencia = ""
		lnNroComprob = iif( empty( tnNumero  ), '0', alltrim( transform( tnNumero  ) ) )
		lcSentencia = "Update " + lcTabla + " set impacZL = datetime(), nrocomprob = " + lnNroComprob + " where Empty( ImpacZL ) = .t."
		goServicios.Datos.EjecutarSentencias( lcSentencia, lcTabla, '' )
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LogueoArchivo( tcMensaje as String ) as Void
		strtofile( tcMensaje +chr(13)+chr(10), "logREchazos.txt",1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarInformacionDeErrores( tcMensaje as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LanzarFacturacionEnLince( tcOrigenDeDatos as String, tcRutaLince as String, tdFechaFacturacion as date ) as Collection
		local loInfoProblemasEnFac as Object,loColRetorno as Collection, loColComprobantes as Collection

		loColRetorno = newobject( "Collection" )
		
		if empty( tcOrigenDeDatos )
		else
			with this.oFacturacionLince
				.txtSuc = strtran( upper(iif(empty(tcRutaLince),_Screen.Zoo.App.cRutaLince, tcRutaLince )),"\DBF\", "")
				this.cRutaFacturacionLince = .txtSuc
				.OrigenDeDatos = alltrim( tcOrigenDeDatos )
				.txtFechaFac = iif( empty(tdFechaFacturacion), goServicios.Librerias.ObtenerFecha(), tdFechaFacturacion )
				loColComprobantes = .GenerarFacturasLince()
		
				for each loItem in loColComprobantes foxobject
					loColRetorno.Add( loItem )
				endfor

				loInfoProblemasEnFac = this.oFacturacionLince.ObtenerInformacion()
				this.CargarInformacion( loInfoProblemasEnFac )	
							
			endwith
		endif

		return loColRetorno 		

	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarComprobantesRazonesSocialesIncobrables( tcOrigenDeDatos as String, tcRutaLince as String, tdFechaFacturacion as date ) as Collection

		local lMontoDeudaCupones as Number, ;
				lMontoDeudaCtaCte as Number, loColComprobantes as Collection,;
				loColRetorno as Collection, lcComproBanteCanjeDeValores as String ,;
				loItem as Object, lcComproBanteCobranza as String, lnNotaDeCreditoEnCTB as Integer, ;
				loMem as Object, loInfoProblemasEnNC as Object

		loColRetorno = newobject( "Collection" )

		if empty( tcOrigenDeDatos )
		else		

			lMontoDeudaCtaCte = this.ObtenerMontoDeudaCuentaCorriente( tcOrigenDeDatos )
			lMontoDeudaCupones = this.ObtenerMontoDeudaCupones( tcOrigenDeDatos )

			if this.ValidarCONDICIONDEPAGO( tcOrigenDeDatos , lMontoDeudaCtaCte, lMontoDeudaCupones ) 

				if lMontoDeudaCupones <> 0 or lMontoDeudaCtaCte <> 0
					with this.oFacturacionLince
						.txtSuc = strtran( upper(iif(empty(tcRutaLince),_Screen.Zoo.App.cRutaLince, tcRutaLince )),"\DBF\", "")
						this.cRutaFacturacionLince = .txtSuc
						.txtFechaFac = iif( empty(tdFechaFacturacion), goServicios.Librerias.ObtenerFecha(), tdFechaFacturacion )					
						.OrigenDeDatos =  iif( empty( tcOrigenDeDatos ), "", tcOrigenDeDatos ) 
						.MontoDeudaCupones = lMontoDeudaCupones 
						.MontoDeudaCtaCte = lMontoDeudaCtaCte 
						loColComprobantes = .GenerarNotasDeCreditoLince()
						
						for each loItem in loColComprobantes foxobject
							loColRetorno.Add( loItem )
						endfor
				
					endwith 

					loInfoProblemasEnNC = this.oFacturacionLince.ObtenerInformacion()
					this.CargarInformacion( loInfoProblemasEnNC )
					
					if loInfoProblemasEnNC.Count = 0 and loColRetorno.Count > 0   && Si no se genero la NC no genero Cobranza ni canje de Valores.

						if lMontoDeudaCupones > 0 	&&and this.oFacturacionLince.MontoDeudaCupones = 0

							lcComproBanteCanjeDeValores = this.GeneraCanjeDeValoresEnLince( tcOrigenDeDatos )
							if !empty( lcComproBanteCanjeDeValores )
								loColRetorno.Add( lcComproBanteCanjeDeValores )
							endif 	
						endif	
				
						if lMontoDeudaCtaCte > 0	&&and this.oFacturacionLince.MontoDeudaCtaCte = 0
							lnNotaDeCreditoEnCTB = val( strtran( alltrim( substr( loColRetorno.Item[ 1 ], 21 ) ), "-", "") ) + 300000000
							if !used( "Ctb" )
								this.Abrirctb( this.cRutaFacturacionLince )  &&_Screen.Zoo.App.cRutaLince
							endif 	

							if used ( "C_DeudaCuentaCorriente" ) and !empty( lnNotaDeCreditoEnCTB )
								select Ctb
								set order to Ctb1
								seek lnNotaDeCreditoEnCTB 
								if found()  &&inserto los Comprobantes generados x la NC al cursor de pendientes
									scan while Ctb.cNum = lnNotaDeCreditoEnCTB 
										scatter name loMem
										insert into C_DeudaCuentaCorriente from name loMem
									endscan  
								endif 
							endif 

							lcComproBanteCobranza = this.GenerarCobranza()
							use in select( "Ctb" )
							
							if !empty( lcComproBanteCobranza )
								loColRetorno.Add( lcComproBanteCobranza )
							endif 					
							
						endif 	
					endif 
				endif 
			else
				this.AgregarInformacion( 'Esta acción No puede realizarse, la Razón social ' + tcOrigenDeDatos + ;
					' tiene un medio de pago distinto al de la deuda, se recomienda usar la herramienta de Normalización de deuda.' )
			endif 
		endif 
		
		return loColRetorno 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDeudaCuentaCorriente( tcRazonSocial as String ) as Number
		local lcSql as String, lnMonto as Number, lcTabla as String 
		
		lcTabla = this.ObtenerEsquemaTablaSQL( "ctb" )

		lcSql = "SELECT cnum, cven, ccue, cfch, cvto, cpar, cm1, cm2," + ;
					  "cs1, cs2, ctxto, cseq, cref, cusu, ctotal, civa1," + ;
					  "civa2, cxiva1, cxiva2, cefec, cdolares, ctarjeta," + ;
					  "ccheque, ccte, ccambio, cvuelto, cobs, csh1, cpodes," + ;
					  "cdescu, ct101, ct401, ccorre " + ;
					  "FROM " + lcTabla + " ctb " +;
					" where ctb.cs1 <> 0 " +;
					" and cnum < 900000000 and ccue = '" + tcRazonSocial + "'" + ;
					" order by cfch"
	
		This.EjecutarSentencia( lcSql, "C_DeudaCuentaCorriente", set("Datasession" ) )
		
		lnMonto = 0

		if used( "C_DeudaCuentaCorriente" ) and reccount( "C_DeudaCuentaCorriente" ) > 0
			sum C_DeudaCuentaCorriente.cs1 to lnMonto 
		endif 

		return lnMonto

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDeudaCupones( tcRazonSocial as String ) as Number
		local lcSql as String, lnMonto as Number, lcTabla as String 
		
		lcTabla = this.ObtenerEsquemaTablaSQL( "val" ) 

		lnMonto = 0

		lcSql = "select isnull(sum(va.JJM),0) as Monto " +;
      			"FROM " + lcTabla + " va WHERE " +;
      			"( JJT=3 AND (JJbjNUM=0 or JJbjNUM is null) AND JJNU>0 ) " +;
                " and jjcli = '" + tcRazonSocial + "'"

		this.EjecutarSentencia( lcSql, "C_DeudaCupones", set("Datasession" ) )

		if used( "C_DeudaCupones" ) and reccount( "C_DeudaCupones" ) > 0
			sum C_DeudaCupones.Monto to lnMonto 
		endif 
		
		return lnMonto		
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerEsquemaTablaSQL( tcTabla as String ) as String 
		return "CtasCtes.Vista_ZOO_SA_" + tcTabla
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function EjecutarSentencia( tcSql, tcCursor, tnIdSesion ) as VOID 
		goServicios.Datos.EjecutarSQL( tcSql, tcCursor, tnIdSesion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GeneraCanjeDeValoresEnLince( tRazonSocial as String ) as String
		local lcComprobante as String, ldFecha as date , lnMontoAjuste as number , lnSelect as Integer 
		
		this.AbrirVal( this.cRutaFacturacionLince )  &&_Screen.Zoo.App.cRutaLince
		ldFecha = goServicios.Librerias.ObtenerFecha()
		lnNumeroCanje = this.ObtenerNumeroCanje()
		lnTipoValor = 1
		lcCodigoValor = "AJ"
		lcDescripcion = "AJUSTE PES"
		lnImporte = 0.01
		lcVendedor = "ZOO"
		
		lnselect = select()
		
		select sum( jjTotFac ) as MontoAjuste ;
				from val ;
					where ( jjNum < 800000000 or  jjNum > 899999999 ) ;
						and val.jjcli = tRazonSocial ;
						and jjt = 3 ;
						and empty( val.jjbjnum )  ;
				into cursor cur_XXX_SaldoValores
		
		select 	cur_XXX_SaldoValores
		lnMontoAjuste = cur_XXX_SaldoValores.MontoAjuste
		use in select(  'cur_XXX_SaldoValores.MontoAjuste' )
		select( lnSelect ) 
		
		insert into val ;
			(jjNum, jjT, jjCo, jjFe, jjDe, jjNu, jjM, jjCli, jjFecha, jjVen, jjTotFac, jjTurno, jjCotiz);
			values;
			( lnNumeroCanje, lnTipoValor, lcCodigoValor, ldFecha, lcDescripcion, 0,;
			lnImporte, tRazonSocial, ldFecha, lcVendedor, lnImporte, 1, 1)

	
		if (lnImporte * -1 + lnMontoAjuste ) <> 0 
			insert into val ;
				(jjNum, jjT, jjCo, jjFe, jjDe, jjNu, jjM, jjCli, jjFecha, jjVen, jjTotFac, jjTurno, jjCotiz);
				values;
				( lnNumeroCanje, lnTipoValor, lcCodigoValor, ldFecha, lcDescripcion, 0,;
				lnImporte * -1+ lnMontoAjuste , tRazonSocial, ldFecha, lcVendedor, lnImporte, 1, 1)
		endif 

		update val set jjbjcli = tRazonSocial, jjbjfch = ldFecha , jjbjnum = lnNumeroCanje ;
					where ( jjNum < 800000000 or  jjNum > 899999999 ) and val.jjcli = tRazonSocial and ;
					jjt = 3 and ;
					empty( val.jjbjnum )

		use in select( "Val" )
		
		lcComprobante = "Canje de valores Nº " + transform( lnNumeroCanje - 800000000 )
		
		return lcComprobante
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroCanje() as Integer 
        local lnRetorno as Integer
        lnRetorno = 800000001   

        select val
        set order to val1 desc
        
        set near on
        seek 899999999
        set near off
        
        if ( between(val.jjnum, 800000000, 899999999) )
        	lnRetorno = val.jjnum + 1
        endif

        return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarCobranza() as string 
		local lnNumeroCobranza, lnNumeroRecibo, lnSecuencia, ldFecha,;
			lcComprobante as String, lccTxtO as String, lcRutaTabla as String  
		
		this.AbrirVal( this.cRutaFacturacionLince )  &&_Screen.Zoo.App.cRutaLince
		if !used( "Ctb" )
			this.AbrirCTB( this.cRutaFacturacionLince )  &&_Screen.Zoo.App.cRutaLince 
		endif 	
		select Ctb
		set order to ctb4
		lcRutaTabla = addbs( alltrim( this.cRutaFacturacionLince  ) ) + iif( "\DBF" $ alltrim( upper( this.cRutaFacturacionLince  ) ), "" , addbs( "DBF" ) )
		use ( alltrim( lcRutaTabla ) + "X.dbf" ) in 0	&&_Screen.Zoo.App.cRutaLince
			
		ldFecha = goServicios.Librerias.ObtenerFecha()
		lnNumeroRecibo = this.ObtenerNumeroRecibo()
		lnNumeroCobranza = 200000000 + lnNumeroRecibo			

		select C_DeudaCuentaCorriente	
		**OJO QUE ACA FALTA LA NOTA DE CREDITO QUE ACABO DE DAR DE ALTA ;-)
		scan 
			
			lnSecuencia = this.ObtenerNumeroSecuencia()
			lccTxtO = "Rec X 0001-" + padl( lnNumeroRecibo, 8, "0" ) + " " + alltrim( C_DeudaCuentaCorriente.ctxto )
		
			insert into ctb ( cNum, cCue, cFch, cVto, cPar, cM1, cM2, cS1, cS2, cTxtO, cTotal, cTurno, cSh1, cCheque, cseq, cref, cven) values;
				( lnNumeroCobranza, C_DeudaCuentaCorriente.cCue, ldFecha , ldFecha , 1,;
				C_DeudaCuentaCorriente.cS1*-1, C_DeudaCuentaCorriente.cS2*-1 , 0, 0,;
				lccTxto , 0, 1, C_DeudaCuentaCorriente.cS1*-1, 0, lnSecuencia, C_DeudaCuentaCorriente.cSeq, "ZOO" )
			
			select ctb
			seek C_DeudaCuentaCorriente.cSeq
			if found()
				replace cs1 with 0, cs2 with 0
			endif 
			select 	C_DeudaCuentaCorriente
			
		endscan 
		
		this.ActualizarNumero( lnNumeroRecibo )
		
		use in select( "Val" )		
		use in select( "X" )		

		lcComprobante = "Cobranza Nº " + transform( lnNumeroRecibo )
		
		return lcComprobante

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroRecibo() as Integer
		local lnSelect as integer, lnRetorno as Integer 
		lnSelect = select()
		select x
		lnRetorno = x.xreca + 1
		select( lnSelect )
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoInterno( tnTipo ) as Integer
		local lnRetorno as Integer, lnSelect as Integer 
		lnSelect = select()
		select ( max( jjnu ) ) as proximo from val where jjt = tnTipo into cursor cProximo
		lnRetorno = cProximo.proximo + 1
		use in select( "cProximo" )
		select( lnSelect )
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroSecuencia() as Integer 
		local lnSelect as integer, lnRetorno as Integer 
		lnSelect = select()
		select x
		lnRetorno = x.xsqc + 1
		replace x.xsqc with lnRetorno 
		select( lnSelect )
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarNumero( tnNumero as Integer) as Void
		local lnSelect as integer
		lnSelect = select()
		select x
		replace x.xreca with tnNumero
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oFacturacionLince.release()
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCONDICIONDEPAGO( tcRazonSocial , tMontoDeudaCtaCte, tMontoDeudaCupones ) as Boolean 
		local lcSql as String, lcTabla as String , lRetorno as Boolean, lcCursor as String, lnSelect  as Integer   
		
		lnSelect  = select()
		lRetorno = .f.
		lcCursor = 'c' + sys( 2015 )
		lcTabla = this.ObtenerEsquemaTablaSQL( "Cli" ) 

		text to lcSql textmerge noshow
			select 
				(case 
				when medPago IN ( 'AMEX', 'BAN', 'FRA', 'MASTER' , 'VISA' ) then 'T'  
				when medPago IN ( 'PRE', 'CC' ) then 'C'
				else '' end)   as Tipo
			FROM ZL.RazonSocial 
			WHERE Cmpcod = '<<tcRazonSocial>>'		
		endtext 
	
		This.EjecutarSentencia( lcSql, lcCursor, set("Datasession" ) )

		if used( lcCursor ) and reccount( lcCursor ) > 0
			select &lcCursor
			if ( tMontoDeudaCtaCte <> 0 and tMontoDeudaCupones = 0 and &lcCursor..Tipo = 'C' ) or ( tMontoDeudaCtaCte = 0 and tMontoDeudaCupones <> 0 and &lcCursor..Tipo = 'T' ) 
				lRetorno = .t.
			endif 
		endif

		use in select( lcCursor )
		select( lnSelect )
		
		return lRetorno 
	endfunc 

enddefine

*************************************************************************************************
define class ItemRechazo as custom

	Numero = 0
	RazonSocial = ""

enddefine
