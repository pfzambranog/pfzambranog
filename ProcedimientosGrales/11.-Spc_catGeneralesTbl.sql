/*

Procedimiento que lista los valores de la tabla de Catalogos Generales.

Declare
   @PsTabla              Varchar(  90)   = Null,  
   @PsColumna            Varchar(  90)   = Null,  
   @PnValor              Smallint        = Null,  
   @PsDescripcion        Varchar(  60)   = Null,
   @PnEstatus            Integer         = 0,   
   @PsMensaje            Varchar( 250)   = ' '

Begin
   Execute  dbo.Spc_catGeneralesTbl @PsTabla        = @PsTabla,
                                    @PsColumna      = @PsColumna,
                                    @PnValor        = @PnValor,
                                    @PsDescripcion  = @PsDescripcion,
                                    @PnEstatus      = @PnEstatus Output,
                                    @PsMensaje      = @PsMensaje Output

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return

End
Go

*/

Create Or Alter Procedure dbo.Spc_catGeneralesTbl
   (@PsTabla                   Sysname       = Null,  
    @PsColumna                 Sysname       = Null,  
    @PnValor                   Smallint      = Null,  
    @PsDescripcion             Varchar(  60) = Null,  
    @PnEstatus                 Integer       = 0   Output,  
    @PsMensaje                 Varchar( 250) = ' ' Output)    
  
As  
Declare  
    @w_sql               Varchar(Max),  
    @w_desc_error        Varchar( 250),  
    @w_Error             Integer,  
    @w_primero           Bit,  
    @w_comilla           Char(1)  
  
Begin
/*
Objetivo: Listar los valores de la tabla de Catalogos Generales.
Verión:   1
*/

   Set Nocount       On  
   Set Xact_Abort    On  
   Set Ansi_Nulls    On  
   Set Ansi_Warnings On  
   Set Ansi_Padding  On  
     
   Select @PnEstatus  = 0,  
          @PsMensaje  = Null,  
          @w_primero  = 0,  
          @w_comilla  = Char(39)  
  
   Set @w_sql = 'Select tabla, columna, valor, descripcion
                 From   dbo.catGeneralesTbl 
                 Where  1 = 1'  
  
   If Isnull(Rtrim(Ltrim(@PsTabla)), ' ') != ' '  
      Begin  
         Set @w_sql     = @w_sql + ' And Tabla Like ' + @w_comilla + '%' + @PsTabla + '%' + @w_comilla  
      End  
  
   If Isnull(Rtrim(Ltrim(@PsColumna)), ' ') != ' '  
      Begin  
         Set @w_sql = @w_sql + ' And  Columna Like ' + @w_comilla + '%' + @PsColumna + '%' + @w_comilla  
      End  
  
   If Isnull(@PnValor, -1) != -1  
      Begin  
         Set @w_sql = @w_sql + ' And Valor = ' + Cast(@PnValor As Varchar)  
      End  
  
   If Isnull(Rtrim(Ltrim(@PsDescripcion)), ' ') != ' '  
      Begin  
         Set @w_sql = @w_sql + ' And Descripcion Like ' + @w_comilla + '%' + @PsDescripcion + '%' + @w_comilla  
      End  
  
   Set @w_sql = @w_sql + ' Order by Descripcion '  
  
   Begin Try  

   PRINT @w_sql

      Execute (@w_sql)  
   End Try  
  
   Begin Catch  
      Select  @w_Error      = @@Error,  
              @w_desc_error = Substring (Error_Message(), 1, 230)  
   End   Catch  
  
   If Isnull(@w_Error, 0) <> 0  
      Begin  
         Select @PnEstatus = @w_Error,  
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Varchar))) + ' ' + @w_desc_error  
         Set Xact_Abort Off  
         Return  
      End  
  
   Set Xact_Abort Off  
   Return  
End  
Go 

--
-- Comentarios
--

Declare
   @w_valor          Nvarchar(250) = 'Procedimiento que lista los Valores de lla Tabla de Catalogos Generales.',
   @w_procedimiento  NVarchar(250) = 'Spc_catGeneralesTbl';

If Not Exists (Select Top 1 1
               From   sys.extended_properties a
               Join   sysobjects  b
               On     b.xtype   = 'P'
               And    b.name    = @w_procedimiento
               And    b.id      = a.major_id)
   Begin
      Execute  sp_addextendedproperty @name       = N'MS_Description',
                                      @value      = @w_valor,
                                      @level0type = 'Schema',
                                      @level0name = N'dbo',
                                      @level1type = 'Procedure', 
                                      @level1name = @w_procedimiento

   End
Else
   Begin
      Execute sp_updateextendedproperty @name       = 'MS_Description',
                                        @value      = @w_valor,
                                        @level0type = 'Schema',
                                        @level0name = N'dbo',
                                        @level1type = 'Procedure', 
                                        @level1name = @w_procedimiento
   End
Go