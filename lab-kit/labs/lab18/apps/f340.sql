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
,p_default_id_offset=>12437760538005619
,p_default_owner=>'GGADMIN'
);
end;
/

prompt APPLICATION 300 - DS그룹 보험 정보계 2.0
--
-- Application Export:
--   Application:     300
--   Name:            DS그룹 보험 정보계 2.0
--   Exported By:     GGADMIN
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      9
--       Items:                    3
--       Processes:                2
--       Regions:                 28
--       Buttons:                  4
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
--           Button:               1
--       PWA:
--       Globalization:
--       Reports:
--       E-Mail:
--     Supporting Objects:  Excluded
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,unistr('DS\ADF8\B8F9 \BCF4\D5D8 \C815\BCF4\ACC4 2.0'))
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'DS-INSURANCE-360')
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
,p_logo_text=>'DS Insurance Intelligence'
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
,p_version_scn=>'47498523'
,p_print_server_type=>'INSTANCE'
,p_file_storage=>'DB'
,p_is_pwa=>'N'
,p_theme_id=>42
,p_home_url=>'f?p=&APP_ID.:1:&SESSION.'
,p_login_url=>'f?p=&APP_ID.:9999:&APP_SESSION.::&DEBUG.:::'
,p_theme_style_by_user_pref=>false
,p_global_page_id=>0
,p_navigation_list_id=>wwv_flow_imp.id(3000000002000000)
,p_navigation_list_position=>'SIDE'
,p_navigation_list_template_id=>wwv_flow_imp.id(141231982935464641676)
,p_nav_list_template_options=>'#DEFAULT#:js-defaultCollapsed:js-navCollapsed--hidden:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(3000000003000000)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(141231982565336641676)
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
 p_id=>wwv_flow_imp.id(1453727428145378)
,p_list_item_display_sequence=>70
,p_list_item_link_text=>unistr('\C790\AE08\C138\D0C1 \D750\B984 \AC10\C9C0')
,p_static_id=>'nav-aml-rdf'
,p_list_item_link_target=>'f?p=&APP_ID.:60:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-project-diagram'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000005)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('\C720\C9C0\C728\00B7\D574\C9C0\C704\D5D8')
,p_static_id=>'nav-cancel'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-warning'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000002)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\ACC4\C57D\00B7\ACE0\AC1D 360')
,p_static_id=>'nav-customers'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-users'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000001)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\ACBD\C601 \B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000004)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('\BCF4\D5D8\AE08 \CCAD\AD6C')
,p_static_id=>'nav-fund'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-medkit'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000006)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>unistr('\C0C1\D488 \D3EC\D2B8\D3F4\B9AC\C624')
,p_static_id=>'nav-products'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-briefcase'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(3000000002000003)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\BCF4\D5D8\B8CC\00B7\B0A9\C785')
,p_static_id=>'nav-transactions'
,p_list_item_link_target=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-credit-card'
,p_list_item_current_type=>'TARGET_PAGE'
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
,p_default_page_template=>wwv_flow_imp.id(141231746302586641528)
,p_default_dialog_template=>wwv_flow_imp.id(141231744803151641526)
,p_error_template=>wwv_flow_imp.id(141231738202050641521)
,p_printer_friendly_template=>wwv_flow_imp.id(141231746302586641528)
,p_login_template=>wwv_flow_imp.id(141231738202050641521)
,p_default_button_template=>wwv_flow_imp.id(141231988573684641693)
,p_default_region_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_chart_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_form_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_reportr_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_wizard_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_menur_template=>wwv_flow_imp.id(141231900043525641592)
,p_default_listr_template=>wwv_flow_imp.id(141231887613368641579)
,p_default_irr_template=>wwv_flow_imp.id(141231885514208641577)
,p_default_report_template=>wwv_flow_imp.id(141231947137569641634)
,p_default_label_template=>wwv_flow_imp.id(141231987777532641689)
,p_default_menu_template=>wwv_flow_imp.id(141231990252742641696)
,p_default_list_template=>wwv_flow_imp.id(141231975923032641668)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(141231984732321641680)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(141231982935464641676)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(141231905212987641595)
,p_default_dialogr_template=>wwv_flow_imp.id(141231755042925641547)
,p_default_option_label=>wwv_flow_imp.id(141231987777532641689)
,p_default_required_label=>wwv_flow_imp.id(141231987294547641688)
,p_default_navbar_list_template=>wwv_flow_imp.id(141231982565336641676)
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
prompt --application/shared_components/user_interface/templates/button/html_button_legacy_apex_5_migration
begin
wwv_flow_imp_shared.create_button_templates(
 p_id=>wwv_flow_imp.id(1454856031268985)
,p_template_name=>'HTML button (legacy - APEX 5 migration)'
,p_static_id=>'html-button-legacy-apex-5-migration'
,p_template=>' <input type="button" value="#LABEL#" onclick="#JAVASCRIPT#" id="#DOM_ID#" class="#BUTTON_CSS_CLASSES#" #BUTTON_ATTRIBUTES#/>'
,p_hot_template=>' <input type="button" value="#LABEL#" onclick="#JAVASCRIPT#" id="#DOM_ID#" class="#BUTTON_CSS_CLASSES#" #BUTTON_ATTRIBUTES#/>'
,p_translate_this_template=>'N'
,p_theme_class_id=>13
,p_theme_id=>42
);
end;
/
prompt --application/shared_components/globalization/language
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
,p_name=>unistr('\BCF4\D5D8 \ACBD\C601 \B300\C2DC\BCF4\B4DC')
,p_alias=>'DASHBOARD'
,p_step_title=>unistr('\BCF4\D5D8 \ACBD\C601 \B300\C2DC\BCF4\B4DC')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000001000003)
,p_plug_name=>unistr('\CD5C\ADFC 14\C77C \B0A9\C785\00B7\CCAD\AD6C \CD94\C774')
,p_static_id=>unistr('\C77C\BCC4-\AC70\B798-\CD94\C774-\CD5C\ADFC-30\C77C')
,p_title=>unistr('\CD5C\ADFC 14\C77C \B0A9\C785\00B7\CCAD\AD6C \CD94\C774')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
,p_plug_query_no_data_found=>unistr('\B370\C774\D130 \C5C6\C74C')
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000001000004)
,p_region_id=>wwv_flow_imp.id(3000000001000003)
,p_chart_type=>'bar'
,p_title=>unistr('\C77C\BCC4 \AC70\B798 \AC74\C218 (\B0A9\C785/\D574\C57D)')
,p_height=>'350'
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
 p_id=>wwv_flow_imp.id(3000000001000006)
