*-----------------------------------------------------------------------------------------
define class GestorDeExcepcionesSQLServer as custom

	#IF .f.
		Local this as GestorDeExcepcionesSQLServer of GestorDeExcepcionesSQLServer.prg
	#ENDIF

	protected oInformacion
	oInformacion = null

	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as Object
		with this
			if !vartype( .oInformacion ) = "O" and isnull( .oInformacion )
				if !vartype( .oInformacion ) = "O" and isnull( .oInformacion )
					.oInformacion = _screen.Zoo.CrearObjeto( "ZooInformacion" )
				endif	
			endif
		endwith
		return this.oInformacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function LevantarExcepcion( tcQueryEjecutada as String, taError as Array ) as Void
		local loError as Object
		external array taError
		this.oInformacion.Limpiar()

		if vartype( taError[ 1 ] ) = "L"
			This.AgregarInformacion( "Error en la conexión verifique que el usuario tenga permisos para la ejecución.")
			This.AgregarInformacion( "Instrucción SQL no realizada: " + tcQueryEjecutada )			
		else
			if taError[ 1 ] == 1526 && Error de ODBC
				do case
					case taError[ 5 ] == 3960 or taError[ 5 ] = 3961
						this.AgregarInformacion( "No se puede realizar la operación. La base de datos no se encuentra disponible. Espere un momento e intente nuevamente." )
					case inlist( taError[ 5 ], 457, 468 ) && Error de Collation.
						this.AgregarInformacion( chr( 13 ) + chr( 10 ) + "Instrucción SQL no realizada: " + tcQueryEjecutada, taError[ 5 ] )
						try
							this.AgregarInformacionDeCollationIcorrectasEnBDsDeNegocio( tcQueryEjecutada )
							this.AgregarInformacionDeCollationIcorrectas( goDatos.ObtenerNombreBD( "ADNIMPLANT" ) )
							this.AgregarInformacionDeCollationIcorrectas( goDatos.ObtenerNombreBD( "ZOOLOGICMASTER" ) )
							this.AgregarInformacion( "Collation requerida: " + this.ObtenerCollationMandatoria() )
						catch
						endtry
						this.AgregarInformacion( "No es posible realizar esta operación. Algunas bases de datos están utilizando una Collation distinta a la requerida por la aplicación." + ;
							" Por favor comuniquese con la Mesa de Ayuda de Zoo Logic para recibir asistencia." )
					otherwise
						this.AgregarInformacion( "Instrucción SQL no realizada: " + tcQueryEjecutada )
						this.AgregarInformacion( "Estado SQL: " + taError[ 4 ] )
						this.AgregarInformacion( "Error ODBC: " + taError[ 3 ] )
						this.AgregarInformacion( "Error SQL: " + taError[ 2 ] )
						this.AgregarInformacion( "Código de Error SQL: " + transform( taError[ 5 ] ) )
				endcase
	
				if taError[ 5 ] == 2601
					This.AgregarInformacion( "Se ha infringido una restricción del motor de base de datos." )
				endif
			endif
		endif
		goServicios.Errores.LevantarExcepcion( this.oInformacion )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerProblemaEnBaseDeDatos( tcDB as String, tnConexion as Integer ) as String
		local lcRetorno as String, lcCursor as String, lcEstado as String
		lcRetorno = ""
		lcCursor = sys( 2015 )
		if !goServicios.Librerias.ExisteBaseDeDatosSqlServer( tcDB )
			lcRetorno = "La base de datos " + tcDB + " no existe."
		else
			sqlexec( tnConexion, "SELECT DATABASEPROPERTYEX( '" + tcDB + "', 'Status' ) AS DBStatus", lcCursor )
			lcEstado = upper( alltrim( &lcCursor..DBStatus ) )
			if lcEstado != "ONLINE"
				lcRetorno = "No es posible tener acceso a la base de datos " + tcDB + " debido a que se encuentra en estado " + lcEstado + "."
			else
				sqlexec( tnConexion, "SELECT User_Access_Desc FROM Sys.Databases WHERE name = '" + tcDB + "'", lcCursor )
				lcEstado = upper( alltrim( &lcCursor..User_Access_Desc ) )
				if lcEstado == "SINGLE_USER"
					lcRetorno = "No es posible tener acceso a la base de datos " + tcDB + " debido a que esta configurada en el modo SINGLE_USER."
				endif
			endif
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInformacionDeCollationIcorrectasEnBDsDeNegocio( tcQueryEjecutada as String ) as Void
		local lcCursor as String, lcBD as String
		lcCursor = sys( 2015 )
		this.AgregarInformacionDeCollationIcorrectas( goDatos.ObtenerNombreBD( _Screen.Zoo.App.cSucursalActiva ) )
		goDatos.EjecutarSentencias( "SELECT EmpCod FROM [" + goDatos.ObtenerNombreBD( "ZOOLOGICMASTER" ) + "].PUESTO.Emp", "", "", lcCursor, set( "Datasession" ) )
		select( lcCursor )
		scan for upper( alltrim( EmpCod ) ) != upper( alltrim( _Screen.Zoo.App.cSucursalActiva ) )
			lcBD = goDatos.ObtenerNombreBD( EmpCod )
			if atc( lcBD, tcQueryEjecutada, 1 ) > 0
				this.AgregarInformacionDeCollationIcorrectas( goDatos.ObtenerNombreBD( EmpCod ) )
			endif
		endscan
		use in select( lcCursor )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInformacion( tcInformacion as String, tnNumero as Integer ) as Void
		if pcount() == 2
			this.oInformacion.AgregarInformacion( tcInformacion, tnNumero )
		else
			this.oInformacion.AgregarInformacion( tcInformacion )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCollationMandatoria() as String
		local lcCollation as String, lcBD as String, loAdminDB as Object
		loAdminDB = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.BasesDeDatos.AdministradorBD", "", "" )
		lcCollation = loAdminDB.CollationDefault
		lcBD = ""

		do case
			case goServicios.Librerias.ExisteBaseDeDatos( goDatos.ObtenerNombreBD( "ZOOLOGICMASTER" ) )
				lcBD = goDatos.ObtenerNombreBD( "ZOOLOGICMASTER" )
			case goServicios.Librerias.ExisteBaseDeDatos( goDatos.ObtenerNombreBD( "ADNIMPLANT" ) )
				lcBD = goDatos.ObtenerNombreBD( "ADNIMPLANT" )
		endcase

		if !empty( lcBD )
			lcCollation = this.ObtenerCollationDeBD( lcBD )
		endif
		return lcCollation
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCollationDeBD( tcBD as String ) as String
		local lcCollation as String, lcQuery as String, lcCursor as String
		lcQuery = "SELECT DATABASEPROPERTYEX( '" + tcBD + "', 'Collation' ) AS Collation"
		lcCursor = sys( 2015 )
		goDatos.EjecutarSentencias( lcQuery, "", "", lcCursor, set( "Datasession" ) )
		lcCollation = alltrim( &lcCursor..Collation )
		use in select( lcCursor )
		return lcCollation
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCollationsUtilizadasEnUnaBD( tcBD as String ) as Collection
		local loListaDeCollations as Object, lcQuery as String, lcCursor as String
		loListaDeCollations = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		lcCursor = sys( 2015 )
		text to lcQuery textmerge flags 1 noshow
			SELECT DISTINCT Collation FROM (
				SELECT
					c.Collation_Name AS Collation
				FROM
					[<<tcBD>>].sys.tables AS tab
				INNER JOIN
					[<<tcBD>>].sys.schemas AS sch ON tab.schema_id = sch.schema_id
				LEFT JOIN
				    [<<tcBD>>].sys.columns AS c ON tab.[Object_id] = c.[Object_id]
				INNER JOIN
				    [<<tcBD>>].sys.types t ON c.system_type_id = t.system_type_id
				LEFT OUTER JOIN
				(
				SELECT  ic.object_id, ic.column_id, i.is_primary_key
				FROM
				    [<<tcBD>>].sys.index_columns ic 
				INNER JOIN 
				    [<<tcBD>>].sys.indexes i ON ic.object_id = i.object_id AND 
					ic.index_id = i.index_id AND i.is_primary_key = 1) AS ClavesPrimarias ON ClavesPrimarias.object_id = c.object_id AND ClavesPrimarias.column_id = c.column_id
				LEFT OUTER JOIN  
				    [<<tcBD>>].sys.extended_properties p on p.major_id = tab.[Object_id] AND p.class = 1
				) Indices
				WHERE Collation IS NOT NULL
				ORDER BY Collation
		endtext
		goDatos.EjecutarSentencias( lcQuery, "", "", lcCursor, set( "Datasession" ) )
		select ( lcCursor )
		scan all
			loListaDeCollations.Agregar( alltrim( Collation ) )
		endscan
		use in select( lcCursor )
		return loListaDeCollations
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInformacionDeCollationIcorrectas( tcBD as String ) as Void
		local lcRetorno as String, loCollationsEnBD as Object, lcCollation as String, lcCollationMandatoria as String
		lcCollationMandatoria = this.ObtenerCollationMandatoria()
		lcCollation = this.ObtenerCollationDeBD( tcBD )
		if ( lcCollation != lcCollationMandatoria )
			this.AgregarInformacion( "La base de datos " + tcBD + " posee la Collation " + lcCollation + " la cual es incorrecta." )
		else
			loCollationsEnBD = this.ObtenerCollationsUtilizadasEnUnaBD( tcBD )
			for each lcCollation in loCollationsEnBD
				if lcCollation != lcCollationMandatoria
					this.AgregarInformacion( "Algunos objetos de la base de datos " + tcBD + " poseen la Collation " + lcCollation + " la cual es incorrecta." )
				endif
			endfor
		endif
	endfunc

enddefine
