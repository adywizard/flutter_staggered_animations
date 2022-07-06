import 'package:flutter/widgets.dart';
import 'animation_configuration.dart';
import 'animation_executor.dart';

class AnimationConfigurator extends StatelessWidget {
  final Duration? duration;
  final Duration? delay;
  final Widget Function(Animation<double>) animatedChildBuilder;

  const AnimationConfigurator({
    Key? key,
    this.duration,
    this.delay,
    required this.animatedChildBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationConfiguration = AnimationConfiguration.of(context);

    if (animationConfiguration == null) {
      throw FlutterError.fromParts(
        <DiagnosticsNode>[
          ErrorSummary('Animation not wrapped in an AnimationConfiguration.'),
          ErrorDescription('This error happens if you use an Animation that is not wrapped in an '
              'AnimationConfiguration.'),
          ErrorHint('The solution is to wrap your Animation(s) with an AnimationConfiguration. '
              'Reminder: an AnimationConfiguration provides the configuration '
              'used as a base for every children Animation. Configuration made in AnimationConfiguration '
              'can be overridden in Animation children if needed.'),
        ],
      );
    }

    final position = animationConfiguration.position;
    final dur = duration ?? animationConfiguration.duration;
    final dely = delay ?? animationConfiguration.delay;
    final columnCount = animationConfiguration.columnCount;

    return AnimationExecutor(
      duration: dur,
      delay: stagger(position, dur, dely, columnCount),
      builder: (context, animationController) => animatedChildBuilder(animationController!),
    );
  }

  Duration stagger(int position, Duration duration, Duration? delay, int columnCount) {
    var delayInMilliseconds = (delay == null ? duration.inMilliseconds ~/ 6 : delay.inMilliseconds);

    int _computeStaggeredGridDuration() {
      return (position ~/ columnCount + position % columnCount) * delayInMilliseconds;
    }

    int _computeStaggeredListDuration() {
      return position * delayInMilliseconds;
    }

    return Duration(milliseconds: columnCount > 1 ? _computeStaggeredGridDuration() : _computeStaggeredListDuration());
  }
}
