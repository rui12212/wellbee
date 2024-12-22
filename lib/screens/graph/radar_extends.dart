import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/utils/lerp.dart';
import 'package:flutter/material.dart';

/// Allow maxEntry and minEntry values to be specified with parameters
class RadarChartDataFixMinMax extends RadarChartData {
  RadarChartDataFixMinMax(
      {required super.dataSets,
      super.radarBackgroundColor,
      super.radarBorderData,
      super.radarShape,
      super.getTitle,
      super.titleTextStyle,
      super.titlePositionPercentageOffset,
      super.tickCount,
      super.ticksTextStyle,
      super.tickBorderData,
      super.gridBorderData,
      super.radarTouchData,
      super.borderData,
      this.max,
      this.min});

  final RadarEntry? max;

  final RadarEntry? min;

  @override
  RadarEntry get maxEntry => max ?? super.maxEntry;

  @override
  RadarEntry get minEntry => min ?? super.minEntry;

  @override
  RadarChartData copyWith(
      {List<RadarDataSet>? dataSets,
      Color? radarBackgroundColor,
      BorderSide? radarBorderData,
      RadarShape? radarShape,
      GetTitleByIndexFunction? getTitle,
      TextStyle? titleTextStyle,
      double? titlePositionPercentageOffset,
      int? tickCount,
      TextStyle? ticksTextStyle,
      BorderSide? tickBorderData,
      BorderSide? gridBorderData,
      RadarTouchData? radarTouchData,
      FlBorderData? borderData,
      RadarEntry? max,
      RadarEntry? min}) {
    return RadarChartDataFixMinMax(
      dataSets: dataSets ?? this.dataSets,
      radarBackgroundColor: radarBackgroundColor ?? this.radarBackgroundColor,
      radarBorderData: radarBorderData ?? this.radarBorderData,
      radarShape: radarShape ?? this.radarShape,
      getTitle: getTitle ?? this.getTitle,
      titleTextStyle: titleTextStyle ?? this.ticksTextStyle,
      titlePositionPercentageOffset:
          titlePositionPercentageOffset ?? this.titlePositionPercentageOffset,
      tickCount: tickCount ?? this.tickCount,
      ticksTextStyle: ticksTextStyle ?? this.ticksTextStyle,
      tickBorderData: tickBorderData ?? this.tickBorderData,
      gridBorderData: gridBorderData ?? this.gridBorderData,
      radarTouchData: radarTouchData ?? this.radarTouchData,
      borderData: borderData ?? this.borderData,
      max: max ?? this.max,
      min: min ?? this.min,
    );
  }

  @override
  RadarChartData lerp(BaseChartData a, BaseChartData b, double t) {
    if (a is RadarChartDataFixMinMax && b is RadarChartDataFixMinMax) {
      return RadarChartDataFixMinMax(
        dataSets: lerpRadarDataSetList(a.dataSets, b.dataSets, t),
        radarBackgroundColor:
            Color.lerp(a.radarBackgroundColor, b.radarBackgroundColor, t),
        getTitle: b.getTitle,
        titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
        titlePositionPercentageOffset: lerpDouble(
          a.titlePositionPercentageOffset,
          b.titlePositionPercentageOffset,
          t,
        ),
        tickCount: lerpInt(a.tickCount, b.tickCount, t),
        ticksTextStyle: TextStyle.lerp(a.ticksTextStyle, b.ticksTextStyle, t),
        gridBorderData: BorderSide.lerp(a.gridBorderData, b.gridBorderData, t),
        radarBorderData:
            BorderSide.lerp(a.radarBorderData, b.radarBorderData, t),
        radarShape: b.radarShape,
        tickBorderData: BorderSide.lerp(a.tickBorderData, b.tickBorderData, t),
        borderData: FlBorderData.lerp(a.borderData, b.borderData, t),
        radarTouchData: b.radarTouchData,
        max: RadarEntry.lerp(a.maxEntry, b.maxEntry, t),
        min: RadarEntry.lerp(a.minEntry, b.minEntry, t),
      );
    } else {
      return super.lerp(a, b, t);
    }
  }
}
