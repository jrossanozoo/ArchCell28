define class Cobranzas as custom
	RutaTablas = ""
	RutaIndices = ""
	RutaTablasPro = ""
	RutaIndicesPro = ""
	DepositosErroneos = null
	Deshacer = null
	MontoMinimoParaSuspenderRazonSocial = 0
	DepositoEspecifico = ''
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.RutaTablas = addbs( alltrim( _Screen.Zoo.App.cRutaLince ) ) + iif( "\DBF" $ alltrim( upper( _Screen.Zoo.App.cRutaLince ) ), "" , addbs( "DBF" ) )
		this.RutaIndices = addbs( left( alltrim( this.RutaTablas ),len( this.RutaTablas )-4) + "IDX" )
		this.RutaTablasPro = addbs( alltrim( _Screen.Zoo.App.cRutaLincePro ) ) + iif( "\DBF" $ alltrim( upper( _Screen.Zoo.App.cRutaLincePro ) ), "" , addbs( "DBF" ) )
		this.RutaIndicesPro = addbs( left( alltrim( this.RutaTablasPro ),len( this.RutaTablasPro )-4) + "IDX" )
		this.DepositosErroneos =  newobject( "collection" )
		this.MontoMinimoParaSuspenderRazonSocial = goparametros.zl.valORESSUGERIDOS.MontoMinimoParaSuspenderRazonSocial      
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CompletarDepositoYEntidad( toDeposito as Object, toEntidad as Object, tcCursor as String ) as Boolean
		local llRetorno as Boolean, loError as Exception, lcDetalle as String
		
		llRetorno = .t.
		toDeposito.RazonSocial = &tcCursor..Rz
		toDeposito.Importe = &tcCursor..Monto
		toDeposito.Codigo = &tcCursor..cId
		toDeposito.Fecha = &tcCursor..fDepo
		toDeposito.Numero = &tcCursor..Num
		
		&& pivotal #173173877
		if alltrim(nvl(&tcCursor..Valor,"")) = "" 
			* Mantenemos compatibilidad para atras usando la vieja logica
			toDeposito.Valor = this.ObtenerCodigoValor( substr(alltr(toDeposito.Codigo), 1, 1 ))
			toDeposito.DestinoEndosable = this.ObtenerCodigoDeBancoADepositar( toDeposito.Valor )
		else	
			toDeposito.Valor = &tcCursor..Valor
			toDeposito.DestinoEndosable = nvl(&tcCursor..DesEndo,"")
		endif
			
		&& pivotal #173173877 
		if (alltrim( toDeposito.Valor ) = "")  or (alltrim( toDeposito.DestinoEndosable ) = "") 
			llRetorno = .f.
		else
			try
				toEntidad.Numero = &tcCursor..Num
			catch to loError 
				lcDetalle = this.ProcesarExcepcion(	loError )
				* No se encontro el numero de asignacion
				this.AgregarDepositoNoProcesado( "No se encontro la Asignación de Razón Social a Depósitos de Clientes " +;
					transf( toDeposito.Numero ) + chr(13) + lcDetalle , toDeposito )
				llRetorno = .f.
			endtry		
		endif 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Procesar() as Void
		local lcCursor as String, lcConsulta as String, loEntidad as entidad OF entidad.prg,;
			loDeposito as Object, lcFormaDePago as String, llNoHuboError as Boolean, lcDetalle as String,;
			lcwhereadicional as String, lcFormaDePagoLince as String

		loEntidad = _Screen.Zoo.InstanciarEntidad( "AsignacionRzDepositosClientes" )
		lcCursor = sys( 2015 )
		lcwhereadicional = ''
		
		if !empty( this.DepositoEspecifico )
			lcwhereadicional = " and ARSDEP.Depo = '" + alltrim( this.DepositoEspecifico ) + "'"
		endif 

		text to lcConsulta textmerge noshow 
			 SELECT 
			 	  DEPCLI.cId
			 	, DEPCLI.Fdepo
			 	, DEPCLI.Ddepo
			 	, DEPCLI.Deta
			 	, DEPCLI.Monto
			 	, ARSDEP.rz
			 	, ARSDEP.Num
			 	, DEPCLI.Valor
			 	, DEPCLI.DesEndo  
			 from DEPCLI 
			 left join ARSDEP on ARSDEP.Depo = DEPCLI.Cid 
			 where ARSDEP.proce <> .t. <<lcwhereadicional>> 
			 order by DEPCLI.Fdepo, DEPCLI.Cid 
		endtext 
		
		goServicios.Datos.Ejecutarsentencias( lcConsulta, "DepCli, ArsDep", "", lcCursor, set("datasession") )
		
		if reccount( '&lcCursor' ) > 0
			this.AbrirTablas()
			this.AbrirTablasPro()
		else
			* Sin registros para procesar
			return
		endif

		if this.PudeBloquearTablaX()
			select &lcCursor

			scan		
				loDeposito = newobject( "Deposito", "Cobranzas.prg" )
				this.Deshacer =  newobject( "collection" )

				if this.CompletarDepositoYEntidad( loDeposito, loEntidad, lcCursor )
					
					llNoHuboError = .t.

					try
						this.Insertar( loDeposito, .f. )
						lcFormaDePago = this.ObtenerMedioDePago( loDeposito.RazonSocial )
					catch to loError
	 					lcDetalle = this.ProcesarExcepcion(	loError )
						this.AgregarDepositoNoProcesado( "No se pudo realizar la Cobranza/Descarga de valores. " +;
							transf( loDeposito.Numero ) + chr(13) + "Detalle : " + lcDetalle, loDeposito )
						llNoHuboError = .f.
					endtry
					
					if llNoHuboError
						try			
							if inlist( substr( lcFormaDePago, 1, 1 ), "F", "V", "M", "B" ) or upper( alltrim( lcFormaDePago ) ) = "DAP"
								lcFormaDePagoLince = iif( upper( alltrim( lcFormaDePago ) ) = "DAP", "DAP", substr( lcFormaDePago, 1, 1 ) )
								this.Insertar( loDeposito, .t., lcFormaDePagoLince )
								this.CanjeDeValores( loDeposito )
							endif			
						catch to loError
							lcDetalle = this.ProcesarExcepcion(	loError )
							this.AgregarDepositoNoProcesado( "No se pudo realizar Pase a Cupones/Aplicacion contra recibos. " +;
								transf( &lcCursor..Num ) + chr(13) + "Detalle : " + lcDetalle, loDeposito )
							llNoHuboError = .t.
						endtry
						
						if llNoHuboError
							try			
								loEntidad.Modificar()
								loEntidad.Procesado = .t.
								loEntidad.FechaProcesado = date()