,p_chart_id=>wwv_flow_imp.id(3000000001000004)
,p_static_id=>'s-cancel-daily'
,p_seq=>20
,p_name=>unistr('\BCF4\D5D8\AE08 \CCAD\AD6C')
,p_data_source_type=>'SQL'
,p_data_source=>'select to_char(trunc(sysdate)-level+1,''MM-DD'') dt,2+mod(level*3,8) cnt from dual connect by level<=14 order by dt'
,p_series_type=>'bar'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'DT'
,p_color=>'#ED6647'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(3000000001000005)
,p_chart_id=>wwv_flow_imp.id(3000000001000004)
,p_static_id=>'s-pay-daily'
,p_seq=>10
,p_name=>unistr('\BCF4\D5D8\B8CC \B0A9\C785')
,p_data_source_type=>'SQL'
,p_data_source=>'select to_char(trunc(sysdate)-level+1,''MM-DD'') dt,20+mod(level*7,18) cnt from dual connect by level<=14 order by dt'
,p_series_type=>'bar'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'DT'
,p_color=>'#4884C4'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(3000000001000007)
,p_chart_id=>wwv_flow_imp.id(3000000001000004)
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
 p_id=>wwv_flow_imp.id(3000000001000008)
,p_chart_id=>wwv_flow_imp.id(3000000001000004)
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
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(3000000001000009)
,p_name=>unistr('\CD5C\ADFC \C2E4\C2DC\AC04 \BCF4\D5D8 \C774\BCA4\D2B8')
,p_static_id=>unistr('\CD5C\ADFC-\C2E4\C2DC\AC04-\AC70\B798-\B0B4\C5ED-ogg-\BCF5\C81C-\B370\C774\D130')
,p_title=>unistr('\CD5C\ADFC \C2E4\C2DC\AC04 \BCF4\D5D8 \C774\BCA4\D2B8')
,p_template=>wwv_flow_imp.id(141231887613368641579)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>unistr('select to_char(claim_time,''YYYY-MM-DD'') "\B0A0\C9DC",claim_no "\ACE0\AC1D\BA85",claim_type||'' / ''||claim_status "\AC70\B798\C720\D615",to_char(claimed_amount,''FM999,999,999'') "\AC70\B798\AE08\C561(\C6D0)",hospital_name "\D380\B4DC\BA85",to_char(claim_time,''HH24:MI:SS'') "\CC98\B9AC\C2DC\AC01" from ggadmin.ins2_claim order by claim_ti')
||'me desc fetch first 20 rows only'
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('\AE08\C77C \AC70\B798 \B0B4\C5ED\C774 \C5C6\C2B5\B2C8\B2E4.')
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533834779643844)
,p_query_column_id=>4
,p_column_alias=>unistr('\AC70\B798\AE08\C561(\C6D0)')
,p_column_display_sequence=>4
,p_column_heading=>unistr('\CCAD\AD6C\AE08\C561(\C6D0)')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533710651643844)
,p_query_column_id=>3
,p_column_alias=>unistr('\AC70\B798\C720\D615')
,p_column_display_sequence=>3
,p_column_heading=>unistr('\CCAD\AD6C\C720\D615/\C0C1\D0DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533690823643844)
,p_query_column_id=>2
,p_column_alias=>unistr('\ACE0\AC1D\BA85')
,p_column_display_sequence=>2
,p_column_heading=>unistr('\CCAD\AD6C\BC88\D638')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533592514643844)
,p_query_column_id=>1
,p_column_alias=>unistr('\B0A0\C9DC')
,p_column_display_sequence=>1
,p_column_heading=>unistr('\C774\BCA4\D2B8\C77C')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534016940643844)
,p_query_column_id=>6
,p_column_alias=>unistr('\CC98\B9AC\C2DC\AC01')
,p_column_display_sequence=>6
,p_column_heading=>unistr('\C811\C218\C2DC\AC01')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533989522643844)
,p_query_column_id=>5
,p_column_alias=>unistr('\D380\B4DC\BA85')
,p_column_display_sequence=>5
,p_column_heading=>unistr('\BCD1\C6D0')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(3000000001000002)
,p_name=>unistr('\BCF4\D5D8 \D575\C2EC KPI')
,p_static_id=>unistr('\D575\C2EC-kpi')
,p_title=>unistr('\BCF4\D5D8 \D575\C2EC KPI')
,p_template=>wwv_flow_imp.id(141231887613368641579)
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>unistr('select ''\BCF4\C720 \ACC4\C57D'' label,to_char(count(*)) value,''fa-file-text-o'' icon,''u-color-24'' color from ggadmin.ins2_policy where policy_status<>''\D574\C9C0'' union all select ''\ACE0\AC1D \C218'',to_char(count(*)),''fa-users'',''u-color-3'' from ggadmin.ins2_customer union all select ''\C6D4 \BCF4')
||unistr('\D5D8\B8CC'',to_char(sum(monthly_premium),''FM999,999,999'')||''\C6D0'',''fa-won'',''u-color-14'' from ggadmin.ins2_policy where policy_status in (''\C815\C0C1'',''\B0A9\C785\C720\C608'',''\C2E4\D6A8\C704\D5D8'') union all select ''\C2EC\C0AC\C911 \CCAD\AD6C'',to_char(sum(case when claim_status in (''\C2EC\C0AC\C911'',''\C870\C0AC\C911'',''\C11C\B958\BCF4\C644'') then 1 else 0 end))')
||unistr(',''fa-medkit'',''u-color-1'' from ggadmin.ins2_claim union all select ''\C2B9\C778 \BCF4\D5D8\AE08'',to_char(sum(approved_amount),''FM999,999,999'')||''\C6D0'',''fa-check-circle'',''u-color-21'' from ggadmin.ins2_claim union all select ''HIGH \B9AC\C2A4\D06C'',to_char(sum(case when risk_level=''HIGH'' a')
||unistr('nd action_status<>''\C644\B8CC'' then 1 else 0 end)),''fa-warning'',''u-color-2'' from ggadmin.ins2_risk_signal')
,p_query_num_rows=>6
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('\B370\C774\D130 \C5C6\C74C')
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533498806643843)
,p_query_column_id=>4
,p_column_alias=>'COLOR'
,p_column_display_sequence=>4
,p_column_heading=>'COLOR'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533308405643843)
,p_query_column_id=>3
,p_column_alias=>'ICON'
,p_column_display_sequence=>3
,p_column_heading=>'ICON'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533130032643843)
,p_query_column_id=>1
,p_column_alias=>'LABEL'
,p_column_display_sequence=>1
,p_column_heading=>'LABEL'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11533286730643843)
,p_query_column_id=>2
,p_column_alias=>'VALUE'
,p_column_display_sequence=>2
,p_column_heading=>'VALUE'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\ACC4\C57D\00B7\ACE0\AC1D 360')
,p_alias=>'CUSTOMERS'
,p_step_title=>unistr('\ACC4\C57D\00B7\ACE0\AC1D 360')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000006)
,p_plug_name=>unistr('\ACC4\C57D\00B7\ACE0\AC1D 360 \BAA9\B85D')
,p_static_id=>unistr('\ACE0\AC1D-\BAA9\B85D')
,p_title=>unistr('\ACC4\C57D\00B7\ACE0\AC1D 360 \BAA9\B85D')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>unistr('select p.policy_no "\ACC4\C57D\BC88\D638",c.customer_id "\ACE0\AC1DID",c.customer_name "\ACE0\AC1D\BA85",c.gender "\C131\BCC4",trunc(months_between(sysdate,c.birth_date)/12) "\B098\C774",c.region "\C9C0\C5ED",c.customer_grade "\ACE0\AC1D\B4F1\AE09",pr.product_name "\C0C1\D488\BA85",p.policy_status "\ACC4\C57D\C0C1\D0DC",p.monthly_premium "\C6D4\BCF4\D5D8\B8CC",p.cover')
||unistr('age_amount "\BCF4\C7A5\AE08\C561",p.persistency_month "\C720\C9C0\AC1C\C6D4",p.contract_date "\ACC4\C57D\C77C" from ggadmin.ins2_policy p join ggadmin.ins2_customer c on c.customer_id=p.customer_id join ggadmin.ins2_product pr on pr.product_code=p.product_code order by p.contract_date desc')
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000010000007)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000010000007
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000010000008)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300100'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\C131\BCC4":"\B098\C774":"\C9C1\C5C5":"\C5F0\B77D\CC98":"\C774\BA54\C77C":"\C8FC\C18C":"\C790\B140\C218":"\B0A9\C785\AC74\C218":"\B0A9\C785\CD1D\C561":"\BBF8\B0A9\AC74\C218":"\AC00\C785\C77C"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000010000002)
,p_plug_name=>unistr('\C131\BCC4\00B7\C5F0\B839\B300 \ACE0\AC1D \BD84\D3EC')
,p_static_id=>unistr('\C131\BCC4-\C5F0\B839\BCC4-\ACE0\AC1D-\BD84\D3EC')
,p_title=>unistr('\C131\BCC4\00B7\C5F0\B839\B300 \ACE0\AC1D \BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
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
,p_name=>unistr('\C5EC\C131')
,p_data_source_type=>'SQL'
,p_data_source=>unistr('select case when age<30 then ''20\B300'' when age<40 then ''30\B300'' when age<50 then ''40\B300'' when age<60 then ''50\B300'' else ''60\B300\C774\C0C1'' end age_group,count(*) cnt from (select gender,trunc(months_between(sysdate,birth_date)/12) age from ggadmin.ins2_customer) where gen')
||unistr('der=''\C5EC'' group by case when age<30 then ''20\B300'' when age<40 then ''30\B300'' when age<50 then ''40\B300'' when age<60 then ''50\B300'' else ''60\B300\C774\C0C1'' end')
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
,p_name=>unistr('\B0A8\C131')
,p_data_source_type=>'SQL'
,p_data_source=>unistr('select case when age<30 then ''20\B300'' when age<40 then ''30\B300'' when age<50 then ''40\B300'' when age<60 then ''50\B300'' else ''60\B300\C774\C0C1'' end age_group,count(*) cnt from (select gender,trunc(months_between(sysdate,birth_date)/12) age from ggadmin.ins2_customer) where gen')
||unistr('der=''\B0A8'' group by case when age<30 then ''20\B300'' when age<40 then ''30\B300'' when age<50 then ''40\B300'' when age<60 then ''50\B300'' else ''60\B300\C774\C0C1'' end')
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
,p_name=>unistr('\BCF4\D5D8\B8CC\00B7\B0A9\C785 \D604\D669')
,p_alias=>'TRANSACTIONS'
,p_step_title=>unistr('\BCF4\D5D8\B8CC\00B7\B0A9\C785 \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000005)
,p_plug_name=>unistr('\BCF4\D5D8\B8CC \B0A9\C785 \C0C1\C138')
,p_static_id=>unistr('\AC70\B798-\B0B4\C5ED-interactive-report')
,p_title=>unistr('\BCF4\D5D8\B8CC \B0A9\C785 \C0C1\C138')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>unistr('select payment_time "\CC98\B9AC\C2DC\AC01",payment_id "\B0A9\C785ID",policy_no "\ACC4\C57D\BC88\D638",customer_id "\ACE0\AC1DID",payment_month "\B0A9\C785\C6D4",premium_amount "\BCF4\D5D8\B8CC(\C6D0)",payment_status "\B0A9\C785\C0C1\D0DC",payment_method "\B0A9\C785\BC29\BC95",delay_days "\C5F0\CCB4\C77C\C218" from ggadmin.ins2_payment order by payment_time desc')
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000020000006)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000020000006
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000020000007)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300200'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\B0A0\C9DC":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\AC70\B798\C720\D615":"\AC70\B798\AE08\C561(\C6D0)":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"3\AC1C\C6D4\CF5C\C218":"\C5F0\CCB4\AC74\C218":"\CC98\B9AC\C2DC\AC01"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000020000002)
,p_plug_name=>unistr('\B0A9\C785 \C0C1\D0DC \BD84\D3EC')
,p_static_id=>unistr('\AC70\B798-\C720\D615\BCC4-\BD84\D3EC')
,p_title=>unistr('\B0A9\C785 \C0C1\D0DC \BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000020000003)
,p_region_id=>wwv_flow_imp.id(3000000020000002)
,p_chart_type=>'pie'
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
 p_id=>wwv_flow_imp.id(3000000020000004)
,p_chart_id=>wwv_flow_imp.id(3000000020000003)
,p_static_id=>'s-txn-type'
,p_seq=>10
,p_name=>unistr('\B0A9\C785 \AC74\C218')
,p_data_source_type=>'SQL'
,p_data_source=>'select payment_status op_name,count(*) cnt from ggadmin.ins2_payment group by payment_status order by cnt desc'
,p_series_type=>'pie'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'OP_NAME'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
end;
/
prompt --application/pages/page_00030
begin
wwv_flow_imp_page.create_page(
 p_id=>30
,p_name=>unistr('\C0AC\ACE0\00B7\BCF4\D5D8\AE08 \CCAD\AD6C')
,p_alias=>'FUND_STATUS'
,p_step_title=>unistr('\C0AC\ACE0\00B7\BCF4\D5D8\AE08 \CCAD\AD6C')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000030000005)
,p_plug_name=>unistr('\BCF4\D5D8\AE08 \CCAD\AD6C \C0C1\C138')
,p_static_id=>unistr('\C801\B9BD\AE08-\C0C1\C138-\B0B4\C5ED')
,p_title=>unistr('\BCF4\D5D8\AE08 \CCAD\AD6C \C0C1\C138')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>unistr('select claim_time "\C811\C218\C2DC\AC01",claim_no "\CCAD\AD6C\BC88\D638",policy_no "\ACC4\C57D\BC88\D638",customer_id "\ACE0\AC1DID",claim_type "\CCAD\AD6C\C720\D615",claimed_amount "\CCAD\AD6C\AE08\C561(\C6D0)",approved_amount "\C2B9\C778\AE08\C561(\C6D0)",claim_status "\CC98\B9AC\C0C1\D0DC",fraud_score "\C774\C0C1\C810\C218",hospital_name "\BCD1\C6D0",adjuster_name "\B2F4\B2F9\C2EC\C0AC\C790" from ggadmin.ins2_claim ')
||'order by claim_time desc'
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
,p_plug_name=>unistr('\CCAD\AD6C \C720\D615\BCC4 \AE08\C561')
,p_static_id=>unistr('\D380\B4DC\BCC4-\CD1D-\C801\B9BD\AE08-\CD5C\ADFC-\AE30\C900\C77C')
,p_title=>unistr('\CCAD\AD6C \C720\D615\BCC4 \AE08\C561')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
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
,p_name=>unistr('\CCAD\AD6C\AE08\C561')
,p_data_source_type=>'SQL'
,p_data_source=>'select claim_type fund_name,sum(claimed_amount) tot_amt from ggadmin.ins2_claim group by claim_type order by tot_amt desc'
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
,p_name=>unistr('\C720\C9C0\C728\00B7\D574\C9C0\C704\D5D8')
,p_alias=>'CANCELLATION'
,p_step_title=>unistr('\C720\C9C0\C728\00B7\D574\C9C0\C704\D5D8')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000040000003)
,p_plug_name=>unistr('\C2DC\AC04\B300\BCC4 \B9AC\C2A4\D06C \C2E0\D638')
,p_static_id=>unistr('\C6D4\BCC4-\D574\C57D-\CD94\C774')
,p_title=>unistr('\C2DC\AC04\B300\BCC4 \B9AC\C2A4\D06C \C2E0\D638')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
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
,p_name=>unistr('\C704\D5D8 \C2E0\D638')
,p_data_source_type=>'SQL'
,p_data_source=>'select to_char(detected_at,''MM-DD HH24'') ym,count(*) cnt from ggadmin.ins2_risk_signal group by to_char(detected_at,''MM-DD HH24'') order by ym'
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
,p_plug_name=>unistr('\ACE0\AC1D\00B7\ACC4\C57D \C704\D5D8\C2E0\D638')
,p_static_id=>unistr('\D574\C57D-\C0C1\C138-\B0B4\C5ED')
,p_title=>unistr('\ACE0\AC1D\00B7\ACC4\C57D \C704\D5D8\C2E0\D638')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>unistr('select detected_at "\D0D0\C9C0\C2DC\AC01",signal_id "\C2E0\D638ID",customer_id "\ACE0\AC1DID",policy_no "\ACC4\C57D\BC88\D638",signal_type "\C2E0\D638\C720\D615",risk_level "\C704\D5D8\B4F1\AE09",risk_score "\C704\D5D8\C810\C218",expected_loss "\C608\C0C1\C190\C2E4(\C6D0)",action_status "\C870\CE58\C0C1\D0DC",description "\B0B4\C6A9" from ggadmin.ins2_risk_signal order by detected_at des')
||'c'
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
,p_name=>unistr('\C720\C9C0\00B7\B9AC\C2A4\D06C \C694\C57D')
,p_static_id=>unistr('\D574\C57D-\D604\D669-\C694\C57D')
,p_title=>unistr('\C720\C9C0\00B7\B9AC\C2A4\D06C \C694\C57D')
,p_template=>wwv_flow_imp.id(141231887613368641579)
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>unistr('select ''\C2E4\D6A8\00B7\D574\C9C0\C704\D5D8 \ACC4\C57D'' label,to_char(sum(case when policy_status in (''\C2E4\D6A8\C704\D5D8'',''\D574\C9C0\AC80\D1A0'') then 1 else 0 end)) value,''fa-warning'' icon,''u-color-1'' color from ggadmin.ins2_policy union all select ''\BBF8\C870\CE58 \B9AC\C2A4\D06C'',to_char(sum(case when action_status not in (''\C644\B8CC'',''\C548\B0B4\C644\B8CC''')
||unistr(') then 1 else 0 end)),''fa-exclamation-triangle'',''u-color-2'' from ggadmin.ins2_risk_signal union all select ''\C608\C0C1 \C190\C2E4\C561'',to_char(sum(expected_loss),''FM999,999,999'')||''\C6D0'',''fa-won'',''u-color-3'' from ggadmin.ins2_risk_signal union all select ''\D3C9\ADE0 \C704\D5D8\C810\C218'',to_char')
||'(round(avg(risk_score),1),''FM990.0''),''fa-line-chart'',''u-color-4'' from ggadmin.ins2_risk_signal'
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
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534752588643845)
,p_query_column_id=>3
,p_column_alias=>'ICON'
,p_column_display_sequence=>3
,p_column_heading=>'ICON'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534596314643845)
,p_query_column_id=>1
,p_column_alias=>'LABEL'
,p_column_display_sequence=>1
,p_column_heading=>'LABEL'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(11534685580643845)
,p_query_column_id=>2
,p_column_alias=>'VALUE'
,p_column_display_sequence=>2
,p_column_heading=>'VALUE'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00050
begin
wwv_flow_imp_page.create_page(
 p_id=>50
,p_name=>unistr('\C0C1\D488 \D3EC\D2B8\D3F4\B9AC\C624')
,p_alias=>'PRODUCTS'
,p_step_title=>unistr('\C0C1\D488 \D3EC\D2B8\D3F4\B9AC\C624')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000050000005)
,p_plug_name=>unistr('\BCF4\D5D8 \C0C1\D488 \D3EC\D2B8\D3F4\B9AC\C624')
,p_static_id=>unistr('\BCF4\D5D8-\C0C1\D488-\BAA9\B85D')
,p_title=>unistr('\BCF4\D5D8 \C0C1\D488 \D3EC\D2B8\D3F4\B9AC\C624')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>unistr('select category "\CE74\D14C\ACE0\B9AC",product_code "\C0C1\D488\CF54\B4DC",product_name "\C0C1\D488\BA85",channel "\C8FC\B825\CC44\B110",monthly_premium "\AE30\C900\BCF4\D5D8\B8CC(\C6D0)",coverage_amount "\AE30\C900\BCF4\C7A5\AE08\C561(\C6D0)",status "\C0C1\D0DC",launch_date "\CD9C\C2DC\C77C" from ggadmin.ins2_product order by category,product_code')
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
,p_title=>unistr('\C0C1\D488 \CE74\D14C\ACE0\B9AC \BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
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
,p_name=>unistr('\C0C1\D488 \C218')
,p_data_source_type=>'SQL'
,p_data_source=>'select category,count(*) cnt from ggadmin.ins2_product group by category order by cnt desc'
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
prompt --application/pages/page_00060
begin
wwv_flow_imp_page.create_page(
 p_id=>60
,p_name=>unistr('\C790\AE08\C138\D0C1 \D750\B984 \AC10\C9C0')
,p_alias=>'AML-FLOW-DETECTION'
,p_step_title=>unistr('\C790\AE08\C138\D0C1 \D750\B984 \AC10\C9C0')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141231746302586641528)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000013)
,p_plug_name=>unistr('\CC28\D2B8 \C0AC\C6A9 SQL')
,p_static_id=>'aml-chart-used-sql'
,p_title=>unistr('\D0D0\C9C0 \C720\D615\BCC4 \C758\C2EC\AE08\C561 \00B7 \C0AC\C6A9 SQL')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--accent7'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>11
,p_plug_source=>'begin sys.htp.prn(dbms_lob.substr(ggadmin.aml_component_sql_html(nvl(:P60_GRAPH_ENGINE,''RDF''),''CHART''),32000,1)); end;'
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_display_condition_type=>'EXISTS'
,p_plug_display_when_condition=>'select 1 from dual where v(''REQUEST'') = ''SHOW_CHART_SQL'''
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000005)
,p_plug_name=>unistr('\C758\C2EC \D750\B984 \D0D0\C9C0 \ACB0\ACFC')
,p_static_id=>'aml-detection-report'
,p_title=>unistr('\C758\C2EC \D750\B984 \D0D0\C9C0 \ACB0\ACFC')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231885514208641577)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>unistr('select detection_type "\D0D0\C9C0\C720\D615",risk_score "\C704\D5D8\C810\C218",flow_path "\C790\AE08\D750\B984",suspicious_amount "\C758\C2EC\AE08\C561(\C6D0)",description "\D0D0\C9C0\C124\BA85",evidence_source "\BD84\C11D \ADFC\AC70" from ggadmin.aml_rdf_detection_v where nvl(:P60_GRAPH_ENGINE,''RDF'')=''RDF'' union all select detection_type,risk_scor')
||'e,flow_path,suspicious_amount,description,evidence_source from ggadmin.aml_pg_detection_v where :P60_GRAPH_ENGINE=''PGSQL'' order by 2 desc,4 desc'
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(3000000420000006)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_internal_uid=>3000000060000006
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(3000000420000007)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300600'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\D0D0\C9C0\C720\D615":"\C704\D5D8\C810\C218":"\C790\AE08\D750\B984":"\C758\C2EC\AE08\C561(\C6D0)":"\D0D0\C9C0\C124\BA85":"\BD84\C11D \ADFC\AC70"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000009)
,p_plug_name=>unistr('\BD84\C11D \C5D4\C9C4 \C120\D0DD')
,p_static_id=>'aml-engine-selector'
,p_title=>unistr('\C790\AE08\C138\D0C1 \D750\B984 \BD84\C11D \C5D4\C9C4')
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--accent7'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>5
,p_plug_item_display_point=>'ABOVE'
,p_location=>null
,p_plug_source=>unistr('<p style="margin:0;color:#475569">\B3D9\C77C\D55C \AC70\B798 \B370\C774\D130\B97C RDF \C758\BBF8\B9DD \B610\B294 SQL Property Graph\B85C \BD84\C11D\D569\B2C8\B2E4. \AC01 \ADF8\B798\D504 \C6B0\CE21 \C0C1\B2E8\C758 showSQL\C5D0\C11C \D574\B2F9 \CFFC\B9AC\B97C \D655\C778\D560 \C218 \C788\C2B5\B2C8\B2E4.</p>')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000008)
,p_plug_name=>unistr('\C790\AE08 \D750\B984 \AD00\ACC4 \ADF8\B798\D504')
,p_static_id=>'aml-flow-graph'
,p_title=>unistr('\C790\AE08 \D750\B984 \AD00\ACC4 \ADF8\B798\D504')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>15
,p_plug_source=>'begin if nvl(:P60_GRAPH_ENGINE,''RDF'')=''PGSQL'' then sys.htp.prn(dbms_lob.substr(ggadmin.aml_pg_graph_html(),32000,1)); else sys.htp.prn(dbms_lob.substr(ggadmin.aml_rdf_graph_html(),32000,1)); end if; end;'
,p_plug_source_type=>'NATIVE_PLSQL'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000017)
,p_plug_name=>unistr('\AD00\ACC4 \ADF8\B798\D504 \C0AC\C6A9 SQL')
,p_static_id=>'aml-graph-used-sql'
,p_title=>unistr('\C790\AE08 \D750\B984 \AD00\ACC4 \ADF8\B798\D504 \00B7 \C0AC\C6A9 SQL')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--accent7'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>16
,p_plug_source=>'begin sys.htp.prn(dbms_lob.substr(ggadmin.aml_component_sql_html(nvl(:P60_GRAPH_ENGINE,''RDF''),''GRAPH''),32000,1)); end;'
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_display_condition_type=>'EXISTS'
,p_plug_display_when_condition=>'select 1 from dual where v(''REQUEST'') = ''SHOW_GRAPH_SQL'''
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000002)
,p_plug_name=>unistr('\D0D0\C9C0 \C720\D615\BCC4 \C758\C2EC\AE08\C561')
,p_static_id=>'aml-risk-type-chart'
,p_title=>unistr('\D0D0\C9C0 \C720\D615\BCC4 \C758\C2EC\AE08\C561')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141231887613368641579)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(3000000420000003)
,p_region_id=>wwv_flow_imp.id(3000000420000002)
,p_chart_type=>'pie'
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
 p_id=>wwv_flow_imp.id(3000000420000004)
