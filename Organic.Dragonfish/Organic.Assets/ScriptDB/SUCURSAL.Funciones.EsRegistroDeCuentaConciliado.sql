IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsRegistroDeCuentaConciliado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsRegistroDeCuentaConciliado];
GO;
  
CREATE FUNCTION [Funciones].[EsRegistroDeCuentaConciliado]
( 
  @Codigo char(20)
  )

RETURNS char(2)
AS
BEGIN

	declare @Retorno char(2) = 'No';
	if exists(
		select top 1 *
		from ZOOLOGIC.regcta as c
		inner join [ZooLogic].[DETREGCON] as d on d.REG = c.CODIGO
		where d.REG = @Codigo )
	begin 
		set @Retorno = 'Si'; 
	end

	return @Retorno
end
