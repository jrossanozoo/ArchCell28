define class ColaboradorAtributosFW as custom

	#IF .f.
		Local this as ColaboradorAtributosFW of ColaboradorAtributosFW.prg
	#ENDIF

	protected cColumnasFW
	protected cValoresFW
	protected cValoresFWSubEntidadesFaltantes

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local lcDate as String, lcHora as String,  lcUsuario as String, ;
			lcSerie as String, lcSerieLince as String, lcVersion as String, lcBase as String
		lcDate = goServicios.Librerias.ValoraString( goServicios.Librerias.obtenerfecha() )
		lcHora = "[00:00:00]"
		lcUsuario = "[" + goServicios.Seguridad.cUsuarioLogueado + "]"
		lcSerie = "[" + _Screen.Zoo.App.cSerie + "]"
		lcSerieLince = "[LINCE]"
		lcVersion = "[" + _Screen.Zoo.App.cVersionSegunIni + "]"
		lcBase = "[" + _Screen.Zoo.App.cSucursalActiva + "]"

		this.cColumnasFW = "FModiFW, HModiFW, FAltaFW, HAltaFW, UaltaFW, UmodiFW, SaltaFW, SmodiFW, ValtaFW, VmodiFW, BDaltaFW, BDmodiFW,ZADSFW"
		this.cValoresFW = " ldDate, lcHora, ldDate, lcHora, " + lcUsuario + ", " + lcUsuario + ", " + lcSerieLince + ", " + lcSerie + ", " + lcVersion + ", " + lcVersion + ", " + lcBase + ", " + lcBase + ", " + this.ObtenerTextoAccionesDeSistema()
		this.cValoresFWSubEntidadesFaltantes = lcDate + ", " + lcHora + ", " + lcDate + ", " + lcHora + ", " + lcUsuario + ", " + lcUsuario + ", " + lcSerieLince + ", " + lcSerie + ", " + lcVersion + ", " + lcVersion + ", " + lcBase + ", " + lcBase + ", " + this.ObtenerTextoAccionesDeSistemaParaSubentidadesFaltantes()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColumnasFW() as String
		return this.cColumnasFW
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresFW() as String
		return this.cValoresFW
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresFWSubEntidadesFaltantes() as String
		return this.cValoresFWSubEntidadesFaltantes
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTextoAccionesDeSistema() as String
		return "[" + dtoc( goServicios.Librerias.ObtenerFecha() ) + " - " + goServicios.Librerias.ObtenerHora() + " - " + "Transferido desde Lince.]"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTextoAccionesDeSistemaParaSubentidadesFaltantes() as String
		return "[Generado automáticamente por falta de datos en el archivo de migración de Lince]"
	endfunc 
	
enddefine
