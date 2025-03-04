import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class ReportCreatorTitle extends StatefulWidget {
  const ReportCreatorTitle({
    required this.state,
    super.key,
  });

  final SnaplyState state;

  @override
  State<ReportCreatorTitle> createState() => _ReportCreatorTitleState();
}

class _ReportCreatorTitleState extends State<ReportCreatorTitle> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.title);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newText = _controller.text;
    if (newText != widget.state.title) {
      context.act(UpdateReportTitle(newText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLength: 50,
          style: titleStyle,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter report title',
            hintStyle: titleStyle?.copyWith(
              color: titleStyle.color?.withOpacity(0.5),
            ),
            counterText: '',
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }
}
