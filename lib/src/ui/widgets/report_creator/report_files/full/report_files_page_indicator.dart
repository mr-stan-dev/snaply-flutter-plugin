import 'package:flutter/material.dart';

class ReportFilesPageIndicator extends StatelessWidget {
  const ReportFilesPageIndicator({
    required this.currentPage,
    required this.length,
    super.key,
  });

  final int currentPage;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (i) => _indicatorItem(context, i)),
      ),
    );
  }

  Widget _indicatorItem(BuildContext context, int page) {
    final color = page == currentPage
        ? Theme.of(context).primaryColor
        : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
          color: color,
        ),
      ),
    );
  }
}
