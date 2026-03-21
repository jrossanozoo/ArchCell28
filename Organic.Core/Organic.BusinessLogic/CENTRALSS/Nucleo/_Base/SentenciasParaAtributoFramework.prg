define class SentenciasParaAtributoFramework as custom

	#if .f.
		local this as SentenciasParaAtributoFramework of SentenciasParaAtributoFramework.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaCamposInsert() as String
		local lcSentencia as String
		
		lcSentencia = "FecTrans, EstTrans, FAltaFW, HAltaFW, FModiFW, HModiFW, FecImpo, HoraImpo, FecExpo, HoraExpo, UAltaFW, UModiFW, SAltaFW, SModiFW, BDAltaFW, BDModiFW, VAltaFW, VModiFW, ZADSFW"
		
		return lcSentencia 

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaValoresInsert( toValores as Object ) as String
		local lcDatos as String, loValores as Object
		
		if pcount() == 1
			loValores = toValores
		else
			loValores = this.ObtenerObjetoValoresAtributosGenericos()
		endif

		lcDatos = goServicios.Librerias.ValorAStringSegunTipoBase( {} ) +", "+ ;
					goServicios.Librerias.ValorAStringSegunTipoBase( "" ) +", "+ ;
                 	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.dFechaActual ) + ", " + ;
                 	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cHoraActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.dFechaActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cHoraActual ) + ", " + ;
  					goServicios.Librerias.ValorAStringSegunTipoBase( {} ) +", "+ ;
					goServicios.Librerias.ValorAStringSegunTipoBase( "" ) +", "+ ;
					goServicios.Librerias.ValorAStringSegunTipoBase( {} ) +", "+ ;
					goServicios.Librerias.ValorAStringSegunTipoBase( "" ) +", "+ ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( goServicios.Librerias.EscapeCaracteresSqlServer( loValores.cUsuarioActual ) ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( goServicios.Librerias.EscapeCaracteresSqlServer( loValores.cUsuarioActual ) ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cSerieActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cSerieActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cSucursalActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cSucursalActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cVersionActual ) + ", " + ;
                  	goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cVersionActual ) + ", " + ;
	                goServicios.Librerias.ValorAStringSegunTipoBase( loValores.cZADSFW )
	    
		return lcDatos
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoValoresAtributosGenericos() as Object
		return newobject( "ValoresAtributosGenericos" )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class ValoresAtributosGenericos as custom

	dFechaActual = {}
	cHoraActual = ""
	cUsuarioActual = ""
	cSerieActual = ""
	cSucursalActual = ""
	cVersionActual = ""
	cZADSFW = ""

	*-----------------------------------------------------------------------------------------
	function Init() as Boolean
		this.dFechaActual    = goServicios.Librerias.ObtenerFecha()
		this.cHoraActual     = goServicios.Librerias.ObtenerHora()
		this.cUsuarioActual  = padr( alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ), 20, " " )
		this.cSerieActual    = alltrim( _screen.Zoo.App.cSerie )
		this.cSucursalActual = alltrim( _screen.Zoo.App.cSucursalActiva )
		this.cVersionActual  = _screen.Zoo.App.ObtenerVersion()
	endfunc

enddefine