// ignore_for_file: unused_element, experimental_member_use

import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AppDropdownSlashEditor extends StatefulWidget {
  const AppDropdownSlashEditor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppDropdownSlashEditorState createState() => _AppDropdownSlashEditorState();
}

class _AppDropdownSlashEditorState extends State<AppDropdownSlashEditor> {
  final QuillController _controller = () {
    return QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onImagePaste: (imageBytes) async {
            // Save the image somewhere and return the image URL that will be
            // stored in the Quill Delta JSON (the document).
            final newFileName =
                'image-file-${DateTime.now().toIso8601String()}.png';
            final newPath = path.join(
              io.Directory.systemTemp.path,
              newFileName,
            );
            final file = await io.File(
              newPath,
            ).writeAsBytes(imageBytes, flush: true);
            return file.path;
          },
        ),
      ),
    );
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final AppDropdownController _dropdownController = AppDropdownController();

  bool _showSlashDropdown = false;
  int _slashPosition = -1;
  String _searchQuery = '';

  // Command options for the dropdown
  final List<SlashCommandOption> _allCommands = [
    SlashCommandOption(
      id: 'task_list',
      icon: Icons.checklist,
      title: 'To-do List',
      description: 'Create a task list with checkboxes',
      action: SlashAction.todoList,
      searchTerms: ['todo', 'task', 'checkbox', 'check'],
    ),
    SlashCommandOption(
      id: 'heading1',
      icon: Icons.title,
      title: 'Heading 1',
      description: 'Big section heading',
      action: SlashAction.heading1,
      searchTerms: ['h1', 'heading', 'title', 'large'],
    ),
    SlashCommandOption(
      id: 'heading2',
      icon: Icons.title,
      title: 'Heading 2',
      description: 'Medium section heading',
      action: SlashAction.heading2,
      searchTerms: ['h2', 'heading', 'subtitle'],
    ),
    SlashCommandOption(
      id: 'heading3',
      icon: Icons.title,
      title: 'Heading 3',
      description: 'Small section heading',
      action: SlashAction.heading3,
      searchTerms: ['h3', 'heading', 'small'],
    ),
    SlashCommandOption(
      id: 'bullet_list',
      icon: Icons.format_list_bulleted,
      title: 'Bullet List',
      description: 'Create a bulleted list',
      action: SlashAction.bulletList,
      searchTerms: ['list', 'bullet', 'ul', 'unordered'],
    ),
    SlashCommandOption(
      id: 'numbered_list',
      icon: Icons.format_list_numbered,
      title: 'Numbered List',
      description: 'Create a numbered list',
      action: SlashAction.numberedList,
      searchTerms: ['list', 'numbered', 'ol', 'ordered'],
    ),
    SlashCommandOption(
      id: 'quote',
      icon: Icons.format_quote,
      title: 'Quote',
      description: 'Insert a blockquote',
      action: SlashAction.quote,
      searchTerms: ['quote', 'blockquote', 'citation'],
    ),
    SlashCommandOption(
      id: 'code_block',
      icon: Icons.code,
      title: 'Code Block',
      description: 'Insert a code block',
      action: SlashAction.codeBlock,
      searchTerms: ['code', 'block', 'programming'],
    ),
    // SlashCommandOption(
    //   id: 'image',
    //   icon: Icons.image,
    //   title: 'Image',
    //   description: 'Upload an image from your computer',
    //   action: SlashAction.image,
    //   searchTerms: ['code', 'block', 'programming'],
    // ),
    // SlashCommandOption(
    //   id: 'video',
    //   icon: Icons.video_call,
    //   title: 'Loom/YouTube',
    //   description: 'Embed video',
    //   action: SlashAction.video,
    //   searchTerms: ['code', 'block', 'programming'],
    // ),
  ];

  List<SlashCommandOption> get _filteredCommands {
    if (_searchQuery.isEmpty) return _allCommands;

    return _allCommands.where((command) {
      final query = _searchQuery.toLowerCase();
      return command.title.toLowerCase().contains(query) ||
          command.description.toLowerCase().contains(query) ||
          command.searchTerms.any((term) => term.contains(query));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final selection = _controller.selection;
    if (!selection.isCollapsed) {
      _hideSlashDropdown();
      return;
    }

    final text = _controller.document.toPlainText();
    final cursorPosition = selection.baseOffset;

    if (cursorPosition > 0 && cursorPosition <= text.length) {
      // Look backwards from cursor to find '/'
      int slashIndex = -1;
      String afterSlash = '';

      for (int i = cursorPosition - 1; i >= 0; i--) {
        if (text[i] == '/') {
          slashIndex = i;
          afterSlash = text.substring(i + 1, cursorPosition);
          break;
        }
        if (text[i] == ' ' || text[i] == '\n') {
          break;
        }
      }

      if (slashIndex != -1) {
        // Check if we're at the start of a line or after a space
        bool validSlashPosition =
            slashIndex == 0 ||
            text[slashIndex - 1] == '\n' ||
            text[slashIndex - 1] == ' ';

        if (validSlashPosition &&
            !afterSlash.contains(' ') &&
            !afterSlash.contains('\n')) {
          _slashPosition = slashIndex;
          _searchQuery = afterSlash;
          _showDropdown();
          return;
        }
      }
    }

    _hideSlashDropdown();
  }

  void _showDropdown() {
    if (!_showSlashDropdown) {
      setState(() {
        _showSlashDropdown = true;
      });
      // Small delay to ensure the dropdown button is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dropdownController.open();
      });
    }
  }

  void _hideSlashDropdown() {
    if (_showSlashDropdown) {
      setState(() {
        _showSlashDropdown = false;
        _searchQuery = '';
      });
      _dropdownController.close();
    }
  }

  void _executeCommand(SlashCommandOption command) {
    _hideSlashDropdown();

    // Remove the slash and search text
    final selection = _controller.selection;
    final cursorPosition = selection.baseOffset;

    if (_slashPosition != -1 && _slashPosition < cursorPosition) {
      _controller.replaceText(
        _slashPosition,
        cursorPosition - _slashPosition,
        '',
        TextSelection.collapsed(offset: _slashPosition),
      );
    }

    // Apply the formatting
    _applyFormatting(command.action);

    // Focus back to editor
    _editorFocusNode.requestFocus();
  }

  void _applyFormatting(SlashAction action) {
    switch (action) {
      case SlashAction.heading1:
        _controller.formatSelection(Attribute.header);
        break;
      case SlashAction.heading2:
        _controller.formatSelection(Attribute.h2);
        break;
      case SlashAction.heading3:
        _controller.formatSelection(Attribute.h3);
        break;
      case SlashAction.bulletList:
        _controller.formatSelection(Attribute.ul);
        break;
      case SlashAction.numberedList:
        _controller.formatSelection(Attribute.ol);
        break;
      case SlashAction.todoList:
        _controller.formatSelection(
          Attribute('list', AttributeScope.block, 'checked'),
        );
        break;
      case SlashAction.codeBlock:
        _controller.formatSelection(Attribute.codeBlock);
        break;
      case SlashAction.quote:
        _controller.formatSelection(Attribute.blockQuote);
        break;
      case SlashAction.image:
        BlockEmbed.image("imageUrl");
        break;
      case SlashAction.video:
        BlockEmbed.video(
          "youtube.com/watch?v=VjmcQ19vpWg&list=PLpCqPSEm2Xe8sEY2haMDUVgwbkIs5NCJI&index=56",
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommands = _filteredCommands;

    return Stack(
      children: [
        // Main Editor
        SizedBox(
          child: QuillEditor(
            focusNode: _editorFocusNode,
            scrollController: _editorScrollController,
            controller: _controller,
            config: QuillEditorConfig(
              placeholder: "Press '/' for commands",
              padding: const EdgeInsets.all(16),
              embedBuilders: [
                ...FlutterQuillEmbeds.editorBuilders(
                  imageEmbedConfig: QuillEditorImageEmbedConfig(
                    imageProviderBuilder: (context, imageUrl) {
                      // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                      if (imageUrl.startsWith('assets/')) {
                        return AssetImage(imageUrl);
                      }
                      return null;
                    },
                  ),
                  videoEmbedConfig: QuillEditorVideoEmbedConfig(
                    customVideoBuilder: (videoUrl, readOnly) {
                      // Example: Check for YouTube Video URL and return your
                      // YouTube video widget here.
                      bool isYouTubeUrl(String videoUrl) {
                        try {
                          final uri = Uri.parse(videoUrl);
                          return uri.host == 'www.youtube.com' ||
                              uri.host == 'youtube.com' ||
                              uri.host == 'youtu.be' ||
                              uri.host == 'www.youtu.be';
                        } catch (_) {
                          return false;
                        }
                      }

                      // if (isYouTubeUrl(videoUrl)) {
                      return YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId: "iLnmTe5Q2Qw",
                        ),
                        showVideoProgressIndicator: true,
                      );
                      // }

                      // Return null to fallback to the default logic
                      // return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Invisible dropdown trigger positioned at cursor
        if (_showSlashDropdown)
          AppDropdown<SlashCommandOption>(
            controller: _dropdownController,
            overlayWidth: 320,
            overlayHeight: 400,
            gapFromButton: 40,
            alignWithDevice: false,
            overlayColor: const Color(0xFF2D2D2D),
            overlayRadius: 8,
            button: const SizedBox.shrink(), // Invisible button
            items: filteredCommands
                .map(
                  (command) => AppDropdownItem<SlashCommandOption>(
                    value: command,
                    queryString:
                        '${command.title} ${command.description} ${command.searchTerms.join(' ')}',
                    height: 56,
                    child: _SlashCommandWidget(command: command),
                  ),
                )
                .toList(),
            onItemSelected: _executeCommand,
          ),
      ],
    );
  }
}

// Custom widget for each slash command item
class _SlashCommandWidget extends StatelessWidget {
  final SlashCommandOption command;

  const _SlashCommandWidget({required this.command});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(command.icon, size: 18, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  command.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  command.description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data classes
enum SlashAction {
  todoList,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  quote,
  codeBlock,
  image,
  video,
}

class SlashCommandOption {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final SlashAction action;
  final List<String> searchTerms;

  SlashCommandOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.searchTerms,
  });
}
