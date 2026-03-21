IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsBaseDeReplica]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[EsBaseDeReplica];
GO;

create function [Funciones].[EsBaseDeReplica]( )
		returns bit
		as
		begin
			declare @cRetorno bit, @valor int
			set @valor = ( SELECT COUNT(*) FROM [ADNIMPLANT].[EstructuraBDVersion] WHERE Ubicacion = 'REPLICA' )
			set @cRetorno = ( case when  @valor > 0 then 1 else 0 end )
			return @cRetorno
		end