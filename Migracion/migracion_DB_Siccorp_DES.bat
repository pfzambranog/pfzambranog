@echo off

set serv=192.168.99.1
set db=DB_Siccorp_DES
Set dir=C:\MSSQL\Data
Set dir1=%CD%
set dbTemp=tempdb

cls
@echo on

Echo 
Echo Inicio del Proceso de Generaci�n de la Base de Datos y migraci�n de objetos y datos.
Echo
Echo Press CTRL-C to cancel u otra tecla para continuar
Echo

Pause

Echo "Inicio de Proceso"

rem Recuperaci�n BD ServicioPostal.

If Exist ServicioPostal.bak del ServicioPostal.bak

call "C:\Program Files\WinRAR\unrar.exe" e ServicioPostal.rar


rem Generacion de Base de datos y Tablas.

Call ".\1.- Tablas\mgrTablas.bat" %serv% %db% %dbTemp% %dir% %dir1% 

rem Generaci�n de Disparadores.

Call ".\2.- Triggers\mgrTriggers.bat" %serv% %db% 

rem Generac��n de Funciones

Call ".\3.- Funciones\mgrFunciones.bat"   %serv% %db% 

rem Generac��n de Procedimientos

Call ".\4.- Procedimientos Grales\mgrProcedimientosGral.bat" %serv% %db% 

rem Actualizaci�n de datos

Call ".\5.- Datos\mgrdatos.bat"                   %serv% %db% 


rem Actualizaci�n de datos a trav�s de la aplicaci�n de Scripts

Call ".\6.- Scripts\mgrScripts.bat"               %serv% %db% 

rem Reporte de Cargos y Abobos

Call ".\7.- Cargos y Abonos\cargosyabonos.bat" %serv% %db% 

rem Proceso de Saldos

Call ".\8.- Saldos\saldos.bat" %serv% %db% 

rem Proceso de env�o de correos

Call ".\9.- Envio de Correos\EnvioCorreos.bat" %serv% %db% 

rem Migraci�n de Procedimientos
 
Call ".\10.- Procedimientos\Procedimientos.bat" %serv% %db% 

rem Borra Bd ServicioPostal
 
osql -S  %serv% -d %dbTemp% -E -e -i Sp_BorraBd.sql                      > Sp_BorraBd.log

osql -S  %serv% -d %dbTemp% -E -e -Q "Drop Procedure dbo.Spp_BorraBd "   >  Borra_proc.log


rem Ajuste Cierre

Call ".\11.- Ajuste Cierre\Ajuste Cierre.bat" %serv% %db%

rem Validaciones de migraci�n

Call ".\12.- Validacion Migracion\mgrValidacion.bat" %serv% %db% 

rem Borrado del archivo de ServicioPostal

If Exist ServicioPostal.bak    del ServicioPostal.bak

If Exist ServicioPostal.rar    del ServicioPostal.rar


rem Borra archivos sql

If Exist sp_GeneraBd.sql       del sp_GeneraBd.sql
If Exist Sp_RecuperaBd.sql     del Sp_RecuperaBd.sql
If Exist sp_AsignaPermisos.sql del sp_AsignaPermisos.sql
If Exist Sp_BorraBd.sql        del Sp_BorraBd.sql


Echo "Fin de Proceso"