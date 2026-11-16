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
 
prompt APPLICATION 300 - 보험 정보계 시스템
--
-- Application Export:
--   Application:     300
--   Name:            보험 정보계 시스템
--   Date and Time:   02:47 Sunday September 6, 2026
--   Exported By:     SYS
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      8
--       Items:                    2
--       Processes:                2
--       Regions:                 21
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C'))
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'INS300')
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
,p_logo_text=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C')
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
,p_version_scn=>'69111183'
,p_print_server_type=>'INSTANCE'
,p_file_storage=>'DB'
,p_is_pwa=>'N'
,p_theme_id=>42
,p_home_url=>'f?p=&APP_ID.:1:&SESSION.'
,p_login_url=>'f?p=&APP_ID.:9999:&APP_SESSION.::&DEBUG.:::'
,p_theme_style_by_user_pref=>false
,p_global_page_id=>0
,p_navigation_list_id=>wwv_flow_imp.id(7228337573640159)
,p_navigation_list_position=>'SIDE'
,p_navigation_list_template_id=>wwv_flow_imp.id(141234192358427007136)
,p_nav_list_template_options=>'#DEFAULT#:js-defaultCollapsed:js-navCollapsed--hidden:t-TreeNav--classic'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(7228337572640159)
,p_nav_bar_list_template_id=>wwv_flow_imp.id(141234191988299007136)
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
 p_id=>wwv_flow_imp.id(7228337573640154)
,p_list_item_display_sequence=>50
,p_list_item_link_text=>unistr('\D574\C57D \BD84\C11D')
,p_static_id=>'nav-cancel'
,p_list_item_link_target=>'f?p=&APP_ID.:40:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-warning'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640157)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>unistr('\ACE0\AC1D \D604\D669')
,p_static_id=>'nav-customers'
,p_list_item_link_target=>'f?p=&APP_ID.:10:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-users'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640158)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'nav-dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-home'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640155)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>unistr('\C801\B9BD\AE08/\D380\B4DC \D604\D669')
,p_static_id=>'nav-fund'
,p_list_item_link_target=>'f?p=&APP_ID.:30:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-bar-chart'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640153)
,p_list_item_display_sequence=>60
,p_list_item_link_text=>unistr('\C0C1\D488 \D604\D669')
,p_static_id=>'nav-products'
,p_list_item_link_target=>'f?p=&APP_ID.:50:&APP_SESSION.::&DEBUG.::'
,p_list_item_icon=>'fa-th-large'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(7228337573640156)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>unistr('\AC70\B798/\B0A9\C785 \D604\D669')
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
 p_id=>wwv_flow_imp.id(7228337571640159)
