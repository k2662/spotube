import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spotube/hooks/use_breakpoints.dart';

class AdaptiveSelectTile<T> extends HookWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final ListTileControlAffinity? controlAffinity;
  final T value;
  final ValueChanged<T?>? onChanged;

  final List<DropdownMenuItem<T>> options;

  final Breakpoints breakAfterOr;

  const AdaptiveSelectTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.options,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.subtitle,
    this.secondary,
    this.breakAfterOr = Breakpoints.md,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoint = useBreakpoints();
    final rawControl = DropdownButton<T>(
      items: options,
      value: value,
      onChanged: onChanged,
    );
    final controlPlaceholder = useMemoized(
        () => options
            .firstWhere(
              (element) => element.value == value,
              orElse: () => DropdownMenuItem<T>(
                value: null,
                child: Container(),
              ),
            )
            .child,
        [value, options]);

    final control = breakpoint >= breakAfterOr
        ? rawControl
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
              child: controlPlaceholder,
            ),
          );

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: controlAffinity != ListTileControlAffinity.leading
          ? secondary
          : control,
      trailing: controlAffinity == ListTileControlAffinity.leading
          ? secondary
          : control,
      onTap: breakpoint >= breakAfterOr
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: title,
                    children: [
                      for (final option in options)
                        RadioListTile<T>(
                          title: option.child,
                          value: option.value as T,
                          groupValue: value,
                          onChanged: (v) {
                            Navigator.pop(context);
                            onChanged?.call(v);
                          },
                        ),
                    ],
                  );
                },
              );
            },
    );
  }
}