set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback
alter session set container=ORCLPDB1;

declare
  l_src_app constant number := 101;
  l_dst_app constant number := 340;
  l_theme   constant number := 42;
  l_off     constant number := 340000000000000000;
  l_sgid    number;

  procedure clone_table(p_table varchar2) is
    l_cols varchar2(32767);
    l_expr varchar2(32767);
    l_sql  clob;
  begin
    select listagg(column_name, ',') within group(order by column_id),
           listagg(
             case
               when column_name = 'ID' then 's.ID + ' || l_off
               when column_name = 'FLOW_ID' then to_char(l_dst_app)
               when column_name = 'THEME_ID' then to_char(l_theme)
               when column_name = 'SECURITY_GROUP_ID' then to_char(l_sgid)
               when column_name = 'REFERENCE_ID' then 'NULL'
               when column_name in (
                 'PAGE_TEMPLATE_ID','REGION_TEMPLATE_ID','REPORT_TEMPLATE_ID','BREADCRUMB_TEMPLATE_ID',
                 'LIST_TEMPLATE_ID','FIELD_TEMPLATE_ID','BUTTON_TEMPLATE_ID','VIRTUAL_TEMPLATE_ID','GROUP_ID',
                 'DEFAULT_FIELD_TEMPLATE_ID','DEFAULT_REQ_FIELD_TEMPLATE_ID','DEFAULT_BUTTON_TEMPLATE_ID'
               ) then 'case when s.' || column_name || ' is null then null else s.' || column_name || ' + ' || l_off || ' end'
               else 's.' || column_name
             end, ',') within group(order by column_id)
      into l_cols, l_expr
      from dba_tab_cols
     where owner = 'APEX_260100'
       and hidden_column = 'NO'
       and virtual_column = 'NO'
       and table_name = upper(p_table);

    l_sql := 'insert into apex_260100.' || p_table || '(' || l_cols || ') select ' || l_expr ||
             ' from apex_260100.' || p_table || ' s where s.flow_id = :src and s.theme_id = :theme' ||
             ' and not exists (select 1 from apex_260100.' || p_table || ' d where d.flow_id = :dst and d.theme_id = :theme2 and nvl(d.static_id, chr(0)) = nvl(s.static_id, chr(0)))';
    execute immediate l_sql using l_src_app, l_theme, l_dst_app, l_theme;
    dbms_output.put_line(p_table || ': inserted ' || sql%rowcount || ' missing rows');
  end;

  procedure shift_ref(p_table varchar2, p_col varchar2) is
  begin
    execute immediate '
      update apex_260100.' || p_table || ' d
         set ' || p_col || ' = ' || p_col || ' + :off
       where flow_id = :dst
         and ' || p_col || ' in (
           select id from apex_260100.wwv_flow_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_page_plug_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_menu_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_button_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_field_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_list_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_row_templates where flow_id = :src and theme_id = :theme
         )'
      using l_off, l_dst_app, l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme,
            l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme;
  exception
    when others then
      dbms_output.put_line('WARN shift_ref skipped ' || p_table || '.' || p_col || ': ' || sqlerrm);
  end;

  procedure shift_ref_no_flow(p_table varchar2, p_col varchar2, p_where varchar2) is
  begin
    execute immediate '
      update apex_260100.' || p_table || ' d
         set ' || p_col || ' = ' || p_col || ' + :off
       where ' || p_where || '
         and ' || p_col || ' in (
           select id from apex_260100.wwv_flow_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_page_plug_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_menu_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_button_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_field_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_list_templates where flow_id = :src and theme_id = :theme
           union all select id from apex_260100.wwv_flow_row_templates where flow_id = :src and theme_id = :theme
         )'
      using l_off, l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme,
            l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme, l_src_app, l_theme;
  exception
    when others then
      dbms_output.put_line('WARN shift_ref skipped ' || p_table || '.' || p_col || ': ' || sqlerrm);
  end;
