# na3eeman

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Imported Componnants Usage:

### flutter_animated_button
```dart
dependencies:
  flutter_animated_button: <latest_version>
```
`import 'package:flutter_animated_button/flutter_animated_button.dart';`

```dart
AnimatedButton(
    width: 200,
    text: 'SUBMIT',
    selectedTextColor: Colors.black,
    transitionType: TransitionType.BOTTOM_TO_TOP,
    textStyle: TextStyle(
        fontSize: 28,
        letterSpacing: 5,
        color: Colors.deepOrange,
        fontWeight: FontWeight.w300),
  )
```

### [My Profile Avatar](https://pub.dev/packages/my_profile_avatar)
```
dependencies:
    my_profile_avatar: ^1.0.0
```
`import 'package:my_profile_avatar/my_profile_avatar.dart';`
```
MyProfileAvatar(
    style: MyProfileAvatarStyle(
        size: 60,
        color: Colors.blue,
        radius: 30,
    ),
    urlImage: 'https://example.com/avatar.jpg',
)
```

### [animated_floating_buttons](https://github.com/nabil-hfz/animated-floatbuttons)
```dart
dependencies:
    animated_floating_buttons: ^0.0.1
```
`import 'package:animated_floating_buttons/animated_floating_buttons.dart';`
```dart
      /// when you want to close the menu you have to create 
      final GlobalKey<AnimatedFloatingActionButtonState> key =GlobalKey<AnimatedFloatingActionButtonState>();
      /// and then assign it to the our widget library
Widget float1() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        heroTag: "btn1",
        tooltip: 'First button',
        child: Icon(Icons.add),
      ),
    );
}

Widget float2() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        heroTag: "btn2",
        tooltip: 'Second button',
        child: Icon(Icons.add),
      ),
    );
}
Scaffold(
    floatingActionButton: AnimatedFloatingActionButton(
        //Fab list
        fabButtons: <Widget>[
            float1(), float2()
        ],
        key : key,
        colorStartAnimation: Colors.blue,
        colorEndAnimation: Colors.red,
        animatedIconData: AnimatedIcons.menu_close //To principal button
    ),
)
```

### [material_neumorphic_button](https://pub.dev/packages/material_neumorphic_toggle)
```dart
dependencies:
  material_neumorphic_toggle: ^1.1.3
```
`import 'package:material_neumorphic_toggle/material_neumorphic_toggle.dart';`
```dart
Expanded(
 child: NeumorphicToggle(
   height: 50,
   selectedIndex: _selectedIndex,
   displayForegroundOnlyIfSelected: true,
   children: [
     ToggleElement(
       background: Center(child: Text("This week", style: TextStyle(fontWeight: FontWeight.w500),)),
       foreground: Center(child: Text("This week", style: TextStyle(fontWeight: FontWeight.w700),)),
     ),
     ToggleElement(
       background: Center(child: Text("This month", style: TextStyle(fontWeight: FontWeight.w500),)),
       foreground: Center(child: Text("This month", style: TextStyle(fontWeight: FontWeight.w700),)),
     ),
     ToggleElement(
       background: Center(child: Text("This year", style: TextStyle(fontWeight: FontWeight.w500),)),
       foreground: Center(child: Text("This year", style: TextStyle(fontWeight: FontWeight.w700),)),
     )
   ],
   thumb: Neumorphic(
     boxShape: NeumorphicBoxShape.roundRect(borderRadius: BorderRadius.all(Radius.circular(12))),
   ),
   onChanged: (value) {
     setState(() {
       _selectedIndex = value;
       print("_firstSelected: $_selectedIndex");
     });
   },
 ),
),
```

