define class EntColoryTalle_Cliente as Ent_cliente of Ent_cliente.prg

	#if .f.
		local this as EntColoryTalle_Cliente of EntColoryTalle_Cliente.prg
	#endif

	lEsCargaDeAtributoVirtual = .f.
	lEsLecturaDNI = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()

		this.enlazar( "Setear_Recomendadopor", "SetearAtributosRecomendante")
		this.enlazar( "Cargar", "SetearAtributoVirtualRecomendante" )
		if vartype( This.Percepciones )= 'O' and !isnull( This.Percepciones )
			This.BindearEvento( this , "Modificar" , This, "HabilitarDeshabilitarSiprib" )
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosRecomendante( txVal as variant ) as void
	
		if this.CargaManual() and !this.lEsCargaDeAtributoVirtual 
			this.CodRecomendante = this.RecomendadoPor.Codigo
			this.NombreRecomendante = this.RecomendadoPor.Nombre	
		endif	
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoVirtualRecomendante() as Boolean
		local loError as zooException OF zooException.prg 

		if this.CargaManual() and !empty( this.CodRecomendante )
			this.lEsCargaDeAtributoVirtual  = .t.
			try
				this.RecomendadoPor_PK = this.CodRecomendante 
			catch to loError
			endtry
			this.lEsCargaDeAtributoVirtual  = .f.
		endif
	
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidacionBasica() as Boolean
		local llRetorno as Boolean
	
		llRetorno = dodefault()
		llRetorno = llRetorno and this.ValidarRecomendacionRecursiva()
		llRetorno = llRetorno and this.ValidarRecomendanteInactivo()
		if llRetorno = .T. and goParametros.Felino.DatosImpositivos.CuitValidoObligatorioEnElAltaDeClientes = 3
			this.ValidarCuitORut()
		endif			
		return llRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------	
	function Validar_Nrodocumento( txVal as variant ) as Boolean

		Return this.ValidarDNI( txVal ) and dodefault( txVal )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDNI(tcDniNoValido as String) as Boolean
		local llEsValidoDNI as Boolean
		
		llEsValidoDNI = .t.
		
		if goParametros.Dibujante.PermiteDniCuitDeClienteRepetido = 2
			if !empty(tcDniNoValido)
				do case
					case len(alltrim(tcDniNoValido)) < 7
						this.oMensaje.Informar( "El número de documento ingresado debe contener 7 o más caracteres." )
						llEsValidoDNI = .f.
					case this.CaracteresRepetidos(tcDniNoValido)
						this.oMensaje.Informar ( "El número de documento ingresado no es válido." )
						llEsValidoDNI = .f.
				endcase
			endif
		endif	
		
		if llEsValidoDNI and !empty(tcDniNoValido) and len( alltrim( chrtran( tcDniNoValido, goServicios.LiBRERIAS.obtenernumerosvalidos(),"" ) ) ) > 0 
			if this.EsPasaporte( this.tipodocumento )
				if len( alltrim( chrtran( tcDniNoValido, goServicios.Librerias.obtenerletrasynumerosvalidos(),"" ) ) ) > 0
					goServicios.Errores.LevantarExcepcion( "El número de documento ingresado contiene símbolos." )
					llEsValidoDNI = .f.
				endif
			else
				goServicios.Errores.LevantarExcepcion( "El número de documento ingresado contiene letras o símbolos." )
				llEsValidoDNI = .f.
			endif
		endif
		return llEsValidoDNI
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function EsPasaporte( tcTipoDoc as String ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = ( this.nPais != 3 and tcTipoDoc == "06" ) or ( this.nPais = 3 and tcTipoDoc == "05" ) 
	
		return llRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function CaracteresRepetidos(tcDniNoValido as String) as Boolean
		local lcCaracter as Character
		
		tcDniNoValido = alltrim(tcDniNoValido)
		lcCaracter = left(tcDniNoValido, 1)
		return at(lcCaracter, tcDniNoValido, len(tcDniNoValido)) > 0
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarRecomendacionRecursiva() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		if !empty( this.RecomendadoPor_pk ) and this.RecomendadoPor_pk = this.codigo
			this.AgregarInformacion( 'No está permitido asignar este cliente recomendante.' )
			llRetorno = .f.
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarRecomendanteInactivo() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		if this.RecomendadoPor.InactivoFW
			this.AgregarInformacion( 'El cliente recomendante no puede ser un cliente inactivo.' )
			llRetorno = .f.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializandoEntidadComportamientoSugerido( toEntidadComportamientoSugerido as entidad OF entidad.prg ) as Void
		toEntidadComportamientoSugerido.UsarPrefijoBaseDeDatos = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarNombre() as Void
		local llRetorno as Boolean
		llRetorno = .T.
		if this.SituacionFiscal_PK = 3 && Consumidor Final
			llRetorno = this.ValidarNombreConsumidorFinal()
			if llRetorno
				this.CompletarNombre()
			else 
				this.Agregarinformacion( 'Debe cargar al menos un nombre y/o apellido.', 9005, 'PrimerNombre' )
			endif
		else
			if empty( this.Nombre )	
				this.AgregarInformacion( 'Debe cargar el campo denominación o razón social.', 9005, 'Nombre' )
				llRetorno = .F.	
			endif
		endif				
		llRetorno = llRetorno and dodefault()	
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ValidarNombreConsumidorFinal() as Boolean
		local llRetorno as Boolean 
		llRetorno = .t.
		if empty(alltrim(this.PrimerNombre)) and empty(alltrim(this.SegundoNombre)) and empty(alltrim(this.apellido))
			llRetorno = .f.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CompletarNombre() as Void
		local lcSeparador as String, lcNombre as String 
		if empty(alltrim(this.PrimerNombre)) and empty(alltrim(this.SegundoNombre)) and empty(alltrim(this.apellido))
			this.PrimerNombre = this.nombre
		else
			lcNombre = ""
			this.Nombre = ""
			lcSeparador	= ""
			if empty(alltrim(this.apellido))
			else
				lcNombre = alltrim(this.apellido)
			endif
			if empty(alltrim(this.PrimerNombre)) 
			else
				lcSeparador = iif(len(lcNombre)>0,", ","")
				lcNombre = lcNombre + lcSeparador + alltrim(this.PrimerNombre)
			endif
			if empty(alltrim(this.SegundoNombre))
			else
				do case
					case len(alltrim(this.apellido))=0 and len(alltrim(this.PrimerNombre))=0
						lcSeparador = ""
					case len(alltrim(this.PrimerNombre))=0
						lcSeparador = ", "
					otherwise 
						lcSeparador = " "
				endcase
				lcNombre = lcNombre + lcSeparador + alltrim(this.SegundoNombre)
			endif
			this.Nombre = lcNombre
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarDeshabilitarSiprib() as Void
		local llHabilitarControlesSiprib as Boolean

		llHabilitarControlesSiprib = .F.
		for each Percepciones in this.Percepciones
			if alltrim(Percepciones.jurisdiccion_pk ) = "921"
				llHabilitarControlesSiprib = .T.
			endif
		endfor

		if llHabilitarControlesSiprib
			this.lHabilitarCodigoSiprib_PK = .T.
		else
			if this.esedicion() or this.esnuevo()
				this.codigoSIPRIB_PK = ""
				this.lHabilitarCodigoSiprib_PK = .F.
			endif
		endif

	endfunc	

	*-----------------------------------------------------------------------------------------
	function ObtenerSexo( tcInicialSexo as String ) as String

		local lcRetorno as String
		lcRetorno = ""
		
		do case
			case tcInicialSexo = 'M'
				lcRetorno = "Masculino"
			case tcInicialSexo = 'F'
				lcRetorno = "Femenino"
			case tcInicialSexo = 'X'
				lcRetorno = "No binario"
		endcase
			
		return lcRetorno
	endfunc 

enddefine
