select * from TFG_LCM_ResultadoComparativaEnergia tlrce 

select * from TFG_LCM_ResultadoComparativaEnergiav1 tlrce 
where 1=1
 and idCUPS = 'ES0031405093566001EQ0F'


-- 1. BORRAR LAS TABLAS SI EXISTEN
IF OBJECT_ID('dbo.TFG_LCM_ResultadoComparativaEnergiav1', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ResultadoComparativaEnergiav1;

IF OBJECT_ID('dbo.TFG_LCM_ConsumoDiariov1', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ConsumoDiariov1;


IF OBJECT_ID('dbo.TFG_LCM_ConsumoFacturadov1', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ConsumoFacturadov1;