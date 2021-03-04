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