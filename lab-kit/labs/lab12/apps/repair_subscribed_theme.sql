prompt --application/repair_subscribed_theme
declare
  c_app_id            constant number := wwv_flow.g_flow_id;
  c_theme_source_app  constant number := 102;
  l_page_template     number;
  l_region_template   number;
  l_button_template   number;
  l_field_template    number;
  l_menu_template     number;
begin
  select default_page_template,
         default_region_template,
         default_button_template,
         default_label_template,
         default_menu_template
    into l_page_template,
         l_region_template,
         l_button_template,
         l_field_template,
         l_menu_template
    from apex_260100.wwv_flow_themes
   where flow_id = c_theme_source_app
     and theme_id = 42;

  update apex_260100.wwv_flows f
     set (theme_id,
          default_page_template, printer_friendly_template, default_region_template,
          default_label_template, default_report_template, default_list_template,
          default_menu_template, default_button_template, error_template,
          default_chart_template, default_reportr_template, default_form_template,
          default_wizard_template, default_menur_template, default_listr_template,
          default_irr_template, navigation_list_template_id, nav_bar_list_template_id) =
         (select theme_id,
                 default_page_template, printer_friendly_template, default_region_template,
                 default_label_template, default_report_template, default_list_template,
                 default_menu_template, default_button_template, error_template,
                 default_chart_template, default_reportr_template, default_form_template,
                 default_wizard_template, default_menur_template, default_listr_template,
                 default_irr_template, navigation_list_template_id, nav_bar_list_template_id
            from apex_260100.wwv_flows
           where id = c_theme_source_app)
   where f.id = c_app_id;

  update apex_260100.wwv_flow_themes t
     set (default_page_template, default_dialog_template, error_template, printer_friendly_template,
          login_template, default_button_template, default_region_template, default_chart_template,
          default_form_template, default_reportr_template, default_wizard_template, default_menur_template,
          default_listr_template, default_irr_template, default_report_template, default_label_template,
          default_menu_template, default_list_template, default_top_nav_list_template,
          default_side_nav_list_template, default_dialogbtnr_template, default_dialogr_template,
          default_option_label, default_required_label, default_nav_bar_list_template) =
         (select default_page_template, default_dialog_template, error_template, printer_friendly_template,
                 login_template, default_button_template, default_region_template, default_chart_template,
                 default_form_template, default_reportr_template, default_wizard_template, default_menur_template,
                 default_listr_template, default_irr_template, default_report_template, default_label_template,
                 default_menu_template, default_list_template, default_top_nav_list_template,
                 default_side_nav_list_template, default_dialogbtnr_template, default_dialogr_template,
                 default_option_label, default_required_label, default_nav_bar_list_template
            from apex_260100.wwv_flow_themes
           where flow_id = c_theme_source_app
             and theme_id = 42)
   where t.flow_id = c_app_id
     and t.theme_id = 42;

  update apex_260100.wwv_flow_steps s
     set step_template = l_page_template
   where flow_id = c_app_id
     and step_template is not null
     and not exists (
       select 1 from apex_260100.wwv_flow_templates x where x.id = s.step_template
     );

  update apex_260100.wwv_flow_page_plugs p
     set plug_template = l_region_template
   where flow_id = c_app_id
     and plug_template is not null
     and not exists (
       select 1 from apex_260100.wwv_flow_page_plug_templates x where x.id = p.plug_template
     );

  update apex_260100.wwv_flow_page_plugs p
     set menu_template_id = l_menu_template
   where flow_id = c_app_id
     and menu_template_id is not null
     and not exists (
       select 1 from apex_260100.wwv_flow_menu_templates x where x.id = p.menu_template_id
     );

  update apex_260100.wwv_flow_step_buttons b
     set button_template_id = l_button_template
   where flow_id = c_app_id
     and button_template_id is not null
     and not exists (
       select 1 from apex_260100.wwv_flow_button_templates x where x.id = b.button_template_id
     );

  update apex_260100.wwv_flow_step_items i
     set field_template = l_field_template
   where flow_id = c_app_id
     and field_template is not null
     and not exists (
       select 1 from apex_260100.wwv_flow_field_templates x where x.id = i.field_template
     );
end;
/
