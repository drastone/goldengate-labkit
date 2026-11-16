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
,p_default_id_offset=>19788287080546735
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - DS Iceberg SQL Console
--
-- Application Export:
--   Application:     300
--   Name:            DS Iceberg SQL Console
--   Date and Time:   02:48 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      8
--       Items:                    2
--       Processes:                2
--       Regions:                 18
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,'DS Iceberg SQL Console')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'DS-ICEBERG-SQL')
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
,p_logo_text=>'Iceberg SQL Console'
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
,p_navigation_list_template_id=>wwv_flow_imp.id(141224632408922100560)
,p_nav_list_template_options=>'#DEFAULT#:js-defaultCollapsed:js-navCollapsed--hidden:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(141224632038794100560)
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
,p_version_scn=>'SH256:azlJMz7RBiN5FkcBpvxaBdtTTV3RlIZ6l_B5Dtx4snY'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000002)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Catalog Snapshot'
,p_static_id=>'nav-customers'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-database'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'10'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'SQL Terminal'
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-terminal'
,p_list_item_current_type=>'TARGET_PAGE'
,p_list_item_current_for_pages=>'1'
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
,p_default_page_template=>wwv_flow_imp.id(141224395776044100412)
,p_default_dialog_template=>wwv_flow_imp.id(141224394276609100410)
,p_error_template=>wwv_flow_imp.id(141224387675508100405)
,p_printer_friendly_template=>wwv_flow_imp.id(141224395776044100412)
,p_login_template=>wwv_flow_imp.id(141224387675508100405)
,p_default_button_template=>wwv_flow_imp.id(141224638047142100577)
,p_default_region_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_chart_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_form_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_reportr_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_wizard_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_menur_template=>wwv_flow_imp.id(141224549516983100476)
,p_default_listr_template=>wwv_flow_imp.id(141224537086826100463)
,p_default_irr_template=>wwv_flow_imp.id(141224534987666100461)
,p_default_report_template=>wwv_flow_imp.id(141224596611027100518)
,p_default_label_template=>wwv_flow_imp.id(141224637250990100573)
,p_default_menu_template=>wwv_flow_imp.id(141224639726200100580)
,p_default_list_template=>wwv_flow_imp.id(141224625396490100552)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(141224634205779100564)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(141224632408922100560)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(141224554686445100479)
,p_default_dialogr_template=>wwv_flow_imp.id(141224404516383100431)
,p_default_option_label=>wwv_flow_imp.id(141224637250990100573)
,p_default_required_label=>wwv_flow_imp.id(141224636768005100572)
,p_default_navbar_list_template=>wwv_flow_imp.id(141224632038794100560)
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
,p_name=>'Iceberg SQL Terminal'
,p_alias=>'ICEBERG-SQL-TERMINAL'
,p_step_title=>'Iceberg SQL Terminal'
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
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000002)
,p_plug_name=>'Iceberg SQL Terminal'
,p_static_id=>unistr('\D575\C2EC-kpi')
,p_title=>'Iceberg SQL Terminal'
,p_region_css_classes=>'codex-kpi-cards'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224537086826100463)
,p_plug_display_sequence=>10
,p_plug_item_display_point=>'ABOVE'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<style>',
'html .ice-shell{height:calc(100vh - 176px);min-height:560px;background:#0b0f14;border:1px solid #28313d;border-radius:8px;display:flex;flex-direction:column;overflow:hidden;font-family:Consolas,"Courier New",monospace}',
'html .ice-top{height:auto;min-height:44px;background:#131a22;border-bottom:1px solid #28313d;display:flex;align-items:center;gap:8px;padding:8px 12px;flex-wrap:wrap}',
'.ice-dot{width:11px;height:11px;border-radius:50%;display:inline-block}.ice-red{background:#ff5f56}.ice-yellow{background:#ffbd2e}.ice-green{background:#27c93f}',
'.ice-title{font-weight:700;color:#e6edf3}.ice-chip{font-size:12px;color:#9fb0c3;border:1px solid #344051;border-radius:4px;padding:3px 7px}.ice-spacer{flex:1}',
'html .ice-out{flex:1;overflow:auto;padding:14px;color:#d8e1ec;line-height:1.5}',
'html .ice-editor{border-top:1px solid #28313d;background:#0b0f14;padding:10px;display:grid;grid-template-columns:1fr auto;gap:8px}',
'html #iceSql{width:100%;min-height:78px;max-height:170px;resize:vertical;background:#101722;color:#e6edf3;border:1px solid #344051;border-radius:6px;padding:9px 10px;font-family:Consolas,"Courier New",monospace;font-size:13px;line-height:1.45}',
'.ice-run{min-width:86px;border:1px solid #2f81f7;background:#1f6feb;color:white;border-radius:6px;font-weight:700;cursor:pointer}.ice-run:disabled{opacity:.55;cursor:wait}',
'.ice-line{white-space:pre-wrap;margin:0 0 8px}.ice-prompt{color:#58a6ff;font-weight:700}.ice-muted{color:#8b949e}.ice-err{color:#ff7b72}.ice-ok{color:#7ee787}',
'.ice-block{border:1px solid #28313d;background:#0f1620;border-radius:7px;margin:10px 0;padding:10px;overflow:auto}',
'.ice-msg{border:1px solid #344051;border-radius:6px;padding:9px 10px;margin:8px 0;background:#101722}.ice-msg.ice-ok{border-color:#238636;color:#d8e1ec}.ice-msg.ice-err{border-color:#da3633;color:#ffdcd7}',
'.ice-table-wrap{overflow:auto;max-width:100%;border:1px solid #28313d;border-radius:7px;margin-top:8px}.ice-table{border-collapse:collapse;width:max-content;min-width:720px}.ice-table th,.ice-table td{border-bottom:1px solid #28313d;border-right:1px '
||'solid #28313d;padding:6px 8px;text-align:left;vertical-align:top;white-space:nowrap}.ice-table th{background:#151d28;color:#79c0ff}.ice-table td{background:#0d131b}.ice-type{font-size:11px;color:#8b949e;font-weight:400}.ice-null{color:#8b949e;font-st'
||'yle:italic}.ice-result-meta{font-size:12px;color:#9fb0c3;margin:3px 0 5px}',
'.ice-help{display:flex;flex-wrap:wrap;gap:6px;margin:9px 0}.ice-help button{border:1px solid #344051;background:#111c2a;color:#d8e1ec;border-radius:5px;padding:5px 8px;font-family:Consolas,"Courier New",monospace;font-size:12px;cursor:pointer}.ice-he'
||'lp button:hover{border-color:#58a6ff;color:#79c0ff} @media(max-width:760px){html .ice-shell{height:calc(100vh - 140px);min-height:520px}.ice-chip{display:none}html .ice-editor{grid-template-columns:1fr}.ice-run{height:38px}.ice-table th,.ice-table td'
||'{white-space:normal}}',
'</style>',
'<div class="ice-shell">',
'  <div class="ice-top">',
'    <span class="ice-dot ice-red"></span><span class="ice-dot ice-yellow"></span><span class="ice-dot ice-green"></span>',
'    <span class="ice-title">Iceberg SQL Terminal</span>',
'    <span class="ice-chip">Trino</span>',
'    <span class="ice-chip">iceberg.insurance</span>',
'    <span class="ice-chip">read-only</span>',
'    <span class="ice-spacer"></span>',
'    <span id="iceStatus" class="ice-chip">checking proxy...</span>',
'  </div>',
'  <div id="iceOut" class="ice-out"></div>',
'  <div class="ice-editor">',
'    <textarea id="iceSql" spellcheck="false">select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_ts',
'from iceberg.insurance.cfund_transactions',
'order by op_ts desc',
'limit 10</textarea>',
'    <button id="iceRun" class="ice-run" type="button">Run</button>',
'  </div>',
'</div>',
'<script>',
'(function(){',
'  var apiBase = localStorage.getItem(''icebergSqlProxy'') || ''http://localhost:38100'';',
'  var out = document.getElementById(''iceOut'');',
'  var sql = document.getElementById(''iceSql'');',
'  var run = document.getElementById(''iceRun'');',
'  var status = document.getElementById(''iceStatus'');',
'  var history = [];',
'  var hidx = -1;',
'',
'  function esc(v){',
'    return String(v == null ? '''' : v).replace(/[&<>"'']/g, function(c){',
'      return {''&'':''&amp;'',''<'':''&lt;'',''>'':''&gt;'',''"'':''&quot;'',"''":''&#39;''}[c];',
'    });',
'  }',
'  function append(html, cls){',
'    var d = document.createElement(''div'');',
'    d.className = cls || ''ice-block'';',
'    d.innerHTML = html;',
'    out.appendChild(d);',
'    out.scrollTop = out.scrollHeight;',
'  }',
'  function appendText(text, cls){',
'    append(''<div class="ice-line">'' + esc(text) + ''</div>'', cls || '''');',
'  }',
'  function setBusy(v){',
'    run.disabled = v;',
'    run.textContent = v ? ''Running'' : ''Run'';',
'  }',
'  function help(){',
'    fetch(apiBase + ''/api/help'')',
'      .then(function(r){ return r.json(); })',
'      .then(function(j){',
'        append(j.html || '''', ''ice-block'');',
'        Array.prototype.slice.call(out.querySelectorAll(''.ice-help button'')).forEach(function(b){',
'          b.onclick = function(){ sql.value = b.getAttribute(''data-sql'') || b.textContent; sql.focus(); };',
'        });',
'      });',
'  }',
'  function check(){',
'    fetch(apiBase + ''/api/health'')',
'      .then(function(r){ return r.json(); })',
'      .then(function(j){',
'        if(j.ok){ status.textContent = ''proxy OK / '' + j.catalog + ''.'' + j.schema; }',
'        else { status.textContent = ''proxy error''; }',
'      })',
'      .catch(function(){',
'        status.textContent = ''proxy offline'';',
unistr('        append(''<div class="ice-msg ice-err">Proxy \C5F0\ACB0 \C2E4\D328: SSH \D130\B110\C5D0 <code>-L 38100:127.0.0.1:38100</code>\C744 \CD94\AC00\D588\B294\C9C0 \D655\C778\D558\C138\C694.</div>'', ''ice-block'');'),
'      });',
'  }',
'  function exec(){',
'    var text = sql.value.trim();',
'    if(!text){ return; }',
'    history.push(text);',
'    hidx = history.length;',
'    append(''<div class="ice-line"><span class="ice-prompt">ICEBERG&gt;</span> '' + esc(text) + ''</div>'', ''ice-block'');',
'    setBusy(true);',
'    fetch(apiBase + ''/api/query'', {',
'      method: ''POST'',',
'      headers: {''Content-Type'':''application/json''},',
'      body: JSON.stringify({sql:text, maxRows:200})',
'    })',
'      .then(function(r){ return r.json().then(function(j){ j.httpStatus = r.status; return j; }); })',
'      .then(function(j){',
'        if(j.ok){ append(j.html || ''<div class="ice-msg ice-ok">Query finished.</div>'', ''ice-block''); }',
'        else { append(''<div class="ice-msg ice-err">'' + esc(j.error || ''Query failed'') + ''</div>'', ''ice-block''); }',
'      })',
'      .catch(function(e){',
'        append(''<div class="ice-msg ice-err">Request failed: '' + esc(e.message || e) + ''</div>'', ''ice-block'');',
'      })',
'      .finally(function(){ setBusy(false); sql.focus(); });',
'  }',
'  run.onclick = exec;',
'  sql.addEventListener(''keydown'', function(e){',
'    if((e.ctrlKey || e.metaKey) && e.key === ''Enter''){ e.preventDefault(); exec(); }',
'    if(e.key === ''ArrowUp'' && e.altKey && history.length){',
'      e.preventDefault(); hidx = Math.max(0, hidx - 1); sql.value = history[hidx] || sql.value;',
'    }',
'    if(e.key === ''ArrowDown'' && e.altKey && history.length){',
'      e.preventDefault(); hidx = Math.min(history.length, hidx + 1); sql.value = history[hidx] || '''';',
'    }',
'  });',
'  appendText(''Connected target: Trino / iceberg.insurance.cfund_transactions'', ''ice-muted'');',
'  appendText(''Type a read-only SQL or use a short alias: tables, columns, count, latest, snapshots, files.'', ''ice-muted'');',
'  help();',
'  check();',
'  sql.focus();',
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
,p_plug_comment=>'Generated by Codex for Trino/Iceberg SQL terminal.'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>'Catalog Snapshot'
,p_alias=>'CATALOG-SNAPSHOT'
,p_step_title=>'Catalog Snapshot'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(3000000010000006)
,p_name=>'Catalog Snapshot'
,p_static_id=>unistr('\ACE0\AC1D-\BAA9\B85D')
,p_title=>'Catalog Snapshot'
,p_template=>wwv_flow_imp.id(141224534987666100461)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select domain_name,',
'       system_name,',
'       app_alias,',
'       owner_account,',
'       data_product_name,',
'       freshness_sla,',
'       nvl(quality_status, ''CATALOG'') quality_status,',
'       downstream_consumers',
'  from ggadmin.mesh_domain_contract_v',
' order by domain_order'))
,p_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104554503731625)
,p_query_column_id=>3
,p_column_alias=>'APP_ALIAS'
,p_static_id=>'app-alias'
,p_column_display_sequence=>30
,p_column_heading=>'App Alias'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104733960731626)
,p_query_column_id=>5
,p_column_alias=>'DATA_PRODUCT_NAME'
,p_static_id=>'data-product-name'
,p_column_display_sequence=>50
,p_column_heading=>'Data Product'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104352082731624)
,p_query_column_id=>1
,p_column_alias=>'DOMAIN_NAME'
,p_static_id=>'domain-name'
,p_column_display_sequence=>10
,p_column_heading=>'Domain'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(105073281731627)
,p_query_column_id=>8
,p_column_alias=>'DOWNSTREAM_CONSUMERS'
,p_static_id=>'downstream-consumers'
,p_column_display_sequence=>80
,p_column_heading=>'Consumers'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104836040731626)
,p_query_column_id=>6
,p_column_alias=>'FRESHNESS_SLA'
,p_static_id=>'freshness-sla'
,p_column_display_sequence=>60
,p_column_heading=>'Freshness SLA'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104618839731625)
,p_query_column_id=>4
,p_column_alias=>'OWNER_ACCOUNT'
,p_static_id=>'owner-account'
,p_column_display_sequence=>40
,p_column_heading=>'Owner'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104954017731627)
,p_query_column_id=>7
,p_column_alias=>'QUALITY_STATUS'
,p_static_id=>'quality-status'
,p_column_display_sequence=>70
,p_column_heading=>'Quality'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(104455706731624)
,p_query_column_id=>2
,p_column_alias=>'SYSTEM_NAME'
,p_static_id=>'system-name'
,p_column_display_sequence=>20
,p_column_heading=>'Independent System'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000002)
,p_plug_name=>unistr('\B3C4\BA54\C778 Contract \AC74\C218')
,p_static_id=>unistr('\C131\BCC4-\C5F0\B839\BCC4-\ACE0\AC1D-\BD84\D3EC')
,p_title=>unistr('\B3C4\BA54\C778 Contract \AC74\C218')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141224537086826100463)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000010000003)
,p_region_id=>wwv_flow_imp.id(3000000010000002)
,p_chart_type=>'bar'
,p_height=>'280'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
,p_overview_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000010000005)
,p_chart_id=>wwv_flow_imp.id(3000000010000003)
,p_static_id=>'s-female-age'
,p_seq=>20
,p_name=>'Domain Contract Count'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select domain_name category, count(*) cnt',
'  from ggadmin.mesh_domain_contract_v',
' group by domain_name',
' order by domain_name'))
,p_series_type=>'bar'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'AGE_GROUP'
,p_color=>'#ED6685'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000010000004)
,p_chart_id=>wwv_flow_imp.id(3000000010000003)
,p_static_id=>'s-male-age'
,p_seq=>10
,p_name=>'Domain Contract Count'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select domain_name category, count(*) cnt',
'  from ggadmin.mesh_domain_contract_v',
' group by domain_name',
' order by domain_name'))
,p_series_type=>'bar'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'AGE_GROUP'
,p_color=>'#4884C4'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000010000008)
,p_chart_id=>wwv_flow_imp.id(3000000010000003)
,p_static_id=>'x'
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000010000009)
,p_chart_id=>wwv_flow_imp.id(3000000010000003)
,p_static_id=>'y'
,p_axis=>'y'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Query Examples'
,p_alias=>'QUERY-EXAMPLES'
,p_step_title=>'Query Examples'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000005)
,p_plug_name=>'Query Examples'
,p_static_id=>unistr('\AC70\B798-\B0B4\C5ED-interactive-report')
,p_title=>'Query Examples'
,p_region_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'N'
,p_plug_template=>wwv_flow_imp.id(141224534987666100461)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<div class="t-Region-body">',
'<pre style="white-space:pre-wrap;font-family:Consolas,''Courier New'',monospace">',
'tables',
'columns',
'count',
'latest',
'snapshots',
'files',
'',
'select cust_id, fund_code, fund_name, fund_amt, op_gubun, op_ts',
'from iceberg.insurance.cfund_transactions',
'order by op_ts desc',
'limit 10;',
'',
'select committed_at, snapshot_id, parent_id, operation',
'from iceberg.insurance."cfund_transactions$snapshots"',
'order by committed_at desc',
'limit 10;',
'</pre>',
'</div>',
''))
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>'Iceberg Metadata'
,p_alias=>'ICEBERG-METADATA'
,p_step_title=>'Iceberg Metadata'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000005)
,p_plug_name=>unistr('\C801\B9BD\AE08 \C0C1\C138 \B0B4\C5ED')
,p_static_id=>unistr('\C801\B9BD\AE08-\C0C1\C138-\B0B4\C5ED')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141224534987666100461)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  DT "\AE30\C900\C77C",'),
unistr('  CUST_ID "\ACE0\AC1DID",'),
unistr('  CUST_NM "\ACE0\AC1D\BA85",'),
unistr('  FUND_CODE "\D380\B4DC\CF54\B4DC",'),
unistr('  FUND_NAME "\D380\B4DC\BA85",'),
unistr('  FUND_CNT "\C88C\C218",'),
unistr('  TO_CHAR(FUND_PRICE,''FM999,999.99'') "\AE30\C900\AC00",'),
unistr('  TOT_CNT "\CD1D\C88C\C218",'),
unistr('  TO_CHAR(TOT_AMT,''FM999,999,999,999'') "\C801\B9BD\AE08(\C6D0)"'),
'FROM V_INS_RESERVES',
'ORDER BY DT DESC, CUST_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000030000006)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000030000006
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000030000009)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300300'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\AE30\C900\C77C":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"\C88C\C218":"\AE30\C900\AC00":"\CD1D\C88C\C218":"\C801\B9BD\AE08(\C6D0)"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000002)
,p_plug_name=>unistr('\D380\B4DC\BCC4 \CD1D \C801\B9BD\AE08 (\CD5C\ADFC \AE30\C900\C77C)')
,p_static_id=>unistr('\D380\B4DC\BCC4-\CD1D-\C801\B9BD\AE08-\CD5C\ADFC-\AE30\C900\C77C')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141224537086826100463)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000030000003)
,p_region_id=>wwv_flow_imp.id(3000000030000002)
,p_chart_type=>'bar'
,p_height=>'320'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'horizontal'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_value_format_scaling=>'auto'
,p_sorting=>'value-desc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'auto'
,p_overview_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000030000004)
,p_chart_id=>wwv_flow_imp.id(3000000030000003)
,p_static_id=>'s-fund-reserve'
,p_seq=>10
,p_name=>unistr('\CD1D \C801\B9BD\AE08(\C6D0)')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT FUND_NAME, SUM(TOT_AMT) TOT_AMT',
'FROM SOE.RESERVES_AMT',
'WHERE DT = (SELECT MAX(DT) FROM SOE.RESERVES_AMT)',
'GROUP BY FUND_NAME',
'ORDER BY TOT_AMT DESC',
'FETCH FIRST 15 ROWS ONLY'))
,p_series_type=>'bar'
,p_items_value_column_name=>'TOT_AMT'
,p_items_label_column_name=>'FUND_NAME'
,p_color=>'#4884C4'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000030000007)
,p_chart_id=>wwv_flow_imp.id(3000000030000003)
,p_static_id=>'x'
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000030000008)
,p_chart_id=>wwv_flow_imp.id(3000000030000003)
,p_static_id=>'y'
,p_axis=>'y'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);
end;
/
prompt --application/pages/page_00040
begin
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>'Data Product Contract'
,p_alias=>'DATA-PRODUCT-CONTRACT'
,p_step_title=>'Data Product Contract'
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
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000003)
,p_plug_name=>unistr('\C6D4\BCC4 \D574\C57D \CD94\C774')
,p_static_id=>unistr('\C6D4\BCC4-\D574\C57D-\CD94\C774')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141224537086826100463)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000040000004)
,p_region_id=>wwv_flow_imp.id(3000000040000003)
,p_chart_type=>'line'
,p_height=>'300'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'auto'
,p_overview_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000040000005)
,p_chart_id=>wwv_flow_imp.id(3000000040000004)
,p_static_id=>'s-cancel-monthly'
,p_seq=>10
,p_name=>unistr('\D574\C57D \AC74\C218')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT SUBSTR(DT,1,6) YM, COUNT(*) CNT',
'FROM SOE.CANCELAMT',
'GROUP BY SUBSTR(DT,1,6)',
'ORDER BY YM'))
,p_series_type=>'line'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'YM'
,p_color=>'#ED6647'
,p_line_style=>'solid'
,p_line_type=>'auto'
,p_marker_rendered=>'auto'
,p_marker_shape=>'auto'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000040000008)
,p_chart_id=>wwv_flow_imp.id(3000000040000004)
,p_static_id=>'x'
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000040000009)
,p_chart_id=>wwv_flow_imp.id(3000000040000004)
,p_static_id=>'y'
,p_axis=>'y'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000006)
,p_plug_name=>unistr('\D574\C57D \C0C1\C138 \B0B4\C5ED')
,p_static_id=>unistr('\D574\C57D-\C0C1\C138-\B0B4\C5ED')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141224534987666100461)
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  DT "\B0A0\C9DC",'),
unistr('  CUST_ID "\ACE0\AC1DID",'),
unistr('  CUST_NM "\ACE0\AC1D\BA85",'),
unistr('  OP_NAME "\AC70\B798\C720\D615",'),
unistr('  TO_CHAR(TOT_AMT,''FM999,999,999,999'') "\D574\C57D\AE08\C561(\C6D0)",'),
unistr('  FUND_CODE "\D380\B4DC\CF54\B4DC",'),
unistr('  FUND_NAME "\D380\B4DC\BA85",'),
unistr('  CALL_CNT_3M "\CF5C\D69F\C218(3\AC1C\C6D4)",'),
unistr('  LATE_PMT_CNT "\C5F0\CCB4\AC74\C218",'),
unistr('  CONSULT_TEXT "\C0C1\B2F4\B0B4\C6A9"'),
'FROM V_INS_CANCEL',
'ORDER BY DT DESC, CUST_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000040000007)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000040000007
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000040000010)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300400'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\B0A0\C9DC":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\AC70\B798\C720\D615":"\D574\C57D\AE08\C561(\C6D0)":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"\CF5C\D69F\C218(3\AC1C\C6D4)":"\C5F0\CCB4\AC74\C218":"\C0C1\B2F4\B0B4\C6A9"')
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(3000000040000002)
,p_name=>unistr('\D574\C57D \D604\D669 \C694\C57D')
,p_static_id=>unistr('\D574\C57D-\D604\D669-\C694\C57D')
,p_template=>wwv_flow_imp.id(141224537086826100463)
,p_display_sequence=>10
,p_region_css_classes=>'codex-kpi-cards'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('SELECT ''\CD1D \D574\C57D \AC74\C218'' LABEL, TO_CHAR(COUNT(*),''FM999,999'') VALUE, ''fa-times-circle'' ICON, ''u-color-1'' COLOR'),
'FROM SOE.CANCELAMT',
'UNION ALL',
unistr('SELECT ''\CD1D \D574\C57D \AE08\C561(\C6D0)'', TO_CHAR(NVL(SUM(TOT_AMT),0),''FM999,999,999,999''), ''fa-won'', ''u-color-2'''),
'FROM SOE.CANCELAMT',
'UNION ALL',
unistr('SELECT ''\D3C9\ADE0 \CF5C \D69F\C218'', TO_CHAR(ROUND(AVG(CALL_CNT_3M),1),''FM999.9''), ''fa-phone'', ''u-color-3'''),
'FROM SOE.CANCELAMT',
'UNION ALL',
unistr('SELECT ''\D3C9\ADE0 \C5F0\CCB4 \AC74\C218'', TO_CHAR(ROUND(AVG(LATE_PMT_CNT),1),''FM999.9''), ''fa-warning'', ''u-color-4'''),
'FROM SOE.CANCELAMT'))
,p_query_num_rows=>4
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('\D574\C57D \B370\C774\D130 \C5C6\C74C')
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534846838643845)
,p_query_column_id=>4
,p_column_alias=>'COLOR'
,p_column_display_sequence=>4
,p_column_heading=>'COLOR'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534752588643845)
,p_query_column_id=>3
,p_column_alias=>'ICON'
,p_column_display_sequence=>3
,p_column_heading=>'ICON'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534596314643845)
,p_query_column_id=>1
,p_column_alias=>'LABEL'
,p_column_display_sequence=>1
,p_column_heading=>unistr('\C9C0\D45C')
,p_column_html_expression=>'<div class="codex-kpi-card codex-kpi-#COLOR#"><span class="codex-kpi-icon fa #ICON# #COLOR#" aria-hidden="true"></span><span><span class="codex-kpi-label">#LABEL#</span><span class="codex-kpi-value">#VALUE#</span></span></div>'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534685580643845)
,p_query_column_id=>2
,p_column_alias=>'VALUE'
,p_column_display_sequence=>2
,p_column_heading=>'VALUE'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00050
begin
wwv_flow_imp_page.create_page(
 p_id=>50
,p_name=>'Proxy Status'
,p_alias=>'PROXY-STATUS'
,p_step_title=>'Proxy Status'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141224395776044100412)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141224549516983100476)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141224639726200100580)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000005)
,p_plug_name=>unistr('\BCF4\D5D8 \C0C1\D488 \BAA9\B85D')
,p_static_id=>unistr('\BCF4\D5D8-\C0C1\D488-\BAA9\B85D')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141224534987666100461)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  CATEGORY "\CE74\D14C\ACE0\B9AC",'),
unistr('  PRODUCT_CODE "\C0C1\D488\CF54\B4DC",'),
unistr('  PRODUCT "\C0C1\D488\BA85",'),
unistr('  DES "\C0C1\D488\C124\BA85",'),
'  CASE GUBUN',
unistr('    WHEN ''D'' THEN ''\C801\B9BD\D615'''),
unistr('    WHEN ''A'' THEN ''\C548\C815\D615'''),
unistr('    WHEN ''S'' THEN ''\D2B9\BCC4\D615'''),
unistr('    ELSE GUBUN END "\C720\D615",'),
unistr('  CREATED "\CD9C\C2DC\C77C"'),
'FROM SOE.PRODUCT',
'ORDER BY CATEGORY, PRODUCT_CODE'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000050000006)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000050000006
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000050000007)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300500'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\CE74\D14C\ACE0\B9AC":"\C0C1\D488\CF54\B4DC":"\C0C1\D488\BA85":"\C0C1\D488\C124\BA85":"\C720\D615":"\CD9C\C2DC\C77C"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000002)
,p_plug_name=>unistr('\C0C1\D488 \CE74\D14C\ACE0\B9AC \BD84\D3EC')
,p_static_id=>unistr('\C0C1\D488-\CE74\D14C\ACE0\B9AC-\BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141224537086826100463)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000050000003)
,p_region_id=>wwv_flow_imp.id(3000000050000002)
,p_chart_type=>'donut'
,p_height=>'300'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_stack_label=>'off'
,p_connect_nulls=>'Y'
,p_value_format_scaling=>'auto'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'auto'
,p_overview_rendered=>'off'
,p_pie_other_threshold=>0
,p_pie_selection_effect=>'highlight'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000050000004)
,p_chart_id=>wwv_flow_imp.id(3000000050000003)
,p_static_id=>'s-product-cat'
,p_seq=>10
,p_name=>unistr('\CE74\D14C\ACE0\B9AC\BCC4 \C0C1\D488\C218')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CATEGORY, COUNT(*) CNT',
'FROM SOE.PRODUCT',
'GROUP BY CATEGORY',
'ORDER BY CNT DESC'))
,p_series_type=>'pie'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'CATEGORY'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
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
,p_step_template=>wwv_flow_imp.id(141224387675508100405)
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
,p_plug_template=>wwv_flow_imp.id(141224579733387100500)
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
