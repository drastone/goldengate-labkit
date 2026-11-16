prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2026.03.30'
,p_release=>'26.1.0'
,p_default_workspace_id=>3000124735735903
,p_default_application_id=>300
,p_default_id_offset=>20610667115406633
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - DS Databricks Retention Ops
--
-- Application Export:
--   Application:     300
--   Name:            DS Databricks Retention Ops
--   Date and Time:   02:48 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      8
--       Items:                    2
--       Processes:                2
--       Regions:                 13
--       Buttons:                  1
--     Shared Components:
--       Logic:
--       Navigation:
--         Lists:                  2
--         Breadcrumbs:            1
--           Entries:              6
--       Security:
--         Authentication:         1
--       User Interface:
--         Themes:                 1
--         Templates:
--       PWA:
--       Globalization:
--       Reports:
--       E-Mail:
--     Supporting Objects:  Included
--   Version:         26.1.0
--   Instance ID:     746093091029900
--

prompt --application/delete_application
begin
wwv_flow_imp.remove_flow(wwv_flow.g_flow_id);
end;
/
prompt --application/create_application
begin
wwv_imp_workspace.create_flow(
 p_id=>wwv_flow.g_flow_id
,p_owner=>nvl(wwv_flow_application_install.get_schema,'GGADMIN')
,p_name=>nvl(wwv_flow_application_install.get_application_name,'DS Databricks Retention Ops')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'DS-DATABRICKS-RETENTION')
,p_page_view_logging=>'YES'
,p_page_protection_enabled_y_n=>'Y'
,p_checksum_salt=>'3000A1B2C3D4E5F60718293A4B5C6D7E8F9011223344556677889900AABBCC00'
,p_bookmark_checksum_function=>'SH512'
,p_compatibility_mode=>'21.2'
,p_accessible_read_only=>'N'
,p_session_state_commits=>'IMMEDIATE'
,p_flow_language=>'ko'
,p_flow_language_derived_from=>'FLOW_PRIMARY_LANGUAGE'
,p_date_format=>'YYYY-MM-DD'
,p_timestamp_format=>'YYYY-MM-DD HH24:MI:SS'
,p_timestamp_tz_format=>'YYYY-MM-DD HH24:MI:SS TZH:TZM'
,p_direction_right_to_left=>'N'
,p_flow_image_prefix=>nvl(wwv_flow_application_install.get_image_prefix,'')
,p_authentication_id=>wwv_flow_imp.id(3000000001000000)
,p_application_tab_set=>1
,p_logo_type=>'T'
,p_logo_text=>'Databricks Retention Ops'
,p_public_user=>'APEX_PUBLIC_USER'
,p_proxy_server=>nvl(wwv_flow_application_install.get_proxy,'')
,p_no_proxy_domains=>nvl(wwv_flow_application_install.get_no_proxy_domains,'')
,p_flow_version=>'1.0'
,p_flow_status=>'AVAILABLE_W_EDIT_LINK'
,p_browser_cache=>'N'
,p_browser_frame=>'D'
,p_deep_linking=>'Y'
,p_runtime_api_usage=>'T'
,p_pass_ecid=>'N'
,p_authorize_batch_job=>'N'
,p_rejoin_existing_sessions=>'N'
,p_csv_encoding=>'Y'
,p_modernization_available=>'Y'
,p_file_prefix=>nvl(wwv_flow_application_install.get_static_app_file_prefix,'')
,p_files_version=>1
,p_version_scn=>'79144736'
,p_print_server_type=>'INSTANCE'
,p_file_storage=>'DB'
,p_is_pwa=>'N'
,p_theme_id=>42
,p_home_url=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_login_url=>'f?p=&APP_ID.:9999:&APP_SESSION.::&DEBUG.:::'
,p_theme_style_by_user_pref=>false
,p_global_page_id=>0
,p_navigation_list_id=>wwv_flow_imp.id(3000000002000000)
,p_navigation_list_position=>'SIDE'
,p_navigation_list_template_id=>wwv_flow_imp.id(141223810028887240662)
,p_nav_list_template_options=>'#DEFAULT#:js-defaultCollapsed:js-navCollapsed--hidden:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(141223809658759240662)
,p_nav_bar_template_options=>'#DEFAULT#'
);
end;
/
prompt --application/plugin_settings
begin
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532026860643836)
,p_plugin_type=>'DYNAMIC ACTION'
,p_plugin=>'NATIVE_OPEN_AI_ASSISTANT'
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531658250643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_COLOR_PICKER'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'mode', 'FULL')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532198313643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_DATE_PICKER_APEX'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'appearance_behavior', 'MONTH-PICKER:YEAR-PICKER:TODAY-BUTTON',
  'days_outside_month', 'VISIBLE',
  'show_on', 'FOCUS',
  'time_increment', '15')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532267851643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_GEOCODED_ADDRESS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'background', 'default',
  'display_as', 'LIST',
  'map_preview', 'POPUP:ITEM',
  'match_mode', 'RELAX_HOUSE_NUMBER')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531540395643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_SELECT_MANY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_values_as', 'separated')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532788135643837)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_SINGLE_CHECKBOX'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'checked_value', 'Y',
  'unchecked_value', 'N')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531768838643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_STAR_RATING'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'default_icon', 'fa-star',
  'tooltip', '#VALUE#')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531856236643836)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_YES_NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_style', 'SWITCH_CB',
  'off_value', 'N',
  'on_value', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532672969643836)
