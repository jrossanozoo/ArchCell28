**********************************************************************
Define Class zTestDetallePRESUPUESTOSFacturaDetalle As FxuTestCase Of FxuTestCase.prg
	#If .F.
		Local This As zTestDetallePRESUPUESTOSFacturaDetalle Of zTestDetallePRESUPUESTOSFacturaDetalle.prg
	#Endif


	*-----------------------------------------------------------------------------------------
	Function Setup
		Local loEntidad As entidad Of entidad.prg, llDarAlta As Boolean
		llDarAlta = .F.
		loEntidad = _Screen.zoo.instanciarentidad( "Talonario" )

		With loEntidad
			Try
				.Codigo = "MODIPRECIOS"
			Catch To loError
				llDarAlta = .T.
			Endtry

			If llDarAlta
				.Nuevo()
				.Codigo = "MODIPRECIOS"
				.entidad = "MODIFICACIONPRECIOS"
				.Numero = 1
				.Grabar()
			Endif

			.Release()
		Endwith
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_func_COM_ArticulosParaPresupuestosPorEjecutivoParaTest()
		CrearFuncion_AdmEstadoRS()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorUsuario()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcItemsVigentes()
	Endfunc

	*---------------------------------
	Function TearDown
		RestaurarFuncion_func_COM_ArticulosParaPresupuestosPorEjecutivoDespuesDelTest()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestActualizarListadeprecios

		Local loEntidad As entidad Of entidad.prg
		loEntidad = _Screen.zoo.instanciarentidad( "TIPOARTICULOITEMSERVICIO" )
		With loEntidad
			Try
				.cCod = "01"
				.Eliminar()
			Catch To loError
			Endtry

			.Nuevo()
			.cCod = "01"
			.Descrip = "Descrip 01"
			.TipoDePresupuesto = "ABON"
			.Grabar()
			.Release()
		Endwith		
		
		This.agregarmocks( "MONEDA,TIPOARTICULOITEMSERVICIO,UBICACION" )
		_Screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', .T. )

		goParametros.zl.altas.LiSTADEPRECIOSPREFERENTE ='LISTA1'
		goParametros.zl.altas.LISTADEPRECIOCOMPRESUPUESTOS='LISTA1'		

		loEntidad = _Screen.zoo.instanciarentidad( "LISTADEPRECIOS" )
		With loEntidad
			Try
				.Codigo = "LISTA1"
				.Eliminar()
			Catch To loError
			Endtry
			Try
				.Nuevo()
				.Codigo = "LISTA1"
				.Nombre = "Lista 01"
				.Moneda_Pk = "01"
				.Grabar()
			Catch To loError
			Endtry

			Try
				.Codigo = "LISTA2"
				.Eliminar()
			Catch To loError
			Endtry

			Try
				.Nuevo()
				.Codigo = "LISTA2"
				.Nombre = "Lista 02"
				.Moneda_Pk = "02"
				.Grabar()
			Catch To loError
			Endtry
			.Release()
		Endwith

		loEntidad = _Screen.zoo.instanciarentidad( "ZLISARTICULOS" )
		With loEntidad
			Try
				.Codigo = "01"
				.Eliminar()
			Catch To loError
			Endtry

			.Nuevo()
			.Codigo = "01"
			.Descrip = "Descrip 01"
			.TipoArticulo_Pk = "01"
			.desactivado = .f.
			.Grabar()

			.Release()
		Endwith

		loEntidad = _Screen.zoo.instanciarentidad( "Modificacionprecios" )
		With loEntidad
			.Nuevo()
			.FechaVigencia = Date()
			With .ModPrecios
				.LimpiarItem()
				.oItem.Articulo_Pk = "01"
				.oItem.ListaDePrecio_Pk = "LISTA1"
				.oItem.PrecioAct = 10
				.Actualizar()

				.LimpiarItem()
				.oItem.Articulo_Pk = "01"
				.oItem.ListaDePrecio_Pk = "LISTA2"
				.oItem.PrecioAct = 20
				.Actualizar()

			Endwith

			.Grabar()
			.Release()
		Endwith

		local loColaboradorPresupuestos_AUX 
		loColaboradorPresupuestos_AUX = newobject( 'ColaboradorPresupuestos_AUX' ) 
		loEntidad = _Screen.zoo.instanciarentidad( "Presupuestos" )
		loEntidad.FacturaDetalle.oItem.InyectarColaboradorPresupuestos( loColaboradorPresupuestos_AUX  )

		With loEntidad
			.Nuevo()
			.lHabilitarFacturaDetalle = .t.
			.ListaDePrecios_Pk = 'LISTA1'
			.TipoDePresupuesto = 'ABON'
			With .FacturaDetalle
				.oItem.oClasificacionesDelCliente = _screen.zoo.crearobjeto( "zoocoleccion" )
				.oItem.Ubicacion_Pk = "01"
				.oItem.Articulo_Pk = "01"
				.oItem.Cantidad = 10
				.Actualizar()
				This.assertequals( "El Monto no es correcto.", 100, .oItem.Monto )
			Endwith

			.Release()
		Endwith

	Endfunc

Enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_FuncObtenerTipoUsuarioZLAD
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncObtenerTipoUsuarioZLAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncObtenerTipoUsuarioZLAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE function [ZL].[FuncObtenerTipoUsuarioZLAD]
		(
			@UsuarioZL Varchar(100)
		)
		returns Varchar(7)
		as
		begin
			declare @ret Varchar(4);

					select @ret = L.Tipousu
						from  ZL.DUsrZLAD D
						JOIN ZL.Legops L on upper(D.codusu) = L.ccod
						where upper(D.USUAD) = upper( @UsuarioZL )

			return ISNULL(@ret, '' )
		end
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorUsuario
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorUsuario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorUsuario]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		create
		 FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorUsuario]
		()
		RETURNS TABLE 
		AS
		RETURN 
		(
			select 
					E.Ccod as Esquema ,
					E.Descr as Descripcion,
				
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
					e.dueno as Duenio,
					case l.Ccortesia when '' 
						then 
							case l.Descp when '' then l.Ccod else l.Descp end 
						else l.Ccortesia end as DescripcionDuenio
				from ZL.esqcom E
			
				join ZL.Legops l on l.ccod = e.dueno 
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_func_COM_ArticulosParaPresupuestosPorEjecutivoParaTest
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]
		(
			@Ejecutivo varchar(100)
		)
		RETURNS TABLE
		AS
		RETURN
		(
			select
					i.ccod as Articulo
				from zl.isarticu i
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function RestaurarFuncion_func_COM_ArticulosParaPresupuestosPorEjecutivoDespuesDelTest
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[func_COM_ArticulosParaPresupuestosPorEjecutivo]
		(
			@Ejecutivo varchar(100)
		)
		RETURNS TABLE
		AS
		RETURN
		(
			select
					i.ccod as Articulo
				from zl.isarticu i
				join zl.tiparis t on t.ccod = i.tipart and t.facpres = 1
			UNION
			select
					a.CODCLA
				from zl.DCLAEECC e
				JOIN ZL.DCLAART A ON A.cmpClasif = e.cmpClasif
				where e.codCLA = @Ejecutivo
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_AdmEstadoRS
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AdmEstadoRS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[AdmEstadoRS]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE function [ZL].[AdmEstadoRS] ( ) returns table as return

		select zl.ASESTRZAD.NRz
		                             ,zl.ASESTRZAD.CEstado
		                             ,rtrim(zl.Estado.Nombre) as [Estado RS Descripción]
		                             ,' '  as [Código Foto Zoo Logic]
		                             ,zl.Estado.Inclfac as [Facturable]
		                             ,case when IsNull(Ltrim(rtrim(zl.Estado.fRAENT)),'')='' then 0 else 1 end as [Dar Código]
		                             ,zl.Estado.Observmda as [Obtener Servicio MDA]
		                             ,zl.Estado.Replica as [zNube Mandato de Replica]
		                             ,zl.Estado.Portal as [zNube Acceso al Portal]
		                             ,zl.ASESTRZAD.Fecha + zl.ASESTRZAD.Cmphoraini AS Fecha
		          from zl.ASESTRZAD   WITH (NOLOCK)
		                  inner join
		                             /*se cruza con los últimos comprobantes de asignación de estado*/
		                             (     select nrz as RS, max(numero) as ultimoComprobante
		                                   from zl.ASESTRZAD   WITH (NOLOCK)
		                                   group by nrz
		                             ) as RsUltimoEstado
		                             on zl.ASESTRZAD.numero = RsUltimoEstado.ultimoComprobante
		                          left join zl.Estado   WITH (NOLOCK) on zl.ASESTRZAD.cestado =  zl.Estado.codigo
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[func_NormalizarNombre]
				(@Texto varchar(max))
			RETURNS VARCHAR(MAX) AS
			BEGIN

				declare @Text varchar(max) = ltrim(rtrim((case when @Texto is null then '' else lower(replace(@Texto, '.', '')) end)))
				while charindex('  ', @Text) > 0
					begin
						set @Text = replace(@Text, '  ', ' ')
					end
				declare @LastTextIndex int = (select charindex(' ', reverse(@Text))), @LastText varchar(max) = ''
				declare @New varchar(max) = ''
				declare @Index int = 1, @Len int = len(@Text)

				while (@Index <= @Len)
					begin
						if (substring(@Text, @Index, 1) like '[^a-z]' and @Index + 1 <= @Len)
							begin
								select @New = @New + upper(substring(@Text, @Index, 2)), @Index = @Index + 2
							end
						else
							begin
								select @New = @New + substring(@Text, @Index, 1), @Index = @Index + 1
							end
					end

				set @New = (upper(left(@New, 1)) + right(@New, abs(@Len - 1)))
				set @LastText = right(lower(@New), abs(@Len - (@Len - @LastTextIndex + 1)))
				set @New =
					case
						when @LastText = 'sa' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.'
						when @LastText = 'srl' then left(@New, @Len - @LastTextIndex + 1) + 'S.R.L.'
						when @LastText = 'sas' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.S.'
						else @New
					end

				return ltrim(rtrim(@New))

			END
	endtext
		
	goServicios.Datos.EjecutarSQL( lcSQL , '' )

endfunc
 

*-----------------------------------------------------------------------------------------
function CrearFuncion_funcItemsVigentes() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcItemsVigentesAFechaConDetalle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcItemsVigentesAFechaConDetalle]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE  FUNCTION [ZL].[funcItemsVigentesAFechaConDetalle]
			(@Fecha datetime)
		RETURNS TABLE
		AS
		RETURN
		(
			select i.ccod, i.Crass as RS
			from zl.itemserv as i WITH (NOLOCK)
			where (fealvig between '19000102' and @Fecha )
				and (febavig >= @Fecha or febavig='19000101')

			union all

			select i.ccod, i.Crass as RS
			from zl.itemserv as i WITH (NOLOCK)
				join zl.relaciontiis as ti  WITH (NOLOCK) on ti.ccod =  i.ccod
			where fealvig = '19000101' and febavig='19000101'
				and ti.fechaact > '19000101'
				and i.cmpfecdes = '19000101'
		)
	endtext
		
	goServicios.Datos.EjecutarSQL( lcSQL , '' )


	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcItemsVigentesAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcItemsVigentesAFecha]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[funcItemsVigentesAFecha]
			(@Fecha datetime)
		RETURNS TABLE
		AS
		RETURN
		(
			select ccod
			FROM [ZL].[funcItemsVigentesAFechaConDetalle](@Fecha)
			
		)
	endtext
		
	goServicios.Datos.EjecutarSQL( lcSQL , '' )
	

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcItemsVigentes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcItemsVigentes]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[funcItemsVigentes]()
		RETURNS TABLE
		AS
		RETURN
		(
			select * from [ZL].[funcItemsVigentesAFecha](DATEADD(DAY, 0, DATEDIFF(DAY,0,CURRENT_TIMESTAMP)))
		)
	endtext
		
	goServicios.Datos.EjecutarSQL( lcSQL , '' )
	

endfunc


********************************************************************************
define class ColaboradorPresupuestos_AUX As ColaboradorPresupuestos Of ColaboradorPresupuestos.prg

	*-----------------------------------------------------------------------------------------
	function ValidarArticulo( toItem as Object ) as Void
		nodefault 
	endfunc 


enddefine
