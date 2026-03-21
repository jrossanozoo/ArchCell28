IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_TareaNormalizarCuits]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
GO;

CREATE PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
	as
	begin
		SET NOCOUNT ON
		IF ( SELECT COUNT([Ubicacion]) FROM [ADNIMPLANT].[EstructuraBDVersion]  WHERE [Ubicacion] = 'Sucursal' ) = 1
		BEGIN
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'CHEQUE', @Campo = N'cCoTribGir'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'CLI', @Campo = N'CLT_CUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'CORRE', @Campo = N'COCUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'CompRR', @Campo = N'cuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'CtaBan', @Campo = N'CBCuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'EntFin', @Campo = N'EfCuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'POS', @Campo = N'CuitComer'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'RAZONS', @Campo = N'CUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'TRA', @Campo = N'TRCUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZooLogic', @Tabla = N'XVALORES', @Campo = N'CLCUIT'
		end

	end

GO;