### [neumorphic_button](https://pub.dev/packages/neumorphic_button)
```dart
dependencies:
  neumorphic_button: ^0.0.1+2
```
`import 'package:neumorphic_button/neumorphic_button.dart';`
```dart
/* light */
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
          child: NeumorphicButton(
        onTap: () {},
        child: Image.asset(
          'assets/apple.png',
          height: 80,
          color: Colors.grey[700],
        ),
        BorderRadius: 12,
        bottomRightShadowBlurRadius: 15,
        bottomRightShadowSpreadRadius: 1,
        borderWidth: 5,
        backgroundColor: Colors.grey.shade300,
        topLeftShadowBlurRadius: 15,
        topLeftShadowSpreadRadius: 1,
        topLeftShadowColor: Colors.white,
        bottomRightShadowColor: Colors.grey.shade500,
        height: size.width * 0.5,
        width: size.width * 0.5,
        padding: EdgeInsets.all(50),
        bottomRightOffset: Offset(4, 4),
        topLeftOffset: Offset(-4, -4),
      )),
    );
  }
}
```

### [o3d](https://pub.dev/packages/o3d)
```dart
dependencies:
  o3d: ^3.1.0
```
`import 'package:o3d/o3d.dart';`
```dart
/*Creating a O3D widget */
class _MyHomePageState extends State<MyHomePage> {
  
  // to control the animation
  O3DController controller = O3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () => 
                  controller.cameraOrbit(20, 20, 5),
              icon: const Icon(Icons.change_circle)),
          IconButton(
              onPressed: () =>
                  controller.cameraTarget(1.2, 1, 4), 
              icon: const Icon(Icons.change_circle_outlined)),
        ],
      ),
      body: O3D.asset(
         src: 'assets/glb/jeff_johansen_idle.glb', 
         controller: controller,
      ),
    );
  }
}
Loading a bundled Flutter asset 
O3D.asset(
  src: 'assets/MyModel.glb',
  // ...
),
/*
Loading a model from the web 
*/
body: O3D.network(
   src:'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
   // ...
),
/*
Loading a model from the file system 
*/
This is not available on Web.

class HomePage extends StatelessWidget {
   const HomePage({super.key});
   
   @override
   Widget build(BuildContext context) {
      return O3D(src: 'file:///path/to/MyModel.glb',
      // ...
      );
   }
}
```

### [Flutter-Neumorphic](https://github.com/Idean/Flutter-Neumorphic)
```dart
dependencies:
  flutter_neumorphic: ^3.0.3
```
`import 'package:flutter_neumorphic/flutter_neumorphic.dart';`
```dart
/* no exapmles */

```

### [scrollable_calender](https://pub.dev/packages/scrollable_calender)
```dart
dependencies:
  scrollable_calender: 0.0.4
```
`import 'package:kest_scrollable_calender/kest_scrollable_calender.dart';`
```dart
CustomDateSelector(
  label: "Birth Date",
  theme: CalendarTheme.light, // or CalendarTheme.dark // also has a copy with for your colors...
  onDateSelected: (year, month, day) {
    print('Selected: $day/$month/$year');
  },
```

