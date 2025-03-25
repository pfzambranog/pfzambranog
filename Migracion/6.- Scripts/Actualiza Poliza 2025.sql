Use DB_Siccorp_DES
Go

Begin
   If  Object_id(N'tempdb.dbo.#TmpPolizaCierre', 'U') Is not Null
       Begin
            Drop Table #TmpPolizaCierre
       End

   If  Object_id(N'tempdb.dbo.#TmpPolizaHist', 'U') Is not Null
       Begin
            Drop Table #TmpPolizaHist
       End

   Create Table #TmpPolizaCierre
   (secuencia         Integer     Not Null Identity (1, 1) Primary Key,
    referencia        Varchar(20) Not Null,
    Fecha_mov         Date        Not Null,
    ejercicio         Smallint    Not Null,
    mes               Tinyint     Not Null,
    existe            Bit         Not Null Default 0,
    Index TmpPolizaCierreIdx01 Unique (referencia, Fecha_mov))
 
--
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI005', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI006', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI007', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI008', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI009', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI010', '2023-07-04', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI011', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI011', '2024-06-18', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI012', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021579', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021580', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021581', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021584', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021585', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021587', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021588', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021590', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021591', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021593', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021594', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021596', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021597', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021601', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021602', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021603', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021604', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021605', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021606', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021607', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021608', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021609', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021610', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021612', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021613', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021614', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021615', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021616', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI021617', '2022-12-31', 2022, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI000007', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI001', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI002', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI003', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI004', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI005', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI006', '2024-05-10', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI008', '2025-02-18', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028984', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028985', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028986', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028988', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028989', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028990', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028991', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028995', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028997', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI028998', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029000', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029001', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029002', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029003', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029004', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029014', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029022', '2023-12-13', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI029023', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI032600', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI053352', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI053353', '2023-12-31', 2023, 12
   Insert into #TmpPolizaCierre (referencia, fecha_mov, ejercicio, mes) Select 'PDI053354', '2023-12-31', 2023, 12
--

   Begin Transaction
      Insert Into dbo.poliza
      Select *
      From   dbo.PolizaHist
      Where  ejercicio = 2024;
   
      Insert Into dbo.movimientos
      Select *
      From   dbo.movimientosHist
      Where  ejercicio = 2024;
   
      Select a.*
      Into   #TmpPolizaHist
      from   dbo.PolizaHist a
      Join   #TmpPolizaCierre b
      On     b.referencia = a.referencia Collate database_default
      And    b.ejercicio  = a.ejercicio
      And    a.mes        = 12
      And    b.Fecha_mov  = Cast(a.Fecha_mov as Date)
      If @@Rowcount = 0
         Begin
            Select 'Todas las Pólizas de Cierre están en el Histórico.'
            Rollback Transaction
            Goto Salida;
         End
   
      Delete dbo.movimientosHist
      Where  ejercicio = 2024;
   
      Delete   dbo.PolizaHist
      Where  ejercicio = 2024;

   Commit Transaction

Salida:

End
Go