,p_name=>'Breadcrumb'
,p_static_id=>'breadcrumb300'
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640154)
,p_short_name=>unistr('\D574\C57D \BD84\C11D')
,p_static_id=>'bc-cancel'
,p_link=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
,p_page_id=>40
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640157)
,p_short_name=>unistr('\ACE0\AC1D \D604\D669')
,p_static_id=>'bc-customers'
,p_link=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
,p_page_id=>10
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640158)
,p_short_name=>unistr('\B300\C2DC\BCF4\B4DC')
,p_static_id=>'bc-dashboard'
,p_link=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_page_id=>1
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640155)
,p_short_name=>unistr('\C801\B9BD\AE08/\D380\B4DC \D604\D669')
,p_static_id=>'bc-fund'
,p_link=>'f?p=&APP_ID.:30:&SESSION.::&DEBUG.:::'
,p_page_id=>30
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640153)
,p_short_name=>unistr('\C0C1\D488 \D604\D669')
,p_static_id=>'bc-products'
,p_link=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:::'
,p_page_id=>50
);
wwv_flow_imp_shared.create_menu_option(
 p_id=>wwv_flow_imp.id(7228337571640156)
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
,p_default_page_template=>wwv_flow_imp.id(141233955725549006988)
,p_default_dialog_template=>wwv_flow_imp.id(141233954226114006986)
,p_error_template=>wwv_flow_imp.id(141233947625013006981)
,p_printer_friendly_template=>wwv_flow_imp.id(141233955725549006988)
,p_login_template=>wwv_flow_imp.id(141233947625013006981)
,p_default_button_template=>wwv_flow_imp.id(141234197996647007153)
,p_default_region_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_chart_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_form_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_reportr_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_wizard_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_menur_template=>wwv_flow_imp.id(141234109466488007052)
,p_default_listr_template=>wwv_flow_imp.id(141234097036331007039)
,p_default_irr_template=>wwv_flow_imp.id(141234094937171007037)
,p_default_report_template=>wwv_flow_imp.id(141234156560532007094)
,p_default_label_template=>wwv_flow_imp.id(141234197200495007149)
,p_default_menu_template=>wwv_flow_imp.id(141234199675705007156)
,p_default_list_template=>wwv_flow_imp.id(141234185345995007128)
,p_default_top_nav_list_temp=>wwv_flow_imp.id(141234194155284007140)
,p_default_side_nav_list_temp=>wwv_flow_imp.id(141234192358427007136)
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>wwv_flow_imp.id(141234114635950007055)
,p_default_dialogr_template=>wwv_flow_imp.id(141233964465888007007)
,p_default_option_label=>wwv_flow_imp.id(141234197200495007149)
,p_default_required_label=>wwv_flow_imp.id(141234196717510007148)
,p_default_navbar_list_template=>wwv_flow_imp.id(141234191988299007136)
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
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
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
,p_alias=>'DASHBOARD'
,p_step_title=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C - \B300\C2DC\BCF4\B4DC')
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
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'06'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337574640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337574640156)
,p_plug_name=>unistr('\C77C\BCC4 \AC70\B798 \CD94\C774 (\CD5C\ADFC 30\C77C)')
,p_static_id=>unistr('\C77C\BCC4-\AC70\B798-\CD94\C774-\CD5C\ADFC-30\C77C')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
,p_plug_query_no_data_found=>unistr('\B370\C774\D130 \C5C6\C74C')
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337574640155)
,p_region_id=>wwv_flow_imp.id(7228337574640156)
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
 p_id=>wwv_flow_imp.id(7228337574640153)
,p_chart_id=>wwv_flow_imp.id(7228337574640155)
,p_static_id=>'s-cancel-daily'
,p_seq=>20
,p_name=>unistr('\D574\C57D')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DT, NVL(CNT,0) CNT',
'FROM V_INS_TXN_DAILY',
'WHERE DT >= TO_CHAR(SYSDATE-30,''YYYYMMDD'')',
'AND OP_GUBUN = ''5''',
'ORDER BY DT'))
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
 p_id=>wwv_flow_imp.id(7228337574640154)
,p_chart_id=>wwv_flow_imp.id(7228337574640155)
,p_static_id=>'s-pay-daily'
,p_seq=>10
,p_name=>unistr('\C815\AE30\B0A9\C785')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DT, NVL(CNT,0) CNT',
'FROM V_INS_TXN_DAILY',
'WHERE DT >= TO_CHAR(SYSDATE-30,''YYYYMMDD'')',
'AND OP_GUBUN = ''1''',
'ORDER BY DT'))
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
 p_id=>wwv_flow_imp.id(7228337574640152)
,p_chart_id=>wwv_flow_imp.id(7228337574640155)
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
 p_id=>wwv_flow_imp.id(7228337574640151)
,p_chart_id=>wwv_flow_imp.id(7228337574640155)
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
 p_id=>wwv_flow_imp.id(7228337574640150)
