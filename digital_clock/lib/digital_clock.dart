// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element { background, text, shadow, theme, imgColor, txtColor }

final _lightTheme = {
  _Element.background: Color(0xFFD1B3FE),
  _Element.text: Colors.redAccent,
  _Element.shadow: Colors.black,
  _Element.theme: 'light',
  _Element.imgColor: Colors.amberAccent,
  _Element.txtColor: Colors.blue,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
  _Element.theme: 'dark',
  _Element.imgColor: Colors.amberAccent,
  _Element.txtColor: Colors.redAccent,
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _weatherImg = '';
//  var color_list = [];

  static var color_list_light1 = [
    Color(0xFF1abc9c),
    Color(0xFF2ecc71),
    Color(0xFF3498db),
    Color(0xFF673AB7),
    Color(0xFFC74EA6),
    Color(0xFFCC66FF),
    Color(0xFF8BC34A),
  ];
  static var color_list_dark1 = [
    Color(0xFF333300),
    Color(0xFF424242),
    Color(0xFF4E342E),
    Color(0xFF3E2723),
    Color(0xFF57575),
    Color(0xFF455A64),
    Color(0xFF37474F),
  ];
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
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
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
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _weatherImg =
          'assets/' + this.getWeatherIcon(widget.model.weatherString) + '.png';
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      _backgroundColorCount =
          (int.parse(DateFormat('s').format(_dateTime)) / 10).round();
      if (_backgroundColorCount == 6) {
        _backgroundColorCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final timeStr = DateFormat(
            widget.model.is24HourFormat ? 'HH : mm : ss' : 'hh : mm : ss aa')
        .format(_dateTime);
    final dateStr = DateFormat('E dd : MM : yyyy').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 10;

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Orbitron',
      fontSize: fontSize,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(2, 0),
        ),
      ],
    );
    final defaultSubStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Orbitron',
      fontSize: fontSize / 2,
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(2, 0),
        ),
      ],
    );

    final defaultSmallStyle = TextStyle(
      color: colors[_Element.txtColor],
      fontSize: 18,
    );

    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              Color(colors[_Element.theme].toString() == 'dark'
                  ? color_list_dark[_backgroundColorCount]
                  : color_list_light[_backgroundColorCount]),
              Color(colors[_Element.theme].toString() == 'dark'
                  ? color_list_dark[_backgroundColorCount + 1]
                  : color_list_light[_backgroundColorCount + 1]),
            ],
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomRight,
            stops: [0.2, 0.8],
            tileMode: TileMode.clamp),
      ),
      child: Center(
        child: Container(
          child: Stack(
            children: <Widget>[
              Center(
                child: Wrap(
                  children: [
                    Center(child: Text(timeStr, style: defaultStyle)),
                    Center(child: Text(dateStr, style: defaultSubStyle)),
                  ],
                ),
              ),
              Positioned(
                right: 5,
                bottom: 5,
                child: Row(children: <Widget>[
                  Image.asset(
                    'assets/iconfinder_location_115718.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: colors[_Element.imgColor],
                  ),
                  Text(widget.model.location, style: defaultSmallStyle),
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
                    color: colors[_Element.imgColor],
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
                    color: colors[_Element.imgColor],
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
                    color: colors[_Element.imgColor],
                  ),
                  Text(' ' + widget.model.lowString + ' ',
                      style: defaultSmallStyle),
                  Image.asset(
                    'assets/iconfinder_Thermometer_Hot_3741361.png',
                    fit: BoxFit.cover,
                    width: 18,
                    height: 18,
                    color: colors[_Element.imgColor],
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
    var _aweather;
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

  int hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }
}
