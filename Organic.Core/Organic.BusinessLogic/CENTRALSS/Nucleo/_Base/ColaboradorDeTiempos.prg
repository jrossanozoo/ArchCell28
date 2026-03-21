#define NUEVALINEA	chr(13) + chr(10)
#define SEPARADOR	chr(9)

define class ColaboradorDeTiempos as ColaboradorBase of ColaboradorBase.prg

	#if .f.
		Local this as ColaboradorDeTiempos of ColaboradorDeTiempos.prg
	#endif

	Carpeta = ''
	Detalle = ''
	Lista = ''
	Primero = 0
	Completo = 0
	Promedio = 0
	TotalGeneral = 0
	PromedioGeneral = 0
	Milisegundos = .t.
	TablaResumen = ''
	TablaDetalle = ''
	
	function init
		dodefault()
		this.Carpeta = _Screen.Zoo.CRutaInicial
	endfunc

	*-----------------------------------------------------------------------------------------
	function TiemposEnNuevoEnEntidad( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as String
		local lnInicial as Number, lnFinal as Number, lnTiempo as Number, lnTotal as Number, lnPromedio as Number, lcTablaResumen as String, lcTablaDetalle as String
		tnRepeticion = iif(type('tnRepeticion')#'N' or tnRepeticion<1,10,tnRepeticion)
		tnSerie = iif(type('tnSerie')#'N' or tnSerie<1,1,tnSerie)
		lcTablaResumen = ''
		lcTablaDetalle = ''
		this.Detalle = ''
		this.Lista = ''
		this.TotalGeneral = 0
		this.PromedioGeneral = 0
		lcResultado = 'Tiempos acción nuevo en entidad ' + tcEntidad + NUEVALINEA
		lcResultado = lcResultado + "Motor (" + this.TipoMotorDB + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Driver " + this.DriverSQL + NUEVALINEA
		lcResultado = lcResultado + "Servidor (" + this.ServidorSQL + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Base de datos (" + this.NombreBaseDB + ")"+ NUEVALINEA
		loEntidad = _Screen.Zoo.InstanciarEntidad( tcEntidad )
		lnInicial = this.ObtenerSegundos()
		loEntidad.Nuevo()
		lnFinal = this.ObtenerSegundos()
		this.Primero = lnFinal - lnInicial
		loEntidad.Cancelar()
		lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
		lcTablaDetalle = lcTablaDetalle + tcEntidad + ',primer nuevo,0,0,' + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		for lnInd = 1 to tnSerie
			this.Primero = 0
			this.Completo = 0
			this.Promedio = 0
			for lnRep = 1 to tnRepeticion
				lnInicial = this.ObtenerSegundos()
				loEntidad.Nuevo()
				lnFinal = this.ObtenerSegundos()
				lnTiempo = round((lnFinal - lnInicial)/1000,3)
				this.Completo = this.Completo + lnTiempo
				this.Lista = ", " + alltrim(str(lnTiempo,7,3))
*!*					lcTablaDetalle = lcTablaDetalle + tcEntidad + ',nuevo,' + alltrim(str(lnInd)) + ',' + alltrim(str(lnRep)) + ',' + alltrim( str(round(lnTiempo,4),12,4)) + NUEVALINEA
				lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
				lcTablaDetalle = lcTablaDetalle + tcEntidad + ',nuevo,' + alltrim(str(lnInd)) + ',' + alltrim(str(lnRep)) + ',' + alltrim( str(round(lnTiempo,4),12,4)) + NUEVALINEA
				loEntidad.Cancelar()
			next
			this.Promedio = round(this.Completo / tnRepeticion,4)
			lcResultado = lcResultado + "Serie " + alltrim(str(lnInd)) + " - " + alltrim(str(tnRepeticion)) + " repeticiones" + NUEVALINEA
			lcResultado = lcResultado + "Total " + alltrim(str(round(this.Completo,4),12,4)) + " - Promedio " + alltrim(str(round(this.Promedio,4),12,4)) + NUEVALINEA
			this.TotalGeneral = this.TotalGeneral + this.Completo
			lcTablaResumen = lcTablaResumen + tcEntidad + ',nuevo,' + alltrim(str(tnRepeticion)) + ',' + alltrim(str(round(this.Completo,4),12,4)) + ',' + alltrim(str(round(this.Completo / tnRepeticion,4),12,4)) + NUEVALINEA
		next
		loEntidad.Release()
		this.PromedioGeneral = round(this.TotalGeneral / tnSerie,4)
		lcResultado = lcResultado + "Motor " + this.TipoMotorDB + ' Driver' + this.DriverSQL + "Servidor " + this.ServidorSQL + "Base de datos " + this.NombreBaseDB
		lcResultado = lcResultado + "Total general " + alltrim(str(round(this.TotalGeneral,4),12,4)) + " - Promedio " + alltrim(str(round(this.PromedioGeneral,4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Promedio ponderado " + alltrim(str(round(this.TotalGeneral / (tnRepeticion * tnSerie),4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Primer nuevo " + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		this.GrabarRegistro(this.Carpeta+"log\TiemposFormulario.log", lcResultado)
		this.TablaResumen = lcTablaResumen
		this.TablaDetalle = lcTablaDetalle

		return lcResultado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposEnNuevoEnFormulario( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as String
		local lcResultado as String, lnInicial as Number, lnFinal as Number, lnTotal as Number, lnPromedio as Number
		tnRepeticion = iif(type('tnRepeticion')#'N' or tnRepeticion<1,10,tnRepeticion)
		tnSerie = iif(type('tnSerie')#'N' or tnSerie<1,1,tnSerie)
		lcTablaResumen = ''
		lcTablaDetalle = ''
		this.Detalle = ''
		this.Lista = ''
		this.TotalGeneral = 0
		this.PromedioGeneral = 0
		lcResultado = 'Tiempos en formulario ' + tcEntidad + NUEVALINEA
		lcResultado = lcResultado + "Motor (" + this.TipoMotorDB + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Driver " + this.DriverSQL + NUEVALINEA
		lcResultado = lcResultado + "Servidor (" + this.ServidorSQL + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Base de datos (" + this.NombreBaseDB + ")"+ NUEVALINEA
		loFormulario = goFormularios.Procesar( tcEntidad )
		lnInicial = this.ObtenerSegundos()
		loFormulario.oKontroler.Ejecutar("NUEVO")
		lnFinal = this.ObtenerSegundos()
		this.Primero = lnFinal - lnInicial
		loFormulario.oKontroler.Ejecutar("CANCELAR")
		lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
		lcTablaDetalle = lcTablaDetalle + tcEntidad + ',primer nuevo,0,0,' + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		for lnInd = 1 to tnSerie
			this.Primero = 0
			this.Completo = 0
			this.Promedio = 0
*!*				lnInicial = this.ObtenerSegundos()
*!*				loFormulario.Ejecutar("NUEVO")
*!*				lnFinal = this.ObtenerSegundos()
*!*				loFormulario.Ejecutar("CANCELAR")
*!*				this.Primero = lnFinal - lnInicial
			for lnRep = 1 to tnRepeticion
				lnInicial = this.ObtenerSegundos()
				loFormulario.oKontroler.Ejecutar("NUEVO")
				lnFinal = this.ObtenerSegundos()
				lnTiempo = round((lnFinal - lnInicial)/1000,3)
				this.Completo = this.Completo + lnFinal - lnInicial
				this.Lista = ", " + alltrim(str(lnFinal - lnInicial,7,3))
				loFormulario.oKontroler.Ejecutar("CANCELAR")
				lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
				lcTablaDetalle = lcTablaDetalle + tcEntidad + ',nuevo,' + alltrim(str(lnInd)) + ',' + alltrim(str(lnRep)) + ',' + alltrim( str(round(lnTiempo,4),12,4)) + NUEVALINEA
			next
			this.Promedio = round(this.Completo / tnRepeticion,4)
			lcResultado = lcResultado + "Serie " + alltrim(str(lnInd)) + " - " + alltrim(str(tnRepeticion)) + " repeticiones" + NUEVALINEA
			lcResultado = lcResultado + "Total " + alltrim(str(this.Completo,4)) + " - Promedio " + alltrim(str(this.Promedio,4)) + NUEVALINEA
			this.TotalGeneral = this.TotalGeneral + this.Completo
			lcTablaResumen = lcTablaResumen + tcEntidad + ',nuevo,' + alltrim(str(tnRepeticion)) + ',' + alltrim(str(round(this.Completo,4),12,4)) + ',' + alltrim(str(round(this.Completo / tnRepeticion,4),12,4)) + NUEVALINEA
		next
		loFormulario.Release()
		this.PromedioGeneral = round(this.TotalGeneral / tnSerie,4)
		lcResultado = lcResultado + "Total general " + alltrim(str(round(this.TotalGeneral,4),12,4)) + " - Promedio " + alltrim(str(round(this.PromedioGeneral,4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Promedio ponderado " + alltrim(str(round(this.TotalGeneral / (tnRepeticion * tnSerie),4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Primer nuevo " + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		this.GrabarRegistro(this.Carpeta+"TiemposFormulario.log", lcResultado)
		this.TablaResumen = lcTablaResumen
		this.TablaDetalle = lcTablaDetalle
		return lcResultado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposEnInstanciarEntidad( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as String
		local lnInicial as Number, lnFinal as Number, lnTiempo as Number, lnTotal as Number, lnPromedio as Number, lcTablaResumen as String, lcTablaDetalle as String, loEntidad as Object
		tnRepeticion = iif(type('tnRepeticion')#'N' or tnRepeticion<1,10,tnRepeticion)
		tnSerie = iif(type('tnSerie')#'N' or tnSerie<1,1,tnSerie)
		lcTablaResumen = ''
		lcTablaDetalle = ''
		this.Detalle = ''
		this.Lista = ''
		this.TotalGeneral = 0
		this.PromedioGeneral = 0
		lcResultado = 'Tiempos en instanciar entidad ' + tcEntidad + NUEVALINEA
		lcResultado = lcResultado + "Motor (" + this.TipoMotorDB + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Driver " + this.DriverSQL + NUEVALINEA
		lcResultado = lcResultado + "Servidor (" + this.ServidorSQL + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Base de datos (" + this.NombreBaseDB + ")"+ NUEVALINEA
		lnInicial = this.ObtenerSegundos()
		loEntidad = _Screen.Zoo.InstanciarEntidad( tcEntidad )
		lnFinal = this.ObtenerSegundos()
		this.Primero = lnFinal - lnInicial
		loEntidad.Release()
		lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
		lcTablaDetalle = lcTablaDetalle + tcEntidad + ',primer instancia,0,0,' + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		for lnInd = 1 to tnSerie
			this.Primero = 0
			this.Completo = 0
			this.Promedio = 0
			for lnRep = 1 to tnRepeticion
				lnInicial = this.ObtenerSegundos()
				loEntidad = _Screen.Zoo.InstanciarEntidad( tcEntidad )
				lnFinal = this.ObtenerSegundos()
				lnTiempo = round((lnFinal - lnInicial)/1000,3)
				this.Completo = this.Completo + lnTiempo
				this.Lista = ", " + alltrim(str(lnTiempo,7,3))
				lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
				lcTablaDetalle = lcTablaDetalle + tcEntidad + ',instanciar,' + alltrim(str(lnInd)) + ',' + alltrim(str(lnRep)) + ',' + alltrim( str(round(lnTiempo,4),12,4)) + NUEVALINEA
				loEntidad.Release()
			next
			this.Promedio = round(this.Completo / tnRepeticion,4)
			lcResultado = lcResultado + "Serie " + alltrim(str(lnInd)) + " - " + alltrim(str(tnRepeticion)) + " repeticiones" + NUEVALINEA
			lcResultado = lcResultado + "Total " + alltrim(str(round(this.Completo,4),12,4)) + " - Promedio " + alltrim(str(round(this.Promedio,4),12,4)) + NUEVALINEA
			this.TotalGeneral = this.TotalGeneral + this.Completo
			lcTablaResumen = lcTablaResumen + tcEntidad + ',instanciar,' + alltrim(str(tnRepeticion)) + ',' + alltrim(str(round(this.Completo,4),12,4)) + ',' + alltrim(str(round(this.Completo / tnRepeticion,4),12,4)) + NUEVALINEA
		next
		this.PromedioGeneral = round(this.TotalGeneral / tnSerie,4)
		lcResultado = lcResultado + "Total general " + alltrim(str(round(this.TotalGeneral,4),12,4)) + " - Promedio " + alltrim(str(round(this.PromedioGeneral,4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Promedio ponderado " + alltrim(str(round(this.TotalGeneral / (tnRepeticion * tnSerie),4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Primer instancia " + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		this.GrabarRegistro(this.Carpeta+"log\TiemposSQLEntidadInstanciar.log", lcResultado)
		this.TablaResumen = lcTablaResumen
		this.TablaDetalle = lcTablaDetalle

		return lcResultado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposEnInstanciarFormulario( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as String
		local lnInicial as Number, lnFinal as Number, lnTiempo as Number, lnTotal as Number, lnPromedio as Number, lcTablaResumen as String, lcTablaDetalle as String, loFormulario as Object
		tnRepeticion = iif(type('tnRepeticion')#'N' or tnRepeticion<1,10,tnRepeticion)
		tnSerie = iif(type('tnSerie')#'N' or tnSerie<1,1,tnSerie)
		lcTablaResumen = ''
		lcTablaDetalle = ''
		this.Detalle = ''
		this.Lista = ''
		this.TotalGeneral = 0
		this.PromedioGeneral = 0
		lcResultado = 'Tiempos en instanciar formulario ' + tcEntidad + NUEVALINEA
		lcResultado = lcResultado + "Motor (" + this.TipoMotorDB + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Driver " + this.DriverSQL + NUEVALINEA
		lcResultado = lcResultado + "Servidor (" + this.ServidorSQL + ")"+ NUEVALINEA
		lcResultado = lcResultado + "Base de datos (" + this.NombreBaseDB + ")"+ NUEVALINEA
		lnInicial = this.ObtenerSegundos()
		loFormulario = goFormularios.Procesar( tcEntidad )
		lnFinal = this.ObtenerSegundos()
		this.Primero = lnFinal - lnInicial
		loFormulario.Release()
		lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
		lcTablaDetalle = lcTablaDetalle + tcEntidad + ',primer instancia,0,0,' + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		for lnInd = 1 to tnSerie
			this.Primero = 0
			this.Completo = 0
			this.Promedio = 0
			for lnRep = 1 to tnRepeticion
				lnInicial = this.ObtenerSegundos()
				loFormulario = goFormularios.Procesar( tcEntidad )
				lnFinal = this.ObtenerSegundos()
				lnTiempo = round((lnFinal - lnInicial)/1000,3)
				this.Completo = this.Completo + lnTiempo
				this.Lista = ", " + alltrim(str(lnTiempo,7,3))
				lcTablaDetalle = lcTablaDetalle + this.TipoMotorDB + ',' + this.DriverSQL + ',' + this.ServidorSQL + ',' + this.NombreBaseDB + ','
				lcTablaDetalle = lcTablaDetalle + tcEntidad + ',nuevo,' + alltrim(str(lnInd)) + ',' + alltrim(str(lnRep)) + ',' + alltrim( str(round(lnTiempo,4),12,4)) + NUEVALINEA
				loFormulario.Release()
			next
			this.Promedio = round(this.Completo / tnRepeticion,4)
			lcResultado = lcResultado + "Serie " + alltrim(str(lnInd)) + " - " + alltrim(str(tnRepeticion)) + " repeticiones" + NUEVALINEA
			lcResultado = lcResultado + "Total " + alltrim(str(round(this.Completo,4),12,4)) + " - Promedio " + alltrim(str(round(this.Promedio,4),12,4)) + NUEVALINEA
			this.TotalGeneral = this.TotalGeneral + this.Completo
			lcTablaResumen = lcTablaResumen + tcEntidad + ',instanciar,' + alltrim(str(tnRepeticion)) + ',' + alltrim(str(round(this.Completo,4),12,4)) + ',' + alltrim(str(round(this.Completo / tnRepeticion,4),12,4)) + NUEVALINEA
		next
		this.PromedioGeneral = round(this.TotalGeneral / tnSerie,4)
		lcResultado = lcResultado + "Total general " + alltrim(str(round(this.TotalGeneral,4),12,4)) + " - Promedio " + alltrim(str(round(this.PromedioGeneral,4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Promedio ponderado " + alltrim(str(round(this.TotalGeneral / (tnRepeticion * tnSerie),4),12,4)) + NUEVALINEA
		lcResultado = lcResultado + "Primer instancia " + alltrim( str(round(this.Primero,4),12,4)) + NUEVALINEA
		this.GrabarRegistro(this.Carpeta+"log\TiemposSQLFormularioInstanciar.log", lcResultado)
		this.TablaResumen = lcTablaResumen
		this.TablaDetalle = lcTablaDetalle
		loFormulario.Release()

		return lcResultado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposGrabarEnEntidad( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposGrabarEnFormulario( tcEntidad as String, tnRepeticion as Integer, tnSerie as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposGrabarComprobanteEnEntidad( tcComprobante as String, tnRepeticion as Integer, tnSerie as Integer, ;
			tlControlaStock as Boolean, tcCliente as String, tcProducto as String, tnLineas as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TiemposGrabarComprobanteEnFormulario( tcComprobante as String, tnRepeticion as Integer, tnSerie as Integer, ;
			tlControlaStock as Boolean, tcCliente as String, tcProducto as String, tnLineas as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSegundos() as Decimal
		local lnRetorno as Decimnal
		lnRetorno = seconds() * iif(this.Milisegundos,1000,1)
		return lnRetorno
	EndFunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define Class TiemposEnFormularios as Session

	Repeticion = 5
	Comprobantes = 5
	Articulos = 10
	Valores = 10
	TiempoGlobal = 0
	TiempoTotal = 0
	TiempoIndividual = 0
	NuevoGlobal = 0
	NuevoTotal = 0
	NuevoIndividual = 0
	CargaGlobal = 0
	CargaTotal = 0
	CargaIndividual = 0
	GrabarGlobal = 0
	GrabarTotal = 0
	GrabarIndividual = 0
	RegistroDetallado = ""
	Informe = ""
	Milisegundos = .t.
	cColor = ""
	cTalle = ""
	cHoraInicial = ""
	cHoraFinal = ""

	*-----------------------------------------------------------------------------------------
	Function Facturas() as Void

		local lnTiempoTotal as Integer, lnTiempo as Integer, loComprobante as Object, lnCantidad as Integer, lnItem as Integer, lcMensaje as String, lnArt as Integer, lnVal as Integer, lcAviso as String, lcNuevo as String, lcIndividual as String

		this.TiempoGlobal = 0
		this.TiempoTotal = 0

		this.GrabarGlobal = 0
		this.GrabarTotal = 0
		this.GrabarIndividual = 0

		this.NuevoGlobal = 0
		this.NuevoTotal = 0
		this.NuevoIndividual = 0

		lcAviso = ""
		lcNuevo = ""
		lcIndividual = ""

		this.cHoraInicial = time()

		for lcCantidad = 1 to this.Repeticion
			loComprobante = _Screen.Zoo.InstanciarEntidad( "Factura" )
			for lnItem = 1 to this.Comprobantes+1
				lnTiempo = this.ObtenerSegundos()
				this.TiempoIndividual = lnTiempo
				this.NuevoIndividual = lnTiempo
				loComprobante.Nuevo()
				lnTiempo = this.ObtenerSegundos()
				this.NuevoIndividual = lnTiempo - this.NuevoIndividual
				with loComprobante.FacturaDetalle
					for lnArt = 1 to this.Articulos
						.LimpiarItem()
						.oItem.Articulo_PK = "00100101"
						if !empty(this.cColor)
							.oItem.Color_PK = this.cColor
						endif
						if !empty(this.cTalle)
							.oItem.Talle_PK = this.cTalle
						endif
						.oItem.Cantidad = 1
						.oItem.Precio = 1
						.Actualizar()
					next
				endwith
				with loComprobante.ValoresDetalle
					for lnVal = 1 to this.Valores
						.LimpiarItem()
						.oItem.Valor_PK = "0"
						.oItem.Recibido = iif(lnVal = this.Valores,loComprobante.Total - (this.Valores - 1),1)
						.Actualizar()
					next
				endwith
				this.GrabarIndividual = this.ObtenerSegundos()
				this.CargaIndividual = this.GrabarIndividual - lnTiempo
				loComprobante.Grabar()
				lnTiempo = this.ObtenerSegundos()
				this.GrabarIndividual = lnTiempo - this.GrabarIndividual
				this.TiempoIndividual = lnTiempo - this.TiempoIndividual

				if lnItem = 1
					lcAviso = lcAviso + NUEVALINEA
				endif
*!*					lcAviso = lcAviso + " " + alltrim(str(this.TiempoIndividual))
				lcAviso = lcAviso + SEPARADOR + alltrim(str(this.TiempoIndividual)) + " (" + alltrim(str(this.NuevoIndividual)) + "-" + alltrim(str(this.GrabarIndividual)) + ") "
				if lnItem > 1
					this.TiempoTotal = this.TiempoTotal + this.TiempoIndividual
					this.NuevoTotal = this.NuevoTotal + this.NuevoIndividual
					this.GrabarTotal = this.GrabarTotal + this.GrabarIndividual
					this.CargaTotal = this.CargaTotal + this.CargaIndividual
				endif
			next
			
			loComprobante.Release()
		next
		this.RegistroDetallado = lcAviso + NUEVALINEA
		this.Informe = "Tiempo total por entidad " + SEPARADOR + str(this.TiempoTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por entidad " + SEPARADOR + str(this.TiempoTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA
		this.Informe = this.Informe + "Tiempo nuevo por entidad " + SEPARADOR + str(this.NuevoTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por entidad " + SEPARADOR + str(this.NuevoTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA
		this.Informe = this.Informe + "Tiempo grabar por entidad " + SEPARADOR + str(this.GrabarTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por entidad " + SEPARADOR + str(this.GrabarTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA 
		this.Informe = this.Informe + "Tiempo carga por entidad " + SEPARADOR + str(this.CargaTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por entidad " + SEPARADOR + str(this.CargaTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA 

		lcMensaje = "Tiempo total por entidad " + SEPARADOR + str(this.TiempoTotal) + NUEVALINEA
		lcMensaje = "Nuevo total por entidad " + SEPARADOR + str(this.NuevoTotal) + NUEVALINEA
		lcMensaje = "Grabar total por entidad " + SEPARADOR + str(this.GrabarTotal) + NUEVALINEA

		this.TiempoGlobal = this.TiempoTotal
		this.TiempoTotal = 0
		this.NuevoGlobal = this.NuevoTotal
		this.NuevoTotal = 0
		this.GrabarGlobal = this.GrabarTotal
		this.GrabarTotal = 0
		this.CargaGlobal = this.CargaTotal
		this.CargaTotal = 0

		lnTiempoTotal = 0

		lcAviso = ""
		lcNuevo = ""
		lcIndividual = ""

		for lcCantidad = 1 to this.Repeticion
			loComprobante = goServicios.Formularios.Procesar( "Factura" )
			for lnItem = 1 to this.Comprobantes+1
				lnTiempo = this.ObtenerSegundos()
				this.TiempoIndividual = lnTiempo
				this.NuevoIndividual = lnTiempo
				loComprobante.oEntidad.Nuevo()
				lnTiempo = this.ObtenerSegundos()
				this.NuevoIndividual = lnTiempo - this.NuevoIndividual
				with loComprobante.oEntidad.FacturaDetalle
					for lnArt = 1 to this.Articulos
						.LimpiarItem()
						.oItem.Articulo_PK = "00100101"
						if !empty(this.cColor)
							.oItem.Color_PK = this.cColor
						endif
						if !empty(this.cTalle)
							.oItem.Talle_PK = this.cTalle
						endif
						.oItem.Cantidad = 1
						.oItem.Precio = 1
						.Actualizar()
					next
				endwith
				with loComprobante.oEntidad.ValoresDetalle
					for lnVal = 1 to this.Valores
						.LimpiarItem()
						.oItem.Valor_PK = "0"
						.oItem.Recibido = iif(lnVal = this.Valores,loComprobante.oEntidad.Total - (this.Valores - 1),1)
						.Actualizar()
					next
				endwith
				this.GrabarIndividual = this.ObtenerSegundos()
				this.CargaIndividual = this.GrabarIndividual - lnTiempo
				loComprobante.oEntidad.Grabar()
				lnTiempo = this.ObtenerSegundos()
				this.GrabarIndividual = lnTiempo - this.GrabarIndividual
				this.TiempoIndividual = lnTiempo - this.TiempoIndividual
				if lnItem = 1
					lcAviso = lcAviso + NUEVALINEA
				endif
				lcAviso = lcAviso + SEPARADOR + alltrim(str(this.TiempoIndividual)) + " (" + alltrim(str(this.NuevoIndividual)) + "-" + alltrim(str(this.GrabarIndividual)) + ") "
				if lnItem > 1
					this.TiempoTotal = this.TiempoTotal + this.TiempoIndividual
					this.NuevoTotal = this.NuevoTotal + this.NuevoIndividual
					this.GrabarTotal = this.GrabarTotal + this.GrabarIndividual
					this.CargaTotal = this.CargaTotal + this.CargaIndividual
				endif
			next
			
			loComprobante.Release()
		next

		this.cHoraFinal = time()

		this.RegistroDetallado = this.RegistroDetallado + lcAviso + NUEVALINEA
		this.Informe = this.Informe + "Tiempo total por formulario " + SEPARADOR + str(this.TiempoTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por formulario " + SEPARADOR + str(this.TiempoTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA
		this.Informe = this.Informe + "Tiempo nuevo por formulario " + SEPARADOR + str(this.NuevoTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por formulario " + SEPARADOR + str(this.NuevoTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA
		this.Informe = this.Informe + "Tiempo grabar por formulario " + SEPARADOR + str(this.GrabarTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por formulario " + SEPARADOR + str(this.GrabarTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA
		this.Informe = this.Informe + "Tiempo carga por formulario " + SEPARADOR + str(this.CargaTotal) + NUEVALINEA
		this.Informe = this.Informe + "Promedio por formulario " + SEPARADOR + str(this.CargaTotal/(this.Repeticion * this.Comprobantes)) + NUEVALINEA

		this.TiempoGlobal = this.TiempoGlobal + this.TiempoTotal
		this.NuevoGlobal = this.NuevoGlobal + this.NuevoTotal
		this.GrabarGlobal = this.GrabarGlobal + this.GrabarTotal
		this.CargaGlobal = this.CargaGlobal + this.CargaTotal
		lcMensaje = lcMensaje + "Tiempo total por formulario " + SEPARADOR + str(this.TiempoTotal) + NUEVALINEA
		lcMensaje = lcMensaje + "Nuevo total por formulario " + SEPARADOR + str(this.NuevoTotal) + NUEVALINEA
		lcMensaje = lcMensaje + "Grabar total por formulario " + SEPARADOR + str(this.GrabarTotal) + NUEVALINEA
		lcMensaje = lcMensaje + "Carga total por formulario " + SEPARADOR + str(this.CargaTotal) + NUEVALINEA
		lcMensaje = "De " + this.cHoraInicial + " a " + this.cHoraFinal + NUEVALINEA + lcMensaje

		messagebox(lcMensaje)
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function ComprobanteDeCaja() as Void
		local lnTiempoTotal as Integer, lnTiempo as Integer, loComprobante as Object, lnCantidad as Integer, lnItem as Integer, lcMensaje as String, lnVal as Integer, lcNuevo as String, lcIndividual as String

		this.TiempoGlobal = 0
		this.TiempoTotal = 0
		
		this.GrabarGlobal = 0
		this.GrabarTotal = 0
		this.GrabarIndividual = 0

		this.NuevoGlobal = 0
		this.NuevoTotal = 0
		this.NuevoIndividual = 0

		lcAviso = ""
		lcNuevo = ""
		lcIndividual = ""

		lnTiempoTotal = 0

		for lcCantidad = 1 to this.Repeticion
			loComprobante = _Screen.Zoo.InstanciarEntidad( "ComprobanteDeCaja" )
			for lnItem = 1 to this.Comprobantes+1
				lnTiempo = this.ObtenerSegundos()
				this.TiempoIndividual = lnTiempo
				this.NuevoIndividual = lnTiempo
				loComprobante.Nuevo()
				this.NuevoIndividual = this.ObtenerSegundos() - this.NuevoIndividual
				loComprobante.OrigenDestino_PK = "DEMO"
				loComprobante.Concepto_PK = "CIERRE"
				loComprobante.Tipo = 2
				loComprobante.Vendedor_PK = "0000000011"
				for lnVal = 1 to 5
					loComprobante.Valores.LimpiarItem()
					loComprobante.Valores.oItem.Valor_PK = "0"
					loComprobante.Valores.oItem.Monto = 100
					loComprobante.Valores.Actualizar()
				endfor

				this.GrabarIndividual = this.ObtenerSegundos()
				loComprobante.Grabar()
				lnTiempo = this.ObtenerSegundos()
				this.GrabarIndividual = lnTiempo - this.GrabarIndividual
				this.TiempoIndividual = lnTiempo - this.TiempoIndividual
				if lnItem = 1
					lcAviso = lcAviso + chr(10) + chr(13)
				endif
				lcAviso = lcAviso + " " + alltrim(str(this.TiempoIndividual)) + " (" + alltrim(str(this.NuevoIndividual)) + "-" + alltrim(str(this.GrabarIndividual)) + ") "
				if lnItem > 1
					this.TiempoTotal = this.TiempoTotal + this.TiempoIndividual
					this.NuevoTotal = this.NuevoTotal + this.NuevoIndividual
					this.GrabarTotal = this.GrabarTotal + this.GrabarIndividual
				endif
			next
			loComprobante.Release()
		next

		this.RegistroDetallado = lcAviso + chr(10) + chr(13)
		this.Informe = "Tiempo total por entidad " + str(this.TiempoTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por entidad " + str(this.TiempoTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)
		this.Informe = this.Informe + "Tiempo nuevo por entidad " + str(this.NuevoTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por entidad " + str(this.NuevoTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)
		this.Informe = this.Informe + "Tiempo grabar por entidad " + str(this.GrabarTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por entidad " + str(this.GrabarTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)

		lcMensaje = "Tiempo total por entidad " + str(this.TiempoTotal)
		lcMensaje = "Nuevo total por entidad " + str(this.NuevoTotal) + chr(10) + chr(13)
		lcMensaje = "Grabar total por entidad " + str(this.GrabarTotal) + chr(10) + chr(13)


		this.TiempoGlobal = this.TiempoTotal
		this.TiempoTotal = 0
		this.NuevoGlobal = this.NuevoTotal
		this.NuevoTotal = 0
		this.GrabarGlobal = this.GrabarTotal
		this.GrabarTotal = 0

		lnTiempoTotal = 0

		lcAviso = ""
		lcNuevo = ""
		lcIndividual = ""

		for lcCantidad = 1 to this.Repeticion
			loComprobante = goServicios.Formularios.Procesar( "ComprobanteDeCaja" )
			for lnItem = 1 to this.Comprobantes+1
				lnTiempo = this.ObtenerSegundos()
				this.TiempoIndividual = lnTiempo
				this.NuevoIndividual = lnTiempo
				loComprobante.oEntidad.Nuevo()
				this.NuevoIndividual = this.ObtenerSegundos() - this.NuevoIndividual
				loComprobante.oEntidad.OrigenDestino_PK = "DEMO"
				loComprobante.oEntidad.Concepto_PK = "CIERRE"
				loComprobante.oEntidad.Tipo = 2
				loComprobante.oEntidad.Vendedor_PK = "0000000011"

				for lnVal = 1 to 5
					loComprobante.oEntidad.Valores.LimpiarItem()
					loComprobante.oEntidad.Valores.oItem.Valor_PK = "0"
					loComprobante.oEntidad.Valores.oItem.Monto = 100
					loComprobante.oEntidad.Valores.Actualizar()
				endfor
				this.GrabarIndividual = this.ObtenerSegundos()
				loComprobante.oEntidad.Grabar()
				lnTiempo = this.ObtenerSegundos()
				this.GrabarIndividual = lnTiempo - this.GrabarIndividual
				this.TiempoIndividual = lnTiempo - this.TiempoIndividual
				if lnItem = 1
					lcAviso = lcAviso + chr(10) + chr(13)
				endif
				lcAviso = lcAviso + " " + alltrim(str(this.TiempoIndividual)) + " (" + alltrim(str(this.NuevoIndividual)) + "-" + alltrim(str(this.GrabarIndividual)) + ") "
				if lnItem > 1
					this.TiempoTotal = this.TiempoTotal + this.TiempoIndividual
					this.NuevoTotal = this.NuevoTotal + this.NuevoIndividual
					this.GrabarTotal = this.GrabarTotal + this.GrabarIndividual
				endif
			next
			loComprobante.Release()
		next

		this.RegistroDetallado = this.RegistroDetallado + lcAviso + chr(10) + chr(13)
		this.Informe = this.Informe + "Tiempo total por formulario " + str(this.TiempoTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por formulario " + str(this.TiempoTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)
		this.Informe = this.Informe + "Tiempo nuevo por formulario " + str(this.NuevoTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por formulario " + str(this.NuevoTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)
		this.Informe = this.Informe + "Tiempo grabar por formulario " + str(this.GrabarTotal) + chr(10) + chr(13)
		this.Informe = this.Informe + "Promedio por formulario " + str(this.GrabarTotal/(this.Repeticion * this.Comprobantes)) + chr(10) + chr(13)

		this.TiempoGlobal = this.TiempoGlobal + this.TiempoTotal
		this.NuevoGlobal = this.NuevoGlobal + this.NuevoTotal
		this.GrabarGlobal = this.GrabarGlobal + this.GrabarTotal
		lcMensaje = lcMensaje + +chr(10) + chr(13) + "Tiempo total por formulario " + str(this.TiempoTotal)
		lcMensaje = lcMensaje + +chr(10) + chr(13) + "Tiempo total por formulario " + str(lnTiempoTotal)
		lcMensaje = "Nuevo total por formulario " + str(this.NuevoTotal) + chr(10) + chr(13)
		lcMensaje = "Grabar total por formulario " + str(this.GrabarTotal) + chr(10) + chr(13)

		messagebox(this.Informe)
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function ObtenerSegundos() as Decimal
		local lnRetorno as Decimnal
		lnRetorno = seconds() * iif(this.Milisegundos,100,1)
		return lnRetorno
	EndFunc 

EndDefine
