import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

extension _TimeOfDayExt on TimeOfDay {
  int get totalRangeTime => this.hour * _minutesInHour + this.minute;
}

const _minutesInHour = 60;

const _defaultColorRed = const Color(0xFFE53935);
const _defaultColorGreen = const Color(0xFF43A047);
const _defaultColorSelected = const Color(0xFFFF9800);

const _defaultLabelStyle = const TextStyle(
  color: Colors.black87,
  fontSize: 9.0,
  fontWeight: FontWeight.w400,
);

String _addLeadingZeroIfNeeded(int value) {
  if (value < 10) {
    return '0$value';
  }
  return value.toString();
}

/// A range consisting of starting [TimeOfDay] and ending [TimeOfDay].
class BookingValues implements Comparable<BookingValues> {
  /// The initial/starting value of the [BookingValues] range.
  final TimeOfDay start;

  /// The final/ending value of the [BookingValues] range.
  final TimeOfDay end;

  /// If `true` then this [BookingValues] range is available for booking.
  /// Defaults to `false`.
  final bool isAvailable;

  BookingValues(
    this.start,
    this.end, {
    this.isAvailable = false,
  }) : assert(
          (start.totalRangeTime == 0 && start.totalRangeTime == 0) ||
              (start.totalRangeTime < end.totalRangeTime),
          'Starting time must not be later than the ending time!',
        );

  @override
  int compareTo(BookingValues other) {
    final otherStart = other.start.totalRangeTime;
    if (start.totalRangeTime == otherStart) {
      return 0;
    } else if (start.totalRangeTime < otherStart) {
      return -1;
    } else {
      return 1;
    }
  }

  @override
  String toString() =>
      'BookingValues{start: $start, end: $end, isAvailable: $isAvailable}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingValues &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// A widget which allows you to easily select booking/reservation ranges.
///
/// Usage example:
/// ```
/// BookingRangeSlider(
///               onChanged: (value) {
///                 print(value);
///               },
///               displayHandles: true,
///               labelFrequency: TimeOfDay(hour: 1, minute: 0),
///               initialTime: TimeOfDay(hour: 0, minute: 0),
///               endingTime: TimeOfDay(hour: 6, minute: 0),
///               values: <BookingValues>[
///                 BookingValues(
///                   TimeOfDay(hour: 1, minute: 0),
///                   TimeOfDay(hour: 2, minute: 0),
///                 ),
///                 BookingValues(
///                   TimeOfDay(hour: 3, minute: 0),
///                   TimeOfDay(hour: 3, minute: 30),
///                 ),
///                 BookingValues(
///                   TimeOfDay(hour: 4, minute: 0),
///                   TimeOfDay(hour: 5, minute: 0),
///                   isAvailable: true,
///                 ),
///                 BookingValues(
///                   TimeOfDay(hour: 5, minute: 30),
///                   TimeOfDay(hour: 6, minute: 0),
///                 ),
///               ],
///             )
/// ```
class BookingRangeSlider extends LeafRenderObjectWidget {
  /// Color for displaying unavailable/booked [BookingValues] ranges.
  /// Defaults to red color.
  final Color unavailableColor;

  /// Color for displaying available/free [BookingValues] ranges.
  /// Defaults to green color.
  final Color availableColor;

  /// Color for displaying the current selected [BookingValues] range.
  /// Defaults to orange color.
  final Color selectedColor;

  /// Whether should be displayed handles at the bounds of selected
  /// [BookingValues] range. Defaults to true.
  final bool displayHandles;

  /// Whether should be displayed labels at top of the [BookingRangeSlider] slider.
  /// Defaults to true.
  final bool displayLabels;

  /// Whether should be highlighted the current selected
  /// [BookingValues] range. Defaults to true.
  final bool highlightSelected;

  /// How often should be displayed the label above the [BookingRangeSlider] slider.
  /// Defaults to each 4 hours.
  final TimeOfDay labelFrequency;

  /// The [TextStyle] of the label.
  final TextStyle labelStyle;

  /// Initial/starting boundary of the left side of [BookingRangeSlider].
  /// Defaults to 0h 0min.
  ///
  /// If both [initialTime] and [endingTime] have values `hours` and `minutes` 0
  /// then the range of [BookingRangeSlider] is 24 hours.
  ///
  /// Initial time must not be later than the [endingTime].
  final TimeOfDay initialTime;

