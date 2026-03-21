define class logSC As Custom

	hidden cTextoAcumulado
	hidden cSerie
	hidden cVersion
	hidden Tabla

	cRuta = ""
	oSpecialFolders = null
	cTextoAcumulado = ""
	cDesactivacion = ""
	cSerie = ""
	cVersion = ""
	cVG = ""
	cVD = ""
	cVV = ""
	cVM = ""
	Tabla = ""
	TipoIng = ""

	*-----------------------------------------------------------------------------------------
	procedure init()
		#Define	CSIDL_COMMON_APPDATA	0x0023
		local lcTabla as string, lcRutaArchivosDePrograma as string, lcNombreProducto As String

		dodefault()

		set procedure to "getspecialfolder.prg"

		this.cSerie 	= _screen.zoo.app.cSerie
		this.cVersion	= _screen.zoo.app.obtenerversion()

		this.cRuta = _Screen.Zoo.cRutaInicial
		this.oSpecialFolders = createobject("GetSpecialFolder")
		lcRutaArchivosDePrograma = this.oSpecialFolders.DevuelveRuta( CSIDL_COMMON_APPDATA )

		lcNombreProducto = _Screen.Zoo.App.NombreProducto

		if !directory( addbs( lcRutaArchivosDePrograma ) + "Zoo Logic" )
			md ( addbs( lcRutaArchivosDePrograma ) + "Zoo Logic" )
		endif

		if !directory( addbs( lcRutaArchivosDePrograma ) + "Zoo Logic\" + lcNombreProducto )
			md ( addbs( lcRutaArchivosDePrograma ) + "Zoo Logic\" + lcNombreProducto )
		endif

		this.Tabla = addbs( lcRutaArchivosDePrograma ) + "Zoo Logic\" + lcNombreProducto + "\logCod.dat"
		lcTabla = this.Tabla

		if file( lcTabla )
			if this.VerificarTabla( lcTabla )
			else
				this.ArreglarTabla( lcTabla )
			endif
		else
			this.CrearTabla( lcTabla )
		endif

	endproc

	*-----------------------------------------------------------------------------------------
	protected function VerificarTabla( tcTabla as string ) as Boolean
		local llRetorno as Boolean, loError as exception
		llRetorno = .t.
		try
			use ( tcTabla ) exclu
			use in select( tcTabla )
		catch to loError
			llRetorno = .f.
		endtry

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArreglarTabla( tcTabla as string ) as Void
		delete file ( ForceExt( tcTabla, "*" ) )
		if !file( tcTabla )
			this.CrearTabla( tcTabla )
			use in select( juststem( tcTabla ) )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Reparar( tcTabla as string ) as boolean
		local lcCamino as string, llRetorno as Boolean, llReind_now as Boolean
		llReind_now = .t.
		llTablaReparada = .f.
		dimension lcBadFile[2]

		llRetorno = .t.
		lcCamino = addbs( justpath( tcTabla ) )
		try
			This.Repair( lcCamino, justfname( tcTabla ),@lcBadFile,@llReind_now )
			llTablaReparada = .t.
		catch to loError
		endtry

		if used( tcTabla )
		else
			llRetorno = .f.
			&& BADFILE( 1 ) o BADFILE( 2 )
		endif
		use in select( tcTabla )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearTabla( tcTabla ) as void
		create table ( tcTabla ) free ( 	fecha D, ;
											hora C(8), ;
											coddes C(50), ;
											serie C(6), ;
											IdHW C(4), ;
											IdTXT C(254), ;
											VG C(20), ;
											VM C(20), ;
											VD C(20), ;
											VV C(20), ;
											Carpeta C(100), ;
											version C(10), ;
											PC M, ;
											TipoIng C(10) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Loguear() as Void
		local lcTabla as string

		lcTabla = this.Tabla
		use ( lcTabla ) shared

		try
			if This.TipoIng != "ENT"
				this.ObtenerDatos()
			endif
		catch to loError
			this.cTextoAcumulado = this.cTextoAcumulado + chr( 13 ) + chr( 10 ) + loError.message
		endtry

		append blank
		replace coddes with this.cDesactivacion, ;
			serie with this.cSerie, ;
			IdHW with iif( This.TipoIng != "ENT", substr( this.cDesactivacion, 10, 4 ), ""), ;
			idTXT with this.ObtTextoIdTXT(), ;
			carpeta with sys( 5 ) + curdir(), ;
			logcod.version with left( this.cVersion, 7 ), ;
			VG with this.cVG, ;
			VD with this.cVD, ;
			VV with this.cVV, ;
			VM with this.cVM, ;
			pc with this.cTextoAcumulado, ;
			fecha with date(), ;
			hora with time(), ;
			TipoIng With This.TipoIng

		use in select( juststem( lcTabla ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtTextoIdTXT
		local lcRetorno as string
		lcRetorno = ""

		if file( "..\id.txt" )
			lcRetorno = filetostr( "..\id.txt" )
			lcRetorno = strtran( lcRetorno, chr( 13 ) + chr( 10 ), " | " )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDatos() as Void
		local o, od, op
		o = createobject('Wscript.Network')
		this.ConcatenarValores( "Dominio: " + o.UserDomain )
		this.ConcatenarValores( "Usuario: " + o.UserName )
		this.ConcatenarValores( " " )
		this.ConcatenarValores( "UNIDADES DE RED" )
		oD = o.EnumNetworkDrives
		for i = 0 to oD.count-1 step 2
			this.ConcatenarValores( "Unidad: " + oD.item(i) + " - Recurso: " + oD.item(i+1) )
		endfor
		this.ConcatenarValores( " " )
		this.ConcatenarValores( "IMPRESORAS" )
		oP = o.EnumPrinterConnections
		for i = 0 to oP.count-1 step 2
			this.ConcatenarValores( "Puerto: " + oP.item(i) +  " - Impresora: " + oP.item(i+1) )
		endfor
		release oD
		release oP
		release o

		this.ConcatenarValores( " " )
		this.ConcatenarValores( "SISTEMA OPERATIVO" )
		this.DatosSO()

		this.ConcatenarValores( " " )
		this.ConcatenarValores( "PROCESADOR" )
		this.DatosProcesador()

		this.ConcatenarValores( " " )
		this.ConcatenarValores( "EQUIPO" )
		this.DatosSistema()

		local lcComputerName, loWMIService, loItems, loItem, lcMACAddress
		lcComputerName = "."
		loWMIService = getobject("winmgmts:\\" + lcComputerName + "\root\cimv2")
		loItems = loWMIService.ExecQuery("Select * from Win32_NetworkAdapter",,48)

		this.ConcatenarValores( " " )
		this.ConcatenarValores( " " )
		this.ConcatenarValores( "ADAPTADORES DE RED" )	&&+ transform( j ) )
		for each loItem in loItems
			lcMACAddress = loItem.MACAddress
			if !isnull(lcMACAddress)
				this.ConcatenarValores( "Nombre: " + loItem.name )
				this.ConcatenarValores( "Descripción: " + loItem.description )
				this.ConcatenarValores( "Tipo de adaptador: " + loItem.AdapterType )
				this.ConcatenarValores( "Fabricante: " + loItem.Manufacturer )
				this.ConcatenarValores( "MAC Address: " + loItem.MACAddress )
				this.ConcatenarValores( "Fecha de último reinicio: " + transform( loItem.TimeOfLastReset ) )
			else
				this.ConcatenarValores( "Nombre: " + loItem.name + " - (SIN MAC ADDRESS)" )
			endif
			this.ConcatenarValores( " " )
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ConcatenarValores( tcLinea as string ) as Void
		this.cTextoAcumulado = this.cTextoAcumulado + tcLinea + chr(13)+ chr(10)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DatosSO() as Void
		local loWMIService, loItems, loItem
		loWMIService = getobject("winmgmts:\\.")
		loItems = loWMIService.ExecQuery("Select * from Win32_OperatingSystem")

		for each loItem in loItems
			this.ConcatenarValores( "Nombre: " + loItem.name )
			this.ConcatenarValores( "Versión: " + loItem.version )
			this.ConcatenarValores( "Service Pack (Major): " + transform( loItem.ServicePackMajorVersion ) )
			this.ConcatenarValores( "Service Pack (Minor): " + transform( loItem.ServicePackMinorVersion ) )
			this.ConcatenarValores( "Fabricante: " + loItem.Manufacturer )
			this.ConcatenarValores( "Carpeta Windows: " + loItem.WindowsDirectory )
			this.ConcatenarValores( "Memoria física libre: " + transform( int(val(loItem.FreePhysicalMemory)) ) )
			this.ConcatenarValores( "Memoria virtual total: " + transform( int(val(loItem.TotalVirtualMemorySize)) ) )
			this.ConcatenarValores( "Memoria virtual disponible: " + transform( int(val(loItem.FreeVirtualMemory)) ) )
		next
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DatosProcesador() as Void
		local lcComputerName, loWMI, lowmiWin32Objects, lowmiWin32Object
		lcComputerName = getwordnum(sys(0),1)
		loWMI = getobject("WinMgmts://" + lcComputerName)
		lowmiWin32Objects = loWMI.InstancesOf("Win32_Processor")

		for each loItem in lowmiWin32Objects
			this.ConcatenarValores( "ID: " + transform(loItem.ProcessorId) )
			this.ConcatenarValores( "Arquitectura: " + transform( loItem.Architecture ) )
			this.ConcatenarValores( "Descripción: " + loItem.description )
			this.ConcatenarValores( "Velocidad de reloj: " + transform( loItem.MaxClockSpeed ) )
			this.ConcatenarValores( "Fabricante: " + transform( loItem.Manufacturer ) )
			this.ConcatenarValores( "Nombre: " + transform( loItem.name ) )
			this.ConcatenarValores( "Tipo de procesador: " + transform( loItem.ProcessorType ) )
			this.ConcatenarValores( "Versión: " + transform( loItem.version ) )
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DatosSistema() as Void
		local loWMIService, loItems, loItem
		loWMIService = getobject("winmgmts:\\.")
		loItems = loWMIService.ExecQuery("Select * from Win32_ComputerSystem")

		for each loItem in loItems
			this.ConcatenarValores( "Nombre: " + loItem.name )
			this.ConcatenarValores( "Fabricante: " + loItem.Manufacturer )
			this.ConcatenarValores( "Modelo: " + loItem.Model )
			this.ConcatenarValores( "Memoria física total: " + transform( loItem.TotalPhysicalMemory ) )
		next
	endfunc


enddefine