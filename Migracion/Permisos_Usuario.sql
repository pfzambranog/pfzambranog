-- Genera Reporte para Asignación de permisos por Rol a Objetos de Base de datos.
Declare
   @w_user    sysname,
   @w_comilla Char(1);

Begin
   Select @w_user    = 'ZEPGA-NEW\pzamb',
          @w_comilla = Char(34);

   If Not Exists ( Select Top 1 1
                   From   sys.syslogins
                   Where  name = @w_user)
      Begin
         Select idError = 9999,
                Error   = 'Error.: El Usuario Seleccionado No es Válido';

         Goto Salida
      End

--
-- Creación de Tabla Temporal
--

   Create Table #TempComando
  (Secuencia   Integer Not Null Identity (1, 1) Primary Key,
   Comando     Varchar(Max) Not Null);

--
-- Permisos Funciones y Procedimientos.
--

   Insert Into #TempComando
  (Comando)
   Select Concat('Grant Execute, references on ', @w_comilla, name, @w_comilla, ' to ', 
                 @w_comilla, @w_user, @w_comilla,';')
   From   Sysobjects
   Where  Type In ('FN', 'P')
   And    Uid   = 1
   Order  By Type, name;

--
-- Permisos Vistas.
--

   Insert Into #TempComando
  (Comando)
   Select Concat('Grant Select, references on ', @w_comilla, name, @w_comilla, ' to ', 
                 @w_comilla, @w_user, @w_comilla,';')
   From   Sysobjects
   Where  Type = 'V'
   And    Uid  = 1
   Order  By Type, name;

--
-- Permisos Tablas.
--

   Insert Into #TempComando
  (Comando)
   Select Concat('Grant Select, Update, Insert, Delete, references on ', @w_comilla, name, @w_comilla, ' to ', 
                 @w_comilla, @w_user, @w_comilla,';')
   From   Sysobjects
   Where  Type = 'U'
   And    Uid  = 1
   Order  By Type, name;

--
-- Salida.
--

   Select Comando
   From   #TempComando
   Order  By Secuencia;

   Drop Table #TempComando;

Salida:

   Return

End
Go
