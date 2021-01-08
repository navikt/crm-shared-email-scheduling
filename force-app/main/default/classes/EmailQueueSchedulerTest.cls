@isTest
private without sharing class EmailQueueSchedulerTest {

	@TestSetup
	static void makeData() {
		EmailQueueDataTest.makeData();
	}

	@isTest
	private static void testTestSchedule() {

		Test.StartTest();
		String CRON_EXP = '0 0 0 3 9 ? 2022';
		System.schedule( 'EmailQueueSchedulerTest', CRON_EXP, new EmailQueueScheduler() );
		Test.StopTest();

		// ! no tests, as queueable is not possible to run inside scheduled class
		// ! full tests are performed in EmailQueueJobTest
	}
}