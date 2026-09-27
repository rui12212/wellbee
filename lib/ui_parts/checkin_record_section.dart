import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wellbee/assets/inet.dart';
import 'package:wellbee/ui_function/shared_prefs.dart';
import 'package:wellbee/ui_parts/color.dart';

/// 暦の半期。half は 0 が 1〜6月、1 が 7〜12月。
class _HalfYear {
  final int year;
  final int half;

  const _HalfYear(this.year, this.half);

  /// 並べ替えと比較に使う通し番号
  int get index => year * 2 + half;

  int get firstMonth => half * 6 + 1;

  String get label {
    final from = DateFormat('MMM').format(DateTime(year, firstMonth));
    final to = DateFormat('MMM').format(DateTime(year, firstMonth + 5));
    return '$from – $to $year';
  }

  static _HalfYear of(int year, int month) =>
      _HalfYear(year, month <= 6 ? 0 : 1);
}

/// ホーム画面に置くチェックイン記録セクション。
/// 月ごとのチェックイン回数を棒グラフで表示し、下にコース別の内訳を並べる。
/// 横スワイプで過去の半期へ遡れる。
class CheckInRecordSection extends StatefulWidget {
  const CheckInRecordSection({super.key});

  @override
  State<CheckInRecordSection> createState() => _CheckInRecordSectionState();
}

class _CheckInRecordSectionState extends State<CheckInRecordSection> {
  bool _isLoading = true;
  String? _errorMessage;

  /// '2026-07' → { 'Yoga': 4, 'Flamenco': 2 }
  final Map<String, Map<String, int>> _countsByMonth = {};

  /// 表示対象の半期。古い順に並ぶ。
  List<_HalfYear> _halves = [];

  /// 全期間の「月合計」の最大値から決めた縦軸の上限。
  /// ページごとに再計算しないので、横スクロールしてもバーの高さの意味が変わらない。
  double _axisMax = 10;

  PageController? _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyCheckIns();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _fetchMonthlyCheckIns() async {
    try {
      final token = await SharedPrefs.fetchAccessToken();
      final url = Uri.parse(
          '${baseUri}attendances/checkin/my_monthly_checkin/?token=$token');
      final response = await Future.any([
        http.get(url, headers: {
          "Authorization": 'JWT $token',
          "Content-Type": "application/json",
        }),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException("Request Timeout")),
      ]);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _processData(data);
        setState(() => _isLoading = false);
      } else if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Internet Error occurred';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Try again later';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _processData(List<dynamic> data) {
    var oldest = _HalfYear.of(DateTime.now().year, DateTime.now().month);

    for (final row in data) {
      final month = row['month'] as String?;
      final courseName = (row['course_name'] as String?) ?? 'Other';
      final count = (row['count'] as num?)?.toInt() ?? 0;
      if (month == null || count <= 0) continue;

      final parts = month.split('-');
      if (parts.length < 2) continue;
      final year = int.tryParse(parts[0]);
      final monthNumber = int.tryParse(parts[1]);
      if (year == null || monthNumber == null) continue;

      _countsByMonth.putIfAbsent(month, () => {});
      _countsByMonth[month]![courseName] =
          (_countsByMonth[month]![courseName] ?? 0) + count;

      final half = _HalfYear.of(year, monthNumber);
      if (half.index < oldest.index) oldest = half;
    }

    // 全期間の月合計の最大値から縦軸の上限を決める
    var maxMonthlyTotal = 0;
    for (final counts in _countsByMonth.values) {
      final total = counts.values.fold<int>(0, (sum, v) => sum + v);
      if (total > maxMonthlyTotal) maxMonthlyTotal = total;
    }
    _axisMax = ((maxMonthlyTotal ~/ 10) + 1) * 10.0;

    // 最古の半期から現在の半期まで。未来の半期は作らない。
    final now = DateTime.now();
    final latest = _HalfYear.of(now.year, now.month);
    final halves = <_HalfYear>[];
    for (var index = oldest.index; index <= latest.index; index++) {
      halves.add(_HalfYear(index ~/ 2, index % 2));
    }
    _halves = halves;
    _currentPage = halves.length - 1;
    _pageController = PageController(initialPage: _currentPage);
  }

  /// 縦軸の目盛り間隔
  double _axisInterval() {
    if (_axisMax <= 10) return 5;
    if (_axisMax <= 40) return 10;
    return (_axisMax / 4 / 10).ceil() * 10;
  }

