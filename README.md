# crm-platform-email-scheduling

[![Build](https://github.com/navikt/crm-platform-email-scheduling/workflows/%5BPUSH%5D%20Create%20Package/badge.svg)](https://github.com/navikt/crm-platform-email-scheduling/actions?query=workflow%3Acreate)
[![GitHub version](https://badgen.net/github/release/navikt/crm-platform-email-scheduling/stable)](https://github.com/navikt/crm-platform-email-scheduling)
[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/navikt/crm-platform-email-scheduling/blob/master/LICENSE)

An email scheduling interfaces to queue emails and be within daily email limits from Salesforce. Simple Salesforce App to view queued and sent emails, as well as failed attempts to send an email. You can also retry failed emails.

After getting access to the app using the permission set `EmailSchedulingApp_Admin`, open the `Email Scheduling` app.

## How to use

To use this framework, add the package as a dependency in `sfdx-project.json`

```json
{
    "packageDirectories": [
        {
            "path": "force-app",
            "default": true,
            "package": "my-package",
            "versionNumber": "0.1.0.NEXT",
            "dependencies": [
                {
                    "package": "crm-platform-email-scheduling",
                    "versionNumber": "1.1.0.LATEST"
                }
            ]
        }
    ],
    "namespace": "",
    "sfdcLoginUrl": "https://login.salesforce.com",
    "sourceApiVersion": "50.0",
    "packageAliases": {
        "crm-platform-email-scheduling": "0Ho2o000000fxWwCAI"
    }
}
```

Then simply create a `EmailQueue__c` record to add it to the Email Queue.

```java
EmailQueue__c email = new EmailQueue__c();
email.TemplateId__c = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'your_template' LIMIT 1].Id; // Either Id or Name must be set
email.TemplateName__c = 'DEVELOPER_NAME_OF_EMAIL_TEMPLATE'; // Either Id or Name must be set
email.TargetObjectId__c = [SELECT Id FROM Contact WHERE Email = 'email@nav.no' LIMIT 1].Id; // Any Contact, Lead or User
email.WhatId__c = [SELECT Id FROM Case LIMIT 1].Id; // Any SObject for merge fields in EmailTemplate
email.Status__c = 'Queued'; // 'Queued' is default, choose 'Instant' to skip the queue
email.Priority__c = '5'; // 1 to 5, where 5 is the highest
email.SaveAsActivity__c = true; // Save the Email as a Task after sending

insert email;
```

## Annet

For spørsmål om denne applikasjonen, bruk #arbeidsgiver-crm på Slack.
