Use msdb
Go

--
-- Programador: Pedro Zambrano
-- Fecha:       17-sep-2024.
-- Observaci�n: Script de Activaci�n del Servicio de env�o de correo.
--

sp_configure 'show advanced options', 1;
Go
Reconfigure;
Go
sp_configure 'Database Mail XPs', 1;
Go
Reconfigure
Go