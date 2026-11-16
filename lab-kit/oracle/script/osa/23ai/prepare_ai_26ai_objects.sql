set serveroutput on
whenever sqlerror exit failure rollback

begin
  raise_application_error(
    -20089,
    'Source-side analytics object creation is retired. Run /home/oracle/labs/lab18/lab18_init.sh from Base Linux to create Target SOE objects.'
  );
end;
/