,p_name=>unistr('\CD5C\ADFC \C2E4\C2DC\AC04 \AC70\B798 \B0B4\C5ED (OGG \BCF5\C81C \B370\C774\D130)')
,p_static_id=>unistr('\CD5C\ADFC-\C2E4\C2DC\AC04-\AC70\B798-\B0B4\C5ED-ogg-\BCF5\C81C-\B370\C774\D130')
,p_template=>wwv_flow_imp.id(141234097036331007039)
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  t.DT AS "\B0A0\C9DC",'),
unistr('  t.CUST_NM AS "\ACE0\AC1D\BA85",'),
unistr('  t.OP_NAME AS "\AC70\B798\C720\D615",'),
unistr('  TO_CHAR(t.TOT_AMT,''FM999,999,999'') AS "\AC70\B798\AE08\C561(\C6D0)",'),
unistr('  t.FUND_NAME AS "\D380\B4DC\BA85",'),
unistr('  t.CALL_DT_TS AS "\CC98\B9AC\C2DC\AC01"'),
'FROM V_INS_TXN t',
'WHERE t.DT = TO_CHAR(SYSDATE,''YYYYMMDD'')',
'ORDER BY t.CALL_DT_TS DESC NULLS LAST',
'FETCH FIRST 20 ROWS ONLY'))
,p_query_num_rows=>20
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('\AE08\C77C \AC70\B798 \B0B4\C5ED\C774 \C5C6\C2B5\B2C8\B2E4.')
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305497204003685)
,p_query_column_id=>4
,p_column_alias=>unistr('\AC70\B798\AE08\C561(\C6D0)')
,p_column_display_sequence=>4
,p_column_heading=>unistr('\AC70\B798\AE08\C561(\C6D0)')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305373076003685)
,p_query_column_id=>3
,p_column_alias=>unistr('\AC70\B798\C720\D615')
,p_column_display_sequence=>3
,p_column_heading=>unistr('\AC70\B798\C720\D615')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305353248003685)
,p_query_column_id=>2
,p_column_alias=>unistr('\ACE0\AC1D\BA85')
,p_column_display_sequence=>2
,p_column_heading=>unistr('\ACE0\AC1D\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305254939003685)
,p_query_column_id=>1
,p_column_alias=>unistr('\B0A0\C9DC')
,p_column_display_sequence=>1
,p_column_heading=>unistr('\B0A0\C9DC')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305679365003685)
,p_query_column_id=>6
,p_column_alias=>unistr('\CC98\B9AC\C2DC\AC01')
,p_column_display_sequence=>6
,p_column_heading=>unistr('\CC98\B9AC\C2DC\AC01')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305651947003685)
,p_query_column_id=>5
,p_column_alias=>unistr('\D380\B4DC\BA85')
,p_column_display_sequence=>5
,p_column_heading=>unistr('\D380\B4DC\BA85')
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(7228337574640157)
,p_name=>unistr('\D575\C2EC KPI')
,p_static_id=>unistr('\D575\C2EC-kpi')
,p_template=>wwv_flow_imp.id(141234097036331007039)
,p_display_sequence=>10
,p_region_css_classes=>'codex-kpi-cards'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader:t-Region--scrollBody'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  ''\CD1D \ACE0\AC1D \C218'' LABEL,'),
'  TO_CHAR(TOTAL_CUST,''FM999,999'') VALUE,',
'  ''fa-users'' ICON,',
'  ''u-color-24'' COLOR',
'FROM V_INS_KPI',
'UNION ALL',
unistr('SELECT ''\AE08\C77C \AC70\B798 \AC74\C218'', TO_CHAR(TODAY_TXN,''FM999,999''), ''fa-exchange'', ''u-color-3'' FROM V_INS_KPI'),
'UNION ALL',
unistr('SELECT ''\AE08\C77C \B0A9\C785\C561(\C6D0)'', TO_CHAR(TODAY_PMT_AMT,''FM999,999,999,999''), ''fa-won'', ''u-color-14'' FROM V_INS_KPI'),
'UNION ALL',
unistr('SELECT ''\AE08\C77C \D574\C57D \AC74\C218'', TO_CHAR(TODAY_CANCEL,''FM999,999''), ''fa-warning'', ''u-color-1'' FROM V_INS_KPI'),
'UNION ALL',
unistr('SELECT ''\CD1D \D574\C57D \AC74\C218(\B204\C801)'', TO_CHAR(TOTAL_CANCEL,''FM999,999''), ''fa-times-circle'', ''u-color-2'' FROM V_INS_KPI'),
'UNION ALL',
unistr('SELECT ''\CD1D \C801\B9BD\AE08(\C6D0)'', TO_CHAR(TOTAL_RESERVES,''FM999,999,999,999''), ''fa-piggy-bank'', ''u-color-21'' FROM V_INS_KPI')))
,p_query_num_rows=>6
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('\B370\C774\D130 \C5C6\C74C')
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1305161231003684)
,p_query_column_id=>4
,p_column_alias=>'COLOR'
,p_column_display_sequence=>4
,p_column_heading=>'COLOR'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1304970830003684)
,p_query_column_id=>3
,p_column_alias=>'ICON'
,p_column_display_sequence=>3
,p_column_heading=>'ICON'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1304792457003684)
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
 p_id=>wwv_flow_imp.id(1304949155003684)
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
prompt --application/pages/page_00010
begin
wwv_flow_imp_page.create_page(
 p_id=>10
,p_name=>unistr('\ACE0\AC1D \D604\D669')
,p_alias=>'CUSTOMERS'
,p_step_title=>unistr('\ACE0\AC1D \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337565640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337565640153)
,p_plug_name=>unistr('\ACE0\AC1D \BAA9\B85D')
,p_static_id=>unistr('\ACE0\AC1D-\BAA9\B85D')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141234094937171007037)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  CUST_ID "\ACE0\AC1DID",'),
unistr('  CUST_NM "\ACE0\AC1D\BA85",'),
unistr('  GENDER "\C131\BCC4",'),
unistr('  AGE "\B098\C774",'),
unistr('  JOB "\C9C1\C5C5",'),
unistr('  HP_NO "\C5F0\B77D\CC98",'),
unistr('  EMAIL "\C774\BA54\C77C",'),
unistr('  JUSO "\C8FC\C18C",'),
unistr('  CHILD "\C790\B140\C218",'),
unistr('  DEPOSIT_CNT "\B0A9\C785\AC74\C218",'),
unistr('  TO_CHAR(DEPOSIT_AMT,''FM999,999,999'') "\B0A9\C785\CD1D\C561",'),
unistr('  NON_DEPOSIT_CNT "\BBF8\B0A9\AC74\C218",'),
unistr('  CREATED "\AC00\C785\C77C"'),
'FROM V_INS_CUST',
'ORDER BY CUST_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(7228337565640152)
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
 p_id=>wwv_flow_imp.id(7228337565640151)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300100'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\C131\BCC4":"\B098\C774":"\C9C1\C5C5":"\C5F0\B77D\CC98":"\C774\BA54\C77C":"\C8FC\C18C":"\C790\B140\C218":"\B0A9\C785\AC74\C218":"\B0A9\C785\CD1D\C561":"\BBF8\B0A9\AC74\C218":"\AC00\C785\C77C"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337565640157)
,p_plug_name=>unistr('\C131\BCC4/\C5F0\B839\BCC4 \ACE0\AC1D \BD84\D3EC')
,p_static_id=>unistr('\C131\BCC4-\C5F0\B839\BCC4-\ACE0\AC1D-\BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337565640156)
,p_region_id=>wwv_flow_imp.id(7228337565640157)
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
 p_id=>wwv_flow_imp.id(7228337565640154)
,p_chart_id=>wwv_flow_imp.id(7228337565640156)
,p_static_id=>'s-female-age'
,p_seq=>20
,p_name=>unistr('\C5EC\C131')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  CASE WHEN AGE < 30 THEN ''20\B300'''),
unistr('       WHEN AGE < 40 THEN ''30\B300'''),
unistr('       WHEN AGE < 50 THEN ''40\B300'''),
unistr('       WHEN AGE < 60 THEN ''50\B300'''),
unistr('       ELSE ''60\B300\C774\C0C1'' END AS AGE_GROUP,'),
'  COUNT(*) CNT',
'FROM SOE.CUST_INFO',
'WHERE GENDER = ''F''',
'GROUP BY',
unistr('  CASE WHEN AGE < 30 THEN ''20\B300'''),
unistr('       WHEN AGE < 40 THEN ''30\B300'''),
unistr('       WHEN AGE < 50 THEN ''40\B300'''),
unistr('       WHEN AGE < 60 THEN ''50\B300'''),
unistr('       ELSE ''60\B300\C774\C0C1'' END'),
'ORDER BY AGE_GROUP'))
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
 p_id=>wwv_flow_imp.id(7228337565640155)
