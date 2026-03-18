@isTest
public class EnrollmentScoreAPITest {

    @isTest
    static void testAPI_PositiveAndNegative() {

        // Step 1: Create Contact
        Contact c = new Contact(
            LastName = 'Doe',
            Email = 'jane.doe@example.com'
        );
        insert c;

        // Step 2: Prepare request body
        String body = JSON.serialize(new Map<String, Object>{
            'scores' => new List<Object>{
                new Map<String, Object>{
                    'contactEmail' => 'jane.doe@example.com',
                    'score' => 85,
                    'recommendedAction' => 'Schedule Call',
                    'sourceSystem' => 'EDMO',
                    'scoredAt' => System.now()
                },
                new Map<String, Object>{
                    'contactEmail' => 'notfound@example.com',
                    'score' => 40,
                    'recommendedAction' => 'Send Info Pack',
                    'sourceSystem' => 'EDMO',
                    'scoredAt' => System.now()
                }
            }
        });

        // Step 3: Mock REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/enrollment-scores/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Step 4: Call API
        List<EnrollmentScoreAPI.ResponseItem> res =
            EnrollmentScoreAPI.ingestScores();

        // Step 5: Assertions (SAFE way - no index dependency)
        System.assertEquals(2, res.size(), 'Response size should be 2');

        Boolean successFound = false;
        Boolean failureFound = false;

        for (EnrollmentScoreAPI.ResponseItem r : res) {
            if (r.email == 'jane.doe@example.com' && r.success) {
                successFound = true;
            }
            if (r.email == 'notfound@example.com' && !r.success) {
                failureFound = true;
            }
        }

        System.assert(successFound, 'Valid email should succeed');
        System.assert(failureFound, 'Invalid email should fail');
    }


    @isTest
    static void testAPI_Bulk() {

        // Step 1: Create multiple Contacts
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                LastName = 'User' + i,
                Email = 'user' + i + '@test.com'
            ));
        }
        insert contacts;

        // Step 2: Prepare bulk request
        List<Object> scoreList = new List<Object>();

        for (Integer i = 0; i < 5; i++) {
            scoreList.add(new Map<String, Object>{
                'contactEmail' => contacts[i].Email,
                'score' => 50,
                'recommendedAction' => 'Assign Counselor',
                'sourceSystem' => 'EDMO',
                'scoredAt' => System.now()
            });
        }

        String body = JSON.serialize(
            new Map<String, Object>{ 'scores' => scoreList }
        );

        // Step 3: Mock request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/enrollment-scores/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Step 4: Call API
        List<EnrollmentScoreAPI.ResponseItem> res =
            EnrollmentScoreAPI.ingestScores();

        // Step 5: Assertions
        System.assertEquals(5, res.size(), 'Should process 5 records');

        for (EnrollmentScoreAPI.ResponseItem r : res) {
            System.assert(r.success, 'All bulk records should succeed');
        }
    }
}
