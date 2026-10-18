import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/feature/presentation/view/widgets/chat_tile.dart';
import 'package:flutter_firebase_chat/src/utils/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../components/not_found_widget.dart';
import '../managers/chat_providers.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  final Color? primaryColor;
  final Widget? floatingActionButton;
  final Widget? aiFloatingActionButton;
  final Function()? onNewChatPressed;
  final Function()? onAIChatPressed;
  final String? searchHint;

  const ChatsScreen({
    super.key,
    this.primaryColor,
    this.floatingActionButton,
    this.aiFloatingActionButton,
    this.onNewChatPressed,
    this.onAIChatPressed,
    this.searchHint,
  });

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = widget.primaryColor ?? const Color(0xffF39200);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? "Search",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            // Chat List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fetchChatsProvider);
                  await Future.delayed(const Duration(milliseconds: 100));
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final provider = ref.watch(fetchChatsProvider);
                    return provider.customWhen(
                      ref: ref,
                      refreshable: fetchChatsProvider.future,
                      skipLoadingOnRefresh: true,
                      skipLoadingOnReload: true,
                      error: (e, st) {
                        return NotFoundWidget(
                          title: "Error occurred".tr,
                          message: e.toString(),
                        );
                      },
                      data: (chats) {
                        final filteredChats = _searchQuery.isEmpty
                            ? chats
                            : chats.where((chat) {
                                return chat.receiverName.toLowerCase().contains(
                                      _searchQuery,
                                    ) ||
                                    chat.lastMessage.toLowerCase().contains(
                                      _searchQuery,
                                    );
                              }).toList();

                        if (filteredChats.isEmpty) {
                          return NotFoundWidget(
                            title: _searchQuery.isEmpty
                                ? "No Chats found".tr
                                : "No results found".tr,
                            message: _searchQuery.isEmpty
                                ? "You have no chats yet".tr
                                : "Try a different search term".tr,
                          );
                        }
                        return ListView.separated(
                          itemBuilder: (context, index) {
                            final conv = filteredChats[index];
                            return ChatTileContainer(
                              chat: conv,
                              primaryColor: orangeColor,
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E5E5),
                            indent: 88,
                          ),
                          itemCount: filteredChats.length,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.floatingActionButton ?? _buildDefaultFABs(orangeColor),
    );
  }

  Widget _buildDefaultFABs(Color orangeColor) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (widget.onAIChatPressed != null ||
            widget.aiFloatingActionButton != null)
          PositionedDirectional(
            end: 0,
            bottom: 80,
            child:
                widget.aiFloatingActionButton ??
                FloatingActionButton(
                  onPressed: widget.onAIChatPressed ?? () {},
                  backgroundColor: orangeColor,
                  mini: true,
                  child: const Icon(Icons.smart_toy, color: Colors.white),
                ),
          ),
        // New Chat FAB (larger, on the left)
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child:
              widget.floatingActionButton ??
              FloatingActionButton(
                onPressed: widget.onNewChatPressed ?? () {},
                backgroundColor: orangeColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
        ),
      ],
    );
  }
}
