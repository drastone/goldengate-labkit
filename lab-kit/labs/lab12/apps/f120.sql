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
,p_default_id_offset=>12830129906706373
,p_default_owner=>'GGADMIN'
);
end;
/
 
prompt APPLICATION 300 - 신계약 언더라이팅 시스템
--
-- Application Export:
--   Application:     300
--   Name:            신계약 언더라이팅 시스템
--   Date and Time:   05:33 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      8
--       Items:                   13
--       Processes:                6
--       Regions:                 18
--       Buttons:                  2
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,unistr('\C2E0\ACC4\C57D \C5B8\B354\B77C\C774\D305 \C2DC\C2A4\D15C'))
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'NEW-BUSINESS')
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
,p_logo_text=>unistr('\C2E0\ACC4\C57D \C5B8\B354\B77C\C774\D305')
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
,p_navigation_list_template_id=>wwv_flow_imp.id(132721730215506017)
,p_nav_list_template_options=>'#DEFAULT#:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(132721278363506017)
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
 p_id=>wwv_flow_imp.id(182948324094778)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('AIDP \BB38\C11C')
,p_static_id=>'nav-aidp-docs'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-cloud-upload'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'20'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(182773815094778)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\CCAD\C57D \D604\D669')
,p_static_id=>'nav-applications'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-list-alt'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'10'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(183266569094779)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>unistr('\ACC4\C57D \C0DD\C131')
,p_static_id=>'nav-core-handoff'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-check-circle'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'50'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(2429624000018)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'1'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(183119815094779)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('\C57D\AD00 \AC80\D1A0')
,p_static_id=>'nav-terms-review'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-file-text-o'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'40'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(183024005094778)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('\C5B8\B354\B77C\C774\D305')
,p_static_id=>'nav-underwriting'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-user-md'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'30'
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
 p_id=>wwv_flow_imp.id(183526790094782)