,p_chart_id=>wwv_flow_imp.id(7228337565640156)
,p_static_id=>'s-male-age'
,p_seq=>10
,p_name=>unistr('\B0A8\C131')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  CASE WHEN AGE < 30 THEN ''20\B300'''),
unistr('       WHEN AGE < 40 THEN ''30\B300'''),
unistr('       WHEN AGE < 50 THEN ''40\B300'''),
unistr('       WHEN AGE < 60 THEN ''50\B300'''),
unistr('       ELSE ''60\B300\C774\C0C1'' END AS AGE_GROUP,'),
'  COUNT(*) CNT',
'FROM SOE.CUST_INFO',
'WHERE GENDER = ''M''',
'GROUP BY',
unistr('  CASE WHEN AGE < 30 THEN ''20\B300'''),
unistr('       WHEN AGE < 40 THEN ''30\B300'''),
unistr('       WHEN AGE < 50 THEN ''40\B300'''),
unistr('       WHEN AGE < 60 THEN ''50\B300'''),
unistr('       ELSE ''60\B300\C774\C0C1'' END'),
'ORDER BY AGE_GROUP'))
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
 p_id=>wwv_flow_imp.id(7228337565640151)
,p_chart_id=>wwv_flow_imp.id(7228337565640156)
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
 p_id=>wwv_flow_imp.id(7228337565640150)
