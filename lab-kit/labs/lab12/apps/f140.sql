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
,p_default_id_offset=>15025090908249811
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - 보험 SIU 그래프 조사 시스템
--
-- Application Export:
--   Application:     300
--   Name:            보험 SIU 그래프 조사 시스템
--   Date and Time:   05:33 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      7
--       Items:                    5
--       Processes:                3
--       Regions:                 17
--       Buttons:                  2
--     Shared Components:
--       Logic:
--       Navigation:
--         Lists:                  2
--         Breadcrumbs:            1
--           Entries:              5
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
--   Instance ID:     956234216184939
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,unistr('\BCF4\D5D8 SIU \ADF8\B798\D504 \C870\C0AC \C2DC\C2A4\D15C'))
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'SIU-GRAPH')
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
,p_logo_text=>unistr('\BCF4\D5D8 SIU')
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
,p_version_scn=>'77589045'
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
,p_navigation_list_template_id=>wwv_flow_imp.id(130526769213962579)
,p_nav_list_template_options=>'#DEFAULT#:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(130526317361962579)
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
,p_version_scn=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(10521619010821)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('\C870\C0AC \C774\B825')
,p_static_id=>'nav-actions'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-history'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'40'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(2405225000024)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(10494401010821)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('Graph SQL \D0D0\C9C0')
,p_static_id=>'nav-detection'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-code-fork'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'30'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(10378913010820)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\AD00\ACC4 \ADF8\B798\D504')
,p_static_id=>'nav-graph'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-share-alt'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'20'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(10252495010820)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\C870\C0AC \D050')
,p_static_id=>'nav-queue'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-search'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'10'
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
 p_id=>wwv_flow_imp.id(11085456010838)
