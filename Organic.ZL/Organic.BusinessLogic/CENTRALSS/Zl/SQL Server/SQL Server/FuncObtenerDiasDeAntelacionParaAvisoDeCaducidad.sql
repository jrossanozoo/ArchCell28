USE [ZL]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncObtenerDiasDeAntelacionParaAvisoDeCaducidad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [ZL].[FuncObtenerDiasDeAntelacionParaAvisoDeCaducidad]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

create function [ZL].[FuncObtenerDiasDeAntelacionParaAvisoDeCaducidad]()
returns int
with encryption
as
begin
	return 30
end