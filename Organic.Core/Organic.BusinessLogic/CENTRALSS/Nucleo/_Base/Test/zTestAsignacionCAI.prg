**********************************************************************
Define Class zTestAsignacionCAI As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As zTestAsignacionCAI Of zTestAsignacionCAI.prg
	#Endif
	
	*-----------------------------------------------------------------------------------------
	function zTestAsignarCAI
		local loEntidad as din_entidadFrancia OF din_entidadFrancia.prg , loTal as entidad OF entidad.prg
		
		loTal = _screen.zoo.instanciarentidad( "Talonario" )
		
		try
			loTal.Codigo = 'TALFRANCIA2'
			loTal.Eliminar()
		catch
		endtry
		
		try
			loTal.Codigo = 'TALFRANCIA3'
			loTal.Eliminar()
		catch
		endtry

		loTal.Nuevo()
		loTal.Entidad = "FRANCIA"
		loTal.Formula = "'TALFRANCIA2'"
		loTal.Numero = 9
		loTal.Grabar()

		loTal.Nuevo()
		loTal.Entidad = "FRANCIA"
		loTal.Formula = "'TALFRANCIA3'"
		loTal.Numero = 19
		loTal.Grabar()
		
		loEntidad = _screen.zoo.instanciarentidad( "Francia" )
		loEntidad.oNumeraciones = newobject( "NumeracionesTest" )
		loEntidad.oNumeraciones.Inicializar()
		loEntidad.oNumeraciones.SetearEntidad( loEntidad )

		try
			loEntidad.Codigo = 1
			loEntidad.Eliminar()
		catch
		endtry
		
		loEntidad.Nuevo()
		loEntidad.Codigo = 1
		loDescripcion = ""
		loEntidad.FecHACAI = date()
		loentidad.fechaCUALQUIERA = date() - 10
		
		this.assertequals( "No asigno correctamente el numero", 10, loEntidad.Numero )
		this.assertequals( "No asigno correctamente los habitantes", 20, loEntidad.Habitantes )

		loEntidad.Grabar()

		this.assertequals( "Solo debe pasar por la asignacion de los atributos CAI una vez. Solo por el atributo clave candidata", 1, loEntidad.oNumeraciones.lCantidadAsignaciones )
		this.assertequals( "Solo debe pasar por la asignacion de los atributos CAI una vez. El atributo numero es incorrecto", "NUMERO", loEntidad.oNumeraciones.cAtributoNumeracion )
		this.assertequals( "Solo debe pasar por la asignacion de los atributos CAI una vez. El atributo fecha es incorrecto", "FECHACAI", loEntidad.oNumeraciones.cAtributoFecha )

		try
			loTal.Codigo = 'TALFRANCIA2'
			loTal.Eliminar()
		catch
		endtry
		
		try
			loTal.Codigo = 'TALFRANCIA3'
			loTal.Eliminar()
		catch
		endtry
		
		loTal.release()
		
		try
			loEntidad.Codigo = 1
			loEntidad.Eliminar()
		catch
		endtry
			
		loentidad.release()
	endfunc 


Enddefine

define class NumeracionesTest as Numeraciones of Numeraciones.prg
	
	lCantidadAsignaciones = 0
	cAtributoNumeracion = ""
	cAtributoFecha = ""

	function AsignarAtributosCAI( tcAtributoNumero as String, tcAtributoFechaCAI as string ) as Void
		this.lCantidadAsignaciones  = this.lCantidadAsignaciones  + 1
		this.cAtributoNumeracion = upper( tcAtributoNumero )
		this.cAtributoFecha = upper( tcAtributoFechaCAI )
	endfunc

enddefine