*!*									loEntidad.AginacionDeRSaDeposito = &lcCursor..num 
								
								if empty( loEntidad.Registrado_PK )
									loEntidad.Registrado_PK = alltrim( goServicios.Seguridad.cUsuarioLogueado )
								endif

								if empty( loEntidad.Fecha )
									loEntidad.Fecha = date()
								endif
								loEntidad.Grabar()
							catch to loError
								lcDetalle = this.ProcesarExcepcion(	loError )
								this.AgregarDepositoNoProcesado( "No se pudo actualizar la Asignación de Razón Social a Depósitos de Clientes. " +;
									transf( &lcCursor..Num ) + chr(13) + " Detalle : " + lcDetalle , loDeposito )
								llNoHuboError = .t.
							endtry
							
							if llNoHuboError
								try
									this.ActualizarRZ( loDeposito.RazonSocial , loDeposito.Importe )			
								catch to loError
									lcDetalle = this.ProcesarExcepcion(	loError )
									this.AgregarDepositoNoProcesado( "No se pudo actualizar el estado de la Razon Social. " +;
										transf( &lcCursor..Num ) + chr(13) + "Detalle : " + lcDetalle, loDeposito )
									llNoHuboError = .t.
								endtry
							endif						
						endif
					endif
					
					if !llNoHuboError and this.Deshacer.Count != 0
						this.VolveraAtras()
					endif
					
				endif

				select &lcCursor
			endscan
		
			this.DesBloquearTablaX()

		endif
		
		use in select( '&lcCursor' )

		this.CerrarTablas()
		this.CerrarTablasPro()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PudeBloquearTablaX() as boolean
		local lpude as Boolean, lnreintentos as Integer , lnveces as Integer , nSec as Datetime, le as Exception  
		lpude = .f.
		lnreintentos = 10
		lnveces = 1
		nSec = datetime()
		select x

		do while  lnveces <= lnreintentos 

			if rlock()
				lpude = .t.
				exit
			endif	

			if datetime() - nSec >= lnveces 
				lnveces = lnveces + 1
				
			endif 	
		enddo 
		return lpude 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesBloquearTablaX() as Void
		select x
		unlock
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VolveraAtras() as Void
		local i as Integer, lcSentencia as String

		for i = 1 to this.Deshacer.Count
			lcSentencia = this.Deshacer[i].Sentencia
			&lcSentencia
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarRZ( tcRazonSocial as String , tnImporte as Integer ) as Void
		local loEntidad as Din_EntidadZLASIGESTADOSRZADM of Din_EntidadZLASIGESTADOSRZADM.prg
		
		lnSaldo = this.ObtenerSaldo( tcRazonSocial )
		lnSaldo = lnSaldo + this.ObtenerSaldoPro( tcRazonSocial )

		if lnSaldo <= this.MontoMinimoParaSuspenderRazonSocial
			loEntidad = _Screen.Zoo.InstanciarEntidad( "ZlAsigEstadosRzADM" )
			loEntidad.Nuevo()
			loEntidad.RazonSocial_pk = tcRazonSocial
			loEntidad.EstadoRZ_pk = "08"
			loEntidad.DetalleCambioEstado = "Deposito $" + transform( abs( tnImporte ) )
			loEntidad.Grabar()
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LetraSegunCliente( tcCodigoCliente as String ) as Void
		local lcRetorno as String, llCerrarTabla as Boolean
		
		lcRetorno = ""
		
		select cli
		set order to cli1
		if seek( tcCodigoCliente )
			if cli.clIva = 1 or cli.clIva = 2 or cli.clIva = 6
				lcRetorno = "a"
			else
				lcRetorno = "b"
			endif		
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Insertar( toDeposito as Object, tlPasarACupon as Boolean, tcCodigoValor as String ) as Void
		local lnNumeroCobranza, lnNumeroInterno, lcCodigoValor, lnTipoValor, lcCodigoEntidadFinanciera,;
			lnDepositoImporte, lcLetra, lnNumero, lnSecuencia, lcDescripcion, loVueltaAtras, loError as Exception,;
			lcRzSocial as String, lnDepImporte as Number , ldFecha as Date  
		
		* Duro duro
		lcCodigoEntidadFinanciera = "0"
	
		if tlPasarACupon
			toDeposito.Importe = toDeposito.Importe * -1
			lcCodigoValor = tcCodigoValor
			lcDescripcion = toDeposito.RazonSocial +  " - Dep " + dtoc( toDeposito.Fecha )
		else
			lcCodigoValor = toDeposito.Valor &&this.ObtenerCodigoValor( substr(toDeposito.Codigo, 1, 1 ))
			lcDescripcion = padr(toDeposito.Codigo,13) + "_0"
		endif
	
		lnTipoValor = this.ObtenerTipoValor( lcCodigoValor )	
		lnNumero = this.ObtenerNumero()
		lnNumeroCobranza = 200000000 + lnNumero			
		
		lnNumeroInterno =  this.ObtenerYActualizarNumeroInternoXJJNU( lnTipoValor )  &&      "( select max( jjnu ) + 1 as proximo from val as ValXXX where jjt = " + transform( lnTipoValor ) + ")"
		*
		***		
		loVueltaAtras = this.ObtenerObjetoVueltaAtras()
		loVueltaAtras.Sentencia = "update VAL set jjNum = 0 where jjNum =" + transform( lnNumeroCobranza )
		this.Deshacer.Add( loVueltaAtras )

		lcRzSocial = toDeposito.RazonSocial
		lnDepImporte = toDeposito.Importe
		ldFecha = dtoc( goServicios.Librerias.ObtenerFecha() )

		text to lcSQL textmerge noshow
			insert into val (jjNum,jjT,jjCo,jjFe,jjDe,jjM,jjCli,jjFecha,jjTotFac,jjTurno,jjCotiz,jjCuitLib,jjEntFin,jjNu) select distinct <<lnNumeroCobranza>>,<<lnTipoValor>>,'<<lcCodigoValor>>',ctod('<<ldFecha>>'),'<<lcDescripcion>>',<<lnDepImporte>>,'<<lcRzSocial>>',ctod('<<ldFecha>>'),<<lnDepImporte>>,1,1,'30-70779197-3','<<lcCodigoEntidadFinanciera>>',<<transform(lnNumeroInterno)>> from val
		endtext
		&lcSQL 

		***
		
		lnDepositoImporte = toDeposito.Importe * -1
		lnSecuencia = this.ObtenerNumeroSecuencia()
		
		***
		loVueltaAtras = this.ObtenerObjetoVueltaAtras()
		loVueltaAtras.Sentencia = "update CTB set cNum = 0 where cNum =" + transform( lnNumeroCobranza )
		this.Deshacer.Add( loVueltaAtras )

		insert into ctb ( cNum, cCue, cFch, cVto, cPar, cM1, cM2, cS1, cS2, cTxtO, cTotal, cTurno, cSh1, cCheque, cseq ) values;
			( lnNumeroCobranza, toDeposito.RazonSocial, date(), date(), 1,;
			lnDepositoImporte, lnDepositoImporte, lnDepositoImporte, lnDepositoImporte,;
			"Rec X 0001-" + padl( lnNumero, 8, "0" ) + " Dep " + dtoc( toDeposito.Fecha ), lnDepositoImporte, 1, lnDepositoImporte, lnDepositoImporte, lnSecuencia )
		***
		
		this.ActualizarNumero( lnNumero )
		
		if tlPasarACupon
			this.ActualizarSaldo( lnNumeroCobranza )
		else
			this.DescargaDeValores( lnNumeroCobranza, lcCodigoValor, toDeposito.DestinoEndosable )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroSecuencia() as Integer 
		select x
		replace x.xsqc with x.xsqc + 1
		
		return x.xsqc
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarSaldo( tnNumeroCobranza as Integer ) as Void
		select ctb
		update ctb set cs1 = 0, cs2 = 0 where ( cNum = tnNumeroCobranza - 1 ) or ( cNum = tnNumeroCobranza )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DescargaDeValores( tnNumeroCobranza as Integer, tcCodigoValor as String, tcDestinoEndosable as String  ) as Void
        local lcBanco as String, lnNumero as Integer
        
        lcBanco = tcDestinoEndosable  &&this.ObtenerCodigoDeBancoADepositar( tcCodigoValor )
        lnNumero = this.ObtenerNumeroDescargaDeValores()

        select val
        set order to val1
        * Ver
        if seek ( tnNumeroCobranza )
			replace val.jjbjNum with lnNumero,;
				val.jjbjcli with lcBanco,;
				val.jjbjfch with date()
        endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroDescargaDeValores() as integer
        local lnRetorno as Integer
        lnRetorno = 500000001   

        select val
        set order to val4 desc
        
        set near on
        seek 599999999
        set near off
        
        if ( between(val.jjbjnum, 500000000, 599999999) )
              lnRetorno = val.jjbjnum + 1
        endif

        return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeBancoADepositar( tcCodigoValores as String ) as String
		local lcRetorno as String

		do case
			case tcCodigoValores = "09"
				lcRetorno = "016"

			case tcCodigoValores = "05"
				lcRetorno = "017"

			case tcCodigoValores = "02"
				lcRetorno = "067"

			case tcCodigoValores = "10"
				lcRetorno = "010MP"
			otherwise 	
				lcRetorno = ""
		endcase			
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoValor( tcLetra as String ) as string
		local lcRetorno as String

		do case
			case tcLetra = "R"
				lcRetorno = "09"

			case tcLetra = "C"
				lcRetorno = "05"

			case tcLetra = "B"
				lcRetorno = "02"

			case tcLetra = "M"
				lcRetorno = "10"
			otherwise 	
				lcRetorno = ""
		endcase			
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumero() as Integer
		local lcCampo as String

			
		lcCampo = "xreca"
		select x
		return x.xreca + 1
	endfunc 

