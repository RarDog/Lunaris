import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../backend/models/creator_link.dart';

class FormattedContentText extends StatefulWidget {
  const FormattedContentText({
    super.key,
    required this.text,
    this.style,
    this.linkColor,
    this.selectable = true,
  });

  final String text;
  final TextStyle? style;
  final Color? linkColor;
  final bool selectable;

  @override
  State<FormattedContentText> createState() => _FormattedContentTextState();
}

class _FormattedContentTextState extends State<FormattedContentText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось открыть ссылку: $url')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final defaultStyle = widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final linkStyle = defaultStyle.copyWith(
      color: widget.linkColor ?? scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: (widget.linkColor ?? scheme.primary).withValues(alpha: 0.45),
    );

    final text = widget.text;
    if (text.isEmpty) return const SizedBox.shrink();

    final urlRegex = RegExp(r'''https?://[^\s<>"{}|\\^`\[\]]+''', caseSensitive: false);
    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }

      var rawUrl = match.group(0)!;
      var cleanUrl = rawUrl;
      var trailing = '';
      while (cleanUrl.isNotEmpty &&
          (cleanUrl.endsWith(')') ||
              cleanUrl.endsWith('.') ||
              cleanUrl.endsWith(',') ||
              cleanUrl.endsWith(';') ||
              cleanUrl.endsWith('!') ||
              cleanUrl.endsWith('?') ||
              cleanUrl.endsWith(':') ||
              cleanUrl.endsWith('>'))) {
        trailing = cleanUrl[cleanUrl.length - 1] + trailing;
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }

      final recognizer = TapGestureRecognizer()
        ..onTap = () => _launch(cleanUrl);
      _recognizers.add(recognizer);

      spans.add(TextSpan(
        text: cleanUrl,
        style: linkStyle,
        recognizer: recognizer,
      ));

      if (trailing.isNotEmpty) {
        spans.add(TextSpan(
          text: trailing,
          style: defaultStyle,
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    if (widget.selectable) {
      return SelectableText.rich(
        TextSpan(children: spans),
        style: defaultStyle,
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      style: defaultStyle,
    );
  }
}

class CreatorLinkChips extends StatelessWidget {
  const CreatorLinkChips({
    super.key,
    required this.links,
    this.title,
  });

  final List<CreatorLink> links;
  final String? title;

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось открыть ссылку: $url')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 15,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  title!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: links.map((link) {
            final brand = link.brandColor;
            final labelText = link.title.isNotEmpty ? link.title : link.serviceName;

            return Material(
              color: brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openLink(context, link.url),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: brand.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        link.iconData,
                        size: 16,
                        color: brand,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          labelText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 12,
                        color: brand.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
