import 'package:get/get.dart';

import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/reward_task.dart';

class RewardsController extends GetxController {
  final _account = Get.find<AccountService>();

  RxInt get bonus => _account.bonus;
  RxInt get streak => _account.checkInStreak;
  int get activeStreak => _account.activeStreak;
  RxInt get readingMinutes => _account.readingMinutesToday;
  bool get checkedInToday => _account.checkedInToday;
  List<int> get checkInRewards => AccountService.checkInRewards;

  /// The video task "plays" for a moment before paying out.
  final RxString runningTask = ''.obs;

  void checkIn() {
    final got = _account.checkIn();
    if (got > 0) toast('Checked in · day ${streak.value}', '+$got bonus');
  }

  int progress(RewardTask t) => t.repeat == TaskRepeat.once
      ? (_account.oneTimeTasks.contains(t.key) ? 1 : 0)
      : _account.taskCount(t.key);

  int max(RewardTask t) => t.repeat == TaskRepeat.once ? 1 : t.max;

  bool isDone(RewardTask t) => progress(t) >= max(t);

  Future<void> doTask(RewardTask t) async {
    if (isDone(t)) return;
    runningTask.value = t.key;
    // Stand-in for watching the ad / opening the social page.
    await Future.delayed(Duration(milliseconds: t.key == 'video' ? 1500 : 600));
    runningTask.value = '';
    final ok = t.repeat == TaskRepeat.once
        ? _account.completeOneTimeTask(t.key, bonusAmount: t.bonus, source: t.title)
        : _account.completeDailyTask(t.key, bonusAmount: t.bonus, max: t.max, source: t.title);
    if (ok) toast(t.title, '+${t.bonus} bonus');
  }

  bool milestoneClaimed(ReadingMilestone m) => _account.taskCount('read_${m.minutes}') > 0;

  void claimReading(ReadingMilestone m) {
    final ok = _account.claimReading(m.minutes, bonusAmount: m.bonus, gemAmount: m.gems);
    if (ok) {
      toast('Reading reward', '+${m.bonus} bonus${m.gems > 0 ? ' · +${m.gems} gem' : ''}');
    } else {
      toast('Keep reading', '${m.minutes - readingMinutes.value} more minutes to go');
    }
  }
}
