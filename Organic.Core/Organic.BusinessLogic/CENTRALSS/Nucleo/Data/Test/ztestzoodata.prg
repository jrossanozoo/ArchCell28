**********************************************************************
Define Class zTestZooData as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestZooData of zTestZooData.prg
	#ENDIF
	
	oZooData = null
	cRuta = ""
	nDataSessionId = 0
	*---------------------------------
	Function Setup
		This.nDataSessionId = set( "Datasession" )
		this.oZooData = newobject( "ZooData", "ZooData.prg" )
		cRuta = _Screen.zoo.ObtenerRutaTemporal()
	EndFunc

	*---------------------------------
	Function TearDown
		this.oZooData.release()
		set datasession to This.nDataSessionId
	EndFunc

	*---------------------------------------------------------------------------------
	function zTestZooData
		this.assertequals( "Instancia ZooData", "O", vartype( this.oZooData ) )	

	endfunc

	*-----------------------------------------------------------------------------------------
	function ztestAbretabla
		local loData as zoodata of zoodata.prg
		local lcTabla As String
		loData = This.oZooData
		lcTabla = sys( 2015 )
		create dbf( This.cRuta + lcTabla ) ( campo1 L )
		use in select( lctabla )
		This.AssertTrue( "Debio haber abierto la tabla " + lcTabla, loData.AbreTabla( lcTabla, , , This.cRuta ) )
		This.AssertTrue( "Debe estar abierta la tabla " + lcTabla, Used( lcTabla ) )
		use in select( lctabla )
		This.AssertTrue( "No Debio haber abierto la tabla " + lcTabla + "DDDDD", !loData.AbreTabla( lcTabla + "DDDDD" , , , This.cRuta ) )
		This.AssertTrue( "No Debe estar abierta la tabla " + lcTabla + "DDDDD" , !Used( lcTabla + "DDDDD" ) )		
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestCierraTabla
		local loData as zoodata of zoodata.prg
		local lcTabla As String
		loData = This.oZooData
		lcTabla = sys( 2015 )
		create dbf( This.cRuta + lcTabla ) ( campo1 L )
		=flock( lcTabla )
		This.AssertTrue( "No Debio haber Cerrado la tabla " + lctabla, !loData.CierraTabla( lcTabla, .T. ) )
		This.AssertTrue( "No Debe estar Cerrada la tabla " + lctabla, Used( lcTabla ) )
		unlock in ( lcTabla )
		This.AssertTrue( "Debio haber Cerrado la tabla " + lctabla, loData.CierraTabla( lcTabla ) )
		This.AssertTrue( "Debe estar Cerrada la tabla " + lctabla, !Used( lcTabla ) )		
		This.AssertTrue( "No debio haber Cerrado la tabla .F." , !loData.CierraTabla( .F. ) )

	endfunc 
		*-----------------------------------------------------------------------------------------
	function ztestArmarCursor
		local loData as zoodata of zoodata.prg, lcTabla As String
		loData = This.oZooData
		lcTabla = sys( 2015 )
		This.AssertTrue( "Debio haber abierto c_Diccionario", loData.ArmarCursor( "Diccionario" )	)
		This.AssertTrue( "Debio haber abierto c_Diccionario 2", Used( "c_Diccionario" )	)
		This.AssertTrue( "No debe quedar abierto Diccionario", !Used( "Diccionario" )	)

		loData = newobject( "ZooData_Test" )
		This.AssertTrue( "No debio haber abierto c_" + lcTabla, !loData.ArmarCursor( lcTabla )	)
		use in select( "c_Diccionario" )

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestAbrirTablas
		local loData as zoodata of zoodata.prg
		local lcTabla1 As String, lcTabla2 As String, lcTabla3 As String, lcTabla4 as String
		loData = This.oZooData
		lcTabla1 = sys( 2015 )
		lcTabla2 = sys( 2015 )
		lcTabla3 = sys( 2015 )
		lcTabla4 = sys( 2015 )
		create dbf( This.cRuta + lcTabla1 ) ( campo1 L )
		use in select( lctabla1 )
		create dbf( This.cRuta + lcTabla2 ) ( campo1 L )
		use in select( lctabla2 )
		create dbf( This.cRuta + lcTabla3 ) ( campo1 L )
		use in select( lctabla3 )
		This.AssertTrue( "Debio haber abierto todas las tablas", loData.Abrirtablas( lcTabla1 + "," + lcTabla2 + "," + lcTabla3 ) )
		This.AssertTrue( "Debe estar abierta la tabla " + lcTabla1, used( lcTabla1) )
		This.AssertTrue( "Debe estar abierta la tabla " + lcTabla2, used( lcTabla2) )
		This.AssertTrue( "Debe estar abierta la tabla " + lcTabla3, used( lcTabla3) )
		use in select( lcTabla1 )
		use in select( lcTabla2 )
		use in select( lcTabla3 )

		loData = newobject( "ZooData_Test" )
		This.AssertTrue( "No Debio haber abierto todas las tablas", !loData.Abrirtablas( lcTabla1 + "," + lcTabla2 + "," + lcTabla3 + "," + lcTabla4 ) )
		This.AssertTrue( "No debe estar abierta la tabla " + lcTabla4, !used( lcTabla4) )

		use in select( lcTabla1 )
		use in select( lcTabla2 )
		use in select( lcTabla3 )		
		use in select( lcTabla4 )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestCerrarTablas
		local loData as zoodata of zoodata.prg
		local lcTabla1 As String, lcTabla2 As String, lcTabla3 As String, lcTabla4 as String
		loData = This.oZooData
		lcTabla1 = sys( 2015 )
		lcTabla2 = sys( 2015 )
		lcTabla3 = sys( 2015 )
		lcTabla4 = sys( 2015 )
		create dbf( This.cRuta + lcTabla1 ) ( campo1 L )
		create dbf( This.cRuta + lcTabla2 ) ( campo1 L )
		create dbf( This.cRuta + lcTabla3 ) ( campo1 L )
		This.AssertTrue( "Debio haber Cerrado todas las tablas", loData.CerrarTablas( lcTabla1 + "," + lcTabla2 + "," + lcTabla3 + "," + lcTabla4 ) )
		This.AssertTrue( "No Debe estar abierta la tabla " + lcTabla1, !used( lcTabla1) )
		This.AssertTrue( "No Debe estar abierta la tabla " + lcTabla2, !used( lcTabla2) )
		This.AssertTrue( "No Debe estar abierta la tabla " + lcTabla3, !used( lcTabla3) )

		loData = newobject( "ZooData_Test" )
		This.AssertTrue( "Debio haber dado error", !loData.CerrarTablas( lcTabla1 + "," + lcTabla2 + "," + lcTabla3 + "," + lcTabla4 ) )

	endfunc 

EndDefine

define class ZooData_Test as ZooData
	*-----------------------------------------------------------------------------------------
	function AbreTabla() as Void
		local loError As zooException of zooException.prg
		loError = Newobject( "ZooException", "ZooException.prg" )
		loError.Throw()
	endfunc 
	function CierraTabla() as Void
		local loError As zooException of zooException.prg
		loError = Newobject( "ZooException", "ZooException.prg" )
		loError.Throw()
	endfunc 
enddefine

