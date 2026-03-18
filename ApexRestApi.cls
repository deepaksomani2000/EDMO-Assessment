@RestResource(urlMapping='/enrollment-scores/*')
global with sharing class EnrollmentScoreAPI {

    global class ScoreRequest {
        public String contactEmail;
        public Integer score;
        public String recommendedAction;
        public String sourceSystem;
        public Datetime scoredAt;
    }

    global class RequestWrapper {
        public List<ScoreRequest> scores;
    }

    global class ResponseItem {
        public String email;
        public Boolean success;
        public String message;
    }

    @HttpPost
    global static List<ResponseItem> ingestScores() {

        RestRequest req = RestContext.request;

        RequestWrapper wrapper = (RequestWrapper)
            JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);

        List<ResponseItem> responses = new List<ResponseItem>();

        if (wrapper == null || wrapper.scores == null) {
            return responses;
        }

        Set<String> emails = new Set<String>();

        for (ScoreRequest sr : wrapper.scores) {
            if (sr.contactEmail != null) {
                emails.add(sr.contactEmail);
            }
        }

        Map<String, Contact> contactMap = new Map<String, Contact>(
            [SELECT Id, Email FROM Contact WHERE Email IN :emails]
        );

        List<Enrollment_Score__c> recordsToInsert = new List<Enrollment_Score__c>();

        for (ScoreRequest sr : wrapper.scores) {

            ResponseItem res = new ResponseItem();
            res.email = sr.contactEmail;

            if (!contactMap.containsKey(sr.contactEmail)) {
                res.success = false;
                res.message = 'Contact not found';
            } else {

                Enrollment_Score__c rec = new Enrollment_Score__c(
                    Contact__c = contactMap.get(sr.contactEmail).Id,
                    Score__c = sr.score,
                    Recommended_Action__c = sr.recommendedAction,
                    Source_System__c = sr.sourceSystem,
                    Scored_At__c = sr.scoredAt
                );

                recordsToInsert.add(rec);

                res.success = true;
                res.message = 'Created';
            }

            responses.add(res);
        }

        if (!recordsToInsert.isEmpty()) {
            Database.insert(recordsToInsert, false);
        }

        return responses;
    }
}