  String _monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  /// その半期のコース別合計を、多い順に並べて返す
  List<MapEntry<String, int>> _courseTotalsOf(_HalfYear half) {
    final totals = <String, int>{};
    for (var i = 0; i < 6; i++) {
      final counts = _countsByMonth[_monthKey(half.year, half.firstMonth + i)];
      if (counts == null) continue;
      counts.forEach((course, count) {
        totals[course] = (totals[course] ?? 0) + count;
      });
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _halves.length) return;
    _pageController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        height: 160.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return SizedBox(
        width: double.infinity,
        height: 160.h,
        child: Center(
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
          ),
        ),
      );
    }
    if (_countsByMonth.isEmpty || _halves.isEmpty) {
      return Container(
        width: double.infinity,
        height: 160.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 40.sp, color: Colors.grey.shade300),
            SizedBox(height: 10.h),
            Text(
              'No check-in yet.',
              style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
            ),
          ],
        ),
      );
    }

    final half = _halves[_currentPage];
    final courseTotals = _courseTotalsOf(half);
    final halfTotal = courseTotals.fold<int>(0, (sum, e) => sum + e.value);

    // ホーム画面が長くなりすぎないよう、上位3件だけ出して残りは Others にまとめる
    final topCourses = courseTotals.take(3).toList();
    final restCourses = courseTotals.skip(3).toList();
    final restTotal = restCourses.fold<int>(0, (sum, e) => sum + e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
          child: Column(
            children: [
              _buildPeriodRow(half),
              SizedBox(height: 14.h),
              SizedBox(
                height: 230.h,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _halves.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) => _buildChart(_halves[index]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Courses',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8.w),
            Text(
              half.label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (courseTotals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'No check-in in this period.',
              style: TextStyle(fontSize: 14.sp, color: kColorTextDarkGrey),
            ),
          )
        else ...[
          ...topCourses.map((entry) => _buildLegendRow(entry.key, entry.value)),
          if (restCourses.isNotEmpty)
            _buildLegendRow(
              'Others',
              restTotal,
              note: restCourses.length == 1
                  ? '1 course'
                  : '${restCourses.length} courses',
              dotColor: Colors.grey.shade400,
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(height: 1.h, color: Colors.grey.shade200),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$halfTotal',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: kColorPrimary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodRow(_HalfYear half) {
    final hasPrevious = _currentPage > 0;
    final hasNext = _currentPage < _halves.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildArrowButton(
          icon: Icons.arrow_back_ios_new,
          enabled: hasPrevious,
          onTap: () => _goToPage(_currentPage - 1),
        ),
        Text(
          half.label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        _buildArrowButton(
          icon: Icons.arrow_forward_ios,
          enabled: hasNext,
          onTap: () => _goToPage(_currentPage + 1),
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(17.r),
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: enabled ? Colors.grey.shade100 : Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14.sp,
            color: enabled ? kColorTextDarkGrey : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow(
    String courseName,
    int count, {
    String? note,
    Color? dotColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: dotColor ?? kColorPrimary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    courseName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                if (note != null) ...[
                  SizedBox(width: 6.w),
                  Text(
                    note,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(_HalfYear half) {
    final now = DateTime.now();
    final currentMonthIndex = DateTime(now.year, now.month);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _axisMax,
        minY: 0,
        barGroups: List.generate(6, (i) {
          final month = half.firstMonth + i;
          final isFuture =
              DateTime(half.year, month).isAfter(currentMonthIndex);
          final counts = _countsByMonth[_monthKey(half.year, month)];

          if (isFuture || counts == null || counts.isEmpty) {
            return BarChartGroupData(x: i, barRods: const []);
          }

          final total =
              counts.values.fold<int>(0, (sum, v) => sum + v).toDouble();

          return BarChartGroupData(
            x: i,
            showingTooltipIndicators: const [0],
            barRods: [
              BarChartRodData(
                toY: total,
                width: 22.w,
                color: kColorPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
              ),
            ],
          );
        }),
        // バーの上に月の合計回数を常時表示する
        barTouchData: BarTouchData(
          enabled: false,
          handleBuiltInTouches: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 4.h,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: kColorTextDarkGrey,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _axisInterval(),
              reservedSize: 28.w,
              getTitlesWidget: (value, meta) {
                if (value > _axisMax) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Text(
                    value.toInt().toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24.h,
              getTitlesWidget: (value, meta) {
                final month = half.firstMonth + value.toInt();
                final isFuture =
                    DateTime(half.year, month).isAfter(currentMonthIndex);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(DateTime(half.year, month)),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                          isFuture ? Colors.grey.shade300 : kColorTextDarkGrey,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _axisInterval(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
      ),
    );
  }
}
