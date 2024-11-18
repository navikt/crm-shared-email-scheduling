public without sharing class EmailQueueTrigger_setTemplate {
    public static void verifyTemplateId(List<EmailQueue__c> emailQueues) {
        Set<String> templateNames = getTemplateNames(emailQueues);
        Map<String, Id> emailTemplates = getTemplates(templateNames);
        setTemplateId(emailQueues, emailTemplates);
    }

    public static Set<String> getTemplateNames(List<EmailQueue__c> emailQueues) {
        Set<String> templateNames = new Set<String>();

        for (EmailQueue__c emailQueue : emailQueues) {
            if (emailQueue.TemplateId__c == null && emailQueue.TemplateName__c != null) {
                templateNames.add(emailQueue.TemplateName__c);
            }
        }

        return templateNames;
    }

    public static Map<String, Id> getTemplates(Set<String> templateNames) {
        Map<String, Id> emailTemplateMap = new Map<String, Id>();

        if(templateNames.isEmpty()){
            return emailTemplateMap;
        }

        List<EmailTemplate> emailTemplates = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName IN :templateNames
        ];

        for (EmailTemplate emailTemplate : emailTemplates) {
            emailTemplateMap.put(emailTemplate.DeveloperName, emailTemplate.Id);
        }

        return emailTemplateMap;
    }

    public static List<EmailQueue__c> setTemplateId(List<EmailQueue__c> emailQueues, Map<String, Id> emailTemplates) {
        for (EmailQueue__c emailQueue : emailQueues) {
            String templateName = emailQueue.TemplateName__c;
            if (emailQueue.TemplateId__c == null && emailTemplates.containsKey(templateName)) {
                emailQueue.TemplateId__c = emailTemplates.get(templateName);
            }
        }

        return emailQueues;
    }
}
