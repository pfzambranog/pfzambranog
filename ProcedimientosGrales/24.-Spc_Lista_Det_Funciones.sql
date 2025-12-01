/*
Declare
   @PsNombre     Varchar( 60) = Null,
   @PnEstatus    Integer      = 0,
   @PsMensaje    Varchar(250) = Null;
Begin
   Execute dbo.Spc_Lista_Det_Funciones @PsNombre  = @PsNombre,
                                       @PnEstatus = @PnEstatus Output,
                                       @PsMensaje = @PsMensaje Output;

   If @PnEstatus != 0
      Begin
         Select @PnEstatus, @PsMensaje
      End

   Return
End
Go

*/

Create Or Alter Procedure dbo.Spc_Lista_Det_Funciones
  (@PsNombre     Varchar( 60) = Null,
   @PnEstatus    Integer      = 0    Output,
   @PsMensaje    Varchar(250) = Null Output)

As
   Declare 
   @w_Error             Integer,
   @w_desc_error        Varchar( 250),
   @w_registros         Integer;

Begin
/*
Objetivo: Listar los objetos tipo función declarados en la base de datos.
Versión:  2
*/

   Set Nocount       On
   Set Xact_Abort    On
   Set Ansi_Nulls    Off
   Set Ansi_Warnings On
   Set Ansi_Padding  On


   Select  @PnEstatus    = 0,
           @PsMensaje    = ''

   Begin Try 
      Select SCHEMA_NAME(so.SCHEMA_ID) Esquema,
             so.name [Nombre Función], 
             so.type [Tipo Función],
             so.Type_Desc [Descripción Tipo Función],
             p.parameter_id [Id Parametro],
             p.name [Nombre Parametro],
             TYPE_NAME(p.user_type_id) [Tipo de Dato],
             Case When p.system_type_id Not In(34, 35, 58, 61, 189) Then 
                       Case When p.max_length > 0 And p.precision = 0 Then Cast(p.max_length As Varchar)
                            When p.max_length < 0 And p.precision = 0 Then 'Max'
                            When p.precision  > 0 And p.scale = 0 Then Cast(p.precision As Varchar) 
                            When p.precision  > 0 And p.scale > 0 Then Cast(p.precision As Varchar) + ', ' + Cast(p.scale As Varchar)  
                       End
                  Else Cast(p.max_length As Varchar)
             End Longitud,
             Case When p.is_output = 1 
                  Then 'OUT' 
                  Else 'IN' 
             End [Tipo Parametro] 
      From   sys.objects    so
      Join   sys.parameters p
      On     so.OBJECT_ID = p.OBJECT_ID
      Join   sys.types      st 
      On     st.system_type_id = p.system_type_id  
      And    p.user_type_id = st.user_type_id 
      Where  so.TYPE IN ('FN','TF','IF')
      And    so.name   like Iif(@PsNombre  Is Null, so.name,  '%' + @PsNombre + '%') 
      Order  By [Esquema], so.name, p.parameter_id
      Set @w_registros = @@Rowcount
   End Try

   Begin Catch
      Select  @w_Error      = @@Error,
              @w_desc_error = Substring (Error_Message(), 1, 230)
   End   Catch
        
   If Isnull(@w_Error, 0) <> 0
      Begin
         Select @PnEstatus = @w_Error,
                @PsMensaje = 'Error.: ' + Rtrim(Ltrim(Cast(@w_Error As Char))) + ' ' + @w_desc_error
         Set Xact_Abort Off
         Return
      End


   If @w_registros  = 0
      Begin
         Select @PnEstatus  = 4, 
                @PsMensaje  = dbo.Fn_Busca_MensajeError(@PnEstatus)

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
   @w_valor          Nvarchar(250) = 'Procedimiento que Consulta las funciones declaradas en la base de datos.',
   @w_procedimiento  NVarchar(250) = 'Spc_Lista_Det_Funciones';

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
