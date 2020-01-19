// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';
import 'clock_dial.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  Timer _timer;
  var dateStr = '';
  var _weatherImg = 'assets/sunny.png';
  final color_list_light = [
    0xFF1abc9c,
    0xFF2ecc71,
    0xFF3498db,
    0xFF673AB7,
    0xFFC74EA6,
    0xFFCC66FF,
    0xFF8BC34A,
  ];
  final color_list_dark = [
    0xFF333300,
    0xFF424242,
    0xFF4E342E,
    0xFF3E2723,
    0xFF57575,
    0xFF455A64,
    0xFF37474F,
  ];
  var _backgroundColorCount = 0;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _weatherImg =
          'assets/' + this.getWeatherIcon(widget.model.weatherString) + '.png';
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      dateStr = DateFormat('E dd/MM/yyyy aa').format(_now);
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
      _backgroundColorCount =
          (int.parse(DateFormat('s').format(_now)) / 10).round();
      if (_backgroundColorCount == 6) {
        _backgroundColorCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Colors.red,
            backgroundColor: Color(0x66D2E3FC), //Colors.white
            cardColor: Colors.amber,
            dividerColor: Colors.blue,
            dialogBackgroundColor: Colors.redAccent,
            selectedRowColor: Colors.red,
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Colors.red,
            backgroundColor: Color(0xFF3C4043),
            cardColor: Colors.amberAccent,
            dividerColor: Colors.red,
            dialogBackgroundColor: Colors.blueGrey,
            selectedRowColor: Colors.grey,
          );

    final time = DateFormat.Hms().format(DateTime.now());

    var defaultSmallStyle = TextStyle(
      color: customTheme
          .cardColor, //((customTheme.brightness.toString() == 'light') ? Colors.red : Colors.amberAccent),
      fontSize: 16,
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
//        color: customTheme.backgroundColor,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                Color(customTheme.brightness.toString() == 'Brightness.dark'
                    ? color_list_dark[_backgroundColorCount]
                    : color_list_light[_backgroundColorCount]),
                Color(customTheme.brightness.toString() == 'Brightness.dark'
                    ? color_list_dark[_backgroundColorCount + 1]
                    : color_list_light[_backgroundColorCount + 1]),
              ],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              stops: [0.2, 0.8],
              tileMode: TileMode.clamp),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              // Example of a hand drawn with [Container].
              // Minute Hand
              DrawnHand(
                color: customTheme.primaryColor,
                thickness: 5,
                size: 0.58,
                angleRadians: _now.hour * radiansPerHour +
                    (_now.minute / 60) * radiansPerHour,
              ),
              // Example of a hand drawn with [CustomPainter].
              // Hour Hand
              DrawnHand(
                color: customTheme.highlightColor,
                thickness: 9,
                size: 0.48,
                angleRadians: _now.minute * radiansPerTick,
              ),
              //Second hand
              DrawnHand(
                color: customTheme.accentColor,
                thickness: 3,
                size: 0.68,
                angleRadians: _now.second * radiansPerTick,
              ),
              Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(10.0),
                child: new CustomPaint(
                  painter: new ClockDialPainter(
                      customTheme.dialogBackgroundColor,
                      customTheme.selectedRowColor),
                ),
              ),
              Positioned(
                  left: 5,
                  bottom: 5,
                  child: Text(dateStr, style: defaultSmallStyle)),
              //Weather Info
              Positioned(
                right: 5,
                bottom: 5,
                child: Row(children: <Widget>[
                  Image.asset(
                    'assets/iconfinder_location_115718.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: customTheme.dividerColor,
                  ),
                  Text(' ' + widget.model.location, style: defaultSmallStyle),
                ]),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Row(children: <Widget>[
                  Image.asset(
                    'assets/iconfinder_Thermometer_Warm_3741363.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: customTheme.dividerColor,
                  ),
                  Text(
                      ' ' +
                          widget.model.temperature.toString() +
                          (widget.model.unit == TemperatureUnit.celsius
                              ? ' °C '
                              : ' °F '
                          // widget.model.weatherString + ' ' +
                          ),
                      style: defaultSmallStyle),
                  Image.asset(
                    _weatherImg,
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: customTheme.dividerColor,
                  ),
                ]),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Row(children: <Widget>[
                  Image.asset(
                    'assets/iconfinder_Thermometer_Cold_3741365.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: customTheme.dividerColor,
                  ),
                  Text(' ' + widget.model.lowString + ' ',
                      style: defaultSmallStyle),
                  Image.asset(
                    'assets/iconfinder_Thermometer_Hot_3741361.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: customTheme.dividerColor,
                  ),
                  Text(' ' + widget.model.highString, style: defaultSmallStyle),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color getContrastColor(Color _color) {
    Color y = Color.fromARGB((_color.alpha), (255 - _color.red),
        (255 - _color.blue), (255 - _color.green));
    return y;
  }

  String getWeatherIcon(String _weather) {
    var _aweather = '';
    if ('snowy' == _weather) {
      _aweather = 'iconfinder_Sunny_3741356';
    } else if ('cloudy' == _weather) {
      _aweather = 'iconfinder_Light_Snow_3741353';
    } else if ('foggy' == _weather) {
      _aweather = 'iconfinder_Foggy_3741362';
    } else if ('rainy' == _weather) {
      _aweather = 'iconfinder_Moderate_Rain_3741351';
    } else if ('cloudy' == _weather) {
      _aweather = 'iconfinder_Light_Snow_3741353';
    } else if ('thunderstorm' == _weather) {
      _aweather = 'iconfinder_Thunder_3741360';
    } else if ('snowy' == _weather) {
      _aweather = 'iconfinder_Snow_3741358';
    } else {
      _aweather = 'iconfinder_Sunny_3741356';
    }
    return _aweather;
  }
}