,p_chart_id=>wwv_flow_imp.id(7228337565640156)
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
,p_name=>unistr('\AC70\B798/\B0A9\C785 \D604\D669')
,p_alias=>'TRANSACTIONS'
,p_step_title=>unistr('\AC70\B798/\B0A9\C785 \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337555640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337555640154)
,p_plug_name=>unistr('\AC70\B798 \B0B4\C5ED (Interactive Report)')
,p_static_id=>unistr('\AC70\B798-\B0B4\C5ED-interactive-report')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141234094937171007037)
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
unistr('  DT "\B0A0\C9DC",'),
unistr('  CUST_ID "\ACE0\AC1DID",'),
unistr('  CUST_NM "\ACE0\AC1D\BA85",'),
unistr('  OP_NAME "\AC70\B798\C720\D615",'),
unistr('  TO_CHAR(TOT_AMT,''FM999,999,999,999'') "\AC70\B798\AE08\C561(\C6D0)",'),
unistr('  FUND_CODE "\D380\B4DC\CF54\B4DC",'),
unistr('  FUND_NAME "\D380\B4DC\BA85",'),
unistr('  CALL_CNT_3M "3\AC1C\C6D4\CF5C\C218",'),
unistr('  LATE_PMT_CNT "\C5F0\CCB4\AC74\C218",'),
unistr('  CALL_DT_TS "\CC98\B9AC\C2DC\AC01"'),
'FROM V_INS_TXN',
'ORDER BY CALL_DT_TS DESC NULLS LAST, DT DESC'))
,p_plug_source_type=>'NATIVE_IR'
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(7228337555640153)
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
 p_id=>wwv_flow_imp.id(7228337555640152)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300200'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\B0A0\C9DC":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\AC70\B798\C720\D615":"\AC70\B798\AE08\C561(\C6D0)":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"3\AC1C\C6D4\CF5C\C218":"\C5F0\CCB4\AC74\C218":"\CC98\B9AC\C2DC\AC01"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337555640157)
