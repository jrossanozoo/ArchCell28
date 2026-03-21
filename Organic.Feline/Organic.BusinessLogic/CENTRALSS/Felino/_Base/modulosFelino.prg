define class ModulosFelino as Modulos of Modulos.prg
	#include din_ConstantesModulos.h
	
	#IF .f.
		Local this as ModulosFelino of ModulosFelino.prg
	#ENDIF

	nPosicionModuloSaaS = 17
	*-----------------------------------------------------------------------------------------
	&& Sobreescribe el método de la clase MODULOS
	protected function LlenarColeccion() as Void		

		dodefault()
		with this
			.oModulos.Agregar( .ObtenerModulo( 2, M0001NOM, M0001DES, "V", "0001" ), "V" )
			.oModulos.Agregar( .ObtenerModulo( 17, M0028NOM, M0028DES, "W", "0028" ), "W" )			
			.oModulos.Agregar( .ObtenerModulo( 29, M0049NOM, M0049DES, "K", "0049" ), "K" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		this.oEquivalencias.agregar( "", "1" )
		this.oEquivalencias.agregar( "", "2" )
		this.oEquivalencias.agregar( "", "3" )
		this.oEquivalencias.agregar( "", "4" )
		this.oEquivalencias.agregar( "", "5" )
		this.oEquivalencias.agregar( "", "6" )
		this.oEquivalencias.agregar( "", "7" )
		this.oEquivalencias.agregar( "", "8" )
		this.oEquivalencias.agregar( "", "9" )
		this.oEquivalencias.agregar( "", "10" )
		this.oEquivalencias.agregar( "", "11" )
		this.oEquivalencias.agregar( "", "12" )
		this.oEquivalencias.agregar( "K", "13" )
		this.oEquivalencias.agregar( "", "14" )
		this.oEquivalencias.agregar( "", "15" )
		this.oEquivalencias.agregar( "", "16" )
		this.oEquivalencias.agregar( "", "17" )
		this.oEquivalencias.agregar( "", "18" )
		this.oEquivalencias.agregar( "", "19" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraDeUnModuloSegunAlias( tcAlias as String ) as Character
		local lcModulo as String, lcAlias as String   
		lcModulo = ""
		lcAlias = upper( alltrim( tcAlias ) )
		do case
			case lcAlias == "CONTABILIDAD"
				lcModulo = "B"
			case lcAlias == "COMPRAS"
				lcModulo = "K"
		endcase	    
		return lcModulo
	endfunc 

enddefine
