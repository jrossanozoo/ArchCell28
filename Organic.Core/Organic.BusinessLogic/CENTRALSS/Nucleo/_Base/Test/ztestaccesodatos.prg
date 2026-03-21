**********************************************************************
Define Class zTestAccesoDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestAccesoDatos of zTestAccesoDatos.prg
	#ENDIF
	
	oAccesoDatos = null
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*-----------------------------------
	function zTestAbrirTabla
		local lcTabla as string, lcRuta as String, llRetorno as Boolean
		local goAccesoDatos as "AccesoDatos" of "AccesoDatos.prg"
		goAccesoDatos = _screen.Zoo.Crearobjeto( "AccesoDatos" )
		
		lcRuta = addbs( curdir() )
		lcTabla = sys( 2015 )
		
		create table ( lcRuta + lcTabla ) free ( cod N( 3 ) )
		use in ( lcTabla )

		
		with this
			llRetorno = goAccesoDatos.AbrirTabla( lcTabla , .T., lcRuta, 'ZtestAliasE' )
			.asserttrue( "No se abrio la tabla Exclusiva", llRetorno ) 
			goAccesoDatos.CerrarTabla( "ZtestAliasE" )

			llRetorno = goAccesoDatos.AbrirTabla( lcTabla , .f., lcRuta, 'ZtestAlias' )
			.asserttrue( "No se abrio la tabla", llRetorno ) 
			
			llRetorno = goAccesoDatos.AbrirTabla( lcTabla , .f., lcRuta, 'ZtestAlias1',.t. )
			.asserttrue( "No se abrio 2 veces la tabla", goAccesoDatos.EstaAbierta( "ZtestAlias" ) and llRetorno )

		endwith
		
		goAccesoDatos.CerrarTabla( "ZtestAlias,ZtestAlias1,ZtestAliasE" )
		delete file ( lcRuta + lcTabla )

		release goAccesoDatos

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestCerrarTabla
		local lcTabla as string, lcRuta as String
		local goAccesoDatos as "AccesoDatos" of "AccesoDatos.prg"
*		goAccesoDatos = _screen.Zoo.Crearobjeto( "AccesoDatos" )
		goAccesoDatos = newobject( "AccesoDatos", "AccesoDatos.prg" )
		lcRuta = addbs( sys( 2023 ) )
		lcTabla = sys( 2015 )
		
		create table ( lcRuta + lcTabla ) free ( cod N( 3 ) )
		use in ( lcTabla )
		
		use in 0 ( lcRuta + lcTabla ) alias tabla1 shared 
		use in 0 ( lcRuta + lcTabla ) alias tabla2 shared again
		use in 0 ( lcRuta + lcTabla ) alias tabla3 shared again
		use in 0 ( lcRuta + lcTabla ) alias tabla4 shared again

		with this

			.asserttrue( "No hay tablas abiertas para testear el cierre de las mismas", used( 'tabla1' ) ;
				and used( 'tabla2' ) and used( 'tabla3' ) and used( 'tabla4' ) )
			
			goAccesoDatos.CerrarTabla( 'tabla1' )
			.asserttrue( "No pudo cerrar la tabla1", !used( 'tabla1' ) )

			goAccesoDatos.CerrarTabla( 'tabla2,tabla3,tabla4' )
			.asserttrue( "No pudo cerrar alguna de estas tablas", !used( 'tabla2' ) and ;
					!used( 'tabla3' ) and !used( 'tabla4' ) )
	
		endwith 
		
		
		delete file ( lcRuta + lcTabla )
		release goAccesoDatos

	endfunc 
	*---------------------------------
	Function TearDown

	EndFunc
	*-----------------------------------
	
EndDefine
