#include din_ConstantesModulos.h

define class ModulosColoryTalle as Modulos of Modulos.prg

	#IF .f.
		Local this as ModulosColoryTalle of ModulosColoryTalle.prg
	#ENDIF

	nPosicionModuloSaaS = 32
	nVersion = 2 && Versionado de módulos para poder saber en la PC del cliente ;
				 && cuando debe pedir códigos de desactivación para actualizar los módulos del sistema. ;
				 && Aumentar la versión con números enteros.
	
	*-----------------------------------------------------------------------------------------
	&& Sobreescribe el método de la clase MODULOS pero hereda el modulo BASE. 
	protected function LlenarColeccion() as Void

		dodefault()
		with this
			&& 1 - 13 Reservados
			
			.oModulos.Agregar( .ObtenerModulo( 19, M0026NOM, M0026DES, "U", "0026" ), "U" )
			.oModulos.Agregar( .ObtenerModulo( 20, M0030NOM, M0030DES, "I", "0030" ), "I" )
			.oModulos.Agregar( .ObtenerModulo( 21, M0031NOM, M0031DES, "O", "0031" ), "O" )
			.oModulos.Agregar( .ObtenerModulo( 22, M0032NOM, M0032DES, "P", "0032" ), "P" )
			.oModulos.Agregar( .ObtenerModulo( 23, M0042NOM, M0042DES, "T", "0042" ), "T" )
			.oModulos.Agregar( .ObtenerModulo( 24, M0043NOM, M0043DES, "Q", "0043" ), "Q" )
			.oModulos.Agregar( .ObtenerModulo( 25, M0044NOM, M0044DES, "D", "0044" ), "D" )
			.oModulos.Agregar( .ObtenerModulo( 26, M0045NOM, M0045DES, "G", "0045" ), "G" )
			.oModulos.Agregar( .ObtenerModulo( 27, M0046NOM, M0046DES, "H", "0046" ), "H" )
			.oModulos.Agregar( .ObtenerModulo( 28, M0048NOM, M0048DES, "J", "0048" ), "J" )
			.oModulos.Agregar( .ObtenerModulo( 29, M0049NOM, M0049DES, "K", "0049" ), "K" )
			.oModulos.Agregar( .ObtenerModulo( 30, M0056NOM, M0056DES, "L", "0056" ), "L" )
			 
			&& 31 - 32 - 33 Reservados
			
			.oModulos.Agregar( .ObtenerModulo( 34, M0061NOM, M0061DES, "M", "0061" ), "M" )  
			.oModulos.Agregar( .ObtenerModulo( 35, M0028NOM, M0028DES, "W", "0028" ), "W" )	
			.oModulos.Agregar( .ObtenerModulo( 36, M0024NOM, M0024DES, "S", "0024" ), "S" )			
			.oModulos.Agregar( .ObtenerModulo( 37, M0068NOM, M0068DES, "N", "0068" ), "N" )
			&& 38 - 39 Reservados

			.oModulos.Agregar( .ObtenerModulo( 40, M0050NOM, M0050DES, "F", "0050" ), "F" )
			.oModulos.Agregar( .ObtenerModulo( 41, M0075NOM, M0075DES, "E", "0075" ), "E" )
			
			&& 55 - 55 Reservados
			.oModulos.Agregar( .ObtenerModulo( 42, M0055NOM, M0055DES, "X", "0055" ), "X" )

		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LlenarEquivalencias() as Void
		with this.oEquivalencias as zoocoleccion of zoocoleccion.prg
			.agregar( "Q", "1" )  && Q-0043	Listados
			.agregar( "S", "2" )  && S-0024	Stock
			.agregar( "D", "3" )  && D-0044	Gestión Mayorista	
			.agregar( "G", "4" )  && G-0045	Interfaces	
			.agregar( "O", "5" )  && O-0031	Consultas	
			.agregar( "P", "6" )  && P-0032	Altas y Precios	
			.agregar( "U", "7" )  && U-0026	Comunicaciones	
			.agregar( "W", "8" )  && W-0028	"SaaS"
			.agregar( "H", "9" )  && H-0046	Servicio REST
			.agregar( "I", "10" ) && I-0030	Stock y Toma de Inventario
			.agregar( "J", "11" ) && J-0048	Facturación Ventas
			.agregar( "T", "12" ) && T-0042	Operaciones con Tarjetas de Crédito
			.agregar( "K", "13" ) && K-0049	Gestión de compras
			.agregar( "L", "14" ) && L-0056	Impresión de etiquetas
			.agregar( "M", "15" ) && M-0061	Centralizador
			.agregar( "N",  "16" ) && M-0068 Comercio Exterior
			.agregar( "F",  "17" ) && F-0050 Contabilidad
			.agregar( "E",  "18" ) && E-0075 E-Commerce
			.agregar( "X",  "19" ) && X-0055 Producción
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraDeUnModuloSegunAlias( tcAlias as String ) as Character
		local lcModulo as String, lcAlias as String   
		lcModulo = ""
		lcAlias = upper( alltrim( tcAlias ) )
		do case
			case lcAlias == "TARJETA"
				lcModulo = "T"
			case lcAlias == "SAAS"
				lcModulo = "W"
			case lcAlias == "ETIQUETA"
				lcModulo = "L"
			case lcAlias == "CENTRALIZADOR"
				lcModulo = "M"
			case lcAlias == "COMUNICACIONES"
				lcModulo = "U"
			case lcAlias == "CONTABILIDAD"
				lcModulo = "F"
			case lcAlias == "ECOMMERCE"
				lcModulo = "E"
			case lcAlias == "COMPRAS"
				lcModulo = "K"
			case lcAlias == "PRODUCCION"
				lcModulo = "X"

		endcase	    
		return lcModulo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ModuloHabilitado( tcModulo as string ) as Boolean
		local llRetorno as Boolean
		if upper(alltrim(tcModulo)) = 'X'
			llRetorno = .t.
		else
			llRetorno = dodefault( tcModulo )
		endif
		return .t. && llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EntidadHabilitada( tcEntidad as string ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		do case
		case lower(tcEntidad) = 'modelodeproduccion'
		case lower(tcEntidad) = 'ordendeproduccion'
		case lower(tcEntidad) = 'inventario'
		case lower(tcEntidad) = 'insumo'
		case lower(tcEntidad) = 'curvadeproduccion'
		case lower(tcEntidad) = 'taller'
		case lower(tcEntidad) = 'procesoproduccion'
		case lower(tcEntidad) = 'maquinaria'
		case lower(tcEntidad) = 'consumoproduccion'
		case lower(tcEntidad) = 'rubroproduccion'
		case lower(tcEntidad) = 'motivodescarte'
		case lower(tcEntidad) = 'tipificacionproduccion1'
		case lower(tcEntidad) = 'tipificacionproduccion2'
		case lower(tcEntidad) = 'gestiondeproduccion'
		case lower(tcEntidad) = 'movimientostockaproducc'
		case lower(tcEntidad) = 'stockinventario'
		case lower(tcEntidad) = 'movimientostockainvent'
		case lower(tcEntidad) = 'movimientostockdesdeproducc'
		case lower(tcEntidad) = 'finaldeproduccion'
		case lower(tcEntidad) = 'clasificacionproduccion'
		otherwise
			llRetorno = dodefault(tcEntidad)
		endcase
		return .t. && llRetorno
	endfunc

enddefine
