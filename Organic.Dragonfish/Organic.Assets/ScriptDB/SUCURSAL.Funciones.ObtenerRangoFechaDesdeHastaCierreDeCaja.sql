IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerRangoFechaDesdeHastaCierreDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerRangoFechaDesdeHastaCierreDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerRangoFechaDesdeHastaCierreDeCaja]
( @desde char(19), @hasta char(19), @SoloCierres bit )	
RETURNS @retorno3 TABLE(
	ff char(19),
	idcaja int,
	idcajaaudi int, 
	tarea varchar(10), 
	ciclo int,
	id int
)
AS
BEGIN
declare @fecha char(19);
declare @id int;
declare @count int;
declare @count1 int;
declare @retorno table(
	ff char(19),
	idcaja int,
	idcajaaudi int, 
	tarea varchar(10), 
	ciclo int,
	id int identity(1,1)
);
declare @retorno1 table(
	ff char(19),
	idcaja int,
	idcajaaudi int, 
	tarea varchar(10), 
	ciclo int
);
declare @retorno2 table(
	ff char(19),
	idcaja int,
	idcajaaudi int, 
	tarea varchar(10), 
	ciclo int
);
declare @retorno4 table(
	ff char(19),
	idcaja int,
	idcajaaudi int, 
	tarea varchar(10), 
	ciclo int,
	id int identity(1,1)
);
				--
				insert into @retorno1
				select  cast( convert(date, fecha, 103 ) as char(10) ) + ' ' + cast( hora  as char( 8 ) ) as ff, NUMCAJA,CODIGO, tarea, 0 as ciclo
				from Zoologic.CAJAAUDI 
				where cast(convert(date, fecha,103) as char(10)) +' '+ cast( hora  as char( 8 ) ) >= @desde
				and cast(convert(date, fecha,103) as char(10)) +' '+ cast( hora  as char( 8 ) ) <= @hasta;		

				
				insert into @retorno
				select * from @retorno1 order by idcaja, ff;

						
				if @SoloCierres = 1 and (select top 1 tarea from @retorno order by id desc) = 'APERTURA'
				begin
					delete top(1) from @retorno where id = (select top 1 id from @retorno order by id desc)
				end;
				if (select top 1 tarea from @retorno order by id asc) = 'CIERRE'
				begin
					--
					if @SoloCierres = 1	
						insert into @retorno2				
						select cast( convert(date, fecha, 103 ) as char(10) ) + ' ' + cast( hora  as char( 8 ) ) as ff, NUMCAJA,CODIGO, tarea, 0 as ciclo
						from Zoologic.CAJAAUDI where codigo = (select (idcajaaudi - 1) from (select top 1 tarea,idcajaaudi from @retorno where tarea = 'CIERRE' order by idcajaaudi asc) as C1)
						and NUMCAJA = (select numcaja from (select top 1 tarea,idcaja from @retorno where tarea = 'CIERRE' order by idcajaaudi asc) as C1)
					else
						insert into @retorno2				
						select cast( convert(date, fecha, 103 ) as char(10) ) + ' ' + cast( hora  as char( 8 ) ) as ff, NUMCAJA,CODIGO, tarea, 0 as ciclo
						from Zoologic.CAJAAUDI where codigo = (select (idcajaaudi - 1) from (select top 1 tarea,idcajaaudi from @retorno order by idcajaaudi asc) as C1)
						and NUMCAJA = (select numcaja from (select top 1 tarea,idcaja from @retorno order by idcajaaudi asc) as C1)

					insert into @retorno4
					select * from @retorno2 where tarea  = 'APERTURA' order by idcaja, ff;
					insert into @retorno3
					select * from @retorno4 order by idcaja, ff;
				end;
				
				
				insert into @retorno3
				select * from @retorno order by idcaja, ff
				
				set @count1 = (select top 1 id from @retorno3 order by id);
				Set @id=1
				SELECT @count = COUNT(*) FROM @retorno3
				
				while @id<=@count
				begin
					UPDATE @retorno3 SET ciclo = (@count1/2) where id = @count1 or (id = @count1 + 1 and tarea <> 'APERTURA');
					UPDATE @retorno3 SET ciclo = (@count1/2)+1 where (id = @count1 + 1) and tarea = 'APERTURA';
					select @count1 = @count1 + 2
					select @id=@id+2
				end
				
			return 
end