,p_short_name=>unistr('AIDP \BB38\C11C')
,p_static_id=>'bc-aidp-docs'
,p_link=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
,p_page_id=>20
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(183395929094782)
,p_short_name=>unistr('\CCAD\C57D \D604\D669')
,p_static_id=>'bc-applications'
,p_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
,p_page_id=>10
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(183784489094782)
,p_short_name=>unistr('\ACC4\C57D \C0DD\C131')
,p_static_id=>'bc-core-handoff'
,p_link=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:::'
,p_page_id=>50
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(183318883094782)
,p_short_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'bc-dashboard'
,p_link=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(183727899094782)
,p_short_name=>unistr('\C57D\AD00 \AC80\D1A0')
,p_static_id=>'bc-terms-review'
,p_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
,p_page_id=>40
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(183581958094782)
,p_short_name=>unistr('\C5B8\B354\B77C\C774\D305')
,p_static_id=>'bc-underwriting'
,p_link=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
,p_page_id=>30
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
,p_default_page_template=>wwv_flow_imp.id(132583961193505889)
,p_default_dialog_template=>wwv_flow_imp.id(132578819360505883)
,p_error_template=>wwv_flow_imp.id(132568779882505873)
,p_printer_friendly_template=>wwv_flow_imp.id(132583961193505889)
,p_login_template=>wwv_flow_imp.id(132568779882505873)
,p_default_button_template=>wwv_flow_imp.id(132733865718506026)
,p_default_region_template=>wwv_flow_imp.id(132660752871505975)
,p_default_chart_template=>wwv_flow_imp.id(132660752871505975)
,p_default_form_template=>wwv_flow_imp.id(132660752871505975)
,p_default_reportr_template=>wwv_flow_imp.id(132660752871505975)
,p_default_wizard_template=>wwv_flow_imp.id(132660752871505975)
,p_default_menur_template=>wwv_flow_imp.id(132673120301505984)
,p_default_listr_template=>wwv_flow_imp.id(132660752871505975)
,p_default_irr_template=>wwv_flow_imp.id(132650915782505967)
,p_default_report_template=>wwv_flow_imp.id(132698887377506001)
,p_default_label_template=>wwv_flow_imp.id(132731452172506024)
,p_default_menu_template=>wwv_flow_imp.id(132735530372506027)
,p_default_list_template=>wwv_flow_imp.id(132715325167506013)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(132727114387506021)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(132721730215506017)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(132596903661505911)
,p_default_dialogr_template=>wwv_flow_imp.id(132594120381505907)
,p_default_option_label=>wwv_flow_imp.id(132731452172506024)
,p_default_required_label=>wwv_flow_imp.id(132732679110506025)
,p_default_navbar_list_template=>wwv_flow_imp.id(132721278363506017)
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
,p_name=>unistr('\C2E0\ACC4\C57D \B300\C2DC\BCF4\B4DC')
,p_alias=>'DASHBOARD'
,p_step_title=>unistr('\C2E0\ACC4\C57D \C5B8\B354\B77C\C774\D305 \C2DC\C2A4\D15C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(183983987094782)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(185317732094783)
,p_name=>unistr('OCI AIDP \C124\C815')
,p_static_id=>'nb-aidp-config'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select config_key "\C124\C815",'),
'       case',
unistr('         when config_value is null then ''(\BBF8\C124\C815)'''),
'         when config_key like ''%OCID%'' then substr(config_value, 1, 28) || ''...''',
'         else config_value',
unistr('       end "\AC12",'),
unistr('       description "\C124\BA85"'),
'  from soe.nb_aidp_config',
' order by config_key'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185516746094783)
,p_query_column_id=>2
,p_column_alias=>unistr('\AC12')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\AC12')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185601448094783)
,p_query_column_id=>3
,p_column_alias=>unistr('\C124\BA85')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C124\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185418081094783)
,p_query_column_id=>1
,p_column_alias=>unistr('\C124\C815')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C124\C815')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(184127932094783)
,p_name=>unistr('\C2E0\ACC4\C57D \C5C5\BB34 \C694\C57D')
,p_static_id=>'nb-kpi'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>unistr('select label "\C9C0\D45C", value "\AC12" from soe.nb_dashboard_kpi_v order by seq')
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>10
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184350875094783)
,p_query_column_id=>2
,p_column_alias=>unistr('\AC12')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\AC12')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184250625094783)
,p_query_column_id=>1
,p_column_alias=>unistr('\C9C0\D45C')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\C9C0\D45C')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(184386714094783)
,p_name=>unistr('\CD5C\ADFC \CCAD\C57D \CC98\B9AC')
,p_static_id=>'nb-recent-applications'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       received_at "\C811\C218\C2DC\AC01",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       product_name "\C0C1\D488",'),
'       aidp_status "AIDP",',
unistr('       risk_grade "\C704\D5D8",'),
unistr('       decision_code "\D310\C815",'),
unistr('       substr(decision_reason, 1, 220) "\D310\C815\ADFC\AC70"'),
'  from soe.nb_application_v',
' order by application_id desc'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184915663094783)
,p_query_column_id=>5
,p_column_alias=>'AIDP'
,p_column_display_sequence=>50
,p_column_heading=>'AIDP'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184859743094783)
,p_query_column_id=>4
,p_column_alias=>unistr('\C0C1\D488')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\C0C1\D488')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185013869094783)
,p_query_column_id=>6
,p_column_alias=>unistr('\C704\D5D8')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C704\D5D8')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184629111094783)
,p_query_column_id=>2
,p_column_alias=>unistr('\C811\C218\C2DC\AC01')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\C811\C218\C2DC\AC01')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184537197094783)
,p_query_column_id=>1
,p_column_alias=>unistr('\CCAD\C57DID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CCAD\C57DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(184748028094783)
,p_query_column_id=>3
,p_column_alias=>unistr('\CCAD\C57D\C790')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\CCAD\C57D\C790')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185135994094783)
,p_query_column_id=>7
,p_column_alias=>unistr('\D310\C815')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\D310\C815')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(185206907094783)
,p_query_column_id=>8
,p_column_alias=>unistr('\D310\C815\ADFC\AC70')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\D310\C815\ADFC\AC70')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\CCAD\C57D \C811\C218 \D604\D669')
,p_alias=>'APPLICATIONS'
,p_step_title=>unistr('\CCAD\C57D \C811\C218 \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(185829553094783)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(185958211094783)
,p_plug_name=>unistr('\C2E0\ACC4\C57D \CCAD\C57D \BAA9\B85D')
,p_static_id=>'nb-application-ir'
,p_plug_template=>wwv_flow_imp.id(132650915782505967)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       received_at "\C811\C218\C2DC\AC01",'),
unistr('       customer_id "\ACE0\AC1DID",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       product_code "\C0C1\D488\CF54\B4DC",'),
unistr('       product_name "\C0C1\D488\BA85",'),
unistr('       coverage_amt "\AC00\C785\AE08\C561",'),
unistr('       premium_amt "\C6D4\BCF4\D5D8\B8CC",'),
unistr('       channel_name "\CC44\B110",'),
unistr('       fp_id "\B2F4\B2F9FP",'),
unistr('       status "\C0C1\D0DC",'),
unistr('       aidp_status "AIDP\C0C1\D0DC",'),
unistr('       underwriting_status "\C2EC\C0AC\C0C1\D0DC",'),
unistr('       risk_score "\C704\D5D8\C810\C218",'),
unistr('       risk_grade "\C704\D5D8\B4F1\AE09",'),
unistr('       decision_code "\D310\C815",'),
unistr('       decision_reason "\D310\C815\ADFC\AC70",'),
unistr('       document_count "\BB38\C11C\C218",'),
unistr('       extracted_count "\CD94\CD9C\C644\B8CC"'),
'  from soe.nb_application_v',
' order by application_id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(186028708094783)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>13016158614801156
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(186082019094783)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'NB12010'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\CCAD\C57DID":"\C811\C218\C2DC\AC01":"\ACE0\AC1DID":"\CCAD\C57D\C790":"\C0C1\D488\CF54\B4DC":"\C0C1\D488\BA85":"\AC00\C785\AE08\C561":"\C6D4\BCF4\D5D8\B8CC":"\CC44\B110":"\B2F4\B2F9FP":"\C0C1\D0DC":"AIDP\C0C1\D0DC":"\C2EC\C0AC\C0C1\D0DC":"\C704\D5D8\C810\C218":"\C704\D5D8\B4F1\AE09":"\D310\C815":"\D310\C815\ADFC\AC70":"\BB38\C11C\C218":"\CD94\CD9C\C644\B8CC"')
);
end;
/
prompt --application/pages/page_00020
begin
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>unistr('AIDP \BB38\C11C \C811\C218/\CD94\CD9C')
,p_alias=>'AIDP-DOCUMENTS'
,p_step_title=>unistr('AIDP \BB38\C11C \C811\C218/\CD94\CD9C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(186284536094783)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(186477291094783)
,p_name=>unistr('AIDP \BB38\C11C \CC98\B9AC \D050')
,p_static_id=>'nb-aidp-doc-report'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select document_id "\BB38\C11CID",'),
'       ''<strong>'' || application_id || ''</strong><br><span class="nb-muted">'' ||',
unistr('       apex_escape.html(applicant_name) || ''</span>'' "\CCAD\C57D",'),
'       ''<strong>'' || apex_escape.html(nvl(doc_name, ''-'')) ||',
unistr('       ''</strong><br><span class="nb-muted">'' || apex_escape.html(doc_type) || ''</span>'' "\BB38\C11C",'),
'       ''<span class="nb-file" title="'' || apex_escape.html_attribute(nvl(file_name, ''-'')) || ''">'' ||',
'       apex_escape.html(case when length(file_name) > 34 then substr(file_name, 1, 26) || ''...'' || substr(file_name, -5) else nvl(file_name, ''-'') end) ||',
'       ''</span><br><span class="nb-muted">'' ||',
'       case when document_size_bytes is null then ''-'' else to_char(ceil(document_size_bytes / 1024), ''FM999G999G990'') || '' KB'' end ||',
unistr('       ''</span>'' "\D30C\C77C",'),
'       ''<span class="nb-badge '' ||',
'       case aidp_status',
'         when ''AIDP_EXTRACTED'' then ''nb-ok''',
'         when ''AIDP_READY'' then ''nb-info''',
'         when ''PROCESSING'' then ''nb-warn''',
'         when ''FAILED'' then ''nb-bad''',
'         else ''nb-neutral''',
'       end || ''">'' || apex_escape.html(aidp_status) || ''</span><br><span class="nb-muted">'' ||',
unistr('       apex_escape.html(next_action) || ''</span>'' "\C0C1\D0DC",'),
'       case when confidence_score is null then ''-'' else to_char(round(confidence_score * 100, 1), ''FM990D0'') || ''%'' end ||',
unistr('       ''<br><span class="nb-muted">\D544\B4DC '' || nvl(to_char(field_count), ''0'') || ''</span>'' ||'),
'       case when processor_job_id is null then '''' else ''<br><span class="nb-mono" title="'' ||',
'       apex_escape.html_attribute(processor_job_id) || ''">'' ||',
'       apex_escape.html(substr(processor_job_id, 1, 22)) || ''...</span>'' end "AIDP",',
'       ''<div class="nb-preview" title="'' || apex_escape.html_attribute(nvl(aidp_message, ''-'')) || ''">'' ||',
'       apex_escape.html(case when length(aidp_message) > 120 then substr(aidp_message, 1, 120) || ''...'' else nvl(aidp_message, ''-'') end) ||',
unistr('       ''</div>'' "\BA54\C2DC\C9C0",'),
'       ''<div class="nb-preview" title="'' || apex_escape.html_attribute(nvl(text_preview, ''-'')) || ''">'' ||',
'       apex_escape.html(case when length(text_preview) > 160 then substr(text_preview, 1, 160) || ''...'' else nvl(text_preview, ''-'') end) ||',
unistr('       ''</div>'' "\BBF8\B9AC\BCF4\AE30",'),
'       ''<span class="nb-actions"><a class="t-Button t-Button--small" href="'' ||',
'       apex_page.get_url(p_page => 20, p_items => ''P20_ACTION,P20_DOCUMENT_ID'', p_values => ''DEMO,'' || document_id) ||',
unistr('       ''"><span class="fa fa-magic" aria-hidden="true"></span>\B370\BAA8\CD94\CD9C</a><a class="t-Button t-Button--small" href="'' ||'),
'       apex_page.get_url(p_page => 20, p_items => ''P20_ACTION,P20_DOCUMENT_ID'', p_values => ''OCI,'' || document_id) ||',
unistr('       ''"><span class="fa fa-cloud-upload" aria-hidden="true"></span>OCI\C694\CCAD</a></span>'' "\CC98\B9AC"'),
'  from soe.nb_document_v',
' order by document_id desc'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187954799094784)
,p_query_column_id=>6
,p_column_alias=>'AIDP'
,p_column_display_sequence=>60
,p_column_heading=>'AIDP'
,p_column_html_expression=>'#AIDP#'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187987252094784)
,p_query_column_id=>7
,p_column_alias=>unistr('\BA54\C2DC\C9C0')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\BA54\C2DC\C9C0')
,p_column_html_expression=>unistr('#\BA54\C2DC\C9C0#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187590155094784)
,p_query_column_id=>3
,p_column_alias=>unistr('\BB38\C11C')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\BB38\C11C')
,p_column_html_expression=>unistr('#\BB38\C11C#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187391948094784)
,p_query_column_id=>1
,p_column_alias=>unistr('\BB38\C11CID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\BB38\C11CID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188133325094784)
,p_query_column_id=>8
,p_column_alias=>unistr('\BBF8\B9AC\BCF4\AE30')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\BBF8\B9AC\BCF4\AE30')
,p_column_html_expression=>unistr('#\BBF8\B9AC\BCF4\AE30#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187780220094784)
,p_query_column_id=>5
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C0C1\D0DC')
,p_column_html_expression=>unistr('#\C0C1\D0DC#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188217792094784)
,p_query_column_id=>9
,p_column_alias=>unistr('\CC98\B9AC')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\CC98\B9AC')
,p_column_html_expression=>unistr('#\CC98\B9AC#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187488034094784)
,p_query_column_id=>2
,p_column_alias=>unistr('\CCAD\C57D')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\CCAD\C57D')
,p_column_html_expression=>unistr('#\CCAD\C57D#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(187736999094784)
,p_query_column_id=>4
,p_column_alias=>unistr('\D30C\C77C')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\D30C\C77C')
,p_column_html_expression=>unistr('#\D30C\C77C#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(188323198094784)
,p_name=>unistr('\CD5C\ADFC AIDP \CD94\CD9C \D544\B4DC')
,p_static_id=>'nb-aidp-field-recent'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       document_id "\BB38\C11CID",'),
unistr('       field_label "\D56D\BAA9",'),
unistr('       field_name "\D544\B4DC\BA85",'),
unistr('       field_value "\CD94\CD9C\AC12",'),
unistr('       normalized_value "\C815\ADDC\D654\AC12",'),
unistr('       case when confidence_pct is null then ''-'' else to_char(confidence_pct, ''FM990D0'') || ''%'' end "\C2E0\B8B0\B3C4",'),
unistr('       page_no "\D398\C774\C9C0"'),
'  from soe.nb_aidp_field_v',
' order by document_id desc, field_name',
' fetch first 40 rows only'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>40
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188474816094784)
,p_query_column_id=>2
,p_column_alias=>unistr('\BB38\C11CID')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\BB38\C11CID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(189014001094784)
,p_query_column_id=>7
,p_column_alias=>unistr('\C2E0\B8B0\B3C4')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C2E0\B8B0\B3C4')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188934290094784)
,p_query_column_id=>6
,p_column_alias=>unistr('\C815\ADDC\D654\AC12')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C815\ADDC\D654\AC12')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188432930094784)
,p_query_column_id=>1
,p_column_alias=>unistr('\CCAD\C57DID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CCAD\C57DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188869683094784)
,p_query_column_id=>5
,p_column_alias=>unistr('\CD94\CD9C\AC12')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\CD94\CD9C\AC12')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(189095835094784)
,p_query_column_id=>8
,p_column_alias=>unistr('\D398\C774\C9C0')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\D398\C774\C9C0')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188671471094784)
,p_query_column_id=>4
,p_column_alias=>unistr('\D544\B4DC\BA85')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\D544\B4DC\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(188629326094784)
,p_query_column_id=>3
,p_column_alias=>unistr('\D56D\BAA9')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\D56D\BAA9')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(186421918094783)
,p_plug_name=>unistr('\CCAD\C57D \C11C\B958 \C5C5\B85C\B4DC')
,p_static_id=>'nb-doc-upload'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(186615139094783)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(186421918094783)
,p_button_name=>'UPLOAD_DOC'
,p_static_id=>'upload-doc'
,p_button_action=>'SUBMIT'
,p_button_template_id=>wwv_flow_imp.id(132733865718506026)
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('\BB38\C11C \C5C5\B85C\B4DC')
,p_button_position=>'NEXT'
,p_icon_css_classes=>'fa-upload'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(187190212094784)
,p_name=>'P20_ACTION'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(186700864094783)
,p_name=>'P20_APPLICATION_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_item_default=>'120002'
,p_prompt=>unistr('\CCAD\C57DID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>12
,p_field_template=>wwv_flow_imp.id(132731452172506024)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(187284622094784)
,p_name=>'P20_DOCUMENT_ID'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(187021815094784)
,p_name=>'P20_DOC_FILE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_prompt=>unistr('\BB38\C11C \D30C\C77C')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_FILE'
,p_cSize=>80
,p_tag_attributes=>'accept="application/pdf,image/*,text/plain"'
,p_field_template=>wwv_flow_imp.id(132731452172506024)
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(186952685094784)
,p_name=>'P20_DOC_NAME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_prompt=>unistr('\BB38\C11C\BA85')
,p_placeholder=>unistr('\C608: \AC74\AC15\ACE0\C9C0\C11C')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>60
,p_field_template=>wwv_flow_imp.id(132731452172506024)
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--stretchInputs'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(186801166094784)
,p_name=>'P20_DOC_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_item_default=>'APPLICATION_FORM'
,p_prompt=>unistr('\BB38\C11C\C720\D615')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>unistr('STATIC:\CCAD\C57D\C11C;APPLICATION_FORM,\AC74\AC15\ACE0\C9C0\C11C;HEALTH_DISCLOSURE,\C9C4\B2E8\C11C;MEDICAL_CERTIFICATE,\C18C\B4DD\C99D\BE59;INCOME_PROOF,\C57D\AD00/\C0C1\D488\C124\BA85\C11C;PRODUCT_TERMS')
,p_field_template=>wwv_flow_imp.id(132731452172506024)
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(187110455094784)
,p_name=>'P20_LAST_DOCUMENT_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(186421918094783)
,p_prompt=>unistr('\CD5C\ADFC \BB38\C11CID')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>wwv_flow_imp.id(132731452172506024)
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(189209374094784)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run AIDP Document Action'
,p_static_id=>'run-aidp-document-action'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P20_ACTION is not null and :P20_DOCUMENT_ID is not null then',
'    if :P20_ACTION = ''DEMO'' then',
'      soe.nb_aidp_pkg.demo_extract(to_number(:P20_DOCUMENT_ID));',
'    elsif :P20_ACTION = ''OCI'' then',
'      soe.nb_aidp_pkg.queue_oci_aidp(to_number(:P20_DOCUMENT_ID));',
'    end if;',
'    :P20_LAST_DOCUMENT_ID := :P20_DOCUMENT_ID;',
'    :P20_ACTION := null;',
'    :P20_DOCUMENT_ID := null;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>13019339280801157
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(189342183094784)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Upload New Business Document'
,p_static_id=>'upload-new-business-document'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_filename    varchar2(512);',
'  l_mime_type   varchar2(200);',
'  l_blob        blob;',
'  l_document_id number;',
'begin',
'  if nvl(:REQUEST, ''-'') <> ''UPLOAD_DOC'' then',
'    return;',
'  end if;',
'',
'  if :P20_APPLICATION_ID is null then',
unistr('    raise_application_error(-20251, ''\CCAD\C57DID\B97C \C785\B825\D558\C138\C694.'');'),
'  end if;',
'',
'  if :P20_DOC_FILE is not null then',
'    select filename, mime_type, blob_content',
'      into l_filename, l_mime_type, l_blob',
'      from apex_application_temp_files',
'     where name = :P20_DOC_FILE',
'     order by created_on desc',
'     fetch first 1 row only;',
'  else',
unistr('    raise_application_error(-20252, ''\C5C5\B85C\B4DC\D560 \BB38\C11C \D30C\C77C\C744 \C120\D0DD\D558\C138\C694.'');'),
'  end if;',
'',
'  insert into soe.nb_document (',
'    application_id,',
'    doc_type,',
'    doc_name,',
'    file_name,',
'    mime_type,',
'    document_size_bytes,',
'    document_blob,',
'    content_text,',
'    aidp_status,',
'    aidp_model,',
'    aidp_message',
'  ) values (',
'    to_number(:P20_APPLICATION_ID),',
'    nvl(:P20_DOC_TYPE, ''APPLICATION_FORM''),',
'    nvl(:P20_DOC_NAME, l_filename),',
'    l_filename,',
'    l_mime_type,',
'    dbms_lob.getlength(l_blob),',
'    l_blob,',
unistr('    ''\C5C5\B85C\B4DC \D30C\C77C '' || l_filename || '' \C758 OCI AIDP \CD94\CD9C \B300\AE30'','),
'    ''AIDP_READY'',',
'    ''OCI_DOCUMENT_UNDERSTANDING'',',
unistr('    ''\C5C5\B85C\B4DC \C644\B8CC - OCI Document Understanding worker \B300\AE30'''),
'  ) returning document_id into l_document_id;',
'',
'  update soe.nb_application',
'     set status = ''AIDP_REVIEW'',',
'         aidp_status = ''AIDP_READY'',',
'         updated_at = systimestamp',
'   where application_id = to_number(:P20_APPLICATION_ID);',
'',
'  :P20_LAST_DOCUMENT_ID := l_document_id;',
'  commit;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_success_message=>unistr('\C2E0\ACC4\C57D \BB38\C11C\B97C \C5C5\B85C\B4DC\D558\ACE0 OCI AIDP \CC98\B9AC \D050\C5D0 \B123\C5C8\C2B5\B2C8\B2E4.')
,p_internal_uid=>13019472089801157
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('\C5B8\B354\B77C\C774\D305 \C2EC\C0AC')
,p_alias=>'UNDERWRITING'
,p_step_title=>unistr('\C5B8\B354\B77C\C774\D305 \C2EC\C0AC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(189537507094784)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(189938640094784)
,p_name=>unistr('\C5B8\B354\B77C\C774\D305 \D050')
,p_static_id=>'nb-underwriting-report'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       product_name "\C0C1\D488",'),
unistr('       to_char(coverage_amt, ''FM999G999G999G990'') "\AC00\C785\AE08\C561",'),
unistr('       to_char(premium_amt, ''FM999G999G990'') "\C6D4\BCF4\D5D8\B8CC",'),
unistr('       risk_score "\C704\D5D8\C810\C218",'),
unistr('       risk_grade "\C704\D5D8\B4F1\AE09",'),
unistr('       decision_code "\D310\C815",'),
unistr('       decision_reason "\D310\C815\ADFC\AC70",'),
unistr('       latest_note "\C2EC\C0AC\BA54\BAA8",'),
unistr('       status "\C0C1\D0DC",'),
'       ''<a class="t-Button t-Button--small" href="'' ||',
'       apex_page.get_url(p_page => 30, p_items => ''P30_ACTION,P30_APPLICATION_ID'', p_values => ''RUN,'' || application_id) ||',
unistr('       ''"><span class="fa fa-refresh" aria-hidden="true"></span>\C2EC\C0AC\C2E4\D589</a>'' "\CC98\B9AC"'),
'  from soe.nb_underwriting_v',
' order by case risk_grade when ''HIGH'' then 1 when ''MEDIUM'' then 2 when ''LOW'' then 3 else 9 end,',
'          application_id desc'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>30
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190294173094785)
,p_query_column_id=>4
,p_column_alias=>unistr('\AC00\C785\AE08\C561')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\AC00\C785\AE08\C561')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(191020743094785)
,p_query_column_id=>11
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>110
,p_column_heading=>unistr('\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190174643094785)
,p_query_column_id=>3
,p_column_alias=>unistr('\C0C1\D488')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\C0C1\D488')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190925888094785)
,p_query_column_id=>10
,p_column_alias=>unistr('\C2EC\C0AC\BA54\BAA8')
,p_column_display_sequence=>100
,p_column_heading=>unistr('\C2EC\C0AC\BA54\BAA8')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190393468094785)
,p_query_column_id=>5
,p_column_alias=>unistr('\C6D4\BCF4\D5D8\B8CC')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C6D4\BCF4\D5D8\B8CC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190614575094785)
,p_query_column_id=>7
,p_column_alias=>unistr('\C704\D5D8\B4F1\AE09')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C704\D5D8\B4F1\AE09')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190541423094785)
,p_query_column_id=>6
,p_column_alias=>unistr('\C704\D5D8\C810\C218')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\C704\D5D8\C810\C218')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(191084670094785)
,p_query_column_id=>12
,p_column_alias=>unistr('\CC98\B9AC')
,p_column_display_sequence=>120
,p_column_heading=>unistr('\CC98\B9AC')
,p_column_html_expression=>unistr('#\CC98\B9AC#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190068684094784)
,p_query_column_id=>1
,p_column_alias=>unistr('\CCAD\C57DID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CCAD\C57DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190114976094784)
,p_query_column_id=>2
,p_column_alias=>unistr('\CCAD\C57D\C790')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\CCAD\C57D\C790')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190719906094785)
,p_query_column_id=>8
,p_column_alias=>unistr('\D310\C815')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\D310\C815')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(190851801094785)
,p_query_column_id=>9
,p_column_alias=>unistr('\D310\C815\ADFC\AC70')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\D310\C815\ADFC\AC70')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(189599608094784)
,p_name=>'P30_ACTION'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(189766774094784)
,p_name=>'P30_APPLICATION_ID'
,p_item_sequence=>20
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(189840060094784)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run Underwriting Action'
,p_static_id=>'run-underwriting-action'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P30_ACTION = ''RUN'' and :P30_APPLICATION_ID is not null then',
'    soe.nb_aidp_pkg.run_underwriting(to_number(:P30_APPLICATION_ID));',
'    :P30_ACTION := null;',
'    :P30_APPLICATION_ID := null;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>13019969966801157
);
end;
/
prompt --application/pages/page_00040
begin
wwv_flow_imp_page.create_page(
 p_id=>40
,p_name=>unistr('\C57D\AD00/\C0C1\D488\C124\BA85\C11C \AC80\D1A0')
,p_alias=>'TERMS-REVIEW'
,p_step_title=>unistr('\C57D\AD00/\C0C1\D488\C124\BA85\C11C \AC80\D1A0')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(191334563094785)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(191690865094785)
,p_plug_name=>unistr('AIDP \CD94\CD9C \D544\B4DC')
,p_static_id=>'nb-aidp-field-ir'
,p_plug_template=>wwv_flow_imp.id(132650915782505967)
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       document_id "\BB38\C11CID",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       doc_name "\BB38\C11C\BA85",'),
unistr('       doc_type "\BB38\C11C\C720\D615",'),
unistr('       field_label "\D56D\BAA9",'),
unistr('       field_name "\D544\B4DC\BA85",'),
unistr('       field_value "\CD94\CD9C\AC12",'),
unistr('       normalized_value "\C815\ADDC\D654\AC12",'),
unistr('       confidence_score "\C2E0\B8B0\B3C4"'),
'  from soe.nb_aidp_field_v',
' order by application_id desc, document_id, field_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(191801229094785)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>13021931135801158
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(191941210094785)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'NB12041'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\CCAD\C57DID":"\BB38\C11CID":"\CCAD\C57D\C790":"\BB38\C11C\BA85":"\BB38\C11C\C720\D615":"\D56D\BAA9":"\D544\B4DC\BA85":"\CD94\CD9C\AC12":"\C815\ADDC\D654\AC12":"\C2E0\B8B0\B3C4"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(191454201094785)
,p_plug_name=>unistr('\C0C1\D488\BCC4 \C57D\AD00 \AC80\D1A0 \D3EC\C778\D2B8')
,p_static_id=>'nb-terms-review-ir'
,p_plug_template=>wwv_flow_imp.id(132650915782505967)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       product_code "\C0C1\D488\CF54\B4DC",'),
unistr('       product_name "\C0C1\D488\BA85",'),
unistr('       terms_doc_code "\C57D\AD00\BB38\C11C",'),
unistr('       aidp_terms_focus "AIDP\AC80\D1A0\D3EC\C778\D2B8",'),
unistr('       decision_code "\D310\C815",'),
unistr('       decision_reason "\D310\C815\ADFC\AC70"'),
'  from soe.nb_terms_review_v',
' order by application_id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(191508556094785)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>13021638462801158
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(191653391094785)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'NB12040'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\CCAD\C57DID":"\CCAD\C57D\C790":"\C0C1\D488\CF54\B4DC":"\C0C1\D488\BA85":"\C57D\AD00\BB38\C11C":"AIDP\AC80\D1A0\D3EC\C778\D2B8":"\D310\C815":"\D310\C815\ADFC\AC70"')
);
end;
/
prompt --application/pages/page_00050
begin
wwv_flow_imp_page.create_page(
 p_id=>50
,p_name=>unistr('\C2B9\C778 \ACC4\C57D \C0DD\C131')
,p_alias=>'CORE-HANDOFF'
,p_step_title=>unistr('\C2B9\C778 \ACC4\C57D \C0DD\C131')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.a-IRR-table{table-layout:auto}',
'.a-IRR-table td{vertical-align:top;overflow-wrap:anywhere}',
'.t-Report-cell{vertical-align:top}',
'.nb-actions{display:inline-flex;gap:6px;flex-wrap:nowrap;white-space:nowrap}',
'.nb-actions .t-Button,.t-Report-cell .t-Button{margin:0 2px 2px 0}',
'.nb-muted{color:#6b7280;font-size:12px;line-height:1.25}',
'.nb-file{display:inline-block;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
'.nb-mono{display:inline-block;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:11px;color:#374151}',
'.nb-preview{max-height:3.8em;overflow:hidden;line-height:1.28;color:#1f2937}',
'.nb-badge{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:2px 7px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap}',
'.nb-ok{background:#e8f7ee;color:#146c43}',
'.nb-info{background:#e8f1ff;color:#1d4ed8}',
'.nb-warn{background:#fff4d6;color:#92400e}',
'.nb-bad{background:#fee2e2;color:#b91c1c}',
'.nb-neutral{background:#eef2f7;color:#334155}',
'[id="nb-aidp-doc-report"] .t-Report,[id="nb-aidp-field-recent"] .t-Report{overflow-x:auto}',
'[id="nb-aidp-doc-report"] .t-Report-report{display:table!important;table-layout:fixed;width:1180px;min-width:1180px}',
'[id="nb-aidp-field-recent"] .t-Report-report{display:table!important;table-layout:fixed;width:980px;min-width:980px}',
'[id="nb-aidp-doc-report"] .t-Report-report thead,[id="nb-aidp-field-recent"] .t-Report-report thead{display:table-header-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tbody,[id="nb-aidp-field-recent"] .t-Report-report tbody{display:table-row-group!important}',
'[id="nb-aidp-doc-report"] .t-Report-report tr,[id="nb-aidp-field-recent"] .t-Report-report tr{display:table-row!important}',
'[id="nb-aidp-doc-report"] .t-Report-report th,[id="nb-aidp-doc-report"] .t-Report-report td,',
'[id="nb-aidp-field-recent"] .t-Report-report th,[id="nb-aidp-field-recent"] .t-Report-report td{display:table-cell!important;vertical-align:top;font-size:13px;line-height:1.35;overflow:hidden}',
'[id="nb-aidp-doc-report"] .t-Report-cell:before,[id="nb-aidp-field-recent"] .t-Report-cell:before{display:none!important;content:none!important}',
'[id="nb-aidp-doc-report"] th:nth-child(1),[id="nb-aidp-doc-report"] td:nth-child(1){width:64px}',
'[id="nb-aidp-doc-report"] th:nth-child(2),[id="nb-aidp-doc-report"] td:nth-child(2){width:105px}',
'[id="nb-aidp-doc-report"] th:nth-child(3),[id="nb-aidp-doc-report"] td:nth-child(3){width:165px}',
'[id="nb-aidp-doc-report"] th:nth-child(4),[id="nb-aidp-doc-report"] td:nth-child(4){width:175px}',
'[id="nb-aidp-doc-report"] th:nth-child(5),[id="nb-aidp-doc-report"] td:nth-child(5){width:140px}',
'[id="nb-aidp-doc-report"] th:nth-child(6),[id="nb-aidp-doc-report"] td:nth-child(6){width:135px}',
'[id="nb-aidp-doc-report"] th:nth-child(7),[id="nb-aidp-doc-report"] td:nth-child(7){width:180px}',
'[id="nb-aidp-doc-report"] th:nth-child(8),[id="nb-aidp-doc-report"] td:nth-child(8){width:240px}',
'[id="nb-aidp-doc-report"] th:nth-child(9),[id="nb-aidp-doc-report"] td:nth-child(9){width:176px}',
''))
,p_step_template=>wwv_flow_imp.id(132583961193505889)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(192091043094785)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(132735530372506027)
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(192554360094785)
,p_name=>unistr('Core Banking \BC18\C601 \D6C4\BCF4')
,p_static_id=>'nb-core-handoff-report'
,p_template=>wwv_flow_imp.id(132660752871505975)
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('select application_id "\CCAD\C57DID",'),
unistr('       applicant_name "\CCAD\C57D\C790",'),
unistr('       customer_id "\ACE0\AC1DID",'),
unistr('       product_code "\C0C1\D488\CF54\B4DC",'),
unistr('       product_name "\C0C1\D488\BA85",'),
unistr('       to_char(coverage_amt, ''FM999G999G999G990'') "\AC00\C785\AE08\C561",'),
unistr('       to_char(premium_amt, ''FM999G999G990'') "\C6D4\BCF4\D5D8\B8CC",'),
unistr('       status "\C0C1\D0DC",'),
unistr('       decision_code "\D310\C815",'),
unistr('       core_contract_no "\ACC4\C57D\BC88\D638",'),
unistr('       handoff_status "\BC18\C601\C0C1\D0DC",'),
'       case',
'         when status <> ''APPROVED''',
'              and decision_code in (''AUTO_APPROVE_CANDIDATE'',''MANUAL_REVIEW'',''MEDICAL_REVIEW'') then',
'           ''<a class="t-Button t-Button--small t-Button--hot" href="'' ||',
'           apex_page.get_url(p_page => 50, p_items => ''P50_ACTION,P50_APPLICATION_ID'', p_values => ''APPROVE,'' || application_id) ||',
unistr('           ''"><span class="fa fa-check" aria-hidden="true"></span>\C2B9\C778</a>'''),
'         else ''-''',
unistr('       end "\CC98\B9AC"'),
'  from soe.nb_core_handoff_v',
' order by case when status = ''APPROVED'' then 2 else 1 end, application_id desc'))
,p_query_row_template=>wwv_flow_imp.id(132698887377506001)
,p_query_num_rows=>30
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193131074094785)
,p_query_column_id=>6
,p_column_alias=>unistr('\AC00\C785\AE08\C561')
,p_column_display_sequence=>60
,p_column_heading=>unistr('\AC00\C785\AE08\C561')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193562307094785)
,p_query_column_id=>10
,p_column_alias=>unistr('\ACC4\C57D\BC88\D638')
,p_column_display_sequence=>100
,p_column_heading=>unistr('\ACC4\C57D\BC88\D638')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(192868230094785)
,p_query_column_id=>3
,p_column_alias=>unistr('\ACE0\AC1DID')
,p_column_display_sequence=>30
,p_column_heading=>unistr('\ACE0\AC1DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193572763094785)
,p_query_column_id=>11
,p_column_alias=>unistr('\BC18\C601\C0C1\D0DC')
,p_column_display_sequence=>110
,p_column_heading=>unistr('\BC18\C601\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193271764094785)
,p_query_column_id=>8
,p_column_alias=>unistr('\C0C1\D0DC')
,p_column_display_sequence=>80
,p_column_heading=>unistr('\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193036449094785)
,p_query_column_id=>5
,p_column_alias=>unistr('\C0C1\D488\BA85')
,p_column_display_sequence=>50
,p_column_heading=>unistr('\C0C1\D488\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(192944284094785)
,p_query_column_id=>4
,p_column_alias=>unistr('\C0C1\D488\CF54\B4DC')
,p_column_display_sequence=>40
,p_column_heading=>unistr('\C0C1\D488\CF54\B4DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193212333094785)
,p_query_column_id=>7
,p_column_alias=>unistr('\C6D4\BCF4\D5D8\B8CC')
,p_column_display_sequence=>70
,p_column_heading=>unistr('\C6D4\BCF4\D5D8\B8CC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193719307094785)
,p_query_column_id=>12
,p_column_alias=>unistr('\CC98\B9AC')
,p_column_display_sequence=>120
,p_column_heading=>unistr('\CC98\B9AC')
,p_column_html_expression=>unistr('#\CC98\B9AC#')
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(192604452094785)
,p_query_column_id=>1
,p_column_alias=>unistr('\CCAD\C57DID')
,p_column_display_sequence=>10
,p_column_heading=>unistr('\CCAD\C57DID')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(192698350094785)
,p_query_column_id=>2
,p_column_alias=>unistr('\CCAD\C57D\C790')
,p_column_display_sequence=>20
,p_column_heading=>unistr('\CCAD\C57D\C790')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(193450057094785)
,p_query_column_id=>9
,p_column_alias=>unistr('\D310\C815')
,p_column_display_sequence=>90
,p_column_heading=>unistr('\D310\C815')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(192179503094785)
,p_name=>'P50_ACTION'
,p_item_sequence=>10
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(192272243094785)
,p_name=>'P50_APPLICATION_ID'
,p_item_sequence=>20
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(192404849094785)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve New Business Application'
,p_static_id=>'approve-new-business-application'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P50_ACTION = ''APPROVE'' and :P50_APPLICATION_ID is not null then',
'    soe.nb_aidp_pkg.approve_application(to_number(:P50_APPLICATION_ID));',
'    :P50_ACTION := null;',
'    :P50_APPLICATION_ID := null;',
'  end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>13022534755801158
);
end;
/
prompt --application/pages/page_09999
begin
wwv_flow_imp_page.create_page(
 p_id=>9999
,p_name=>unistr('\B85C\ADF8\C778')
,p_alias=>'LOGIN'
,p_step_title=>unistr('\C2E0\ACC4\C57D \C5B8\B354\B77C\C774\D305 \B85C\ADF8\C778')
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
,p_step_template=>wwv_flow_imp.id(132583961193505889)
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
,p_plug_template=>wwv_flow_imp.id(132660752871505975)
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
