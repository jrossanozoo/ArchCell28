#define NUEVALINEA	chr(13) + chr(10)
#define SEPARADOR	chr(9)

define class ColaboradorBase as Session

	#if .f.
		Local this as ColaboradorBase of ColaboradorBase.prg
	#endif
	
	TipoMotorDB = ''
	ServidorSQL = ''
	NombreBaseDB = ''
	DriverSQL = ''

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local loMotor as Object, lcString as String, lnPosicion as Integer
		set memowidth to 120
		dodefault()
		this.TipoMotorDB = _screen.zoo.app.TipoDeBase
		this.ServidorSQL = _Screen.Zoo.App.cNombreDelServidorSQL
		this.NombreBaseDB = _Screen.zoo.App.cSucursalActiva
		loMotor = _Screen.Zoo.CrearObjetoPorProducto( "ColaboradorConexion", "CursoresVFPSQL.prg")
		lcString = loMotor.ObtenerStringDeConexion()
		lnPosicion = at("Driver=",lcString)
		lcString = substr(lcString,lnPosicion)
		lnPosicion = at(";",lcString)
		lcString = left(lcString, lnPosicion-1)
		this.DriverSQL = lcString
		loMotor.Release()
	endfunc 


	*-----------------------------------------------------------------------------------------
	function GrabarRegistro( tcArchivo as String, tcDetalle as String ) as Void
		local lnHandle as Integer
		if type('tcArchivo') = 'C' and !empty(tcArchivo) and type('tcDetalle') = 'C' and !empty(tcDetalle)
			if file(tcArchivo)
				lnHandle = fopen(tcArchivo,1)
				fseek(lnHandle,0,2)
			else
				lnHandle = fcreate(tcArchivo)
			endif
			for lnLinea = 1 to memlines(tcDetalle)
				fwrite(lnHandle,mline(tcDetalle,lnLinea)+NUEVALINEA)
			next
			fclose(lnHandle)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GrabarCVS( tcArchivo as String, tcDetalle as String, tcCabecera as String ) as Void
		local lnHandle as Integer
		if type('tcArchivo') = 'C' and !empty(tcArchivo) and type('tcDetalle') = 'C' and !empty(tcDetalle)
			if file(tcArchivo)
				lnHandle = fopen(tcArchivo,1)
				fseek(lnHandle,0,2)
			else
				lnHandle = fcreate(tcArchivo)
				if type('tcCabecera') = 'C' and !empty(tcCabecera)
					fwrite(lnHandle,tcCabecera+NUEVALINEA)
				endif
			endif
			for lnLinea = 1 to memlines(tcDetalle)
				fwrite(lnHandle,mline(tcDetalle,lnLinea)+NUEVALINEA)
			next
			fclose(lnHandle)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		*this.Destroy() se llama con el release this automaticamente
		release this 
	endfunc

enddefine

