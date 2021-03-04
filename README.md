# booking_range_slider

[![pub package](https://img.shields.io/pub/v/booking_range_slider.svg)](https://pub.dev/packages/booking_range_slider)

A Flutter package which allows you to easily select booking/reservation ranges.

**Version has not reached 1.0.0. Bugs may be present or breaking changes might be introduced.**

## Usage

A simple usage example:

```dart
BookingRangeSlider(
  onChanged: (value) {
    _do(value);
  },
  displayHandles: true,
  labelFrequency: TimeOfDay(hour: 1, minute: 0),
  initialTime: TimeOfDay(hour: 0, minute: 0),
  endingTime: TimeOfDay(hour: 6, minute: 0),
  values: <BookingValues>[
    BookingValues(
      TimeOfDay(hour: 1, minute: 0),
      TimeOfDay(hour: 2, minute: 0),
    ),
    BookingValues(
      TimeOfDay(hour: 3, minute: 0),
      TimeOfDay(hour: 3, minute: 30),
    ),
    BookingValues(
      TimeOfDay(hour: 4, minute: 0),
      TimeOfDay(hour: 5, minute: 0),
      isAvailable: true,
    ),
    BookingValues(
      TimeOfDay(hour: 5, minute: 30),
      TimeOfDay(hour: 6, minute: 0),
    ),
  ],
)
```

### Properties
```dart
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
```