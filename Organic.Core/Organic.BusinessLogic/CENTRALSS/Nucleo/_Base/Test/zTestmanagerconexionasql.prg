**********************************************************************
Define Class zTestmanagerconexionasql As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As zTestmanagerconexionasql Of zTestmanagerconexionasql.PRG
	#Endif
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerObtenerNuevaConexion
		local loVFPx as object, lcString as String
		loVFPx = CREATEOBJECT( "VisualFoxPro.Application.9" )

		try
			loVFPx.Caption = "0"
			loVFPx.DoCmd( [use "] + addbs( _screen.zoo.cRutaInicial ) + "..\taspein\data\" + [relaciones.dbf" Again Shared  In 0] )
			loVFPx.DoCmd( [use "] + addbs( _screen.zoo.cRutaInicial ) + "..\taspein\data\" + [SubProyectos.dbf" Again Shared  In 0] )
			loVFPx.DoCmd( [use "] + addbs( _screen.zoo.cRutaInicial ) + "..\taspein\data\" + [Proyectos.dbf" Again Shared  In 0] )
			loVFPx.DoCmd( [use "] + addbs( _screen.zoo.cRutaInicial ) + "..\taspein\data\" + [FormDuros.dbf" Again Shared  In 0] )

			loVFPx.DoCmd( [loManagerTasPein = newobject( "ManagerTaspein", "] + addbs( _screen.zoo.cRutaInicial ) + "..\taspein\manager\" + [ManagerTaspein.prg" )] )
			loVFPx.DoCmd( [loManagerTasPein.SetearPathDelSubProyecto( 37 )] )
			loVFPx.DoCmd( [loManagerTasPein.InstanciarZooAplicacion( 37 )] )
			loVFPx.DoCmd( [pp = _screen.zoo.CrearObjeto( "ZooLogicSA.Core.ManagerLogueo" )] )

			lcString = 	"Driver={" + goLibrerias.obtenerdatosdeini( addbs( _screen.zoo.app.cRutaDataConfig ) + "dataconfig.ini", "SQL", "Driver" ) + "}" + ;
						";Server=" + goLibrerias.obtenerdatosdeini( addbs( _screen.zoo.app.cRutaDataConfig ) + "dataconfig.ini", "SQL", "Servidor" ) + ;
						";Database=" + goLibrerias.obtenerdatosdeini( addbs( _screen.zoo.app.cRutaDataConfig ) + "dataconfig.ini", "SQL", "BaseDeDatos" ) + ;
						";Trusted_Connection=Yes"

			loVFPx.DoCmd( " _vfp.Caption = transform( sqlstringconnect( '" + lcString + "' ) ) " )

			This.asserttrue( "Error en la DLL de Logueos. Tiene conflicto con las conexiones a SQL." + chr( 13 ) + lcString , val( loVFPx.Caption ) > 0 )
		catch to loError
			This.asserttrue( "Error al querer correr el TEST. Verifique el mismo" + chr( 13 ) + ;
				loError.message, .f. )
		finally
			loVFPx.Quit
		endtry

		loVFPx = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestSqlServerSeteoBase
		local lcNombreCursor as String, lcXml as String , lcSqlCmd as String 
		private goDatos
		goDatos = _screen.zoo.crearobjeto( "ServicioDatos" )
		lcNombreCursor = "C_" + sys( 2015 )

		lcXml = goDatos.EjecutarSql( 'DBCC USEROPTIONS' )
		xmltocursor( lcXml, lcNombreCursor, 4 ) 	

		select ( lcNombreCursor )

		locate for upper( alltrim( Set_option ) ) = "LANGUAGE"
		if found()
			This.assertequals( "La opcion de Language para el motor de base de datos Sql." , lower( alltrim( &lcNombreCursor..Value ) ) , "español" )
		else
			This.asserttrue( "No se encontro la opcion de Language para el motor de base de datos Sql.", .f. )
		endif

		locate for upper( alltrim( Set_option ) ) = "ISOLATION LEVEL"
		if found()
			This.assertequals( "La opcion de isolation de las transacciones de la conexión no es la correcta.", "READ COMMITTED SNAPSHOT" , upper( alltrim( &lcNombreCursor..Value ) ) )
		else
			This.asserttrue( "No se encontro la opcion de Isolation para el motor de base de datos Sql.", .f. )
		endif

		lcSqlCmd = "select collation_name, snapshot_isolation_state,is_read_committed_snapshot_on from sys.databases where name = db_name()"
		lcXml = goDatos.EjecutarSql( lcSqlCmd )
		xmltocursor( lcXml, lcNombreCursor, 4 ) 	

		This.assertequals( "La opcion de collation del motor no es la correcta." , ;
				upper( alltrim( &lcNombreCursor..collation_name ) ) , "SQL_LATIN1_GENERAL_CP1_CI_AI" )
				
		This.assertequals( "La opcion de Snapshot del motor no se encuentra activa." , ;
				&lcNombreCursor..snapshot_isolation_state, 1 )

		This.assertequals( "La opcion de READ_COMMITTED_SNAPSHOT ON del motor no se encuentra activa." , ;
				.t., &lcNombreCursor..is_read_committed_snapshot_on )

		use in select( lcNombreCursor )

	endfunc 


enddefine




