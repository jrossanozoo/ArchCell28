**********************************************************************
Define Class ztestMdaincmda as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestMdaincmda of ztestMdaincmda.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestSqlServerCargaUnaLlamadaTipoSALDejaElIdTecnovozEnBlanco
		local loEntidad as entidad OF entidad.prg, loLibrerias as Object, loError as Exception

		this.agregarmocks( "MDATIPOINTERACCION" )
		CrearFuncionesSQL()
		=crearCodigoSugeridoCOMPORTAMIENTOCODIGOSUGERIDOENTIDAD()
		
		try

			loLibrerias = goServicios.Librerias
			goServicios.Librerias = createobject( "Mock_LibreriasTest" )
			goLibrerias = goServicios.Librerias
			_screen.zoo.app.oteCNOVOZ.Release()
			_screen.zoo.app.oteCNOVOZ = null
			_screen.mocks.agregarmock( 'MANAGERTECNOVOZ' )
			_screen.mocks.AgregarSeteoMetodo( 'MANAGERTECNOVOZ', 'Obtenervalorsugeridoreferencia', '' )
			_screen.mocks.AgregarSeteoMetodo( 'MANAGERTECNOVOZ', 'Obtenervalorsugeridotecnovoz', '' )
			_screen.mocks.AgregarSeteoMetodo( 'MANAGERTECNOVOZ', 'Obtenerrazonsocialdetecnovoz', '' )
			_screen.mocks.AgregarSeteoMetodo( 'Relaserierzad_sqlserver', 'Obtenerdatosentidad', .T., "[Codigo],[nroserie = ''],[],[distinct]" )
			_screen.mocks.AgregarSeteoMetodo( 'MANAGERTECNOVOZ', 'Obtenermotivoaperturaautomaticadeincidente', '' )

			CrearTalonario()
			goServicios.Librerias.cRetornoObtenerArchivoPlano = "123456"

			loEntidad = createobject( "Ent_TestMDAINCMDA" )
			with loEntidad

				.Nuevo()
				with .DetalleTransacciones
					.LimpiarItem()
					.oItem.TipoContacto_Pk = "SAL"
					.Actualizar()
				endwith
				This.assertequals( "Es incorrecto el IDTecnovoz","", .DetalleTransacciones.item[ 1 ].idTecnoTransaccionTVoz )				
				.Cancelar()
			endwith
			
			loEntidad.Release()
		catch to loError
			throw loError
		finally
			_screen.zoo.app.oteCNOVOZ.Release()
			_screen.zoo.app.oteCNOVOZ = null
			goServicios.Librerias.Release()
			goServicios.Librerias = loLibrerias
			goLibrerias = loLibrerias
			loLibrerias = null
		endtry
		
	endfunc 	

Enddefine

*-----------------------------------------------------------------------------------------
function CrearTalonario
	local loEntidad as Object
	loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
	
	try
		loEntidad.Codigo = "MDAINCMDA"
	catch
		loEntidad.Nuevo()
		loEntidad.Codigo = "MDAINCMDA"
		loEntidad.Grabar()
	endtry
	loEntidad.Release()
endfunc 


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_LibreriasTest as Librerias of Librerias.Prg
	cRetornoObtenerArchivoPlano = ""
	*-----------------------------------------------------------------------------------------
	function ObtenerArchivoPlano( tcNombre as String, tnLineas as integer, tnDesde as integer, tnPosicion as integer) as string
		return This.cRetornoObtenerArchivoPlano
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Ent_TestMDAINCMDA as Ent_MDAINCMDA of Ent_MDAINCMDA.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosRazonSocial( ) as Void
	**bla	
	endfunc 
	
	
	*-----------------------------------------------------------------------------------------
	function ValidarTipoIncidenteXProducto()
		return  .T. 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarSubTipoIncidente()
		return  .T. 
	endfunc 	

enddefine

*-----------------------------------------------------------------------------------------
function ObtenerXML_Vacio() as String
		local loBoleta, lcXml
		loBoleta = _screen.zoo.instanciarentidad("Mdaincmda")
		lcXml = loBoleta.oad.obtenerdatosentidad("Numero",,,"MAX")
		loBoleta.release()
		return lcXml

endfunc 
	
*-----------------------------------------------------------------------------------------
function CrearFuncionesSQL() as Void
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerUsuarioZLPorUsuarioAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerUsuarioZLPorUsuarioAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerUsuarioZLPorUsuarioAD]
		( @Usuario as Varchar(100) )
			RETURNS TABLE
			AS
			RETURN
			(
				select 
					CODUSU as UsuarioZL
				from ZL.DUSRZLAD DU
				where DU.USUAD = @Usuario
					)
				ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc 

*-----------------------------------------------------------------------------------------
function crearCodigoSugeridoCOMPORTAMIENTOCODIGOSUGERIDOENTIDAD() as Void
	Local lcTexto
	TEXT to lcTexto noshow
		if not exists( select * from Organizacion.COMCODSU where entidad= 'MDAINCMDA')
			insert into ORGANIZACION.COMCODSU ( "Horaexpo","Horaimpo","Haltafw","Fectrans","Fecimpo","Fmodifw","Hmodifw","Saltafw","Vmodifw","Zadsfw","Valtafw","Umodifw","Smodifw","Ualtafw","Fecexpo","Faltafw","Bdmodifw","Esttrans","Bdaltafw","Desentidad","Entidad","Anchodispo","Sugerir","Idglobal","Anchosuger","Prefijobd","Prefijo","Vistaprev","Busqextend","Obs","Salta" ) values ( '', '', '17:45:50', '19000101', '19000101', '20251030', '17:45:50', '104500', '01.0001.00000', '', '01.0001.00000', '', '104500', '', '19000101', '20251030', 'ZL', '', 'ZL', 'Incidentes', 'MDAINCMDA', 8.00, 0, 0, 0, 0, '', '', 0, '', 0 )
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )	
	
endfunc 
