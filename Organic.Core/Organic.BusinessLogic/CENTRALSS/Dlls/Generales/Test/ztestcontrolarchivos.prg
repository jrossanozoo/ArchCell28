Define Class ztestcontrolarchivos As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As ztestcontrolarchivos Of ztestcontrolarchivos.prg
	#Endif

	*-----------------------------------------------------------------------------------------g
	function zTestActualizarArchivos
		local loControl as Object, lcOrig as String, lcNov as string, lnH as integer, ;
			llOk as boolean, lcalias as string, loManejo as object, lcDelete as string

		loControl = newobject( "ControlArchivos", "c:\zoo\autobuild\ControlArchivos.prg" )
		loControl.lModifica = .t.

		loManejo = newobject( "ManejoArchivos", "ManejoArchivos.prg" )

		lcDelete  = set("Deleted")
		set deleted on
		lcAlias = loControl.cTabla 
		use in select( lcAlias )
		
		*****
		lcOrig = lower( Addbs( Sys( 2023 ) ) + "zooTmp\Orig\" )
		lcNov = lower( Addbs( Sys( 2023 ) ) + "zooTmp\Nov\" )

		loManejo.BorrarCarpeta( lcOrig )
		loManejo.BorrarCarpeta( lcNov )

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		this.assertequals( "Error log. (1)", 3, reccount( lcAlias ) )	&&solo la cabecera

		****		
		select ( lcAlias )
		zap
		
		md ( lcOrig )
		md ( lcNov )

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		this.assertequals( "Error log. (3)", 3, reccount( lcAlias ) )	&&solo la cabecera

		****		
		select ( lcAlias )
		zap
		
		create table ( lcNov + "Nov.dbf" ) free ( C1 c(1) )
		
		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom 
		this.assertequals( "Error log. (4)", "- ERROR Copiando: File is in use.", alltrim( &lcAlias..txt ) )
		skip -1
		this.assertequals( "Error log. (5)", "Copiando", alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (5)", "Existe en Novedades y no en Origen", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (5)", lcOrig, alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (5)", lcNov, alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (5)", "nov.dbf", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "No debe copiar (5)", !file( lcOrig + "Nov.dbf" ) )

		****		
		select ( lcAlias )
		zap
		
		use in select ( "Nov" )
		
		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom 
		this.assertequals( "Error log. (6)", "Copiando", alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (6)", "Existe en Novedades y no en Origen", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (6)", lcOrig, alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (6)", lcNov, alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (6)", "nov.dbf", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "No copio (6)", file( lcOrig + "Nov.dbf" ) )

		****		
		select ( lcAlias )
		zap
		
		create table ( lcOrig + "Orig.dbf" ) free ( C1 c(1) )

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom 
		this.assertequals( "Error log. (7)", "- ERROR Borrando: File is in use.", alltrim( &lcAlias..txt ) )
		skip -1
		this.assertequals( "Error log. (8)", "Borrando", alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (8)", "Existe en Origen y no en Novedades", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (8)", lcOrig, alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (8)", "", alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (8)", "orig.dbf", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "No debe borrar (8)", file( lcOrig + "Orig.dbf" ) )
		
		****		
		select ( lcAlias )
		zap
		
		use in select ( "Orig" )
		
		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom 
		this.assertequals( "Error log. (9)", "Borrando", alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (9)", "Existe en Origen y no en Novedades", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (9)", lcOrig, alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (9)", "", alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (9)", "orig.dbf", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "Debe borrar (9)", !file( lcOrig + "Orig.dbf" ) )

		****		
		select ( lcAlias )
		zap
		
		create table ( lcOrig + "Nov.dbf" ) free ( C1 c(1) )
		use
		
		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		this.assertequals( "Error log. (10)", 3, reccount( lcAlias ) )	&&solo la cabecera

		****		
		inkey(3)

		select ( lcAlias )
		zap
		
		select 0
		use ( lcNov + "Nov.dbf" )
		append blank
		replace C1 with "P"

		use

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom
		this.assertequals( "Error log. (11)", "Copiando", alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (11)", "Actualizado desde Novedades", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (11)", lcOrig, alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (11)", lcNov, alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (11)", "nov.dbf", alltrim( &lcAlias..Archivo ) )

		****		
		select ( lcAlias )
		zap
		
		md ( lcNov + "\SubNov" )
		create table ( lcNov + "\SubNov\Nov.dbf" ) free ( C1 c(1) )
		use
		md ( lcNov + "\SubNov\SubSubNov" )
		create table ( lcNov + "\SubNov\SubSubNov\Nov.dbf" ) free ( C1 c(1) )
		use

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom
*		this.assertequals( "Error log. (12)", "Copiando carpeta", alltrim( &lcAlias..txt ) )
*		this.assertequals( "Error log (Motivo). (12)", "Existe en Novedades y no en Origen", alltrim( &lcAlias..Motivo ) )
*		this.assertequals( "Error log (DirOrig). (12)", "", alltrim( &lcAlias..DirOrig ) )
*		this.assertequals( "Error log (DirNov). (12)", lcNov + "subnov\subsubnov", alltrim( &lcAlias..DirNov ) )
*		this.assertequals( "Error log (Archivo). (12)", "", alltrim( &lcAlias..Archivo ) )
*		skip -1
		this.assertequals( "Error log (DirNov). (12)", lcNov + "subnov", alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (12)", "", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "Debe copiar la carpeta y sus subcarpetas (12)", directory( lcOrig + "\SubNov\SubSubNov" ) )
		this.assertTrue( "Debe copiar el archivo (1)", file( lcOrig + "\SubNov\Nov.dbf" ) )
		this.assertTrue( "Debe copiar el archivo (2)", file( lcOrig + "\SubNov\SubSubNov\Nov.dbf" ) )
		
		****		
		select ( lcAlias )
		zap
		
		md ( lcOrig + "\SubOrig" )
		create table ( lcOrig + "\SubOrig\Orig.dbf" ) free ( C1 c(1) )
		use
		md ( lcOrig + "\SubOrig\SubSubOrig" )
		create table ( lcOrig + "\SubOrig\SubSubOrig\Orig.dbf" ) free ( C1 c(1) )
		use

		lcalias = loControl.VerificarCarpetas( lcOrig, lcNov )

		select ( lcAlias )
		go bottom

		this.assertequals( "Error log. (13)", "Borrando carpeta" , alltrim( &lcAlias..txt ) )
		this.assertequals( "Error log (Motivo). (13)", "Existe en Origen y no en Novedades", alltrim( &lcAlias..Motivo ) )
		this.assertequals( "Error log (DirOrig). (13)", lcOrig + "suborig", alltrim( &lcAlias..DirOrig ) )
		this.assertequals( "Error log (DirNov). (13)", "", alltrim( &lcAlias..DirNov ) )
		this.assertequals( "Error log (Archivo). (13)", "", alltrim( &lcAlias..Archivo ) )
		this.assertTrue( "Debe borrar la carpeta y sus subcarpetas (13)", !directory( lcOrig + "\SubOrig\SubSubOrig" ) )
		this.assertTrue( "Debe borrar la carpeta y sus subcarpetas (13.2)", !directory( lcOrig + "\SubOrig" ) )
		this.assertTrue( "Debe borrar el archivo (1)", !file( lcOrig + "\SubOrig\Orig.dbf" ) )
		this.assertTrue( "Debe borrar el archivo (2)", !file( lcOrig + "\SubOrig\SubSubOrig\Orig.dbf" ) )
		
		***********
		use in select ( "Nov" )
		use in select ( "Orig" )
		
		use in select( lcAlias )
		
		loControl = null

		set deleted &lcDelete
	endfunc 

	
Enddefine
