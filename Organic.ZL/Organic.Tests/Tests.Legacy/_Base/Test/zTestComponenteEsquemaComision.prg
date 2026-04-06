**********************************************************************
Define Class zTestComponenteEsquemaComision as FxuTestCase OF FxuTestCase.prg

	#If .F.
		Local This As zTestComponenteEsquemaComision Of zTestComponenteEsquemaComision.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	Function Setup
		local loEntidad as entidad OF entidad.prg
		
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.Codigo = "ITEMSERCOD"
			catch to loError
				.nuevo()
				.Codigo = "ITEMSERCOD"
				.Numero = 1
				.Grabar()
			catch to loError
			finally
				.release()
			endtry
		endwith

		=BlanquearTablas()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial()
	Endfunc

	*---------------------------------
	Function TearDown
		=BlanquearTablas()
	Endfunc	

	*-----------------------------------------------------------------------------------------
    Function zTestSQLServerObtenerItemsSinEsquemas
        local loEntidad as Object, loError as Exception,  lnRegimenComision as Integer,;
         loEntidadItem as Object, loEntidadCom as Object, loTalonario as Object , loZLTIPOUSUARIOZL as Object, ;
         loLegajoops as Object , loEsquemaComisional as Object 

		this.agregarmocks( "Zlrazonsociales,ZLSERIES,Zlisarticulos,contratov2, ActualizarzOO" ) 

		_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Levantarexcepciontexto', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlrazonsociales', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Levantarexcepciontexto', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlisarticulos', 'Tienemoduloti', .F. )
		_screen.mocks.AgregarSeteoMetodo( 'Zlrazonsocialesad_sqlserver', 'Verificarexistenciaclaveprimaria', .T., "[55555]" )
		_screen.mocks.AgregarSeteoMetodo( 'Zlrazonsocialesad_sqlserver', 'Cargar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" ) 

		loZLTIPOUSUARIOZL = _Screen.zoo.instanciarentidad( "ZLTIPOUSUARIOZL" )
		With loZLTIPOUSUARIOZL 
			Try
				.cCod = '1'
				.Modificar()
			Catch
				.nuevo()
				.cCod = '1'
			finally
				.Descrip = 'desc' + Sys( 2015 )
				.grabar()
			Endtry
			.Release()
		Endwith
		loZLTIPOUSUARIOZL = Null		
		
		loLegajoops = _Screen.zoo.instanciarentidad( "Legajoops" )
		With loLegajoops 
			Try
				.Codigo = '1'
				.Modificar()
			Catch
				.nuevo()
				.Codigo = '1'
			finally
				.Cortesia = 'desc' + Sys( 2015 )
				.tipousuarioZL_pk = '1'
				.UsuarioActivo = .t.
				.grabar()
			Endtry
			.Release()
		Endwith
		loLegajoops = Null			

		loEsquemaComisional = _Screen.zoo.instanciarentidad( "Esquemacomisional" )
		With loEsquemaComisional
			Try
				.cCod = 22
				.Modificar()
			Catch
				.nuevo()
				.cCod = 22
			finally
				.Descrip = 'Esquema de prueba ' + Sys( 2015 )
				.Owner_Pk = '1'
				.grabar()
			Endtry
		Endwith
		loEsquemaComisional.Release()
		loEsquemaComisional = Null

		loTalonario = _screen.zoo.instanciarentidad( "Talonario" )

		with loTalonario
			try
				.codigo = 'ITEMSERCOD'
				.Modificar()
			catch to loerror
				.nuevo()
				.codigo = 'ITEMSERCOD'
			finally
				.grabar()
			endtry
			.release()
		endwith

		loEntidadItem = _Screen.zoo.instanciarentidad( "ZLITEMSSERVICIOS" )
		with loEntidadItem
			try
				.RazonSocial =  _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestComponenteEsquemaComision.prg" ) 
				.nuevo()
				.RazonSocial_pk = '55555'
				.NumeroSerie_pk = '900000'
				.articulo_pk = '123456'
				.FechaAlta = date()
				.grabar()
	        catch to loError
	        endtry

			try
				.nuevo()
				.RazonSocial_pk = '55555'
				.NumeroSerie_pk = '900000'
				.articulo_pk = '654321'
				.FechaAlta = date()
				.grabar()
	        catch to loError
	        endtry
		endwith

		loEntidad = _Screen.zoo.instanciarentidad( "ZLASIGESQUECOMISIO" )
		with loEntidad
			try
				.nuevo()
				.RazonSocial_pk = '55555'
				.RegimenComision_pk = 22
				.FechaAlta = date()
				.grabar()
	        catch to loError
	        endtry
		endwith

		loEntidadCom = _Screen.zoo.instanciarentidad( "COMASIGITEMSERESQCOM" )

		loEntidadCom.ultimo()
		loEntidadItem.ultimo()
		this.assertequals( "El número de Item debería ser el mismo(1)", loEntidadItem.codigo , loEntidadCom.itemservicio_Pk ) 

		loEntidadCom.anterior()
		loEntidadItem.anterior()
		this.assertequals( "El número de Item debería ser el mismo(2)", loEntidadItem.codigo, loEntidadCom.itemservicio_Pk )

		loEntidadCom.eliminar()
		loEntidadItem.eliminar()
		loEntidadCom.ultimo()
		loEntidadCom.eliminar()
		loEntidadItem.ultimo()
		loEntidadItem.eliminar()
		loEntidad.ultimo()
		loEntidad.eliminar()

		loEntidad.release()
		loEntidadCom.release()
		loEntidadItem.release()
	Endfunc

enddefine

*!*	 DRAGON 2028
function BlanquearTablas
	Use In Select( "ITEMSERV" )
	goServicios.Datos.EjecutarSentencias( 'delete from ITEMSERV', 'ITEMSERV' )

	Use In Select( "ASESCOMAC" )
	goServicios.Datos.EjecutarSentencias( 'delete from ASESCOMAC', 'ASESCOMAC' )

	Use In Select( "Comasisesc" )
		goServicios.Datos.EjecutarSentencias( 'delete from Comasisesc', 'Comasisesc' )
endfunc

*------------------------------------------------------------------------------
define class ZLRazonSociales_Aux as Ent_ZLRazonSociales of Ent_ZLRazonSociales.prg

	*--------------------------------------------------------------------------------------------------------
	function Validar_Regimencomision( txVal as variant ) as Boolean
		return .t.
	endfunc 
	
Enddefine


*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
		(	
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
		select 
				E.Ccod as Esquema ,
				E.Descr as Descripcion,
				Nrz    as RazonSocial ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
				e.dueno as Duenio,
				l.Ccortesia as DescripcionDuenio
				--,	ASESCOMAC.Asignacion as Asignacion
			from ZL.esqcom E
			left join (select Nrz, CREGIMEN, Numero as Asignacion  from zl.ASESCOMAC 
							where NUMERO in ( select max(numero)
								from zl.ASESCOMAC
								group by   Nrz
											)      
						) as ASESCOMAC on e.ccod = ASESCOMAC.CREGIMEN 
			join ZL.Legops l on l.ccod = e.dueno 
			)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
	
endfunc