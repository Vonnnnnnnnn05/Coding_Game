import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:highlight/languages/cpp.dart' as cpp_lang;
import 'package:highlight/languages/cs.dart' as cs_lang;
import 'package:highlight/languages/java.dart' as java_lang;
import 'package:highlight/languages/javascript.dart' as js_lang;
import 'package:highlight/languages/python.dart' as py_lang;

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../editor/data/language_config.dart';
import '../../submissions/data/submission_repository.dart';
import '../../submissions/domain/submission.dart';
import '../domain/challenge.dart';
import 'challenge_providers.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);
    return challenges.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (items) {
        final challenge = items.firstWhere((item) => item.id == challengeId);
        return _ChallengeWorkspace(challenge: challenge);
      },
    );
  }
}

class _ChallengeWorkspace extends ConsumerStatefulWidget {
  const _ChallengeWorkspace({required this.challenge});

  final Challenge challenge;

  @override
  ConsumerState<_ChallengeWorkspace> createState() =>
      _ChallengeWorkspaceState();
}

class _ChallengeWorkspaceState extends ConsumerState<_ChallengeWorkspace> {
  LanguageConfig _language = supportedLanguages.first;
  late CodeController _controller;
  bool _running = false;
  bool _submitting = false;
  Submission? _lastSubmission;

  @override
  void initState() {
    super.initState();
    _controller = _newController(_starterFor(_language));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final description = _DescriptionPanel(challenge: widget.challenge);
    final editor = _EditorPanel(
      language: _language,
      controller: _controller,
      lastSubmission: _lastSubmission,
      running: _running,
      submitting: _submitting,
      onLanguageChanged: _changeLanguage,
      onRun: _runCode,
      onSubmit: _submit,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go('/challenges'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.challenge.title),
        actions: [DifficultyChip(difficulty: widget.challenge.difficulty)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: description),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: editor),
                  ],
                )
              : ListView(
                  children: [
                    description,
                    const SizedBox(height: 16),
                    SizedBox(height: 720, child: editor),
                  ],
                ),
        ),
      ),
    );
  }

  void _changeLanguage(LanguageConfig? language) {
    if (language == null || language == _language) return;
    setState(() {
      _language = language;
      final old = _controller;
      _controller = _newController(_starterFor(language));
      old.dispose();
    });
  }

  Future<void> _runCode() async {
    setState(() => _running = true);
    try {
      final submission = await ref
          .read(submissionControllerProvider.notifier)
          .runCode(
            challenge: widget.challenge,
            language: _language,
            code: _controller.text,
          );
      setState(() => _lastSubmission = submission);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final submission = await ref
          .read(submissionControllerProvider.notifier)
          .submit(
            challenge: widget.challenge,
            language: _language,
            code: _controller.text,
          );
      setState(() => _lastSubmission = submission);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _starterFor(LanguageConfig language) {
    return widget.challenge.starterCode[language.key] ?? '';
  }

  CodeController _newController(String text) {
    return CodeController(
      text: text,
      language: switch (_language.key) {
        'python' => py_lang.python,
        'cpp' => cpp_lang.cpp,
        'java' => java_lang.java,
        'javascript' => js_lang.javascript,
        'csharp' => cs_lang.cs,
        _ => py_lang.python,
      },
    );
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Execution failed: $error')));
  }
}

class _DescriptionPanel extends StatelessWidget {
  const _DescriptionPanel({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(challenge.description),
          const SizedBox(height: 16),
          Text('Examples', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final example in challenge.examples)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SelectableText(
                'Input:\n${example.input}\n\nOutput:\n${example.output}\n\n${example.explanation}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          Text('Constraints', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final constraint in challenge.constraints)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('- $constraint'),
            ),
        ],
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.language,
    required this.controller,
    required this.lastSubmission,
    required this.running,
    required this.submitting,
    required this.onLanguageChanged,
    required this.onRun,
    required this.onSubmit,
  });

  final LanguageConfig language;
  final CodeController controller;
  final Submission? lastSubmission;
  final bool running;
  final bool submitting;
  final ValueChanged<LanguageConfig?> onLanguageChanged;
  final VoidCallback onRun;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<LanguageConfig>(
                  initialValue: language,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: supportedLanguages
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: onLanguageChanged,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: running || submitting ? null : onRun,
                icon: running
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Run'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: running || submitting ? null : onSubmit,
                icon: submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: const Text('Submit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CodeTheme(
                  data: CodeThemeData(styles: atomOneDarkTheme),
                  child: CodeField(
                    controller: controller,
                    expands: true,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ResultPanel(submission: lastSubmission),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.submission});

  final Submission? submission;

  @override
  Widget build(BuildContext context) {
    if (submission == null) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text('Run or submit code to see feedback.'),
      );
    }
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SubmissionStatusChip(status: submission!.status),
              const SizedBox(width: 12),
              Text('Time: ${submission!.runtimeMs ?? 0} ms'),
              const SizedBox(width: 12),
              Text('Memory: ${submission!.memoryKb ?? 0} KB'),
            ],
          ),
          if ((submission!.output ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText('Output:\n${submission!.output}'),
          ],
          if ((submission!.error ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText('Error:\n${submission!.error}'),
          ],
        ],
      ),
    );
  }
}
