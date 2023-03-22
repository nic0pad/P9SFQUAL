/**
 * Shedule Class to run the batch AccountBatchUpdateCA
 * Update CA of all accounts
 * 
 * @author Nicolas Padiou
 */
global class ScheduleAccountUpdateCA implements Schedulable {
    global void execute(SchedulableContext ctx) {
      AccountBatchUpdateCA batch = new AccountBatchUpdateCA();
      Database.executeBatch(batch);
    }
}