,p_short_name=>unistr('\C870\C0AC \C774\B825')
,p_static_id=>'bc-actions'
,p_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
,p_page_id=>40
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(10649430010837)
,p_short_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'bc-dashboard'
,p_link=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(10925027010838)
,p_short_name=>unistr('Graph SQL \D0D0\C9C0')
,p_static_id=>'bc-detection'
,p_link=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
,p_page_id=>30
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(10850087010838)
,p_short_name=>unistr('\AD00\ACC4 \ADF8\B798\D504')
,p_static_id=>'bc-graph'
,p_link=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
,p_page_id=>20
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(10726783010838)
,p_short_name=>unistr('\C870\C0AC \D050')
,p_static_id=>'bc-queue'
,p_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
,p_page_id=>10
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
,p_default_page_template=>wwv_flow_imp.id(130389000191962451)
,p_default_dialog_template=>wwv_flow_imp.id(130383858358962445)
,p_error_template=>wwv_flow_imp.id(130373818880962435)
,p_printer_friendly_template=>wwv_flow_imp.id(130389000191962451)
,p_login_template=>wwv_flow_imp.id(130373818880962435)
,p_default_button_template=>wwv_flow_imp.id(130538904716962588)
,p_default_region_template=>wwv_flow_imp.id(130465791869962537)
,p_default_chart_template=>wwv_flow_imp.id(130465791869962537)
,p_default_form_template=>wwv_flow_imp.id(130465791869962537)
,p_default_reportr_template=>wwv_flow_imp.id(130465791869962537)
,p_default_wizard_template=>wwv_flow_imp.id(130465791869962537)
,p_default_menur_template=>wwv_flow_imp.id(130478159299962546)
,p_default_listr_template=>wwv_flow_imp.id(130465791869962537)
,p_default_irr_template=>wwv_flow_imp.id(130455954780962529)
,p_default_report_template=>wwv_flow_imp.id(130503926375962563)
,p_default_label_template=>wwv_flow_imp.id(130536491170962586)
,p_default_menu_template=>wwv_flow_imp.id(130540569370962589)
,p_default_list_template=>wwv_flow_imp.id(130520364165962575)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(130532153385962583)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(130526769213962579)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(130401942659962473)
,p_default_dialogr_template=>wwv_flow_imp.id(130399159379962469)
,p_default_option_label=>wwv_flow_imp.id(130536491170962586)
,p_default_required_label=>wwv_flow_imp.id(130537718108962587)
,p_default_navbar_list_template=>wwv_flow_imp.id(130526317361962579)
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
,p_name=>unistr('SIU \B300\C2DC\BCF4\B4DC')
,p_alias=>'DASHBOARD'
,p_step_title=>unistr('\BCF4\D5D8 SIU \ADF8\B798\D504 \C870\C0AC \C2DC\C2A4\D15C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'.siu-badge{display:inline-flex;align-items:center;min-width:54px;justify-content:center;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700}',
'.siu-p1{background:#fee2e2;color:#991b1b}.siu-p2{background:#ffedd5;color:#9a3412}.siu-p3{background:#fef3c7;color:#92400e}.siu-normal{background:#dcfce7;color:#166534}',
'.siu-status{font-weight:700;color:#0f172a}.siu-muted{color:#64748b;font-size:12px}.siu-money{font-variant-numeric:tabular-nums}',
'.siu-actions{display:flex;gap:6px;flex-wrap:wrap}.siu-actions .t-Button{white-space:nowrap}',
'.siu-kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px}',
'.siu-kpi .cell{border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#fff}',
'.siu-kpi .v{font-size:22px;font-weight:800;color:#111827}.siu-kpi .l{font-size:12px;color:#64748b}',
'.t-Report-report,.a-IRR-table{table-layout:auto}.t-Report-cell,.a-IRR-table td{vertical-align:top}',
''))
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11284220010839)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(130540569370962589)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12424489010840)
,p_plug_name=>unistr('\ADF8\B798\D504 \C870\C0AC \B124\D2B8\C6CC\D06C')
,p_static_id=>'siu-dashboard-graph'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>40
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sys.htp.prn(dbms_lob.substr(soe.siu_pkg.graph_html(null), 32000, 1));',
'end;'))
,p_plug_source_type=>'NATIVE_PLSQL'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(11453147010840)
,p_name=>unistr('\ACE0\C704\D5D8 \C870\C0AC \D050')
,p_static_id=>'siu-dashboard-high-risk'
,p_template=>wwv_flow_imp.id(130465791869962537)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ''<span class="siu-badge '' ||',
'       case risk_grade when ''P1'' then ''siu-p1'' when ''P2'' then ''siu-p2'' when ''P3'' then ''siu-p3'' else ''siu-normal'' end ||',
unistr('       ''">'' || risk_grade || ''</span>'' "\B4F1\AE09",'),
unistr('       claim_no "\CCAD\AD6C\BC88\D638",'),
unistr('       customer_name "\ACE0\AC1D",'),
unistr('       claim_type "\CCAD\AD6C\C720\D615",'),
unistr('       provider_name "\AE30\AD00/\C5C5\CCB4",'),
unistr('       ''<span class="siu-money">'' || to_char(claimed_amount, ''FM999G999G999G990'') || ''</span>'' "\CCAD\AD6C\AE08\C561",'),
unistr('       risk_score "\C810\C218",'),
unistr('       fraud_pattern "\D0D0\C9C0\D328\D134",'),
unistr('       investigation_status "\C0C1\D0DC"'),
'  from soe.siu_claim_case_v',
' where risk_grade in (''P1'',''P2'',''P3'')',
' order by risk_score desc, claimed_amount desc'))
,p_query_row_template=>wwv_flow_imp.id(130503926375962563)
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11718125010840)
,p_query_column_id=>3
,p_column_alias=>unistr('\ACE0\AC1D')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\ACE0\AC1D')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11996249010840)
,p_query_column_id=>5
,p_column_alias=>unistr('\AE30\AD00/\C5C5\CCB4')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\AE30\AD00/\C5C5\CCB4')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11514934010840)
,p_query_column_id=>1
,p_column_alias=>unistr('\B4F1\AE09')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\B4F1\AE09')
,p_column_html_expression=>unistr('#\B4F1\AE09#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(12322773010840)
,p_query_column_id=>9
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(12113488010840)
,p_query_column_id=>7
,p_column_alias=>unistr('\C810\C218')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C810\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(12058821010840)
,p_query_column_id=>6
,p_column_alias=>unistr('\CCAD\AD6C\AE08\C561')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\CCAD\AD6C\AE08\C561')
,p_column_html_expression=>unistr('#\CCAD\AD6C\AE08\C561#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11688580010840)
,p_query_column_id=>2
,p_column_alias=>unistr('\CCAD\AD6C\BC88\D638')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\CCAD\AD6C\BC88\D638')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11908171010840)
,p_query_column_id=>4
,p_column_alias=>unistr('\CCAD\AD6C\C720\D615')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\CCAD\AD6C\C720\D615')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(12273398010840)
,p_query_column_id=>8
,p_column_alias=>unistr('\D0D0\C9C0\D328\D134')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\D0D0\C9C0\D328\D134')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11360247010840)
,p_plug_name=>unistr('\C870\C0AC KPI')
,p_static_id=>'siu-kpi-html'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_html clob := ''<div class="siu-kpi">'';',
'begin',
'  for r in (select * from soe.siu_dashboard_kpi_v order by seq) loop',
'    l_html := l_html || ''<div class="cell"><div class="v">'' || apex_escape.html(r.value) ||',
'      ''</div><div class="l"><span class="fa '' || apex_escape.html_attribute(r.icon) || ''"></span> '' ||',
'      apex_escape.html(r.label) || ''</div></div>'';',
'  end loop;',
'  sys.htp.prn(l_html || ''</div>'');',
'end;'))
,p_plug_source_type=>'NATIVE_PLSQL'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\C870\C0AC \D050')
,p_alias=>'QUEUE'
,p_step_title=>unistr('\C870\C0AC \D050')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'.siu-badge{display:inline-flex;align-items:center;min-width:54px;justify-content:center;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700}',
'.siu-p1{background:#fee2e2;color:#991b1b}.siu-p2{background:#ffedd5;color:#9a3412}.siu-p3{background:#fef3c7;color:#92400e}.siu-normal{background:#dcfce7;color:#166534}',
'.siu-status{font-weight:700;color:#0f172a}.siu-muted{color:#64748b;font-size:12px}.siu-money{font-variant-numeric:tabular-nums}',
'.siu-actions{display:flex;gap:6px;flex-wrap:wrap}.siu-actions .t-Button{white-space:nowrap}',
'.siu-kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px}',
'.siu-kpi .cell{border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#fff}',
'.siu-kpi .v{font-size:22px;font-weight:800;color:#111827}.siu-kpi .l{font-size:12px;color:#64748b}',
'.t-Report-report,.a-IRR-table{table-layout:auto}.t-Report-cell,.a-IRR-table td{vertical-align:top}',
''))
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12704730010840)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(130540569370962589)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13087662010841)
,p_plug_name=>unistr('SIU \C870\C0AC \B300\C0C1 \CCAD\AD6C')
,p_static_id=>'siu-claim-queue-ir'
,p_plug_template=>wwv_flow_imp.id(130455954780962529)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select claim_key "Claim Key",',
'       ''<span class="siu-badge '' ||',
'       case risk_grade when ''P1'' then ''siu-p1'' when ''P2'' then ''siu-p2'' when ''P3'' then ''siu-p3'' else ''siu-normal'' end ||',
unistr('       ''">'' || risk_grade || ''</span>'' "\B4F1\AE09",'),
unistr('       claim_no "\CCAD\AD6C\BC88\D638",'),
'       source_system "Source",',
unistr('       customer_id "\ACE0\AC1DID",'),
unistr('       customer_name "\ACE0\AC1D",'),
unistr('       phone_no "\C5F0\B77D\CC98",'),
unistr('       product_code "\C0C1\D488",'),
unistr('       claim_type "\CCAD\AD6C\C720\D615",'),
unistr('       incident_date "\C0AC\ACE0\C77C",'),
unistr('       received_at "\C811\C218\C2DC\AC01",'),
unistr('       claimed_amount "\CCAD\AD6C\AE08\C561",'),
unistr('       provider_name "\AE30\AD00/\C5C5\CCB4",'),
unistr('       provider_risk_tier "\AE30\AD00\C704\D5D8",'),
unistr('       account_owner "\C218\CDE8\ACC4\C88C",'),
unistr('       account_customer_count "\ACC4\C88C\ACF5\C720",'),
unistr('       shared_contact_count "\C5F0\B77D\CC98\ACF5\C720",'),
unistr('       risk_score "\C704\D5D8\C810\C218",'),
unistr('       fraud_pattern "\D0D0\C9C0\D328\D134",'),
unistr('       investigation_status "\C870\C0AC\C0C1\D0DC",'),
'       ''<span class="siu-actions"><a class="t-Button t-Button--small" href="'' ||',
'       apex_page.get_url(p_page => 10, p_items => ''P10_ACTION,P10_CLAIM_KEY'', p_values => ''OPEN,'' || claim_key) ||',
unistr('       ''"><span class="fa fa-search"></span>\C870\C0AC\AC1C\C2DC</a><a class="t-Button t-Button--small" href="'' ||'),
'       apex_page.get_url(p_page => 10, p_items => ''P10_ACTION,P10_CLAIM_KEY'', p_values => ''CLOSE,'' || claim_key) ||',
unistr('       ''"><span class="fa fa-check"></span>\C885\ACB0</a></span>'' "\CC98\B9AC"'),
'  from soe.siu_claim_case_v',
' order by risk_score desc, received_at desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(13180931010841)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>15038271839260652
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(13262374010841)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'SIU14010'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"Claim Key":"\B4F1\AE09":"\CCAD\AD6C\BC88\D638":"Source":"\ACE0\AC1DID":"\ACE0\AC1D":"\C5F0\B77D\CC98":"\C0C1\D488":"\CCAD\AD6C\C720\D615":"\C0AC\ACE0\C77C":"\C811\C218\C2DC\AC01":"\CCAD\AD6C\AE08\C561":"\AE30\AD00/\C5C5\CCB4":"\AE30\AD00\C704\D5D8":"\C218\CDE8\ACC4\C88C":"\ACC4\C88C\ACF5\C720":"\C5F0\B77D\CC98\ACF5\C720":"\C704\D5D8\C810\C218":"\D0D0\C9C0\D328\D134":"\C870\C0AC\C0C1\D0DC":"\CC98\B9AC"')
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12780344010840)
,p_name=>'P10_ACTION'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12848118010841)
,p_name=>'P10_CLAIM_KEY'
,p_item_sequence=>20
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12930363010841)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run SIU Queue Action'
,p_static_id=>'run-siu-queue-action'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P10_ACTION = ''OPEN'' and :P10_CLAIM_KEY is not null then',
'    soe.siu_pkg.open_case(:P10_CLAIM_KEY, :APP_USER);',
'  elsif :P10_ACTION = ''CLOSE'' and :P10_CLAIM_KEY is not null then',
'    soe.siu_pkg.close_case(:P10_CLAIM_KEY, :APP_USER);',
'  end if;',
'  :P10_ACTION := null;',
'  :P10_CLAIM_KEY := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>15038021271260652
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>unistr('\AD00\ACC4 \ADF8\B798\D504')
,p_alias=>'RELATIONSHIP-GRAPH'
,p_step_title=>unistr('\AD00\ACC4 \ADF8\B798\D504')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'.siu-badge{display:inline-flex;align-items:center;min-width:54px;justify-content:center;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700}',
'.siu-p1{background:#fee2e2;color:#991b1b}.siu-p2{background:#ffedd5;color:#9a3412}.siu-p3{background:#fef3c7;color:#92400e}.siu-normal{background:#dcfce7;color:#166534}',
'.siu-status{font-weight:700;color:#0f172a}.siu-muted{color:#64748b;font-size:12px}.siu-money{font-variant-numeric:tabular-nums}',
'.siu-actions{display:flex;gap:6px;flex-wrap:wrap}.siu-actions .t-Button{white-space:nowrap}',
'.siu-kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px}',
'.siu-kpi .cell{border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#fff}',
'.siu-kpi .v{font-size:22px;font-weight:800;color:#111827}.siu-kpi .l{font-size:12px;color:#64748b}',
'.t-Report-report,.a-IRR-table{table-layout:auto}.t-Report-cell,.a-IRR-table td{vertical-align:top}',
''))
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13411180010842)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(130540569370962589)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(13965103010843)
,p_name=>unistr('\ADF8\B798\D504 Edge \BAA9\B85D')
,p_static_id=>'siu-graph-edge-report'
,p_template=>wwv_flow_imp.id(130465791869962537)
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select source_type "\CD9C\BC1C\C720\D615",'),
unistr('       source_name "\CD9C\BC1C\B178\B4DC",'),
unistr('       relation_name "\AD00\ACC4",'),
unistr('       target_type "\B3C4\CC29\C720\D615",'),
unistr('       target_name "\B3C4\CC29\B178\B4DC",'),
unistr('       evidence_text "\ADFC\AC70"'),
'  from soe.siu_graph_edge_v',
' order by source_type, source_name, relation_name'))
,p_query_row_template=>wwv_flow_imp.id(130503926375962563)
,p_query_num_rows=>40
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14282722010843)
,p_query_column_id=>3
,p_column_alias=>unistr('\AD00\ACC4')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\AD00\ACC4')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14532652010843)
,p_query_column_id=>6
,p_column_alias=>unistr('\ADFC\AC70')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\ADFC\AC70')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14508632010843)
,p_query_column_id=>5
,p_column_alias=>unistr('\B3C4\CC29\B178\B4DC')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\B3C4\CC29\B178\B4DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14370051010843)
,p_query_column_id=>4
,p_column_alias=>unistr('\B3C4\CC29\C720\D615')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\B3C4\CC29\C720\D615')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14187004010843)
,p_query_column_id=>2
,p_column_alias=>unistr('\CD9C\BC1C\B178\B4DC')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\CD9C\BC1C\B178\B4DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14050386010843)
,p_query_column_id=>1
,p_column_alias=>unistr('\CD9C\BC1C\C720\D615')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CD9C\BC1C\C720\D615')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13597793010842)
,p_plug_name=>unistr('\ADF8\B798\D504 \D544\D130')
,p_static_id=>'siu-graph-filter'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13907139010843)
,p_plug_name=>unistr('\AD00\ACC4 \B124\D2B8\C6CC\D06C')
,p_static_id=>'siu-graph-html'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>30
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sys.htp.prn(dbms_lob.substr(soe.siu_pkg.graph_html(:P20_CLAIM_NO), 32000, 1));',
'end;'))
,p_plug_source_type=>'NATIVE_PLSQL'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(13793837010843)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(13597793010842)
,p_button_name=>'APPLY_GRAPH_FILTER'
,p_static_id=>'apply-graph-filter'
,p_button_action=>'SUBMIT'
,p_button_template_id=>wwv_flow_imp.id(130538904716962588)
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('\C870\D68C')
,p_button_position=>'NEXT'
,p_show_processing=>'Y'
,p_icon_css_classes=>'fa-refresh'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13623618010842)
,p_name=>'P20_CLAIM_NO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(13597793010842)
,p_prompt=>unistr('\CCAD\AD6C\BC88\D638')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select claim_no || '' \00B7 '' || customer_name || '' \00B7 '' || risk_grade d, claim_no r'),
'  from soe.siu_claim_case_v',
' order by risk_score desc, claim_no'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>unistr('\C804\CCB4 \B124\D2B8\C6CC\D06C')
,p_field_template=>wwv_flow_imp.id(130536491170962586)
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
,p_lov_display_extra=>'NO'
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('Graph SQL \D0D0\C9C0')
,p_alias=>'GRAPH-SQL-DETECTION'
,p_step_title=>unistr('Graph SQL \D0D0\C9C0')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'.siu-badge{display:inline-flex;align-items:center;min-width:54px;justify-content:center;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700}',
'.siu-p1{background:#fee2e2;color:#991b1b}.siu-p2{background:#ffedd5;color:#9a3412}.siu-p3{background:#fef3c7;color:#92400e}.siu-normal{background:#dcfce7;color:#166534}',
'.siu-status{font-weight:700;color:#0f172a}.siu-muted{color:#64748b;font-size:12px}.siu-money{font-variant-numeric:tabular-nums}',
'.siu-actions{display:flex;gap:6px;flex-wrap:wrap}.siu-actions .t-Button{white-space:nowrap}',
'.siu-kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px}',
'.siu-kpi .cell{border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#fff}',
'.siu-kpi .v{font-size:22px;font-weight:800;color:#111827}.siu-kpi .l{font-size:12px;color:#64748b}',
'.t-Report-report,.a-IRR-table{table-layout:auto}.t-Report-cell,.a-IRR-table td{vertical-align:top}',
''))
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14765515010843)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(130540569370962589)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(15005758010843)
,p_name=>unistr('\ADF8\B798\D504 \D0D0\C9C0 \ACB0\ACFC')
,p_static_id=>'siu-detection-report'
,p_template=>wwv_flow_imp.id(130465791869962537)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select detection_type "\D0D0\C9C0\C720\D615",'),
unistr('       risk_grade "\B4F1\AE09",'),
unistr('       risk_score "\C810\C218",'),
unistr('       customer_count "\ACE0\AC1D\C218",'),
unistr('       claim_count "\CCAD\AD6C\C218",'),
unistr('       to_char(suspicious_amount, ''FM999G999G999G990'') "\C758\C2EC\AE08\C561",'),
unistr('       nvl(provider_name, ''-'') "\AE30\AD00/\C5C5\CCB4",'),
unistr('       nvl(account_owner, ''-'') "\ACC4\C88C",'),
unistr('       nvl(contact_value, ''-'') "\C5F0\B77D\CC98/\C8FC\C18C",'),
unistr('       evidence_text "\ADFC\AC70"'),
'  from soe.siu_graph_detection_v',
' order by risk_score desc, suspicious_amount desc'))
,p_query_row_template=>wwv_flow_imp.id(130503926375962563)
,p_query_num_rows=>30
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15770282010843)
,p_query_column_id=>8
,p_column_alias=>unistr('\ACC4\C88C')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\ACC4\C88C')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15327379010843)
,p_query_column_id=>4
,p_column_alias=>unistr('\ACE0\AC1D\C218')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\ACE0\AC1D\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15953526010844)
,p_query_column_id=>10
,p_column_alias=>unistr('\ADFC\AC70')
,p_column_display_sequence=>100
,p_column_heading=>unistr('\ADFC\AC70')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15675166010843)
,p_query_column_id=>7
,p_column_alias=>unistr('\AE30\AD00/\C5C5\CCB4')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\AE30\AD00/\C5C5\CCB4')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15141665010843)
,p_query_column_id=>2
,p_column_alias=>unistr('\B4F1\AE09')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\B4F1\AE09')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15891852010843)
,p_query_column_id=>9
,p_column_alias=>unistr('\C5F0\B77D\CC98/\C8FC\C18C')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\C5F0\B77D\CC98/\C8FC\C18C')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15553338010843)
,p_query_column_id=>6
,p_column_alias=>unistr('\C758\C2EC\AE08\C561')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C758\C2EC\AE08\C561')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15252919010843)
,p_query_column_id=>3
,p_column_alias=>unistr('\C810\C218')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C810\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15490477010843)
,p_query_column_id=>5
,p_column_alias=>unistr('\CCAD\AD6C\C218')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\CCAD\AD6C\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15078842010843)
,p_query_column_id=>1
,p_column_alias=>unistr('\D0D0\C9C0\C720\D615')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\D0D0\C9C0\C720\D615')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14850388010843)
,p_plug_name=>'Graph SQL'
,p_static_id=>'siu-graph-sql'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  sys.htp.prn(dbms_lob.substr(soe.siu_pkg.sql_html, 32000, 1));',
'end;'))
,p_plug_source_type=>'NATIVE_PLSQL'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(16098600010844)
,p_name=>unistr('\ACE0\AC1D\BCC4 \C704\D5D8\C694\C778')
,p_static_id=>'siu-risk-factor-report'
,p_template=>wwv_flow_imp.id(130465791869962537)
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select claim_no "\CCAD\AD6C\BC88\D638",'),
unistr('       customer_name "\ACE0\AC1D",'),
unistr('       factor_type "\C704\D5D8\C694\C778",'),
unistr('       factor_target "\B300\C0C1",'),
unistr('       factor_count "\C5F0\ACB0\C218",'),
unistr('       factor_score "\AC00\C810",'),
unistr('       evidence_text "\ADFC\AC70"'),
'  from soe.siu_risk_factor_v',
' order by factor_score desc, claim_no'))
,p_query_row_template=>wwv_flow_imp.id(130503926375962563)
,p_query_num_rows=>40
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16672051010844)
,p_query_column_id=>6
,p_column_alias=>unistr('\AC00\C810')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\AC00\C810')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16214543010844)
,p_query_column_id=>2
,p_column_alias=>unistr('\ACE0\AC1D')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\ACE0\AC1D')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16794535010844)
,p_query_column_id=>7
,p_column_alias=>unistr('\ADFC\AC70')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\ADFC\AC70')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16429683010844)
,p_query_column_id=>4
,p_column_alias=>unistr('\B300\C0C1')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\B300\C0C1')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16573668010844)
,p_query_column_id=>5
,p_column_alias=>unistr('\C5F0\ACB0\C218')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C5F0\ACB0\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16331553010844)
,p_query_column_id=>3
,p_column_alias=>unistr('\C704\D5D8\C694\C778')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C704\D5D8\C694\C778')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16149983010844)
,p_query_column_id=>1
,p_column_alias=>unistr('\CCAD\AD6C\BC88\D638')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CCAD\AD6C\BC88\D638')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00040
begin
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>unistr('\C870\C0AC \C774\B825')
,p_alias=>'ACTIONS'
,p_step_title=>unistr('\C870\C0AC \C774\B825')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'.siu-badge{display:inline-flex;align-items:center;min-width:54px;justify-content:center;border-radius:999px;padding:3px 8px;font-size:12px;font-weight:700}',
'.siu-p1{background:#fee2e2;color:#991b1b}.siu-p2{background:#ffedd5;color:#9a3412}.siu-p3{background:#fef3c7;color:#92400e}.siu-normal{background:#dcfce7;color:#166534}',
'.siu-status{font-weight:700;color:#0f172a}.siu-muted{color:#64748b;font-size:12px}.siu-money{font-variant-numeric:tabular-nums}',
'.siu-actions{display:flex;gap:6px;flex-wrap:wrap}.siu-actions .t-Button{white-space:nowrap}',
'.siu-kpi{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px}',
'.siu-kpi .cell{border:1px solid #cbd5e1;border-radius:8px;padding:12px;background:#fff}',
'.siu-kpi .v{font-size:22px;font-weight:800;color:#111827}.siu-kpi .l{font-size:12px;color:#64748b}',
'.t-Report-report,.a-IRR-table{table-layout:auto}.t-Report-cell,.a-IRR-table td{vertical-align:top}',
''))
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(16945586010844)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(130540569370962589)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(17081522010844)
,p_name=>unistr('SIU \C870\CE58 \C774\B825')
,p_static_id=>'siu-action-report'
,p_template=>wwv_flow_imp.id(130465791869962537)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select action_id "\C774\B825ID",'),
unistr('       action_at "\C870\CE58\C2DC\AC01",'),
unistr('       claim_no "\CCAD\AD6C\BC88\D638",'),
unistr('       customer_name "\ACE0\AC1D",'),
unistr('       risk_grade "\B4F1\AE09",'),
unistr('       risk_score "\C810\C218",'),
unistr('       action_type "\C870\CE58",'),
unistr('       action_status "\C0C1\D0DC",'),
unistr('       action_owner "\B2F4\B2F9\C790",'),
unistr('       action_note "\BA54\BAA8"'),
'  from soe.siu_investigation_action_v',
' order by action_at desc, action_id desc'))
,p_query_row_template=>wwv_flow_imp.id(130503926375962563)
,p_query_num_rows=>40
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17487560010844)
,p_query_column_id=>4
,p_column_alias=>unistr('\ACE0\AC1D')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\ACE0\AC1D')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17967062010844)
,p_query_column_id=>9
,p_column_alias=>unistr('\B2F4\B2F9\C790')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\B2F4\B2F9\C790')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17519154010844)
,p_query_column_id=>5
,p_column_alias=>unistr('\B4F1\AE09')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\B4F1\AE09')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(18071770010844)
,p_query_column_id=>10
,p_column_alias=>unistr('\BA54\BAA8')
,p_column_display_sequence=>100
,p_column_heading=>unistr('\BA54\BAA8')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17889085010844)
,p_query_column_id=>8
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17200284010844)
,p_query_column_id=>1
,p_column_alias=>unistr('\C774\B825ID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C774\B825ID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17632250010844)
,p_query_column_id=>6
,p_column_alias=>unistr('\C810\C218')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C810\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17756856010844)
,p_query_column_id=>7
,p_column_alias=>unistr('\C870\CE58')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C870\CE58')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17291692010844)
,p_query_column_id=>2
,p_column_alias=>unistr('\C870\CE58\C2DC\AC01')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\C870\CE58\C2DC\AC01')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17379008010844)
,p_query_column_id=>3
,p_column_alias=>unistr('\CCAD\AD6C\BC88\D638')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\CCAD\AD6C\BC88\D638')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_09999
begin
wwv_flow_imp_page.create_page(
 p_id=>9999
,p_name=>unistr('\B85C\ADF8\C778')
,p_alias=>'LOGIN'
,p_step_title=>unistr('\BCF4\D5D8 SIU \B85C\ADF8\C778')
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
,p_step_template=>wwv_flow_imp.id(130389000191962451)
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'12'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000009999000001)
,p_plug_name=>unistr('\BCF4\D5D8 SIU \ADF8\B798\D504 \C870\C0AC \C2DC\C2A4\D15C')
,p_static_id=>unistr('\BCF4\D5D8-\C815\BCF4\ACC4-\C2DC\C2A4\D15C')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(130465791869962537)
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
,p_show_processing=>'Y'
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
@/home/oracle/labs/lab12/apps/repair_subscribed_theme.sql
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