,p_plug_name=>unistr('\AC70\B798 \C720\D615\BCC4 \BD84\D3EC')
,p_static_id=>unistr('\AC70\B798-\C720\D615\BCC4-\BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337555640156)
,p_region_id=>wwv_flow_imp.id(7228337555640157)
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
 p_id=>wwv_flow_imp.id(7228337555640155)
,p_chart_id=>wwv_flow_imp.id(7228337555640156)
,p_static_id=>'s-txn-type'
,p_seq=>10
,p_name=>unistr('\AC70\B798 \C720\D615\BCC4 \AC74\C218')
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT o.OP_NAME, COUNT(*) CNT',
'FROM SOE.CUST_GEN_AMT t',
'JOIN SOE.OPM o ON t.OP_GUBUN = o.OP_GUBUN',
'GROUP BY o.OP_NAME',
'ORDER BY CNT DESC'))
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
,p_name=>unistr('\C801\B9BD\AE08/\D380\B4DC \D604\D669')
,p_alias=>'FUND_STATUS'
,p_step_title=>unistr('\C801\B9BD\AE08/\D380\B4DC \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337545640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337545640154)
,p_plug_name=>unistr('\C801\B9BD\AE08 \C0C1\C138 \B0B4\C5ED')
,p_static_id=>unistr('\C801\B9BD\AE08-\C0C1\C138-\B0B4\C5ED')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141234094937171007037)
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
 p_id=>wwv_flow_imp.id(7228337545640153)
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
 p_id=>wwv_flow_imp.id(7228337545640150)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300300'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\AE30\C900\C77C":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"\C88C\C218":"\AE30\C900\AC00":"\CD1D\C88C\C218":"\C801\B9BD\AE08(\C6D0)"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337545640157)
,p_plug_name=>unistr('\D380\B4DC\BCC4 \CD1D \C801\B9BD\AE08 (\CD5C\ADFC \AE30\C900\C77C)')
,p_static_id=>unistr('\D380\B4DC\BCC4-\CD1D-\C801\B9BD\AE08-\CD5C\ADFC-\AE30\C900\C77C')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337545640156)
,p_region_id=>wwv_flow_imp.id(7228337545640157)
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
 p_id=>wwv_flow_imp.id(7228337545640155)
,p_chart_id=>wwv_flow_imp.id(7228337545640156)
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
 p_id=>wwv_flow_imp.id(7228337545640152)
,p_chart_id=>wwv_flow_imp.id(7228337545640156)
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
 p_id=>wwv_flow_imp.id(7228337545640151)
,p_chart_id=>wwv_flow_imp.id(7228337545640156)
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
,p_name=>unistr('\D574\C57D \BD84\C11D')
,p_alias=>'CANCELLATION'
,p_step_title=>unistr('\D574\C57D \BD84\C11D')
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
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337535640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337535640156)
,p_plug_name=>unistr('\C6D4\BCC4 \D574\C57D \CD94\C774')
,p_static_id=>unistr('\C6D4\BCC4-\D574\C57D-\CD94\C774')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>20
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337535640155)
,p_region_id=>wwv_flow_imp.id(7228337535640156)
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
 p_id=>wwv_flow_imp.id(7228337535640154)
,p_chart_id=>wwv_flow_imp.id(7228337535640155)
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
 p_id=>wwv_flow_imp.id(7228337535640151)
,p_chart_id=>wwv_flow_imp.id(7228337535640155)
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
 p_id=>wwv_flow_imp.id(7228337535640150)
,p_chart_id=>wwv_flow_imp.id(7228337535640155)
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
 p_id=>wwv_flow_imp.id(7228337535640153)
