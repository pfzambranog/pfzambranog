Use DB_Siccorp_DES
Go

--
-- Script de Validación de Movimientos de Polizas contables.
--

Begin
   Set nocount On

   Select Count(1) "Registros Faltantes en Movimientos"
   from   dbo.movimientosHist a With (Index (IX_FK_MovimientosHistFk01))
   Where  ejercicio  = 2024
   And    Not Exists (Select Top 1 1
                      From   dbo.movimientos
                      Where  referencia = a.referencia
                      And    cons       = a.cons
                      And    fecha_mov  = a.fecha_mov
                      And    Ejercicio  = a.ejercicio
                      And    mes        = a.mes);
   
   
   Select Count(1) "Registros Faltantes en Movimiento Histórico"
   from   dbo.movimientos  a With (Index(IX_FK_MovimientosFk01))
   Where  ejercicio  = 2024
   And    Not Exists (Select Top 1 1
                      From   dbo.movimientosHist With (Index(PK_MovimientosHist))
                      Where  referencia = a.referencia
                      And    cons       = a.cons
                      And    fecha_mov  = a.fecha_mov
                      And    Ejercicio  = a.ejercicio
                      And    mes        = a.mes
   				      And    Llave      = a.Llave);

   Return

End
Go
