**********************************************************************
Define Class ztestZooMantenimiento as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestZooMantenimiento of ztestZooMantenimiento.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestAntesDeGrabar

		local loEntidad as Object, lcClave as String
		loEntidad = _Screen.zoo.instanciarentidad( "ZooMantenimiento" )
		loEntidad.Nuevo()
		lcClave = loentidad.oGestorClaves.ObtenerClaveDelDia( dtos( loEntidad.Fecha ) )
		This.Assertequals( "No se corrio el metodo SetearClaveDelDia 0 ", "", loEntidad.Clave )
		loEntidad.Clave = ""
		loEntidad.AntesDeGrabar()
		This.Assertequals( "No se corrio el metodo SetearClaveDelDia 1 ", lcClave, loEntidad.Clave )
		loEntidad.Cancelar()
		loEntidad.Release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestSetearClaveDelDia

		local loEntidad as Object, lcClave as String
		loEntidad = _Screen.zoo.instanciarentidad( "ZooMantenimiento" )
		loEntidad.clave = "PEPE"
		loEntidad.SetearClaveDelDia( {} )
		This.Assertequals( "No se corrio bien metodo SetearClaveDelDia 0 ", "", alltrim( loEntidad.Clave ) )
		loEntidad.Clave = "PEPE"
		loEntidad.SetearClaveDelDia( {01/01/2001} )
		This.Assertequals( "No se corrio el metodo SetearClaveDelDia 1 ", "SK553YW", loEntidad.Clave )
		loEntidad.Release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestClaveDelDia
			local loClave as Object, ldFecha as Date, lnI as Integer, lcClave as String, lcPrimeraParte as String, lcSegundaParte as String, lcTerceraParte as String
			loClave = _screen.zoo.crearobjeto( "ZooLogicSA.Core.BasesDeDatos.GestorPasswords")
			ldFecha = date()
			use in select( "ClaveDelDia" )
			create cursor ClaveDelDia ( Clave C(8) )
			for lni = 1 to 3660
				lcClave =  loClave.ObtenerClaveDelDia( dtos( ldFecha + lni ))
				insert into ClaveDelDia ( Clave ) values ( lcClave )
				lcPrimeraParte = substr( lcClave, 1, 2 )
				lcSegundaParte = substr( lcClave, 3, 3 )
				lcTerceraParte = substr( lcClave, 6, 2 )
				if ( "AA" <= lcPrimeraParte and lcPrimeraParte <= "ZZ" ) and ( "000" <= lcSegundaParte and lcSegundaParte <= "999" ) and ( "AA" <= lcTerceraParte and lcTerceraParte <= "ZZ" )
				else
					This.AssertTrue( "Problemas de clavedeldia para el dia " + dtos( ldFecha + lni ), .f. )
				Endif				
			endfor
			select count(*) as Cant from ClaveDelDia group by Clave having Cant > 1 into cursor c_Repetidos
			This.AssertTrue( "Existen Codigos Repetidos mayor a lo esperado para la fecha " + dtos( ldFecha ), 10 >= reccount( "c_Repetidos" ))
			use in select( "ClaveDelDia" )
			use in select( "c_Repetidos" )

	endfunc 



EndDefine