### [Customizable Calendar](https://medium.com/@dmroznurr/customizable-calendar-widget-with-flutter-flutter-custom-calendar-b8e7bedb159d)
```dart
dependencies:
  flutter_custom_calendar: ^0.0.1
```
`import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
`
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('tr', ''), // Turkish
        const Locale('ur', ''), // Urdu
        const Locale('zh', ''), // Chinese
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text('Customizable Calendar Example'),
        ),
        body: Center(
          child: FlutterCustomCalendar(
            selectedDate: DateTime.now(),
            calenderBackgroundColor: Colors.white,
            selectedDayColor: Colors.orange,
            unselectedDayColor: Colors.transparent,
            selectedDayTextColor: Colors.white,
            unselectedDayTextColor: Colors.black,
            onDateSelected: (DateTime date) {
              print('Selected date: $date');
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

```

### [bottom_picker](https://pub.dev/packages/bottom_picker)
```dart
dependencies:
 bottom_picker: ^4.1.0
```
`import 'package:bottom_picker/bottom_picker.dart';`
```dart
/// Renders the header component of the bottom picker
final Widget Function(BuildContext context)? headerBuilder;

///defines whether the bottom picker is dismissable or not
///by default it's set to false
///
final bool dismissable;

///list of items (List of widgets) used to create simple item picker (required)
///and should not be empty or null
///
///for date/dateTime/time items parameter is not available
///
late List<Widget>? items;

///Nullable function, invoked when navigating between picker items
///whether it's date picker or simple item picker it will return a value DateTime or int(index)
///
late Function(dynamic)? onChange;

///Nullable function invoked  when clicking on submit button
///if the picker  type is date/time/dateTime it will return DateTime value
///else it will return the index of the selected item
///
late Function(dynamic)? onSubmit;

/// Nullable function invoked when the picker get dismissed
/// it will return the selected value
late Function(dynamic)? onDismiss;

///set the theme of the bottom picker (the button theme)
///possible values
///```
///{
///blue,
///orange,
///temptingAzure,
///heavyRain,
///plumPlate,
///morningSalad
///}
///```
final BottomPickerTheme bottomPickerTheme;

///used for simple bottom picker
///by default it's 0, needs to be in the range [0, this.items.length-1]
///otherwise an exception will be thrown
///for date and time picker type this parameter is not available
///
late int selectedItemIndex;

///The initial date time applied on the date and time picker
///by default it's null
///
DateTime? initialDateTime;

///The initial time set in the time picker widget
///required only when using the `time` constructor
Time? initialTime;

/// The initial duration set for the timer picker
/// By default it's set to null so it's `Duration.zero`
Duration? initialTimerDuration;

/// The time picker mode "hm", "hms" or "ms"
/// By default it's set to "hm"
CupertinoTimerPickerMode? timerPickerMode;

/// The timer seconds interval
/// Cannot be less then 1
///
/// Default value is 1.
int timerSecondsInterval = 1;

///The max time can be set in the time picker widget
Time? maxTime;

///The min time can be set in the time picker widget
Time? minTime;

///The gap between two minutes
///by default it's 1 minute
int minuteInterval = 1;

///the max date time on the date picker
///by default it's null
DateTime? maxDateTime;

///the minimum date & time applied on the date picker
///by default it's null
///
DateTime? minDateTime;

///define whether the time uses 24h or 12h format
///by default it's false (12h format)
///
late bool use24hFormat;

///the padding that will be applied to the button
///if the padding is null the button will be rendered null
final double? buttonPadding;

///the width that will be applied to the button
///if the buttonWidth is null the button will be rendered with null
final double? buttonWidth;

///the bottom picker background color,
///by default it's white
///
final Color backgroundColor;

///date order applied on date picker or date time picker
///by default it's YYYY/MM/DD
DatePickerDateOrder? dateOrder;

/// The picker theme data
final CupertinoTextThemeData? pickerThemeData;

///define the picker item extent available only for list items picker
///by default it's 35
late double itemExtent;

///the layout orientation of the bottom picker
///by default the orientation is set to LTR
///```
///LAYOUT_ORIENTATION.ltr,
///LAYOUT_ORIENTATION.rtl
///```
TextDirection? layoutOrientation;

///THe alignment of the bottom picker button
///by default it's `MainAxisAlignment.center`
final MainAxisAlignment buttonAlignment;

///bottom picker main widget height
///if it's null the bottom picker will get the height from
///[bottomPickerHeight] extension on context
final double? height;

///invoked when pressing on the submit button when using range picker
///it return two dates (first date, end date)
///required when using [BottomPicker.range]
late Function(DateTime, DateTime)? onRangeDateSubmitPressed;

///the minimum first date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? minFirstDate;

///the minimum second date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? minSecondDate;

///the maximum first date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? maxFirstDate;

///the maximum second date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? maxSecondDate;

///the initial first date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? initialFirstDate;

///the initial last date in the date range picker
///not required if null no minimum will be set in the date picker
DateTime? initialSecondDate;

/// A widget overlaid on the picker to highlight the currently selected entry.
/// The [selectionOverlay] widget drawn above the [CupertinoPicker]'s picker
/// wheel.
Widget? selectionOverlay;

///The button's widget that will be displayed
///if null the button will have a simple 'Select' text in the center
final Widget? buttonContent;

///indicates if the submit button will be displayed or not
///by default the submit button is shown
late bool displaySubmitButton;

///a single color will be applied to the button instead of the gradient
///themes
///
final Color? buttonSingleColor;

///to set a custom button theme color use this list
///when it's not null it will be applied
///
final List<Color>? gradientColors;

/// The style that will be applied on the button's widget
final BoxDecoration? buttonStyle;

/// Invoked when pressing on the submit button when using range picker
/// it return two dates (first time, end time)
/// required when using [BottomPicker.rangeTime]
late Function(DateTime, DateTime)? onRangeTimeSubmitPressed;

/// Function invoked when the picker is dismissed used with range picker
/// and time range picker.
late Function(DateTime, DateTime)? onRangePickerDismissed;

///the minimum first time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? minFirstTime;

///the minimum second time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? minSecondTime;

///the maximum first time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? maxFirstTime;

///the maximum second time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? maxSecondTime;

///the initial first time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? initialFirstTime;

///the initial last time in the time range picker
///not required if null no minimum will be set in the time picker
DateTime? initialSecondTime;

/// Indicates whether the time seperator (":") will be shown or not.
bool showTimeSeparator = false;

/// Indiacate whether the bottom picker will be closed (poped out of the Navigator)
/// when the submit button is pressed.
///
/// By default closeOnSubmit = true.
bool? closeOnSubmit;

/// The datepicker calendar type
List<int> calendarDays = CupertinoDatePickerWidget.fullWeek;

/// The bottom picker selector diameter ratio.
final double diameterRatio;

/// A predicate that can be used to select which hours are selectable.
SelectableHourPredicate? hourPredicate;

/// Indicates whether to use SafeArea to avoid content overflow.
final bool useSafeArea;
```
```dart
BottomPicker(
  items: items,
  headerBuilder: (context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Choose your country',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.close),
        ),
      ],
    );
  },
).show(context);
```

### [omni_datetime_picker](https://pub.dev/packages/omni_datetime_picker)
```dart
dependencies:
  omni_datetime_picker: ^2.3.1
