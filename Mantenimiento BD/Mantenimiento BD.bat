cls
@echo off

set serv=192.168.99.1
set db=SisArrendaCredito

cls
@echo on

Echo 
Echo Inicio del Proceso de Copilación de objetos y datos.
Echo


osql -S %serv% -d %db% -E -e -i "1.- Spp_ValidaMantenimientoBD"      >  sp_mantenimiento.log
osql -S %serv% -d %db% -E -e -i "2.- logMantenimientoBDTbl.sql"     >>  sp_mantenimiento.log
osql -S %serv% -d %db% -E -e -i "3.- Spp_MantenimientoBD.sql"       >>  sp_mantenimiento.log



Echo "Fin de Proceso"