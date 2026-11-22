#!/bin/python3
## Copyright (c) 2021, Oracle and/or its affiliates.

##
##  deployment-set-password.py
##  set password
##

import os
import sys
import json
import subprocess
import time
import urllib3
import urllib.request
import logging
import ssl
import requests
import psutil

default_ggschema     = 'ggadmin'
listen_on            = 'OGG_LISTEN_ON' in os.environ and os.environ['OGG_LISTEN_ON'] or '0.0.0.0'
service_address      = '127.0.0.1'
service_ports        = {
    'ServiceManager':  9011,
    'adminsrvr':       9012,
    'distsrvr':        9013,
    'recvsrvr':        9014,
    'pmsrvr':          9015
}
requests_session     = None
secure_requests_session     = None
rest_call_headers    = {
    'ContentType':    'application/json',
    'Accept':         'application/json'
}

def get_admin_credentials():
    """Returns the administrator username and password for the OGG administrator"""
    return os.environ['OGG_ADMIN'], os.environ['OGG_ADMIN_PWD']

def get_digest_authentication():
    """Retrieve an authentication method for making a request"""
    userName, credential = get_admin_credentials()
    #print("old_password: "+credential)
    return requests.auth.HTTPDigestAuth(userName, credential)

def get_requests_session():
    """Create a session that retries REST API calls that fail"""
    global requests_session
    if not requests_session:
        retry_strategy = requests.packages.urllib3.util.retry.Retry(
            total=5,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            method_whitelist=["GET", "PUT", "DELETE", "POST", "PATCH"]
        )
        adapter = requests.adapters.HTTPAdapter(max_retries=retry_strategy)
        requests_session = requests.Session()
        requests_session.mount("https://", adapter)
        requests_session.mount("http://",  adapter)
    return requests_session


def get_secure_requests_session():
    """Create a session that retries REST API calls that fail"""
    global secure_requests_session
    if not secure_requests_session:
        retry_strategy = requests.packages.urllib3.util.retry.Retry(
            total=5,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            method_whitelist=["GET", "PUT", "DELETE", "POST", "PATCH"]
        )
        adapter = requests.adapters.HTTPAdapter(max_retries=retry_strategy)
        secure_requests_session = requests.Session()
        secure_requests_session.mount("https://", adapter)
        secure_requests_session.mount("http://",  adapter)
    return secure_requests_session

def change_pwd_deployment(secure, new_password):
    if secure:
        url = 'https://'
    else:
        url = 'http://'
    url = url + service_address + ':' + str(service_ports['ServiceManager']) + '/services/v2/authorizations/Security/' + os.environ['OGG_ADMIN']
    body = {
        'credential': new_password
    }
    #print("patch: "+url)
    if secure:
        response = get_secure_requests_session().patch(url, verify=False, headers=rest_call_headers, auth=get_digest_authentication(), json=body)
    else:
        response = get_requests_session().patch(url, headers=rest_call_headers, auth=get_digest_authentication(), json=body)
    response.raise_for_status()
    if response.status_code == 200:
        response_json = response.json()
        if 'response' in response_json:
            return response_json['response']
    return None

def main():
    """Application entry point"""
    urllib3.disable_warnings()

    secure = os.getenv("OGG_SECURE_DEPLOYMENT", 'False').lower() in ('true', '1', 't');
    print("secure: "+str(secure))
    new_password = sys.argv[1]
    print("new_password: "+new_password)

    try:
        
        change_pwd_deployment(secure, new_password)
        print("Successfully changed the password.");
    except requests.exceptions.HTTPError as err:
        print("Failed to change the password.")
        print(err)
        status_code = err.response.status_code
        if status_code == 400:
            #400: Bad request
            print("The provided password may not meet the requirements.")
        elif status_code == 401:
            #401: Unauthorized
            print("The password may have already been changed. In such case, you need to use GGMA Console to change the password.")
        return 1
    return 0


sys.exit(main())