begin
  select security_group_id into l_sgid from apex_260100.wwv_flows where id = l_dst_app;

  clone_table('wwv_flow_templates');
  clone_table('wwv_flow_page_plug_templates');
  clone_table('wwv_flow_menu_templates');
  clone_table('wwv_flow_button_templates');
  clone_table('wwv_flow_field_templates');
  clone_table('wwv_flow_list_templates');
  clone_table('wwv_flow_row_templates');
  clone_table('wwv_flow_template_opt_groups');
  clone_table('wwv_flow_template_options');

  merge into apex_260100.wwv_flow_themes d
  using (select * from apex_260100.wwv_flow_themes where flow_id = l_src_app and theme_id = l_theme) s
     on (d.flow_id = l_dst_app and d.theme_id = l_theme)
   when matched then update set
        d.default_page_template = s.default_page_template + l_off,
        d.default_dialog_template = s.default_dialog_template + l_off,
        d.error_template = s.error_template + l_off,
        d.printer_friendly_template = s.printer_friendly_template + l_off,
        d.login_template = s.login_template + l_off,
        d.default_button_template = s.default_button_template + l_off,
        d.default_region_template = s.default_region_template + l_off,
        d.default_chart_template = s.default_chart_template + l_off,
        d.default_form_template = s.default_form_template + l_off,
        d.default_reportr_template = s.default_reportr_template + l_off,
        d.default_wizard_template = s.default_wizard_template + l_off,
        d.default_menur_template = s.default_menur_template + l_off,
        d.default_listr_template = s.default_listr_template + l_off,
        d.default_irr_template = s.default_irr_template + l_off,
        d.default_report_template = s.default_report_template + l_off,
        d.default_label_template = s.default_label_template + l_off,
        d.default_menu_template = s.default_menu_template + l_off,
        d.default_list_template = s.default_list_template + l_off,
        d.default_top_nav_list_template = s.default_top_nav_list_template + l_off,
        d.default_side_nav_list_template = s.default_side_nav_list_template + l_off,
        d.default_dialogbtnr_template = s.default_dialogbtnr_template + l_off,
        d.default_dialogr_template = s.default_dialogr_template + l_off,
        d.default_nav_bar_list_template = s.default_nav_bar_list_template + l_off,
        d.security_group_id = l_sgid;

  shift_ref_no_flow('wwv_flows', 'DEFAULT_PAGE_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'PRINTER_FRIENDLY_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_REGION_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_LABEL_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_REPORT_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_LIST_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_MENU_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_BUTTON_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'ERROR_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_CHART_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_REPORTR_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_FORM_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_WIZARD_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_MENUR_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_LISTR_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'DEFAULT_IRR_TEMPLATE', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'NAVIGATION_LIST_TEMPLATE_ID', 'id = ' || l_dst_app);
  shift_ref_no_flow('wwv_flows', 'NAV_BAR_LIST_TEMPLATE_ID', 'id = ' || l_dst_app);

  shift_ref('wwv_flow_steps', 'STEP_TEMPLATE');
  shift_ref('wwv_flow_steps', 'NAVIGATION_LIST_TEMPLATE_ID');
  shift_ref('wwv_flow_page_plugs', 'PLUG_TEMPLATE');
  shift_ref('wwv_flow_page_plugs', 'MENU_TEMPLATE_ID');
  shift_ref('wwv_flow_page_plugs', 'LIST_TEMPLATE_ID');
  shift_ref('wwv_flow_page_plugs', 'PLUG_QUERY_ROW_TEMPLATE');
  shift_ref('wwv_flow_page_plugs', 'PRN_TEMPLATE_ID');
  shift_ref('wwv_flow_step_buttons', 'BUTTON_TEMPLATE_ID');
  shift_ref('wwv_flow_step_items', 'ITEM_FIELD_TEMPLATE');
  shift_ref('wwv_flow_step_items', 'FIELD_TEMPLATE');
  shift_ref('wwv_flow_lists', 'DISPLAY_ROW_TEMPLATE_ID');
  shift_ref('wwv_flow_region_report_column', 'COLUMN_FIELD_TEMPLATE');

  update apex_260100.wwv_flows
     set theme_id = l_theme,
         theme_style_by_user_pref = 'N',
         last_updated_by = 'CODEX',
         last_updated_on = sysdate
   where id = l_dst_app;

  update apex_260100.wwv_flow_authentications
     set name = 'Oracle APEX Accounts',
         static_id = 'oracle-apex-accounts',
         scheme_type = 'NATIVE_APEX_ACCOUNTS',
         last_updated_by = 'CODEX',
         last_updated_on = sysdate
   where flow_id = l_dst_app;

  commit;
end;
/

select flow_id, count(*) page_templates from apex_260100.wwv_flow_templates where flow_id in (101,340) group by flow_id order by flow_id;
select flow_id, count(*) region_templates from apex_260100.wwv_flow_page_plug_templates where flow_id in (101,340) group by flow_id order by flow_id;
select flow_id, count(*) menu_templates from apex_260100.wwv_flow_menu_templates where flow_id in (101,340) group by flow_id order by flow_id;
exit