  /// Ending/final boundary of the left side of [BookingRangeSlider].
  /// Defaults to 0h 0min.
  ///
  /// If both [initialTime] and [endingTime] have values `hours` and `minutes` 0
  /// then the range of [BookingRangeSlider] is 24 hours.
  ///
  /// Ending time must be later than the [initialTime].
  final TimeOfDay endingTime;

  /// What [TimeOfDay] values can be iterated for each handle drag.
  /// Defaults to 30 minutes.
  ///
  /// For example - each handle drag will increases/decrease the
  /// current [TimeOfDay] by 2 hours:
  /// ```
  /// division: TimeOfDay(hour: 2, minute: 0),
  /// ```
  ///
  final TimeOfDay division;

  /// Triggered when the handle position changes.
  final ValueChanged<BookingValues>? onChanged;

  /// List of [BookingValues] which will fill the [BookingRangeSlider] by the
  /// `isAvailable` property of [BookingValues]. Not every range is needed to be
  /// filled - the rest of unfilled area will be filled with
  /// green [BookingValues] values by default.
  ///
  /// [BookingValues] must not overlap!
  final List<BookingValues> values;

  const BookingRangeSlider({
    Key? key,
    this.unavailableColor = _defaultColorRed,
    this.availableColor = _defaultColorGreen,
    this.selectedColor = _defaultColorSelected,
    this.displayHandles = true,
    this.displayLabels = true,
    this.highlightSelected = true,
    this.labelStyle = _defaultLabelStyle,
    this.labelFrequency = const TimeOfDay(hour: 4, minute: 0),
    this.initialTime = const TimeOfDay(hour: 0, minute: 0),
    this.endingTime = const TimeOfDay(hour: 0, minute: 0),
    this.division = const TimeOfDay(hour: 0, minute: 30),
    required this.onChanged,
    required this.values,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBookingSlider(
      unavailableColor: unavailableColor,
      availableColor: availableColor,
      selectedColor: selectedColor,
      displayHandles: displayHandles,
      displayLabels: displayLabels,
      highlightSelected: highlightSelected,
      labelStyle: labelStyle,
      labelFrequency: labelFrequency,
      initialTime: initialTime,
      endingTime: endingTime,
      division: division,
      onChanged: onChanged,
      values: values,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderBookingSlider renderObject,
  ) {
    renderObject
      ..unavailableColor = unavailableColor
      ..availableColor = availableColor
      ..selectedColor = selectedColor
      ..displayHandles = displayHandles
      ..displayLabels = displayLabels
      ..highlightSelected = highlightSelected
      ..labelStyle = labelStyle
      ..labelFrequency = labelFrequency
      ..initialTime = initialTime
      ..endingTime = endingTime
      ..division = division
      ..onChanged = onChanged
      ..values = values;
  }

  // TODO:
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _RenderBookingSlider extends RenderBox {
  Color _unavailableColor;
  Color _availableColor;
  Color _selectedColor;
  bool _displayHandles;
  bool _displayLabels;
  bool _highlightSelected;
  TimeOfDay _labelFrequency;
  TextStyle _labelStyle;
  TimeOfDay _initialTime;
  TimeOfDay _endingTime;
  TimeOfDay _division;
  ValueChanged<BookingValues>? _onChanged;
  List<BookingValues> _values;

  _RenderBookingSlider({
    required Color unavailableColor,
    required Color availableColor,
    required Color selectedColor,
    required bool displayHandles,
    required bool displayLabels,
    required bool highlightSelected,
    required TimeOfDay labelFrequency,
    required TextStyle labelStyle,
    required TimeOfDay initialTime,
    required TimeOfDay endingTime,
    required TimeOfDay division,
    required ValueChanged<BookingValues>? onChanged,
    required List<BookingValues> values,
  })   : _unavailableColor = unavailableColor,
        _availableColor = availableColor,
        _selectedColor = selectedColor,
        _displayHandles = displayHandles,
        _displayLabels = displayLabels,
        _highlightSelected = highlightSelected,
        _labelStyle = labelStyle,
        _labelFrequency = labelFrequency,
        _initialTime = initialTime,
        _endingTime = endingTime,
        _division = division,
        _onChanged = onChanged,
        _values = values {
    drag = HorizontalDragGestureRecognizer()..onUpdate = updateHandlePos;
    sortCheckValues();
  }

  Color get unavailableColor => _unavailableColor;

  set unavailableColor(Color value) {
    if (value == unavailableColor) {
      return;
    }
    _unavailableColor = value;
    markNeedsPaint();
  }

  Color get availableColor => _availableColor;

  set availableColor(Color value) {
    if (value == availableColor) {
      return;
    }
    _availableColor = value;
    markNeedsPaint();
  }

  Color get selectedColor => _selectedColor;

  set selectedColor(Color value) {
    if (value == selectedColor) {
      return;
    }
    _selectedColor = value;
    markNeedsPaint();
  }

  bool get displayHandles => _displayHandles;

  set displayHandles(bool value) {
    if (value == displayHandles) {
      return;
    }
    _displayHandles = value;
    markNeedsLayout();
  }

  bool get displayLabels => _displayLabels;

  set displayLabels(bool value) {
    if (value == displayLabels) {
      return;
    }
    _displayLabels = value;
    markNeedsLayout();
  }

  bool get highlightSelected => _highlightSelected;

  set highlightSelected(bool value) {
    if (value == highlightSelected) {
      return;
    }
    _highlightSelected = value;
    markNeedsLayout();
  }

  TimeOfDay get labelFrequency => _labelFrequency;

  set labelFrequency(TimeOfDay value) {
    if (value == labelFrequency) {
      return;
    }
    _labelFrequency = value;
    markNeedsPaint();
  }

  TextStyle get labelStyle => _labelStyle;

  set labelStyle(TextStyle value) {
    if (value == labelStyle) {
      return;
    }
    _labelStyle = value;
    markNeedsLayout();
  }

  TimeOfDay get initialTime => _initialTime;

  set initialTime(TimeOfDay value) {
    if (value == initialTime) {
      return;
    }
    _initialTime = value;
    markNeedsPaint();
  }

  TimeOfDay get endingTime => _endingTime;

  set endingTime(TimeOfDay value) {
    if (value == endingTime) {
      return;
    }
    _endingTime = value;
    markNeedsPaint();
  }

  TimeOfDay get division => _division;

  set division(TimeOfDay value) {
    if (value == division) {
      return;
    }
    _division = value;
    markNeedsPaint();
  }

  ValueChanged<BookingValues>? get onChanged => _onChanged;

  set onChanged(ValueChanged<BookingValues>? value) {
    if (value == onChanged) {
      return;
    }
    _onChanged = value;
    markNeedsPaint();
  }

  List<BookingValues> get values => _values;

  set values(List<BookingValues> value) {
    if (value == values) {
      return;
    }
    _values = List.from(value);
    markNeedsPaint();
  }

  void sortCheckValues() {
    if (values.isEmpty) {
      setupEmpty();
    } else {
      values.any((e) {
        final check = e.end.totalRangeTime > endingTime.totalRangeTime;
        if (check) {
          throw ('${e.toString()} does not fit into the endingTime: ${endingTime.toString()}');
        }
        return check;
      });

      final bookingValuesList = <BookingValues>[]
        ..addAll(values.where((item) => !item.isAvailable));
      if (bookingValuesList.isEmpty) {
        setupEmpty();
        return;
      }

      bookingValuesList.sort((a, b) => a.compareTo(b));

      bool isInvalid = false;
      for (var i = 0; i < bookingValuesList.length; i++) {
        if (i != bookingValuesList.length - 1) {
          final curr = bookingValuesList[i];
          final next = bookingValuesList[i + 1];

          final currStartTime = curr.start.totalRangeTime;
          final nextStartTime = next.start.totalRangeTime;

          final currEndTime = curr.end.totalRangeTime;
          if (currStartTime == nextStartTime) {
            isInvalid = false;
          } else if (nextStartTime < currEndTime) {
            isInvalid = true;
          } else {
            isInvalid = false;
          }

          if (isInvalid) {
            throw ('Values cannot overlap. The relevant values: \n$curr\n$next');
          }
        }
      }
      values = bookingValuesList;
    }
  }

  void setupEmpty() {
    values = <BookingValues>[
      BookingValues(initialTime, endingTime, isAvailable: true),
    ];
  }

  static const minWidth = 120.0;

  double get handleSize => (labelStyle.fontSize ?? 3);

  double leftHandleValue = 0.5;
  double rightHandleValue = 0.75;

  late HorizontalDragGestureRecognizer drag;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // translate() method remaps the (0,0) position on the canvas
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    paintRects(canvas);

    if (displayHandles) {
      paintHandles(canvas);
    }

    if (displayLabels) {
      paintLabels(canvas);
    }

    // restore the translation at the beginning
    canvas.restore();
  }

  void paintRects(Canvas canvas) {
    final total = totalTimeInSeconds;
    final onePortion = size.width / total;

    final availablePaint = Paint()
      ..color = availableColor
      ..style = PaintingStyle.fill;
    final baseRect = Rect.fromPoints(
      Offset.zero,
      size.bottomRight(Offset.zero),
    );
    canvas.drawRect(baseRect, availablePaint);

    for (final value in values.where((e) => !e.isAvailable)) {
      final paint = Paint();

      paint
        ..color = unavailableColor
        ..style = PaintingStyle.fill;

      final timePortionRect = Rect.fromPoints(
        Offset(
          onePortion * value.start.totalRangeTime,
          0,
        ),
        Offset(
          onePortion * value.end.totalRangeTime,
          size.bottomRight(Offset.zero).dy,
        ),
        // size.bottomRight(Offset.zero),
      );
      canvas.drawRect(timePortionRect, paint);
    }

    if (highlightSelected) {
      final selectedRect = Rect.fromPoints(
        Offset(size.width * leftHandleValue, 0),
        Offset(size.width * rightHandleValue, size.height),
      );
      canvas.drawRect(
        selectedRect,
        Paint()..color = selectedColor,
      );
    }
  }

  void paintHandles(Canvas canvas) {
    final paint = Paint()..color = Colors.black;

    final leftHandleX = leftHandleValue * size.width;
    final rightHandleX = rightHandleValue * size.width;

    final handleSize = Size(3, size.height);
    final leftHandleRect = Offset(leftHandleX, 0) & handleSize;
    final rightHandleRect = Offset(rightHandleX, 0) & handleSize;

    canvas.drawRect(leftHandleRect, paint);
    canvas.drawRect(rightHandleRect, paint);
  }

  void paintLabels(Canvas canvas) {
    var total = endingTime.totalRangeTime - initialTime.totalRangeTime;
    if (total == 0) {
      total = 1440;
    }

    final p = labelFrequency.totalRangeTime;
    final freq = total / p;
    final spacing = size.width / freq;

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.85;
    for (var i = 0; i <= freq; i++) {
      var upperPoint = Offset(
        spacing * i,
        size.height * -0.75,
      );
      final lowerPoint = Offset(
        spacing * i,
        -2,
      );

      canvas.drawLine(upperPoint, lowerPoint, paint);
      paintTextLabel(canvas, upperPoint, lowerPoint, freq, i);
    }
  }

  void paintTextLabel(
    Canvas canvas,
    Offset upperPoint,
    Offset lowerPoint,
    double freq,
    int i,
  ) {
    final hrs = _addLeadingZeroIfNeeded(labelFrequency.hour * i);
    final mins = _addLeadingZeroIfNeeded(labelFrequency.minute);

    final textStyle = labelStyle.getTextStyle();
    final paragraphStyle = ui.ParagraphStyle(
      textDirection: TextDirection.ltr,
    );
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText('$hrs:$mins');
    final constraints = ui.ParagraphConstraints(width: size.width / freq);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(constraints);

    final textOffset = upperPoint.scale(1 * 0.9995, 2.25);
    canvas.drawParagraph(paragraph, textOffset);
  }

  void updateHandlePos(DragUpdateDetails dragUpdateDetails) {
    // restrict a number between 0 and size of the widget
    // (to get rid of out bounds clicks)
    final x = dragUpdateDetails.localPosition.dx.clamp(0, size.width);

    final pos = x / size.width;

    final leftDistance = (pos - leftHandleValue).abs();
    final rightDistance = (pos - rightHandleValue).abs();
    final newPos = double.parse((findClosest(pos)).toStringAsFixed(12));

    if (leftHandleValue != newPos && rightHandleValue != newPos) {
      if (leftDistance < rightDistance && rightHandleValue != newPos) {
        leftHandleValue = newPos;
      } else {
        if (leftHandleValue != newPos) {
          rightHandleValue = newPos;
        }
      }
      // debugPrint(
      //   'leftHandleValue: ${leftHandleValue.toString()} ----- '
      //   'rightHandleValue: ${rightHandleValue.toString()} ----- '
      //   'dragPos: $pos',
      // );

      if (onChanged != null) {
        final total = totalTimeInSeconds;
        final leftValueTime = convertToTimeOfDay(leftHandleValue * total);
        final rightValueTime = convertToTimeOfDay(rightHandleValue * total);

        final bookingVal = isSelectionAvailable(leftValueTime, rightValueTime);
        onChanged!(bookingVal);
      }
      markNeedsPaint();
    }
  }

  BookingValues isSelectionAvailable(
    TimeOfDay leftValueTime,
    TimeOfDay rightValueTime,
  ) {
    final isUnavailable = values.any((item) {
      if (item.isAvailable) {
        // print('base');
        return false;
      }

      final leftHandleDur = leftValueTime.totalRangeTime;
      final rightHandleDur = rightValueTime.totalRangeTime;

      final leftItemDur = item.start.totalRangeTime;
      final rightItemDur = item.end.totalRangeTime;

      // 120 - 180; 30 - 120
      if (leftHandleDur <= leftItemDur && rightHandleDur <= leftItemDur) {
        // print('valid 1st');
        return false;
      }

      // 120 - 180; 180 - 210
      if (leftHandleDur >= rightItemDur && leftHandleDur >= rightItemDur) {
        // print('valid 2nd');
        return false;
      }

      // 120 - 180; 120 - 150
      if (leftHandleDur >= leftItemDur && rightHandleDur <= rightItemDur) {
        // print('1st');
        return true;
      }

      // 120 - 180; 60 - 200
      if (leftHandleDur <= leftItemDur && rightHandleDur >= rightItemDur) {
        // print('2nd');
        return true;
      }

      // 120 - 180; 60 - 150
      if (leftHandleDur <= leftItemDur &&
          rightHandleDur >= leftItemDur &&
          rightHandleDur <= rightItemDur) {
        // print('3rd');
        return true;
      }

      // 120 - 180; 150 - 200
      if ((leftHandleDur >= leftItemDur && leftHandleDur <= rightItemDur) &&
          (rightHandleDur >= leftItemDur && rightHandleDur >= rightItemDur)) {
        // print('4th');
        return true;
      }

      // print('end');
      return false;
    });
    // print('${!isUnavailable} \n\n');
    return BookingValues(
      leftValueTime,
      rightValueTime,
      isAvailable: !isUnavailable,
    );
  }

  TimeOfDay convertToTimeOfDay(double seconds) {
    final secs = seconds.round();

    final hrs = secs ~/ _minutesInHour;
    final mins = secs % _minutesInHour;
    return TimeOfDay(hour: hrs, minute: mins);
  }

  // 24 hrs range - 0:00 to 0:00
  int get totalTimeInSeconds {
    var total = endingTime.totalRangeTime - initialTime.totalRangeTime;
    if (total == 0) {
      total = 1440;
    }
    return total;
  }

  double findClosest(double input) {
    final total = totalTimeInSeconds;

    final p = division.totalRangeTime;
    final freq = total / p;
    final timestampDiv = 1 / freq;

    final list = List.generate(
      freq.floor() + 1,
      (i) => i * timestampDiv,
    );

    double minDiff = 999;
    double closest = -1;
    for (final val in list) {
      final curr = input - val;
      if (curr >= 0 && curr < minDiff) {
        minDiff = curr;
        closest = val;
      }
    }
    // debugPrint('$input ----------- $list ----------- $closest');

    if (closest == -1) {
      return 0;
    }
    return closest;
  }

  @override
  double computeMinIntrinsicWidth(double height) => minWidth;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final customHeight = (labelStyle.fontSize ?? 3) * 1.5;
    final size = Size(
      constraints.maxWidth,
      customHeight,
    );
    return size;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      drag.addPointer(event);
    }
  }

  @override
  void detach() {
    drag.dispose();
    super.detach();
  }
}
