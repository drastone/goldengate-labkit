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
,p_default_id_offset=>10228337575640159
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - 콜센터 상담 시스템
--
-- Application Export:
--   Application:     300
--   Name:            콜센터 상담 시스템
--   Date and Time:   05:33 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      6
--       Items:                   28
--       Processes:                6
--       Regions:                 11
--       Buttons:                  4
--     Shared Components:
--       Logic:
--         Processes:              1
--       Navigation:
--         Lists:                  2
--         Breadcrumbs:            1
--           Entries:              3
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,unistr('\CF5C\C13C\D130 \C0C1\B2F4 \C2DC\C2A4\D15C'))
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'CALL-CENTER')
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
,p_authentication_id=>wwv_flow_imp.id(7228337574640159)
,p_application_tab_set=>1
,p_logo_type=>'T'
,p_logo_text=>unistr('\CF5C\C13C\D130 \C0C1\B2F4 \C2DC\C2A4\D15C')
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
,p_navigation_list_id=>wwv_flow_imp.id(7228337573640159)
,p_navigation_list_position=>'SIDE'
,p_navigation_list_template_id=>wwv_flow_imp.id(135323522546572231)
,p_nav_list_template_options=>'#DEFAULT#:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(7228337572640159)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(135323070694572231)
,p_nav_bar_template_options=>'#DEFAULT#'
);
end;
/
prompt --application/plugin_settings
begin
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303689285003677)
,p_plugin_type=>'DYNAMIC ACTION'
,p_plugin=>'NATIVE_OPEN_AI_ASSISTANT'
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303320675003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_COLOR_PICKER'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'mode', 'FULL')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303860738003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_DATE_PICKER_APEX'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'appearance_behavior', 'MONTH-PICKER:YEAR-PICKER:TODAY-BUTTON',
  'days_outside_month', 'VISIBLE',
  'show_on', 'FOCUS',
  'time_increment', '15')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303930276003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_GEOCODED_ADDRESS'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'background', 'default',
  'display_as', 'LIST',
  'map_preview', 'POPUP:ITEM',
  'match_mode', 'RELAX_HOUSE_NUMBER')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303202820003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_SELECT_MANY'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_values_as', 'separated')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1304450560003678)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_SINGLE_CHECKBOX'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'checked_value', 'Y',
  'unchecked_value', 'N')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303431263003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_STAR_RATING'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'default_icon', 'fa-star',
  'tooltip', '#VALUE#')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303518661003677)
,p_plugin_type=>'ITEM TYPE'
,p_plugin=>'NATIVE_YES_NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_style', 'SWITCH_CB',
  'off_value', 'N',
  'on_value', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1304335394003677)
,p_plugin_type=>'PROCESS TYPE'
,p_plugin=>'NATIVE_GEOCODING'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'match_mode', 'RELAX_HOUSE_NUMBER')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303643346003677)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_DISPLAY_SELECTOR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'include_slider', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303114286003677)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_IR'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'actions_menu_structure', 'IG')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1303973904003677)
,p_plugin_type=>'REGION TYPE'
,p_plugin=>'NATIVE_MAP_REGION'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'use_vector_tile_layers', 'Y')).to_clob
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1304192964003677)
,p_plugin_type=>'WEB SOURCE TYPE'
,p_plugin=>'NATIVE_ADFBC'
);
wwv_flow_imp_shared.create_plugin_setting(
 p_id=>wwv_flow_imp.id(1304124710003677)
,p_plugin_type=>'WEB SOURCE TYPE'
,p_plugin=>'NATIVE_BOSS'
);
end;
/
prompt --application/shared_components/navigation/lists/navigation_bar
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(7228337572640159)
,p_name=>'Navigation Bar'
,p_static_id=>'nav-bar-ins300'
,p_version_scn=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337572640158)
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
 p_id=>wwv_flow_imp.id(7228337573640159)
