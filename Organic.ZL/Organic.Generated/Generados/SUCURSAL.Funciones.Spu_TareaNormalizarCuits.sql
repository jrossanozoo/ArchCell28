IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_TareaNormalizarCuits]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
GO;

CREATE PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
	as
	begin
		SET NOCOUNT ON
		IF ( SELECT COUNT([Ubicacion]) FROM [ADNIMPLANT].[EstructuraBDVersion]  WHERE [Ubicacion] = 'Sucursal' ) = 1
		BEGIN
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'CHEQUE', @Campo = N'cCoTribGir'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'FrmApCta', @Campo = N'Cuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'Legajo', @Campo = N'cCUILcony'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'Legajo', @Campo = N'cCuil'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'NTPRelaserieTel', @Campo = N'cuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'PROVEED', @Campo = N'CLCUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'RORDTR', @Campo = N'Cuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'RazonSocial', @Campo = N'Cuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZL', @Tabla = N'XVALORES', @Campo = N'CLCUIT'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZOOLOGIC', @Tabla = N'ENTFIN', @Campo = N'EfCuit'
			EXEC [Funciones].[Spu_NormalizarCuits] @Esquema = N'ZOOLOGIC', @Tabla = N'depcli', @Campo = N'Cuit'
		end

	end

GO;
