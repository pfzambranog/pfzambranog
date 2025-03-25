Use DB_Siccorp_DES
Go

Declare
   @w_registros      Integer,
   @w_error          Integer,
   @w_linea          Integer,
   @w_mensaje        Varchar(250);
Begin
   Set Nocount    On
   Set Xact_Abort On

   Select @w_linea   = 0,
          @w_error   = 0,
          @w_mensaje = 'Proceso Terminado OK.';

   If  Object_id(N'tempdb.dbo.#TmpPolizaAnio', 'U') Is not Null
       Begin
            Drop Table #TmpPolizaAnio
       End

   If  Object_id(N'tempdb.dbo.#TmpmovimientosAnio', 'U') Is not Null
       Begin
            Drop Table #TmpmovimientosAnio
       End

   Select *
   Into   #TmpPolizaAnio
   From   dbo.polizaAnio
   where  Mes     = 12
   And    Mes_Mov = 'CIE'
   If @@Rowcount = 0
      Begin
         Set @w_mensaje =  'NO HAY PÓlIZAS PARA ACTUALIZAR'
         Goto Salida;
      End

   Select a.*
   Into   #TmpmovimientosAnio
   From   dbo.movimientosAnio a
   Join   dbo.polizaAnio      b
   On     b.Referencia = a.referencia
   And    b.Fecha_Mov  = a.Fecha_mov
   And    b.Ejercicio  = a.ejercicio
   And    b.Mes        = a.mes
   Where  b.Mes        = 12
   And    b.Mes_Mov    = 'CIE'
   If @@Rowcount = 0
      Begin
         Set @w_mensaje = 'NO HAY MOVIMIENTOS PARA ACTUALIZAR'
         Goto Salida;
      End

   Update #TmpPolizaAnio
   Set    mes = 13;

   Update #TmpmovimientosAnio
   Set    mes = 13;

   Begin Transaction
      Begin Try

         Delete dbo.movimientosAnio
         From   dbo.movimientosAnio a
         Join   dbo.polizaAnio      b
         On     b.Referencia = a.referencia 
         And    b.Fecha_Mov  = a.Fecha_mov
         And    b.Ejercicio  = a.ejercicio
         And    b.Mes        = a.mes
         Where  b.Mes        = 12
         And    b.Mes_Mov    = 'CIE';

         Delete dbo.polizaAnio
         From   dbo.polizaAnio b
         Where  b.Mes        = 12
         And    b.Mes_Mov    = 'CIE';

         Insert Into dbo.polizaAnio
         Select *
         From   #TmpPolizaAnio;

         Insert Into dbo.movimientosAnio
         Select *
         From   #TmpmovimientosAnio;

      End Try

      Begin Catch
         Select  @w_Error   = @@Error,
                 @w_linea   = Error_line(),
                 @w_mensaje = Substring (Error_Message(), 1, 200)

      End   Catch

       If Isnull(@w_Error, 0) <> 0
          Begin
             Select @w_Error Error, Concat('Error.: ', @w_Error, ' ', @w_mensaje, ' en Línea ', @w_linea) Mensaje;

             Rollback Transaction
             Set Xact_Abort Off
             Goto Salida
          End

   Commit Transaction;

Salida:

   Select @w_mensaje mensaje;

   If  Object_id(N'tempdb.dbo.#TmpPolizaAnio', 'U') Is not Null
       Begin
            Drop Table #TmpPolizaAnio
       End

   If  Object_id(N'tempdb.dbo.#TmpmovimientosAnio', 'U') Is not Null
       Begin
            Drop Table #TmpmovimientosAnio
       End

End
Go
