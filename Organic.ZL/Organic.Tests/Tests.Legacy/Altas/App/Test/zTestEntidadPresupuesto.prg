DEFINE CLASS zTestEntidadPresupuesto as FxuTestCase OF FxuTestCase.prg
	#IF .f.
		LOCAL THIS AS zTestEntidadPresupuesto OF zTestEntidadPresupuesto.PRG
	#ENDIF

	*---------------------------------
	Function Setup
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_AdmEstadoRS()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorUsuario()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInicializar
		local lcEntidad as Object
		
		lcEntidad = newobject( "Mock_EntidadPResupuesto" )
		This.asserttrue( "Debi pasar por el metodo 'InyectarListaDePrecios'.", lcEntidad.lPasoPorInyectarListaDePrecios )
		
		lcEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificaListaDePreciosInyectadaEnItem
		local loEntidad as entidad OF entidad.prg, loError as zooexception OF zooexception.prg
		This.agregarmocks( "MONEDA" )
		
		loEntidad = _Screen.zoo.instanciarentidad( "LISTADEPRECIOS" )
		with loEntidad
			try
				.Codigo = "TEST99"
				.Modificar()
			catch to loError
				.Nuevo()
				.Codigo = "TEST99"
			finally
				.CondicionIva = 1
				.Moneda_Pk = "01"
				.Nombre = "Moneda 99"
				.Grabar
			endtry

			try
				.Codigo = "TEST88"
				.Modificar()
			catch to loError
				.Nuevo()
				.Codigo = "TEST88"
			finally
				.CondicionIva = 1
				.Moneda_Pk = "01"
				.Nombre = "Moneda 88"
				.Grabar
			endtry

			.Release()
		endwith

		loEntidad = _Screen.zoo.instanciarentidad( "presupuestos" )
		with loEntidad
			goParametros.zl.altas.LISTADEPRECIOSPREFERENTE="TEST99"
			goParametros.zl.altas.LISTADEPRECIOCOMPRESUPUESTOS="TEST99"
			.Nuevo()
			.ListaDePrecios_Pk = "TEST99"
			This.assertequals( "No Actualizo la lista de precios en el Item(1).", "TEST99" , .FacturaDetalle.oItem.oListaDePrecios.Codigo )
		
			goParametros.zl.altas.LISTADEPRECIOSPREFERENTE="TEST88"
			goParametros.zl.altas.LISTADEPRECIOCOMPRESUPUESTOS="TEST88"
			.ListaDePrecios_Pk = "TEST88"
			This.assertequals( "No Actualizo la lista de precios en el Item(2).", "TEST88" , .FacturaDetalle.oItem.oListaDePrecios.Codigo )
		
			.Release()
		endwith
		
	endfunc 
	
ENDDEFINE


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class Mock_EntidadPResupuesto as ent_presupuestos of ent_presupuestos.prg

	lPasoPorInyectarListaDePrecios = .F.
	*-----------------------------------------------------------------------------------------
	function InyectarListaDePrecios() as Void
		This.lPasoPorInyectarListaDePrecios = .T.
	endfunc 
	
enddefine


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
endfunc

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
		                             ,Rtrim(zl.Estado.Nombre) as [Estado RS Descripción]
		                             ,' ' as [Código Foto Zoo Logic]
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
endfunc

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
