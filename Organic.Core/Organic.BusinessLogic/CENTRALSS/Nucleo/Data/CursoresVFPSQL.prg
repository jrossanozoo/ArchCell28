define class CursoresVFPSQL as zooSession of zooSession

	#if .f.
		local this as CursoresVFPSQL of CursoresVFPSQL.prg
	#endif

	StringConexion = ""
	CarpetaTemporal = ""

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		loManager = _Screen.Zoo.CrearObjeto( "ColaboradorConexion", "CursoresVFPSQL.prg")
		this.StringConexion = loManager.ObtenerStringDeConexion()
		this.CarpetaTemporal = _Screen.Zoo.Obtenerrutatemporal()
		this.CrearBaseDeCursores()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerBaseDeDatos() as String
		return this.CarpetaTemporal+'BaseCursoresVFP.DBC'
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AbrirBase() as Void
		if !file(this.CarpetaTemporal+'BaseCursoresVFP.DBC')
			this.CrearBaseDeCursores
*!*			else
*!*				open database (this.CarpetaTemporal+'BaseCursoresVFP.DBC')
		endif
		open database (this.CarpetaTemporal+'BaseCursoresVFP.DBC')
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarBase() as Void
		close databases
	endfunc 

	FUNCTION CrearConexion_SQLDragonFish
	***************** Connection Definitions SQLEXPRESS2019 ***************

	CREATE CONNECTION SQLDragonFish ; 
	   CONNSTRING this.StringConexion
	****
