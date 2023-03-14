global class ScheduleAccountUpdateCA implements Schedulable {
    global void execute(SchedulableContext ctx) {
      AccountBatchUpdateCA batch = new AccountBatchUpdateCA();
      Database.executeBatch(batch);
    }
}