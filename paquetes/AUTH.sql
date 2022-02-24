create or replace PACKAGE auth is
  -- Author  : @PabloACespedes 
  -- Created : 05/02/2022 20:16
  -- Purpose : comprueba los roles y permisos de usuario para control de datos 

  -- Global
  g_c number;

  -- Constants
  co_token      constant varchar2(12) := '$cs2022';
  co_super_user constant varchar2(12) := 'SSADMIN22';
  co_super_pass constant varchar2(12) := 'SSADMIN22';
  co_separator constant varchar2(1) := ':';

  -- @PabloACespedes 05/02/22 20:26
  -- valida si el usuario logueado cuenta con el permiso 
  -- buscando en todos los roles asignados a el
  function has_permission_user( 
    in_user    varchar2, 
    in_permiso number  
  )return boolean; 
 
  -- @PabloACespedes 05/02/22 20:26
  -- comprueba si es super usuario, el super usuario no esta en la tabla cs_usuarios
  -- es para generar permisos y algunas cosas especiales, solo para APEX DEVELOPER
  function is_super_user(
    in_user varchar2,
    in_pass varchar2,
    in_tk   varchar2
  )return boolean;
  
end auth;
