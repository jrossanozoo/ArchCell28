**********************************************************************
Define Class ztestzooInformacion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestzooInformacion of ztestzooInformacion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestInstanciar
		local loZooInformacion as Object
		
		loZooInformacion = _screen.zoo.crearObjeto( "ZooInformacion" )
		
		This.asserttrue( "No se instancio el objeto zooInformacion", vartype( loZooInformacion ) = "O" )
		loZooInformacion.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificaEnlace
		local loInformacion as ZooSession of ZooSession.prg,;
				loInformacion1 as ZooSession of ZooSession.prg ,;
				loInformacion2 as ZooSession of ZooSession.prg, loInfo as Object, loInfo1 as Object		
	
			loInformacion  = newobject( "MockInformacion" )
			loInformacion1 = newobject( "MockInformacion" )
			loInformacion2 = newobject( "MockInformacion" )						

			loInformacion.AddProperty( "oHijo", loInformacion1 )
			loInformacion1.AddProperty( "oNieto", loInformacion2 )	

			loInformacion.enlazar( "oHijo.EventoObtenerInformacion", "InyectarInformacion" )
			loInformacion1.enlazar( "oNieto.EventoObtenerInformacion", "InyectarInformacion" )
			
			loInformacion2.AgregarInformacion( "Informacion" )
			
			This.assertTrue( "No paso por eventoObtenerInformacion del Informacion2", loInformacion2.lPasoPoreventoObtenerInformacion )
			This.assertTrue( "No paso por SetearInformacion del Informacion2", loInformacion2.lPasoPorSetearInformacion )						
			This.assertTrue( "Paso por lPasoPorinyectarInformacion del Informacion2", !loInformacion2.lPasoPorinyectarInformacion )	

			This.assertTrue( "No paso por eventoObtenerInformacion del Informacion1", loInformacion1.lPasoPoreventoObtenerInformacion )
			This.assertTrue( "No paso por SetearInformacion del Informacion1", loInformacion1.lPasoPorSetearInformacion )						
			This.assertTrue( "No paso por lPasoPorinyectarInformacion del Informacion1", loInformacion1.lPasoPorinyectarInformacion )		
			
			This.assertTrue( "Paso por lPasoPorsetearInformacion del Informacion", !loInformacion.lPasoPorsetearInformacion )
			This.assertTrue( "No paso por lPasoPorinyectarInformacion del Informacion", loInformacion.lPasoPorinyectarInformacion )		
			This.assertTrue( "No paso por eventoObtenerInformacion del Informacion", loInformacion.lPasoPoreventoObtenerInformacion )

			loInfo2 = loInformacion2.ObtenerColeccion()
			loInfo1 = loInformacion1.ObtenerColeccion()			
			loInfo = loInformacion.ObtenerColeccion()						
			
			This.assertequals( "El objecto Informacion entre la info1 y Info2 no es el mismo.", loInfo1, loInfo2 ) 
			This.assertequals( "El objecto Informacion entre la info y Info1 no es el mismo.", loInfo, loInfo1 ) 


			loInformacion2.Release			
			loInformacion1.Release
			loInformacion.Release
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestLimpiar 
		local loInfo as zooInformacion of ZooInformacion.prg
		
		loInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
		
		loInfo.agregarinformacion( "Problema 1 " )
		This.assertequals( "No se agrego 1 problema a la coleccion de informacion del ZooInformacion", 1 , loInfo.Count )
		loInfo.Limpiar()
		
		This.assertequals( "No se limpio la coleccion de informacion del ZooInformacion", 0 , loInfo.Count )
		
		loInfo.Release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestSerializarInformacion
		local loInfo as zooInformacion of ZooInformacion.prg, lcSerializado as String, lcValorEsperado as String
		
		loInfo = _screen.zoo.crearobjeto( "ZooInformacion" )
		loInfo.agregarInformacion( "Informacion 1", 15, "Informacion extra" )
		loInfo.agregarInformacion( "Info 2" )
		loInfo.agregarInformacion( "Inform 3", 9003 )
		
text to lcValorEsperado noshow
Item:1 Mensaje:Informacion 1
     Numero:15 Con Info Extra
Item:2 Mensaje:Info 2
     Numero:0 Sin Info Extra
Item:3 Mensaje:Inform 3
     Numero:9003 Sin Info Extra
endtext
		lcValorEsperado = chr(13) + chr(10) + lcValorEsperado
		lcSerializado = loInfo.SerializarInformacion()
		this.assertequals( "Error en el resultado de la serializacion", lcValorEsperado, lcSerializado )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNoExisteMensajeSinInformacion
		local loInformacion as zooinformacion of zooInformacion.prg 
		
		loInformacion = _screen.zoo.crearobjeto( "zooinformacion" )
		
		this.asserttrue( "No existe mensaje porque no hay informacion" , !loInformacion.ExisteMensaje( "Mensaje1" ) )
		
		loInformacion = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNoExisteMensajeConInformacion
		local loInformacion as zooinformacion of zooInformacion.prg 
		
		loInformacion = _screen.zoo.crearobjeto( "zooinformacion" )
		loInformacion.Agregarinformacion( "Mensaje2" )
		
		this.asserttrue( "No existe mensaje porque no hay informacion" , !loInformacion.ExisteMensaje( "Mensaje1" ) )
		
		loInformacion = null

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestExisteMensajeConInformacion
		local loInformacion as zooinformacion of zooInformacion.prg 
		
		loInformacion = _screen.zoo.crearobjeto( "zooinformacion" )
		loInformacion.Agregarinformacion( "Mensaje2" )
		
		this.asserttrue( "Existe mensaje." , loInformacion.ExisteMensaje( "Mensaje2" ) )
		
		loInformacion = null

	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
Define class MockInformacion as ZooSession of ZooSession.prg
lPasoPorsetearInformacion = .f.
lPasoPorinyectarInformacion = .f.
lPasoPoreventoObtenerInformacion = .f.

	*-----------------------------------------------------------------------------------------
	function setearInformacion( toInformacion as Object ) as Void
		dodefault( toInformacion )
		This.lPasoPorsetearInformacion = .t.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function inyectarInformacion( toQuienLlama as Object ) as Void
		dodefault( toQuienLlama )
		This.lPasoPorinyectarInformacion = .t.
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoObtenerInformacion( toYoMismo as Object ) as Void
		this.lPasoPoreventoObtenerInformacion = .t.
		****Si hay algun otro zooSession escuchando le va a inyectar un objeto Informacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarInformacion( tcTexto as String ) as Void
		This.oInformacion.AgregarInformacion( tcTexto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccion() as Void
		return This.oInformacion
	endfunc 

enddefine


