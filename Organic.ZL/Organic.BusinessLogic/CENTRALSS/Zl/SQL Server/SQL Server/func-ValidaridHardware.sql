Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ValidarIdHardware]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[ValidarIdHardware] () returns varchar(4) begin declare @CodigoModulo varchar(4) set @CodigoModulo = 0000 return @CodigoModulo end')
  end   
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/************************************************************************************************/
/* Valida Perfil */
/************************************************************************************************/			
ALTER function [ZL].[ValidarIdHardware]
	( @nroserie varchar(6) , 
      @idhard varchar(4) )
returns bit
	begin
		declare @lRetorno bit
		declare @IdHardWare varchar(4)

		set @lRetorno = 1

		Select top 1 @IdHardWare = idhard from [ZL].[RegCodDesact] 
			where nroserie = @nroserie and entradas <> 0 order by fecha desc ,hora desc

		if ( @IdHardWare is null or @IdHardWare = '' ) and len(@nroserie) > 6
			begin
				set @nroserie = substring(@nroserie, 2, len(@nroserie)-1)

				Select top 1 @IdHardWare = idhard from [ZL].[RegCodDesact] 
					where nroserie = @nroserie and entradas <> 0 order by fecha desc ,hora desc
			end

		if @IdHardWare <> @idhard 
			set @lRetorno = 0

	return @lRetorno

end