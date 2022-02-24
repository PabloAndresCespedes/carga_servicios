create or replace package PAQ_ESTADOS is

/*
  @PabloACespedes 05/02/2022 20:42
  Libreria de estados para el sistema
  en base a la tabla CS_ESTADOS
*/

co_inactivo constant number := 0;
co_activo  constant number := 1;
co_carga  constant number := 2;
co_cerrado  constant number := 3;
co_anulado  constant number := 4;
 
function inactivo return number;
function activo return number;
function cerrado return number;

end PAQ_ESTADOS;