,p_plugin_type=>'PROCESS TYPE'
,p_plugin=>'NATIVE_GEOCODING'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'match_mode', 'RELAX_HOUSE_NUMBER')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531980921643836)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_DISPLAY_SELECTOR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'include_slider', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11531451861643836)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_IR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'actions_menu_structure', 'IG')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532311479643836)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_MAP_REGION'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'use_vector_tile_layers', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532530539643836)
,p_plugin_type=>'WEB SOURCE TYPE'
,p_plugin=>'NATIVE_ADFBC'
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(11532462285643836)
,p_plugin_type=>'WEB SOURCE TYPE'
,p_plugin=>'NATIVE_BOSS'
);
end;
/
prompt --application/shared_components/navigation/lists/navigation_bar
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(3000000003000000)
,p_name=>'Navigation Bar'
,p_static_id=>'nav-bar-ins300'
,p_version_scn=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000003000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B85C\ADF8\C544\C6C3')
,p_static_id=>'nav-logout'
,p_list_item_link_target=>'f?p=&APP_ID.:9999:&SESSION.:LOGOUT::::'
,p_list_item_icon=>'fa-sign-out'
,p_list_item_current_type=>'TARGET_PAGE'
);
end;
/
prompt --application/shared_components/navigation/lists/navigation_menu
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(3000000002000000)
,p_name=>'Navigation Menu'
,p_static_id=>'nav-menu-ins300'
,p_version_scn=>'SH256:1InO4cPIboR1bj8Dcgj935NKNHB_r73rViIMMhxkPcA'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000005)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('\C870\CE58 \C6CC\D06C\BCA4\CE58')
,p_static_id=>'nav-cancel'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-tasks'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'40'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000002)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\ACE0\AC1D \C704\D5D8 \D050')
,p_static_id=>'nav-customers'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-users'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'10'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('Retention \C0C1\D669\D310')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000004)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('\BAA8\B378 \C124\BA85')
,p_static_id=>'nav-fund'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-search'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'30'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000006)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>unistr('Databricks \C5F0\B3D9\C0C1\D0DC')
,p_static_id=>'nav-products'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-database'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'50'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000003)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778')
,p_static_id=>'nav-transactions'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-bullhorn'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'20'
);
end;
/
prompt --application/shared_components/navigation/listentry
begin
null;
end;
/
prompt --application/shared_components/navigation/navigation_bar
begin
null;
end;
/
prompt --application/shared_components/logic/application_settings
begin
null;
end;
/
prompt --application/shared_components/navigation/tabs/standard
begin
null;
end;
/
prompt --application/shared_components/navigation/tabs/parent
begin
null;
end;
/
prompt --application/pages/page_groups
begin
null;
end;
/
prompt --application/shared_components/navigation/breadcrumbs/breadcrumb
begin
wwv_flow_imp_shared.create_menu(
 p_id=>wwv_flow_imp.id(3000000004000000)
,p_name=>'Breadcrumb'
,p_static_id=>'breadcrumb300'
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000005)
,p_short_name=>unistr('\D574\C57D \BD84\C11D')
,p_static_id=>'bc-cancel'
,p_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
,p_page_id=>40
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000002)
,p_short_name=>unistr('\ACE0\AC1D \D604\D669')
,p_static_id=>'bc-customers'
,p_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
,p_page_id=>10
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000001)
,p_short_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'bc-dashboard'
,p_link=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000004)
,p_short_name=>unistr('\C801\B9BD\AE08/\D380\B4DC \D604\D669')
,p_static_id=>'bc-fund'
,p_link=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
,p_page_id=>30
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000006)
,p_short_name=>unistr('\C0C1\D488 \D604\D669')
,p_static_id=>'bc-products'
,p_link=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:::'
,p_page_id=>50
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(3000000004000003)
,p_short_name=>unistr('\AC70\B798/\B0A9\C785 \D604\D669')
,p_static_id=>'bc-transactions'
,p_link=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
,p_page_id=>20
);
end;
/
prompt --application/shared_components/navigation/breadcrumbentry
begin
null;
end;
/
prompt --application/shared_components/user_interface/themes
begin
wwv_flow_imp_shared.create_theme(
 p_id=>wwv_flow_imp.id(3000000099000001)
,p_theme_id=>42
,p_static_id=>'universal-theme'
,p_theme_name=>'Universal Theme'
,p_theme_internal_name=>'UNIVERSAL_THEME'
,p_version_identifier=>'24.1'
,p_navigation_type=>'L'
,p_nav_bar_type=>'LIST'
,p_is_locked=>false
,p_current_theme_style_id=>wwv_flow_imp.id(3000000099000010)
,p_default_page_template=>wwv_flow_imp.id(141223573396009240514)
,p_default_dialog_template=>wwv_flow_imp.id(141223571896574240512)
,p_error_template=>wwv_flow_imp.id(141223565295473240507)
,p_printer_friendly_template=>wwv_flow_imp.id(141223573396009240514)
,p_login_template=>wwv_flow_imp.id(141223565295473240507)
,p_default_button_template=>wwv_flow_imp.id(141223815667107240679)
,p_default_region_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_chart_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_form_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_reportr_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_wizard_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_menur_template=>wwv_flow_imp.id(141223727136948240578)
,p_default_listr_template=>wwv_flow_imp.id(141223714706791240565)
,p_default_irr_template=>wwv_flow_imp.id(141223712607631240563)
,p_default_report_template=>wwv_flow_imp.id(141223774230992240620)
,p_default_label_template=>wwv_flow_imp.id(141223814870955240675)
,p_default_menu_template=>wwv_flow_imp.id(141223817346165240682)
,p_default_list_template=>wwv_flow_imp.id(141223803016455240654)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(141223811825744240666)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(141223810028887240662)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(141223732306410240581)
,p_default_dialogr_template=>wwv_flow_imp.id(141223582136348240533)
,p_default_option_label=>wwv_flow_imp.id(141223814870955240675)
,p_default_required_label=>wwv_flow_imp.id(141223814387970240674)
,p_default_navbar_list_template=>wwv_flow_imp.id(141223809658759240662)
,p_file_prefix=>nvl(wwv_flow_application_install.get_static_theme_file_prefix(42),'#APEX_FILES#themes/theme_42/24.1/')
,p_files_version=>65
,p_icon_library=>'FONTAPEX'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APEX_FILES#libraries/apex/#MIN_DIRECTORY#widget.stickyWidget#MIN#.js?v=#APEX_VERSION#',
'#THEME_FILES#js/theme42#MIN#.js?v=#APEX_VERSION#'))
,p_css_file_urls=>'#THEME_FILES#css/Core#MIN#.css?v=#APEX_VERSION#'
,p_reference_id=>wwv_imp_util.get_subscription_id(4070917134413059350,2000,'universal-theme',8842)
);
end;
/
prompt --application/shared_components/user_interface/theme_style
begin
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(3000000099000010)
,p_theme_id=>42
,p_name=>'Redwood Light'
,p_static_id=>'redwood-light'
,p_css_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APEX_FILES#libraries/oracle-fonts/oraclesans-apex#MIN#.css?v=#APEX_VERSION#',
'#THEME_FILES#css/Redwood#MIN#.css?v=#APEX_VERSION#'))
,p_is_public=>true
,p_is_accessible=>false
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Redwood-Theme.less'
,p_theme_roller_output_file_url=>'#THEME_FILES#css/Redwood-Theme#MIN#.css?v=#APEX_VERSION#'
,p_theme_roller_read_only=>true
,p_reference_id=>wwv_imp_util.get_subscription_id(2596426436825065489,2010,'redwood-light',8842,null,'universal-theme')
);
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(3000000099000011)
,p_theme_id=>42
,p_name=>'Vita'
,p_static_id=>'vita'
,p_is_public=>true
,p_is_accessible=>true
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Vita.less'
,p_theme_roller_output_file_url=>'#THEME_FILES#css/Vita#MIN#.css?v=#APEX_VERSION#'
,p_theme_roller_read_only=>true
,p_reference_id=>wwv_imp_util.get_subscription_id(2719875314571594493,2010,'vita',8842,null,'universal-theme')
);
end;
/
prompt --application/shared_components/user_interface/theme_files
begin
null;
end;
/
prompt --application/shared_components/user_interface/template_opt_groups
begin
null;
end;
/
prompt --application/shared_components/user_interface/template_options
begin
null;
end;
/
prompt --application/shared_components/globalization/language
begin
null;
end;
/
prompt --application/shared_components/globalization/translations
begin
null;
end;
/
prompt --application/shared_components/logic/build_options
begin
null;
end;
/
prompt --application/shared_components/globalization/messages
begin
null;
end;
/
prompt --application/shared_components/globalization/dyntranslations
begin
null;
end;
/
prompt --application/shared_components/security/authentications/apex_accounts
begin
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(3000000001000000)
,p_name=>'APEX Accounts'
,p_static_id=>'apex-accounts-ins300'
,p_scheme_type=>'NATIVE_CUSTOM'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'authentication_function', 'login',
  'enable_legacy_attributes', 'N')).to_clob
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function login (',
'    p_username in varchar2,',
'    p_password in varchar2 )',
'    return boolean',
'is',
'begin',
'    return apex_util.is_login_password_valid (',
'        p_username => upper(p_username),',
'        p_password => p_password );',
'end login;'))
,p_invalid_session_type=>'LOGIN'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>'1'
);
end;
/
prompt --application/user_interfaces/combined_files
begin
null;
end;
/
prompt --application/pages/page_00000
begin
wwv_flow_imp_page.create_page(
 p_id=>0
,p_name=>'Global Page'
,p_reload_on_submit=>null
,p_warn_on_unsaved_changes=>null
,p_autocomplete_on_off=>'OFF'
,p_protection_level=>'D'
,p_page_component_map=>'14'
);
end;
/
prompt --application/pages/page_00001
begin
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>unistr('Retention \C0C1\D669\D310')
,p_alias=>'RETENTION-DASHBOARD'
,p_step_title=>unistr('Retention \C0C1\D669\D310')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'06'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000002)
,p_plug_name=>unistr('Retention \C0C1\D669\D310')
,p_static_id=>unistr('\D575\C2EC-kpi')
,p_title=>unistr('Retention \C0C1\D669\D310')
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="dashboard">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">Retention \C0C1\D669\D310</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
,p_plug_query_headings_type=>'COLON_DELMITED_LIST'
,p_plug_query_num_rows=>6
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_plug_query_no_data_found=>unistr('\B370\C774\D130 \C5C6\C74C')
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\ACE0\AC1D \C704\D5D8 \D050')
,p_alias=>'CUSTOMER-RISK-QUEUE'
,p_step_title=>unistr('\ACE0\AC1D \C704\D5D8 \D050')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000002)
,p_plug_name=>unistr('\ACE0\AC1D \C704\D5D8 \D050')
,p_static_id=>unistr('\C131\BCC4-\C5F0\B839\BCC4-\ACE0\AC1D-\BD84\D3EC')
,p_title=>unistr('\ACE0\AC1D \C704\D5D8 \D050')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="queue">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">\ACE0\AC1D \C704\D5D8 \D050</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>unistr('\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778')
,p_alias=>'SEGMENT-CAMPAIGNS'
,p_step_title=>unistr('\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000002)
,p_plug_name=>unistr('\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778')
,p_static_id=>unistr('\AC70\B798-\C720\D615\BCC4-\BD84\D3EC')
,p_title=>unistr('\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="segments">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('\BAA8\B378 \C124\BA85')
,p_alias=>'MODEL-EXPLAINABILITY'
,p_step_title=>unistr('\BAA8\B378 \C124\BA85')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000002)
,p_plug_name=>unistr('\BAA8\B378 \C124\BA85')
,p_static_id=>unistr('\D380\B4DC\BCC4-\CD1D-\C801\B9BD\AE08-\CD5C\ADFC-\AE30\C900\C77C')
,p_title=>unistr('\BAA8\B378 \C124\BA85')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="explain">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">\BAA8\B378 \C124\BA85</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
);
end;
/
prompt --application/pages/page_00040
begin
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>unistr('\C870\CE58 \C6CC\D06C\BCA4\CE58')
,p_alias=>'ACTION-WORKBENCH'
,p_step_title=>unistr('\C870\CE58 \C6CC\D06C\BCA4\CE58')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000002)
,p_plug_name=>unistr('\C870\CE58 \C6CC\D06C\BCA4\CE58')
,p_static_id=>unistr('\D574\C57D-\D604\D669-\C694\C57D')
,p_title=>unistr('\C870\CE58 \C6CC\D06C\BCA4\CE58')
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="actions">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">\C870\CE58 \C6CC\D06C\BCA4\CE58</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
,p_plug_query_headings_type=>'COLON_DELMITED_LIST'
,p_plug_query_num_rows=>4
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_plug_query_no_data_found=>unistr('\D574\C57D \B370\C774\D130 \C5C6\C74C')
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
);
end;
/
prompt --application/pages/page_00050
begin
wwv_flow_imp_page.create_page(
 p_id=>50
,p_name=>unistr('Databricks \C5F0\B3D9\C0C1\D0DC')
,p_alias=>'DATABRICKS-LINEAGE'
,p_step_title=>unistr('Databricks \C5F0\B3D9\C0C1\D0DC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141223573396009240514)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141223727136948240578)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141223817346165240682)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000002)
,p_plug_name=>unistr('Databricks \C5F0\B3D9\C0C1\D0DC')
,p_static_id=>unistr('\C0C1\D488-\CE74\D14C\ACE0\B9AC-\BD84\D3EC')
,p_title=>unistr('Databricks \C5F0\B3D9\C0C1\D0DC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141223714706791240565)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
' <style>',
' html .dbx-wrap{min-height:calc(100vh - 165px);background:#f6f7f9;color:#1f2833;font-family:Inter,Arial,sans-serif}',
' .dbx-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 16px;background:#fff;border-bottom:1px solid #d8dee8}.dbx-title{font-size:20px;font-weight:760}.dbx-status{display:flex;align-items:center;gap:8px;font-siz'
||'e:12px;color:#627083;margin-top:3px}.dbx-dot{width:9px;height:9px;border-radius:50%;background:#9aa6b2}.dbx-dot.ok{background:#168a5b}.dbx-dot.warn{background:#b87914}.dbx-actions{display:flex;gap:8px}.dbx-btn{height:34px;border:1px solid #aab8c7;bac'
||'kground:#fff;color:#223043;border-radius:6px;padding:0 11px;cursor:pointer}.dbx-btn.primary{background:#25645f;border-color:#25645f;color:#fff}.dbx-btn:disabled{opacity:.55;cursor:wait}',
' .dbx-main{padding:14px 16px;display:grid;gap:12px}.dbx-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.dbx-kpi{background:#fff;border:1px solid #d8dee8;border-radius:8px;padding:12px;min-height:86px}.dbx-kpi-label{font-'
||'size:12px;color:#627083}.dbx-kpi-value{font-size:24px;font-weight:760;margin-top:6px;white-space:nowrap}.dbx-kpi-sub{font-size:12px;color:#6e7b8d;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
' .dbx-grid{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(340px,.9fr);gap:12px}.dbx-panel{background:#fff;border:1px solid #d8dee8;border-radius:8px;min-width:0}.dbx-panel-h{height:43px;display:flex;align-items:center;justify-content:spac'
||'e-between;padding:0 12px;border-bottom:1px solid #e3e8ef;font-weight:720}.dbx-panel-b{padding:12px;overflow:auto}.dbx-table{width:100%;border-collapse:collapse;font-size:13px}.dbx-table th,.dbx-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1'
||';text-align:left;vertical-align:top}.dbx-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfd;position:sticky;top:0}.dbx-num{text-align:right}.dbx-mini{font-size:12px;color:#687789}.dbx-badge{display:inline-flex;align-ite'
||'ms:center;justify-content:center;min-width:38px;height:22px;border-radius:999px;font-size:12px;font-weight:740;border:1px solid #cad4df;background:#f3f6fa}.dbx-badge.p1{color:#a01d25;background:#fff1f1;border-color:#ffc9ce}.dbx-badge.p2{color:#85530d'
||';background:#fff7e6;border-color:#f0d09a}.dbx-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}.dbx-badge.done{color:#255c3f;background:#e9f8ef;border-color:#baddc9}.dbx-badge.work{color:#25517a;background:#eef6ff;border-color:#c5dbf2}',
' .dbx-bars{display:grid;gap:8px}.dbx-bar{display:grid;grid-template-columns:122px minmax(120px,1fr) 92px;gap:8px;align-items:center;font-size:13px}.dbx-bar-track{height:11px;border-radius:999px;background:#e5ebf1;overflow:hidden}.dbx-bar-fill{height:'
||'11px;border-radius:999px;background:linear-gradient(90deg,#25645f,#416fa8)}.dbx-driver{display:grid;gap:10px}.dbx-driver-row{display:grid;grid-template-columns:145px minmax(150px,1fr) 70px;gap:9px;align-items:center;font-size:13px}.dbx-sql{white-spac'
||'e:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#111923;color:#dce7f3;border-radius:8px;padding:12px;overflow:auto}.dbx-loader{height:190px;display:flex;align-items:center;justify-content:center;colo'
||'r:#667588}.dbx-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.dbx-stack{display:grid;gap:12px}.dbx-action-row{display:flex;gap:6px;flex-wrap:wrap}.dbx-pill{display:inline-flex;align-items:center;height'
||':24px;border-radius:999px;background:#edf1f6;color:#526173;padding:0 9px;font-size:12px} @media(max-width:900px){.dbx-kpis{grid-template-columns:repeat(2,minmax(0,1fr))}.dbx-grid{grid-template-columns:1fr}.dbx-head{align-items:flex-start;flex-directi'
||'on:column}.dbx-bar,.dbx-driver-row{grid-template-columns:96px minmax(100px,1fr) 72px}.dbx-title{font-size:18px}}',
' </style>',
' <div class="dbx-wrap" id="dbxApp" data-view="lineage">',
'   <div class="dbx-head">',
unistr('     <div><div class="dbx-title">Databricks \C5F0\B3D9\C0C1\D0DC</div><div class="dbx-status"><span id="dbxDot" class="dbx-dot"></span><span id="dbxStatus">connecting</span></div></div>'),
'     <div class="dbx-actions"><button type="button" class="dbx-btn" id="dbxSql">SQL</button><button type="button" class="dbx-btn primary" id="dbxRefresh">Refresh</button></div>',
'   </div>',
'   <div class="dbx-main" id="dbxMain"><div class="dbx-loader">Loading Databricks signals...</div></div>',
' </div>',
' <script>',
' (function(){',
'   var root=document.getElementById(''dbxApp''); if(!root){return;}',
'   var view=root.getAttribute(''data-view'');',
'   var main=document.getElementById(''dbxMain'');',
'   var status=document.getElementById(''dbxStatus'');',
'   var dot=document.getElementById(''dbxDot'');',
'   var refresh=document.getElementById(''dbxRefresh'');',
'   var sqlBtn=document.getElementById(''dbxSql'');',
'   var apiBase=localStorage.getItem(''databricksRetentionProxy'') || ''http://localhost:38200'';',
'   var actionState=JSON.parse(localStorage.getItem(''dbxActionState'')||''{}'');',
'   function saveState(){localStorage.setItem(''dbxActionState'',JSON.stringify(actionState));}',
'   function setStatus(text,kind){status.textContent=text;dot.className=''dbx-dot ''+(kind||'''');}',
'   function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'   function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('   function money(v){var n=Number(v||0);if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';}return n.toLocaleString(''ko-KR'');}'),
'   function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'   function kpi(label,value,sub){return ''<div class="dbx-kpi"><div class="dbx-kpi-label">''+esc(label)+''</div><div class="dbx-kpi-value">''+value+''</div><div class="dbx-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'   function panel(title,body,right){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(title)+''</span><span class="dbx-mini">''+esc(right||'''')+''</span></div><div class="dbx-panel-b">''+body+''</div></section>'';}',
'   function badge(v){var p=String(v||''P3'');return ''<span class="dbx-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}',
'   function statusBadge(cust,statusText){var s=actionState[cust]||statusText||''READY'';var cls=s===''DONE''?''done'':(s===''IN_PROGRESS''?''work'':'''');return ''<span class="dbx-badge ''+cls+''">''+esc(s)+''</span>'';}',
'   function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="dbx-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);retur'
||'n ''<div class="dbx-bar"><div>''+esc(r[labelKey])+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'   function drivers(rows){var max=rows.reduce(function(m,r){return Math.max(m,Math.abs(Number(r.contribution||0)));},0)||1;return ''<div class="dbx-driver">''+rows.map(function(r){var w=pct(Math.abs(Number(r.contribution||0))*100/max);return ''<div clas'
||'s="dbx-driver-row"><div>''+esc(r.feature_name)+''</div><div class="dbx-bar-track"><div class="dbx-bar-fill" style="width:''+w+''%"></div></div><div class="dbx-num">''+Number(r.contribution||0).toFixed(3)+''</div><div class="dbx-mini" style="grid-column:1 /'
||' -1">''+esc(r.explanation||'''')+''</div></div>'';}).join('''')+''</div>'';}',
'   function tableHtml(cols,rows){return ''<table class="dbx-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="dbx-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(fun'
||'ction(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="dbx-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
unistr('   function queueCols(includeAction){var cols=[{label:''\B4F1\AE09'',value:function(r){return badge(r.risk_tier);}},{label:''\ACE0\AC1D'',value:function(r){return esc(r.customer_name)+''<div class="dbx-mini">#''+esc(r.cust_id)+'' \00B7 ''+esc(r.segment_name)+''</div>'';}},'),
unistr('     {label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''30\C77C \C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_30d_outflow);}},{label:''\D574\C9C0\D655\B960'',num:true,value:function(r){return fmt(r.lapse_probability_pct)+''%'';}},'),
unistr('     {label:''\C8FC\C694 \C6D0\C778'',key:''dominant_driver''},{label:''\CD94\CC9C \C870\CE58'',key:''recommended_action''},{label:''\B2F4\B2F9'',key:''action_owner''},{label:''\C0C1\D0DC'',value:function(r){return statusBadge(r.cust_id,r.action_status);}}];'),
unistr('     if(includeAction){cols.push({label:''\CC98\B9AC'',value:function(r){return ''<div class="dbx-action-row"><button type="button" class="dbx-btn" data-act="IN_PROGRESS" data-cust="''+esc(r.cust_id)+''">\C811\C218</button><button type="button" class="dbx-btn primary" da')
||unistr('ta-act="DONE" data-cust="''+esc(r.cust_id)+''">\C644\B8CC</button></div>'';}});}'),
'     return cols;',
'   }',
unistr('   function segmentCols(){return [{label:''\C138\ADF8\BA3C\D2B8'',key:''segment_name''},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customer_count);}},{label:''P1'',num:true,value:function(r){return fmt(r.p1_count);}},{label:''P2'',num:true,value:function(r){return')
||unistr(' fmt(r.p2_count);}},{label:''\D3C9\ADE0\C704\D5D8'',num:true,value:function(r){return fmt(r.avg_risk_score);}},{label:''\C720\CD9C\C608\CE21'',num:true,value:function(r){return money(r.predicted_outflow);}},{label:''\C804\D658\AE30\D68C'',num:true,value:function(r){return money(r.conversion_opportunity)')
||unistr(';}},{label:''\CEA0\D398\C778'',key:''recommended_campaign''}];}'),
'   function fetchView(name){setStatus(''loading'',''warn'');refresh.disabled=true;return fetch(apiBase+''/api/view/''+name).then(function(r){return r.json();}).then(function(j){if(!j.ok){throw new Error(j.error||''Databricks proxy error'');}setStatus((j.mode'
||unistr('||''live'')+'' \00B7 ''+(j.status||''ready''),''ok'');return j;}).finally(function(){refresh.disabled=false;});}'),
'   function onError(e){main.innerHTML=''<div class="dbx-error">''+esc(e.message||e)+''<br>proxy ''+esc(apiBase)+''</div>'';setStatus(''proxy unavailable'',''warn'');}',
'   function bindActions(){main.querySelectorAll(''button[data-act]'').forEach(function(b){b.onclick=function(){actionState[this.getAttribute(''data-cust'')]=this.getAttribute(''data-act'');saveState();loadActions();};});}',
unistr('   function loadDashboard(){fetchView(''dashboard'').then(function(j){var q=j.queue||[], seg=j.segments||[], b=j.batch||{};main.innerHTML=''<div class="dbx-kpis">''+kpi(''P1 \ACE0\AC1D'',fmt(j.kpis.p1_count),''P2 ''+fmt(j.kpis.p2_count))+kpi(''30\C77C \C720\CD9C\C608\CE21'',money(j.kpis.')
||unistr('predicted_outflow),''scored ''+fmt(j.kpis.signal_row_count)+'' rows'')+kpi(''Model AUC'',Number(j.kpis.auc_score||0).toFixed(3),b.model_version||'''')+kpi(''Freshness'',fmt(j.kpis.freshness_minutes)+''\BD84'',b.databricks_object||'''')+''</div><div class="dbx-grid">''+p')
||unistr('anel(''\ACE0\AC1D \C704\D5D8 Top'',tableHtml(queueCols(false),q.slice(0,8)),''Databricks scoring'')+panel(''\C138\ADF8\BA3C\D2B8 \C720\CD9C\C608\CE21'',bars(seg,''segment_name'',''predicted_outflow''),''campaign'')+''</div><div class="dbx-grid">''+panel(''\BAA8\B378 \C8FC\C694 \C124\BA85'',drivers(j.features||[]),''global'')+panel(''Databr')
||'icks Batch'',''<div class="dbx-stack">''+kpi(''Batch'',esc(b.batch_id||''-''),b.status||'''')+kpi(''Model'',esc(b.model_name||''-''),b.scoring_finished_at||'''')+kpi(''Source'',esc(b.source_system||''-''),b.source_snapshot_ts||'''')+''</div>'',''lakehouse'')+''</div>'';}).catc'
||'h(onError);}',
unistr('   function loadQueue(){fetchView(''queue'').then(function(j){main.innerHTML=panel(''\ACE0\AC1D \C704\D5D8 \D050'',tableHtml(queueCols(false),j.queue||[]),''P1/P2 priority'');}).catch(onError);}'),
unistr('   function loadSegments(){fetchView(''segments'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''\C138\ADF8\BA3C\D2B8 \CEA0\D398\C778'',tableHtml(segmentCols(),j.segments||[]),''Databricks aggregate'')+panel(''\C804\D658\AE30\D68C'',bars(j.segments||[],''segment_name'',''conversion_opp')
||'ortunity''),''expected value'')+''</div>'';}).catch(onError);}',
unistr('   function loadExplain(){fetchView(''explain'').then(function(j){main.innerHTML=''<div class="dbx-grid">''+panel(''Global Feature Contribution'',drivers(j.features||[]),''model'')+panel(''\B300\D45C P1 \ACE0\AC1D \C124\BA85'',tableHtml([{label:''Feature'',key:''feature_name''},{label:''V')
||'alue'',key:''feature_value''},{label:''Contribution'',num:true,value:function(r){return Number(r.contribution||0).toFixed(3);}},{label:''Explanation'',key:''explanation''}],j.customer_features||[]),''customer #''+esc(j.customer_id||''''))+''</div>'';}).catch(onErro'
||'r);}',
unistr('   function loadActions(){fetchView(''actions'').then(function(j){main.innerHTML=panel(''\C870\CE58 \C6CC\D06C\BCA4\CE58'',tableHtml(queueCols(true),j.queue||[]),''local action state'');bindActions();}).catch(onError);}'),
'   function loadLineage(){fetchView(''lineage'').then(function(j){var line=(j.lineage||[]).map(function(x){return ''<div><span class="dbx-pill">''+esc(x.step)+''</span> ''+esc(x.name)+''<div class="dbx-mini">''+esc(x.detail||'''')+''</div></div>'';}).join('''');va'
||'r sql=(j.sql||[]).map(function(s){return ''<section class="dbx-panel"><div class="dbx-panel-h"><span>''+esc(s.name)+''</span></div><div class="dbx-panel-b"><pre class="dbx-sql">''+esc(s.statement)+''</pre></div></section>'';}).join('''');main.innerHTML=''<div'
||' class="dbx-grid">''+panel(''Lineage'',line,''OGG to Databricks to APEX'')+panel(''Connection'',tableHtml([{label:''Key'',key:''key''},{label:''Value'',key:''value''}],j.connection||[]),''proxy'')+''</div><div class="dbx-stack">''+sql+''</div>'';}).catch(onError);}',
'   var loaders={dashboard:loadDashboard,queue:loadQueue,segments:loadSegments,explain:loadExplain,actions:loadActions,lineage:loadLineage};',
'   refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'   sqlBtn.onclick=loadLineage;',
'   (loaders[view]||loadDashboard)();',
' })();',
' </script>',
' '))
);
end;
/
prompt --application/pages/page_09999
begin
wwv_flow_imp_page.create_page(
 p_id=>9999
,p_name=>unistr('\B85C\ADF8\C778')
,p_alias=>'LOGIN'
,p_step_title=>unistr('\B85C\ADF8\C778')
,p_warn_on_unsaved_changes=>'N'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'',
''))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'/* codex-login-spacing */',
'.t-Login-region .t-Form-fieldContainer,',
'.t-Login-container .t-Form-fieldContainer {',
'  margin-bottom: .75rem;',
'}',
'.t-Login-region .t-Form-labelContainer,',
'.t-Login-container .t-Form-labelContainer {',
'  padding-right: .85rem;',
'}',
''))
,p_step_template=>wwv_flow_imp.id(141223565295473240507)
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'12'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000009999000001)
,p_plug_name=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C')
,p_static_id=>unistr('\BCF4\D5D8-\C815\BCF4\ACC4-\C2DC\C2A4\D15C')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141223757353352240602)
,p_plug_display_sequence=>10
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(3000009999000004)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(3000009999000001)
,p_button_name=>'LOGIN'
,p_static_id=>'login'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('\B85C\ADF8\C778')
,p_button_position=>'NEXT'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(3000009999000003)
,p_name=>'P9999_PASSWORD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(3000009999000001)
,p_prompt=>unistr('\BE44\BC00\BC88\D638\00A0\00A0')
,p_placeholder=>unistr('\BE44\BC00\BC88\D638')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>24
,p_cMaxlength=>100
,p_label_alignment=>'RIGHT'
,p_field_template=>wwv_flow_imp.id(141244423432435647300)
,p_item_icon_css_classes=>'fa-key'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(3000009999000002)
,p_name=>'P9999_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(3000009999000001)
,p_prompt=>unistr('\C0AC\C6A9\C790\BA85\00A0\00A0')
,p_placeholder=>unistr('\C0AC\C6A9\C790\BA85')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
,p_cMaxlength=>100
,p_label_alignment=>'RIGHT'
,p_field_template=>wwv_flow_imp.id(141244423432435647300)
,p_item_icon_css_classes=>'fa-user'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'textarea_rows', '5',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(3000009999000005)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Login'
,p_static_id=>'login'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex_authentication.login(',
'    p_username => :P9999_USERNAME,',
'    p_password => :P9999_PASSWORD );'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>3000009999000005
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(3000009999000006)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set Username Cookie'
,p_static_id=>'set-username-cookie'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex_authentication.send_login_username_cookie (',
'    p_username => lower(:P9999_USERNAME) );'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>3000009999000006
);
end;
/
prompt --application/deployment/definition
begin
null;
end;
/
prompt --application/deployment/checks
begin
null;
end;
/
prompt --application/deployment/buildoptions
begin
null;
end;
/
@/home/oracle/labs/lab18/apps/repair_subscribed_theme.sql
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
