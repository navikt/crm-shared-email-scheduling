@isTest
private without sharing class EmailQueueSchedulerTest {

	@TestSetup
	static void makeData() {
		EmailQueueDataTest.createData( 48, null, false );
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

	@isTest
	private static void testGetJobStatus() {

		Test.StartTest();
		List<Id> jobIds = EmailQueueScheduler.processEmailQueue( 'Queued' );
		Test.StopTest();

		System.assertEquals( 1, jobIds.size(), 'should only be one batch, and one job' );

		Integer finishedJobs = EmailQueueScheduler.getJobStatus( jobIds );

		System.assertEquals( 1, finishedJobs, 'should only be one batch, and one job which should be finished' );
	}
}