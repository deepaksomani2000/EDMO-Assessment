public class EnrollmentScoreHandler {

    public static void updateContactPriority(List<Enrollment_Score__c> scores) {

        // Step 1: Store latest score per Contact
        Map<Id, Enrollment_Score__c> latestScoreMap = new Map<Id, Enrollment_Score__c>();

        for (Enrollment_Score__c rec : scores) {

            if (rec.Contact__c == null || rec.Scored_At__c == null) continue;

            if (!latestScoreMap.containsKey(rec.Contact__c) ||
                rec.Scored_At__c > latestScoreMap.get(rec.Contact__c).Scored_At__c) {

                latestScoreMap.put(rec.Contact__c, rec);
            }
        }

        // Step 2: Prepare Contact updates
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Id contactId : latestScoreMap.keySet()) {

            Enrollment_Score__c scoreRec = latestScoreMap.get(contactId);
            Integer score = Integer.valueOf(scoreRec.Score__c);

            String priority;

            if (score >= 75) {
                priority = 'Hot';
            } else if (score >= 40) {
                priority = 'Warm';
            } else {
                priority = 'Cold';
            }

            contactsToUpdate.add(new Contact(
                Id = contactId,
                Enrollment_Priority__c = priority
            ));
        }

        // Step 3: Update Contacts
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}