*!*		CONNSTRING "Driver={Sql Server Native Client 11.0};Server=.\SQLEXPRESS2019;Trusted_Connection=Yes;Database=DRAGONFISH_DEMO"
	****
	DBSetProp('SQLDragonFish', 'Connection', 'Asynchronous', .F.)
	DBSetProp('SQLDragonFish', 'Connection', 'BatchMode', .T.)
	DBSetProp('SQLDragonFish', 'Connection', 'Comment', '')
	DBSetProp('SQLDragonFish', 'Connection', 'DispLogin', 3)
	DBSetProp('SQLDragonFish', 'Connection', 'ConnectTimeOut', 15)
	DBSetProp('SQLDragonFish', 'Connection', 'DispWarnings', .F.)
	DBSetProp('SQLDragonFish', 'Connection', 'IdleTimeOut', 0)
	DBSetProp('SQLDragonFish', 'Connection', 'QueryTimeOut', 0)
	DBSetProp('SQLDragonFish', 'Connection', 'Transactions', 1)
	DBSetProp('SQLDragonFish', 'Connection', 'Database', '')
	DBSetProp('SQLDragonFish', 'Connection', 'PacketSize', 4096)
	DBSetProp('SQLDragonFish', 'Connection', 'WaitTime', 100)

	ENDFUNC

	*-----------------------------------------------------------------------------------------
	function CrearBaseDeCursores() as Void
		if !FILE(this.CarpetaTemporal+'BaseCursoresVFP.DBC')
			CREATE DATABASE (this.CarpetaTemporal+'BaseCursoresVFP.DBC')
			CREATE CONNECTION cnnCursoresVFP ; 
			   CONNSTRING this.StringConexion
			****
			DBSetProp('CNNCURSORESVFP', 'Connection', 'Asynchronous', .F.)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'BatchMode', .T.)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'Comment', '')
			DBSetProp('CNNCURSORESVFP', 'Connection', 'DispLogin', 3)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'ConnectTimeOut', 6)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'DispWarnings', .F.)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'IdleTimeOut', 0)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'QueryTimeOut', 0)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'Transactions', 1)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'Database', '')
			DBSetProp('CNNCURSORESVFP', 'Connection', 'PacketSize', 4096)
			DBSetProp('CNNCURSORESVFP', 'Connection', 'WaitTime', 100)
		endif
	endfunc 

	function CrearVista_ComprobantesDeVentaPorTipoYCliente
	***************** View setup for COMPROBANTESDEVENTAPORTIPOYCLIENTE ***************

		CREATE SQL VIEW "COMPROBANTESDEVENTAPORTIPOYCLIENTE" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Comprobantev.CODIGO, Comprobantev.FACTTIPO, Comprobantev.FLETRA, Comprobantev.FPTOVEN, Comprobantev.FNUMCOMP, Comprobantev.FFCH, Comprobantev.FSUBTON, Comprobantev.FSUBTOT, Comprobantev.FTOTAL, Comprobantevdet.FART, Comprobantevdet.FCANT, Comprobantevdet.FPRECIO, Comprobantevdet.FMTOIVA, Comprobantevdet.FMONTO, Comprobantevdet.FBRUTO, Comprobantevdet.FNETO, Comprobantevdet.NROITEM, Comprobantevdet.CIDITEM, Comprobantevdet.IDITEM, Comprobantevdet.IDITEMORIG, Comprobantevdet.ACONDIVAV, Comprobantevdet.AFECANT, Comprobantevdet.AFESALDO, Comprobantevdet.MNTPTOT FROM  ZooLogic.COMPROBANTEVDET Comprobantevdet  INNER JOIN ZooLogic.COMPROBANTEV Comprobantev  ON  Comprobantevdet.CODIGO = Comprobantev.CODIGO WHERE  Comprobantev.FACTTIPO = ?fnTipoComprobante AND  Comprobantev.FPERSON = ?fcCodigoCliente

		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'UpdateType', 1)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'WhereType', 3)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'FetchMemo', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'SendUpdates', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'UseMemoSize', 255)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'FetchSize', 100)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'MaxRecords', -1)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'Tables', 'ZooLogic.COMPROBANTEV,ZooLogic.COMPROBANTEVDET')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'Prepared', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'CompareMemo', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'Comment', "")
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'BatchUpdateCount', 1)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'ShareConnection', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for COMPROBANTESDEVENTAPORTIPOYCLIENTE
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.codigo field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.codigo', 'Field', 'KeyField', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.codigo', 'Field', 'Updatable', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.codigo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.CODIGO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.codigo', 'Field', 'DataType', "C(38)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.facttipo field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.facttipo', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.facttipo', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.facttipo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FACTTIPO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.facttipo', 'Field', 'DataType', "N(4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fletra field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fletra', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fletra', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fletra', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FLETRA')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fletra', 'Field', 'DataType', "C(1)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fptoven field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fptoven', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fptoven', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fptoven', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FPTOVEN')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fptoven', 'Field', 'DataType', "N(6)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fnumcomp field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fnumcomp', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fnumcomp', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fnumcomp', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FNUMCOMP')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fnumcomp', 'Field', 'DataType', "N(10)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.ffch field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ffch', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ffch', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ffch', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FFCH')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ffch', 'Field', 'DataType', "T")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubton field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubton', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubton', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubton', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FSUBTON')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubton', 'Field', 'DataType', "N(17,4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubtot field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubtot', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubtot', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubtot', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FSUBTOT')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fsubtot', 'Field', 'DataType', "N(17,4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.ftotal field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ftotal', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ftotal', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ftotal', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FTOTAL')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ftotal', 'Field', 'DataType', "N(17,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fart field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fart', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fart', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fart', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FART')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fart', 'Field', 'DataType', "C(15)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fcant field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fcant', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fcant', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fcant', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FCANT')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fcant', 'Field', 'DataType', "N(10,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fprecio field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fprecio', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fprecio', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fprecio', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FPRECIO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fprecio', 'Field', 'DataType', "N(14,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmtoiva field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmtoiva', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmtoiva', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmtoiva', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FMTOIVA')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmtoiva', 'Field', 'DataType', "N(17,4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmonto field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmonto', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmonto', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmonto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FMONTO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fmonto', 'Field', 'DataType', "N(17,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fbruto field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fbruto', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fbruto', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fbruto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FBRUTO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fbruto', 'Field', 'DataType', "N(17,4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.fneto field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fneto', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fneto', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fneto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FNETO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.fneto', 'Field', 'DataType', "N(17,4)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.nroitem field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.nroitem', 'Field', 'KeyField', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.nroitem', 'Field', 'Updatable', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.nroitem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.NROITEM')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.nroitem', 'Field', 'DataType', "N(7)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.ciditem field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ciditem', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ciditem', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ciditem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.CIDITEM')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.ciditem', 'Field', 'DataType', "N(11)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditem field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditem', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditem', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.IDITEM')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditem', 'Field', 'DataType', "C(38)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditemorig field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditemorig', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditemorig', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditemorig', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.IDITEMORIG')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.iditemorig', 'Field', 'DataType', "N(11)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.acondivav field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.acondivav', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.acondivav', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.acondivav', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.ACONDIVAV')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.acondivav', 'Field', 'DataType', "N(3)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.afecant field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afecant', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afecant', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afecant', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.AFECANT')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afecant', 'Field', 'DataType', "N(17,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.afesaldo field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afesaldo', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afesaldo', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afesaldo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.AFESALDO')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.afesaldo', 'Field', 'DataType', "N(17,2)")
		* Props for the COMPROBANTESDEVENTAPORTIPOYCLIENTE.mntptot field.
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.mntptot', 'Field', 'KeyField', .F.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.mntptot', 'Field', 'Updatable', .T.)
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.mntptot', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.MNTPTOT')
		DBSetProp('COMPROBANTESDEVENTAPORTIPOYCLIENTE.mntptot', 'Field', 'DataType', "N(19,4)")
	endfunc
	 
	function CrearVista_RemitosPendientes
	***************** View setup for REMITOSPENDIENTES ***************

		CREATE SQL VIEW "REMITOSPENDIENTES" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Comprobantev.CODIGO, Comprobantev.FACTTIPO, Comprobantev.FLETRA, Comprobantev.FPTOVEN, Comprobantev.FNUMCOMP, Comprobantev.FFCH, Comprobantev.FSUBTON, Comprobantev.FSUBTOT, Comprobantev.FTOTAL, Comprobantevdet.FART, Comprobantevdet.FCANT, Comprobantevdet.FPRECIO, Comprobantevdet.FMTOIVA, Comprobantevdet.FMONTO, Comprobantevdet.FBRUTO, Comprobantevdet.FNETO, Comprobantevdet.NROITEM, Comprobantevdet.CIDITEM, Comprobantevdet.IDITEM, Comprobantevdet.IDITEMORIG, Comprobantevdet.ACONDIVAV, Comprobantevdet.AFECANT, Comprobantevdet.AFESALDO, Comprobantevdet.MNTPTOT, Comprobantevdet.MNTPTOT *  Comprobantevdet.AFESALDO /  Comprobantevdet.FCANT FROM  ZooLogic.COMPROBANTEVDET Comprobantevdet  INNER JOIN ZooLogic.COMPROBANTEV Comprobantev  ON  Comprobantevdet.CODIGO = Comprobantev.CODIGO WHERE  Comprobantev.FACTTIPO = ( 11 ) AND  (  Comprobantev.FPERSON = ( ?fcCodigoCliente ) AND  Comprobantevdet.AFESALDO > ( 0 ) )

		DBSetProp('REMITOSPENDIENTES', 'View', 'UpdateType', 1)
		DBSetProp('REMITOSPENDIENTES', 'View', 'WhereType', 3)
		DBSetProp('REMITOSPENDIENTES', 'View', 'FetchMemo', .T.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'SendUpdates', .F.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'UseMemoSize', 255)
		DBSetProp('REMITOSPENDIENTES', 'View', 'FetchSize', 100)
		DBSetProp('REMITOSPENDIENTES', 'View', 'MaxRecords', -1)
		DBSetProp('REMITOSPENDIENTES', 'View', 'Tables', 'ZooLogic.COMPROBANTEV,ZooLogic.COMPROBANTEVDET')
		DBSetProp('REMITOSPENDIENTES', 'View', 'Prepared', .F.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'CompareMemo', .T.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'Comment', "")
		DBSetProp('REMITOSPENDIENTES', 'View', 'BatchUpdateCount', 1)
		DBSetProp('REMITOSPENDIENTES', 'View', 'ShareConnection', .F.)
		DBSetProp('REMITOSPENDIENTES', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for REMITOSPENDIENTES
		* Props for the REMITOSPENDIENTES.codigo field.
		DBSetProp('REMITOSPENDIENTES.codigo', 'Field', 'KeyField', .T.)
		DBSetProp('REMITOSPENDIENTES.codigo', 'Field', 'Updatable', .F.)
		DBSetProp('REMITOSPENDIENTES.codigo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.CODIGO')
		DBSetProp('REMITOSPENDIENTES.codigo', 'Field', 'DataType', "C(38)")
		* Props for the REMITOSPENDIENTES.facttipo field.
		DBSetProp('REMITOSPENDIENTES.facttipo', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.facttipo', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.facttipo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FACTTIPO')
		DBSetProp('REMITOSPENDIENTES.facttipo', 'Field', 'DataType', "N(4)")
		* Props for the REMITOSPENDIENTES.fletra field.
		DBSetProp('REMITOSPENDIENTES.fletra', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fletra', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fletra', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FLETRA')
		DBSetProp('REMITOSPENDIENTES.fletra', 'Field', 'DataType', "C(1)")
		* Props for the REMITOSPENDIENTES.fptoven field.
		DBSetProp('REMITOSPENDIENTES.fptoven', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fptoven', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fptoven', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FPTOVEN')
		DBSetProp('REMITOSPENDIENTES.fptoven', 'Field', 'DataType', "N(6)")
		* Props for the REMITOSPENDIENTES.fnumcomp field.
		DBSetProp('REMITOSPENDIENTES.fnumcomp', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fnumcomp', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fnumcomp', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FNUMCOMP')
		DBSetProp('REMITOSPENDIENTES.fnumcomp', 'Field', 'DataType', "N(10)")
		* Props for the REMITOSPENDIENTES.ffch field.
		DBSetProp('REMITOSPENDIENTES.ffch', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.ffch', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.ffch', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FFCH')
		DBSetProp('REMITOSPENDIENTES.ffch', 'Field', 'DataType', "T")
		* Props for the REMITOSPENDIENTES.fsubton field.
		DBSetProp('REMITOSPENDIENTES.fsubton', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fsubton', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fsubton', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FSUBTON')
		DBSetProp('REMITOSPENDIENTES.fsubton', 'Field', 'DataType', "N(17,4)")
		* Props for the REMITOSPENDIENTES.fsubtot field.
		DBSetProp('REMITOSPENDIENTES.fsubtot', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fsubtot', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fsubtot', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FSUBTOT')
		DBSetProp('REMITOSPENDIENTES.fsubtot', 'Field', 'DataType', "N(17,4)")
		* Props for the REMITOSPENDIENTES.ftotal field.
		DBSetProp('REMITOSPENDIENTES.ftotal', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.ftotal', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.ftotal', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEV.FTOTAL')
		DBSetProp('REMITOSPENDIENTES.ftotal', 'Field', 'DataType', "N(17,2)")
		* Props for the REMITOSPENDIENTES.fart field.
		DBSetProp('REMITOSPENDIENTES.fart', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fart', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fart', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FART')
		DBSetProp('REMITOSPENDIENTES.fart', 'Field', 'DataType', "C(15)")
		* Props for the REMITOSPENDIENTES.fcant field.
		DBSetProp('REMITOSPENDIENTES.fcant', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fcant', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fcant', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FCANT')
		DBSetProp('REMITOSPENDIENTES.fcant', 'Field', 'DataType', "N(10,2)")
		* Props for the REMITOSPENDIENTES.fprecio field.
		DBSetProp('REMITOSPENDIENTES.fprecio', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fprecio', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fprecio', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FPRECIO')
		DBSetProp('REMITOSPENDIENTES.fprecio', 'Field', 'DataType', "N(14,2)")
		* Props for the REMITOSPENDIENTES.fmtoiva field.
		DBSetProp('REMITOSPENDIENTES.fmtoiva', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fmtoiva', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fmtoiva', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FMTOIVA')
		DBSetProp('REMITOSPENDIENTES.fmtoiva', 'Field', 'DataType', "N(17,4)")
		* Props for the REMITOSPENDIENTES.fmonto field.
		DBSetProp('REMITOSPENDIENTES.fmonto', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fmonto', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fmonto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FMONTO')
		DBSetProp('REMITOSPENDIENTES.fmonto', 'Field', 'DataType', "N(17,2)")
		* Props for the REMITOSPENDIENTES.fbruto field.
		DBSetProp('REMITOSPENDIENTES.fbruto', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fbruto', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fbruto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FBRUTO')
		DBSetProp('REMITOSPENDIENTES.fbruto', 'Field', 'DataType', "N(17,4)")
		* Props for the REMITOSPENDIENTES.fneto field.
		DBSetProp('REMITOSPENDIENTES.fneto', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.fneto', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.fneto', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.FNETO')
		DBSetProp('REMITOSPENDIENTES.fneto', 'Field', 'DataType', "N(17,4)")
		* Props for the REMITOSPENDIENTES.nroitem field.
		DBSetProp('REMITOSPENDIENTES.nroitem', 'Field', 'KeyField', .T.)
		DBSetProp('REMITOSPENDIENTES.nroitem', 'Field', 'Updatable', .F.)
		DBSetProp('REMITOSPENDIENTES.nroitem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.NROITEM')
		DBSetProp('REMITOSPENDIENTES.nroitem', 'Field', 'DataType', "N(7)")
		* Props for the REMITOSPENDIENTES.ciditem field.
		DBSetProp('REMITOSPENDIENTES.ciditem', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.ciditem', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.ciditem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.CIDITEM')
		DBSetProp('REMITOSPENDIENTES.ciditem', 'Field', 'DataType', "N(11)")
		* Props for the REMITOSPENDIENTES.iditem field.
		DBSetProp('REMITOSPENDIENTES.iditem', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.iditem', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.iditem', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.IDITEM')
		DBSetProp('REMITOSPENDIENTES.iditem', 'Field', 'DataType', "C(38)")
		* Props for the REMITOSPENDIENTES.iditemorig field.
		DBSetProp('REMITOSPENDIENTES.iditemorig', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.iditemorig', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.iditemorig', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.IDITEMORIG')
		DBSetProp('REMITOSPENDIENTES.iditemorig', 'Field', 'DataType', "N(11)")
		* Props for the REMITOSPENDIENTES.acondivav field.
		DBSetProp('REMITOSPENDIENTES.acondivav', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.acondivav', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.acondivav', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.ACONDIVAV')
		DBSetProp('REMITOSPENDIENTES.acondivav', 'Field', 'DataType', "N(3)")
		* Props for the REMITOSPENDIENTES.afecant field.
		DBSetProp('REMITOSPENDIENTES.afecant', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.afecant', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.afecant', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.AFECANT')
		DBSetProp('REMITOSPENDIENTES.afecant', 'Field', 'DataType', "N(17,2)")
		* Props for the REMITOSPENDIENTES.afesaldo field.
		DBSetProp('REMITOSPENDIENTES.afesaldo', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.afesaldo', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.afesaldo', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.AFESALDO')
		DBSetProp('REMITOSPENDIENTES.afesaldo', 'Field', 'DataType', "N(17,2)")
		* Props for the REMITOSPENDIENTES.mntptot field.
		DBSetProp('REMITOSPENDIENTES.mntptot', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.mntptot', 'Field', 'Updatable', .T.)
		DBSetProp('REMITOSPENDIENTES.mntptot', 'Field', 'UpdateName', 'ZooLogic.COMPROBANTEVDET.MNTPTOT')
		DBSetProp('REMITOSPENDIENTES.mntptot', 'Field', 'DataType', "N(19,4)")
		* Props for the REMITOSPENDIENTES.exp field.
		DBSetProp('REMITOSPENDIENTES.exp', 'Field', 'KeyField', .F.)
		DBSetProp('REMITOSPENDIENTES.exp', 'Field', 'Updatable', .F.)
		DBSetProp('REMITOSPENDIENTES.exp', 'Field', 'UpdateName', 'Exp')
		DBSetProp('REMITOSPENDIENTES.exp', 'Field', 'DataType', "N(20,9)")
	endfunc

	function CrearVista_ObtenerCostoDeInsumo
		***************** View setup for OBTENERCOSTODEINSUMO ***************

		CREATE SQL VIEW "CostoDeInsumo" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Costoins.INSUMO, Costoins.CCOLOR, Costoins.TALLE, Costoins.TALLER, Costoins.PROCESO, Costoins.CANTIDAD, Costoins.PDIRECTO FROM ZooLogic.COSTOINS Costoins ;
		   		WHERE  Costoins.INSUMO = fInsumo AND  ;
		   		(Costoins.CCOLOR = '' OR  Costoins.CCOLOR = fColor) AND ;
		   		(Costoins.TALLE = '' OR  Costoins.TALLE = fTalle) AND ;
		   		(Costoins.TALLER = '' OR  Costoins.TALLER = fTaller) AND ;
		   		(Costoins.PROCESO = '' OR  Costoins.PROCESO = fProceso) AND ;
		   		Costoins.CANTIDAD = fCantidad

		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'UpdateType', 1)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'WhereType', 3)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'FetchMemo', .T.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'SendUpdates', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'UseMemoSize', 255)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'FetchSize', 100)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'MaxRecords', -1)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'Tables', 'ZooLogic.COSTOINS')
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'Prepared', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'CompareMemo', .T.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'Comment', "")
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'BatchUpdateCount', 1)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'ShareConnection', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for OBTENERCOSTODEINSUMO
		* Props for the OBTENERCOSTODEINSUMO.insumo field.
		DBSetProp('OBTENERCOSTODEINSUMO.insumo', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.insumo', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.insumo', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.INSUMO')
		DBSetProp('OBTENERCOSTODEINSUMO.insumo', 'Field', 'DataType', "C(25)")
		* Props for the OBTENERCOSTODEINSUMO.ccolor field.
		DBSetProp('OBTENERCOSTODEINSUMO.ccolor', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.ccolor', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.ccolor', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CCOLOR')
		DBSetProp('OBTENERCOSTODEINSUMO.ccolor', 'Field', 'DataType', "C(6)")
		* Props for the OBTENERCOSTODEINSUMO.talle field.
		DBSetProp('OBTENERCOSTODEINSUMO.talle', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.talle', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.talle', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.TALLE')
		DBSetProp('OBTENERCOSTODEINSUMO.talle', 'Field', 'DataType', "C(5)")
		* Props for the OBTENERCOSTODEINSUMO.taller field.
		DBSetProp('OBTENERCOSTODEINSUMO.taller', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.taller', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.taller', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.TALLER')
		DBSetProp('OBTENERCOSTODEINSUMO.taller', 'Field', 'DataType', "C(15)")
		* Props for the OBTENERCOSTODEINSUMO.proceso field.
		DBSetProp('OBTENERCOSTODEINSUMO.proceso', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.proceso', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.proceso', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.PROCESO')
		DBSetProp('OBTENERCOSTODEINSUMO.proceso', 'Field', 'DataType', "C(15)")
		* Props for the OBTENERCOSTODEINSUMO.cantidad field.
		DBSetProp('OBTENERCOSTODEINSUMO.cantidad', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.cantidad', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.cantidad', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CANTIDAD')
		DBSetProp('OBTENERCOSTODEINSUMO.cantidad', 'Field', 'DataType', "N(16,6)")
		* Props for the OBTENERCOSTODEINSUMO.pdirecto field.
		DBSetProp('OBTENERCOSTODEINSUMO.pdirecto', 'Field', 'KeyField', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.pdirecto', 'Field', 'Updatable', .F.)
		DBSetProp('OBTENERCOSTODEINSUMO.pdirecto', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.PDIRECTO')
		DBSetProp('OBTENERCOSTODEINSUMO.pdirecto', 'Field', 'DataType', "N(17,2)")
	endfunc

	function CrearCursorRemoto_CostoDeInsumo
	***************** View setup for VCOSTOINS ***************

		CREATE SQL VIEW "crCostoDeInsumo" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Costoins.CODIGO, Costoins.LISTACOST, Costoins.INSUMO, Costoins.CCOLOR, Costoins.TALLE, Costoins.TALLER, Costoins.PROCESO, Costoins.CANTIDAD, Costoins.CDIRORI, Costoins.CDIRECTO FROM  ZooLogic.COSTOINS Costoins

		DBSetProp('crCostoDeInsumo', 'View', 'UpdateType', 1)
		DBSetProp('crCostoDeInsumo', 'View', 'WhereType', 2)
		DBSetProp('crCostoDeInsumo', 'View', 'FetchMemo', .T.)
		DBSetProp('crCostoDeInsumo', 'View', 'SendUpdates', .T.)
		DBSetProp('crCostoDeInsumo', 'View', 'UseMemoSize', 255)
		DBSetProp('crCostoDeInsumo', 'View', 'FetchSize', 100)
		DBSetProp('crCostoDeInsumo', 'View', 'MaxRecords', -1)
		DBSetProp('crCostoDeInsumo', 'View', 'Tables', 'ZooLogic.COSTOINS')
		DBSetProp('crCostoDeInsumo', 'View', 'Prepared', .F.)
		DBSetProp('crCostoDeInsumo', 'View', 'CompareMemo', .T.)
		DBSetProp('crCostoDeInsumo', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('crCostoDeInsumo', 'View', 'Comment', "")
		DBSetProp('crCostoDeInsumo', 'View', 'BatchUpdateCount', 1)
		DBSetProp('crCostoDeInsumo', 'View', 'ShareConnection', .F.)
		DBSetProp('crCostoDeInsumo', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for crCostoDeInsumo
		* Props for the crCostoDeInsumo.codigo field.
		DBSetProp('crCostoDeInsumo.codigo', 'Field', 'KeyField', .T.)
		DBSetProp('crCostoDeInsumo.codigo', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.codigo', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CODIGO')
		DBSetProp('crCostoDeInsumo.codigo', 'Field', 'DataType', "C(79)")
		* Props for the crCostoDeInsumo.listacost field.
		DBSetProp('crCostoDeInsumo.listacost', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.listacost', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.listacost', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.LISTACOST')
		DBSetProp('crCostoDeInsumo.listacost', 'Field', 'DataType', "C(6)")
		* Props for the crCostoDeInsumo.insumo field.
		DBSetProp('crCostoDeInsumo.insumo', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.insumo', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.insumo', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.INSUMO')
		DBSetProp('crCostoDeInsumo.insumo', 'Field', 'DataType', "C(25)")
		* Props for the crCostoDeInsumo.ccolor field.
		DBSetProp('crCostoDeInsumo.ccolor', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.ccolor', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.ccolor', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CCOLOR')
		DBSetProp('crCostoDeInsumo.ccolor', 'Field', 'DataType', "C(6)")
		* Props for the crCostoDeInsumo.talle field.
		DBSetProp('crCostoDeInsumo.talle', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.talle', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.talle', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.TALLE')
		DBSetProp('crCostoDeInsumo.talle', 'Field', 'DataType', "C(5)")
		* Props for the crCostoDeInsumo.taller field.
		DBSetProp('crCostoDeInsumo.taller', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.taller', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.taller', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.TALLER')
		DBSetProp('crCostoDeInsumo.taller', 'Field', 'DataType', "C(15)")
		* Props for the crCostoDeInsumo.proceso field.
		DBSetProp('crCostoDeInsumo.proceso', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.proceso', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.proceso', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.PROCESO')
		DBSetProp('crCostoDeInsumo.proceso', 'Field', 'DataType', "C(15)")
		* Props for the crCostoDeInsumo.cantidad field.
		DBSetProp('crCostoDeInsumo.cantidad', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.cantidad', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.cantidad', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CANTIDAD')
		DBSetProp('crCostoDeInsumo.cantidad', 'Field', 'DataType', "N(16,6)")
		* Props for the crCostoDeInsumo.cdirori field.
		DBSetProp('crCostoDeInsumo.cdirori', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.cdirori', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.cdirori', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CDIRORI')
		DBSetProp('crCostoDeInsumo.cdirori', 'Field', 'DataType', "N(17,2)")
		* Props for the crCostoDeInsumo.cdirecto field.
		DBSetProp('crCostoDeInsumo.cdirecto', 'Field', 'KeyField', .F.)
		DBSetProp('crCostoDeInsumo.cdirecto', 'Field', 'Updatable', .T.)
		DBSetProp('crCostoDeInsumo.cdirecto', 'Field', 'UpdateName', 'ZooLogic.COSTOINS.CDIRECTO')
		DBSetProp('crCostoDeInsumo.cdirecto', 'Field', 'DataType', "N(17,2)")
	endfunc
	 
	function CrearCursorRemoto_ModificacionCostoDeProduccion
	***************** View setup for VMODCOSTOP ***************

		CREATE SQL VIEW "crModCostoProduccion" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Modcostop.CODIGO, Modcostop.DESCRIP, Modcostop.FECHA, Modcostop.NUMERO FROM ZooLogic.MODCOSTOP Modcostop

		DBSetProp('crModCostoProduccion', 'View', 'UpdateType', 1)
		DBSetProp('crModCostoProduccion', 'View', 'WhereType', 3)
		DBSetProp('crModCostoProduccion', 'View', 'FetchMemo', .T.)
		DBSetProp('crModCostoProduccion', 'View', 'SendUpdates', .F.)
		DBSetProp('crModCostoProduccion', 'View', 'UseMemoSize', 255)
		DBSetProp('crModCostoProduccion', 'View', 'FetchSize', 100)
		DBSetProp('crModCostoProduccion', 'View', 'MaxRecords', -1)
		DBSetProp('crModCostoProduccion', 'View', 'Tables', 'ZooLogic.MODCOSTOP')
		DBSetProp('crModCostoProduccion', 'View', 'Prepared', .F.)
		DBSetProp('crModCostoProduccion', 'View', 'CompareMemo', .T.)
		DBSetProp('crModCostoProduccion', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('crModCostoProduccion', 'View', 'Comment', "")
		DBSetProp('crModCostoProduccion', 'View', 'BatchUpdateCount', 1)
		DBSetProp('crModCostoProduccion', 'View', 'ShareConnection', .F.)
		DBSetProp('crModCostoProduccion', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for crModCostoProduccion
		* Props for the crModCostoProduccion.codigo field.
		DBSetProp('crModCostoProduccion.codigo', 'Field', 'KeyField', .T.)
		DBSetProp('crModCostoProduccion.codigo', 'Field', 'Updatable', .F.)
		DBSetProp('crModCostoProduccion.codigo', 'Field', 'UpdateName', 'ZooLogic.MODCOSTOP.CODIGO')
		DBSetProp('crModCostoProduccion.codigo', 'Field', 'DataType', "C(20)")
		* Props for the crModCostoProduccion.descrip field.
		DBSetProp('crModCostoProduccion.descrip', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProduccion.descrip', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProduccion.descrip', 'Field', 'UpdateName', 'ZooLogic.MODCOSTOP.DESCRIP')
		DBSetProp('crModCostoProduccion.descrip', 'Field', 'DataType', "C(100)")
		* Props for the crModCostoProduccion.fecha field.
		DBSetProp('crModCostoProduccion.fecha', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProduccion.fecha', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProduccion.fecha', 'Field', 'UpdateName', 'ZooLogic.MODCOSTOP.FECHA')
		DBSetProp('crModCostoProduccion.fecha', 'Field', 'DataType', "T")
		* Props for the crModCostoProduccion.numero field.
		DBSetProp('crModCostoProduccion.numero', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProduccion.numero', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProduccion.numero', 'Field', 'UpdateName', 'ZooLogic.MODCOSTOP.NUMERO')
		DBSetProp('crModCostoProduccion.numero', 'Field', 'DataType', "N(14)")
	endfunc
 
	function CrearCursorRemoto_ModificacionCostoDeProduccionDetalle
	***************** View setup for VMODCOSTPROD ***************

		CREATE SQL VIEW "crModCostoProdDetalle" ; 
		   REMOTE CONNECT "SQLDragonFish" ; 
		   AS SELECT Modcostprod.CODIGO, Modcostprod.CODLISCOST, Modcostprod.SEMIELAB, Modcostprod.SEMIDETA, Modcostprod.CODCOLOR, Modcostprod.COLORDETA, Modcostprod.CODTALLE, Modcostprod.TALLEDETA, Modcostprod.TALLER, Modcostprod.TALLERDETA, Modcostprod.PROCESO, Modcostprod.PROCDETA, Modcostprod.CANTIDAD, Modcostprod.COSTOVIG, Modcostprod.COSTONUE, Modcostprod.NROITEM FROM  ZooLogic.MODCOSTPROD Modcostprod

		DBSetProp('crModCostoProdDetalle', 'View', 'UpdateType', 1)
		DBSetProp('crModCostoProdDetalle', 'View', 'WhereType', 2)
		DBSetProp('crModCostoProdDetalle', 'View', 'FetchMemo', .T.)
		DBSetProp('crModCostoProdDetalle', 'View', 'SendUpdates', .T.)
		DBSetProp('crModCostoProdDetalle', 'View', 'UseMemoSize', 255)
		DBSetProp('crModCostoProdDetalle', 'View', 'FetchSize', 100)
		DBSetProp('crModCostoProdDetalle', 'View', 'MaxRecords', -1)
		DBSetProp('crModCostoProdDetalle', 'View', 'Tables', 'ZooLogic.MODCOSTPROD')
		DBSetProp('crModCostoProdDetalle', 'View', 'Prepared', .F.)
		DBSetProp('crModCostoProdDetalle', 'View', 'CompareMemo', .T.)
		DBSetProp('crModCostoProdDetalle', 'View', 'FetchAsNeeded', .F.)
		DBSetProp('crModCostoProdDetalle', 'View', 'Comment', "")
		DBSetProp('crModCostoProdDetalle', 'View', 'BatchUpdateCount', 1)
		DBSetProp('crModCostoProdDetalle', 'View', 'ShareConnection', .F.)
		DBSetProp('crModCostoProdDetalle', 'View', 'AllowSimultaneousFetch', .F.)

		*!* Field Level Properties for crModCostoProdDetalle
		* Props for the crModCostoProdDetalle.codigo field.
		DBSetProp('crModCostoProdDetalle.codigo', 'Field', 'KeyField', .T.)
		DBSetProp('crModCostoProdDetalle.codigo', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.codigo', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.CODIGO')
		DBSetProp('crModCostoProdDetalle.codigo', 'Field', 'DataType', "C(20)")
		* Props for the crModCostoProdDetalle.codliscost field.
		DBSetProp('crModCostoProdDetalle.codliscost', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.codliscost', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.codliscost', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.CODLISCOST')
		DBSetProp('crModCostoProdDetalle.codliscost', 'Field', 'DataType', "C(6)")
		* Props for the crModCostoProdDetalle.semielab field.
		DBSetProp('crModCostoProdDetalle.semielab', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.semielab', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.semielab', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.SEMIELAB')
		DBSetProp('crModCostoProdDetalle.semielab', 'Field', 'DataType', "C(25)")
		* Props for the crModCostoProdDetalle.semideta field.
		DBSetProp('crModCostoProdDetalle.semideta', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.semideta', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.semideta', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.SEMIDETA')
		DBSetProp('crModCostoProdDetalle.semideta', 'Field', 'DataType', "C(100)")
		* Props for the crModCostoProdDetalle.codcolor field.
		DBSetProp('crModCostoProdDetalle.codcolor', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.codcolor', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.codcolor', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.CODCOLOR')
		DBSetProp('crModCostoProdDetalle.codcolor', 'Field', 'DataType', "C(6)")
		* Props for the crModCostoProdDetalle.colordeta field.
		DBSetProp('crModCostoProdDetalle.colordeta', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.colordeta', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.colordeta', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.COLORDETA')
		DBSetProp('crModCostoProdDetalle.colordeta', 'Field', 'DataType', "C(50)")
		* Props for the crModCostoProdDetalle.codtalle field.
		DBSetProp('crModCostoProdDetalle.codtalle', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.codtalle', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.codtalle', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.CODTALLE')
		DBSetProp('crModCostoProdDetalle.codtalle', 'Field', 'DataType', "C(5)")
		* Props for the crModCostoProdDetalle.talledeta field.
		DBSetProp('crModCostoProdDetalle.talledeta', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.talledeta', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.talledeta', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.TALLEDETA')
		DBSetProp('crModCostoProdDetalle.talledeta', 'Field', 'DataType', "C(50)")
		* Props for the crModCostoProdDetalle.taller field.
		DBSetProp('crModCostoProdDetalle.taller', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.taller', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.taller', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.TALLER')
		DBSetProp('crModCostoProdDetalle.taller', 'Field', 'DataType', "C(15)")
		* Props for the crModCostoProdDetalle.tallerdeta field.
		DBSetProp('crModCostoProdDetalle.tallerdeta', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.tallerdeta', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.tallerdeta', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.TALLERDETA')
		DBSetProp('crModCostoProdDetalle.tallerdeta', 'Field', 'DataType', "C(100)")
		* Props for the crModCostoProdDetalle.proceso field.
		DBSetProp('crModCostoProdDetalle.proceso', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.proceso', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.proceso', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.PROCESO')
		DBSetProp('crModCostoProdDetalle.proceso', 'Field', 'DataType', "C(15)")
		* Props for the crModCostoProdDetalle.procdeta field.
		DBSetProp('crModCostoProdDetalle.procdeta', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.procdeta', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.procdeta', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.PROCDETA')
		DBSetProp('crModCostoProdDetalle.procdeta', 'Field', 'DataType', "C(250)")
		* Props for the crModCostoProdDetalle.cantidad field.
		DBSetProp('crModCostoProdDetalle.cantidad', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.cantidad', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.cantidad', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.CANTIDAD')
		DBSetProp('crModCostoProdDetalle.cantidad', 'Field', 'DataType', "N(16,6)")
		* Props for the crModCostoProdDetalle.costovig field.
		DBSetProp('crModCostoProdDetalle.costovig', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.costovig', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.costovig', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.COSTOVIG')
		DBSetProp('crModCostoProdDetalle.costovig', 'Field', 'DataType', "N(14,2)")
		* Props for the crModCostoProdDetalle.costonue field.
		DBSetProp('crModCostoProdDetalle.costonue', 'Field', 'KeyField', .F.)
		DBSetProp('crModCostoProdDetalle.costonue', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.costonue', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.COSTONUE')
		DBSetProp('crModCostoProdDetalle.costonue', 'Field', 'DataType', "N(14,2)")
		* Props for the crModCostoProdDetalle.nroitem field.
		DBSetProp('crModCostoProdDetalle.nroitem', 'Field', 'KeyField', .T.)
		DBSetProp('crModCostoProdDetalle.nroitem', 'Field', 'Updatable', .T.)
		DBSetProp('crModCostoProdDetalle.nroitem', 'Field', 'UpdateName', 'ZooLogic.MODCOSTPROD.NROITEM')
		DBSetProp('crModCostoProdDetalle.nroitem', 'Field', 'DataType', "N(7)")
	endfunc

	FUNCTION CrearVista_RGestionProduccion
	***************** View setup for RGESTIONPRODUCCION ***************

	CREATE SQL VIEW "RGESTIONPRODUCCION" ; 
	   REMOTE CONNECT "SQLDragonFish" ; 
	   AS SELECT Gestionprod.CODIGO, Gestionprod.ORDENDEPRO, Gestionprod.PROCESO, Gestionprod.TALLER, Taller.PROVEEDOR, Taller.LISTACOSTO, Taller.INSUMOS, Taller.DESCARTES FROM  {oj  ZooLogic.GESTIONPROD Gestionprod  LEFT OUTER JOIN ZooLogic.TALLER Taller  ON  Gestionprod.TALLER = Taller.CODIGO} WHERE  Gestionprod.CODIGO = ?codGestionProd

	DBSetProp('RGESTIONPRODUCCION', 'View', 'UpdateType', 1)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'WhereType', 3)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'FetchMemo', .T.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'SendUpdates', .F.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'UseMemoSize', 255)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'FetchSize', 100)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'MaxRecords', -1)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'Tables', 'ZooLogic.GESTIONPROD')
	DBSetProp('RGESTIONPRODUCCION', 'View', 'Prepared', .F.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'CompareMemo', .T.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'Comment', "")
	DBSetProp('RGESTIONPRODUCCION', 'View', 'BatchUpdateCount', 1)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'ShareConnection', .F.)
	DBSetProp('RGESTIONPRODUCCION', 'View', 'AllowSimultaneousFetch', .F.)

	*!* Field Level Properties for RGESTIONPRODUCCION
	* Props for the RGESTIONPRODUCCION.codigo field.
	DBSetProp('RGESTIONPRODUCCION.codigo', 'Field', 'KeyField', .T.)
	DBSetProp('RGESTIONPRODUCCION.codigo', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONPRODUCCION.codigo', 'Field', 'UpdateName', 'ZooLogic.GESTIONPROD.CODIGO')
	DBSetProp('RGESTIONPRODUCCION.codigo', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONPRODUCCION.ordendepro field.
	DBSetProp('RGESTIONPRODUCCION.ordendepro', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.ordendepro', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONPRODUCCION.ordendepro', 'Field', 'UpdateName', 'ZooLogic.GESTIONPROD.ORDENDEPRO')
	DBSetProp('RGESTIONPRODUCCION.ordendepro', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONPRODUCCION.proceso field.
	DBSetProp('RGESTIONPRODUCCION.proceso', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.proceso', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONPRODUCCION.proceso', 'Field', 'UpdateName', 'ZooLogic.GESTIONPROD.PROCESO')
	DBSetProp('RGESTIONPRODUCCION.proceso', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONPRODUCCION.taller field.
	DBSetProp('RGESTIONPRODUCCION.taller', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.taller', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONPRODUCCION.taller', 'Field', 'UpdateName', 'ZooLogic.GESTIONPROD.TALLER')
	DBSetProp('RGESTIONPRODUCCION.taller', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONPRODUCCION.proveedor field.
	DBSetProp('RGESTIONPRODUCCION.proveedor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.proveedor', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONPRODUCCION.proveedor', 'Field', 'UpdateName', 'ZooLogic.TALLER.PROVEEDOR')
	DBSetProp('RGESTIONPRODUCCION.proveedor', 'Field', 'DataType', "C(10)")
	* Props for the RGESTIONPRODUCCION.listacosto field.
	DBSetProp('RGESTIONPRODUCCION.listacosto', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.listacosto', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONPRODUCCION.listacosto', 'Field', 'UpdateName', 'ZooLogic.TALLER.LISTACOSTO')
	DBSetProp('RGESTIONPRODUCCION.listacosto', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONPRODUCCION.insumos field.
	DBSetProp('RGESTIONPRODUCCION.insumos', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.insumos', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONPRODUCCION.insumos', 'Field', 'UpdateName', 'ZooLogic.TALLER.INSUMOS')
	DBSetProp('RGESTIONPRODUCCION.insumos', 'Field', 'DataType', "N(4)")
	* Props for the RGESTIONPRODUCCION.descartes field.
	DBSetProp('RGESTIONPRODUCCION.descartes', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONPRODUCCION.descartes', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONPRODUCCION.descartes', 'Field', 'UpdateName', 'ZooLogic.TALLER.DESCARTES')
	DBSetProp('RGESTIONPRODUCCION.descartes', 'Field', 'DataType', "N(4)")
	ENDFUNC
	 
	FUNCTION CrearVista_RGestionCurva
	***************** View setup for RGESTIONCURVA ***************

	CREATE SQL VIEW "RGESTIONCURVA" ; 
	   REMOTE CONNECT "SQLDragonFish" ; 
	   AS SELECT Gespcurv.GESPRODCUR, Gespcurv.MARTDF, Gespcurv.CCOLOR, Gespcurv.CTALLE, Gespcurv.INSUMO, Gespcurv.CANTPROD, Gespcurv.CANTDESC, Gespcurv.CODCOLOR, Gespcurv.CODTALLE FROM ZooLogic.GESPCURV Gespcurv WHERE  Gespcurv.GESPRODCUR = ?codGestionProd

	DBSetProp('RGESTIONCURVA', 'View', 'UpdateType', 1)
	DBSetProp('RGESTIONCURVA', 'View', 'WhereType', 3)
	DBSetProp('RGESTIONCURVA', 'View', 'FetchMemo', .T.)
	DBSetProp('RGESTIONCURVA', 'View', 'SendUpdates', .F.)
	DBSetProp('RGESTIONCURVA', 'View', 'UseMemoSize', 255)
	DBSetProp('RGESTIONCURVA', 'View', 'FetchSize', 100)
	DBSetProp('RGESTIONCURVA', 'View', 'MaxRecords', -1)
	DBSetProp('RGESTIONCURVA', 'View', 'Tables', 'ZooLogic.GESPCURV')
	DBSetProp('RGESTIONCURVA', 'View', 'Prepared', .F.)
	DBSetProp('RGESTIONCURVA', 'View', 'CompareMemo', .T.)
	DBSetProp('RGESTIONCURVA', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('RGESTIONCURVA', 'View', 'Comment', "")
	DBSetProp('RGESTIONCURVA', 'View', 'BatchUpdateCount', 1)
	DBSetProp('RGESTIONCURVA', 'View', 'ShareConnection', .F.)
	DBSetProp('RGESTIONCURVA', 'View', 'AllowSimultaneousFetch', .F.)

	*!* Field Level Properties for RGESTIONCURVA
	* Props for the RGESTIONCURVA.gesprodcur field.
	DBSetProp('RGESTIONCURVA.gesprodcur', 'Field', 'KeyField', .T.)
	DBSetProp('RGESTIONCURVA.gesprodcur', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONCURVA.gesprodcur', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.GESPRODCUR')
	DBSetProp('RGESTIONCURVA.gesprodcur', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONCURVA.martdf field.
	DBSetProp('RGESTIONCURVA.martdf', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.martdf', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.martdf', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.MARTDF')
	DBSetProp('RGESTIONCURVA.martdf', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONCURVA.ccolor field.
	DBSetProp('RGESTIONCURVA.ccolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.ccolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.ccolor', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CCOLOR')
	DBSetProp('RGESTIONCURVA.ccolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONCURVA.ctalle field.
	DBSetProp('RGESTIONCURVA.ctalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.ctalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.ctalle', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CTALLE')
	DBSetProp('RGESTIONCURVA.ctalle', 'Field', 'DataType', "C(5)")
	* Props for the RGESTIONCURVA.insumo field.
	DBSetProp('RGESTIONCURVA.insumo', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.insumo', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.insumo', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.INSUMO')
	DBSetProp('RGESTIONCURVA.insumo', 'Field', 'DataType', "C(25)")
	* Props for the RGESTIONCURVA.cantprod field.
	DBSetProp('RGESTIONCURVA.cantprod', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.cantprod', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.cantprod', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CANTPROD')
	DBSetProp('RGESTIONCURVA.cantprod', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONCURVA.cantdesc field.
	DBSetProp('RGESTIONCURVA.cantdesc', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.cantdesc', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.cantdesc', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CANTDESC')
	DBSetProp('RGESTIONCURVA.cantdesc', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONCURVA.codcolor field.
	DBSetProp('RGESTIONCURVA.codcolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.codcolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.codcolor', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CODCOLOR')
	DBSetProp('RGESTIONCURVA.codcolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONCURVA.codtalle field.
	DBSetProp('RGESTIONCURVA.codtalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONCURVA.codtalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONCURVA.codtalle', 'Field', 'UpdateName', 'ZooLogic.GESPCURV.CODTALLE')
	DBSetProp('RGESTIONCURVA.codtalle', 'Field', 'DataType', "C(5)")
	ENDFUNC
	 
	FUNCTION CrearVista_RGestionDescarte
	***************** View setup for RGESTIONDESCARTE ***************

	CREATE SQL VIEW "RGESTIONDESCARTE" ; 
	   REMOTE CONNECT "SQLDragonFish" ; 
	   AS SELECT Gespdesc.GESPRODDES, Gespdesc.MARTDF, Gespdesc.CCOLOR, Gespdesc.CTALLE, Gespdesc.INSUMO, Gespdesc.CANTDESC, Gespdesc.CODCOLOR, Gespdesc.CODTALLE FROM ZooLogic.GESPDESC Gespdesc WHERE  Gespdesc.GESPRODDES = ?codGestionProd

	DBSetProp('RGESTIONDESCARTE', 'View', 'UpdateType', 1)
	DBSetProp('RGESTIONDESCARTE', 'View', 'WhereType', 3)
	DBSetProp('RGESTIONDESCARTE', 'View', 'FetchMemo', .T.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'SendUpdates', .F.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'UseMemoSize', 255)
	DBSetProp('RGESTIONDESCARTE', 'View', 'FetchSize', 100)
	DBSetProp('RGESTIONDESCARTE', 'View', 'MaxRecords', -1)
	DBSetProp('RGESTIONDESCARTE', 'View', 'Tables', 'ZooLogic.GESPDESC')
	DBSetProp('RGESTIONDESCARTE', 'View', 'Prepared', .F.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'CompareMemo', .T.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'Comment', "")
	DBSetProp('RGESTIONDESCARTE', 'View', 'BatchUpdateCount', 1)
	DBSetProp('RGESTIONDESCARTE', 'View', 'ShareConnection', .F.)
	DBSetProp('RGESTIONDESCARTE', 'View', 'AllowSimultaneousFetch', .F.)

	*!* Field Level Properties for RGESTIONDESCARTE
	* Props for the RGESTIONDESCARTE.gesproddes field.
	DBSetProp('RGESTIONDESCARTE.gesproddes', 'Field', 'KeyField', .T.)
	DBSetProp('RGESTIONDESCARTE.gesproddes', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONDESCARTE.gesproddes', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.GESPRODDES')
	DBSetProp('RGESTIONDESCARTE.gesproddes', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONDESCARTE.martdf field.
	DBSetProp('RGESTIONDESCARTE.martdf', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.martdf', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.martdf', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.MARTDF')
	DBSetProp('RGESTIONDESCARTE.martdf', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONDESCARTE.ccolor field.
	DBSetProp('RGESTIONDESCARTE.ccolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.ccolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.ccolor', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.CCOLOR')
	DBSetProp('RGESTIONDESCARTE.ccolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONDESCARTE.ctalle field.
	DBSetProp('RGESTIONDESCARTE.ctalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.ctalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.ctalle', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.CTALLE')
	DBSetProp('RGESTIONDESCARTE.ctalle', 'Field', 'DataType', "C(5)")
	* Props for the RGESTIONDESCARTE.insumo field.
	DBSetProp('RGESTIONDESCARTE.insumo', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.insumo', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.insumo', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.INSUMO')
	DBSetProp('RGESTIONDESCARTE.insumo', 'Field', 'DataType', "C(25)")
	* Props for the RGESTIONDESCARTE.cantdesc field.
	DBSetProp('RGESTIONDESCARTE.cantdesc', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.cantdesc', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.cantdesc', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.CANTDESC')
	DBSetProp('RGESTIONDESCARTE.cantdesc', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONDESCARTE.codcolor field.
	DBSetProp('RGESTIONDESCARTE.codcolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.codcolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.codcolor', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.CODCOLOR')
	DBSetProp('RGESTIONDESCARTE.codcolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONDESCARTE.codtalle field.
	DBSetProp('RGESTIONDESCARTE.codtalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONDESCARTE.codtalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONDESCARTE.codtalle', 'Field', 'UpdateName', 'ZooLogic.GESPDESC.CODTALLE')
	DBSetProp('RGESTIONDESCARTE.codtalle', 'Field', 'DataType', "C(5)")
	ENDFUNC
	 
	FUNCTION CrearVista_RGestionInsumosProd
	***************** View setup for RGESTIONINSUMOSPROD ***************

	CREATE SQL VIEW "RGESTIONINSUMOSPROD" ; 
	   REMOTE CONNECT "SQLDragonFish" ; 
	   AS SELECT Gespins.GESPRODINS, Gespins.MARTDF, Gespins.CCOLOR, Gespins.CTALLE, Gespins.INSUMO, Gespins.CANTIDAD, Gespins.CANTUNIT, Gespins.CODCOLOR, Gespins.CODTALLE FROM ZooLogic.GESPINS Gespins WHERE  Gespins.GESPRODINS = ?codGestionProd

	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'UpdateType', 1)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'WhereType', 3)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'FetchMemo', .T.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'SendUpdates', .F.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'UseMemoSize', 255)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'FetchSize', 100)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'MaxRecords', -1)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'Tables', 'ZooLogic.GESPINS')
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'Prepared', .F.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'CompareMemo', .T.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'Comment', "")
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'BatchUpdateCount', 1)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'ShareConnection', .F.)
	DBSetProp('RGESTIONINSUMOSPROD', 'View', 'AllowSimultaneousFetch', .F.)

	*!* Field Level Properties for RGESTIONINSUMOSPROD
	* Props for the RGESTIONINSUMOSPROD.gesprodins field.
	DBSetProp('RGESTIONINSUMOSPROD.gesprodins', 'Field', 'KeyField', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.gesprodins', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.gesprodins', 'Field', 'UpdateName', 'ZooLogic.GESPINS.GESPRODINS')
	DBSetProp('RGESTIONINSUMOSPROD.gesprodins', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONINSUMOSPROD.martdf field.
	DBSetProp('RGESTIONINSUMOSPROD.martdf', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.martdf', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.martdf', 'Field', 'UpdateName', 'ZooLogic.GESPINS.MARTDF')
	DBSetProp('RGESTIONINSUMOSPROD.martdf', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONINSUMOSPROD.ccolor field.
	DBSetProp('RGESTIONINSUMOSPROD.ccolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.ccolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.ccolor', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CCOLOR')
	DBSetProp('RGESTIONINSUMOSPROD.ccolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONINSUMOSPROD.ctalle field.
	DBSetProp('RGESTIONINSUMOSPROD.ctalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.ctalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.ctalle', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CTALLE')
	DBSetProp('RGESTIONINSUMOSPROD.ctalle', 'Field', 'DataType', "C(5)")
	* Props for the RGESTIONINSUMOSPROD.insumo field.
	DBSetProp('RGESTIONINSUMOSPROD.insumo', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.insumo', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.insumo', 'Field', 'UpdateName', 'ZooLogic.GESPINS.INSUMO')
	DBSetProp('RGESTIONINSUMOSPROD.insumo', 'Field', 'DataType', "C(25)")
	* Props for the RGESTIONINSUMOSPROD.cantidad field.
	DBSetProp('RGESTIONINSUMOSPROD.cantidad', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.cantidad', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.cantidad', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CANTIDAD')
	DBSetProp('RGESTIONINSUMOSPROD.cantidad', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONINSUMOSPROD.cantunit field.
	DBSetProp('RGESTIONINSUMOSPROD.cantunit', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.cantunit', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.cantunit', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CANTUNIT')
	DBSetProp('RGESTIONINSUMOSPROD.cantunit', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONINSUMOSPROD.codcolor field.
	DBSetProp('RGESTIONINSUMOSPROD.codcolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.codcolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.codcolor', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CODCOLOR')
	DBSetProp('RGESTIONINSUMOSPROD.codcolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONINSUMOSPROD.codtalle field.
	DBSetProp('RGESTIONINSUMOSPROD.codtalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSPROD.codtalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSPROD.codtalle', 'Field', 'UpdateName', 'ZooLogic.GESPINS.CODTALLE')
	DBSetProp('RGESTIONINSUMOSPROD.codtalle', 'Field', 'DataType', "C(5)")
	ENDFUNC
	 
	FUNCTION CrearVista_RGestionInsumosDesc
	***************** View setup for RGESTIONINSUMOSDESC ***************

	CREATE SQL VIEW "RGESTIONINSUMOSDESC" ; 
	   REMOTE CONNECT "SQLDragonFish" ; 
	   AS SELECT Gespind.GESPRODIND, Gespind.MARTDF, Gespind.CCOLOR, Gespind.CTALLE, Gespind.INSUMO, Gespind.CANTIDAD, Gespind.CODCOLOR, Gespind.CODTALLE FROM ZooLogic.GESPIND Gespind WHERE  Gespind.GESPRODIND = ?codGestionProd

	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'UpdateType', 1)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'WhereType', 3)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'FetchMemo', .T.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'SendUpdates', .F.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'UseMemoSize', 255)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'FetchSize', 100)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'MaxRecords', -1)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'Tables', 'ZooLogic.GESPIND')
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'Prepared', .F.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'CompareMemo', .T.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'Comment', "")
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'BatchUpdateCount', 1)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'ShareConnection', .F.)
	DBSetProp('RGESTIONINSUMOSDESC', 'View', 'AllowSimultaneousFetch', .F.)

	*!* Field Level Properties for RGESTIONINSUMOSDESC
	* Props for the RGESTIONINSUMOSDESC.gesprodind field.
	DBSetProp('RGESTIONINSUMOSDESC.gesprodind', 'Field', 'KeyField', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.gesprodind', 'Field', 'Updatable', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.gesprodind', 'Field', 'UpdateName', 'ZooLogic.GESPIND.GESPRODIND')
	DBSetProp('RGESTIONINSUMOSDESC.gesprodind', 'Field', 'DataType', "C(38)")
	* Props for the RGESTIONINSUMOSDESC.martdf field.
	DBSetProp('RGESTIONINSUMOSDESC.martdf', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.martdf', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.martdf', 'Field', 'UpdateName', 'ZooLogic.GESPIND.MARTDF')
	DBSetProp('RGESTIONINSUMOSDESC.martdf', 'Field', 'DataType', "C(15)")
	* Props for the RGESTIONINSUMOSDESC.ccolor field.
	DBSetProp('RGESTIONINSUMOSDESC.ccolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.ccolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.ccolor', 'Field', 'UpdateName', 'ZooLogic.GESPIND.CCOLOR')
	DBSetProp('RGESTIONINSUMOSDESC.ccolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONINSUMOSDESC.ctalle field.
	DBSetProp('RGESTIONINSUMOSDESC.ctalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.ctalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.ctalle', 'Field', 'UpdateName', 'ZooLogic.GESPIND.CTALLE')
	DBSetProp('RGESTIONINSUMOSDESC.ctalle', 'Field', 'DataType', "C(5)")
	* Props for the RGESTIONINSUMOSDESC.insumo field.
	DBSetProp('RGESTIONINSUMOSDESC.insumo', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.insumo', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.insumo', 'Field', 'UpdateName', 'ZooLogic.GESPIND.INSUMO')
	DBSetProp('RGESTIONINSUMOSDESC.insumo', 'Field', 'DataType', "C(25)")
	* Props for the RGESTIONINSUMOSDESC.cantidad field.
	DBSetProp('RGESTIONINSUMOSDESC.cantidad', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.cantidad', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.cantidad', 'Field', 'UpdateName', 'ZooLogic.GESPIND.CANTIDAD')
	DBSetProp('RGESTIONINSUMOSDESC.cantidad', 'Field', 'DataType', "N(16,6)")
	* Props for the RGESTIONINSUMOSDESC.codcolor field.
	DBSetProp('RGESTIONINSUMOSDESC.codcolor', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.codcolor', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.codcolor', 'Field', 'UpdateName', 'ZooLogic.GESPIND.CODCOLOR')
	DBSetProp('RGESTIONINSUMOSDESC.codcolor', 'Field', 'DataType', "C(6)")
	* Props for the RGESTIONINSUMOSDESC.codtalle field.
	DBSetProp('RGESTIONINSUMOSDESC.codtalle', 'Field', 'KeyField', .F.)
	DBSetProp('RGESTIONINSUMOSDESC.codtalle', 'Field', 'Updatable', .T.)
	DBSetProp('RGESTIONINSUMOSDESC.codtalle', 'Field', 'UpdateName', 'ZooLogic.GESPIND.CODTALLE')
	DBSetProp('RGESTIONINSUMOSDESC.codtalle', 'Field', 'DataType', "C(5)")
	ENDFUNC

enddefine

*-----------------------------------------------------------------------------------------
define class ColaboradorConexion as ManagerConexionasql of managerconexionasql.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerStringDeConexion() as String
		return this.ObtenerStringConnect()
	endfunc 

enddefine

