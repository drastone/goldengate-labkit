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
,p_default_id_offset=>20062802842510124
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - DS Financial Flow Intelligence
--
-- Application Export:
--   Application:     300
--   Name:            DS Financial Flow Intelligence
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,'DS Financial Flow Intelligence')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'DS-FLOW-INTEL')
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
,p_logo_text=>'Financial Flow Intelligence'
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
,p_navigation_list_template_id=>wwv_flow_imp.id(141224357893160137171)
,p_nav_list_template_options=>'#DEFAULT#:js-defaultCollapsed:js-navCollapsed--hidden:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(141224357523032137171)
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
,p_version_scn=>'SH256:n65MzMqdHJZquIBFKwXkjv5HF4N6clbgqiDpxhOHkDs'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000005)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('FP \C870\CE58 \D050')
,p_static_id=>'nav-cancel'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-tasks'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'40'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000002)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\ACE0\AC1D\BCC4 \C790\AE08\D750\B984')
,p_static_id=>'nav-customers'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-users'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'10'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000004)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0')
,p_static_id=>'nav-fund'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-warning'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'30'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000006)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>unistr('Iceberg \C6B4\C601\C0C1\D0DC')
,p_static_id=>'nav-products'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-database'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'50'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000003)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\D380\B4DC\BCC4 \C720\C785/\C720\CD9C')
,p_static_id=>'nav-transactions'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-line-chart'
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
,p_default_page_template=>wwv_flow_imp.id(141224121260282137023)
,p_default_dialog_template=>wwv_flow_imp.id(141224119760847137021)
,p_error_template=>wwv_flow_imp.id(141224113159746137016)
,p_printer_friendly_template=>wwv_flow_imp.id(141224121260282137023)
,p_login_template=>wwv_flow_imp.id(141224113159746137016)
,p_default_button_template=>wwv_flow_imp.id(141224363531380137188)
,p_default_region_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_chart_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_form_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_reportr_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_wizard_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_menur_template=>wwv_flow_imp.id(141224275001221137087)
,p_default_listr_template=>wwv_flow_imp.id(141224262571064137074)
,p_default_irr_template=>wwv_flow_imp.id(141224260471904137072)
,p_default_report_template=>wwv_flow_imp.id(141224322095265137129)
,p_default_label_template=>wwv_flow_imp.id(141224362735228137184)
,p_default_menu_template=>wwv_flow_imp.id(141224365210438137191)
,p_default_list_template=>wwv_flow_imp.id(141224350880728137163)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(141224359690017137175)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(141224357893160137171)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(141224280170683137090)
,p_default_dialogr_template=>wwv_flow_imp.id(141224130000621137042)
,p_default_option_label=>wwv_flow_imp.id(141224362735228137184)
,p_default_required_label=>wwv_flow_imp.id(141224362252243137183)
,p_default_navbar_list_template=>wwv_flow_imp.id(141224357523032137171)
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
,p_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_alias=>'FLOW-DASHBOARD'
,p_step_title=>unistr('\B300\C2DC\BCF4\B4DC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'body .codex-kpi-cards .t-Report-report{display:grid!important;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;border:0!important;background:transparent!important}',
'body .codex-kpi-cards .t-Report-report thead,body .codex-kpi-cards .t-Report-report tbody,body .codex-kpi-cards .t-Report-report tr{display:contents!important}',
'body .codex-kpi-cards .t-Report-report th{display:none!important}',
'body .codex-kpi-cards .t-Report-report td{display:block!important;border:0!important;padding:0!important;background:transparent!important}',
'body .codex-kpi-card{display:grid;grid-template-columns:42px minmax(0,1fr);gap:10px;align-items:center;min-height:82px;padding:14px;border:1px solid #d9e0e8;border-radius:8px;background:#fff}',
'body .codex-kpi-icon{display:flex;align-items:center;justify-content:center;width:42px;height:42px;border-radius:8px;font-size:20px;background:#edf2f8;color:#233044}',
'body .codex-kpi-label{display:block;font-size:12px;color:#5f6d7d;line-height:1.25}',
'body .codex-kpi-value{display:block;font-size:22px;font-weight:750;color:#202833;line-height:1.2;margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'body .codex-kpi-blue .codex-kpi-icon{background:#e8f1ff;color:#255c99}',
'body .codex-kpi-green .codex-kpi-icon{background:#e8f7ee;color:#168a5b}',
'body .codex-kpi-orange .codex-kpi-icon{background:#fff4d6;color:#b7791f}',
'body .codex-kpi-red .codex-kpi-icon{background:#fff1f1;color:#b4232a}',
''))
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'06'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000002)
,p_plug_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>unistr('\D575\C2EC-kpi')
,p_title=>unistr('\B300\C2DC\BCF4\B4DC')
,p_region_css_classes=>'codex-kpi-cards'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="dashboard">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">\B300\C2DC\BCF4\B4DC</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
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
,p_name=>unistr('\ACE0\AC1D\BCC4 \C790\AE08\D750\B984')
,p_alias=>'CUSTOMER-FLOW'
,p_step_title=>unistr('\ACE0\AC1D\BCC4 \C790\AE08\D750\B984')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000002)
,p_plug_name=>unistr('\ACE0\AC1D\BCC4 \C790\AE08\D750\B984')
,p_static_id=>unistr('\C131\BCC4-\C5F0\B839\BCC4-\ACE0\AC1D-\BD84\D3EC')
,p_title=>unistr('\ACE0\AC1D\BCC4 \C790\AE08\D750\B984')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="customers">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">\ACE0\AC1D\BCC4 \C790\AE08\D750\B984</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>unistr('\D380\B4DC\BCC4 \C720\C785/\C720\CD9C')
,p_alias=>'FUND-INOUT'
,p_step_title=>unistr('\D380\B4DC\BCC4 \C720\C785/\C720\CD9C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000002)
,p_plug_name=>unistr('\D380\B4DC\BCC4 \C720\C785/\C720\CD9C')
,p_static_id=>unistr('\AC70\B798-\C720\D615\BCC4-\BD84\D3EC')
,p_title=>unistr('\D380\B4DC\BCC4 \C720\C785/\C720\CD9C')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="funds">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">\D380\B4DC\BCC4 \C720\C785/\C720\CD9C</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0')
,p_alias=>'FLOW-ANOMALY'
,p_step_title=>unistr('\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000002)
,p_plug_name=>unistr('\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0')
,p_static_id=>unistr('\D380\B4DC\BCC4-\CD1D-\C801\B9BD\AE08-\CD5C\ADFC-\AE30\C900\C77C')
,p_title=>unistr('\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="anomalies">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">\C774\C0C1 \AC70\B798/\AE09\C99D \D0D0\C9C0</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
);
end;
/
prompt --application/pages/page_00040
begin
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>unistr('FP \C870\CE58 \D050')
,p_alias=>'FP-ACTION-QUEUE'
,p_step_title=>unistr('FP \C870\CE58 \D050')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'body .codex-kpi-cards .t-Report-report{display:grid!important;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;border:0!important;background:transparent!important}',
'body .codex-kpi-cards .t-Report-report thead,body .codex-kpi-cards .t-Report-report tbody,body .codex-kpi-cards .t-Report-report tr{display:contents!important}',
'body .codex-kpi-cards .t-Report-report th{display:none!important}',
'body .codex-kpi-cards .t-Report-report td{display:block!important;border:0!important;padding:0!important;background:transparent!important}',
'body .codex-kpi-card{display:grid;grid-template-columns:42px minmax(0,1fr);gap:10px;align-items:center;min-height:82px;padding:14px;border:1px solid #d9e0e8;border-radius:8px;background:#fff}',
'body .codex-kpi-icon{display:flex;align-items:center;justify-content:center;width:42px;height:42px;border-radius:8px;font-size:20px;background:#edf2f8;color:#233044}',
'body .codex-kpi-label{display:block;font-size:12px;color:#5f6d7d;line-height:1.25}',
'body .codex-kpi-value{display:block;font-size:22px;font-weight:750;color:#202833;line-height:1.2;margin-top:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'body .codex-kpi-blue .codex-kpi-icon{background:#e8f1ff;color:#255c99}',
'body .codex-kpi-green .codex-kpi-icon{background:#e8f7ee;color:#168a5b}',
'body .codex-kpi-orange .codex-kpi-icon{background:#fff4d6;color:#b7791f}',
'body .codex-kpi-red .codex-kpi-icon{background:#fff1f1;color:#b4232a}',
''))
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000002)
,p_plug_name=>unistr('FP \C870\CE58 \D050')
,p_static_id=>unistr('\D574\C57D-\D604\D669-\C694\C57D')
,p_title=>unistr('FP \C870\CE58 \D050')
,p_region_css_classes=>'codex-kpi-cards'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="actions">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">FP \C870\CE58 \D050</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
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
,p_name=>unistr('Iceberg \C6B4\C601\C0C1\D0DC')
,p_alias=>'ICEBERG-HEALTH'
,p_step_title=>unistr('Iceberg \C6B4\C601\C0C1\D0DC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224121260282137023)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224275001221137087)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224365210438137191)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000002)
,p_plug_name=>unistr('Iceberg \C6B4\C601\C0C1\D0DC')
,p_static_id=>unistr('\C0C1\D488-\CE74\D14C\ACE0\B9AC-\BD84\D3EC')
,p_title=>unistr('Iceberg \C6B4\C601\C0C1\D0DC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224262571064137074)
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ffi-wrap{min-height:calc(100vh - 165px);background:#f7f8fb;color:#202833;font-family:Inter,Arial,sans-serif}',
'.ffi-head{display:flex;align-items:center;gap:12px;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #d9e0e8;background:#fff}.ffi-title{font-size:20px;font-weight:700;letter-spacing:0}.ffi-status{display:flex;align-items:center;'
||'gap:8px;font-size:12px;color:#5d6b7a}.ffi-dot{width:9px;height:9px;border-radius:50%;background:#a0a8b2}.ffi-dot.ok{background:#168a5b}.ffi-dot.warn{background:#b7791f}.ffi-actions{display:flex;gap:8px}.ffi-btn{border:1px solid #a9b7c6;background:#ff'
||'f;border-radius:6px;height:34px;padding:0 10px;cursor:pointer;color:#223042}.ffi-btn.primary{background:#255c99;color:#fff;border-color:#255c99}.ffi-btn:disabled{opacity:.55;cursor:wait}',
'.ffi-main{padding:14px 16px;display:grid;gap:12px}.ffi-kpis{display:grid;grid-template-columns:repeat(4,minmax(150px,1fr));gap:10px}.ffi-kpi{background:#fff;border:1px solid #d9e0e8;border-radius:8px;padding:12px;min-height:86px}.ffi-kpi-label{font-s'
||'ize:12px;color:#637184}.ffi-kpi-value{font-size:24px;font-weight:750;margin-top:6px;white-space:nowrap}.ffi-kpi-sub{font-size:12px;color:#6f7d8f;margin-top:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}',
'.ffi-grid{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(340px,.9fr);gap:12px}.ffi-panel{background:#fff;border:1px solid #d9e0e8;border-radius:8px;min-width:0}.ffi-panel-h{height:43px;display:flex;align-items:center;justify-content:space'
||'-between;padding:0 12px;border-bottom:1px solid #e2e7ee;font-weight:700}.ffi-panel-b{padding:12px;overflow:auto}.ffi-table{width:100%;border-collapse:collapse;font-size:13px}.ffi-table th,.ffi-table td{padding:8px 9px;border-bottom:1px solid #e6ebf1;'
||'text-align:left;vertical-align:top}.ffi-table th{font-size:11px;color:#5f6d7d;text-transform:uppercase;background:#fbfcfe;position:sticky;top:0}.ffi-num{text-align:right}.ffi-badge{display:inline-flex;align-items:center;justify-content:center;min-wid'
||'th:38px;height:22px;border-radius:999px;font-size:12px;font-weight:700;border:1px solid #c8d2df;background:#f3f6fa}.ffi-badge.p1{color:#9f1d20;background:#fff1f1;border-color:#ffc9cb}.ffi-badge.p2{color:#86540f;background:#fff7e6;border-color:#f3d29b'
||'}.ffi-badge.p3{color:#1f6b49;background:#ecf9f3;border-color:#bfe7d2}',
'.ffi-bars{display:grid;gap:8px}.ffi-bar{display:grid;grid-template-columns:105px minmax(120px,1fr) 86px;gap:8px;align-items:center;font-size:13px}.ffi-bar-track{height:11px;border-radius:999px;background:#e6ebf1;overflow:hidden}.ffi-bar-fill{height:1'
||'1px;border-radius:999px;background:linear-gradient(90deg,#255c99,#2d8a78)}.ffi-mini{font-size:12px;color:#667588}.ffi-error{border:1px solid #e0a0a0;background:#fff5f5;color:#8d1f24;padding:10px;border-radius:8px}.ffi-sql{white-space:pre-wrap;font-fa'
||'mily:Consolas,"Courier New",monospace;font-size:12px;line-height:1.45;background:#0f1620;color:#dce8f5;border-radius:8px;padding:12px;overflow:auto}.ffi-loader{height:190px;display:flex;align-items:center;justify-content:center;color:#687789}.ffi-sta'
||'ck{display:grid;gap:12px}.ffi-health{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:10px}.ffi-link{color:#245b96;text-decoration:none;font-weight:700} @media(max-width:900px){.ffi-kpis{grid-template-columns:repeat(2,minmax(0,1fr))'
||'}.ffi-grid{grid-template-columns:1fr}.ffi-health{grid-template-columns:1fr}.ffi-head{align-items:flex-start;flex-direction:column}.ffi-bar{grid-template-columns:88px minmax(100px,1fr) 72px}}',
'</style>',
'<div class="ffi-wrap" id="ffiApp" data-view="health">',
'  <div class="ffi-head">',
unistr('    <div><div class="ffi-title">Iceberg \C6B4\C601\C0C1\D0DC</div><div class="ffi-status"><span id="ffiDot" class="ffi-dot"></span><span id="ffiStatus">connecting</span></div></div>'),
'    <div class="ffi-actions"><button type="button" class="ffi-btn" id="ffiOpenSql">SQL</button><button type="button" class="ffi-btn primary" id="ffiRefresh">Refresh</button></div>',
'  </div>',
'  <div class="ffi-main" id="ffiMain"><div class="ffi-loader">Loading Iceberg signals...</div></div>',
'</div>',
'<script>',
'(function(){',
'  var root=document.getElementById(''ffiApp''); if(!root){return;}',
'  var view=root.getAttribute(''data-view'');',
'  var main=document.getElementById(''ffiMain'');',
'  var status=document.getElementById(''ffiStatus'');',
'  var dot=document.getElementById(''ffiDot'');',
'  var refresh=document.getElementById(''ffiRefresh'');',
'  var sqlBtn=document.getElementById(''ffiOpenSql'');',
'  var apiBase=localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var table=''iceberg.insurance.cfund_transactions'';',
'  var sqls={',
'    kpi:"select count(*) row_count, count(distinct cust_id) customer_count, count(distinct fund_code) fund_count, sum(fund_amt) total_amount, max(op_ts) latest_op_ts from "+table,',
'    day:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select d.d business_date, count(*) tx_count, count(distinct cust_id) active_customers, sum(fund_amt) day_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else '
||'0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun in (''3'',''5'')'
||' then -fund_amt else 0 end) net_flow, count_if(fund_amt >= 5000000) large_tx_count from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by d.d",',
'    risk:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt else 0 end) inflow_amount, sum(case when o'
||'p_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, max(fund_amt) max_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_co'
||'unt, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross jo'
||'in latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' el'
||unistr('se ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, inflow_amount, outflow_amount, transfer_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_amount >= 80000000 then ''\C720\CD9C/\D574\C57D \AE08\C561 \C9D1\C911'' when large_tx_count >= 4 then ''\ACE0\C561')
||unistr('\AC70\B798 4\AC74 \C774\C0C1'' when risk_score >= 45 then ''\BCF5\D569 \C704\D5D8\C810\C218 \C0C1\C704'' when total_amount >= 120000000 then ''\CD1D \AC70\B798\AE08\C561 1.2\C5B5 \C774\C0C1'' when outflow_tx_count >= 6 then ''\C720\CD9C\AC70\B798 \BE48\B3C4 \C99D\AC00'' when tx_count >= 100 then ''\AC70\B798\BE48\B3C4 \C0C1\C704'' else ''\BAA8\B2C8\D130\B9C1'' end alert_reason, latest_op_ts from ranked order by ca')
||'se when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc, outflow_amount desc, total_amount desc limit 25",',
'    funds:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select fund_code, max(fund_name) fund_name, count(*) tx_count, count(distinct cust_id) customers, sum(fund_amt) gross_amount, sum(case when op_gubun in (''1'',''2'',''6'') then'
||' fund_amt else 0 end) inflow_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, sum(case when op_gubun=''4'' then fund_amt else 0 end) transfer_amount, sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gub'
||'un in (''3'',''5'') then -fund_amt else 0 end) net_flow, max(op_ts) latest_op_ts from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by fund_code order by abs(sum(case when op_gubun in (''1'',''2'',''6'') then fund_amt when op_gubun i'
||'n (''3'',''5'') then -fund_amt else 0 end)) desc, gross_amount desc limit 15",',
'    ops:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+") select coalesce(op_label, op_gubun) op_label, count(*) tx_count, sum(fund_amt) amount from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by coale'
||'sce(op_label, op_gubun) order by amount desc",',
'    spikes:"with bounds as (select max(substr(op_ts,1,10)) latest_day from "+table+"), daily as (select substr(t.op_ts,1,10) business_date, coalesce(t.op_label,t.op_gubun) op_label, count(*) tx_count, sum(t.fund_amt) amount from "+table+" t cross joi'
||'n bounds b where substr(t.op_ts,1,10) >= date_format(date_add(''day'',-7,date_parse(b.latest_day,''%Y-%m-%d'')),''%Y-%m-%d'') group by substr(t.op_ts,1,10), coalesce(t.op_label,t.op_gubun)), latest as (select d.* from daily d cross join bounds b where d.bu'
||'siness_date=b.latest_day), baseline as (select d.op_label, avg(d.tx_count) avg_tx_count, avg(d.amount) avg_amount from daily d cross join bounds b where d.business_date < b.latest_day group by d.op_label) select l.business_date, l.op_label, l.tx_coun'
||'t, l.amount, round(coalesce(b.avg_tx_count,0),1) avg_tx_count, round(coalesce(b.avg_amount,0),1) avg_amount, round(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0),2) tx_spike_ratio, round(coalesce(l.amount / nullif(b.avg_amount,0),0),2) amount_spik'
||'e_ratio from latest l left join baseline b on b.op_label=l.op_label order by greatest(coalesce(l.tx_count / nullif(b.avg_tx_count,0),0), coalesce(l.amount / nullif(b.avg_amount,0),0)) desc, l.amount desc",',
'    actions:"with latest_day as (select max(substr(op_ts,1,10)) d from "+table+"), ranked as (select cust_id, count(*) tx_count, sum(fund_amt) total_amount, sum(case when op_gubun in (''3'',''5'') then fund_amt else 0 end) outflow_amount, max(fund_amt) m'
||'ax_amount, count_if(fund_amt >= 5000000) large_tx_count, count_if(op_gubun in (''3'',''5'')) outflow_tx_count, max(op_ts) latest_op_ts, round(least(100.0, count(*) / 15.0 + sum(fund_amt) / 25000000.0 + sum(case when op_gubun in (''3'',''5'') then fund_amt el'
||'se 0 end) / 18000000.0 + count_if(fund_amt >= 5000000) * 7.0), 1) risk_score from "+table+" t cross join latest_day d where substr(t.op_ts,1,10)=d.d group by cust_id) select case when risk_score >= 45 or large_tx_count >= 4 or outflow_amount >= 80000'
||'000 then ''P1'' when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then ''P2'' else ''P3'' end priority, cust_id, risk_score, tx_count, total_amount, outflow_amount, max_amount, large_tx_count, outflow_tx_count, case when outflow_a'
||unistr('mount >= 80000000 then ''\C720\CD9C/\D574\C57D \BAA8\B2C8\D130\B9C1'' when large_tx_count >= 4 then ''\ACE0\C561\AC70\B798 \D655\C778'' when tx_count >= 120 then ''\AC70\B798\BE48\B3C4 \AE09\C99D'' when total_amount >= 150000000 then ''\C790\AE08\C774\B3D9 \C0C1\B2F4'' else ''\BAA8\B2C8\D130\B9C1'' end action_type, latest_op_ts from ranked order by case when risk_score >= 45 or')
||' large_tx_count >= 4 or outflow_amount >= 80000000 then 1 when risk_score >= 28 or total_amount >= 120000000 or outflow_tx_count >= 6 then 2 else 3 end, risk_score desc limit 25",',
'    snapshots:"select committed_at, snapshot_id, parent_id, operation, summary[''added-records''] added_records, summary[''total-records''] total_records, summary[''total-data-files''] total_data_files from iceberg.insurance.\"cfund_transactions$snapshots\'
||'" order by committed_at desc limit 10",',
'    files:"select count(*) file_count, sum(record_count) file_records, sum(file_size_in_bytes) file_bytes from iceberg.insurance.\"cfund_transactions$files\"",',
'    latest:"select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_label, op_ts from "+table+" order by op_ts desc limit 20"',
'  };',
'  function setStatus(text,kind){status.textContent=text;dot.className=''ffi-dot ''+(kind||'''');}',
'  function fmt(v){var n=Number(v||0);return n.toLocaleString(''ko-KR'');}',
unistr('  function money(v){var n=Number(v||0); if(Math.abs(n)>=100000000){return (n/100000000).toLocaleString(''ko-KR'',{maximumFractionDigits:1})+''\C5B5'';} return n.toLocaleString(''ko-KR'');}'),
'  function pct(v){return Math.max(0,Math.min(100,Number(v||0)));}',
'  function esc(v){return String(v==null?'''':v).replace(/[&<>"'']/g,function(c){return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];});}',
'  function objects(j){var names=(j.columns||[]).map(function(c){return c.name;});return (j.data||[]).map(function(row){var o={};names.forEach(function(n,i){o[n]=row[i];});return o;});}',
'  function query(sql,maxRows){return fetch(apiBase+''/api/query'',{method:''POST'',headers:{''Content-Type'':''application/json''},body:JSON.stringify({sql:sql,maxRows:maxRows||200})}).then(function(r){return r.json().then(function(j){if(!j.ok){throw new Err'
||'or(j.error||''query failed'');}return objects(j);});});}',
'  function tableHtml(cols,rows){return ''<table class="ffi-table"><thead><tr>''+cols.map(function(c){return ''<th''+(c.num?'' class="ffi-num"'':'''')+''>''+esc(c.label)+''</th>'';}).join('''')+''</tr></thead><tbody>''+rows.map(function(r){return ''<tr>''+cols.map(func'
||'tion(c){var v=typeof c.value===''function''?c.value(r):r[c.key];return ''<td''+(c.num?'' class="ffi-num"'':'''')+''>''+v+''</td>'';}).join('''')+''</tr>'';}).join('''')+''</tbody></table>'';}',
'  function bars(rows,labelKey,valueKey,maxValue){maxValue=maxValue||rows.reduce(function(m,r){return Math.max(m,Number(r[valueKey]||0));},0)||1;return ''<div class="ffi-bars">''+rows.map(function(r){var w=pct(Number(r[valueKey]||0)*100/maxValue);return'
||' ''<div class="ffi-bar"><div>''+esc(r[labelKey])+''</div><div class="ffi-bar-track"><div class="ffi-bar-fill" style="width:''+w+''%"></div></div><div class="ffi-num">''+money(r[valueKey])+''</div></div>'';}).join('''')+''</div>'';}',
'  function kpi(label,value,sub){return ''<div class="ffi-kpi"><div class="ffi-kpi-label">''+esc(label)+''</div><div class="ffi-kpi-value">''+value+''</div><div class="ffi-kpi-sub">''+esc(sub||'''')+''</div></div>'';}',
'  function panel(title,body,right){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(title)+''</span><span class="ffi-mini">''+esc(right||'''')+''</span></div><div class="ffi-panel-b">''+body+''</div></section>'';}',
unistr('  function riskCols(){return [{label:''\B4F1\AE09'',value:function(r){var p=String(r.priority||''P3'');return ''<span class="ffi-badge ''+p.toLowerCase()+''">''+esc(p)+''</span>'';}},'),
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\ACBD\BCF4 \C0AC\C720'',key:''alert_reason''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return mon')
||unistr('ey(r.total_amount);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:')
||unistr('''\ACE0\C561'',num:true,value:function(r){return fmt(r.large_tx_count);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
'  function actionCols(){return [{label:''Priority'',value:function(r){return ''<span class="ffi-badge ''+String(r.priority).toLowerCase()+''">''+esc(r.priority)+''</span>'';}},',
unistr('    {label:''\ACE0\AC1D'',key:''cust_id''},{label:''\C870\CE58\C720\D615'',key:''action_type''},{label:''\C704\D5D8\C810\C218'',num:true,value:function(r){return fmt(r.risk_score);}},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\CD1D\C561'',num:true,value:function(r){return money')
||unistr('(r.total_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){return money(r.outflow_amount);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function fundCols(){return [{label:''\D380\B4DC'',value:function(r){return esc(r.fund_code)+''<div class="ffi-mini">''+esc(r.fund_name)+''</div>'';}},'),
unistr('    {label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\ACE0\AC1D\C218'',num:true,value:function(r){return fmt(r.customers);}},{label:''\C720\C785'',num:true,value:function(r){return money(r.inflow_amount);}},{label:''\C720\CD9C'',num:true,value:function(r){re')
||unistr('turn money(r.outflow_amount);}},{label:''\D380\B4DC\BCC0\ACBD'',num:true,value:function(r){return money(r.transfer_amount);}},{label:''\C21C\C720\C785'',num:true,value:function(r){return money(r.net_flow);}},{label:''\CD5C\C2E0\C2DC\AC01'',key:''latest_op_ts''}];}'),
unistr('  function spikeCols(){return [{label:''\AC70\B798\C720\D615'',key:''op_label''},{label:''\AC70\B798\C218'',num:true,value:function(r){return fmt(r.tx_count);}},{label:''\AE08\C561'',num:true,value:function(r){return money(r.amount);}},{label:''7\C77C\D3C9\ADE0 \AC70\B798\C218'',num:true,value:function(r){return fmt(r.')
||unistr('avg_tx_count);}},{label:''\AC70\B798\C218 \AE09\C99D'',num:true,value:function(r){return fmt(r.tx_spike_ratio)+''x'';}},{label:''\AE08\C561 \AE09\C99D'',num:true,value:function(r){return fmt(r.amount_spike_ratio)+''x'';}},{label:''\AE30\C900\C77C'',key:''business_date''}];}'),
'  function err(e){main.innerHTML=''<div class="ffi-error">''+esc(e.message||e)+''<br>SSH tunnel: -L 38100:127.0.0.1:38100</div>'';setStatus(''proxy unavailable'',''warn'');}',
'  function loadDashboard(){setStatus(''loading'',''warn'');Promise.all([query(sqls.kpi,1),query(sqls.day,1),query(sqls.risk,10),query(sqls.funds,8),query(sqls.spikes,8),query(sqls.snapshots,3)]).then(function(res){var k=res[0][0]||{},d=res[1][0]||{},risk'
||unistr('=res[2],funds=res[3],spikes=res[4],snap=res[5][0]||{};var top=risk[0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Iceberg Rows'',fmt(k.row_count),''latest ''+(k.latest_op_ts||''''))+kpi(''\CD5C\C2E0\C77C \C21C\C720\C785'',money(d.net_flow),d.business_date||'''')+kpi(''\CD5C\C2E0\C77C \C720\CD9C'',mo')
||unistr('ney(d.outflow_amount),''large tx ''+fmt(d.large_tx_count))+kpi(''Top Risk Score'',fmt(top.risk_score||0),''customer ''+(top.cust_id||''-''))+''</div><div class="ffi-grid">''+panel(''\ACE0\AC1D \C870\AE30\ACBD\BCF4 Top 10'',tableHtml(riskCols(),risk),''live'')+panel(''\AC70\B798\C720\D615 \AE09\C99D Top'',tableHtm')
||unistr('l(spikeCols(),spikes),''7-day baseline'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C Top'',tableHtml(fundCols(),funds),''latest day'')+panel(''\CD5C\C2E0 Iceberg Snapshot'',''<div class="ffi-health">''+kpi(''Snapshot'',esc(snap.snapshot_id||''-''),snap.committed_at|')
||'|'''')+kpi(''Added Records'',fmt(snap.added_records),snap.operation||'''')+kpi(''Total Records'',fmt(snap.total_records),''files ''+fmt(snap.total_data_files))+''</div>'',''metadata'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadCustomers(){setStatus(''loading'',''warn'');query(sqls.risk,25).then(function(rows){main.innerHTML=panel(''\ACE0\AC1D\BCC4 \C790\AE08\D750\B984'',tableHtml(riskCols(),rows),''latest day'');setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadFunds(){setStatus(''loading'',''warn'');Promise.all([query(sqls.day,1),query(sqls.funds,15),query(sqls.ops,20)]).then(function(res){var d=res[0][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''\C720\C785'',money(d.inflow_amount),d.business_date')
||unistr('||'''')+kpi(''\C720\CD9C'',money(d.outflow_amount),''\C911\B3C4\C778\CD9C + \D574\C57D'')+kpi(''\C21C\C720\C785'',money(d.net_flow),''\C720\C785 - \C720\CD9C'')+kpi(''\D380\B4DC\BCC0\ACBD'',money(d.transfer_amount),''op_gubun=4'')+''</div><div class="ffi-grid">''+panel(''\D380\B4DC\BCC4 \C720\C785/\C720\CD9C'',tableHtml(fundCols(),res[1]),''latest day'')+panel(''\AC70\B798 \C720\D615\BCC4 \AE08\C561''')
||',bars(res[2],''op_label'',''amount''),''mix'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
unistr('  function loadAnomalies(){setStatus(''loading'',''warn'');Promise.all([query(sqls.spikes,20),query(sqls.risk,15)]).then(function(res){main.innerHTML=''<div class="ffi-grid">''+panel(''\AC70\B798\C720\D615 \AE09\C99D \D0D0\C9C0'',tableHtml(spikeCols(),res[0]),''latest day vs 7-day avg'')+pan')
||unistr('el(''\ACE0\C704\D5D8 \ACE0\AC1D \D6C4\BCF4'',tableHtml(riskCols(),res[1]),''risk scoring'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}'),
unistr('  function loadActions(){setStatus(''loading'',''warn'');query(sqls.actions,25).then(function(rows){main.innerHTML=panel(''FP \C870\CE58 \D050'',tableHtml(actionCols(),rows),''Iceberg signal'');setStatus(''live'',''ok'');}).catch(err);}'),
'  function loadHealth(){setStatus(''loading'',''warn'');Promise.all([query(sqls.snapshots,10),query(sqls.files,1),query(sqls.latest,10)]).then(function(res){var f=res[1][0]||{};main.innerHTML=''<div class="ffi-kpis">''+kpi(''Files'',fmt(f.file_count),''Iceber'
||'g data files'')+kpi(''File Records'',fmt(f.file_records),''metadata sum'')+kpi(''Storage Bytes'',fmt(f.file_bytes),''file_size_in_bytes'')+kpi(''Latest Tx'',esc((res[2][0]||{}).op_ts||''-''),''from table scan'')+''</div><div class="ffi-grid">''+panel(''Snapshot Histor'
||'y'',tableHtml([{label:''Committed'',key:''committed_at''},{label:''Snapshot'',key:''snapshot_id''},{label:''Operation'',key:''operation''},{label:''Added'',num:true,value:function(r){return fmt(r.added_records);}},{label:''Total'',num:true,value:function(r){return fm'
||unistr('t(r.total_records);}}],res[0]),''Iceberg metadata'')+panel(''\CD5C\ADFC \AC70\B798'',tableHtml([{label:''Customer'',key:''cust_id''},{label:''Fund'',key:''fund_code''},{label:''Amount'',num:true,value:function(r){return money(r.fund_amt);}},{label:''Label'',key:''op_label''},{label:''')
||'Time'',key:''op_ts''}],res[2]),''live'')+''</div>'';setStatus(''live'',''ok'');}).catch(err);}',
'  function loadEvidence(){var body=Object.keys(sqls).map(function(k){return ''<section class="ffi-panel"><div class="ffi-panel-h"><span>''+esc(k)+''</span></div><div class="ffi-panel-b"><pre class="ffi-sql">''+esc(sqls[k])+''</pre></div></section>'';}).joi'
||'n('''');main.innerHTML=''<div class="ffi-stack">''+body+''</div>'';setStatus(''ready'',''ok'');}',
'  var loaders={dashboard:loadDashboard,customers:loadCustomers,funds:loadFunds,anomalies:loadAnomalies,actions:loadActions,health:loadHealth,evidence:loadEvidence};',
'  refresh.onclick=function(){(loaders[view]||loadDashboard)();};',
'  sqlBtn.onclick=function(){loadEvidence();};',
'  (loaders[view]||loadDashboard)();',
'})();',
'</script>',
''))
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
,p_step_template=>wwv_flow_imp.id(141224113159746137016)
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
,p_plug_template=>wwv_flow_imp.id(141224305217625137111)
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
