define class AccesoDatosEntidad_sqlServer as AccesoDatosEntidad of AccesoDatosEntidad.prg

	#if .f.
		local this as AccesoDatosEntidad_sqlServer of AccesoDatosEntidad_sqlServer.prg
	#endif

	nCantABorrar  = 1000
	nCantVeces = 0
	oSp = null

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void

		this.lDestroy = .t.
	
		if type( 'This.oSp' ) = 'O' and !isnull( This.oSp )
			this.oSp.oConexion = null
			this.oSp = null
		endif
	
		dodefault()
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MirarSentencias() as Void

		if this.ColSentencias.Count > 0
			=strtofile("Entidad: "+this.oEntidad.ObtenerNombre()+"(sentencias de componentes)"+chr(13)+chr(10),"c:\tmp\sentencias.txt",1)
		endif
		for each line1 in this.ColSentencias
			=strtofile(line1+chr(13)+chr(10),"c:\tmp\sentencias.txt",1)
		endfor 
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	Function oSp_Access() As object
		if !this.ldestroy and ( vartype( this.oSp ) != 'O' or isnull( this.oSp ) )
			this.oSp = this.crearobjeto( 'Din_ProcedimientosAlmacenados' )
			this.oSp.cRutaTablas = this.cRutaTablas
			this.oSp.oConexion = this.oConexion
		endif
		return this.oSp
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearConexionParaTransaccion() as Void
		this.oConexion = _screen.zoo.app.oPoolConexiones.ObtenerConexion( this.oEntidad )
		this.oSp.oConexion = this.oConexion
		this.oConexion.ConectarMotorSQL()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearConexionGlobal() as Void
		_screen.zoo.app.oPoolConexiones.DevolverConexion( this.oConexion, this.oEntidad )
		this.oConexion = goServicios.Datos
		this.oSp.oConexion = this.oConexion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCamposImpo() as Void
		local lcHora as string, ldFecha as Date, lcCursor as String, lcUsuario as String 
		ldFecha = goLibrerias.ObtenerFecha()
		lcHora = goLibrerias.ObtenerHora()
		lcUsuario = alltrim( goServicios.Seguridad.cUsuarioLogueado )
		lcCursor = this.oEntidad.cPrefijoImportar + this.oEntidad.ObtenerNombre()
		Replace all in &lcCursor HORAIMPO With lcHora, FECIMPO With ldFecha, FModiFW with ldFecha, HModiFW with lcHora, UAltaFW with lcUsuario, UModiFW with lcUsuario
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarCamposRecepcion() as Void
		local ldFecha as Date, lcCursor as String, lcUsuario as String 
		ldFecha = goLibrerias.ObtenerFecha()
		lcCursor = This.oEntidad.cPrefijoRecibir + this.oEntidad.ObtenerNombre()
		Replace all in &lcCursor ESTTRANS With [RECIBIDO], FECTRANS With ldFecha
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaTriggerImportacion() as string
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirConexionRecibir() as Void
		this.SetearConexionParaTransaccion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarConexionRecibir() as Void
		this.SetearConexionGlobal()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarTransaccionRecibir() as Void
		this.oConexion.EjecutarSql( 'BEGIN TRANSACTION' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FinalizarTransaccionRecibir() as Void
		this.oConexion.EjecutarSql( 'COMMIT TRANSACTION' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RollbackTransaccionRecibir() as Void
		this.oConexion.EjecutarSql( 'ROLLBACK TRANSACTION' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionRecibirDetalles() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionRecibirCabecera() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInSqlServer( tcCursor as String, tcCampoPk as String, tcTipo as String ) as String
		local lcRetorno As String
		lcRetorno = ""
		select &tcCursor
		scan all 
			if tcTipo = "N"
				lcRetorno = lcRetorno + "," +  transform( &tcCursor..&tcCampoPk )
			Else
				lcRetorno = lcRetorno + ",'" + transform( &tcCursor..&tcCampoPk ) + "'"
			Endif
		endscan
		lcRetorno = substr( lcRetorno, 2 )
		lcRetorno = " in (" + lcRetorno + ")"
		return lcRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerWhereYHaving( tcHaving as String, tcWhereYHaving as string, tcNombreFuncion as String )
		local lcCamposHaving as String, lcRetorno as String

		lcCamposHaving = this.ConvertirAtributosCadenaSql( tcNombreFuncion, tcHaving )
		if atc( "where", tcWhereYHaving ) > 0
			lcRetorno = tcWhereYHaving + ' and ' + lcCamposHaving 
		else
			lcRetorno = ' where ' + lcCamposHaving 
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ejecutarSentencias( loColeccionSentencias as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcSent as String, lcItem as String

		for each lcItem in loColeccionSentencias
			this.oConexion.EjecutarSql( lcItem )
		endfor
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionInSqlServer( tcCursor as String, tcSucursal as String, tcCampoPk as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcValor as String 
		
		loRetorno = _Screen.zoo.crearobjeto( "ZooColeccion" )		
		select &tcCursor
		if empty( tcSucursal )
			scan all
				lcValor = rtrim( transform( &tcCursor..&tcCampoPk ) )
				if vartype( &tcCursor..&tcCampoPk ) != "N"
					lcValor = "'" + lcValor + "'"
				endif
				loRetorno.Agregar( lcValor )
			endscan
		else
			scan all for upper( alltrim( Database ) ) == upper( alltrim( tcSucursal ) )
				lcValor = rtrim( transform( &tcCursor..&tcCampoPk ) )
				if vartype( &tcCursor..&tcCampoPk ) != "N"
					lcValor = "'" + lcValor + "'"
				endif
				loRetorno.Agregar( lcValor )
			endscan
		endif
		return loRetorno
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerFragmentoColeccionInSqlServer( toColeccion as zoocoleccion OF zoocoleccion.prg, tnInicio as Integer, tnCantidad as Integer ) as string
		local lcRetorno as string, lcValor as String, i as Integer, lnCantidad as Integer

		lcRetorno = ""
		
		for i = 0 to tnCantidad - 1
			if ( tnInicio + i ) > toColeccion.count
				exit
			else
				lcRetorno = lcRetorno + "," + toColeccion.Item( tnInicio + i )
			endif
		endfor
		
		if !empty( lcRetorno )
			lcRetorno = substr( lcRetorno, 2 )
			lcRetorno = " in (" + lcRetorno + ")"
		endif
		return lcRetorno	
	endfunc 

enddefine
