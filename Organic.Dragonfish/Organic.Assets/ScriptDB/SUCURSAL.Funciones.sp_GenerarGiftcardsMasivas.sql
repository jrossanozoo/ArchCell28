IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_GenerarGiftcardsMasivas' AND type in (N'P') and SCHEMA_ID('Funciones') = schema_id)
	DROP PROCEDURE Funciones.sp_GenerarGiftcardsMasivas;
GO;

CREATE PROCEDURE [Funciones].[sp_GenerarGiftcardsMasivas]
(
	@Cantidad numeric(4,0),
	@impMonto numeric(15,2),
	@fechaVto varchar(8),
	@nroInterno numeric(8,0),
	@nroPtoVenta numeric(4,0),
	@nroSerie varchar(7),
	@codUsuario varchar(100),
	@codMoneda varchar(10),
	@codBD varchar(8),
	@codVersion varchar(13)
)
AS
BEGIN
	DECLARE @contador INT = 1;
	DECLARE @NumeroInterno INT = @nroInterno;
	DECLARE @IdGlobal CHAR(38);

	WHILE @contador <= @Cantidad
	BEGIN
		SET @NumeroInterno = @NumeroInterno + 1;
		SET @IdGlobal = ( Select ( [Funciones].[ObtenerIdGlobal]() ) );

		Insert Into [ZooLogic].[VALCAMBIO] ( CCOD, CFCHDEST, CFCHORIG, CFECHA, CFECHAVENC, CHORA, CMONTO, CSERIE, CUSUARIO, 
											 FALTAFW, FECEXPO, FECIMPO, FECTRANS, FMODIFW, HALTAFW, HMODIFW, MONEDA, NUMERO, PTOVENTA, 
											 BDALTAFW, BDMODIFW, CBDORIG, SALTAFW, SMODIFW, TIPO, UALTAFW, UMODIFW, VALTAFW, VMODIFW ) 
		Select @IdGlobal, '19000101', CONVERT( VARCHAR(8), GETDATE(), 112 ), CONVERT( VARCHAR(8), GETDATE(), 112 ), @fechaVto, CONVERT( VARCHAR(8), GETDATE(), 108 ), @impMonto, @nroSerie, @codUsuario, 
				 CONVERT( VARCHAR(8), GETDATE(), 112 ), '19000101', '19000101', '19000101', CONVERT( VARCHAR(8), GETDATE(), 112 ), CONVERT( VARCHAR(8), GETDATE(), 108 ), CONVERT( VARCHAR(8), GETDATE(), 108 ), @codMoneda, @NumeroInterno, @nroPtoVenta, 
				 @codBD, @codBD, @codBD, @nroSerie, @nroSerie, 'GiftCard', @codUsuario, @codUsuario, '01.0001.00000', '01.0001.00000'

		SET @contador = @contador + 1;
	END

	Select CCOD As CODIGO, CFECHA As Fecha, CFECHAVENC As FechaVencimiento, CMONTO As Monto, NUMERO As NroInt 
	From [ZooLogic].[VALCAMBIO] As C 
	Where PTOVENTA = @nroPtoVenta and NUMERO > @nroInterno and NUMERO <= @NumeroInterno 

END