* Para la numeracion si maneja A-B
*!*		*-----------------------------------------------------------------------------------------
*!*		function ActualizarNumero( tcTipo as string, tnNumero as Integer) as Void
*!*			local lcCampo as String
*!*			
*!*			lcCampo = "xrec" + tcTipo

*!*			select x
*!*			replace x.&lcCampo with tnNumero
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarNumero( tnNumero as Integer) as Void
		local loVueltaAtras as Object
		
		loVueltaAtras = newobject( "VueltaAtras", "Cobranzas.prg" )

		select x
		loVueltaAtras.Sentencia = "update X Set xreca = " + transform( x.xreca )
		this.Deshacer.Add( loVueltaAtras )

		replace x.xreca with tnNumero
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoInterno( tnInterno, tnTipo ) as Integer
		local lnRetorno as Integer

		select ( max( jjnu ) ) as proximo from val where jjt = tnTipo into cursor cProximo
		lnRetorno = cProximo.proximo + 1
		
		use in select( "cProximo" )
		
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AbrirTablas() as Void
		if !used( "X" )
			use ( this.RutaTablas + "x.dbf" ) in 0
		endif

		if !used( "Val" )
			use ( this.RutaTablas + "val.DBF" ) in 0
		endif

		if !used( "Ctb" )
			use ( this.RutaTablas + "ctb.DBF" ) in 0
		endif

		if !used( "Cli" )
			use ( this.RutaTablas + "cli.DBF" ) in 0
		endif
		
		this.CargarIndice( "val", "val1" )
		this.CargarIndice( "val", "val2" )
		this.CargarIndice( "val", "val3" )
		this.CargarIndice( "val", "val4" )
		this.CargarIndice( "val", "val5" )
		this.CargarIndice( "val", "val6" )
		this.CargarIndice( "val", "val7" )
		
		this.CargarIndice( "ctb", "ctb1" )
		this.CargarIndice( "ctb", "ctb2" )
		this.CargarIndice( "ctb", "ctb3" )
		this.CargarIndice( "ctb", "ctb4" )
		this.CargarIndice( "ctb", "ctb5" )
		this.CargarIndice( "ctb", "ctb6" )
		
		this.CargarIndice( "cli", "cli1" )
		this.CargarIndice( "cli", "cli2" )
		this.CargarIndice( "cli", "cli3" )
		this.CargarIndice( "cli", "cli4" )						
		this.CargarIndice( "cli", "cli5" )
		this.CargarIndice( "cli", "cli6" )
		this.CargarIndice( "cli", "cli7" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarTablas() as Void
		use in select ( "X" )
		use in select ( "val" )
		use in select ( "ctb" )
		use in select ( "Cli" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarIndice( tcTabla as String, tcIndice) as Void
		select '&tcTabla'
		set index to ( this.RutaIndices + tcIndice + ".idx" ) additive
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMedioDePago( tcCodigo as String ) as Void
		local loRazonSocial as Object, lcRetorno as String

		lcRetorno = ""
		loRazonSocial = _Screen.Zoo.InstanciarEntidad( "zlRazonSociales" )
		try
			loRazonSocial.Codigo = tcCodigo
			lcRetorno = loRazonSocial.FormaDePago.Codigo
		catch
		endtry

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroCanje() as Integer 
        local lnRetorno as Integer
        lnRetorno = 800000001   

        select val
        set order to val1 desc
        
        set near on
        seek 899999999
        set near off
        
        if ( between(val.jjnum, 800000000, 899999999) )
              lnRetorno = val.jjnum + 1
        endif

        return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSaldo( tcRazonSocial as String ) as Integer
        local lnRetorno as Integer
        
		select sum(iif(isnull(ctb.cs1),0,ctb.cs1))  as Monto; 
			FROM ctb  where ctb.cs1 <> 0 and cnum < 900000000 and ccue == tcRazonSocial;
		union all;
		select sum(iif(isnull(va.JJM),0,va.JJM)) as Monto;
			 FROM val va WHERE ( JJT=3 AND (JJbjNUM=0 or isnull(JJbjNUM)) AND JJNU>0 ); 
		  			and jjcli == tcRazonSocial;
		  into cursor cSaldo
        
        select sum(Monto) as Saldo from cSaldo into cursor cSaldo
        
        lnRetorno = cSaldo.saldo

        use in select ( "cSaldo" )
        
        return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CanjeDeValores( toDeposito as Object ) as Void
		local lnNumeroCanje as Integer, lnSaldo as Integer, loVueltaAtras as Object
		
		lnSaldo = this.ObtenerSaldo( toDeposito.RazonSocial )
		
		if lnSaldo = 0
			lnNumeroCanje = this.ObtenerNumeroCanje()
			lnTipoValor = 1
			lcCodigoValor = "AJ"
			lcDescripcion = "AJUSTE PES"
			lnImporte = 0.01
			lcVendedor = "ZOO"

			loVueltaAtras = this.ObtenerObjetoVueltaAtras()
			loVueltaAtras.Sentencia = "delete from VAL where jjNum =" + transform( lnNumeroCanje )
			this.Deshacer.Add( loVueltaAtras )
			
			insert into val ;
				(jjNum, jjT, jjCo, jjFe, jjDe, jjNu, jjM, jjCli, jjFecha, jjVen, jjTotFac, jjTurno, jjCotiz);
				values;
				( lnNumeroCanje, lnTipoValor, lcCodigoValor, date(), lcDescripcion, 0,;
				lnImporte, toDeposito.RazonSocial, date(), lcVendedor, lnImporte, 1, 1)

			insert into val ;
				(jjNum, jjT, jjCo, jjFe, jjDe, jjNu, jjM, jjCli, jjFecha, jjVen, jjTotFac, jjTurno, jjCotiz);
				values;
				( lnNumeroCanje, lnTipoValor, lcCodigoValor, date(), lcDescripcion, 0,;
				lnImporte * -1, toDeposito.RazonSocial, date(), lcVendedor, lnImporte, 1, 1)
			
			loVueltaAtras = this.ObtenerObjetoVueltaAtras()
			loVueltaAtras.Sentencia = "update val set jjbjcli = '', jjbjfch = ctod('//') , jjbjnum = 0 " +;
				" where ( jjNum < 800000000 or  jjNum > 899999999 ) and val.jjcli = '" + toDeposito.RazonSocial + "' and jjbjnum = " + transform( lnNumeroCanje )
			this.Deshacer.Add( loVueltaAtras )

			update val set jjbjcli = toDeposito.RazonSocial, jjbjfch = date() , jjbjnum = lnNumeroCanje;
						where ( jjNum < 800000000 or  jjNum > 899999999 ) and val.jjcli = toDeposito.RazonSocial and;
						inlist( jjco, "F", "V", "M", "B" ) and;
						empty( val.jjbjnum )
		endif

	endfunc 

* Esto servia si se manejan con recibos A-B
*!*		*-----------------------------------------------------------------------------------------
*!*		function EsClienteA( tcCliente as String ) as Boolean
*!*			local llCerrarTabla as Boolean, llRetorno as Boolean
*!*			
*!*			llRetorno = .f.

*!*			select cli
*!*			set order to cli1

*!*			if seek( tcCliente )
*!*				if inlist( cli.clIva, 1, 2, 6 )
*!*					llRetorno = .t.		
*!*				endif
*!*			endif
*!*		
*!*			return llRetorno
*!*		endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarDepositoNoProcesado( tcMensajeDeError as String, toDeposito as Object ) as Void
		local loDetalle as Object
		
		toDeposito.DetalleError = tcMensajeDeError
		this.DepositosErroneos.Add( toDeposito )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoValor( tcValor as String ) as Integer
		local lnRetorno as Integer
				
		do case
			case tcValor = "F"
				lnRetorno = 3
				
			case tcValor = "V"
				lnRetorno = 3
				
			case tcValor = "M"
				lnRetorno = 3
				
			case tcValor = "B"
				lnRetorno = 3
				
			case tcValor = "DAP"
				lnRetorno = 3

			case tcValor = "09"
				lnRetorno = 4
				
			case tcValor = "05"
				lnRetorno = 4
				
			case tcValor = "02"
				lnRetorno = 4

			case tcValor = "MP"
				lnRetorno = 4
				
			case tcValor = "10"
				lnRetorno = 4

			otherwise 
				lnRetorno = 4 	
				
		endcase
				
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarExcepcion( toException as Exception)
		local lcRetorno as String

        lcRetorno = ""

        if type( "toException.UserValue" ) = "O"
        	if type( "toException.UserValue.oInformacion" ) = "O"	
        		for i = 1 to toException.UserValue.oInformacion.Count
					lcRetorno = lcRetorno + chr(13) + toException.UserValue.oInformacion.Item[i].cMensaje
        		next
        	endif
        endif
		
		lcRetorno = lcRetorno + iif( !empty(lcRetorno),chr(13),"") + toException.Message
        
        return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoVueltaAtras() as Object
		return newobject( "VueltaAtras", "Cobranzas.prg" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerYActualizarNumeroInternoXJJNU( tnTipoValor ) as Integer 
		local lnSelect, lnRet
		lnSelect = select()
		select x		

		if tnTipoValor = 3
			lnRet = X.hNum + 1
			replace X.hNum with lnRet
		endif 	

		if tnTipoValor = 4
			lnRet = X.XVALNUM + 1
			replace X.XVALNUM  with lnRet
		endif 	


		select( lnSelect )
		return lnRet
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSaldoPro( tcRazonSocial as String ) as Integer
        local lnRetorno as Integer

		select sum( iif( isnull( ctbpro.cs1 ), 0, ctbpro.cs1 ) ) as Monto;
		from ctbpro;
		where ctbpro.cs1 <> 0 and cnum < 900000000 and ccue == tcRazonSocial;
		union all;
		select sum( iif( isnull( va.JJM ), 0, va.JJM ) ) as Monto;
		from valpro va;
		where ( JJT = 3 AND ( JJbjNUM = 0 or isnull( JJbjNUM ) ) AND JJNU > 0 ) and jjcli == tcRazonSocial;
		into cursor cSaldo

        select sum( Monto ) as Saldo from cSaldo into cursor cSaldo
        lnRetorno = cSaldo.Saldo
        use in select ( "cSaldo" )

        return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function AbrirTablasPro() as Void
		if !used( "Valpro" )
			use ( this.RutaTablasPro + "val.DBF" ) alias "Valpro" in 0
		endif

		if !used( "Ctbpro" )
			use ( this.RutaTablasPro + "ctb.DBF" ) alias "Ctbpro" in 0
		endif

		this.CargarIndicePro( "valpro", "val1" )
		this.CargarIndicePro( "valpro", "val2" )
		this.CargarIndicePro( "valpro", "val3" )
		this.CargarIndicePro( "valpro", "val4" )
		this.CargarIndicePro( "valpro", "val5" )
		this.CargarIndicePro( "valpro", "val6" )
		this.CargarIndicePro( "valpro", "val7" )

		this.CargarIndicePro( "ctbpro", "ctb1" )
		this.CargarIndicePro( "ctbpro", "ctb2" )
		this.CargarIndicePro( "ctbpro", "ctb3" )
		this.CargarIndicePro( "ctbpro", "ctb4" )
		this.CargarIndicePro( "ctbpro", "ctb5" )
		this.CargarIndicePro( "ctbpro", "ctb6" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CerrarTablasPro() as Void
		use in select ( "Valpro" )
		use in select ( "Ctbpro" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarIndicePro( tcTabla as String, tcIndice) as Void
		select '&tcTabla'
		set index to ( this.RutaIndicesPro + tcIndice + ".idx" ) additive
	endfunc

enddefine

define class Deposito as custom
	RazonSocial = ""
	Importe = 0
	Codigo = ""
	Fecha = {//}
	DetalleError = ""
	Numero = 0
	Valor = ""
	DestinoEndosable = ""
enddefine

define class VueltaAtras as custom
	Sentencia = ""
enddefine