,p_name=>'Navigation Menu'
,p_static_id=>'nav-menu-ins300'
,p_version_scn=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(2051707341346617)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\ACE0\AC1D 360 \C870\D68C')
,p_static_id=>'nav-customer-360'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-users'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'10'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640158)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(2051837582346618)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\C74C\C131 \C0C1\B2F4 \C811\C218')
,p_static_id=>'nav-voice-stt'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-headset'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
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
prompt --application/shared_components/logic/application_processes/get_audio
begin
wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id(2051575920346617)
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_name=>'GET_AUDIO'
,p_static_id=>'get-audio'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_blob      blob;',
'  l_mime_type varchar2(200);',
'  l_filename  varchar2(512);',
'begin',
'  select audio_blob,',
'         nvl(audio_mime_type, ''audio/webm''),',
'         nvl(audio_file_name, ''call-center-recording.webm'')',
'    into l_blob, l_mime_type, l_filename',
'    from soe.call_center_audio_intake',
'   where intake_id = :P20_PLAY_INTAKE_ID',
'     and dbms_lob.getlength(audio_blob) > 0;',
'',
'  sys.htp.init;',
'  owa_util.mime_header(l_mime_type, false);',
'  sys.htp.p(''Content-Length: '' || dbms_lob.getlength(l_blob));',
'  sys.htp.p(''Content-Disposition: inline; filename="'' || replace(l_filename, ''"'', '''') || ''"'');',
'  sys.htp.p(''Cache-Control: private, max-age=300'');',
'  owa_util.http_header_close;',
'  wpg_docload.download_file(l_blob);',
'  apex_application.stop_apex_engine;',
'exception',
'  when apex_application.e_stop_apex_engine then',
'    raise;',
'  when no_data_found then',
'    sys.htp.init;',
'    owa_util.status_line(404, ''Not Found'');',
'    owa_util.mime_header(''text/plain'', false);',
'    owa_util.http_header_close;',
'    sys.htp.p(''Audio file not found.'');',
'    apex_application.stop_apex_engine;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>'MUST_NOT_BE_PUBLIC_USER'
);
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
 p_id=>wwv_flow_imp.id(7228337571640159)
,p_name=>'Breadcrumb'
,p_static_id=>'breadcrumb300'
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2052025184346625)
,p_short_name=>unistr('\ACE0\AC1D 360 \C870\D68C')
,p_static_id=>'bc-customer-360'
,p_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
,p_page_id=>10
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2051922832346625)
,p_short_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'bc-dashboard'
,p_link=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(2052073063346625)
,p_short_name=>unistr('\C74C\C131 \C0C1\B2F4 \C811\C218')
,p_static_id=>'bc-voice-stt'
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
 p_id=>wwv_flow_imp.id(7228337476640158)
,p_theme_id=>42
,p_static_id=>'universal-theme'
,p_theme_name=>'Universal Theme'
,p_theme_internal_name=>'UNIVERSAL_THEME'
,p_version_identifier=>'24.1'
,p_navigation_type=>'L'
,p_nav_bar_type=>'LIST'
,p_is_locked=>false
,p_current_theme_style_id=>wwv_flow_imp.id(7228337476640149)
,p_default_page_template=>wwv_flow_imp.id(135185753524572103)
,p_default_dialog_template=>wwv_flow_imp.id(135180611691572097)
,p_error_template=>wwv_flow_imp.id(135170572213572087)
,p_printer_friendly_template=>wwv_flow_imp.id(135185753524572103)
,p_login_template=>wwv_flow_imp.id(135170572213572087)
,p_default_button_template=>wwv_flow_imp.id(135335658049572240)
,p_default_region_template=>wwv_flow_imp.id(135262545202572189)
,p_default_chart_template=>wwv_flow_imp.id(135262545202572189)
,p_default_form_template=>wwv_flow_imp.id(135262545202572189)
,p_default_reportr_template=>wwv_flow_imp.id(135262545202572189)
,p_default_wizard_template=>wwv_flow_imp.id(135262545202572189)
,p_default_menur_template=>wwv_flow_imp.id(135274912632572198)
,p_default_listr_template=>wwv_flow_imp.id(135262545202572189)
,p_default_irr_template=>wwv_flow_imp.id(135252708113572181)
,p_default_report_template=>wwv_flow_imp.id(135300679708572215)
,p_default_label_template=>wwv_flow_imp.id(135333244503572238)
,p_default_menu_template=>wwv_flow_imp.id(135337322703572241)
,p_default_list_template=>wwv_flow_imp.id(135317117498572227)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(135328906718572235)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(135323522546572231)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(135198695992572125)
,p_default_dialogr_template=>wwv_flow_imp.id(135195912712572121)
,p_default_option_label=>wwv_flow_imp.id(135333244503572238)
,p_default_required_label=>wwv_flow_imp.id(135334471441572239)
,p_default_navbar_list_template=>wwv_flow_imp.id(135323070694572231)
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
 p_id=>wwv_flow_imp.id(7228337476640149)
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
 p_id=>wwv_flow_imp.id(7228337476640148)
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
 p_id=>wwv_flow_imp.id(7228337574640159)
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
,p_name=>unistr('\CF5C\C13C\D130 \B300\C2DC\BCF4\B4DC')
,p_alias=>'DASHBOARD'
,p_step_title=>unistr('\CF5C\C13C\D130 \C0C1\B2F4 \C2DC\C2A4\D15C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(135185753524572103)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2052287478346625)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(135337322703572241)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(2052401179346625)
,p_name=>unistr('\CF5C\C13C\D130 \C5C5\BB34 \C694\C57D')
,p_static_id=>'call-center-kpi'
,p_template=>wwv_flow_imp.id(135262545202572189)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select ''\C804\CCB4 \ACE0\AC1D'' "\C9C0\D45C", to_char(count(*), ''FM999,999,999'') "\AC12", ''\C0C1\B2F4\C0AC\AC00 \C870\D68C \AC00\B2A5\D55C \ACE0\AC1D'' "\C124\BA85" from soe.call_center_customer_360_v'),
unistr('union all select ''\C815\C0C1 \AC00\C785 \ACE0\AC1D'', to_char(sum(case when subscription_status = ''\C815\C0C1'' then 1 else 0 end), ''FM999,999,999''), ''\D604\C7AC \C720\C9C0 \C911\C778 \ACE0\AC1D'' from soe.call_center_customer_360_v'),
unistr('union all select ''\CD1D \C801\B9BD\AE08'', to_char(sum(total_reserve_amt), ''FM999,999,999,999''), ''\CD5C\ADFC \C794\ACE0 \AE30\C900'' from soe.call_center_customer_360_v'),
unistr('union all select ''\CD5C\ADFC 90\C77C \C0C1\B2F4'', to_char(sum(call_count_90d), ''FM999,999,999''), ''\CF5C\C13C\D130 \C0C1\B2F4 \C774\B825'' from soe.call_center_customer_360_v')))
,p_query_row_template=>wwv_flow_imp.id(135300679708572215)
,p_query_num_rows=>10
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2052590772346625)
,p_query_column_id=>2
,p_column_alias=>unistr('\AC12')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\AC12')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2052708745346625)
,p_query_column_id=>3
,p_column_alias=>unistr('\C124\BA85')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C124\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2052476707346625)
,p_query_column_id=>1
,p_column_alias=>unistr('\C9C0\D45C')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C9C0\D45C')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(2052780222346625)
,p_name=>unistr('\CD5C\ADFC \C0C1\B2F4 \C774\B825')
,p_static_id=>'recent-call-history'
,p_template=>wwv_flow_imp.id(135262545202572189)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select work_dt_ts "\C0C1\B2F4\C2DC\AC01", cust_id "\ACE0\AC1DID", cust_nm "\ACE0\AC1D\BA85", fp_id "\B2F4\B2F9FP",'),
unistr('       fund_name "\C0C1\D488", call_cnt_3m "3\AC1C\C6D4\CF5C\C218", late_pmt_cnt "\C5F0\CCB4\D69F\C218",'),
unistr('       substr(consult_text, 1, 180) "\C0C1\B2F4\B0B4\C6A9"'),
'  from soe.call_center_customer_call_v',
' order by work_dt_ts desc fetch first 20 rows only'))
,p_query_row_template=>wwv_flow_imp.id(135300679708572215)
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053414661346625)
,p_query_column_id=>6
,p_column_alias=>unistr('3\AC1C\C6D4\CF5C\C218')
,p_column_display_sequence=>60
,p_column_heading=>unistr('3\AC1C\C6D4\CF5C\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053002287346625)
,p_query_column_id=>2
,p_column_alias=>unistr('\ACE0\AC1DID')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\ACE0\AC1DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053097669346625)
,p_query_column_id=>3
,p_column_alias=>unistr('\ACE0\AC1D\BA85')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\ACE0\AC1D\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053191399346625)
,p_query_column_id=>4
,p_column_alias=>unistr('\B2F4\B2F9FP')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\B2F4\B2F9FP')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053640220346625)
,p_query_column_id=>8
,p_column_alias=>unistr('\C0C1\B2F4\B0B4\C6A9')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\C0C1\B2F4\B0B4\C6A9')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2052910464346625)
,p_query_column_id=>1
,p_column_alias=>unistr('\C0C1\B2F4\C2DC\AC01')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C0C1\B2F4\C2DC\AC01')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053345885346625)
,p_query_column_id=>5
,p_column_alias=>unistr('\C0C1\D488')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C0C1\D488')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2053466131346625)
,p_query_column_id=>7
,p_column_alias=>unistr('\C5F0\CCB4\D69F\C218')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C5F0\CCB4\D69F\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\ACE0\AC1D 360 \C870\D68C')
,p_alias=>'CUSTOMER-360'
,p_step_title=>unistr('\ACE0\AC1D 360 \C870\D68C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(135185753524572103)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2053767108346625)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(135337322703572241)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2053921556346625)
,p_plug_name=>unistr('\C804\CCB4 \ACE0\AC1D 360')
,p_static_id=>'customer-360-ir'
,p_plug_template=>wwv_flow_imp.id(135252708113572181)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select cust_id "\ACE0\AC1DID", cust_nm "\ACE0\AC1D\BA85", gender "\C131\BCC4", age "\B098\C774",'),
unistr('       subscription_status "\AC00\C785\C0C1\D0DC", hp_no "\D734\B300\D3F0", email "\C774\BA54\C77C", juso "\C8FC\C18C",'),
unistr('       fp_id "\B2F4\B2F9FP", fp_name "FP\BA85", product_count "\AC00\C785\C0C1\D488\C218", product_names "\AC00\C785\C0C1\D488",'),
unistr('       total_reserve_amt "\CD1D\C801\B9BD\AE08", deposit_amt "\C6D4\B0A9\C785\C561", non_deposit_cnt "\BBF8\B0A9\D69F\C218",'),
unistr('       last_call_at "\CD5C\ADFC\C0C1\B2F4\C77C", substr(last_consult_text,1,220) "\CD5C\ADFC\C0C1\B2F4\B0B4\C6A9"'),
'  from soe.call_center_customer_360_v',
' order by cust_id'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(2053976608346625)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>12282314183986784
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(2054069687346625)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'CC11010'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\C131\BCC4":"\B098\C774":"\AC00\C785\C0C1\D0DC":"\D734\B300\D3F0":"\C774\BA54\C77C":"\C8FC\C18C":"\B2F4\B2F9FP":"FP\BA85":"\AC00\C785\C0C1\D488\C218":"\AC00\C785\C0C1\D488":"\CD1D\C801\B9BD\AE08":"\C6D4\B0A9\C785\C561":"\BBF8\B0A9\D69F\C218":"\CD5C\ADFC\C0C1\B2F4\C77C":"\CD5C\ADFC\C0C1\B2F4\B0B4\C6A9"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2054180398346625)
,p_plug_name=>unistr('\ACE0\AC1D\BCC4 \C0C1\D488/\C801\B9BD\AE08 \C0C1\C138')
,p_static_id=>'customer-products-ir'
,p_plug_template=>wwv_flow_imp.id(135252708113572181)
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select cust_id "\ACE0\AC1DID", cust_nm "\ACE0\AC1D\BA85", balance_dt "\C794\ACE0\AE30\C900\C77C",'),
unistr('       fund_code "\C0C1\D488\CF54\B4DC", fund_name "\C0C1\D488\BA85", product_status "\C0C1\D488\C0C1\D0DC",'),
unistr('       fund_rat "\D22C\C785\BE44\C728", fund_cnt "\BCF4\C720\C88C\C218", fund_price "\AE30\C900\AC00",'),
unistr('       tot_cnt "\CD1D\C88C\C218", tot_amt "\D3C9\AC00\AE08\C561", product_category "\C0C1\D488\BD84\B958"'),
'  from soe.call_center_customer_product_v',
' order by cust_id, fund_code'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(2054308284346625)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>12282645859986784
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(2054416646346625)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'CC11011'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\C794\ACE0\AE30\C900\C77C":"\C0C1\D488\CF54\B4DC":"\C0C1\D488\BA85":"\C0C1\D488\C0C1\D0DC":"\D22C\C785\BE44\C728":"\BCF4\C720\C88C\C218":"\AE30\C900\AC00":"\CD1D\C88C\C218":"\D3C9\AC00\AE08\C561":"\C0C1\D488\BD84\B958"')
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>unistr('\C74C\C131 \C0C1\B2F4 \C811\C218')
,p_alias=>'VOICE-CONSULTATION'
,p_step_title=>unistr('\C74C\C131 \C0C1\B2F4 \C811\C218')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () {',
'  function initRecorder() {',
'    var start = document.getElementById("cc-start-recording");',
'    var stop = document.getElementById("cc-stop-recording");',
'    var audio = document.getElementById("cc-audio-preview");',
'    var status = document.getElementById("cc-recording-status");',
'    var warning = document.getElementById("cc-recording-warning");',
'    var recorder = null;',
'    var stream = null;',
'    var chunks = [];',
'',
'    if (!start || !stop || !audio || !status) {',
'      if (window.console) { console.warn("Call center recorder controls were not found."); }',
'      return;',
'    }',
'',
'    function setStatus(text) { status.textContent = text; }',
'    function showWarning(text) {',
'      setStatus(text);',
'      if (warning) { warning.textContent = text; warning.hidden = false; }',
'      if (window.console) { console.warn(text); }',
'    }',
'    function hideWarning() { if (warning) { warning.hidden = true; } }',
'    function detectedContext() { return "host=" + location.hostname + ", secure=" + window.isSecureContext; }',
'    function stopTracks() {',
'      if (stream) {',
'        stream.getTracks().forEach(function (track) { track.stop(); });',
'        stream = null;',
'      }',
'    }',
'    function findFileInput() {',
'      var selectors = [',
'        "input[type=file][id=P20_AUDIO_FILE]",',
'        "input[type=file][name=P20_AUDIO_FILE]",',
'        "input[type=file][id^=P20_AUDIO_FILE]",',
'        "input[type=file][name^=P20_AUDIO_FILE]",',
'        "#P20_AUDIO_FILE_CONTAINER input[type=file]",',
'        "#P20_AUDIO_FILE_fieldset input[type=file]",',
'        "#wwvFlowForm input[type=file]"',
'      ];',
'      var i;',
'      var found;',
'      for (i = 0; i < selectors.length; i += 1) {',
'        found = document.querySelector(selectors[i]);',
'        if (found) { return found; }',
'      }',
'      var form = document.getElementById("wwvFlowForm");',
'      if (!form) { return null; }',
'      found = document.createElement("input");',
'      found.type = "file";',
'      found.id = "P20_AUDIO_FILE_RECORDER_UPLOAD";',
'      found.name = "P20_AUDIO_FILE";',
'      found.accept = "audio/*";',
'      found.style.display = "none";',
'      form.enctype = "multipart/form-data";',
'      form.encoding = "multipart/form-data";',
'      form.appendChild(found);',
'      return found;',
'    }',
'    function setPageItem(name, value) {',
'      var item;',
'      try {',
'        if (window.apex && apex.item) {',
'          item = apex.item(name);',
'          if (item && item.setValue) { item.setValue(value, null, true); return; }',
'        }',
'      } catch (ignore) {}',
'      item = document.getElementById(name);',
'      if (item) { item.value = value; }',
'    }',
'    function clearAudioChunks() {',
'      var i;',
'      setPageItem("P20_AUDIO_CHUNK_COUNT", "0");',
'      setPageItem("P20_DRAFT_INTAKE_ID", "");',
'      for (i = 1; i <= 10; i += 1) {',
'        setPageItem("P20_AUDIO_B64_" + (i < 10 ? "0" + i : i), "");',
'      }',
'    }',
'    function uploadAudioDraft(fileName, mimeType, chunksForUpload) {',
'      var custId = "156";',
'      try {',
'        if (window.apex && apex.item) { custId = apex.item("P20_CUST_ID").getValue() || "156"; }',
'      } catch (ignore) {}',
'      if (!(window.apex && apex.server && apex.server.process)) {',
unistr('        setStatus("\B179\C74C \D30C\C77C \C900\BE44 \C644\B8CC");'),
'        return;',
'      }',
unistr('      setStatus("\B179\C74C \D30C\C77C \C11C\BC84 \C800\C7A5 \C911...");'),
'      apex.server.process("SAVE_AUDIO_DRAFT", {',
'        x01: fileName,',
'        x02: mimeType,',
'        x03: custId,',
'        f01: chunksForUpload',
'      }, {',
'        dataType: "json",',
'        success: function (data) {',
'          if (data && data.intakeId) {',
'            setPageItem("P20_DRAFT_INTAKE_ID", String(data.intakeId));',
'            setPageItem("P20_INTAKE_ID", String(data.intakeId));',
unistr('            setStatus("\B179\C74C \D30C\C77C \C11C\BC84 \C800\C7A5 \C644\B8CC - \C811\C218ID " + data.intakeId + " (" + data.bytes + " bytes)");'),
'          } else {',
unistr('            showWarning("\B179\C74C \D30C\C77C \C11C\BC84 \C800\C7A5 \C751\B2F5\C744 \D655\C778\D558\C9C0 \BABB\D588\C2B5\B2C8\B2E4.");'),
'          }',
'        },',
'        error: function (xhr, statusText, errorThrown) {',
unistr('          showWarning("\B179\C74C \D30C\C77C \C11C\BC84 \C800\C7A5 \C2E4\D328: " + (errorThrown || statusText || "unknown"));'),
'        }',
'      });',
'    }',
'    function saveAudioChunks(blob, mimeType, fileName) {',
'      var reader;',
'      if (!window.FileReader) {',
unistr('        showWarning("\B179\C74C \BBF8\B9AC\B4E3\AE30\B294 \AC00\B2A5\D558\C9C0\B9CC \D604\C7AC \BE0C\B77C\C6B0\C800\AC00 DB \C800\C7A5\C6A9 \BCC0\D658\C744 \C9C0\C6D0\D558\C9C0 \C54A\C2B5\B2C8\B2E4.");'),
'        return;',
'      }',
unistr('      setStatus("\B179\C74C \D30C\C77C \C800\C7A5 \C900\BE44 \C911...");'),
'      reader = new FileReader();',
'      reader.onloadend = function () {',
'        var result = reader.result || "";',
'        var base64 = result.indexOf(",") >= 0 ? result.split(",")[1] : result;',
'        var chunkSize = 30000;',
'        var chunkCount = Math.ceil(base64.length / chunkSize);',
'        var i;',
'        var chunksForUpload = [];',
'        clearAudioChunks();',
'        if (chunkCount > 50) {',
unistr('          showWarning("\B179\C74C \D30C\C77C\C774 \B108\BB34 \D07D\B2C8\B2E4. 30\CD08 \B0B4\C678\B85C \C9E7\AC8C \B2E4\C2DC \B179\C74C\D574 \C8FC\C138\C694.");'),
'          return;',
'        }',
'        setPageItem("P20_AUDIO_FILE_NAME", fileName);',
'        setPageItem("P20_AUDIO_MIME_TYPE", mimeType);',
'        setPageItem("P20_AUDIO_CHUNK_COUNT", String(chunkCount));',
'        for (i = 0; i < chunkCount; i += 1) {',
'          chunksForUpload.push(base64.substring(i * chunkSize, (i + 1) * chunkSize));',
'          if (i < 10) {',
'            setPageItem("P20_AUDIO_B64_" + (i + 1 < 10 ? "0" + (i + 1) : (i + 1)), chunksForUpload[i]);',
'          }',
'        }',
'        uploadAudioDraft(fileName, mimeType, chunksForUpload);',
'      };',
'      reader.onerror = function () {',
unistr('        showWarning("\B179\C74C \D30C\C77C\C744 DB \C800\C7A5 \D615\C2DD\C73C\B85C \BCC0\D658\D558\C9C0 \BABB\D588\C2B5\B2C8\B2E4.");'),
'      };',
'      reader.readAsDataURL(blob);',
'    }',
'    function attachFile(blob, mimeType) {',
'      var fileInput = findFileInput();',
'      var ext = mimeType.indexOf("mp4") >= 0 ? "mp4" : "webm";',
'      var fileName = "call-center-recording-" + Date.now() + "." + ext;',
'      audio.src = URL.createObjectURL(blob);',
'      audio.hidden = false;',
'      clearAudioChunks();',
'      if (fileInput && window.DataTransfer && window.File) {',
'        try {',
'          var file = new File([blob], fileName, { type: mimeType });',
'          var dt = new DataTransfer();',
'          dt.items.add(file);',
'          fileInput.files = dt.files;',
'          fileInput.dispatchEvent(new Event("change", { bubbles: true }));',
'        } catch (ignore) {}',
'      }',
'      saveAudioChunks(blob, mimeType, fileName);',
'    }',
'',
unistr('    setStatus("\B300\AE30");'),
'',
'    start.addEventListener("click", function (event) {',
'      event.preventDefault();',
'      hideWarning();',
unistr('      setStatus("\B9C8\C774\D06C \AD8C\D55C \C694\CCAD \C911...");'),
'      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia || !window.MediaRecorder) {',
unistr('        showWarning("\BE0C\B77C\C6B0\C800\AC00 \B9C8\C774\D06C \B179\C74C \AE30\B2A5\C744 \C81C\ACF5\D558\C9C0 \C54A\C2B5\B2C8\B2E4. \C8FC\C18C\AC00 localhost \B610\B294 HTTPS\C778\C9C0 \D655\C778\D574 \C8FC\C138\C694. (" + detectedContext() + ")");'),
'        return;',
'      }',
'      navigator.mediaDevices.getUserMedia({ audio: true }).then(function (mediaStream) {',
'        var options;',
'        stream = mediaStream;',
'        chunks = [];',
'        try {',
'          if (MediaRecorder.isTypeSupported && MediaRecorder.isTypeSupported("audio/webm")) {',
'            options = { mimeType: "audio/webm" };',
'          }',
'          recorder = options ? new MediaRecorder(stream, options) : new MediaRecorder(stream);',
'        } catch (e) {',
'          stopTracks();',
unistr('          showWarning("\B179\C74C\AE30\B97C \C2DC\C791\D558\C9C0 \BABB\D588\C2B5\B2C8\B2E4: " + (e.name || e.message || e));'),
'          return;',
'        }',
'        recorder.ondataavailable = function (e) { if (e.data && e.data.size) { chunks.push(e.data); } };',
unistr('        recorder.onerror = function (e) { showWarning("\B179\C74C \C911 \C624\B958\AC00 \BC1C\C0DD\D588\C2B5\B2C8\B2E4: " + ((e.error && e.error.name) || e.name || e.message || e)); };'),
'        recorder.onstop = function () {',
'          var mimeType = recorder && recorder.mimeType ? recorder.mimeType : "audio/webm";',
'          var blob = new Blob(chunks, { type: mimeType });',
'          attachFile(blob, mimeType);',
'          stopTracks();',
'          start.disabled = false;',
'          stop.disabled = true;',
'        };',
'        recorder.start();',
'        start.disabled = true;',
'        stop.disabled = false;',
unistr('        setStatus("\B179\C74C \C911");'),
'      }).catch(function (e) {',
'        stopTracks();',
'        start.disabled = false;',
'        stop.disabled = true;',
unistr('        showWarning("\B9C8\C774\D06C \AD8C\D55C \B610\B294 \C7A5\CE58\B97C \D655\C778\D558\C138\C694: " + (e.name || e.message || e) + " (" + detectedContext() + ")");'),
'      });',
'    });',
'',
'    stop.addEventListener("click", function (event) {',
'      event.preventDefault();',
'      if (recorder && recorder.state !== "inactive") { recorder.stop(); }',
'    });',
'  }',
'  if (document.readyState === "loading") {',
'    document.addEventListener("DOMContentLoaded", initRecorder);',
'  } else {',
'    initRecorder();',
'  }',
'}());'))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.cc-recorder { display: flex; gap: .5rem; align-items: center; flex-wrap: wrap; }',
'.cc-recorder audio { max-width: 360px; width: 100%; }',
'.cc-status { color: var(--ut-region-text-color, #333); font-size: .875rem; font-weight: 600; }',
'.cc-note { margin-top: .5rem; color: var(--ut-component-text-muted-color, #5f6b7a); }',
'.cc-warning { margin-top: .75rem; padding: .75rem .875rem; border-left: 4px solid #c2410c; background: #fff7ed; color: #7c2d12; }'))
,p_step_template=>wwv_flow_imp.id(135185753524572103)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2054576095346626)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(135337322703572241)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2054703733346626)
,p_plug_name=>unistr('\C74C\C131 \B179\C74C')
,p_static_id=>'call-center-recorder'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="cc-recorder">',
unistr('  <button type="button" id="cc-start-recording" class="t-Button t-Button--icon t-Button--hot"><span class="t-Icon fa fa-microphone" aria-hidden="true"></span><span class="t-Button-label">\B179\C74C \C2DC\C791</span></button>'),
unistr('  <button type="button" id="cc-stop-recording" class="t-Button t-Button--icon" disabled><span class="t-Icon fa fa-stop" aria-hidden="true"></span><span class="t-Button-label">\B179\C74C \C885\B8CC</span></button>'),
'  <audio id="cc-audio-preview" controls hidden></audio>',
unistr('  <span id="cc-recording-status" class="cc-status">\B300\AE30</span>'),
'</div>',
'<div id="cc-recording-warning" class="cc-warning" hidden></div>',
unistr('<div class="cc-note">\B179\C74C \C885\B8CC \D6C4 \D30C\C77C\C774 \C74C\C131 \D30C\C77C \D56D\BAA9\C5D0 \C790\B3D9 \C5F0\ACB0\B429\B2C8\B2E4. \C0C1\B2F4\C0AC \C694\C57D\C740 \C544\B798 \C785\B825\B780\C5D0 \C801\ACE0 \C800\C7A5\D569\B2C8\B2E4.</div>')))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(2054777680346626)
,p_plug_name=>unistr('\C0C1\B2F4\C0AC \C694\C57D \C785\B825/\C800\C7A5')
,p_static_id=>'call-center-stt-form'
,p_title=>unistr('\C0C1\B2F4\C0AC \C694\C57D \C785\B825/\C800\C7A5')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>30
,p_location=>null
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'<div class="cc-agent-summary-editor" style="margin-bottom:1rem">',
unistr('  <label for="P20_TRANSCRIPT_EDITOR" class="t-Form-label" style="display:block;font-weight:700;margin-bottom:.35rem">\C0C1\B2F4\C0AC \C694\C57D \C785\B825</label>'),
unistr('  <textarea id="P20_TRANSCRIPT_EDITOR" class="textarea apex-item-textarea" rows="7" style="box-sizing:border-box;width:100%;min-height:9rem;resize:vertical" placeholder="\C0C1\B2F4\C0AC\AC00 \C9C1\C811 \D655\C778\D55C \C0C1\B2F4 \C694\C57D\ACFC \C870\CE58 \B0B4\C6A9\C744 \C785\B825\D569\B2C8\B2E4. OCI STT \C6D0\BB38\ACFC \BCC4\B3C4\B85C \C800\C7A5\B429\B2C8\B2E4."></textarea>'),
unistr('  <div class="cc-note" style="margin-top:.35rem;color:var(--ut-component-text-muted-color,#5f6b7a)">\C774 \B0B4\C6A9\C740 \C0C1\B2F4\C0AC \C694\C57D \CEEC\B7FC\C5D0 \C800\C7A5\B418\BA70, OCI Speech STT \C6D0\BB38\ACFC\B294 \BCC4\B3C4\B85C \AD00\B9AC\B429\B2C8\B2E4.</div>'),
'</div>',
'<script>',
'(function () {',
'  function hiddenItem() {',
'    return document.getElementById("P20_TRANSCRIPT");',
'  }',
'  function getHiddenValue() {',
'    var item = hiddenItem();',
'    if (window.apex && apex.item) {',
'      try { return apex.item("P20_TRANSCRIPT").getValue() || ""; } catch (ignore) {}',
'    }',
'    return item ? item.value || "" : "";',
'  }',
'  function setHiddenValue(value) {',
'    var item = hiddenItem();',
'    if (window.apex && apex.item) {',
'      try {',
'        apex.item("P20_TRANSCRIPT").setValue(value || "", null, true);',
'        return;',
'      } catch (ignore) {}',
'    }',
'    if (item) { item.value = value || ""; }',
'  }',
'  function syncEditor() {',
'    var editor = document.getElementById("P20_TRANSCRIPT_EDITOR");',
'    if (editor) { setHiddenValue(editor.value); }',
'  }',
'  function initEditor() {',
'    var editor = document.getElementById("P20_TRANSCRIPT_EDITOR");',
'    var form = document.getElementById("wwvFlowForm");',
'    if (!editor) { return; }',
'    editor.value = getHiddenValue();',
'    editor.addEventListener("input", syncEditor);',
'    if (form) {',
'      form.addEventListener("submit", syncEditor, true);',
'    }',
'    document.addEventListener("click", function (event) {',
'      var target = event.target && event.target.closest ? event.target.closest("button,a,input") : null;',
'      var text;',
'      if (!target) { return; }',
'      text = [',
'        target.id || "",',
'        target.name || "",',
'        target.value || "",',
'        target.textContent || "",',
'        target.getAttribute("aria-label") || "",',
'        target.getAttribute("title") || ""',
'      ].join(" ");',
unistr('      if (/SAVE_LOG|DEMO_STT|OCI_JOB|\C0C1\B2F4\C0AC \C694\C57D \C800\C7A5|\B79C\B364 \B370\BAA8\C694\C57D|OCI Speech Job/.test(text)) {'),
'        syncEditor();',
'      }',
'    }, true);',
'    window.ccSyncAgentSummary = syncEditor;',
'  }',
'  if (document.readyState === "loading") {',
'    document.addEventListener("DOMContentLoaded", initEditor);',
'  } else {',
'    initEditor();',
'  }',
'}());',
'</script>',
''))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(2054910319346626)
,p_name=>unistr('\CD5C\ADFC STT \C0C1\B2F4 \BC18\C601 \B85C\ADF8')
,p_static_id=>'call-center-stt-recent'
,p_template=>wwv_flow_imp.id(135262545202572189)
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select intake_id "\C811\C218ID", created_at "\C811\C218\C2DC\AC01", stt_status "\C0C1\D0DC",'),
unistr('       cust_id "\ACE0\AC1DID", cust_nm "\ACE0\AC1D\BA85", fp_id "\B2F4\B2F9FP", fund_name "\C0C1\D488",'),
unistr('       audio_file_name "\C74C\C131\D30C\C77C", audio_mime_type "MIME",'),
unistr('       call_center_log_id "\C0C1\B2F4\B85C\ADF8ID", transcript_preview "\C0C1\B2F4\C694\C57D",'),
unistr('       oci_transcript_preview "OCI STT\C6D0\BB38", stt_job_id "OCI Job", stt_error "\C5F0\B3D9\BA54\C2DC\C9C0",'),
'       case when nvl(audio_size_bytes, 0) > 0 then',
'         ''<div class="cc-audio-playback"><audio controls preload="none" style="width:220px;max-width:100%" src="'' ||',
'         apex_page.get_url(p_page => 30, p_items => ''P30_INTAKE_ID'', p_values => intake_id) ||',
'         ''"></audio><br><a target="_blank" rel="noopener" href="'' ||',
'         apex_page.get_url(p_page => 30, p_items => ''P30_INTAKE_ID'', p_values => intake_id) ||',
unistr('         ''">\C5F4\AE30</a> <span style="color:#5f6b7a">('' || ceil(audio_size_bytes / 1024) || '' KB)</span></div>'''),
'       else',
unistr('         ''<span style="color:#5f6b7a">\B179\C74C \C5C6\C74C</span>'''),
unistr('       end "\C7AC\C0DD"'),
'  from soe.call_center_audio_recent_v',
' order by created_at desc fetch first 20 rows only'))
,p_query_row_template=>wwv_flow_imp.id(135300679708572215)
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058832732346628)
,p_query_column_id=>9
,p_column_alias=>'MIME'
,p_column_display_sequence=>90
,p_column_heading=>'MIME'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2059168402346629)
,p_query_column_id=>13
,p_column_alias=>'OCI Job'
,p_column_display_sequence=>80
,p_column_heading=>'OCI Job'
,p_column_css_class=>'cc-col-oci'
,p_css_classes=>'cc-col-oci'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2059139808346628)
,p_query_column_id=>12
,p_column_alias=>unistr('OCI STT\C6D0\BB38')
,p_column_display_sequence=>70
,p_column_heading=>'OCI STT'
,p_column_css_class=>'cc-col-preview'
,p_css_classes=>'cc-col-preview'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058343270346628)
,p_query_column_id=>4
,p_column_alias=>unistr('\ACE0\AC1DID')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\ACE0\AC1DID')
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058421421346628)
,p_query_column_id=>5
,p_column_alias=>unistr('\ACE0\AC1D\BA85')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\ACE0\AC1D')
,p_column_css_class=>'cc-col-customer'
,p_css_classes=>'cc-col-customer'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058541820346628)
,p_query_column_id=>6
,p_column_alias=>unistr('\B2F4\B2F9FP')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\B2F4\B2F9FP')
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058906125346628)
,p_query_column_id=>10
,p_column_alias=>unistr('\C0C1\B2F4\B85C\ADF8ID')
,p_column_display_sequence=>100
,p_column_heading=>unistr('\C0C1\B2F4\B85C\ADF8ID')
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2059012458346628)
,p_query_column_id=>11
,p_column_alias=>unistr('\C0C1\B2F4\C694\C57D')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C0C1\B2F4\C694\C57D')
,p_column_css_class=>'cc-col-preview'
,p_css_classes=>'cc-col-preview'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058231912346628)
,p_query_column_id=>3
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C0C1\D0DC')
,p_column_css_class=>'cc-col-status'
,p_css_classes=>'cc-col-status'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058646721346628)
,p_query_column_id=>7
,p_column_alias=>unistr('\C0C1\D488')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C0C1\D488')
,p_column_css_class=>'cc-col-product'
,p_css_classes=>'cc-col-product'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2059293288346629)
,p_query_column_id=>14
,p_column_alias=>unistr('\C5F0\B3D9\BA54\C2DC\C9C0')
,p_column_display_sequence=>140
,p_column_heading=>unistr('\C5F0\B3D9\BA54\C2DC\C9C0')
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058734949346628)
,p_query_column_id=>8
,p_column_alias=>unistr('\C74C\C131\D30C\C77C')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\C74C\C131\D30C\C77C')
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2059446608346629)
,p_query_column_id=>15
,p_column_alias=>unistr('\C7AC\C0DD')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\C7AC\C0DD')
,p_column_html_expression=>unistr('#\C7AC\C0DD#')
,p_column_css_class=>'cc-col-audio'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_css_classes=>'cc-col-audio'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058008456346628)
,p_query_column_id=>1
,p_column_alias=>unistr('\C811\C218ID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C811\C218ID')
,p_column_css_class=>'cc-col-id'
,p_css_classes=>'cc-col-id'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(2058125017346628)
,p_query_column_id=>2
,p_column_alias=>unistr('\C811\C218\C2DC\AC01')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\C811\C218\C2DC\AC01')
,p_column_css_class=>'cc-col-time'
,p_css_classes=>'cc-col-time'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(2055265206346626)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_button_name=>'DEMO_STT'
,p_static_id=>'demo-stt'
,p_button_action=>'SUBMIT'
,p_button_template_id=>wwv_flow_imp.id(135335658049572240)
,p_button_image_alt=>unistr('\B79C\B364 \B370\BAA8\C694\C57D \C0DD\C131/\C800\C7A5')
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-magic'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(2055431404346626)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_button_name=>'OCI_JOB'
,p_static_id=>'oci-job'
,p_button_action=>'SUBMIT'
,p_button_template_id=>wwv_flow_imp.id(135335658049572240)
,p_button_image_alt=>unistr('OCI Speech Job \B300\AE30')
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-cloud'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(2055225850346626)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_button_name=>'SAVE_LOG'
,p_static_id=>'save-log'
,p_button_action=>'SUBMIT'
,p_button_template_id=>wwv_flow_imp.id(135335658049572240)
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('\C0C1\B2F4\C0AC \C694\C57D \C800\C7A5')
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-save'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2055559212346626)
,p_name=>'P20_AGENT_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_item_default=>'&APP_USER.'
,p_prompt=>unistr('\C0C1\B2F4\C0ACID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056530290346626)
,p_name=>'P20_AUDIO_B64_01'
,p_item_sequence=>64
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056656873346626)
,p_name=>'P20_AUDIO_B64_02'
,p_item_sequence=>65
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056666945346626)
,p_name=>'P20_AUDIO_B64_03'
,p_item_sequence=>66
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056777189346626)
,p_name=>'P20_AUDIO_B64_04'
,p_item_sequence=>67
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056954049346626)
,p_name=>'P20_AUDIO_B64_05'
,p_item_sequence=>68
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057041670346626)
,p_name=>'P20_AUDIO_B64_06'
,p_item_sequence=>69
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057121492346626)
,p_name=>'P20_AUDIO_B64_07'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057194510346626)
,p_name=>'P20_AUDIO_B64_08'
,p_item_sequence=>71
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057291031346627)
,p_name=>'P20_AUDIO_B64_09'
,p_item_sequence=>72
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057395663346627)
,p_name=>'P20_AUDIO_B64_10'
,p_item_sequence=>73
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056460209346626)
,p_name=>'P20_AUDIO_CHUNK_COUNT'
,p_item_sequence=>63
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056142077346626)
,p_name=>'P20_AUDIO_FILE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C74C\C131 \D30C\C77C')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_FILE'
,p_cSize=>60
,p_tag_attributes=>'accept="audio/*"'
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056218319346626)
,p_name=>'P20_AUDIO_FILE_NAME'
,p_item_sequence=>61
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056340508346626)
,p_name=>'P20_AUDIO_MIME_TYPE'
,p_item_sequence=>62
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2055894790346626)
,p_name=>'P20_CALL_CNT_3M'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('3\AC1C\C6D4 \CF5C\C218')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2055567326346626)
,p_name=>'P20_CUST_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_item_default=>'156'
,p_prompt=>unistr('\ACE0\AC1DID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>12
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057543958346627)
,p_name=>'P20_DRAFT_INTAKE_ID'
,p_item_sequence=>74
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2055667969346626)
,p_name=>'P20_FUND_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C0C1\D488\CF54\B4DC')
,p_placeholder=>unistr('\BBF8\C785\B825 \C2DC \CD5C\ADFC \C0C1\B2F4 \AE30\C900')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2055848331346626)
,p_name=>'P20_FUND_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C0C1\D488\BA85')
,p_placeholder=>unistr('\BBF8\C785\B825 \C2DC \CD5C\ADFC \C0C1\B2F4 \AE30\C900')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057721301346628)
,p_name=>'P20_INTAKE_ID'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C811\C218ID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2056028737346626)
,p_name=>'P20_LATE_PMT_CNT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C5F0\CCB4\D69F\C218')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>8
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057818840346628)
,p_name=>'P20_LOG_ID'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C0C1\B2F4\B85C\ADF8ID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057948754346628)
,p_name=>'P20_PLAY_INTAKE_ID'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2057564881346627)
,p_name=>'P20_TRANSCRIPT'
,p_item_sequence=>55
,p_item_plug_id=>wwv_flow_imp.id(2054777680346626)
,p_prompt=>unistr('\C0C1\B2F4\C0AC \C694\C57D')
,p_placeholder=>unistr('\C0C1\B2F4\C0AC\AC00 \D655\C778\D55C \C0C1\B2F4 \C694\C57D/\C870\CE58 \B0B4\C6A9\C744 \C785\B825\D569\B2C8\B2E4. OCI STT \C6D0\BB38\ACFC \BCC4\B3C4\B85C \C800\C7A5\B429\B2C8\B2E4.')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_cSize=>100
,p_cHeight=>7
,p_field_template=>wwv_flow_imp.id(135333244503572238)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2059737379346629)
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'GET_AUDIO'
,p_static_id=>'get-audio'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_blob      blob;',
'  l_mime_type varchar2(200);',
'  l_filename  varchar2(512);',
'begin',
'  select audio_blob,',
'         nvl(audio_mime_type, ''audio/webm''),',
'         nvl(audio_file_name, ''call-center-recording.webm'')',
'    into l_blob, l_mime_type, l_filename',
'    from soe.call_center_audio_intake',
'   where intake_id = :P20_PLAY_INTAKE_ID',
'     and dbms_lob.getlength(audio_blob) > 0;',
'',
'  sys.htp.init;',
'  owa_util.mime_header(l_mime_type, false);',
'  sys.htp.p(''Content-Length: '' || dbms_lob.getlength(l_blob));',
'  sys.htp.p(''Content-Disposition: inline; filename="'' || replace(l_filename, ''"'', '''') || ''"'');',
'  sys.htp.p(''Cache-Control: private, max-age=300'');',
'  owa_util.http_header_close;',
'  wpg_docload.download_file(l_blob);',
'  apex_application.stop_apex_engine;',
'exception',
'  when apex_application.e_stop_apex_engine then',
'    raise;',
'  when no_data_found then',
'    sys.htp.init;',
'    owa_util.status_line(404, ''Not Found'');',
'    owa_util.mime_header(''text/plain'', false);',
'    owa_util.http_header_close;',
'    sys.htp.p(''Audio file not found.'');',
'    apex_application.stop_apex_engine;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>12288074954986788
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2059531584346629)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Register STT Consultation'
,p_static_id=>'register-stt-consultation'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_filename    varchar2(512);',
'  l_mime_type   varchar2(200);',
'  l_audio_blob  blob;',
'  l_audio_base64 clob;',
'  l_transcript  clob := :P20_TRANSCRIPT;',
'  l_cust_id     number := nvl(:P20_CUST_ID, 156);',
'  l_existing_intake_id number;',
'  l_intake_id   number;',
'  l_log_id      number;',
'',
'  procedure append_audio_chunk(p_item_name varchar2) is',
'    l_value varchar2(32767);',
'  begin',
'    l_value := apex_util.get_session_state(p_item_name);',
'    if l_value is not null then',
'      if l_audio_base64 is null then',
'        dbms_lob.createtemporary(l_audio_base64, true);',
'      end if;',
'      dbms_lob.writeappend(l_audio_base64, length(l_value), l_value);',
'    end if;',
'  end;',
'',
'  procedure decode_audio_chunks is',
'    l_pos   integer := 1;',
'    l_len   integer;',
'    l_chunk varchar2(32764);',
'    l_raw   raw(32767);',
'  begin',
'    if l_audio_blob is not null then',
'      return;',
'    end if;',
'    append_audio_chunk(''P20_AUDIO_B64_01'');',
'    append_audio_chunk(''P20_AUDIO_B64_02'');',
'    append_audio_chunk(''P20_AUDIO_B64_03'');',
'    append_audio_chunk(''P20_AUDIO_B64_04'');',
'    append_audio_chunk(''P20_AUDIO_B64_05'');',
'    append_audio_chunk(''P20_AUDIO_B64_06'');',
'    append_audio_chunk(''P20_AUDIO_B64_07'');',
'    append_audio_chunk(''P20_AUDIO_B64_08'');',
'    append_audio_chunk(''P20_AUDIO_B64_09'');',
'    append_audio_chunk(''P20_AUDIO_B64_10'');',
'    if l_audio_base64 is null or dbms_lob.getlength(l_audio_base64) = 0 then',
'      return;',
'    end if;',
'    dbms_lob.createtemporary(l_audio_blob, true);',
'    l_len := dbms_lob.getlength(l_audio_base64);',
'    while l_pos <= l_len loop',
'      l_chunk := dbms_lob.substr(l_audio_base64, 32764, l_pos);',
'      l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(l_chunk));',
'      dbms_lob.writeappend(l_audio_blob, utl_raw.length(l_raw), l_raw);',
'      l_pos := l_pos + 32764;',
'    end loop;',
'    l_filename := nvl(:P20_AUDIO_FILE_NAME, ''call-center-recording.webm'');',
'    l_mime_type := nvl(:P20_AUDIO_MIME_TYPE, ''audio/webm'');',
'  end;',
'begin',
'  :P20_CUST_ID := l_cust_id;',
'  begin',
'    l_existing_intake_id := to_number(nullif(:P20_DRAFT_INTAKE_ID, ''''));',
'  exception',
'    when others then',
'      l_existing_intake_id := null;',
'  end;',
'  if :P20_AUDIO_FILE is not null then',
'    begin',
'      select filename, mime_type, blob_content',
'        into l_filename, l_mime_type, l_audio_blob',
'        from apex_application_temp_files',
'       where name = :P20_AUDIO_FILE',
'       order by created_on desc',
'       fetch first 1 row only;',
'    exception',
'      when no_data_found then',
'        null;',
'    end;',
'  end if;',
'  if l_existing_intake_id is null then',
'    begin',
'      select intake_id',
'        into l_existing_intake_id',
'        from soe.call_center_audio_intake',
'       where cust_id = l_cust_id',
'         and call_center_log_id is null',
'         and stt_status = ''UPLOADED''',
'         and dbms_lob.getlength(audio_blob) > 0',
'       order by intake_id desc',
'       fetch first 1 row only;',
'    exception',
'      when no_data_found then',
'        null;',
'    end;',
'  end if;',
'  if l_existing_intake_id is not null and l_audio_blob is null then',
'    begin',
'      select audio_file_name, audio_mime_type, audio_blob',
'        into l_filename, l_mime_type, l_audio_blob',
'        from soe.call_center_audio_intake',
'       where intake_id = l_existing_intake_id',
'         and dbms_lob.getlength(audio_blob) > 0;',
'    exception',
'      when no_data_found then',
'        null;',
'    end;',
'  end if;',
'  decode_audio_chunks;',
'  if l_audio_blob is not null then',
'    l_filename := nvl(l_filename, ''call-center-recording.webm'');',
'    l_mime_type := nvl(l_mime_type, ''audio/webm'');',
'  end if;',
'',
'  if :REQUEST = ''DEMO_STT'' then',
'    l_transcript := soe.call_center_stt_pkg.demo_transcript(l_cust_id, l_filename);',
'  end if;',
'',
'  if :REQUEST = ''OCI_JOB'' then',
'    if l_audio_blob is null then',
unistr('      raise_application_error(-20021, ''OCI Speech\B85C \BCF4\B0BC \B179\C74C \D30C\C77C\C774 \C5C6\C2B5\B2C8\B2E4. \BA3C\C800 \B179\C74C \D6C4 \C11C\BC84 \C800\C7A5 \C644\B8CC \BA54\C2DC\C9C0\B97C \D655\C778\D558\C138\C694.'');'),
'    end if;',
'',
'    if l_existing_intake_id is not null then',
'      update soe.call_center_audio_intake',
'         set cust_id = l_cust_id,',
'             fund_code = nullif(:P20_FUND_CODE, ''''),',
'             fund_name = nullif(:P20_FUND_NAME, ''''),',
'             call_cnt_3m = :P20_CALL_CNT_3M,',
'             late_pmt_cnt = :P20_LATE_PMT_CNT,',
'             audio_file_name = l_filename,',
'             audio_mime_type = l_mime_type,',
'             audio_size_bytes = dbms_lob.getlength(l_audio_blob),',
'             audio_blob = l_audio_blob,',
'             updated_at = systimestamp',
'       where intake_id = l_existing_intake_id;',
'      l_intake_id := l_existing_intake_id;',
'      l_log_id := null;',
'    else',
'      soe.call_center_stt_pkg.register_audio(',
'        p_cust_id         => l_cust_id,',
'        p_fund_code       => nullif(:P20_FUND_CODE, ''''),',
'        p_fund_name       => nullif(:P20_FUND_NAME, ''''),',
'        p_call_cnt_3m     => :P20_CALL_CNT_3M,',
'        p_late_pmt_cnt    => :P20_LATE_PMT_CNT,',
'        p_audio_file_name => l_filename,',
'        p_audio_mime_type => l_mime_type,',
'        p_audio_blob      => l_audio_blob,',
'        p_transcript_text => null,',
'        p_provider        => ''OCI_SPEECH'',',
'        p_intake_id       => l_intake_id,',
'        p_log_id          => l_log_id',
'      );',
'    end if;',
'    soe.call_center_stt_pkg.submit_oci_transcription_job(l_intake_id);',
'  else',
'    if l_transcript is null or dbms_lob.getlength(l_transcript) = 0 then',
unistr('      raise_application_error(-20020, ''STT \C0C1\B2F4\B0B4\C6A9\C744 \C785\B825\D558\AC70\B098 \B370\BAA8 STT \C0DD\C131 \D6C4 \BC18\C601\C744 \C2E4\D589\D558\C138\C694.'');'),
'    end if;',
'',
'    if l_existing_intake_id is not null then',
'      update soe.call_center_audio_intake',
'         set fund_code = nullif(:P20_FUND_CODE, ''''),',
'             fund_name = nullif(:P20_FUND_NAME, ''''),',
'             call_cnt_3m = :P20_CALL_CNT_3M,',
'             late_pmt_cnt = :P20_LATE_PMT_CNT',
'       where intake_id = l_existing_intake_id;',
'      soe.call_center_stt_pkg.finalize_transcript(',
'        p_intake_id       => l_existing_intake_id,',
'        p_transcript_text => l_transcript,',
'        p_log_id          => l_log_id',
'      );',
'      l_intake_id := l_existing_intake_id;',
'    else',
'      soe.call_center_stt_pkg.register_audio(',
'        p_cust_id         => l_cust_id,',
'        p_fund_code       => nullif(:P20_FUND_CODE, ''''),',
'        p_fund_name       => nullif(:P20_FUND_NAME, ''''),',
'        p_call_cnt_3m     => :P20_CALL_CNT_3M,',
'        p_late_pmt_cnt    => :P20_LATE_PMT_CNT,',
'        p_audio_file_name => l_filename,',
'        p_audio_mime_type => l_mime_type,',
'        p_audio_blob      => l_audio_blob,',
'        p_transcript_text => l_transcript,',
'        p_provider        => ''OCI_SPEECH'',',
'        p_intake_id       => l_intake_id,',
'        p_log_id          => l_log_id',
'      );',
'    end if;',
'  end if;',
'',
'  :P20_INTAKE_ID := l_intake_id;',
'  :P20_DRAFT_INTAKE_ID := null;',
'  :P20_LOG_ID := l_log_id;',
'  if :REQUEST in (''SAVE_LOG'', ''DEMO_STT'') then',
'    :P20_TRANSCRIPT := null;',
'  elsif :REQUEST in (''SAVE_LOG'', ''DEMO_STT'') then',
'    :P20_TRANSCRIPT := null;',
'  elsif l_transcript is not null then',
'    :P20_TRANSCRIPT := dbms_lob.substr(l_transcript, 4000, 1);',
'  else',
'    :P20_TRANSCRIPT := null;',
'  end if;',
'  if l_existing_intake_id is not null and l_intake_id is not null and l_existing_intake_id <> l_intake_id then',
'    delete from soe.call_center_audio_intake',
'     where intake_id = l_existing_intake_id',
'       and call_center_log_id is null;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_success_message=>unistr('\CF5C\C13C\D130 STT \C0C1\B2F4 \C811\C218\B97C \CC98\B9AC\D588\C2B5\B2C8\B2E4.')
,p_internal_uid=>12287869159986788
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2059582544346629)
,p_process_sequence=>15
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_AUDIO_DRAFT'
,p_static_id=>'save-audio-draft'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_blob      blob;',
'  l_raw       raw(32767);',
'  l_intake_id number;',
'  l_cust_id   number := nvl(to_number(nullif(apex_application.g_x03, '''')), 156);',
'begin',
'  dbms_lob.createtemporary(l_blob, true);',
'  for i in 1 .. apex_application.g_f01.count loop',
'    if apex_application.g_f01(i) is not null then',
'      l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(apex_application.g_f01(i)));',
'      dbms_lob.writeappend(l_blob, utl_raw.length(l_raw), l_raw);',
'    end if;',
'  end loop;',
'',
'  if dbms_lob.getlength(l_blob) = 0 then',
unistr('    raise_application_error(-20041, ''\B179\C74C \D30C\C77C \B370\C774\D130\AC00 \BE44\C5B4 \C788\C2B5\B2C8\B2E4.'');'),
'  end if;',
'',
'  insert into soe.call_center_audio_intake (',
'    cust_id,',
'    audio_file_name,',
'    audio_mime_type,',
'    audio_size_bytes,',
'    audio_blob,',
'    stt_provider,',
'    stt_status',
'  ) values (',
'    l_cust_id,',
'    nvl(apex_application.g_x01, ''call-center-recording.webm''),',
'    nvl(apex_application.g_x02, ''audio/webm''),',
'    dbms_lob.getlength(l_blob),',
'    l_blob,',
'    ''OCI_SPEECH'',',
'    ''UPLOADED''',
'  ) returning intake_id into l_intake_id;',
'',
'  commit;',
'  owa_util.mime_header(''application/json'', false);',
'  owa_util.http_header_close;',
'  sys.htp.prn(''{"intakeId":'' || l_intake_id || '',"bytes":'' || dbms_lob.getlength(l_blob) || ''}'');',
'  apex_application.stop_apex_engine;',
'exception',
'  when apex_application.e_stop_apex_engine then',
'    raise;',
'  when others then',
'    rollback;',
'    owa_util.status_line(500, ''Server Error'');',
'    owa_util.mime_header(''application/json'', false);',
'    owa_util.http_header_close;',
'    sys.htp.prn(''{"error":"'' || replace(sqlerrm, ''"'', '''') || ''"}'');',
'    apex_application.stop_apex_engine;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>12287920119986788
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('\C74C\C131 \D30C\C77C \C2A4\D2B8\B9BC')
,p_alias=>'AUDIO-FILE'
,p_step_title=>unistr('\C74C\C131 \D30C\C77C \C2A4\D2B8\B9BC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(135185753524572103)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(2059863130346629)
,p_name=>'P30_INTAKE_ID'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(2059977685346629)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Stream Audio File'
,p_static_id=>'stream-audio-file'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_blob      blob;',
'  l_mime_type varchar2(200);',
'  l_filename  varchar2(512);',
'begin',
'  select audio_blob,',
'         nvl(audio_mime_type, ''audio/webm''),',
'         nvl(audio_file_name, ''call-center-recording.webm'')',
'    into l_blob, l_mime_type, l_filename',
'    from soe.call_center_audio_intake',
'   where intake_id = to_number(:P30_INTAKE_ID)',
'     and dbms_lob.getlength(audio_blob) > 0;',
'',
'  sys.htp.init;',
'  owa_util.mime_header(l_mime_type, false);',
'  sys.htp.p(''Content-Length: '' || dbms_lob.getlength(l_blob));',
'  sys.htp.p(''Content-Disposition: inline; filename="'' || replace(l_filename, ''"'', '''') || ''"'');',
'  sys.htp.p(''Cache-Control: private, max-age=300'');',
'  owa_util.http_header_close;',
'  wpg_docload.download_file(l_blob);',
'  apex_application.stop_apex_engine;',
'exception',
'  when apex_application.e_stop_apex_engine then',
'    raise;',
'  when value_error or no_data_found then',
'    sys.htp.init;',
'    owa_util.status_line(404, ''Not Found'');',
'    owa_util.mime_header(''text/plain'', false);',
'    owa_util.http_header_close;',
'    sys.htp.p(''Audio file not found. intake_id='' || :P30_INTAKE_ID);',
'    apex_application.stop_apex_engine;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>12288315260986788
);
end;
/
prompt --application/pages/page_09999
begin
wwv_flow_imp_page.create_page(
 p_id=>9999
,p_name=>unistr('\B85C\ADF8\C778')
,p_alias=>'LOGIN'
,p_step_title=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C')
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
,p_step_template=>wwv_flow_imp.id(135185753524572103)
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'12'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228327576640158)
,p_plug_name=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C')
,p_static_id=>unistr('\BCF4\D5D8-\C815\BCF4\ACC4-\C2DC\C2A4\D15C')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(135262545202572189)
,p_plug_display_sequence=>10
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(7228327576640155)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(7228327576640158)
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
 p_id=>wwv_flow_imp.id(7228327576640156)
,p_name=>'P9999_PASSWORD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(7228327576640158)
,p_prompt=>unistr('\BE44\BC00\BC88\D638\00A0\00A0')
,p_placeholder=>unistr('\BE44\BC00\BC88\D638')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>24
,p_cMaxlength=>100
,p_label_alignment=>'RIGHT'
,p_field_template=>wwv_flow_imp.id(141234195094860007141)
,p_item_icon_css_classes=>'fa-key'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(7228327576640157)
,p_name=>'P9999_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(7228327576640158)
,p_prompt=>unistr('\C0AC\C6A9\C790\BA85\00A0\00A0')
,p_placeholder=>unistr('\C0AC\C6A9\C790\BA85')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>24
,p_cMaxlength=>100
,p_label_alignment=>'RIGHT'
,p_field_template=>wwv_flow_imp.id(141234195094860007141)
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
 p_id=>wwv_flow_imp.id(7228327576640154)
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
 p_id=>wwv_flow_imp.id(7228327576640153)
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