```
'import 'package:omni_datetime_picker/omni_datetime_picker.dart';'
```dart
DateTime? dateTime = await showOmniDateTimePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime(1600).subtract(const Duration(days: 3652)),
                    lastDate: DateTime.now().add(
                      const Duration(days: 3652),
                    ),
                    is24HourMode: false,
                    isShowSeconds: false,
                    minutesInterval: 1,
                    secondsInterval: 1,
                    isForce2Digits: false,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                      maxHeight: 650,
                    ),
                    transitionBuilder: (context, anim1, anim2, child) {
                      return FadeTransition(
                        opacity: anim1.drive(
                          Tween(
                            begin: 0,
                            end: 1,
                          ),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                    barrierDismissible: true,
                    barrierColor: const Color(0x80000000),
                    selectableDayPredicate: (dateTime) {
                      // Disable 25th Feb 2023
                      if (dateTime == DateTime(2023, 2, 25)) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    type: OmniDateTimePickerType.dateAndTime,
                    title: Text('Select Date & Time'),
                    titleSeparator: Divider(),
                    separator: SizedBox(height: 16),
                    padding: EdgeInsets.all(16),
                    insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    theme: ThemeData.light(),
                    actionsBuilder: (context, confirmCallback, cancelCallback) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: cancelCallback,
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: confirmCallback,
                            child: Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
```
```dart
List<DateTime>? dateTimeList =
                      await showOmniDateTimeRangePicker(
                    context: context,
                    startInitialDate: DateTime.now(),
                    startFirstDate:
                        DateTime(1600).subtract(const Duration(days: 3652)),
                    startLastDate: DateTime.now().add(
                      const Duration(days: 3652),
                    ),
                    endInitialDate: DateTime.now(),
                    endFirstDate:
                        DateTime(1600).subtract(const Duration(days: 3652)),
                    endLastDate: DateTime.now().add(
                      const Duration(days: 3652),
                    ),
                    is24HourMode: false,
                    isShowSeconds: false,
                    minutesInterval: 1,
                    secondsInterval: 1,
                    isForce2Digits: false,
                    isForceEndDateAfterStartDate: true,
                    onStartDateAfterEndDateError: () {
                      // Handle error when start date is after end date
                      print('Start date cannot be after end date!');
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                      maxHeight: 650,
                    ),
                    transitionBuilder: (context, anim1, anim2, child) {
                      return FadeTransition(
                        opacity: anim1.drive(
                          Tween(
                            begin: 0,
                            end: 1,
                          ),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 200),
                    barrierDismissible: true,
                    barrierColor: Colors.black54,
                    startSelectableDayPredicate: (dateTime) {
                      // Disable 25th Feb 2023 for start date
                      if (dateTime == DateTime(2023, 2, 25)) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    endSelectableDayPredicate: (dateTime) {
                      // Disable 26th Feb 2023 for end date
                      if (dateTime == DateTime(2023, 2, 26)) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                    type: OmniDateTimePickerType.dateAndTime,
                    title: Text('Select Date & Time Range'),
                    titleSeparator: Divider(),
                    startWidget: Text('Start'),
                    endWidget: Text('End'),
                    separator: SizedBox(height: 16),
                    defaultTab: DefaultTab.start,
                    padding: EdgeInsets.all(16),
                    insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    theme: ThemeData.light(),
                    actionsBuilder: (context, confirmCallback, cancelCallback) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: cancelCallback,
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: confirmCallback,
                            child: Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
```

### [keyboard_safe](https://pub.dev/packages/keyboard_safe)
```dart
dependencies:
  keyboard_safe: ^1.0.0
```
'import 'package:keyboard_safe/keyboard_safe.dart';'
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: KeyboardSafe(
      scroll: true,
      dismissOnTapOutside: true,
      footer: ElevatedButton(
        onPressed: _submitForm,
        child: const Text('Submit'),
      ),
      child: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: 'Email')),
          SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: 'Password')),
        ],
      ),
    ),
  );
}
```

### [material_text_fields](https://pub.dev/packages/material_text_fields)
```dart
dependencies:
material_text_fields: ^1.0.6
```
'import 'package:material_text_fields/material_text_fields.dart';'
```dart
MaterialTextField(
                keyboardType: TextInputType.emailAddress,
                hint: 'Email',
                textInputAction: TextInputAction.next,
                prefixIcon: Image.asset('assets/images/ic_lock.png'),
                controller: _emailTextController,
                validator: FormValidation.emailTextField,
                onChanged: (text) {
                  print('First text field: $text');
                },
                suffixIcon: Image.asset('assets/images/ic_lock.png'),
                enabled: false,
                obscureText: true,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                labelText: 'Password',
                theme: FilledOrOutlinedTextTheme(
                  enabledColor: Colors.grey,
                  focusedColor: Colors.green,
                  fillColor: Colors.transparent,
                ) // you can use theme param to differ this text field from app level theming
              )
```

### [text_input_formatter](https://pub.dev/packages/text_input_formatter)
```dart
dependencies:
  text_input_formatter: ^1.0.2
```
'import 'package:text_input_formatter/text_input_formatter.dart';'
```dart
// defined reusable formatter
final formatter = NumericFormatter(
  allowFraction: true,
  fractionDigits: 5,
  thousandSeparator: ' ',
);
// ...

TextField(
inputFormatters: [formatter],
onChanged: (value) {
// use the formatter to parse the original value
final originalValue = formatter.original(value);
print(originalValue);
}
),
```

### [gsform ](https://pub.dev/packages/gsform)
```dart
dependencies:
  gsform: ^0.3.6
```
```dart
import 'package:gsform/gs_form/core/form_style.dart';
import 'package:gsform/gs_form/enums/field_status.dart';
import 'package:gsform/gs_form/model/data_model/date_data_model.dart';
import 'package:gsform/gs_form/model/data_model/radio_data_model.dart';
import 'package:gsform/gs_form/model/data_model/spinner_data_model.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:gsform/gs_form/widget/section.dart';
```
```dart
GSFormStyle(
	backgroundFieldColor: COLOR,
	backgroundSectionColor: COLOR,
	sectionCardElevation: 0
	titleStyle: TextStyle,
	fieldHintStyle: TextStyle,
	fieldTextStyle: TextStyle,
	sectionRadius: 10.0,
	errorTextStyle: TextStyle,
	fieldRadius: double,
	helpTextStyle:TextStyle ,
	requireType: GSFieldRequireTypeEnum, //text, star
	sectionCardPadding: 8.0,
	requiredText: '(required)'
)
```

### [salonping_card](https://pub.dev/packages/salonping_card)
```dart
dependencies:
  salonping_card: ^0.0.1
```
`import 'package:salonping_card_listview/salonping_card.dart_listview';`
```dart
import 'package:flutter/material.dart';
import 'package:salonping_card_listview/salonping_card.dart_listview';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<SalonpingCardData> products = [
      SalonpingCardData(
          imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/red-lipstick/1.webp',
          title: 'Demo Product1',
          price: '\$10.00',
          totalItems: 15,
          
        ),
      SalonpingCardData(
          imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
          title: 'Demo Product2',
          price: '\$10.00',
          totalItems: 15,
        ),
      SalonpingCardData(
          imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
          title: 'Demo Product3',
          price: '\$10.00',
          totalItems: 15,
        
        ),
      SalonpingCardData(
          imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
          title: 'Demo Product4',
          price: '\$10.00', totalItems: 15,
        ),
      SalonpingCardData(
          imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',
          title: 'Demo Product5',
          price: '\$10.00',
          totalItems: 15,
        ),];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salonping Card Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Salonping Card UI')),
        body: CardListView(
          scrollDirection: Axis.vertical,
          onClick: (product){
          //   Write your code here
          },
          isLoading: false,
          products: products

        ),
      ),
    );
  }
}
```

### [animated_accordion](https://pub.dev/packages/animated_accordion)
```dart
dependencies:
  animated_accordion: latest_version
```
`import 'package:animated_accordion/animated_accordion.dart';`
```dart
import 'package:animated_accordion/animated_accordion.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Expandable Tile Example'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ExampleScreen(),
        ),
      ),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AnimatedAccordion(
          headerTitle: "Slide Animation Title",
          contentWidgets: [
            const ListTile(
              title: Text("Content 1"),
            ),
            const ListTile(
              title: Text("Content 2"),
            ),
            const ListTile(
              title: Text("Content 3"),
            ),
            ElevatedButton(
                onPressed: () {
                  print("Button in Slide");
                },
                child: const Text("Button in Slide")),
          ],
          contentAnimationType: AnimatedAccordionAnimationType.slide,
          headerBackgroundColor: Colors.lightBlue[100],
          contentBackgroundColor: Colors.lightBlue[200],
          headerTitleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentHeight: 150,
          animationDuration: const Duration(milliseconds: 700),
        ),
        AnimatedAccordion(
          headerTitle: "Fade Animation Title",
          contentWidgets: [
            const ListTile(
              title: Text("Fade Content 1"),
            ),
            const ListTile(
              title: Text("Fade Content 2"),
            ),
            const ListTile(
              title: Text("Fade Content 3"),
            ),
          ],
          contentAnimationType: AnimatedAccordionAnimationType.fade,
          headerBackgroundColor: Colors.orange[100],
          contentBackgroundColor: Colors.orange[200],
        ),
        AnimatedAccordion(
          headerTitle: "Scale Animation Title",
          contentWidgets: [
            const ListTile(
              title: Text("Scale Content 1"),
            ),
            const ListTile(
              title: Text("Scale Content 2"),
            ),
            const ListTile(
              title: Text("Scale Content 3"),
            ),
          ],
          contentAnimationType: AnimatedAccordionAnimationType.scale,
          headerBackgroundColor: Colors.green[100],
          contentBackgroundColor: Colors.green[200],
        ),
      ],
    );
  }
}
```

### [kiwi ](https://pub.dev/packages/kiwi)
```dart
dependencies:
  kiwi: ^latest_version
```
`import 'package:kiwi/kiwi.dart';`
```dart
import 'package:kiwi/kiwi.dart';

main() {
  KiwiContainer container = KiwiContainer();

  container.registerInstance(Logger());
  container.registerSingleton((c) => Logger(), name: 'namedLogger');
  container.registerFactory(
      (c) => ServiceA(logger: c.resolve<Logger>('namedLogger')));

  final comumLogger = container.resolve<Logger>();
  final namedLogger = container.resolve<Logger>('namedLogger');
  final serviceA = container.resolve<ServiceA>();

  print(comumLogger.toString()); // Hey, I'm a logger!
  print(namedLogger.toString()); // Hey, I'm a logger!
  print(serviceA.toString()); // Hey, I'm a service A!
}

class Service {
  const Service();

  @override
  String toString() {
    return 'Hey, I\'m a service!';
  }
}

class ServiceA extends Service {
  final Logger logger;

  const ServiceA({required this.logger});

  @override
  String toString() {
    return 'Hey, I\'m a service A!';
  }
}

class Logger {
  const Logger();

  @override
  String toString() {
    return 'Hey, I\'m a logger!';
  }
}
```

### [introduction_screen](https://pub.dev/packages/introduction_screen)
```dart
dependencies:
  introduction_screen: ^4.0.0
```
`import 'package:introduction_screen/introduction_screen.dart';`
```dart
class IntroScreenDemo extends StatefulWidget {
  @override
  State<IntroScreenDemo> createState() => _IntroScreenDemoState();
}

class _IntroScreenDemoState extends State<IntroScreenDemo> {
  // 1. Define a `GlobalKey` as part of the parent widget's state
  final _introKey = GlobalKey<IntroductionScreenState>();
  String _status = 'Waiting...';

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      // 2. Pass that key to the `IntroductionScreen` `key` param
      key: _introKey,
      pages: [
        PageViewModel(
            title: 'Page One',
            bodyWidget: Column(
              children: [
                Text(_status),
                ElevatedButton(
                    onPressed: () {
                      setState(() => _status = 'Going to the next page...');

                      // 3. Use the `currentState` member to access functions defined in `IntroductionScreenState`
                      Future.delayed(const Duration(seconds: 3),
                          () => _introKey.currentState?.next());
                    },
                    child: const Text('Start'))
              ],
            )),
        PageViewModel(
            title: 'Page Two', bodyWidget: const Text('That\'s all folks'))
      ],
      showNextButton: false,
      showDoneButton: false,
    );
  }
}
```

### [snacky ](https://pub.dev/packages/snacky)
```dart

```
```dart
import 'package:snacky_example/widget/example_snacky_configurator.dart';
import 'package:snacky_example/widget/snacky_example.dart';
```
```dart
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:snacky_example/widget/example_snacky_configurator.dart';
import 'package:snacky_example/widget/snacky_example.dart';

const colorAccent = Color(0xFF7D64F2);
const colorPrimary = Color(0xFF1A1A1A);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ImpaktfullThemeConfiguratorWidget(
      child: ExampleSnackyConfigurator(
        child: MaterialApp(
          title: 'Snacky',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: colorAccent),
            useMaterial3: true,
          ),
          navigatorObservers: [
            SnackyNavigationObserver(),
          ],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImpaktfullScreen(
      child: ImpaktfullListView(
        spacing: 8,
        children: [
          Image.asset(
            '../assets/logo.png',
            height: 50,
          ),
          const SizedBox(height: 48),
          ImpaktfullButton.primary(
            label: 'Simple',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SnackyExampleScreen(
                  title: 'Simple',
                  controller: SnackyController.instance,
                ),
              ),
            ),
          ),
          ImpaktfullButton.primary(
            label: 'Toast',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SnackyExampleScreen(
                  title: 'Toast',
                  controller: taostSnackyController,
                ),
              ),
            ),
          ),
          ImpaktfullButton.primary(
            label: 'Gradient',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SnackyExampleScreen(
                  title: 'Gradient',
                  controller: gradientSnackyController,
                ),
              ),
            ),
          ),
          ImpaktfullButton.accent(
            label: 'Layout Config tester',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SnackyExampleScreen(
                  title: 'Layout Config',
                  controller: layoutConfigSnackyController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### []()
```dart

```
``
```dart

```
### []()
```dart

```
``
```dart

```

### []()
```dart

```
``
```dart

```


### []()
```dart

```
``
```dart

```


### []()
```dart

```
``
```dart

```

### []()
```dart

```
``
```dart

```

### []()
```dart

```
``
```dart

```

### []()
```dart

```
``
```dart

```

### []()
```dart

```
``
```dart

```



