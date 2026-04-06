define class ModulosZL as Modulos of Modulos.prg
#include din_ConstantesModulos.h

	*-----------------------------------------------------------------------------------------
	function ModuloHabilitado( tcModulo as string ) as Boolean
		return .t.
	endfunc
	*-----------------------------------------------------------------------------------------
	&& Sobreescribe el método de la clase MODULOS
	protected function LlenarColeccion() as Void		

		dodefault()
		with this
			.oModulos.Agregar( .ObtenerModulo( 2, M0001NOM, M0001DES, "V", "0001" ), "V" )
			.oModulos.Agregar( .ObtenerModulo( 17, M0028NOM, M0028DES, "W", "0028" ), "W" )			
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
		this.oEquivalencias.agregar( "", "13" )
		this.oEquivalencias.agregar( "", "14" )
		this.oEquivalencias.agregar( "", "15" )
		this.oEquivalencias.agregar( "", "16" )
		this.oEquivalencias.agregar( "", "17" )
		this.oEquivalencias.agregar( "", "18" )
		this.oEquivalencias.agregar( "", "19" )
	endfunc 
	
enddefine