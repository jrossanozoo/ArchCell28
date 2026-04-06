USE [ZL]
GO

/****** Object:  UserDefinedFunction [dbo].[ListaATabla]    Script Date: 07/24/2013 15:42:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ListaATabla]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ListaATabla]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [dbo].[ListaATabla]    Script Date: 07/24/2013 15:42:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[ListaATabla] (@delimStr NVARCHAR(max))
RETURNS 

@StrValTable TABLE 
(
     ValorRetorno VARCHAR(100) 
)
AS
BEGIN
    DECLARE @strlist NVARCHAR(max), @pos INT, @delim CHAR, @lstr NVARCHAR(max)
    SET @strlist = ISNULL(@delimStr,'')
    SET @delim = ','

    WHILE ((len(@strlist) > 0) and (@strlist <> ''))
    BEGIN
        SET @pos = charindex(@delim, @strlist)
        
        IF @pos > 0
           BEGIN
              SET @lstr = substring(@strlist, 1, @pos-1)
              SET @strlist = ltrim(substring(@strlist,charindex(@delim, @strlist)+1, 8000))
           END
        ELSE
           BEGIN
              SET @lstr = @strlist
              SET @strlist = ''
           END

        INSERT @StrValTable VALUES (@lstr)
    END
        RETURN 
    END


GO


