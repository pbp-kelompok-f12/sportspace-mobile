import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportspace_app/models/friend_entry.dart';

// ==========================================
// 1. MODEL CHAT ITEM
// ==========================================
class ChatMessageItem {
  final String sender;
  final String message;
  final String timestamp;

  ChatMessageItem({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      sender: json['sender'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

// ==========================================
// 2. CHAT PAGE UTAMA
// ==========================================
class ChatPage extends StatefulWidget {
  final Friend friend;
  const ChatPage({super.key, required this.friend});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // === CONFIG & COLORS ===
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color accentOrange = const Color(0xFFF87E18);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textGrey = const Color(0xFF64748B);

  // === STATE ===
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessageItem> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // === HELPER: IMAGE URL FIXER ===
  ImageProvider _getProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage("assets/images/defaultprofile.png");
    }
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    return NetworkImage("$baseUrl$url");
  }

  // === API FETCH & SEND (Sama seperti sebelumnya) ===
  Future<void> fetchMessages() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/accounts/chat/${widget.friend.username}/');
      if (response['success']) {
        List<dynamic> rawMessages = response['messages'];
        if (mounted) {
          setState(() {
            messages = rawMessages.map((m) => ChatMessageItem.fromJson(m)).toList();
            isLoading = false;
          });
          _scrollToBottom();
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetch: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    final request = context.read<CookieRequest>();
    final tempMessage = ChatMessageItem(
      sender: "me",
      message: text,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(() {
      messages.add(tempMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await request.post(
        '$baseUrl/accounts/chat-send/',
        {'username': widget.friend.username, 'message': text},
      );
      if (response['success']) fetchMessages();
    } catch (e) {
      debugPrint("Error send: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // === UI BUILDER ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: bgLight,
              backgroundImage: _getProfileImage(widget.friend.photoUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.friend.username,
                    style: TextStyle(
                        color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // === LIST PESAN ===
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: accentOrange))
                : messages.isEmpty
                    ? Center(
                        child: Text("Belum ada percakapan.", style: TextStyle(color: textGrey)),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          bool isMe = msg.sender != widget.friend.username;

                          // --- LOGIKA TANGGAL ---
                          bool showDate = false;
                          if (index == 0) {
                            // Pesan pertama -> Tampilkan Tanggal
                            showDate = true;
                          } else {
                            // Cek apakah tanggal pesan ini BEDA dengan pesan sebelumnya
                            final prevMsg = messages[index - 1];
                            if (!_isSameDay(msg.timestamp, prevMsg.timestamp)) {
                              showDate = true;
                            }
                          }

                          if (showDate) {
                            return Column(
                              children: [
                                _buildDateSeparator(msg.timestamp),
                                _buildChatBubble(msg, isMe),
                              ],
                            );
                          } else {
                            return _buildChatBubble(msg, isMe);
                          }
                        },
                      ),
          ),

          // === INPUT AREA (Sama) ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                // Icon(Icons.add_circle_outline_rounded, color: textGrey, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Tulis pesan...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                      ),
                      minLines: 1, maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: sendMessage,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: accentOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET: DATE SEPARATOR ===
  Widget _buildDateSeparator(String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(timestamp),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // === LOGIC: CEK APAKAH TANGGAL SAMA ===
  bool _isSameDay(String iso1, String iso2) {
    try {
      DateTime d1 = DateTime.parse(iso1).toLocal();
      DateTime d2 = DateTime.parse(iso2).toLocal();
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (e) {
      return false;
    }
  }

  // === LOGIC: FORMAT TANGGAL HEADER ===
  String _formatDateHeader(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      DateTime now = DateTime.now();
      
      // Jika Hari Ini
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return "Hari Ini";
      }
      
      // Jika Kemarin
      DateTime yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
        return "Kemarin";
      }

      // Format Tanggal Biasa (dd MMM yyyy)
      // Gunakan package intl untuk hasil lebih bagus: DateFormat("d MMM yyyy").format(dt)
      // Ini versi manual sederhana:
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "-";
    }
  }

  // === WIDGET: BUBBLE CHAT (Sama) ===
  Widget _buildChatBubble(ChatMessageItem msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? primaryNavy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }
}