**********************************************************************
Define Class zTestZooColeccion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestZooColeccion of zTestZooColeccion.prg
	#ENDIF
	
	oColeccion = null
	
	*---------------------------------
	Function Setup
		this.oColeccion = newobject( "zooColeccion", "zooColeccion.prg" )
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function TearDown
	
		if type( "this.oColeccion" ) == "O"

			this.oColeccion.remove(-1)
			this.oColeccion.release()
		endif
	endfunc 
	
	*---------------------------------
	Function zTestColeccion
		this.assertequals( "Instancia de Colección", "O", vartype( this.oColeccion ) )
		local loForm
		loForm = newobject( "Form" )
		this.oColeccion.Agregar( loForm, "Formulario" )
		this.assertequals( "Se agregó objeto a la colección", "O", vartype( this.oColeccion.Item[1] ) )
		this.oColeccion.Agregar( "001", "Codigo" )
		this.assertequals( "Se agregó un ítem a la colección", "001", this.oColeccion.Item[2] )
		this.assertequals( "Clave del ítem", "Codigo", this.oColeccion.GetKey[2] )
		loForm.release()
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestAgregarRangoConClave
		local loCol as Object, loCol2 as Object
		loCol = newobject( "zooColeccion", "zooColeccion.prg" )
		loCol2 = newobject( "zooColeccion", "zooColeccion.prg" )		
		
		loCol.Agregar( "primerItem", "clave1" )
		loCol.Agregar( "segundoItem", "clave2" )
		
		loCol2.Agregar( "TercerItem", "clave3" )
		loCol2.Agregar( "4toItem", "clave4" )
		
		loCol2.AgregarRango( loCol )
		
		this.assertequals( "La cantidad de items esta mal!", 4, loCol2.count )
		
		this.Assertequals( "Error item 1", "TercerItem" ,loCol2.item[1] )
		this.Assertequals( "Error item 2", "4toItem" ,loCol2.item[2] )
		this.Assertequals( "Error item 3", "primerItem" ,loCol2.item[3] )
		this.Assertequals( "Error item 4", "segundoItem" ,loCol2.item[4] )

		this.Assertequals( "Error en clave 3", "clave3" ,loCol2.getkey(1) )
		this.Assertequals( "Error en clave 4", "clave4" ,loCol2.getkey(2) )
		this.Assertequals( "Error en clave 1", "clave1" ,loCol2.getkey(3) )
		this.Assertequals( "Error en clave 2", "clave2" ,loCol2.getkey(4) )		
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestAgregarRango
		local loCol as Object, loCol2 as Object
		loCol = newobject( "zooColeccion", "zooColeccion.prg" )
		loCol2 = newobject( "zooColeccion", "zooColeccion.prg" )		
		
		loCol.Agregar( "primerItem" )
		loCol.Agregar( "segundoItem" )
		
		loCol2.Agregar( "TercerItem" )
		loCol2.Agregar( "4toItem" )
		
		loCol2.AgregarRango( loCol )
		
		this.assertequals( "La cantidad de items esta mal!", 4, loCol2.count )
		
		this.Assertequals( "Error item 1", "TercerItem" ,loCol2.item[1] )
		this.Assertequals( "Error item 2", "4toItem" ,loCol2.item[2] )
		this.Assertequals( "Error item 3", "primerItem" ,loCol2.item[3] )
		this.Assertequals( "Error item 4", "segundoItem" ,loCol2.item[4] )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestFuncionEnlazar
		local loEntidad as Object
		
		loEntidad = _screen.zoo.instanciarentidad( 'letonia' )
		
		with loEntidad
			this.asserttrue( 'No se encuentra el metodo enlazar en el detalle habitantes', pemstatus( .habitantes, 'enlazar', 5 ) )
			
			.habitantes = newobject( 'habitantes2' )
			
			with .habitantes
				.enlazar( 'funcionprueba1', 'funcionprueba2' )
				.funcionprueba1()
				
				this.asserttrue( 'No enlazó funcionprueba1 con la funcionprueba2', .lEnlazo2 )

				.Enlazar( 'oHab3.funcionprueba3', 'funcionprueba1' )
				.oHab3.funcionprueba3()
				
				this.asserttrue( 'No enlazó funcionprueba3 con la funcionprueba1', .lEnlazo1 )
			endwith

			.release()
		endwith					

	endfunc 

EndDefine

define class habitantes2 as zoocoleccion of zoocoleccion.prg
	lEnlazo1 = .f.
	lEnlazo2 = .f.
	oHab3 = null
	*-----------------------------------------------------------------------------------------
	function funcionprueba1() as Void
		this.lEnlazo1 = .t.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function funcionprueba2() as Void
		this.lEnlazo2 = .t.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.oHab3 = newobject( 'habitantes3' )
	endfunc 

enddefine 

define class habitantes3 as zoosession of zoosession.prg
	*-----------------------------------------------------------------------------------------
	function funcionprueba3() as Void
	endfunc 
enddefine 