,p_plug_name=>unistr('\D574\C57D \C0C1\C138 \B0B4\C5ED')
,p_static_id=>unistr('\D574\C57D-\C0C1\C138-\B0B4\C5ED')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141234094937171007037)
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
 p_id=>wwv_flow_imp.id(7228337535640152)
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
 p_id=>wwv_flow_imp.id(7228337535640149)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300400'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\B0A0\C9DC":"\ACE0\AC1DID":"\ACE0\AC1D\BA85":"\AC70\B798\C720\D615":"\D574\C57D\AE08\C561(\C6D0)":"\D380\B4DC\CF54\B4DC":"\D380\B4DC\BA85":"\CF5C\D69F\C218(3\AC1C\C6D4)":"\C5F0\CCB4\AC74\C218":"\C0C1\B2F4\B0B4\C6A9"')
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(7228337535640157)
,p_name=>unistr('\D574\C57D \D604\D669 \C694\C57D')
,p_static_id=>unistr('\D574\C57D-\D604\D669-\C694\C57D')
,p_template=>wwv_flow_imp.id(141234097036331007039)
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
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1306509263003686)
,p_query_column_id=>4
,p_column_alias=>'COLOR'
,p_column_display_sequence=>4
,p_column_heading=>'COLOR'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1306415013003686)
,p_query_column_id=>3
,p_column_alias=>'ICON'
,p_column_display_sequence=>3
,p_column_heading=>'ICON'
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(1306258739003686)
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
 p_id=>wwv_flow_imp.id(1306348005003686)
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
,p_name=>unistr('\C0C1\D488 \D604\D669')
,p_alias=>'PRODUCTS'
,p_step_title=>unistr('\BCF4\D5D8 \C0C1\D488 \D604\D669')
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141233955725549006988)
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337525640158)
,p_plug_name=>'Breadcrumb'
,p_static_id=>'breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_plug_template=>wwv_flow_imp.id(141234109466488007052)
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(7228337571640159)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>wwv_flow_imp.id(141234199675705007156)
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337525640154)
,p_plug_name=>unistr('\BCF4\D5D8 \C0C1\D488 \BAA9\B85D')
,p_static_id=>unistr('\BCF4\D5D8-\C0C1\D488-\BAA9\B85D')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>wwv_flow_imp.id(141234094937171007037)
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
 p_id=>wwv_flow_imp.id(7228337525640153)
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
 p_id=>wwv_flow_imp.id(7228337525640152)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'300500'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('"\CE74\D14C\ACE0\B9AC":"\C0C1\D488\CF54\B4DC":"\C0C1\D488\BA85":"\C0C1\D488\C124\BA85":"\C720\D615":"\CD9C\C2DC\C77C"')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(7228337525640157)
,p_plug_name=>unistr('\C0C1\D488 \CE74\D14C\ACE0\B9AC \BD84\D3EC')
,p_static_id=>unistr('\C0C1\D488-\CE74\D14C\ACE0\B9AC-\BD84\D3EC')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_escape_on_http_output=>'Y'
,p_plug_template=>wwv_flow_imp.id(141234097036331007039)
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(7228337525640156)
,p_region_id=>wwv_flow_imp.id(7228337525640157)
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
 p_id=>wwv_flow_imp.id(7228337525640155)
,p_chart_id=>wwv_flow_imp.id(7228337525640156)
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
,p_step_title=>unistr('\BCF4\D5D8 \C815\BCF4\ACC4 \C2DC\C2A4\D15C')
,p_warn_on_unsaved_changes=>'N'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>wwv_flow_imp.id(141233947625013006981)
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
,p_plug_template=>wwv_flow_imp.id(141234139682892007076)
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
,p_button_template_id=>wwv_flow_imp.id(141234197996647007153)
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
,p_prompt=>unistr('\BE44\BC00\BC88\D638')
,p_placeholder=>unistr('\BE44\BC00\BC88\D638')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>40
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
,p_prompt=>unistr('\C0AC\C6A9\C790\BA85')
,p_placeholder=>unistr('\C0AC\C6A9\C790\BA85')
,p_source_type=>'ALWAYS_NULL'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
'INSERT INTO ggadmin.auth_debug_log(ts,p_user,p_pass,is_valid)',
'VALUES(SYSDATE,:P9999_USERNAME,''len=''||NVL(TO_CHAR(LENGTH(:P9999_PASSWORD)),''NULL''),''BEFORE'');',
'COMMIT;',
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
