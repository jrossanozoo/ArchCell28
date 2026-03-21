IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_RenumerarAsientos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
	DROP PROCEDURE [Contabilidad].[sp_RenumerarAsientos];
GO;

Create procedure [Contabilidad].[sp_RenumerarAsientos]
(
	@AsientoInicial int,
	@NroInicial int
)
as 
Begin
	update [ZooLogic].[ASIENTO] 
	set NUMERO = nuevo 
	from ZooLogic.ASIENTO a inner join 
	(select (ROW_NUMBER() over(order by a.fecha asc  ) +( @NroInicial - 1)) as nuevo ,a.NUMERO, a.acod 
	from [ZooLogic].[ASIENTO] a where a.NUMERO >= @AsientoInicial ) B
	on a.ACOD = b.ACOD

end