,p_chart_id=>wwv_flow_imp.id(3000000420000003)
,p_static_id=>'s-txn-type'
,p_seq=>10
,p_name=>unistr('\C758\C2EC\AE08\C561')
,p_data_source_type=>'SQL'
,p_data_source=>'select detection_type op_name,sum(suspicious_amount) cnt from (select detection_type,suspicious_amount from ggadmin.aml_rdf_detection_v where nvl(:P60_GRAPH_ENGINE,''RDF'')=''RDF'' union all select detection_type,suspicious_amount from ggadmin.aml_pg_det'
||'ection_v where :P60_GRAPH_ENGINE=''PGSQL'') group by detection_type order by cnt desc'
,p_series_type=>'pie'
,p_items_value_column_name=>'CNT'
,p_items_label_column_name=>'OP_NAME'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>true
,p_items_label_position=>'auto'
,p_items_label_display_as=>'PERCENT'
,p_threshold_display=>'onIndicator'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000000420000001)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141231900043525641592)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(3000000004000000)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141231990252742641696)
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(3000000420000011)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(3000000420000009)
,p_button_name=>'APPLY_ENGINE'
,p_static_id=>'apply-engine'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>wwv_flow_imp.id(1454856031268985)
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('\C120\D0DD \C5D4\C9C4\C73C\B85C \BD84\C11D')
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(3000000420000012)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(3000000420000002)
,p_button_name=>'SHOW_CHART_SQL'
,p_static_id=>'show-chart-sql'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--simple:t-Button--small'
,p_button_template_id=>wwv_flow_imp.id(1454856031268985)
,p_button_image_alt=>'showSQL'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:60:&SESSION.:SHOW_CHART_SQL:&DEBUG.:::#aml-chart-used-sql'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(3000000420000016)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(3000000420000008)
,p_button_name=>'SHOW_GRAPH_SQL'
,p_static_id=>'show-graph-sql'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--simple:t-Button--small'
,p_button_template_id=>wwv_flow_imp.id(1454856031268985)
,p_button_image_alt=>'showSQL'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:60:&SESSION.:SHOW_GRAPH_SQL:&DEBUG.:::#aml-graph-used-sql'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(3000000420000010)
,p_name=>'P60_GRAPH_ENGINE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(3000000420000009)
,p_item_default=>'RDF'
,p_prompt=>unistr('\BD84\C11D \BC29\C2DD')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC:Oracle RDF;RDF,Property Graph SQL (SQL/PGQ);PGSQL'
,p_cSize=>30
,p_field_template=>wwv_flow_imp.id(141244423432435647300)
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
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
,p_step_template=>wwv_flow_imp.id(141231738202050641521)
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'12'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(3000009999000001)
,p_plug_name=>unistr('DS\ADF8\B8F9 \BCF4\D5D8 \C815\BCF4\ACC4 2.0')
,p_static_id=>unistr('\BCF4\D5D8-\C815\BCF4\ACC4-\C2DC\C2A4\D15C')
,p_title=>unistr('DS\ADF8\B8F9 \BCF4\D5D8 \C815\BCF4\ACC4 2.0')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141231930259929641616)
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
,p_prompt=>unistr('\BE44\BC00\BC88\D638')
,p_placeholder=>unistr('\BE44\BC00\BC88\D638')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>40
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
,p_prompt=>unistr('\C0AC\C6A9\C790\BA85')
,p_placeholder=>unistr('\C0AC\C6A9\C790\BA85')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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


