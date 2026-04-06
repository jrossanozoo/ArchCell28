USE [ZL]
GO


IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[RangoSeries]') AND type in (N'U'))

BEGIN 

CREATE TABLE [ZL].[RangoSeries](
	[NroSerie] [varchar](7) NOT NULL,
 CONSTRAINT [PK_RangoSeries] PRIMARY KEY CLUSTERED 
(
	[NroSerie] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

--COMPLETA DE POSIBLES SERIES LA TABLA

WITH CTE  (NroSerie)

AS	(
		select 100000 as NroSerie
		
		UNION ALL
		
		select 200000 as NroSerie
		
		UNION ALL
		
		select 400000 as NroSerie
		
		UNION ALL
		
		select 500000 as NroSerie
		
		UNION ALL
		
		select 600000 as NroSerie
		
		UNION ALL
		
		select 700000 as NroSerie
		
		UNION ALL
		
		select 800000 as NroSerie
		
		UNION ALL
		
		select 900000 as NroSerie
		
		UNION ALL
		
		SELECT NroSerie + 1
		FROM CTE
		WHERE 	NroSerie < 109999
		
		UNION ALL
		
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 200000 and 209999
		
		UNION ALL
		
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 400000 and 409999
		
		UNION ALL
		
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 500000 and 509999
		
		UNION ALL
				
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 600000 and 609999
		
		UNION ALL
				
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 700000 and 709999
		
		UNION ALL
				
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 800000 and 809999
		
		UNION ALL
				
		SELECT NroSerie + 1 
		FROM CTE
		WHERE 	NroSerie between 900000 and 909999
		
	
	)

INSERT INTO [ZL].[RangoSeries]

SELECT cast(NroSerie as varchar(7)) as NroSerie  FROM CTE	

OPTION (MAXRECURSION 10000) --cada rango no supera las 10000 recursiones

ORDER BY NroSerie asc




END --NOT EXISTS




