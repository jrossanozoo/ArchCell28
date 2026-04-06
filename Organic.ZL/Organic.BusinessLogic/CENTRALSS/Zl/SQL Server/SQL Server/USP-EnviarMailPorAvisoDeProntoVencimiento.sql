use zl
go

IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[USP-EnviarMailPorAvisoDeProntoVencimiento]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [ZL].[USP-EnviarMailPorAvisoDeProntoVencimiento]
go

CREATE PROCEDURE [ZL].[USP-EnviarMailPorAvisoDeProntoVencimiento]
WITH ENCRYPTION
AS
-- VERIFICAR SI YA SE ENVIO EL MAIL EL DIA DE HOY
-- ENVIO DE MAIL