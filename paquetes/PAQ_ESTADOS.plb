create or replace package body PAQ_ESTADOS is

function inactivo return number is
begin
  return co_inactivo;
end inactivo;

function activo return number is
begin
  return co_activo;
end activo;

function cerrado return number is
begin
  return co_cerrado;
end cerrado;

end PAQ_ESTADOS;
