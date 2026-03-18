
@isTest
public class EnrollmentScoreHandlerTest {

    @isTest
    static void testPriorityUpdate() {

        // Step 1: Create Contact
        Contact c = new Contact(
            LastName = 'Test',
            Email = 'test@example.com'
        );
        insert c;

        // Step 2: Create multiple scores (latest should win)
        List<Enrollment_Score__c> scores = new List<Enrollment_Score__c>{
            new Enrollment_Score__c(
                Contact__c = c.Id,
                Score__c = 30,
                Scored_At__c = System.now()
            ),
            new Enrollment_Score__c(
                Contact__c = c.Id,
                Score__c = 80,
                Scored_At__c = System.now().addMinutes(1)
            )
        };

        insert scores;

        // Step 3: Verify Contact updated
        Contact updated = [
            SELECT Enrollment_Priority__c
            FROM Contact
            WHERE Id = :c.Id
        ];

        System.assertEquals('Hot', updated.Enrollment_Priority__c);
    }
}
